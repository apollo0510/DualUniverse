local unit_classes =
{
    CoreUnit                  = { need = 1; meta = nil; name="core"; },
    ScreenUnit                = { need = 1; meta = nil; name="screen"; },
    AntiGravityGeneratorUnit  = { need = 1; meta = nil; name="agg"; },
    GyroUnit                  = { need = 1; meta = nil; name="gyro"; },
    DataBankUnit              = { need = 1; meta = nil; name="data_bank"; },
};
local unit_lib_req = require("unit_lib");
local unit_lib     = unit_lib_req.new(system,unit,unit_classes);
local db_lib       = require("db_lib");

-- ********************************************************************************
--
-- ********************************************************************************

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

-- ********************************************************************************
--
-- ********************************************************************************

local agg_data = { height = 1000.0; }

-- ********************************************************************************
--
-- ********************************************************************************


 local button_meta=
{
    __index=
    {
        x= 0.0; y= 0.0; w=20.0; h=20.0; text="?"; hotkey=0;

        update = function(self) return false; end;
        fill   = function(self) return "none"; end;
        click  = function(self) 
            -- system.print(format("click %s",self.text));
        end;
    };
};

local buttons = 
{ 
    {   x=-160;y=-80;w=40;h=20;text="+1000"; 
        click = function(self) OnChangeAggHeight(1000.0); end
    };
    {   x=-160;y=-55;w=40;h=20;text="+100"; 
        click = function(self) OnChangeAggHeight(100.0); end
    };
    {   x=-160;y=-20;w=40;h=20;text="Curr"; 
        click = function(self) OnChangeAggHeight(0); end
    };
    {   x=-160;y=15;w=40;h=20;text="-100"; 
        click = function(self) OnChangeAggHeight(-100.0); end
    };
    {    x=-160;y=40;w=40;h=20;text="-1000"; 
        click = function(self) OnChangeAggHeight(-1000.0); end
    };
};

function InitButtons()
    local meta=button_meta;
    for i,button in ipairs(buttons) do
          setmetatable(button,meta);
    end
end

local layer_ui  = nil;
local update_ui = true;

function UpdateLayerUI()
    for i,button in ipairs(buttons) do
        if button:update() then
            button.svg_text=nil;
            update_ui = true;
        end
    end
    if  update_ui or layer_ui==nil then
        local ui_text = {};
        ui_text[1]=        
