local unit_lib        = require("unit_lib");

local format          = string.format;
local ABS             = math.abs;

local recipe_table=
{
-- **********************************************************
--
-- **********************************************************

    PosRefiner=
    {
         { id = 1199082577; count = 1000; name="Pure Alu";     ignore_missing=true; },    
         { id = 1262929839; count = 1000; name="Pure Carbon";  ignore_missing=true; },    
         { id = 1833008839; count = 1000; name="Pure Iron";    ignore_missing=true; },  
         { id = 1678829760; count = 1000; name="Pure Silicon"; ignore_missing=true; },  
         { id = 67742786; count = 1000; name="Pure Chromium"; ignore_missing=true; },  
    };

    PosChemical=
    {
         { id = 1814211557; count = 20000; name="Nitron";},    
         { id = 1397521130; count = 20000; name="Kergon-X3";},    
    };

    PosRecycler=
    {
         { id = 722030824; count =  200; name="Pure Hydrogene"; },    
         { id = 608747454; count =  400; name="Pure Oxygene";   },    
         -- { id = 702266664; count = 3000; name="Copper Scrap"; },    
         { id = 119221489; count = 3000; name="Chromium Scrap";  },    
    };

    PosTransfer=
    {
         { id = 1010524904; count =  200; name="Pure Hydrogene"; ignore_missing=true; },    
         { id = 947806142; count =  400; name="Pure Oxygene";  ignore_missing=true; },    
    };

-- **********************************************************
--
-- **********************************************************

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
         { id = 266176773; count = 20; name="unc reinf S";},    
         { id = 266176771; count = 10; name="unc reinf M";},    
         { id = 266176780; count = 10; name="unc reinf L";},
    };

    AdvFrames=
    {
         { id = 461676511; count = 10; name="unc stand S";},
         { id = 461676501; count = 10; name="unc stand M";},
         { id = 461676500; count = 10; name="unc stand L";},

        { id =494352223  ; count = 20; name="adv reinf XS";},  
        { id =264385523  ; count = 20; name="adv reinf S";},   
        { id =264385481  ; count = 20; name="adv reinf M";},   
        { id =264385482  ; count = 20; name="adv reinf L";},   

        { id =487996202  ; count = 20; name="adv stand XS";},   
    };

    Transformer=
    {
        { id =1365338032  ; count = 10; name="unc transf S";},   
        { id =1365333629  ; count = 10; name="bas transf M";},
        { id =1365338026  ; count = 10; name="unc transf M";},   
        { id =1365686171  ; count = 5; name="adv transf M";},
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

        { id = 2096236588; count = 5; name="adv mob panel M";},   
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
        { id =763760349 ; count = 1; name="adv ionic cham L";},

         { id =1815447012 ; count = 10; name="adv chem cont M";},
    };
    
    Robotics=
    {
        { id =1977512378 ; count = 20; name="bas robo arm M";},   
        { id =1977512379 ; count = 20; name="bas robo arm L";},   
        { id =1977298056 ; count = 20; name="unc robo arm M";},   
        { id =1977408761 ; count = 5; name="adv robo arm M";},   
    };

-- **********************************************************
--
-- **********************************************************

    Mix1=
    {
          { id =3936127019 ; count = 800; name="basic screw";}, 
          { id =3936127018 ; count = 800; name="uncommon screw";}, 

          { id =1799107246 ; count = 200; name="basic pipe";}, 
          { id =1799107247 ; count = 200; name="uncommon pipe";}, 

          { id =1331181119 ; count = 300; name="basic hydraulics";}, 

          { id =794666749 ; count = 500; name="basic component";}, 
          { id =794666748 ; count = 200; name="uncommon component";}, 

          { id =2872711779 ; count = 50; name="bas connector";}, 
          { id =2872711778 ; count = 50; name="unc connector";}, 
        
          { id =527681755  ; count = 50; name="bas power sys";}, 
          { id =527681752  ; count = 50; name="unc power sys";}, 

          { id =1297540454 ; count = 50; name="basic electronics";}, 
          { id =1297540453 ; count = 50; name="uncommon electronics";}, 


    };

    Mix2=
    {
          { id =466630565  ; count = 50; name="basic fixation";}, 

          { id = 3728054834; count = 10; name="basic electric engine S";}, 
          { id = 3728054836 ; count = 10; name="basic electric engine M";}, 

          { id =3808417022 ; count = 50; name="basic processor";}, 
        
          { id =946503935 ; count = 50; name="basic casing XS";}, 
          -- { id = ; count = 50; name="unc casing XS";}, 
         
    };

