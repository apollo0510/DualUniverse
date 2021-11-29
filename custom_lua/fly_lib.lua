local FlyLib=
{
    UnitClasses=
    {
        CoreUnit         = { need = 1; meta = nil; },
        ScreenUnit       = { need = 1; meta = nil; },
        GyroUnit         = { need = 1; meta = nil; },
        TelemeterUnit    = { need = 0; meta = nil; },
    };

    ClassTranslation=
    {
        ["Industry1"      ] = "Industry";
        ["Industry2"      ] = "Industry";
        ["IndustryUnit"   ] = "Industry";
        ["CoreUnitStatic" ] = "CoreUnit";
        ["CoreUnitDynamic"] = "CoreUnit";
        ["CoreUnitSpace"  ] = "CoreUnit";
    };

    system = nil;
    unit   = nil;
    core   = nil;
    screen = nil;

    InitOk = false;
};

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
                else if class~="Generic" then
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
    if u.CoreUnit then
        local core_entry  = u.CoreUnit[1]; 
        if core_entry then
            self.core = core_entry.obj;
        end
    end    
    if u.ScreenUnit then
        local screen_entry  = u.ScreenUnit[1]; 
        if screen_entry then
            self.screen = screen_entry.obj;
        end
    end    
    -- ******************************************************************
    return self.InitOk;
end

-- ******************************************************************
--
-- ******************************************************************






return FlyLib;