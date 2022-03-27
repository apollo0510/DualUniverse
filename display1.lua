objects = 
{
    { cont = cont1; disp=disp1; name="Iron";      container_volume=1075200; },
    { cont = cont2; disp=disp2; name="Aluminium"; container_volume= 716800; },
    { cont = cont3; disp=disp3; name="Carbon";    container_volume=1075200; },
    { cont = cont4; disp=disp4; name="Silicon";   container_volume= 896000; },
};

-- below code is the same for all units


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

      -- T4 ----------------
     ["Fluorine"] = { density = 1.70; comment="Cryolite";} ,
     ["Cobalt"]   = { density = 8.90; comment="Cobaltite";} ,
     ["Gold"]	 = { density = 19.30; comment="Nuggets";} , 
   	 ["Scandium"] = { density = 2.98; comment="Kolbecktite";} ,

    
   	["Ore"]	    = { density=2.0; },
	["WarpCells"]   = { density=2.5; volume=40; },    
};

function AnalyseContainer(o)
    local container_mass  = o.cont.getSelfMass();
    local container_volume = o.container_volume or o.cont.getMaxVolume();

    local m = materials[o.name];
    o.material   = m;
    o.max_volume = container_volume;
    o.mass   = -1.0;
    o.pieces =  0.0;
    o.density          = m.density;
    o.volume_per_piece = m.volume;
   
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
                    local volume = cont.getItemsVolume();
                    if volume~=nil and volume~=o.volume then	
                        o.volume    = volume;
                        o.percent = o.volume * 100.0 / o.max_volume;

                        disp.clear();
                        disp.addText(10,0,15,o.name);
                        
                        if m.comment then
	                      disp.addText(20,20,10,m.comment);
                        end
                        
                        local text=string.format("%.2f%%",o.percent);
                        disp.addText(5,40,18,text);

                        if o.volume_per_piece then
                        	o.pieces  = volume / o.volume_per_piece;
                             text=string.format("%d pcs",o.pieces );
                             disp.addText(10,80,10,text);
				   else 	                            
                            text=string.format("%.1f kL",volume / 1000.0 );
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




