objects = 
{
    { cont = cont1; disp=disp1; name="Iron";      },
    { cont = cont2; disp=disp2; name="Aluminium"; },
    { cont = cont3; disp=disp3; name="Carbon";    },
    { cont = cont4; disp=disp4; name="Silicon";   },
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

    
   	 ["Ore"]	    = { density=2.0; },
	 ["WarpCells"]   = { density=2.5; volume=40; },    
};

function AnalyseContainer(o)

    local m = materials[o.name];
    o.material   = m;
    o.max_volume = o.cont.getMaxVolume();
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
                    local mass = cont.getItemsMass() or 0;
                    if mass~=o.mass then	
                        o.mass    = mass;
                        o.volume  = mass / o.density;
                        o.percent = o.volume * 100.0 / o.max_volume;

                        disp.clear();
                        disp.addText(10,0,15,o.name);
                        
                        if m.comment then
	                      disp.addText(20,20,10,m.comment);
                        end
                        
                        local text=string.format("%.2f%%",o.percent);
                        disp.addText(10,40,20,text);

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


unit.setTimer("ContChecker",1.0);


