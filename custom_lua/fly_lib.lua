local FlyLib=
{
    UnitClasses=
    {
        CoreUnit           = { need = 1; meta = nil; name="core"; },
        ScreenUnit         = { need = 1; meta = nil; name="screen"; },
        GyroUnit           = { need = 1; meta = nil; name="gyro"; },
        TelemeterUnit      = { need = 0; meta = nil; name="telemeter"; },
        SpaceFuelContainer = { need = 0; meta = nil; },
        AtmoFuelContainer  = { need = 0; meta = nil; },
        WarpDriveUnit      = { need = 0; meta = nil; },
        CockpitCommandmentUnit = { need = 0; meta = nil; },
    };

    ClassTranslation=
    {
        ["CoreUnitStatic" ] = "CoreUnit";
        ["CoreUnitDynamic"] = "CoreUnit";
        ["CoreUnitSpace"  ] = "CoreUnit";
    };

    system = nil;
    unit   = nil;
    core   = nil;
    gyro   = nil;
    tele   = nil;
    screen = nil;

    InitOk = false;

    fps_count = 0;
    t         = 0;
    t_10hz    = 0;
    t_1hz     = 0;
    fps       = 0;

    v_forward = nil;
    v_up      = nil;
    v_right   = nil;

    ground_distance = -1;

    player_rel_pos = nil;
    player_distance = 0.0;
    altitude = 0.0;
    atmosphere = 0.0;
    planetinfluence = 0.0;
    speed = 0.0;
    kmh = 0.0;
    
    unit_data = nil;
    mass      = nil;
    max_brake = nil;

    v_angle_v = 0.0;
    v_angle_h = 0.0;
    v_angle_valid = false;

    Xoffset = 0;
    Yoffset = 0;
};

-- ******************************************************************
--
-- ******************************************************************

local degree_to_delta = 4.0;
local rad_to_delta    = 4.0 * 180.0 / math.pi;
local format          = string.format;
local pi_half         = math.pi / 2.0;

local ACOS = math.acos;
local ASIN = math.asin;
local SIN  = math.sin;
local COS  = math.cos;

-- ******************************************************************
--
-- ******************************************************************

 function FlyLib:ErrorHandler(text)
    local u=self.UnitClasses;
    local screen=u.ScreenUnit[1];
    if screen then
	  screen.obj.setCenteredText(text);        
    else
        self.system.print(text);
    end    
end

-- ******************************************************************
--
-- ******************************************************************