[[  <head> <style> svg { font-family: ArialMT , Arial, sans-serif; font-size  : 12px; } </style> </head>
    <svg width="100%" height="100%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
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
]],x0,y0,w,h,button:fill(),tx,ty,button.text);
            end
            ui_text[#ui_text+1]=button.svg_text;
        end
        ui_text[#ui_text+1]="</g>";
        ui_text[#ui_text+1]="</svg>";
        layer_ui=table.concat(ui_text);
        return true;
    end
end

-- ********************************************************************************
--
-- ********************************************************************************

local layer_frames=
[[
    <svg width="100%" height="100%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
       <g fill="none" stroke="#808080"  >
          <rect x=-110 y=-80 width=130 height=60 />
          <rect x=-110 y=-10 width=130 height=60 />
          <rect x=  30 y=-80 width=130 height=60 />
          <rect x=  30 y=-10 width=130 height=60 />
          <rect x=-110 y= 60 width=270 height=30 />
       </g>	
       <g fill="#808080" text-anchor="left">
           <text x=-100 y=-65>AGG height [km]</text>
           <text x=-100 y= 5>Curr height [km]</text>
           <text x= 40 y=-65>AGG dest [km]</text>
           <text x= 40 y= 5>Climb rate [m/s]</text>
           <text x= -100 y= 75>Hold power %</text>
      </g>	
   </svg>
]];

local layer_text_format=
{
[[
     <svg width="100%%" height="100%%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
       <g fill="green" text-anchor="left" style="font-size: 30px" >
           <text x=-100 y=-30 >%s</text>
           <text x=-100 y= 40 >%s</text>
           <text x= 40  y=-30 >%s</text>
           <text x= 40  y= 40 >%s</text>
           <text x= -10  y= 85 >%s</text>
      </g>
      <rect x=-108 y= 62 width=%f height=26 fill="#80808080" stroke="none"/>
   </svg>
]],
[[
     <svg width="100%%" height="100%%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
       <g fill="red" text-anchor="left" style="font-size: 30px" >
           <text x=-100 y=-30 >%s</text>
           <text x=-100 y= 40 >%s</text>
           <text x= 40  y=-30 >%s</text>
           <text x= 40  y= 40 >%s</text>
           <text x= -10  y= 85 >%s</text>
      </g>	
      <rect x=-108 y= 62 width=%f height=26 fill="#80808080" stroke="none"/>
   </svg>
]]
};

-- ********************************************************************************
--
-- ********************************************************************************

function OnStart()
    local u         = unit_lib;
    local screen    = u.screen;
    local data_bank = u.data_bank;
    if screen then
        screen.setHTML("");
        screen.clear();         
    end
    if data_bank then
        db_lib:Start(system,unit,data_bank);
        agg_data=db_lib:GetKey("AggData",agg_data,1);
    end
    InitButtons();
end    

-- ********************************************************************************
--
-- ********************************************************************************
function OnStop()
    db_lib:Stop();
    local u         = unit_lib;
    local screen    = u.screen;
    if screen then
        screen.setCenteredText("Offline");
    end
end    

-- ********************************************************************************
--
-- ********************************************************************************

local last_t = 0.0;
local last_altitude = 0.0;
local last_agg_base = 0.0;

function OnUpdate()

    CheckMouse();

    local u         = unit_lib;
    local screen    = u.screen;

    if screen.layer_frames == nil then
        screen.setHTML("");
        screen.clear(); 
        screen.layer_frames = screen.addContent(0,0,layer_frames);
    end

    local t =system.getArkTime();
    local dt=t-last_t;
    if (dt>=1.0) or update_ui then

        last_t=t;

        local core      = u.core;
        local agg       = u.agg;
        local gyro      = u.gyro
        local data_bank = u.data_bank;

        local altitude  = core.getAltitude();
        
        local agg_state     = agg.isActive();
        local agg_json_data = agg.getData();
        local agg_decode_data = json.decode(agg_json_data);
        local agg_base =agg_decode_data.baseAltitude;
        local agg_power=agg_decode_data.antiGPower;        -- [ 0 .. 1]
        local agg_field=agg_decode_data.antiGravityField; 


        local sink_rate = (altitude - last_altitude) / dt;

        if UpdateLayerUI() then
            if screen.layer_ui == nil then
                screen.layer_ui = screen.addContent(0,0,layer_ui);
            else
                screen.resetContent(screen.layer_ui,layer_ui);
            end
        end

        local agg_base_text  = format("%.3f",agg_base/1000.0);
        local agg_dest_text  = format("%.3f",agg_data.height/1000.0);

        local agg_power_text;
        local agg_power_width;
        if agg_power>0.0 then
            agg_power_text = format("%.1f",agg_power*100.0);
            agg_power_width=266.0 * agg_power;
        else
            agg_power_text = "--";
            agg_power_width=0.0;
        end
        

        local altitude_text;
        local sink_rate_text;

        if altitude ~= 0 then
            altitude_text  = format("%.3f",altitude/1000.0);
            sink_rate_text = format("%.0f",sink_rate);
        else
            altitude_text  = "Space";
            sink_rate_text = "--"
        end

        local text_format_index;
        if agg_state==1 then text_format_index=1; else text_format_index=2; end
        local layer_text=format(layer_text_format[text_format_index],
                                agg_base_text,
                                altitude_text,
                                agg_dest_text,
                                sink_rate_text,
                                agg_power_text,
                                agg_power_width);

        if screen.layer_text==nil then
            screen.layer_text = screen.addContent(0,0,layer_text);
        else
            screen.resetContent(screen.layer_text,layer_text);
        end   

        last_altitude = altitude;
        last_agg_base = agg_base;

        update_ui = false;

    end
end


-- ********************************************************************************
--
-- ********************************************************************************

local mouse_screen_width  = 335;
local mouse_screen_height = 195;
local mouse_screen_x0     = -mouse_screen_width / 2;
local mouse_screen_y0     = -mouse_screen_height / 2;

local last_mouse_x = 0;
local last_mouse_y = 0;
local last_mouse_s = false;
local last_mouse_valid = false;

local mouse_press_x = nil;
local mouse_press_y = nil;
local mouse_release_x=nil;
local mouse_release_y=nil;
local mouse_target   =nil;

function CheckMouse()
   local u         = unit_lib;
   local screen    = u.screen;
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

   if (mouse_x~=last_mouse_x) or 
      (mouse_y~=last_mouse_y) or
      (mouse_s~=last_mouse_s) then
        last_mouse_x=mouse_x;
        last_mouse_y=mouse_y;
        local mouse_change  = (mouse_s ~= last_mouse_s);
        local mouse_press   = mouse_change and mouse_s;
        local mouse_release = mouse_change and last_mouse_s;
        last_mouse_s=mouse_s;
        last_mouse_valid=mouse_valid;
        if mouse_press then
            OnMousePress(mouse_x,mouse_y);
        end
        if mouse_release then
            OnMouseRelease(mouse_x,mouse_y);    
        end
   end
end

function FindMouseTarget(x,y)
    for i,button in ipairs(buttons) do
        if x>=button.x and x<button.x+button.w then
            if y>=button.y and y<button.y+button.h then
                return button;
            end
        end
    end
    return nil;
end


function OnMousePress(mouse_x,mouse_y)
    mouse_press_x=mouse_x;
    mouse_press_y=mouse_y;
    mouse_release_x=nil;
    mouse_release_y=nil;
    mouse_target   =FindMouseTarget(mouse_x,mouse_y);
    --system.print(format("mouse press %.0f %.0f",mouse_x,mouse_y));
end

function OnMouseRelease(mouse_x,mouse_y)
    --system.print(format("mouse release %.0f %.0f",mouse_x,mouse_y));
    mouse_release_x=mouse_x;
    mouse_release_y=mouse_y;
    local mt   =FindMouseTarget(mouse_x,mouse_y);
    if mt and mt==mouse_target then
        mt:click(mouse_x-mouse_target.x,mouse_y-mouse_target.y);
    end
end

function OnChangeAggHeight(delta)
    local h=agg_data.height;
     h = h + delta;
     if h < 1000.0 then h=1000.0; end
     if h > 100000.0 then h=100000.0; end
     if h~=agg_data.height then
        agg_data.height=h;
        agg_data.update=true;
        update_ui = true;
        unit_lib.agg.setBaseAltitude(h);
     end
end

OnStart();