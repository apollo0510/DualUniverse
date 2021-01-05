local unit_lib        = require("unit_lib");

local format          = string.format;

local recipe_table=
{
    Frames=
    {
         { id = 510615335; count = 20; name="bas stand XS" ;t=0.0},    
         { id = 461590286; count = 20; name="bas stand S" ;t=0.0},    
         { id = 461590276; count = 20; name="bas stand M" ;t=0.0},    
         { id = 461590277; count = 10; name="bas stand L" ;t=0.0},    

         { id = 376985783; count = 20; name="bas reinf XS" ;t=0.0},    
         { id = 266197940; count = 20; name="bas reinf S" ;t=0.0},    
         { id = 266197938; count = 20; name="bas reinf M" ;t=0.0},    
         { id = 266197949; count = 10; name="bas reinf L" ;t=0.0},    

         { id = 374123370; count = 20; name="unc reinf XS" ;t=0.0},    
         -- { id = 266176733; count = 20; name="unc reinf S" ;t=0.0},    
         { id = 266176771; count = 10; name="unc reinf M" ;t=0.0},    
    };
    
    Panels=
    {
        { id =117227222  ; count = 20; name="bas mob panel XS";t=0.0},   
        { id =2096261880 ; count = 20; name="bas mob panel S" ;t=0.0},   
        { id =2096261830 ; count = 20; name="bas mob panel M" ;t=0.0},   
        { id =2096261825 ; count = 10; name="bas mob panel L" ;t=0.0},   

        { id =84420764   ; count = 20; name="unc mob panel XS" ;t=0.0},   
        { id =2096240839 ; count = 20; name="unc mob panel S" ;t=0.0},   
        { id =2096240861 ; count = 10; name="unc mob panel M" ;t=0.0},   
        { id =2096240860 ; count = 10; name="unc mob panel L" ;t=0.0},   
    };
    
    Tanks=
    {
        { id =713802609 ; count = 20; name="bas chem cont XS" ;t=0.0},   
        { id =1815471308 ; count = 20; name="bas chem cont S" ;t=0.0},   
        { id =1815471302 ; count = 20; name="bas chem cont M" ;t=0.0},   
        { id =1815471301 ; count = 10; name="bas chem cont L" ;t=0.0},   

        { id =1815450741     ; count = 10; name="unc chem cont M" ;t=0.0},   

        { id =981789849 ; count = 20; name="bas gas cyl XS" ;t=0.0},   
        { id =1194767553 ; count = 20; name="bas gas cyl S" ;t=0.0},   
        { id =1194767567 ; count = 10; name="bas gas cyl M" ;t=0.0},   

        { id =648202053 ; count = 20; name="bas ionic cham XS" ;t=0.0},   
        { id =763768710 ; count = 20; name="bas ionic cham S" ;t=0.0},   
        { id =763768764 ; count = 20; name="bas ionic cham M" ;t=0.0},   
        { id =763768767 ; count = 10; name="bas ionic cham L" ;t=0.0},   
    };
    
    Robotics=
    {
        { id =1977512378 ; count = 20; name="bas robo arm M" ;t=0.0},   
        { id =1977512379 ; count = 20; name="bas robo arm L" ;t=0.0},   
        { id =1977298056 ; count = 20; name="unc robo arm M" ;t=0.0},   
    };

    Mix1=
    {
          { id =3936127019 ; count = 50; name="basic screw"          ;t=0.0}, 
          { id =3936127018 ; count = 50; name="uncommon screw"       ;t=0.0}, 

          { id =794666749 ; count = 50; name="basic component"       ;t=0.0}, 
          { id =794666748 ; count = 50; name="uncommon component"    ;t=0.0}, 
        
          { id =946503935 ; count = 50; name="basic casing XS"       ;t=0.0}, 
          { id =3808417022 ; count = 50; name="basic processor"       ;t=0.0}, 
        
          { id =1297540453 ; count = 50; name="uncommon electronics" ;t=0.0}, 

    };

    Mix2=
    {
          { id =2872711779 ; count = 50; name="bas connector"          ;t=0.0}, 
          { id =2872711778 ; count = 50; name="unc connector"          ;t=0.0}, 
          { id =527681755  ; count = 50; name="bas power sys"          ;t=0.0}, 
          { id =527681752  ; count = 50; name="unc power sys"          ;t=0.0}, 
          { id =466630565  ; count = 50; name="basic fixation" ;t=0.0}, 

    
          
    };

    Electro =
    {
         { id =474017912 ; count = 10; name="and operator" ;t=0.0}, 
         { id =201914900 ; count = 10; name="nand operator" ;t=0.0}, 
         { id =1349418519 ; count = 10; name="or operator" ;t=0.0}, 
         { id =1591620448 ; count = 10; name="nor operator" ;t=0.0}, 
         { id =827922060 ; count = 10; name="xor operator" ;t=0.0}, 
        
         { id =2050468732 ; count = 10; name="not operator" ;t=0.0}, 
         { id =1836783907 ; count = 10; name="relay" ;t=0.0}, 
         { id =1449541857 ; count = 10; name="databank" ;t=0.0}, 

         { id =1210245076 ; count = 10; name="manual button XS" ;t=0.0}, 
         { id =1623233219 ; count = 10; name="manual switch" ;t=0.0}, 
    };

    EquipXS=
    {
        { id =1383063781 ; count = 10; name="vert light XS" ;t=0.0}, 
        { id =555932566 ; count = 10; name="vert light S" ;t=0.0}, 
        { id =164219412 ; count = 10; name="vert light M" ;t=0.0}, 

        { id =441567189  ; count = 100; name="glass panel S" ;t=0.0}, 
        { id =283407660  ; count = 100; name="glass panel M" ;t=0.0}, 
        
        
    };

    EquipS=
    {
        { id =1601756570 ; count = 10; name="vert light L" ;t=0.0}, 
        { id =2045974002  ; count = 100; name="glass panel L" ;t=0.0}, 
        { id =760622009 ; count = 20; name="container XS" ;t=0.0}, 
    
    };

    EquipM=
    {
    
    };

    EquipL=
    {
    
    };

    PlaneL=
    {
    
    };

    PlaneM=
    {
    
    };

    PlaneS=
    {
    
    };

    PlaneXS=
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

    machine_stati=
    {   
        ["STOPPED"]                   = 1,
        ["RUNNING"]                   = 2,
        ["PENDING"]                   = 3,
        ["JAMMED_MISSING_INGREDIENT"] = 4, 
        ["JAMMED_OUTPUT_FULL"]        = 5,
        ["JAMMED_NO_OUTPUT_CONTAINER"]= 6
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
    
    recipe_by_id=
    {

    };
};

function industry_lib.new(system,unit)

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
    };

     local lib={};
     setmetatable(lib, { __index = industry_lib; } );
     lib.unit_lib     = unit_lib.new(system,unit,unit_classes);
     if lib.unit_lib.init_ok then
         lib.system       = system;
         lib.unit         = unit;
         lib.unit_classes = unit_classes;
         lib:BuildRecipeTable();
         -- system.print("industry_lib:BuildRecipeTable done");
         lib.init_ok=lib:AssignRecipeLists();
         -- system.print("industry_lib:AssignRecipeLists done");
         if lib.init_ok then
             unit.setTimer("Periodic",1.0);
         end   
     end
     return lib;
