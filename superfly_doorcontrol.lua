DoorTimeout = 5 --export: Time until door closes

-- ***********************************************************

local format          = string.format;
local print           = system.print;

-- ***********************************************************

local unit_classes=
{
    CoreUnitDynamic  = { need = 1; meta = nil; },
    ManualSwitchUnit = { need = 1; meta = nil; },
    DoorUnit         = { need = 1; meta = { __index={ status=-1; time=0.0; } }; },
    LightUnit        = { need = 1; meta = nil; },
    ForceFieldUnit   = { need = 0; meta = nil; },
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
local last_door_open=-1;
local last_enable_force_field=-1;

function OnPeriodic(shutdown)
    local t  = system.getTime();
    
    local u  = unit_classes;
    local core        = u.CoreUnitDynamic[1].obj;
    local switch_door = u.ManualSwitchUnit[1].obj;
    local led_doors   = u.LightUnit[1].obj;
    local doors       = u.DoorUnit;
    
    local v_velo = vec3(core.getVelocity());
    local speed  = v_velo:len();
    local kmh    = speed * 3.6;
    
    local door_open = false; 
    local door_switch = switch_door.getState();
    
 	if kmh >= 50.0 and door_switch == 1 then
          door_switch = 0;
          print("Auto closing doors inflight");
     end 
    
	for i=1,#doors do
     	local door=doors[i];
         if door.obj then
         	local s=door.obj.getState();
             if s~=door.status then
             	door.status=s;
                 door.time=t;
             end
             if door_switch == 1 then
             	if s == 1 then
                 	door_open = true;
                 else   
                 	door.obj.activate();   
                 end    
             else   
             	if s == 1 then
                     local delta = t - door.time;
                     if (delta>DoorTimeout) or shutdown then
                     	door.obj.deactivate();  
                     else
	                    door_open = true;
                     end    
                 end    
             end   
         end   
     end     
    
     if door_open ~= last_door_open then
     	last_door_open = door_open;
         if door_open then 
     	    led_doors.activate();
             led_doors.setRGBColor(255,0,0);
         else              
             led_doors.activate(); 
             led_doors.setRGBColor(0,255,0);
         end    
	end   
    
     local enable_force_field = (kmh < 10.0) and ((door_switch==1) or door_open);
     if enable_force_field ~= last_enable_force_field then
        last_enable_force_field = enable_force_field;
        local force_fields      = u.ForceFieldUnit;
        local n = #force_fields;
        if n>0 then
            for i=1,n do
                local force_field=force_fields[i];
                  if enable_force_field then
                      force_field.obj.activate();
                  else  
                      force_field.obj.deactivate();
                  end  
            end 
            if enable_force_field then
                print("Deploying force fields");
            else
                print("Retracting force fields");
            end    
        end
     end   
    
end

-- ***********************************************************


if IdentifySlots() then
   print("Starting Door Control"); 
   unit.setTimer("Periodic",1.0);
end    


