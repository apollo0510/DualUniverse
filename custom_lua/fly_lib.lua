local db_lib = require("db_lib");

local AUTOBRAKE_OFF   = 0;
local AUTOBRAKE_WAIT  = 1;
local AUTOBRAKE_ON    = 2;
local AUTOBRAKE_LOCK  = 3;

local auto_brake_colors = 
{
    [AUTOBRAKE_OFF  ] = "#FF0000FF";
    [AUTOBRAKE_WAIT ] = "#80000080";
    [AUTOBRAKE_ON   ] = "#FF0000FF";
    [AUTOBRAKE_LOCK ] = "#FF8080FF";
};

local POSITION_TYPE_SPACE   = 1;
local POSITION_TYPE_PLANET  = 2;
local POSITION_TYPE_SURFACE = 3;
local POSITION_TYPE_ORBIT   = 4;
local PositionTypeNames=
{
    [POSITION_TYPE_SPACE]  ="Space",
    [POSITION_TYPE_PLANET] ="Planet",
    [POSITION_TYPE_SURFACE]="Surface",
    [POSITION_TYPE_ORBIT]  ="Orbit"
};

-- agg api:
-- ************************************
-- activate()
-- deactivate()
-- toggle()
-- isActive()
-- setBaseAltitude(altitude)
-- getBaseAltitude()

-- agg keyboard:
-- ***********************************
-- ALT-G



-- newSpeedValue = 1000
-- Nav.axisCommandManager:setTargetSpeedCommand(axisCommandId.longitudinal, newSpeedValue)
--
--
-- in flush : switch to 
-- controlMasterModeId = 1
-- cancelCurrentControlMasterMode()


    

