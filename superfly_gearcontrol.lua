GearSpeed   = 350 --export: Speed +-50km/h for auto gear deployment

-- ***********************************************************

local format          = string.format;
local print           = system.print;

-- ***********************************************************

local unit_classes=
{
    CoreUnitDynamic  = { need = 1; meta = nil; },
    ManualSwitchUnit = { need = 1; meta = nil; },
    LightUnit        = { need = 1; meta = nil; },
    LandingGearUnit  = { need = 1; meta = nil; }, 
};

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

-- ***********************************************************
local last_gear_down = -1;

function OnPeriodic()
    local t  = system.getTime();
    
    local u           = unit_classes;
    local core        = u.CoreUnitDynamic[1].obj;
    local switch_gear = u.ManualSwitchUnit[1].obj;
    local led_gear    = u.LightUnit[1].obj;
    
    local v_velo = vec3(core.getVelocity());
    local speed  = v_velo:len();
    local kmh    = speed * 3.6;
    
    local gear_down = switch_gear.getState();    

    if kmh >= (GearSpeed + 50.0) and (gear_down==1) then
        system.print("Auto closing gear "  .. t);
        switch_gear.deactivate();
    end   

    if kmh <= (GearSpeed - 50.0) and (gear_down==0) then
        system.print("Auto deploying gear " .. t);
        switch_gear.activate();    
    end   

    if gear_down ~= last_gear_down then
        last_gear_down = gear_down;
        if (gear_down==1) then 
            led_gear.activate();
            led_gear.setRGBColor(255,0,0);
        else              
            led_gear.activate(); 
            led_gear.setRGBColor(0,255,0);
        end    
    end       

end

-- ***********************************************************


if IdentifySlots() then
   print("Starting Gear Control"); 
   unit.setTimer("Periodic",1.0);
end    


