Xoffset = -3 --export: To center the crosshair
Yoffset = -2.3 --export: To center the crosshair

-- ******************************************************************

local degree_to_delta = 4.0;
local rad_to_delta    = 4.0 * 180.0 / math.pi;
local format          = string.format;
local print           = system.print;
local acos            = math.acos;
local pi_half         = math.pi / 2.0;

-- ***********************************************************

local unit_classes=
{
    CoreUnitDynamic  = { need = 1; meta = nil; },
    ScreenUnit       = { need = 1; meta = nil; },
    GyroUnit         = { need = 1; meta = nil; },
    TelemeterUnit    = { need = 0; meta = nil; },
};

local setup_complete = false;

-- ***********************************************************

function IdentifySlots()
    local u = unit_classes;
    for key,obj in pairs(unit) do
        if (type(obj)=="table") and (obj.getElementClass~=nil) then
            local class = obj.getElementClass();
            local class_table = u[class];
            if class_table then
                 local unit = {};
                 unit.obj=obj; 
                 setmetatable(unit,class_table.meta);
                 class_table[#class_table+1]=unit; 
             else if class~="Generic" then
               	print(format("Unexpected unit class %s",class));
             end    
           end    
        end    
    end    
    local all_units_found=true;
    for class_name,class_table in pairs(u) do
        local n = #class_table;
        if n < class_table.need then
            all_units_found=false;
            print(format("Missing unit type %s : %d of %d",class_name,n,class_table.need));
        end    
    end    
    return all_units_found;
end

-- ******************************************************************

local player_rel_pos;
local player_distance; 

local v_forward = nil;
local v_up      = nil;
local v_right   = nil;

local fps = 0;
local fps_count = 0;
local t_10hz = 0.0;    -- 10 hz   
local t_1hz  = 0.0;    -- 1 hz

local t = 0.0;
local v_velo;
local speed = 0.0;
local kmh   = 0.0;
local v_angle_v = 0.0;
local v_angle_h = 0.0;
local v_angle_valid = false;

local pitch = 0.0;
local roll  = 0.0;
local altitude = 0.0;
local atmosphere = 0.0;
local planetinfluence = 0.0;
local ground_distance = -1;

function OnUpdate()
     if setup_complete then
        
         local u      = unit_classes;
    	local core   = u.CoreUnitDynamic[1].obj;
         local gyro   = u.GyroUnit[1].obj;
        
         if v_forward == nil then
            v_forward = vec3(core.getConstructOrientationForward());
            v_up      = vec3(core.getConstructOrientationUp());
            v_right   = vec3(core.getConstructOrientationRight());
            print("Starting Flight Control");
         end
        
        local telemeter = u.TelemeterUnit[1];
        if telemeter then
            ground_distance = telemeter.obj.getDistance();
        else
            ground_distance = -1;
        end    
        
         t      = system.getTime();
         fps_count = fps_count + 1;

         local draw_10hz=false;
         local draw_1hz =false;

         if (t - t_10hz) >= 0.1 then
            t_10hz = t;
            draw_10hz = true;
             if (t - t_1hz) >= 1.0 then
                t_1hz = t;
                draw_1hz = true;
                fps = fps_count;
                fps_count=0;
             end
         end


        player_rel_pos  = vec3(unit.getMasterPlayerRelativePosition()); 
        player_distance = player_rel_pos:len();

        altitude   = core.getAltitude();
        atmosphere = unit.getAtmosphereDensity();  -- [ 0..1]
        planetinfluence = unit.getClosestPlanetInfluence(); -- [ 0..1]

        v_velo = vec3(core.getVelocity());
        speed  = v_velo:len();
        kmh    = speed * 3.6;

        if kmh > 1.0 then
            v_velo.x=v_velo.x/speed;
            v_velo.y=v_velo.y/speed;
            v_velo.z=v_velo.z/speed;
            v_angle_v = pi_half - acos(v_velo:dot(v_up)   );
            v_angle_h = pi_half - acos(v_velo:dot(v_right));
            v_angle_valid = true;
        else
            v_velo.x=0.0;
            v_velo.y=0.0;
            v_velo.z=0.0;
            v_angle_v = 0.0;
            v_angle_h = 0.0;
            v_angle_valid = false;
        end

        roll =gyro.getRoll();
        pitch=gyro.getPitch();

        if roll~=nil and pitch ~=nil then
            CheckScreens(draw_10hz,draw_1hz);
        end   

    end
end    

-- ******************************************************************

function OnStart()
    local u = unit_classes;
    local screen   = u.ScreenUnit[1];
    if screen then
       screen.obj.activate(); 
    end
    --local gyro = u.GyroUnit[1];
    --if gyro then
    --   gyro.obj.hide();
    --end    
    --local core = u.CoreUnitDynamic[1];
    --if core then
    --   core.obj.hide();
    --end    
end

function OnStop()
    local u = unit_classes;
    local screen   = u.ScreenUnit[1];
    if screen then
       screen.obj.deactivate(); 
    end
    --local gyro = u.GyroUnit[1];
    --if gyro then
    --   gyro.obj.show();
    --end    
    --local core = u.CoreUnitDynamic[1];
    --if core then
    --   core.obj.show();
    --end    
end

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
        <svg  width="100%%" height="100%%" viewBox="-100 -100 200 200" preserveAspectRatio ="xMidYMid meet" >
            <g fill="white" text-anchor="middle">
               <text x="90" y="0">%s</text>
               <text x="0"  y="90">%s</text>
               <text x="90" y="-80">%s</text>
            </g>	
            <g fill="white" style="font-size: 10px">
		     <text x="-100"  y="-90">FPS %d</text>
            </g>	
        </svg>
    </body>
]];

