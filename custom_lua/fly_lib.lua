local db_lib = require("db_lib");

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
        Cockpit            = { need = 0; meta = nil; },
    };

    ClassTranslation=
    {
        ["CoreUnitStatic" ] = "CoreUnit";
        ["CoreUnitDynamic"] = "CoreUnit";
        ["CoreUnitSpace"  ] = "CoreUnit";
        ["CockpitCommandmentUnit"  ] = "Cockpit";
        ["CockpitFighterUnit"  ] = "Cockpit";
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

    mouse_x = -1;
    mouse_y = -1;
    mouse_s =  false;
    mouse_valid = false;
    mouse_press_x = nil;
    mouse_press_y = nil;
    mouse_release_x = nil;
    mouse_release_y = nil;
    mouse_target = nil;


    AutoPitch = 2.0;
    AutoYaw   = 2.0;

    autoPitchPID = nil;
    autoYawPID   = nil;
    auto_align   = false;

    target_valid    = false;
    target_position = nil;
    target_vec      = nil;

    update_ui = false;

    button_meta=
    {
        __index=
        {
            x= 0.0; y= 0.0; w=20.0; h=20.0; text="?"; hotkey=0;

            update = function(self,flylib) return false; end;
            fill   = function(self,flylib) return "none"; end;
            click  = function(self,flylib) end;
        };
    };

    buttons = 
    { 
        {   x=-160;y=-80;w=20;h=20;text="T"; 
            
            update=function(self,flylib)
               if flylib.target_valid~=self.target_valid then
                    self.target_valid = flylib.target_valid;
                    return true;
               end
            end;

            fill=function(self,flylib) 
                if flylib.target_valid then return "green";
                else return "none"; end
            end;
        }; 

        {   x=-135;y=-80;w=20;h=20;text="A"; 
            hotkey=1;
            
            update=function(self,flylib)
               if flylib.auto_align~=self.auto_align then
                    self.auto_align = flylib.auto_align;
                    return true;
               end
            end;

            fill=function(self,flylib) 
                if flylib.auto_align then return "red";
                else return "none"; end
            end;

            click=function(self,flylib)
                flylib:ToggleAutoAlign();
            end
        }; 



    };  
};

-- ******************************************************************
--
-- ******************************************************************

function FlyLib:InitButtons()
    local meta=self.button_meta;
    for i,button in ipairs(self.buttons) do
          setmetatable(button,meta);
    end
end

-- ******************************************************************
--
-- ******************************************************************

local degree_to_delta = 4.0;
local rad_to_delta    = 4.0 * 180.0 / math.pi;
local rad_to_deg      = 180.0 / math.pi;
local deg_to_rad      = math.pi / 180.0;

local format          = string.format;
local pi_half         = math.pi / 2.0;

local ACOS = math.acos;
local ASIN = math.asin;
local SIN  = math.sin;
local COS  = math.cos;

local atlas = require("atlas");

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

function FlyLib:SecureCall(func_name,...)
    local f = self[func_name];
    local ok, message = pcall(f,self,...);
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
    self:InitButtons();
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
           self.unit_data = json.decode(unit.getData());
           self.max_brake = self.unit_data.maxBrake;
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

   self:CheckMouse();

   if self.roll~=nil and self.pitch ~=nil then
         self:CheckScreens(draw_10hz,draw_1hz);
   end   

end

    -- ******************************************************************
    --
    -- ******************************************************************

local mouse_screen_width  = 335;
local mouse_screen_height = 195;
local mouse_screen_x0     = -mouse_screen_width / 2;
local mouse_screen_y0     = -mouse_screen_height / 2;

function FlyLib:CheckMouse()
   local screen  = self.screen;
   local mouse_x = screen.getMouseX();
   local mouse_y = screen.getMouseY();
   local mouse_s     = false;
   local mouse_valid = false;
   if mouse_x>=0.0 and mouse_y>=0.0 then
        mouse_x = mouse_screen_x0 + mouse_x * mouse_screen_width;
        mouse_y = mouse_screen_y0 + mouse_y * mouse_screen_height;
        mouse_s = (screen.getMouseState() == 1);
        mouse_valid = true;
   end

   if (mouse_x~=self.mouse_x) or 
      (mouse_y~=self.mouse_y) or
      (mouse_s~=self.mouse_s) then
        self.mouse_x=mouse_x;
        self.mouse_y=mouse_y;
        local mouse_change  = (mouse_s ~= self.mouse_s);
        local mouse_press   = mouse_change and mouse_s;
        local mouse_release = mouse_change and self.mouse_s;
        self.mouse_s=mouse_s;
        self.mouse_valid=mouse_valid;
        if mouse_press then
            self:OnMousePress(mouse_x,mouse_y);
        end
        if mouse_release then
            self:OnMouseRelease(mouse_x,mouse_y);    
        end
   end
end