-- **********************************************************
--
-- **********************************************************

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
         { id =819585790 ; count = 10; name="Telemeter";}, 
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
        { id = 1337135686 ; count = 10; name="transp. screen  L";}, 


        { id =441567189  ; count = 200; name="glass panel S";}, 
        { id =283407660  ; count = 200; name="glass panel M";}, 
        
        { id =2127592346 ; count = 2; name="Unc.Ass.Line XS";}, 

    };

    EquipS=
    {
        { id =1601756570 ; count = 10; name="vert light L";}, 
        { id =2045974002  ; count = 200; name="glass panel L";}, 
        { id =760622009 ; count = 20; name="container XS";}, 
        { id =1275490653 ; count = 2; name="Unc.Ass.Line S";}, 
        { id =1053616004 ; count = 2; name="RezzNode";}, 
    };

    EquipM=
    {
        { id = 1173587001  ; count = 20; name="container S";}, 

        { id = 1230093356  ; count = 0; name="chemical ind.";}, 
        { id = 1809397339  ; count = 0; name="electron. ind.";}, 
        { id = 1197243001  ; count = 0; name="glass furnace";}, 
        { id = 1113319562  ; count = 0; name="metalworks ind.";}, 
        { id = 487570606  ; count = 0; name="basic recycler";},

        { id = 39016077    ; count = 0; name="unc 3d printer";}, 
        { id = 1275491022  ; count = 2; name="unc ass line M";}, 
        { id = 1303072730  ; count = 0; name="unc chem. ind.";}, 
        { id = 1151494170  ; count = 0; name="unc elec. ind.";}, 
        { id = 1081167024  ; count = 0; name="unc glass furn.";}, 
        { id = 1993163113  ; count = 0; name="unc honeyc. ref.";}, 
        { id = 127106567   ; count = 0; name="unc metal. ind.";}, 
        { id = 1597739671  ; count = 0; name="unc refiner M";}, 
        { id = 1137084674  ; count = 0; name="unc smelter";}, 

        { id =55289725    ; count = 10; name="TerriUnit";}, 
        { id =1339054248  ; count = 10; name="Static Core M";}, 


        -- { id = 921860876  ; count = 1; name="scaffolding";},
       
    };

    EquipL=
    {
        { id = 937197329 ; count = 10; name="container M";}, 
        { id = 1702024841; count = 10; name="container L";}, 
        { id = 1339132959; count = 0; name="stat Core L";}, 
        { id = 1275490954; count = 0;  name="unc Ass L";},

        { id = 721775397 ; count = 10;  name="Transfer Unit";},
    };