local FlyLib=
{
    UnitClasses=
    {
        CoreUnit           = { need = 1; meta = nil; name="core"; },
        ScreenUnit         = { need = 0; meta = nil; name="screen"; },
        GyroUnit           = { need = 1; meta = nil; name="gyro"; },
        DataBankUnit       = { need = 1; meta = nil; name="data_bank"; },
        ShieldGenerator    = { need = 0; meta = nil; name="shield"; },
        Radar              = { need = 0; meta = nil; name="radar"; },
        Weapon             = { need = 0; meta = nil; name="weapon"; },

        TelemeterUnit      = { need = 0; meta = nil; name="telemeter"; },
        SpaceFuelContainer = { need = 0; meta = nil; },
        AtmoFuelContainer  = { need = 0; meta = nil; },
        WarpDriveUnit      = { need = 0; meta = nil; },
        Cockpit            = { need = 0; meta = nil; },
        CockpitHovercraftUnit = { need = 0; meta = nil; },
        ManualSwitchUnit   = { need = 0; meta = nil; name="switch"; },
    };

    ClassTranslation=
    {
        ["CoreUnitStatic" ] = "CoreUnit";
        ["CoreUnitDynamic"] = "CoreUnit";
        ["CoreUnitSpace"  ] = "CoreUnit";
        ["CockpitCommandmentUnit"  ] = "Cockpit";
        ["CockpitFighterUnit"  ] = "Cockpit";
        ["ShieldGeneratorExtraSmallGroup"  ] = "ShieldGenerator";
        ["RadarPVPSpaceSmallGroup"] = "Radar";
        ["WeaponCannonExtraSmall"] = "Weapon";
    };

    system = nil;
    unit   = nil;
    construct = nil;
    core   = nil;
    gyro   = nil;
    tele   = nil;
    screen = nil;
    
    shield = nil;
    set_shield_delay=0;
    shield_ready    =false;
    shield_stress = {0.25,0.25,0.25,0.25};

    radar = nil;

    InitOk = false;

    fps_count = 0;
    t         = 0;
    t_10hz    = 0;
    t_1hz     = 0;
    t_2hz     = 0;
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
    in_atmosphere = false;
    near_planet   = false;

    speed = 0.0;
    kmh = 0.0;
    
    unit_data = nil;
    mass      = nil;
    max_speed = nil;
    max_brake = nil;

    v_angle_v = 0.0;
    v_angle_h = 0.0;
    v_angle_valid = false;

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
    AutoRoll  = 2.0;

    autoPitchPID        = nil;
    autoYawPID          = nil;
    autoRollPID         = nil;
    auto_align          = false;
    auto_target         = false;
    target_auto_brake   = AUTOBRAKE_OFF;
    atmo_auto_brake     = false;

    travel_target = 
    {
        valid          = false;
        position       = nil;
        vec            = nil;
        
        brake_distance   = 1000.0;
        shutoff_distance = 100.0;
        shutoff_speed    = 200.0;
    };

    radar_target = 
    {
        valid          = false;
        position       = nil;
        vec            = nil;
        
        brake_distance   = 1000.0;
        shutoff_distance = 100.0;
        shutoff_speed    = 200.0;
    };

    ScreenOffset =
    { 
        x=0;
        y=0;
    };

    current_brake_distance      = 0.0;
    current_brake_distance_compare =0.0;
    current_brake_distance_text = "";

    target_brake_distance_compare = 0.0;
    target_brake_distance_text = "";

    RemainingTravelTime = nil;
    RemainingTravelTimeCompare = nil;
    RemainingTravelTimeText = "";

    update_ui = false;
    blink     = false;

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
               local valid=flylib.travel_target.valid;
               if valid~=self.travel_target_valid then
                    self.travel_target_valid = valid;
                    return true;
               end
            end;

            fill=function(self,flylib) 
                if flylib.travel_target.valid then return "green";
                else return "none"; end
            end;
        }; 

        {   x=-160;y=-55;w=20;h=20;text="A"; 
            hotkey=1;
            
            update=function(self,flylib)
               if flylib.auto_align~=self.auto_align then
                    self.auto_align = flylib.auto_align;
                    return true;
               end
               if flylib.target_auto_brake~=self.target_auto_brake then
                    self.target_auto_brake = flylib.target_auto_brake;
                    return true;
               end
            end;

            fill=function(self,flylib) 
                if flylib.auto_align then 
                   return auto_brake_colors[flylib.target_auto_brake]; 
                else 
                   return "none"; end
            end;

            click=function(self,flylib)
                flylib:ToggleAutoAlign();
            end
        }; 

        {   x=-160;y=-30;w=20;h=20;text="R"; 
            hotkey=2;
            
            update=function(self,flylib)
               if flylib.auto_target~=self.auto_target then
                    self.auto_target = flylib.auto_target;
                    return true;
               end
               local target=flylib.radar_target;
               if target.valid~=self.target_valid then
                    self.target_valid = target.valid;
                    return true;
               end
            end;

            fill=function(self,flylib) 
                if self.auto_target then 
                    if not self.target_valid then
                        return "#00FF00FF "; 
                    else
                        return "#FF0000FF "; 
                    end
                else 
                   return "none"; end
            end;

            click=function(self,flylib)
                flylib:ToggleAutoTarget();
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
local ABS  = math.abs;


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

function FlyLib:IdentifySlots(system,unit,construct,player)
    self.system=system;
    self.unit  =unit;
    self.construct=construct;
    self.player = player;
    self.InitOk = true;
    local u = self.UnitClasses;
    system.print("Starting to identify slots");
    -- ******************************************************************
    for key,obj in pairs(self.unit) do
        if (type(obj)=="table") and (obj.getClass~=nil) then
            local class = obj.getClass();
            class =  self.ClassTranslation[class] or class;
            local class_table = u[class];
            if class_table then
                local unit = {};
                unit.obj=obj; 
                setmetatable(unit,class_table.meta);
                class_table[#class_table+1]=unit; 
                unit.id=obj.getLocalId();
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
    system.print("Checking for missing unit types");
    for class_name,class_table in pairs(u) do
        local n = #class_table;
        if n < class_table.need then
            self.InitOk=false;
            self:ErrorHandler(format("Missing unit type %s : %d of %d",class_name,n,class_table.need));
        end    
    end    
    -- ******************************************************************
    system.print("Loading data base");
    db_lib:Start(system,unit,self.data_bank);
    self.ScreenOffset =db_lib:GetKey("ScreenOffset", self.ScreenOffset , 1);
    self.travel_target=db_lib:GetKey("Target"      , self.travel_target       , 1);
    -- ******************************************************************
    system.print("Init UI buttons");
    self:InitButtons();
    if self.switch then
        self.switch.deactivate();
        self.switch.activate();
    end
    if self.screen then
        self.screen.activate(); 
    end
    return self.InitOk;
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:CheckGear()
    local unit        = self.unit;
    local gear_down = unit.isAnyLandingGearDeployed();
    if (self.kmh >= 350.0) and (gear_down==1) then
        --self.system.print("Auto closing gear "     );
        unit.retractLandingGears();
    end   
    if (self.kmh <= 250.0) and (gear_down==0) then
        --self.system.print("Auto deploying gear ");
        unit.deployLandingGears();    
    end   
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:CheckShield()
    local shield=self.shield;
    if shield then
        local ready = (shield.getResistancesCooldown()==0);

        if ready ~= self.shield_ready then
            self.shield_ready=ready;
            if ready then
                self.system.print(">>> shield ready <<<"); 
            end
         end

        if ready then 

            local stress = shield.getStressRatioRaw();
            if stress[1]==0.0 and stress[2]==0.0 and stress[3]==0.0 and stress[4]==0.0 then
                stress[1]=0.25;
                stress[2]=0.25;
                stress[3]=0.25;
                stress[4]=0.25;
            end

            if self.set_shield_delay==0 then
                local last=self.shield_stress;
                local diff = ABS(last[1]-stress[1]) + ABS(last[2]-stress[2]) + ABS(last[3]-stress[3]) + ABS(last[4]-stress[4]);
                if diff>0.1 then
                    self.set_shield_delay=10;
                    self.system.print("requesting shield config");    
                end
            else
                self.set_shield_delay=self.set_shield_delay-1;
                if self.set_shield_delay<=0 then
                    self.set_shield_delay=0;
                    local pool = shield.getResistancesPool();
                    if shield.setResistances(stress[1]*pool,stress[2]*pool,stress[3]*pool,stress[4]*pool) then
                        self.system.print("shield configured");    
                        self.shield_stress=stress;
                    else
                        self.system.print("shield configuration failed");    
                    end
                end
            end
        end
    end
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:CheckRadar()
    local radar=self.radar;
    if radar then
        local target = self.radar_target;
        local id=radar.getTargetId();
        if id ~= target.id then
            target.id=id;
            -- self.system.print("target id changed");    
        end
        target.valid=false;
        if id~=nil then
           local v=radar.getConstructWorldPos(id);
           if v~=nil then
               if v[1]~=0 or v[2]~=0 or v[3]~=0 then
                   target.vec=vec3(v);
                   target.valid=true;
               end
           end
        end
    end
end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OnCursorKey(dx,dy)

    self.ScreenOffset.x = self.ScreenOffset.x + dx/20.0;
    self.ScreenOffset.y = self.ScreenOffset.y + dy/20.0;
    self.ScreenOffset.update=true;

    self.update_ui = true;

    self.system.print(format("Screen Offset %.2f %.2f",self.ScreenOffset.x,self.ScreenOffset.y));

end
   
    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OnStop()
    db_lib:Stop();
    if self.switch then
        self.switch.deactivate();
        self.switch.activate();
    end
    if self.screen then
        self.screen.deactivate(); 
    end
end
    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OnUpdate()
    
   if not self.InitOk then return end

   local core        = self.core;
   local construct   = self.construct;
   local player      = self.player;
   local unit        = self.unit;
   local system      = self.system;
   local gyro        = self.gyro;

   if self.v_forward == nil then
       self.v_forward = vec3(construct.getOrientationForward());
       self.v_up      = vec3(construct.getOrientationUp());
       self.v_right   = vec3(construct.getOrientationRight());

        self.mass      = construct.getMass();
        self.max_speed = construct.getMaxSpeed();
   end

   if self.telemeter then
       self.ground_distance = self.telemeter.raycast().distance;
   else
       self.ground_distance = -1;
   end    

   local t           = system.getArkTime();
   self.t            = t;
   self.fps_count    = self.fps_count+1;


   self.player_rel_pos  = vec3(player.getPosition()); 
   self.player_distance = self.player_rel_pos:len();

   self.altitude        = core.getAltitude();
   self.atmosphere      = unit.getAtmosphereDensity();  -- [ 0..1]
   self.planetinfluence = unit.getClosestPlanetInfluence(); -- [ 0..1]
   self.in_atmosphere   = (self.atmosphere > 0.001);
   self.near_planet     = (self.planetinfluence>0.001);

   local v_velo = vec3(construct.getVelocity());
   local speed  = v_velo:len();
   self.speed = speed;
   self.kmh   = speed * 3.6;


   local draw_10hz=false;
   local draw_1hz =false;

   if (t - self.t_10hz) >= 0.1 then
       self.t_10hz = t;
       draw_10hz = true;

       self:CheckAutoBrake();
       self:CheckRadar();

       if (t - self.t_2hz) >= 0.5 then
           self.t_2hz = t;
           self.blink = not self.blink;
       end
       if (t - self.t_1hz) >= 1.0 then
           self.t_1hz = t;
           draw_1hz = true;
           self.fps = self.fps_count;
           self.fps_count = 0;
           self.unit_data = json.decode(unit.getWidgetData());
           self.max_brake = self.unit_data.maxBrake;
           self.mass      = construct.getMass();
           self.max_speed = construct.getMaxSpeed();

           self:CalcRemainingTravelTime();
           self:CheckGear();
           self:CheckShield();
       end
   end


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

function FlyLib:CheckAutoBrake()

    self.current_brake_distance, self.current_brake_time = self:CalcBrakeDistance();
    local target=self.travel_target;
    if target.valid and self.auto_align then
        if self.target_auto_brake~=AUTOBRAKE_LOCK then

            local core = self.core;
            local construct = self.construct;
            local myPos=vec3(construct.getWorldPosition());

            local WorldVelocityDir     = vec3(construct.getWorldVelocity()):normalize();
            local constructVelocityDir = WorldVelocityDir;
            local constructVelocity    = self.kmh;
            local safety_factor = 1.1; -- 10% safety

            if self.in_atmosphere then
                local constructRight  = vec3(construct.getWorldOrientationRight());
                local worldVertical   = vec3(core.getWorldVertical()); -- along gravity
                constructVelocityDir  = constructRight:cross(worldVertical):normalize();
                -- constructVelocity     = constructVelocity * constructVelocityDir:dot(WorldVelocityDir);
                safety_factor         = 1.3;
            end

            if constructVelocity > target.shutoff_speed then
                local d = myPos.x * constructVelocityDir.x + 
                          myPos.y * constructVelocityDir.y +
                          myPos.z * constructVelocityDir.z;

                local target_d = target.vec.x * constructVelocityDir.x + 
                                 target.vec.y * constructVelocityDir.y + 
                                 target.vec.z * constructVelocityDir.z - d -target.brake_distance;

                if target_d > 0 then
                    if target_d  < self.current_brake_distance * safety_factor then
                        self.target_auto_brake = AUTOBRAKE_ON;
                    else
                        self.target_auto_brake = AUTOBRAKE_WAIT;
                    end
                else
                    self.target_auto_brake = AUTOBRAKE_LOCK;
                    self.system.print("auto brake lock - overshot target");
                end
            else
                if self.target_auto_brake~=AUTOBRAKE_OFF then
                    self.target_auto_brake = AUTOBRAKE_LOCK;
                    self.system.print("auto brake lock - low speed");
                end
            end
        end
    else
        self.target_auto_brake = AUTOBRAKE_OFF;
    end

    if self.near_planet then

        local atmo_speed_limit = 2050.0 - self.atmosphere * 1000.0;

        local slowdown_area    = 20000.0;
        local atmosphere_begin = 6000.0;
        local entry_speed_area = 10000.0;

        local normed_altitude=(self.altitude-atmosphere_begin) / slowdown_area;
        if normed_altitude < 0.0 then normed_altitude = 0.0 end
        if normed_altitude > 1.0 then normed_altitude = 1.0 end

        local entry_speed_limit=atmo_speed_limit + normed_altitude * entry_speed_area;

        if self.in_atmosphere then
            self.atmo_auto_brake =  self.kmh > entry_speed_limit;
        else
            self.atmo_auto_brake =  (self.pitch <= -45.0) and (self.kmh > entry_speed_limit);
        end
    else
        self.atmo_auto_brake = false;
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
   if screen then
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
                        velocity)

    local target=self.travel_target;
    local active=self.auto_align;
    if self.auto_target and self.radar_target.valid then
        target=self.radar_target;
        active=self.auto_target;
    end
    if target.valid then

        if self.autoPitchPID == nil then
            self.autoPitchPID = pid.new(self.AutoPitch * 0.01, 0, self.AutoPitch * 0.1);
            self.autoYawPID   = pid.new(self.AutoYaw   * 0.01, 0, self.AutoYaw   * 0.1);
            self.autoRollPID  = pid.new(self.AutoRoll  * 0.01, 0, self.AutoRoll   * 0.1);
            self.system.print("starting auto align");
        end

        local myPos=vec3(self.construct.getWorldPosition());
        local align_vector = (target.vec - myPos):normalize();
        local align_scalar_pitch = - align_vector:dot(constructUp);
        local align_scalar_yaw   = - align_vector:dot(constructRight);

        self.align_pitch_angle  =  ASIN(align_scalar_pitch) * rad_to_deg;
        self.align_yaw_angle    =  ASIN(align_scalar_yaw  ) * rad_to_deg;
        self.align_roll_angle   = 0;

        self.autoPitchPID:inject(-self.align_pitch_angle);
        self.autoYawPID:inject(self.align_yaw_angle);
        self.autoRollPID:inject(self.align_roll_angle);

        if active then
            
            local autoPitchInput =0.0;
            local autoYawInput   =0.0;
            local autoRollInput  =0.0;
        
            if not self.near_planet then
                autoPitchInput = self.autoPitchPID:get();
                autoRollInput  = self.autoRollPID:get(); 
            end
            autoYawInput   = self.autoYawPID:get();

            targetAngularVelocity.x = targetAngularVelocity.x +  
                autoPitchInput * constructRight.x +
                autoYawInput   * constructUp.x +
                autoRollInput  * constructForward.x;
            
            targetAngularVelocity.y = targetAngularVelocity.y +  
                autoPitchInput * constructRight.y +
                autoYawInput   * constructUp.y +
                autoRollInput  * constructForward.y;
            
            targetAngularVelocity.z = targetAngularVelocity.z +  
                autoPitchInput * constructRight.z +
                autoYawInput   * constructUp.z +
                autoRollInput  * constructForward.z;
        end

    else
        if self.autoPitchPID then
            self.autoPitchPID       = nil;
            self.autoYawPID         = nil;
            self.autoRollPID        = nil;
            self.align_pitch_angle  = nil;
            self.align_yaw_angle    = nil;
            self.align_roll_angle   = nil;
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

               local solar_system = atlas[_systemId];
               local position=
               {
                    systemId     = _systemId;
                    bodyId       = _bodyId;
                    latitude     = _latitude;
                    longitude    = _longitude;
                    altitude     = _altitude;
                    body         = nil;
                    type         = POSITION_TYPE_SPACE;
                    body         = nil;
               };
               if _bodyId ~= 0 then
                    local body=solar_system[_bodyId];
                    if body ~=nil then
                        position.body=
                        {
                            radius=body.radius;
                            center=vec3(body.center[1],body.center[2],body.center[3]);
                        };
                        local h  = body.radius + _altitude;
                        if h < 1000.0 then
                            position.type=POSITION_TYPE_PLANET;
                        else
                            if _altitude < 10000.0 then
                                position.type=POSITION_TYPE_SURFACE;
                            else
                                position.type=POSITION_TYPE_ORBIT;
                            end
                        end
                    end
               end
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
            local body = position.body;
            if body == nil then
                return vec3(position.latitude, position.longitude, position.altitude);
            else
                local h  = body.radius + position.altitude;
                local c  = body.center;
                local latitude  = position.latitude *deg_to_rad;
                local longitude = position.longitude*deg_to_rad;
                local cosl = COS(latitude);
                local x = c.x + h * COS(longitude) * cosl;
                local y = c.y + h * SIN(longitude) * cosl;
                local z = c.z + h * SIN(latitude);
                return vec3(x,y,z);
            end
        end
        return nil
    end

    function FlyLib:CalcTargetBreakDistance(position)
        -- return bake_distance, shutoff_speed
        if position then
            local body = position.body;
            if body then
                if position.type==POSITION_TYPE_PLANET then
                    return body.radius + 200000.0,5000.0; -- 1su above surface
                end
                if position.type==POSITION_TYPE_SURFACE then
                    return 100.0,200.0;
                end
            end
        end
        return 1000.0,500.0; -- default is 1km distance for a target in space
    end

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:OninputText(text)
    local position=self:ParsePosition(text);
    if position then
        local target=self.travel_target;
        target.position = position;
        target.vec      = self:CalcWorldCoordinates(position);
        target.brake_distance , target.shutoff_speed   = self:CalcTargetBreakDistance(position);
        self.system.print(format("%s brake distance %s" ,
                PositionTypeNames[position.type],
                self:DistanceText(target.brake_distance)));
        target.valid    = (target.vec ~= nil);
        target.update=true;
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
        self.auto_target=false;
        self.system.print("auto align on");
    else
        self.system.print("auto align off");
    end
end

function FlyLib:ToggleAutoTarget()
    self.auto_target = not self.auto_target;
    if self.auto_target then
        self.auto_align=false;
        self.system.print("auto target on");
    else
        self.system.print("auto target off");
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

local layer_crosshair=
[[ <svg width="100%" height="100%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
      <g fill="none" stroke="white" >
          <path d="M-100,0 h50 M50,0 h50 M0,-100 v50 M0,50 v50" stroke="#80808080" />
          <path d="M-50,0 h40 M10,0 h40 M0,-50 v40 M0,10 v40" />
          <circle cx="0" cy="0" r="10" />
       </g>
   </svg>
]];

local layer_frames=
[[ <svg width="100%" height="100%" viewBox="-160 -100 320 200" preserveAspectRatio ="xMidYMid meet" >
       <rect x=-160 y= -100 width=320 height=200 fill="black" stroke="none" />
       <g fill="none" stroke="#80808080" >
          <rect x=-135 y=-80 width=100 height=20 />
          <rect x=20 y=-100 width=140 height=20 />
          <rect x=20 y=-80  width=70  height=20 />
          <rect x=90 y=-80  width=70  height=20 />
          <rect x=60 y= 80 width=100 height=20 />
      </g>	
   </svg>
]];


local layer_text_format=
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
               <text x="90" y="7" %s</text>
               <text x="0"  y="90" %s</text>
               <text x="110" y="96">%s</text>
               <text x="100" y="-83">%s</text>
               <text x="60" y="-63">%s</text>
               <text x="130" y="-63">%s</text>
               <text x="-90" y="-63">%s</text>
            </g>	
            <g fill="white" style="font-size: 10px">
		     <text x="-160"  y="-85">FPS %d</text>
            </g>	
        </svg>
    </body>
]];

    -- ******************************************************************
    --
    -- ******************************************************************