function FlyLib:FindMouseTarget(x,y)
    for i,button in ipairs(self.buttons) do
        if x>=button.x and x<button.x+button.w then
            if y>=button.y and y<button.y+button.h then
                return button;
            end
        end
    end
    return nil;
end

function FlyLib:OnMousePress(mouse_x,mouse_y)
    self.mouse_press_x=mouse_x;
    self.mouse_press_y=mouse_y;
    self.mouse_release_x=nil;
    self.mouse_release_y=nil;
    self.mouse_target   =self:FindMouseTarget(mouse_x,mouse_y);
    -- self.system.print(format("mouse press %.0f %.0f",mouse_x,mouse_y));
end

function FlyLib:OnMouseRelease(mouse_x,mouse_y)
    -- self.system.print(format("mouse release %.0f %.0f",mouse_x,mouse_y));
    self.mouse_release_x=mouse_x;
    self.mouse_release_y=mouse_y;
    local mouse_target   =self:FindMouseTarget(mouse_x,mouse_y);
    if mouse_target and mouse_target==self.mouse_target then
        mouse_target:click(self,mouse_x-mouse_target.x,mouse_y-mouse_target.y);
    end
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OnFlush(targetAngularVelocity,
                        constructUp,            
                        constructForward,       
                        constructRight,
                        constructVelocity,
                        constructVelocityDir,
                        velocity,
                        inAtmosphere)

    if self.target_valid then

        if self.autoPitchPID == nil then
            self.autoPitchPID = pid.new(self.AutoPitch * 0.01, 0, self.AutoPitch * 0.1);
            self.autoYawPID   = pid.new(self.AutoYaw   * 0.01, 0, self.AutoYaw   * 0.1);
            self.system.print("starting auto align");
        end


        local myPos=vec3(self.core.getConstructWorldPos());
        local align_vector = (self.target_vec - myPos):normalize();
        local align_scalar_pitch = - align_vector:dot(constructUp);
        local align_scalar_yaw   = - align_vector:dot(constructRight);

        self.align_pitch_angle  =  ASIN(align_scalar_pitch) * rad_to_deg;
        self.align_yaw_angle    =  ASIN(align_scalar_yaw  ) * rad_to_deg;

        self.autoPitchPID:inject(-self.align_pitch_angle);
        self.autoYawPID:inject(self.align_yaw_angle);

        if self.auto_align then
            
            local autoPitchInput =0.0;
            local autoYawInput   =0.0;
        
            if not inAtmosphere then
                autoPitchInput = self.autoPitchPID:get();
            end
            autoYawInput   = self.autoYawPID:get();

            targetAngularVelocity.x = targetAngularVelocity.x +  
                autoPitchInput * constructRight.x +
                autoYawInput   * constructUp.x;
            
            targetAngularVelocity.y = targetAngularVelocity.y +  
                autoPitchInput * constructRight.y +
                autoYawInput   * constructUp.y;
            
            targetAngularVelocity.z = targetAngularVelocity.z +  
                autoPitchInput * constructRight.z +
                autoYawInput   * constructUp.z;
        end

    else
        if self.autoPitchPID then
            self.autoPitchPID       = nil;
            self.autoYawPID         = nil;
            self.align_pitch_angle  = nil;
            self.align_yaw_angle    = nil;
            self.system.print("stopping auto align");
        end
    end
end


    -- ******************************************************************
    --
    -- ******************************************************************

    function FlyLib:ParsePosition(text)
        if type(text)=="string" then

            if not self.posPattern then
                local num        = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
                self.posPattern = '::pos{' .. num .. ',' .. num .. ',' ..  num .. ',' .. num ..  ',' .. num .. '}'
            end

            local _systemId, _bodyId, _latitude, _longitude, _altitude = string.match(text, self.posPattern);
            _systemId  = tonumber(_systemId);
            _bodyId    = tonumber(_bodyId);
            _latitude  = tonumber(_latitude);
            _longitude = tonumber(_longitude);
            _altitude  = tonumber(_altitude);
            if _systemId ~=nil and 
               _bodyId   ~=nil and 
               _latitude ~=nil and 
               _longitude~=nil and 
               _altitude ~=nil then 
               local position=
               {
                    systemId  = _systemId;
                    bodyId    = _bodyId;
                    latitude  = _latitude;
                    longitude = _longitude;
                    altitude  = _altitude;
               };
               return position;
            end
        end
        return nil;
    end

    -- ******************************************************************
    --
    -- ******************************************************************

    function FlyLib:CalcWorldCoordinates(position)
        if position then
          if position.bodyId == 0 then
             return vec3(position.latitude, position.longitude, position.altitude);
          end
          local solar_system = atlas[position.systemId];
          if solar_system then
              local body = solar_system[position.bodyId];
              if body then
                 local h  = body.radius + position.altitude;
                 local c  = body.center;
                 local latitude  = position.latitude *deg_to_rad;
                 local longitude = position.longitude*deg_to_rad;
                 local cosl = COS(latitude);
                 local x = c[1] + h * COS(longitude) * cosl;
                 local y = c[2] + h * SIN(longitude) * cosl;
                 local z = c[3] + h * SIN(latitude);
                 return vec3(x,y,z);
              end
          end
        end
        return nil
    end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OninputText(text)
    local position=self:ParsePosition(text);
    if position then
        self.target_position = position;
        self.target_vec      = self:CalcWorldCoordinates(position);
        self.target_valid    = (self.target_vec ~= nil);
        self.system.setWaypoint(text);
    else
        self.system.print("OninputText : " .. text);
    end
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:ToggleAutoAlign()
    self.auto_align = not self.auto_align;
    if self.auto_align then
        self.system.print("auto align on");
    else
        self.system.print("auto align off");
    end