-- **********************************************************
--
-- **********************************************************

    SanctEquipL=
    {
        { id = 937197329 ; count = 10; name="container M";}, 
        { id = 1702024841; count = 10; name="container L";}, 
        { id = 721775397 ; count = 10;  name="Transfer Unit";},
    };

    SanctEquipM=
    {
        { id = 1173587001  ; count = 10; name="container S";}, 
        { id = 1113319562  ; count = 5; name="metalworks ind.";}, 
        { id =  908248479  ; count = 5; name="3d printer";}, 
        { id = 1809397339  ; count = 5; name="electron. ind.";}, 
        { id = 1230093356  ; count = 5; name="chemical ind.";}, 
        { id = 1197243001  ; count = 5; name="glass furnace";}, 
        { id = 1837549935  ; count = 1; name="honeyc. ref.";}, 
        { id = 1464958039  ; count = 1; name="basic refiner";},
        { id = 487570606   ; count = 1; name="basic recycler";},
        { id = 960095718   ; count = 1; name="basic smelter";}, 
        { id = 2078992795  ; count = 1; name="ass. line L";},

        { id = 1176770283 ; count = 10; name="Interior Door M";}, 
        { id = 700444865 ; count = 10; name="Reinforced Door M";}, 
        { id = 952044375 ; count = 10; name="Sliding Door M";}, 


    };

    SanctEquipS=
    {
        { id =760622009 ; count = 10; name="container XS";}, 
        { id =2078992796 ; count = 5; name="Bas.Ass.Line M";}, 
        { id =2078992786 ; count = 5; name="Bas.Ass.Line S";}, 

    };

    SanctEquipXS=
    {
        { id =1549896461 ; count = 5; name="Programming Board";}, 
        { id =1349418519 ; count = 10; name="OR operator";}, 
        { id =2050468732 ; count = 10; name="NOT operator";}, 
        { id =474017912 ; count = 10; name="AND operator";}, 
        { id =201914900 ; count = 10; name="NAND operator";}, 
        { id =1591620448 ; count = 10; name="NOR operator";}, 
        { id =827922060 ; count = 10; name="XOR operator";}, 
    };


    SanctFrames=
    {
         { id = 510615335; count = 20; name="bas stand XS";},    
         { id = 461590286; count = 20; name="bas stand S";},    
         { id = 461590276; count = 20; name="bas stand M";},    
         { id = 461590277; count = 10; name="bas stand L";},    

         { id = 376985783; count = 20; name="bas reinf XS";},    
         { id = 266197940; count = 20; name="bas reinf S";},    
         { id = 266197938; count = 20; name="bas reinf M";},    
         { id = 266197949; count = 10; name="bas reinf L";},    
         --{ id = 376985790; count = 4; name="bas reinf XL";},

         --{ id = 374123370; count = 20; name="unc reinf XS";},    
         --{ id = 266176773; count = 20; name="unc reinf S";},    
         --{ id = 266176771; count = 10; name="unc reinf M";},    
         --{ id = 266176780; count = 10; name="unc reinf L";},
    };

    SanctPanels=
    {
        { id =117227222  ; count = 20; name="bas mob panel XS";},   
        { id =2096261880 ; count = 20; name="bas mob panel S";},   
        { id =2096261830 ; count = 20; name="bas mob panel M";},   
        { id =2096261825 ; count = 10; name="bas mob panel L";},   
        { id =117227225 ; count = 1; name="bas mob panel XL";},   

        --{ id =84420764   ; count = 20; name="unc mob panel XS";},   
        --{ id =2096240839 ; count = 20; name="unc mob panel S";},   
        --{ id =2096240861 ; count = 10; name="unc mob panel M";},   
        --{ id =2096240860 ; count = 10; name="unc mob panel L";},   

        { id =1977512378 ; count = 20; name="bas robo arm M";},   
        { id =1977512379 ; count = 20; name="bas robo arm L";},   
        { id =1977298056 ; count = 20; name="unc robo arm M";},   

    };

    SanctTanks=
    {
        { id =713802609 ; count = 10; name="bas chem cont XS";},   
        { id =1815471308 ; count = 10; name="bas chem cont S";},   
        { id =1815471302 ; count = 10; name="bas chem cont M";},   
        { id =1815471301 ; count = 10; name="bas chem cont L";},   

        -- { id =1815450741     ; count = 10; name="unc chem cont M";},   

        -- { id =981789849 ; count = 20; name="bas gas cyl XS";},   
        -- { id =1194767553 ; count = 20; name="bas gas cyl S";},   
        -- { id =1194767567 ; count = 10; name="bas gas cyl M";},   

        -- { id =648202053 ; count = 20; name="bas ionic cham XS";},   
        -- { id =763768710 ; count = 20; name="bas ionic cham S";},   
        -- { id =763768764 ; count = 20; name="bas ionic cham M";},   
        -- { id =763768767 ; count = 10; name="bas ionic cham L";},   

        -- { id =763789004 ; count = 5; name="unc ionic cham L";},   
        -- { id =763760349 ; count = 1; name="adv ionic cham L";},
    };

    SanctEngines=
    {
          { id = 1873130580; count = 10; name="basic electric engine S";}, 
          { id = 1873130574; count = 10; name="basic electric engine M";}, 
    };