end

function industry_lib:ErrorHandler(text)
    local u=self.unit_classes;
    local screen=u.ScreenUnit[1];
    if screen then
	  screen.obj.setCenteredText(text);        
    else
        self.system.print(text);
    end    
end

function industry_lib:BuildRecipeTable()
    for _,recipe_list in pairs(recipe_table) do
        for _,recipe in pairs(recipe_list) do
            local id_string=tostring(recipe.id);
            self.recipe_by_id[id_string]=recipe;
            -- self.system.print("Adding recipe "..id_string);
        end    
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
            self:ErrorHandler(format("No recipe list for %s (%s)",industry.name,name_prefix));
            return false;
        end    
        industry.container = container_lookup[name_postfix];
        if not industry.container then
            self:ErrorHandler(format("No container match for %s (%s)",industry.name,name_postfix));
            return false;
        end    
    end    
    return true;
end

function industry_lib:PeriodicCheck(t)
    local u=self.unit_classes;
    local industry_table = u.Industry;
    local container_table = u.ItemContainer;
    
    local container_changed=false;
    local n=#container_table;
    for i=1,n do
        local container  = container_table[i];
        local volume = container.obj.getItemsVolume();
        local mass   = container.obj.getItemsMass();
        if (volume~=container.volume) or (mass~=container.mass) then
            container.volume = volume;
            container.mass   = mass;
            container.t      = t;
            container_changed= true;
            -- self.system.print("Container content changed : " .. container.name);
        end    
    end  

    local update_screen=false;
    n=#industry_table;
    for i=1,n do
        local industry    = industry_table[i];
        local m           = industry.obj; 
        local status      = self.machine_stati[m.getStatus()];
        local id          = m.getCurrentSchematic();

        if  (status~=industry.status) or 
            (id   ~=industry.id) or 
             container_changed then

            industry.status = status;
            industry.id     = id;
            update_screen   = true;
            
            local id_string=tostring(id);
            
            if (status==self.STATUS_STOPPED) then
                local recipe    = self.recipe_by_id[id_string];
                local container = industry.container;
                if recipe then
                    if recipe.t < container.t then
                        m.startAndMaintain(recipe.count);    
                        recipe.t = t;
                        -- self.system.print(format("Starting recipe %s : %d" , recipe.name,recipe.count));
                    else
                        local recipe_list = industry.recipe_list;
                        for r=1,#recipe_list do
                            recipe=recipe_list[r];
                            if recipe.t < container.t then
                                m.setCurrentSchematic(recipe.id);
                                -- self.system.print("Changing recipe to "..recipe.name);
                                break;
                            end   
                        end 
                    end
                end    
            elseif(status==self.STATUS_JAMMED_MISSING_INGREDIENT) then
               -- work here
            elseif(status~=self.STATUS_RUNNING) then
                m.hardStop();
                -- self.system.print("Stopping machine");    
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
        	local m = industry.obj; 
        	
             local status_name = m.getStatus();
             local status      = self.machine_stati[status_name];
             local si          = self.status_info  [status];
             local id_string   = tostring(industry.id);
             local recipe      = self.recipe_by_id[id_string];
             local text;
             if recipe then
                text=format("<tr style=\"color: %s\"><th>%s</th><th>%s</th><th>%s</th></tr>",si.color,industry.name,si.name,recipe.name);
             else
                text=format("<tr style=\"color: %s\"><th>%s</th><th>%s</th><th>%s</th></tr>",si.color,industry.name,si.name,id_string);
             end   
             table.insert(html,text);
         end  
         table.insert(html,html_end);
         local screen   = u.ScreenUnit[1].obj;
       	screen.setHTML(table.concat(html,'\n'));    

end


return industry_lib;