function FlyLib:CheckScreens(draw_10hz,draw_1hz)
    local screen   = self.screen;
    if screen then
        local cx      = self.v_angle_h * ( rad_to_delta);
        local cy      = self.v_angle_v * (-rad_to_delta);
        local c_pitch = self.pitch * degree_to_delta; -- 1 degree = 20 units
        local layer_dynamic;


        if self.update_ui or screen.layer_frames == nil then
            screen.setHTML("");
            screen.clear(); 
            screen.layer_frames = screen.addContent(0,0,layer_frames);
        end
    
        if self.near_planet then
            layer_dynamic=format(layer_dynamic_atmo,self.roll,c_pitch,cx,cy);
        else   
            layer_dynamic=format(layer_dynamic_space,cx,cy);
        end   

        if self.update_ui or screen.layer_dynamic==nil then
            screen.layer_dynamic = screen.addContent(self.ScreenOffset.x,self.ScreenOffset.y,layer_dynamic);
        else
            screen.resetContent(screen.layer_dynamic,layer_dynamic);
        end   
    
        if self.update_ui or screen.layer_crosshair == nil then
            screen.layer_crosshair = screen.addContent(self.ScreenOffset.x,self.ScreenOffset.y,layer_crosshair);
        end


        if self:UpdateLayerUI() then
            if screen.layer_ui == nil then
                screen.layer_ui = screen.addContent(0,0,self.layer_ui);
            else
                screen.resetContent(screen.layer_ui,self.layer_ui);
            end
        end

        if draw_10hz then
            local x;
            local target = self.travel_target;
            -- **************************************************************************
            local pitch_text;
            if self.align_pitch_angle and not self.near_planet then
                pitch_text=format("fill=\"green\" >[%.1f]",self.align_pitch_angle);
            else
                pitch_text=format(">%.1f",self.pitch);
            end
            -- **************************************************************************
            local roll_text;
            if self.align_yaw_angle~=nil then
                roll_text =format("fill=\"green\" >[%.1f]",self.align_yaw_angle); 
            else
                roll_text =format(">%.1f",self.roll); 
            end
            -- **************************************************************************
            local alt_text;
            if self.near_planet then
                if self.ground_distance >=0 then
                    alt_text=format("(%.1f m)",self.ground_distance)
                else
                    alt_text=format("%.3f km",self.altitude / 1000.0)
                end    
            else
                alt_text="Space";
            end
            -- **************************************************************************
            local speed_text;
            if self.kmh <1.0 then
                speed_text="Stop";
            elseif self.kmh < 10000.0 then
                speed_text=format("%.0f km/h",self.kmh);
            else
                speed_text=format("%.1f Tkm/h",self.kmh/1000.0);
            end
            -- **************************************************************************
            x=self.current_brake_distance;
            if x~=self.current_brake_distance_compare then
                self.current_brake_distance_compare=x;
                self.current_brake_distance_text = self:DistanceText(x);
            end
            -- **************************************************************************
            x=target.brake_distance;
            if x ~= self.target_brake_distance_compare then
                self.target_brake_distance_compare=x;
                self.target_brake_distance_text = self:DistanceText(x);
            end
            -- **************************************************************************
            x=self.RemainingTravelTime;
            if x~=self.RemainingTravelTimeCompare then
                self.RemainingTravelTimeCompare=x;
                self.RemainingTravelTimeText = self:TimeText(x);
            end
            -- **************************************************************************
            local layer_text=format(layer_text_format,
                                pitch_text,
                                roll_text,
                                alt_text,
                                speed_text,
                                self.current_brake_distance_text,
                                self.target_brake_distance_text,
                                self.RemainingTravelTimeText,
                                self.fps);    

            if self.update_ui or screen.layer_text==nil then
                screen.layer_text = screen.addContent(0,0,layer_text);
            else
                screen.resetContent(screen.layer_text,layer_text);
            end    
        end    
    end
    self.update_ui = false;