-- **********************************************************
--
-- **********************************************************

    ProdL=
    {
    };


    ProdM=
    {
    };

    ProdS=
    {
    };

    ProdXS=
    {
    };

    PlaneL=
    {
        { id = 538110466 ; count = 0; name="Mil Space Eng L";}, 
        { id = 1035733967 ; count = 0; name="Adv Man Atmo Eng L";},
        { id = 892172000  ; count = 0; name="Adv Man Space Eng L";}, 

        { id =1041265279 ; count = 4; name="Canopy corner L";}, 
        { id =1011557660 ; count = 4; name="Canopy tilted L";}, 
        { id =830288667  ; count = 4; name="Canopy flat L";}, 
        { id =479960376  ; count = 4; name="Canopy triangle L";}, 
        
        { id =1846671476  ; count = 0; name="Adv Mining Unit";}, 

        -- atmo fuel tank L
        -- space fuel tank L
        -- stabilizer L
        -- warp drive
        -- advanced military atmo engine
    };

    PlaneM1=
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

        { id = 1475837143  ; count = 0; name="Adv Man Space Eng M";}, 
    };

    PlaneM2=
    {
        { id =2007822249  ; count = 10; name="Canopy flat M";}, 
        { id =354023964  ; count = 10; name="Canopy triangle M";}, 
        { id =426566210  ; count = 10; name="Canopy tilted M";}, 
        { id =1156504881  ; count = 10; name="Canopy corner M";}, 

        { id = 1123820852 ; count = 30; name="Wing M";},
        { id = 1756752144 ; count = 10; name="Wing M Vari";},
        { id = 519895957 ; count = 10; name="Vert Booster L";},

    };

    PlaneS=
    {
        { id = 707706079 ; count = 10; name="Hatch S";}, 
        { id = 1405119260 ; count = 10; name="Sliding Door S";}, 
        { id = 615006973 ; count = 10; name="Command Seat";}, 
        { id = 65660295  ; count = 10; name="Canopy flat S";}, 
        { id = 2001045118 ; count = 10; name="Canopy triangle S";}, 
        { id = 203547655 ; count = 10; name="Canopy tilted S";}, 
        { id = 1825028805 ; count = 10; name="Canopy corner S";}, 

        { id = 1574474550  ; count = 0; name="Adv Man Space Eng S";},

        -- adjustor S
        -- space fuel tank S
        -- atmo tank S
        -- hover engine M
        -- navigator chair S
        -- office chair s
        -- retro rocket M
        -- atmo brake M
        -- stabilizer s
    };

    PlaneXS=
    {
        { id = 1972188620 ; count = 10; name="Adjustor S";}, 
        { id = 359449714 ; count = 10; name="Encampment Chair";}, 
        { id = 1834144963 ; count = 10; name="Fuel Intake XS";}, 
        { id = 367260236 ; count = 8; name="Adv Man Atmo Eng XS";}, 
        -- gyro
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

     ShieldMix1=
     {
        { id = 1234754162 ; count = 200; name="Basic Led";}, 
        { id = 1234754161 ; count = 200; name="Uncommon Led";}, 
        { id = 1234754160 ; count = 200; name="Advanced Led";}, 
        { id = 1246524876 ; count = 50; name="Adv Magnet";},

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
        switch.obj.deactivate();
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

    local player_distance= self.unit.getMasterPlayerPosition();
    local r  = 50;
    local dx = ABS(player_distance[1]);
    local dy = ABS(player_distance[2]);
    local dz = ABS(player_distance[3]);
    if dx < r and dy<r and dz<r then
        if switch then switch.obj.activate(); end
        if counter then
            counter.obj.next();
        end
        if not detector then
            self:RunService();
        end
    else
        if switch then switch.obj.deactivate(); end
    end
end

function industry_lib:OnStop()
    local u = self.unit_classes;
    local switch  =u.ManualSwitchUnit[1];
    if switch then
        switch.obj.deactivate();
    end
end

function industry_lib:RunService()

    local t=self.system.getTime();
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
        local status      = self.machine_stati[m.getStatus()];
        local id          = m.getCurrentSchematic();
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
                        m.startAndMaintain(recipe.count);    
                        recipe_times[id_string]=t;
                        --self.system.print(format("Starting recipe %s : %d" , recipe.name,recipe.count));
                    else
                        for r=1,#recipe_list do
                            recipe=recipe_list[r];
                            id_string=tostring(recipe.id);
                            recipe_time=recipe_times[id_string];
                            if (recipe_time==nil) or  (recipe_time < container.t) then
                                m.setCurrentSchematic(recipe.id);
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
                       m.hardStop();
                   end
                end
            elseif(status~=self.STATUS_RUNNING) then
                m.hardStop();
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