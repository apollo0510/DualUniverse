local unit_lib        = require("unit_lib");

local format          = string.format;

local recipe_table=
{
    Frames=
    {
         { id = 510615335; count = 20; name="bas stand XS";},    
         { id = 461590286; count = 20; name="bas stand S";},    
         { id = 461590276; count = 20; name="bas stand M";},    
         { id = 461590277; count = 10; name="bas stand L";},    

         { id = 376985783; count = 20; name="bas reinf XS";},    
         { id = 266197940; count = 20; name="bas reinf S";},    
         { id = 266197938; count = 20; name="bas reinf M";},    
         { id = 266197949; count = 10; name="bas reinf L";},    
         { id = 376985790; count = 4; name="bas reinf XL";},

         { id = 374123370; count = 20; name="unc reinf XS";},    
         -- { id = 266176733; count = 20; name="unc reinf S";},    
         { id = 266176771; count = 10; name="unc reinf M";},    
         { id = 266176780; count = 10; name="unc reinf L";},
    };

    AdvFrames=
    {
        { id =264385523  ; count = 20; name="adv reinf S";},   
        { id =0  ; count = 20; name="adv reinf M";},   
        { id =0  ; count = 20; name="adv reinf L";},   
    };
        
    Panels=
    {
        { id =117227222  ; count = 20; name="bas mob panel XS";},   
        { id =2096261880 ; count = 20; name="bas mob panel S";},   
        { id =2096261830 ; count = 20; name="bas mob panel M";},   
        { id =2096261825 ; count = 10; name="bas mob panel L";},   

        { id =84420764   ; count = 20; name="unc mob panel XS";},   
        { id =2096240839 ; count = 20; name="unc mob panel S";},   
        { id =2096240861 ; count = 10; name="unc mob panel M";},   
        { id =2096240860 ; count = 10; name="unc mob panel L";},   
    };
    
    Tanks=
    {
        { id =713802609 ; count = 20; name="bas chem cont XS";},   
        { id =1815471308 ; count = 20; name="bas chem cont S";},   
        { id =1815471302 ; count = 20; name="bas chem cont M";},   
        { id =1815471301 ; count = 10; name="bas chem cont L";},   

        { id =1815450741     ; count = 10; name="unc chem cont M";},   

        { id =981789849 ; count = 20; name="bas gas cyl XS";},   
        { id =1194767553 ; count = 20; name="bas gas cyl S";},   
        { id =1194767567 ; count = 10; name="bas gas cyl M";},   

        { id =648202053 ; count = 20; name="bas ionic cham XS";},   
        { id =763768710 ; count = 20; name="bas ionic cham S";},   
        { id =763768764 ; count = 20; name="bas ionic cham M";},   
        { id =763768767 ; count = 10; name="bas ionic cham L";},   

        { id =763789004 ; count = 5; name="unc ionic cham L";},   
    };
    
    Robotics=
    {
        { id =1977512378 ; count = 20; name="bas robo arm M";},   
        { id =1977512379 ; count = 20; name="bas robo arm L";},   
        { id =1977298056 ; count = 20; name="unc robo arm M";},   
    };

    Mix1=
    {
          { id =3936127019 ; count = 200; name="basic screw";}, 
          { id =3936127018 ; count = 200; name="uncommon screw";}, 

          { id =1799107246 ; count = 200; name="basic pipe";}, 
          { id =1799107247 ; count = 200; name="uncommon pipe";}, 

          { id =794666749 ; count = 500; name="basic component";}, 
          { id =794666748 ; count = 50; name="uncommon component";}, 
        
          { id =946503935 ; count = 50; name="basic casing XS";}, 
          { id =3808417022 ; count = 50; name="basic processor";}, 
        
          { id =1297540453 ; count = 50; name="uncommon electronics";}, 

    };

    Mix2=
    {
          { id =2872711779 ; count = 50; name="bas connector";}, 
          { id =2872711778 ; count = 50; name="unc connector";}, 
          { id =527681755  ; count = 50; name="bas power sys";}, 
          { id =527681752  ; count = 50; name="unc power sys";}, 
          { id =466630565  ; count = 50; name="basic fixation";}, 
          { id =1331181119 ; count = 300; name="basic hydraulics";}, 

          { id = 3728054834; count = 10; name="basic electric engine S";}, 
          { id = 3728054836 ; count = 10; name="basic electric engine M";}, 
         
    };

    Electro =
    {
         { id =474017912 ; count = 10; name="and operator";}, 
         { id =201914900 ; count = 10; name="nand operator";}, 
         { id =1349418519 ; count = 10; name="or operator";}, 
         { id =1591620448 ; count = 10; name="nor operator";}, 
         { id =827922060 ; count = 10; name="xor operator";}, 
        
         { id =2050468732 ; count = 10; name="not operator";}, 
         { id =1836783907 ; count = 10; name="relay";}, 
         { id =1449541857 ; count = 10; name="databank";}, 

         { id =1210245076 ; count = 10; name="manual button XS";}, 
         { id =1623233219 ; count = 10; name="manual switch";}, 
    };

    EquipXS=
    {
        { id =1383063781 ; count = 10; name="vert light XS";}, 
        { id =555932566 ; count = 10; name="vert light S";}, 
        { id =164219412 ; count = 10; name="vert light M";}, 

        { id = 5872435 ; count = 20; name="screen  XS";}, 
        { id = 5872498 ; count = 20; name="screen  S";}, 
        { id = 5872566 ; count = 20; name="screen  M";}, 
        { id = 1337136126 ; count = 10; name="transp. screen  M";}, 


        { id =441567189  ; count = 100; name="glass panel S";}, 
        { id =283407660  ; count = 100; name="glass panel M";}, 
        
        
    };

    EquipS=
    {
        { id =1601756570 ; count = 10; name="vert light L";}, 
        { id =2045974002  ; count = 100; name="glass panel L";}, 
        { id =760622009 ; count = 20; name="container XS";}, 
        { id =1275490653 ; count = 1; name="Unc.Ass.Line S";}, 
    };

    EquipM=
    {
        { id = 1173587001  ; count = 20; name="container S";}, 

        { id = 1230093356  ; count = 5; name="chemical ind.";}, 
        { id = 1809397339  ; count = 5; name="electron. ind.";}, 
        { id = 1197243001  ; count = 5; name="glass furnace";}, 
        { id = 1113319562  ; count = 5; name="metalworks ind.";}, 

        { id = 39016077    ; count = 5; name="unc 3d printer";}, 
        { id = 1275491022  ; count = 5; name="unc ass line M";}, 
        { id = 1303072730  ; count = 5; name="unc chem. ind.";}, 
        { id = 1151494170  ; count = 5; name="unc elec. ind.";}, 
        { id = 1081167024  ; count = 5; name="unc glass furn.";}, 
        { id = 1993163113  ; count = 5; name="unc honeyc. ref.";}, 
        { id = 127106567   ; count = 5; name="unc metal. ind.";}, 
        { id = 1597739671  ; count = 1; name="unc refiner M";}, 
        { id = 1137084674  ; count = 1; name="unc smelter";}, 
       
    };

    EquipL=
    {
        { id = 937197329 ; count = 20; name="container M";}, 
        { id = 1702024841; count = 20; name="container L";}, 
    };

    PlaneL=
    {
        { id = 538110466 ; count = 4; name="Mil Space Eng L";}, 
    };

    PlaneM=
    {
        { id = 1145478538 ; count = 4; name="Space Fuel Tank M";}, 
        { id = 896390419  ; count = 4; name="Atmo Fuel Tank M";}, 
        { id = 1609056078 ; count = 10; name="Stabilizer M";}, 
        { id = 1117541306 ; count = 10; name="Atmo Airbrake L";}, 
        { id = 476284886  ; count = 10; name="Retro Rocketbrake L";}, 
        { id = 581659554  ; count = 20; name="Adjustor L";}, 
        { id = 1084256146 ; count = 10; name="Flat Hover Engine L";}, 

        { id = 100635561 ; count = 10; name="Airlock M";}, 
        { id = 1176770283 ; count = 10; name="Interior Door M";}, 
        { id = 700444865 ; count = 10; name="Reinforced Door M";}, 
        { id = 952044375 ; count = 10; name="Sliding Door M";}, 
    };

    PlaneS=
    {
        { id = 707706079 ; count = 10; name="Hatch S";}, 
        { id = 1405119260 ; count = 10; name="Sliding Door S";}, 
    
    };

    PlaneXS=
    {
        { id = 1972188620 ; count = 10; name="Adjustor S";}, 
        { id = 359449714 ; count = 10; name="Encampment Chair";}, 
        { id = 1834144963 ; count = 10; name="Fuel Intake XS";}, 
    };


    HoneyComb=
    {
        { id = 370095743 ; count = 300; name="Sodium Matte";}, 
        { id = 206461529 ; count = 300; name="Sodium Aged";}, 
        { id = 1866059236; count = 300; name="Sodium Glossy";}, 
        { id = 519399105; count = 100; name="Matte beige";}, 
        { id = 1689313836; count = 100; name="Matte beige cold";}, 
        { id = 518970978; count = 100; name="Matte black";}, 
        { id = 464851947; count = 100; name="Matte blue cold";}, 
        { id = 1119214409; count = 100; name="Matte blue";}, 
        { id = 2109465292; count = 100; name="Matte dark beige";}, 
        { id = 120381316; count = 100; name="Matte dark beige cold";}, 
        { id = 518920294; count = 100; name="Matte dark blue";}, 
        { id = 165456444; count = 100; name="Matte dark blue cold";}, 
        { id = 1203733057; count = 100; name="Matte dark gray";}, 
        { id = 1504635849; count = 100; name="Matte dark green";}, 
        { id = 1673403525; count = 100; name="Matte dark green cold";}, 
        -- { id = 1528941636; count = 100; name="Matte dark orange";}, 
        -- { id = 811578893; count = 100; name="Matte dark orange cold";}, 
        { id = 1140432965; count = 100; name="Matte dark red";}, 
        { id = 1965917139; count = 100; name="Matte dark red cold";}, 
        { id = 194906983; count = 100; name="Matte yellow red";}, 
        { id = 2019620475 ; count = 100; name="Matte dark yellow cold";}, 
        { id = 1195626365; count = 100; name="Matte gray";}, 
        { id = 1203228381; count = 100; name="Matte green";}, 
        { id = 848897495; count = 100; name="Matte green cold";}, 
        -- { id = 2109465300; count = 100; name="Matte light beige";}, 
        -- { id =120381340 ; count = 100; name="Matte light beige cold";}, 
        { id =518920318 ; count = 100; name="Matte light blue";}, 
        { id =165456436 ; count = 100; name="Matte light blue cold";}, 
        { id =1203733049 ; count = 100; name="Matte light gray";}, 
        { id =1504635841 ; count = 100; name="Matte light green";}, 
        { id =1673403533 ; count = 100; name="Matte light green cold";}, 
        { id =1528941644 ; count = 100; name="Matte light orange";}, 
        -- { id =811579125 ; count = 100; name="Matte light orange cold";}, 
        { id = 1140432973; count = 100; name="Matte light red";}, 
        -- { id = 1965917147; count = 100; name="Matte light red cold";}, 
        { id =194907007 ; count = 100; name="Matte light yellow";}, 
        { id =2019620451 ; count = 100; name="Matte light yellow cold";}, 
        { id =1976371233 ; count = 100; name="Matte orange";}, 
        -- { id =1294971511 ; count = 100; name="Matte orange cold";}, 
        { id =349121824 ; count = 100; name="Matte red";}, 
        { id =1898326674 ; count = 100; name="Matte red cold";}, 
        { id =68509334 ; count = 100; name="Matte white";}, 
        { id =571173960 ; count = 100; name="Matte yellow";}, 
        -- { id =1144275122 ; count = 100; name="Matte yellow cold";}, 
        
    };

     Fuel=
     {
        { id = 400056330 ; count = 20000; name="Xeron Fuel";}, 
        { id = 1814211557 ; count = 40000; name="Nitron Fuel";}, 
        { id = 1397521130 ; count = 40000; name="Kergon-X3 Fuel";}, 
     };

     WarpMix1=
     {
        { id = 1673011820 ; count = 500; name="CU-AG Alloy";}, 
        { id = 1034957327 ; count = 500; name="Calcium Reinforced Copper";}, 
        { id = 3308209457 ; count = 2000; name="Glass";}, 
        { id = 18262914 ; count = 1000; name="AL-FE Alloy";}, 
        { id = 2872711778 ; count = 500; name="Uncommon Connector";}, 
        { id = 2872711779 ; count = 1000; name="Basic Connector";}, 
        { id = 794666749 ; count =  1000; name="Basic Component";}, 
     };

     WarpMix2=
     {
        { id = 1234754161 ; count = 500; name="Uncommon Led";}, 
        { id = 1234754162 ; count = 2000; name="Basic Led";}, 
        { id = 2097691217 ; count = 1000; name="Polysulfide Plastic";}, 
        { id = 4103265826 ; count = 1000; name="Polycalcite Plastic";}, 
        { id = 2014531313 ; count = 2000; name="Polycarbonate Plastic";}, 
     };

     ShieldMix1=
     {
        { id = 1234754162 ; count = 200; name="Basic Led";}, 
        { id = 1234754161 ; count = 200; name="Uncommon Led";}, 
        { id = 1234754160 ; count = 200; name="Advanced Led";}, 

        { id = 3739200051 ; count = 200; name="Basic Optics";}, 
        { id = 3739200050 ; count = 200; name="Unc. Optics";}, 
        { id = 3739200049 ; count = 200; name="Adv. Optics";}, 

        { id = 2301749833 ; count = 200; name="AgLi Glas";}, 
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
        DataBankUnit =
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
        local recipe_by_id={};
        for _,recipe in ipairs(recipe_list) do
            local id_string=tostring(recipe.id);
            recipe_by_id[id_string]=recipe;
            -- self.system.print("Adding recipe "..id_string);
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



function industry_lib:SecureCall(func_name,t)
    local f = self[func_name];
    local ok, message = pcall(f,self,t);
    if not ok then
       local text= string.format("Error in %s :\n%s",func_name,message);
       self.system.print(string.gsub(text,"\n", "<br>"));
    end
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
            local recipe_list = industry.recipe_list;
            
            if (status==self.STATUS_STOPPED) then
                local recipe    = recipe_list.recipe_by_id[id_string];
                local container = industry.container;
                if recipe then

                    local recipe_times= industry.recipe_times;
                    if recipe_times == nil then
                        recipe_times={};
                        industry.recipe_times=recipe_times;
                    end

                    local recipe_time=recipe_times[id_string];
                    if (recipe_time==nil) or  (recipe_time < container.t) then
                        m.startAndMaintain(recipe.count);    
                        recipe_times[id_string]=t;
                        -- self.system.print(format("Starting recipe %s : %d" , recipe.name,recipe.count));
                    else
                        for r=1,#recipe_list do
                            recipe=recipe_list[r];
                            id_string=tostring(recipe.id);
                            recipe_time=recipe_times[id_string];
                            if (recipe_time==nil) or  (recipe_time < container.t) then
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
            local recipe_list = industry.recipe_list;
        	local m = industry.obj; 
        	if m then
                 local status_name = m.getStatus();
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