end

function FlyLib:UpdateLayerUI()
    local buttons = self.buttons;
    local update_ui = self.update_ui;
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

function FlyLib:TimeText(t)
    if t~=nil then
        -- return os.date("%x",t);
        t = t // 1;
        local s = t % 60; t=t//60;
        local m = t % 60; t=t//60;
        local h = t;
        return format("%d:%02d:%02d",h,m,s);
    else
        return "--";
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
    if self.max_brake and self.mass and self.max_speed then
        local c = self.max_speed;
        local c2 = c*c;
        local target_speed  = 0.0;
        local accel    = -self.max_brake / self.mass;
        if self.speed > target_speed then
            if self.speed>c then c=self.speed; end
            local k1 = c * ASIN(self.speed/c);
            local k2 = c2 * COS(k1/c) / accel;
            time     = (c* ASIN(target_speed/c) - k1) / accel;
            distance = k2 - c2 * COS((accel * time + k1) /c) / accel;
        end
    end
    return distance,time;
end

function FlyLib:CalcRemainingTravelTime()
    local target= self.travel_target;
    self.RemainingTravelTime=nil;
    if target.valid then
        local myPos=vec3(self.construct.getWorldPosition());  
        local distance = (myPos-target.vec):len() - self.current_brake_distance - target.brake_distance;
        if distance > 0 and self.speed>=50.0 then
            self.RemainingTravelTime=distance / self.speed + self.current_brake_time;
        end
    end
end

return FlyLib;