function CheckScreens(draw_10hz,draw_1hz)
    local u        = unit_classes;
    local screen   = u.ScreenUnit[1];
    
    -- mouseXpos = screen.getMouseX()
    -- mouseYpos = screen.getMouseY()
    
    local x=Xoffset;
    local y=Yoffset;

    local cx      = v_angle_h * ( rad_to_delta);
    local cy      = v_angle_v * (-rad_to_delta);
    local c_pitch = pitch * degree_to_delta; -- 1 degree = 20 units
    local layer_dynamic;
    
    if planetinfluence > 0.001 then
        layer_dynamic=format(layer_dynamic_atmo,roll,c_pitch,cx,cy);
    else   
        layer_dynamic=format(layer_dynamic_space,cx,cy);
    end   

    if screen.layer_dynamic==nil then
        screen.obj.clear(); 
        screen.layer_dynamic = screen.obj.addContent(x,y,layer_dynamic);
        screen.obj.addContent(x,y,layer_static_format);
    else
        screen.obj.resetContent(screen.layer_dynamic,layer_dynamic);
    end    

    if draw_10hz then
        local pitch_text=format("%.1f°",pitch);
        local roll_text =format("%.1f°",roll); 
        local alt_text;
        
        if ground_distance >=0 then
            alt_text=format("> %.1f m <",ground_distance)
        else
            alt_text=format("%.3f km",altitude / 1000.0)
        end    
        
        local layer_text;
        
        if planetinfluence > 0.001 then
	        local speed_text=format("%.0f km/h",kmh);
        	layer_text=format(layer_text_atmo,pitch_text,roll_text,alt_text,speed_text,fps);    
        else    
	        local speed_text=format("%.1f Tkm/h",kmh/1000.0);
             layer_text=format(layer_text_space,pitch_text,roll_text,speed_text,fps);    
        end    

        if screen.layer_text==nil then
            screen.layer_text = screen.obj.addContent(0,0,layer_text);
        else
            screen.obj.resetContent(screen.layer_text,layer_text);
        end    
    end    

end

setup_complete=IdentifySlots();
if setup_complete then
	OnStart();
end




