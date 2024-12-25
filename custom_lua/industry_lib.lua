local unit_lib        = require("unit_lib");

local format          = string.format;
local ABS             = math.abs;

local recipe_table=
{
    Frames=
    {
         { id = 510615335; count = 20; name="bas stand XS";},    
    };

    Panels=
    {
    };
    
    Tanks=
    {
    };

};

local industry_lib= 
{
    STATUS_STOPPED                    = 1;
    STATUS_RUNNING                    = 2;
    STATUS_PENDING                    = 3;
    STATUS_ERROR                      = 4;
    STATUS_JAMMED_MISSING_INGREDIENT  = 4;
    STATUS_JAMMED_OUTPUT_FULL         = 5;
    STATUS_JAMMED_NO_OUTPUT_CONTAINER = 6;
    STATUS_JAMMED_NO_SCHEMATICS       = 7;

    machine_stati=
    {   
        ["STOPPED"]                   = 1,
        ["RUNNING"]                   = 2,
        ["PENDING"]                   = 3,
        ["JAMMED_MISSING_INGREDIENT"] = 4, 
        ["JAMMED_OUTPUT_FULL"]        = 5,
        ["JAMMED_NO_OUTPUT_CONTAINER"]= 6,
        ["STATUS_JAMMED_NO_SCHEMATICS"]= 7
    };

    status_info=
    {   
        { name="Stop"	, color="#808080" },
        { name="Run"	, color="#40FF40" },
        { name="Pend"	, color="#FFFFFF" },
        { name="Ingr"	, color="#FF4040" },
        { name="Full"	, color="#FF4040" },
        { name="Jammed"  , color="#FF4040" },
    };
    
};

function industry_lib.new(system,unit,player)

    local unit_classes=
    {
        CoreUnit         = { need = 1; meta = nil; },
        ScreenUnit       = { need = 1; meta = nil; },
        Industry         = 
        { 
            need = 1; 
            meta = { __index={ status=0; current_id=0; }; };    
        },
        ItemContainer    = 
        { 
            need = 1; 
            meta = { __index={ volume=0.0; mass=0.0; t=0.0; }; }; 
        },
        DataBankUnit =
        {
           need = 0;
        },
        CounterUnit =
        {
            need = 0;
        },
        LaserDetectorUnit =
        {
            need = 0;
        },
        ManualSwitchUnit =
        {
            need = 0;
        },
    };

     local lib={};
     setmetatable(lib, { __index = industry_lib; } );
     lib.unit_lib     = unit_lib.new(system,unit,unit_classes);
     if lib.unit_lib.init_ok then
         lib.system       = system;
         lib.unit         = unit;
         lib.player       = player;
         lib.unit_classes = unit_classes;
         lib.service_slot = 1000;
         lib.warm_up      = 50;

         lib:BuildRecipeTable();
         -- system.print("industry_lib:BuildRecipeTable done");
         lib.init_ok=lib:AssignRecipeLists();
         -- system.print("industry_lib:AssignRecipeLists done");
         if lib.init_ok then
             lib:InitTransponder();
         end   
     end
     return lib;
end

function industry_lib:ErrorHandler(text,switch_off)
    local u=self.unit_classes;
    local screen=u.ScreenUnit[1];
    if screen then
	  screen.obj.setCenteredText(text);        
    else
        self.system.print(text);
    end    
end

function industry_lib:ShutDown()
    local u=self.unit_classes;
    local screen=u.ScreenUnit[1];
    if screen then
	  screen.obj.setCenteredText("Offline");        
    end    
    local switch  =u.ManualSwitchUnit[1];
    if switch then
        switch.obj.activate();
    end
end

function industry_lib:BuildRecipeTable()
    --local core=self.unit_lib.core;
    for _,recipe_list in pairs(recipe_table) do
        local recipe_by_id={};
        for _,recipe in ipairs(recipe_list) do
            local id_string=tostring(recipe.id);
            recipe_by_id[id_string]=recipe;
            --    local json_string=core.getSchematicInfo(recipe.id);
            --    self.system.print("Adding recipe "..json_string);
        end    
        recipe_list.recipe_by_id=recipe_by_id;
    end
