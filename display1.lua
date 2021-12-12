objects = 
{
    { cont = cont1; disp=disp1; name="Iron";      container_type=3; container_count=3; container_volume=1075200; },
    { cont = cont2; disp=disp2; name="Aluminium"; container_type=3; container_count=3; container_volume= 716800; },
    { cont = cont3; disp=disp3; name="Carbon";    container_type=3; container_count=3; container_volume=1075200; },
    { cont = cont4; disp=disp4; name="Silicon";   container_type=3; container_count=3; container_volume= 896000; },
};

-- below code is the same for all units

container=
{
	[1]={ size="S" ; mass =  1280; volume =   8000; },
     [2]={ size="M" ; mass =  7420; volume =  64000; },
     [3]={ size="L" ; mass = 14840; volume = 128000; }
};

container_skill = 1.4; -- multiplyer for volume

materials=
{
      -- T1 ----------------
	["Carbon"] 	= { density = 2.27; comment="Coal";} ,
	["Aluminium"]= { density = 2.70; comment="Bauxite";} ,
	["Iron"]     = { density = 7.85; comment="Hematite";} ,
	["Silicon"]	= { density = 2.33; comment="Quartz";} ,

      -- T2 ----------------
   	["Chromium"] = { density = 7.19; comment="Chromite";} ,
   	["Copper"]	= { density = 8.96; comment="Malachite";} ,
   	["Calcium"]	= { density = 1.55; comment="Limestone";} ,
   	["Sodium"]	= { density = 0.97; comment="Natron";} ,
    
      -- T3 ----------------
     ["Nickel"]	= { density = 8.91; comment="Garniertite";} ,
     ["Lithium"] = { density = 0.53; comment="Petalite";} ,
     ["Silver"]	= { density = 10.49; comment="Acanthite";} , 
   	["Sulfur"]  = { density = 1.82; comment="Pyrite";} ,

    
   	["Ore"]	    = { density=2.0; },
	["WarpCells"]   = { density=2.5; volume=40; },    
};

function AnalyseContainer(o)
    local container_mass  = o.cont.getSelfMass();
    local container_type  = o.container_type;
    local container_count = o.container_count;
    local container_volume = o.container_volume or o.cont.getMaxVolume();

    if container_type == nil then
        container_count=1;
        if container_mass > 2000 then
            if container_mass > 8000 then
                container_type = 3;
            else
                container_type = 2;
            end
        else
            container_type = 1;
        end
    end
    
    local c = container[container_type];
    local m = materials[o.name];
    o.material   = m;
    if container_volume~=nil and container_volume>0 then
        system.print("container volume = " ..container_volume);     
        o.max_volume = container_volume;
    else
        o.max_volume = c.volume * container_skill * container_count;
    end
    o.mass   = -1.0;
    o.pieces =  0.0;
    o.density          = m.density;
    o.volume_per_piece = m.volume;
    if o.density and o.volume_per_piece then
    	o.mass_per_piece   = o.volume_per_piece * o.density;
    end    
    
end

function UpdateContainers()
   local n=#objects; 
   for i = 1,n do
        local o = objects[i];
        local cont = o.cont;
        local disp = o.disp;
        local m    = o.material;
        if cont then
            if disp then
                if o.max_volume then
                    local mass = cont.getItemsMass();
                    if mass~=nil and mass~=o.mass then	
                        o.mass    = mass;
                        o.volume  = mass / o.density;
                        o.percent = o.volume * 100.0 / o.max_volume;

                        disp.clear();
                        disp.addText(10,0,15,o.name);
                        
                        if m.comment then
	                      disp.addText(20,20,10,m.comment);
                        end
                        
                        local text=string.format("%.2f%%",o.percent);
                        disp.addText(5,40,18,text);

                        if o.mass_per_piece then
                        	o.pieces  = mass / o.mass_per_piece;
                             text=string.format("%d pcs",o.pieces );
                             disp.addText(10,80,10,text);
				   else 	                            
                            text=string.format("%.1f tons",mass / 1000.0 );
                            disp.addText(10,80,10,text);
                        end    
                    end
                else
                    AnalyseContainer(o);
                end  
            else
               system.print("Display not found : " .. o.name);         
            end    
        else
           system.print("Container not found : " .. o.name);    
        end    
   end    
end

function ShutDown()
   local n=#objects; 
   for i = 1,n do
        local o = objects[i];
        local disp = o.disp;
        disp.clear();
    end    
end


unit.setTimer("ContChecker",1.0);