function FlyLib:SecureCall(func_name,a1,a2,a3)
    local f = self[func_name];
    local ok, message = pcall(f,self,a1,a2,a3);
    if not ok then
        local text= format("Error in %s :\n%s",func_name,message);
        self:ErrorHandler(string.gsub(text,"\n", "<br>"));
    end
    return ok;
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:IdentifySlots(system,unit)
    self.system=system;
    self.unit  =unit;
    self.InitOk = true;
    local u = self.UnitClasses;
    -- ******************************************************************
    for key,obj in pairs(self.unit) do
        if (type(obj)=="table") and (obj.getElementClass~=nil) then
            local class = obj.getElementClass();
            class =  self.ClassTranslation[class] or class;
            local class_table = u[class];
            if class_table then
                local unit = {};
                unit.obj=obj; 
                setmetatable(unit,class_table.meta);
                class_table[#class_table+1]=unit; 
                unit.id=obj.getId();
                if class_table.name then
                    self[class_table.name]=obj;
                end
            else 
                if class~="Generic" then
           	        self.system.print(format("Unexpected unit class %s",class));
                end    
            end    
        end    
    end
    -- ******************************************************************
    for class_name,class_table in pairs(u) do
        local n = #class_table;
        if n < class_table.need then
            self.InitOk=false;
            self:ErrorHandler(format("Missing unit type %s : %d of %d",class_name,n,class_table.need));
        end    
    end    
    -- ******************************************************************
    return self.InitOk;
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OnPeriodic()

    local core        = self.core;
    local unit        = self.unit;
    local v_velo = vec3(core.getVelocity());
    local speed  = v_velo:len();
    local kmh    = speed * 3.6;
    local gear_down = unit.isAnyLandingGearExtended();
    if (kmh >= (GearSpeed + 50.0)) and (gear_down==1) then
        --print("Auto closing gear " );
        unit.retractLandingGears();
    end   
    if (kmh <= (GearSpeed - 50.0)) and (gear_down==0) then
        --print("Auto deploying gear ");
        unit.extendLandingGears();    
    end   
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OnUpdate()
    
   if not self.InitOk then return end

   local core        = self.core;
   local unit        = self.unit;
   local system      = self.system;
   local gyro        = self.gyro;

   if self.v_forward == nil then
       self.v_forward = vec3(core.getConstructOrientationForward());
       self.v_up      = vec3(core.getConstructOrientationUp());
       self.v_right   = vec3(core.getConstructOrientationRight());

        self.mass      = core.getConstructMass();
        self.unit_data = json.decode(unit.getData());
        self.max_brake = self.unit_data.maxBrake;
   end

   if self.telemeter then
       self.ground_distance = self.telemeter.getDistance();
   else
       self.ground_distance = -1;
   end    

   local t           = system.getTime();
   self.t            = t;
   self.fps_count    = self.fps_count+1;

   local draw_10hz=false;
   local draw_1hz =false;

   if (t - self.t_10hz) >= 0.1 then
       self.t_10hz = t;
       draw_10hz = true;
       if (t - self.t_1hz) >= 1.0 then
           self.t_1hz = t;
           draw_1hz = true;
           self.fps = self.fps_count;
           self.fps_count = 0;
       end
   end

   self.player_rel_pos  = vec3(unit.getMasterPlayerPosition()); 
   self.player_distance = self.player_rel_pos:len();

   self.altitude        = core.getAltitude();
   self.atmosphere      = unit.getAtmosphereDensity();  -- [ 0..1]
   self.planetinfluence = unit.getClosestPlanetInfluence(); -- [ 0..1]

   local v_velo = vec3(core.getVelocity());
   local speed  = v_velo:len();
   self.speed = speed;
   self.kmh   = speed * 3.6;

   if self.kmh > 1.0 then
        v_velo.x=v_velo.x/speed;
        v_velo.y=v_velo.y/speed;
        v_velo.z=v_velo.z/speed;
        self.v_angle_v = pi_half - ACOS(v_velo:dot(self.v_up)   );
        self.v_angle_h = pi_half - ACOS(v_velo:dot(self.v_right));
        self.v_angle_valid = true;
   else
        self.v_angle_v = 0.0;
        self.v_angle_h = 0.0;
        self.v_angle_valid = false;
   end

   
   self.roll =gyro.getRoll();
   self.pitch=gyro.getPitch();

   if self.roll~=nil and self.pitch ~=nil then
         self:CheckScreens(draw_10hz,draw_1hz);
   end   

end

    -- ******************************************************************
    --
    -- ******************************************************************

local layer_dynamic_atmo=
[[
    <svg width="100%%" height="100%%" viewBox="-100 -100 200 200" preserveAspectRatio ="xMidYMid meet" >
        <g transform="rotate(%.2f) translate( 0 %.2f)" >
            <g stroke-width="20" stroke="black">
                <line x1="-100" y1="0" x2="100" y2="0" />
                <line x1="0" y1="-100" x2="0" y2="100" />
            </g>
            <g stroke-width="3" stroke="blue">
                <line x1="-100" y1="0" x2="-10" y2="0" />
                <line x1="10" y1="0" x2="100" y2="0" />
                <line x1="0" y1="-100" x2="0" y2="-10" />
                <line x1="0" y1="10" x2="0" y2="100" />
            </g>
            <g stroke-width="2" stroke="blue">
                <line x1="-10" y1="-80" x2="10" y2="-80" />
                <line x1="-10" y1="-60" x2="10" y2="-60" />
                <line x1="-10" y1="-40" x2="10" y2="-40" />
                <line x1="-10" y1="-20" x2="10" y2="-20" />
                <line x1="-10" y1="20" x2="10" y2="20" />
                <line x1="-10" y1="40" x2="10" y2="40" />
                <line x1="-10" y1="60" x2="10" y2="60" />
                <line x1="-10" y1="80" x2="10" y2="80" />
                <line x1="-80" y1="-10" x2="-80" y2="10" />
                <line x1="-60" y1="-10" x2="-60" y2="10" />
                <line x1="-40" y1="-10" x2="-40" y2="10" />
                <line x1="-20" y1="-10" x2="-20" y2="10" />
                <line x1="20" y1="-10" x2="20" y2="10" />
                <line x1="40" y1="-10" x2="40" y2="10" />
                <line x1="60" y1="-10" x2="60" y2="10" />
                <line x1="80" y1="-10" x2="80" y2="10" />
            </g>
        </g>
        <g fill="none" >
            <circle cx="%.2f" cy="%.2f" r="12" stroke="green" stroke-width="3" />
        </g>
    </svg>
]];

local layer_dynamic_space=
[[
    <svg width="100%%" height="100%%" viewBox="-100 -100 200 200" preserveAspectRatio ="xMidYMid meet" >
        <g fill="none" >
            <circle cx="%.2f" cy="%.2f" r="12" stroke="darkviolet" stroke-width="3" />
        </g>
    </svg>
]];

local layer_static_format=
[[
    <svg width="100%" height="100%" viewBox="-100 -100 200 200" preserveAspectRatio ="xMidYMid meet" >
        <g stroke="#80808080" >
            <line x1="-100" y1="0" x2="-50" y2="0" />
            <line x1="50" y1="0" x2="100" y2="0" />
            <line x1="0" y1="-100" x2="0" y2="-50" />
            <line x1="0" y1="50" x2="0" y2="100" />
        </g>
        <g stroke="white" >
            <line x1="-50" y1="0" x2="-10" y2="0" />
            <line x1="10" y1="0" x2="50" y2="0" />
            <line x1="0" y1="-50" x2="0" y2="-10" />
            <line x1="0" y1="10" x2="0" y2="50" />
        </g>
        <g fill="none" >
            <circle cx="0" cy="0" r="10" stroke="white" />
        </g>
    </svg>
]];


local layer_text_atmo=
[[
	<head>
		<style>
			svg 
			{ 
				font-family: ArialMT , Arial, sans-serif; 
				font-size  : 20px;
			} 
		</style>
	</head>
	<body>
        <svg width="100%%" height="100%%" viewBox="-100 -100 200 200" preserveAspectRatio ="xMidYMid meet" >
            <g fill="white" text-anchor="middle">
               <text x="90" y="0">%s</text>
               <text x="0"  y="90">%s</text>
               <text x="90" y="90">%s</text>
               <text x="90" y="-80">%s</text>
            </g>	
            <g fill="white" style="font-size: 10px">
		     <text x="-100"  y="-90">FPS %d</text>
            </g>	
        </svg>
    </body>
]];

local layer_text_space=
[[
	<head>
		<style>
			svg 
			{ 
				font-family: ArialMT , Arial, sans-serif; 
				font-size  : 20px;
			} 
		</style>
	</head>
	<body>
        <svg  width="100%%" height="100%%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
            <g fill="white" text-anchor="middle">
               <text x="90" y="0">%s</text>
               <text x="0"  y="90">%s</text>
               <text x="120" y="-80">%s</text>
               <text x="120" y="-60">%s</text>
            </g>	
            <g fill="white" style="font-size: 10px">
		     <text x="-150"  y="-90">FPS %d</text>
            </g>	
        </svg>
    </body>
]];

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:CheckScreens(draw_10hz,draw_1hz)
    local screen   = self.screen;
    
    -- mouseXpos = screen.getMouseX()
    -- mouseYpos = screen.getMouseY()
    
    local x=self.Xoffset;
    local y=self.Yoffset;

    local cx      = self.v_angle_h * ( rad_to_delta);
    local cy      = self.v_angle_v * (-rad_to_delta);
    local c_pitch = self.pitch * degree_to_delta; -- 1 degree = 20 units
    local layer_dynamic;
    
    if self.planetinfluence > 0.001 then
        layer_dynamic=format(layer_dynamic_atmo,self.roll,c_pitch,cx,cy);
    else   
        layer_dynamic=format(layer_dynamic_space,cx,cy);
    end   

    if screen.layer_dynamic==nil then
        screen.setHTML("");
        screen.clear(); 
        screen.layer_dynamic = screen.addContent(x,y,layer_dynamic);
        screen.addContent(x,y,layer_static_format);
    else
        screen.resetContent(screen.layer_dynamic,layer_dynamic);
    end    

    if draw_10hz then
        local pitch_text=format("%.1f",self.pitch);
        local roll_text =format("%.1f",self.roll); 
        local alt_text;
        
        if self.ground_distance >=0 then
            alt_text=format("> %.1f m <",self.ground_distance)
        else
            alt_text=format("%.3f km",self.altitude / 1000.0)
        end    
        
        local layer_text;

        local speed_text;
        if self.kmh <1.0 then
            speed_text="Stop";
        elseif self.kmh < 10000.0 then
            speed_text=format("%.0f km/h",self.kmh);
        else
            speed_text=format("%.1f Tkm/h",self.kmh/1000.0);
        end

        
        if self.planetinfluence > 0.001 then
        	layer_text=format(layer_text_atmo,pitch_text,roll_text,alt_text,speed_text,self.fps);    
        else    
             layer_text=format(layer_text_space,pitch_text,roll_text,speed_text,self:DistanceText(self:CalcBrakeDistance()),self.fps);    
        end    

        if screen.layer_text==nil then
            screen.layer_text = screen.addContent(0,0,layer_text);
        else
            screen.resetContent(screen.layer_text,layer_text);
        end    
    end    
end

function FlyLib:DistanceText(distance)
    if distance<1000.0 then
       return format("%.0fm",distance);
    else
        distance=distance/1000.0;
        if distance<200.0 then
            return format("%.1fkm",distance);
        else
            return format("%.2fsu",distance/200.0);
        end
    end
end

function FlyLib:MassText(mass)
    if mass <1000.0 then
        return format("%.0fKg",mass);
    else
        return format("%.1ft",mass);
    end
end


function FlyLib:CalcBrakeDistance()

    local c = 30000.0 / 3.6; -- in m/s
    local c2 = c*c;

    local target_speed  = 0.0;

    local accel    = -self.max_brake / self.mass;
    local distance = 0.0;
    local time     = 0.0;

    if self.speed > target_speed then
        local k1 = c * ASIN(self.speed/c);
        local k2 = c2 * COS(k1/c) / accel;
        time     = (c* ASIN(target_speed/c) - k1) / accel;
        distance = k2 - c2 * COS((accel * time + k1) /c) / accel;
    end

    return distance,time;
end

return FlyLib;