end

function industry_lib:AssignRecipeLists()
    local u = self.unit_classes;
    local industry_table = u.Industry;
    local container_table = u.ItemContainer;
    
    local container_lookup = {};
    
    local n=#container_table;
    for i=1,n do
        local container  = container_table[i];
        container_lookup[container.name]=container;
    end    
    
    n=#industry_table;
    for i=1,n do
        local industry    = industry_table[i];
        local separator   = string.find(industry.name,"_");
        local name_prefix;
        local name_postfix;
        if separator and separator>1 then
            name_prefix = string.sub(industry.name,1,separator-1);
            name_postfix= string.sub(industry.name,separator+1);
        else
            name_prefix = industry.name;
            name_postfix= industry.name;
        end
        industry.recipe_list = recipe_table[name_prefix];
        if not industry.recipe_list then
            self:ErrorHandler(format("No recipe list for %s (%s)",industry.name,name_prefix),true);
            return false;
        end    
        industry.container = container_lookup[name_postfix];
        industry.container_time = 0;
        if not industry.container then
            self:ErrorHandler(format("No container match for %s (%s)",industry.name,name_postfix),true);
            return false;
        end    
    end    
    return true;
end



function industry_lib:SecureCall(func_name,a1,a2)
    local f = self[func_name];
    local ok, message = pcall(f,self,a1,a2);
    if not ok then
       local text= string.format("Error in %s :\n%s",func_name,message);
       self.system.print(string.gsub(text,"\n", "<br>"));
    end
end

function industry_lib:ContainerCheck(t)

    local u=self.unit_classes;
    local container_table = u.ItemContainer;

    local n_container=#container_table;
    for i=1,n_container do
        local container  = container_table[i];
        local cont_obj   = container.obj;

        if container.acquire_pending then
            container.acquire_pending = false;
            local json_string=cont_obj.getItemsList();
            local item_list = json.encode(json_string);
            self.system.print(json_string);
        else
            local volume = cont_obj.getItemsVolume();
            local mass   = cont_obj.getItemsMass();
            if (volume~=container.volume) or (mass~=container.mass) then
                container.volume = volume;
                container.mass   = mass;
                container.t      = t;
                -- cont_obj.acquireStorage();
                -- container.acquire_pending = true;
                -- self.system.print("Container content changed : " .. container.name);
            end
        end
    end  
end 

function industry_lib:InitTransponder()
    local u = self.unit_classes;    
    local counter =u.CounterUnit[1];
    local detector=u.LaserDetectorUnit[1];
    if counter or not detector then
        self.unit.setTimer("Periodic",0.5);
    end
end


function industry_lib:OnPeriodic()
    local u = self.unit_classes;
    local counter=u.CounterUnit[1];
    local detector=u.LaserDetectorUnit[1];
    local switch  =u.ManualSwitchUnit[1];

    if self.warm_up then
        self.warm_up=self.warm_up-1;
        if self.warm_up<=0 then
            self.warm_up = nil;
            self.unit.setTimer("Periodic",0.20);
        end
    end

    local player_distance= self.player.getPosition();
    local r  = 50;
    local dx = ABS(player_distance[1]);
    local dy = ABS(player_distance[2]);
    local dz = ABS(player_distance[3]);
    if dx < r and dy<r and dz<r then
        if switch then switch.obj.deactivate(); end
        if counter then
            counter.obj.nextIndex();
        end
        if not detector then
            self:RunService();
        end
    else
        if switch then switch.obj.activate(); end
    end
end

function industry_lib:OnStop()
    local u = self.unit_classes;
    local switch  =u.ManualSwitchUnit[1];
    if switch then
        switch.obj.activate();
    end
end