end

function FlyLib:OnOption(hotkey)
    self.system.print("OnOption" .. hotkey);
    for i,button in ipairs(self.buttons) do
          if button.hotkey == hotkey then
             button:click(self);
          end
    end
end

    -- ******************************************************************
    --
    -- ******************************************************************

local layer_dynamic_atmo=
[[
    <svg width="100%%" height="100%%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
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
    <svg width="100%%" height="100%%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
        <circle cx="%.2f" cy="%.2f" r="12" stroke="darkviolet" stroke-width="3" fill="none" />
    </svg>
]];

local layer_static=
[[ <svg width="100%" height="100%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
      <path d="M-100,0 h50 M50,0 h50 M0,-100 v50 M0,50 v50" stroke="#80808080" />
      <path d="M-50,0 h40 M10,0 h40 M0,-50 v40 M0,10 v40" stroke="white" />
      <circle cx="0" cy="0" r="10" stroke="white" fill="none" />
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
        <svg width="100%%" height="100%%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
            <g fill="white" text-anchor="middle">
               <text x="90" y="0" %s</text>
               <text x="0"  y="90" %s</text>
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
               <text x="90" y="0" %s</text>
               <text x="0"  y="90" %s</text>
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
    else
        screen.resetContent(screen.layer_dynamic,layer_dynamic);
    end   
    
    if screen.layer_static == nil then
        screen.layer_static = screen.addContent(x,y,layer_static);
    end

    if self:UpdateLayerUI() then
        if screen.layer_ui == nil then
            screen.layer_ui = screen.addContent(0,0,self.layer_ui);
        else
            screen.resetContent(screen.layer_ui,self.layer_ui);
        end
    end

    if draw_10hz then
        local pitch_text;
        local roll_text;

        if self.align_pitch_angle then
            pitch_text=format("fill=\"green\" >[%.1f]",self.align_pitch_angle);
        else
            pitch_text=format(">%.1f",self.pitch);
        end

        if self.align_yaw_angle~=nil then
            roll_text =format("fill=\"green\" >[%.1f]",self.align_yaw_angle); 
        else
            roll_text =format(">%.1f",self.roll); 
        end

        local alt_text;
        
        if self.ground_distance >=0 then
            alt_text=format("(%.1f m)",self.ground_distance)
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

function FlyLib:UpdateLayerUI()
    local buttons = self.buttons;
    local update_ui = false;
    for i,button in ipairs(buttons) do
        if button:update(self) then
            button.svg_text=nil;
            update_ui = true;
        end
    end
    if  update_ui or self.layer_ui==nil then
        local ui_text = {};
        ui_text[1]=        
[[ <svg width="100%" height="100%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
]];
        ui_text[#ui_text+1]=[[<g text-anchor="middle" stroke="white" fill="white" >]];
        for i,button in ipairs(buttons) do
            if button.svg_text==nil then    
                local x0=button.x;
                local y0=button.y;
                local w =button.w;
                local h =button.h;
                local tx = x0+w/2.0;
                local ty = y0+h/2.0;
                button.svg_text=format(
[[<rect x="%d" y="%d" width="%d" height="%d" fill=%s />
<text x="%d" y="%d"  dy=".35em" >%s</text>
]],x0,y0,w,h,button:fill(self),tx,ty,button.text);
            end
            ui_text[#ui_text+1]=button.svg_text;
        end
        ui_text[#ui_text+1]="</g>";
        ui_text[#ui_text+1]="</svg>";
        self.layer_ui=table.concat(ui_text);
        return true;
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

    local distance = 0.0;
    local time     = 0.0;
    if self.max_brake and self.mass then
        local c = 30000.0 / 3.6; -- in m/s
        local c2 = c*c;
        local target_speed  = 0.0;
        local accel    = -self.max_brake / self.mass;
        if self.speed > target_speed then
            local k1 = c * ASIN(self.speed/c);
            local k2 = c2 * COS(k1/c) / accel;
            time     = (c* ASIN(target_speed/c) - k1) / accel;
            distance = k2 - c2 * COS((accel * time + k1) /c) / accel;
        end
    end
    return distance,time;
end

return FlyLib;