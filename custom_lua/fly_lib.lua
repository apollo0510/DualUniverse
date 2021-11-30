local FlyLib=
{
    UnitClasses=
    {
        CoreUnit           = { need = 1; meta = nil; name="core"; },
        ScreenUnit         = { need = 1; meta = nil; name="screen"; },
        GyroUnit           = { need = 1; meta = nil; name="gyro"; },
        TelemeterUnit      = { need = 0; meta = nil; name="telemeter"; },
        SpaceFuelContainer = { need = 0; meta = nil; },
        CockpitCommandmentUnit = { need = 0; meta = nil; },
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
    kmh = 0.0;

    v_angle_v = 0.0;
    v_angle_h = 0.0;
    v_angle_valid = false;
};

-- ******************************************************************
--
-- ******************************************************************

local degree_to_delta = 4.0;
local rad_to_delta    = 4.0 * 180.0 / math.pi;
local format          = string.format;
local acos            = math.acos;
local pi_half         = math.pi / 2.0;

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
    if self.InitOk then
        self.screen.setCenteredText("Ready");        
    end
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
   self.kmh     = speed * 3.6;

   if self.kmh > 1.0 then
        v_velo.x=v_velo.x/speed;
        v_velo.y=v_velo.y/speed;
        v_velo.z=v_velo.z/speed;
        self.v_angle_v = pi_half - acos(v_velo:dot(self.v_up)   );
        self.v_angle_h = pi_half - acos(v_velo:dot(self.v_right));
        self.v_angle_valid = true;
   else
        self.v_angle_v = 0.0;
        self.v_angle_h = 0.0;
        self.v_angle_valid = false;
   end

   
   self.roll =gyro.getRoll();
   self.pitch=gyro.getPitch();

   if roll~=nil and pitch ~=nil then
         self:CheckScreens(draw_10hz,draw_1hz);
   end   

end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:CheckScreens(draw_10hz,draw_1hz)


end

return FlyLib;