function industry_lib:RunService()

    local t=self.system.getArkTime();
    local u=self.unit_classes;
    local industry_table = u.Industry;

    local update_screen=false;
    local n_industry=#industry_table;
    if n_industry>0 then

        self.service_slot=self.service_slot+1;
        if self.service_slot>n_industry then 
            self.service_slot=1; 
            self:ContainerCheck(t);
        end

        local industry    = industry_table[self.service_slot];
        local m           = industry.obj; 
        local status      = self.machine_stati[m.getState()];
        local id_list     = m.getOutputs();
        local id          = 0;
        if id_list then
            local n=#id_list;
            if n>=1 then
                id = id_list[1];
            end
        end
        local container = industry.container;

        if  (status~=industry.status) or 
            (id   ~=industry.id) or 
            (container.t ~= industry.container_time )  then

            industry.status = status;
            industry.id     = id;
            industry.container_time = container.t;
            update_screen   = true;
            
            local id_string=tostring(id);
            local recipe_list = industry.recipe_list;
            
            if (status==self.STATUS_STOPPED) then
                local recipe    = recipe_list.recipe_by_id[id_string];
                if recipe then

                    local recipe_times= industry.recipe_times;
                    if recipe_times == nil then
                        recipe_times={};
                        industry.recipe_times=recipe_times;
                    end

                    local recipe_time=recipe_times[id_string];
                    if (recipe.count>0) and ((recipe_time==nil) or  (recipe_time < container.t)) then
                        m.startMaintain(recipe.count);    
                        recipe_times[id_string]=t;
                        --self.system.print(format("Starting recipe %s : %d" , recipe.name,recipe.count));
                    else
                        for r=1,#recipe_list do
                            recipe=recipe_list[r];
                            id_string=tostring(recipe.id);
                            recipe_time=recipe_times[id_string];
                            if (recipe_time==nil) or  (recipe_time < container.t) then
                                m.setOutput(recipe.id);
                                --self.system.print("Changing recipe to "..recipe.name);
                                break;
                            end   
                        end 
                    end
                end    
            elseif(status==self.STATUS_JAMMED_MISSING_INGREDIENT) then
                local recipe    = recipe_list.recipe_by_id[id_string];
                if recipe then
                   if recipe.ignore_missing then
                      self.system.print("Ignoring missing ingredients");    
                       m.stop(true);
                   end
                end
            elseif(status~=self.STATUS_RUNNING) then
                m.stop(true);
                --self.system.print("Stopping machine");    
            end    
        end
    end
    
    if update_screen then
        self:UpdateScreen();
    end
end    


local html_begin =
[[
<div class="bootstrap">
     <header>   
         <style>
            table,tr,th,td
             {
                font-family: ArialMT , Arial, sans-serif; 
                font-size: 20px ;
                text-align: left ;
                border: 1px solid white;
        	   background-color: black;
            }
         </style>
     </header>   
     <body>
         <table width="100%">
            <tr style="color: #0000FF" >   
                <th>Name</th>
                <th>Status</th> 
                <th>Recipe</th> 
            </tr> 
]];
        
local html_end=
[[
		</table>
        </body>
     </div>
]];

function industry_lib:UpdateScreen()

        local html={ [1]=html_begin; };
        local u = self.unit_classes;
        local industry_table = u.Industry;
        n=#industry_table;
    	for i=1,n do
        	local industry=industry_table[i];
            local recipe_list = industry.recipe_list;
        	local m = industry.obj; 
        	if m then
                 local status_name = m.getState();
                 if status_name then
                     local status      = self.machine_stati[status_name];
                     if status then
                         local si          = self.status_info  [status];
                         if si then
                             local id_string   = tostring(industry.id);
                             local recipe      = recipe_list.recipe_by_id[id_string];
                             local text;
                             if recipe then
                                text=format("<tr style=\"color: %s\"><th>%s</th><th>%s</th><th>%s</th></tr>",si.color,industry.name,si.name,recipe.name);
                             else
                                text=format("<tr style=\"color: %s\"><th>%s</th><th>%s</th><th>%s</th></tr>",si.color,industry.name,si.name,id_string);
                             end   
                             table.insert(html,text);
                         end
                     end
                 end
             end
         end  
         table.insert(html,html_end);
         local screen   = u.ScreenUnit[1].obj;
       	screen.setHTML(table.concat(html,'\n'));    

end


return industry_lib;