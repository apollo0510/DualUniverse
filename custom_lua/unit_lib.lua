local unit_lib={ };

local format          = string.format;

local class_translation=
{
    ["Industry1"      ] = "Industry";
    ["IndustryUnit"   ] = "Industry";
    ["CoreUnitStatic" ] = "CoreUnit";
    ["CoreUnitDynamic"] = "CoreUnit";
};

function unit_lib.new(system,unit,unit_classes)
     local lib={};
     setmetatable(lib, { __index = unit_lib; } );
     lib.system       = system;
     lib.unit         = unit;
   	 lib.unit_classes = unit_classes;
     lib:IdentifySlots();
     lib:ResolveNames();
     return lib;
end

function unit_lib:ErrorHandler(text)
    local u=self.unit_classes;
    local screen=u.ScreenUnit[1];
    if screen then
	  screen.obj.setCenteredText(text);        
    else
        self.system.print(text);
    end    
end
    
function unit_lib:IdentifySlots()
    self.init_ok=true;
    local u = self.unit_classes;
    for key,obj in pairs(self.unit) do
        if (type(obj)=="table") and (obj.getElementClass~=nil) then
            local class = obj.getElementClass();
            class =  class_translation[class] or class;
            local class_table = u[class];
            if class_table then
                 local unit = {};
                 unit.obj=obj; 
                 setmetatable(unit,class_table.meta);
                 class_table[#class_table+1]=unit; 
                 unit.id=obj.getId();
             else if class~="Generic" then
               	self.system.print(format("Unexpected unit class %s",class));
             end    
           end    
        end    
    end    
    for class_name,class_table in pairs(u) do
        local n = #class_table;
        if n < class_table.need then
            init_ok=false;
            self:ErrorHandler(format("Missing unit type %s : %d of %d",class_name,n,class_table.need));
        end    
    end    
    local core_entry=nil;
    if u.CoreUnit then
       core_entry  = u.CoreUnit[1]; 
    end    
    if core_entry then
        self.core  = core_entry.obj;
    else
        self.core  = nil;
    end    
    return self.init_ok;
end    

function unit_lib:ResolveNames()
     if self.core then
         for class_name,class_table in pairs(self.unit_classes) do
            local n = #class_table;
            for i=1,n do
                local unit=class_table[i];
                unit.name=self.core.getElementNameById(unit.id);
            end   
            table.sort(class_table, function(a,b) return (a.name < b.name); end);
         end   
     end   
end    

return unit_lib;
