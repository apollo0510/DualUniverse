local json = require('dkjson');
local format = string.format;
local print  = system.print;
local insert = table.insert;

-- *****************************************************************
local data_index_col       =1;
local data_index_row        =2;
local data_index_perc       =3;
local data_index_vol        =4;
local data_index_name       =5;
local data_index_status     =6;
-- *****************************************************************


local display_data=
{
	columns=2;
	rows   =4;

	-- left display
	bars=
	{
		{ 1,1,0,0,"Aluminium",nil},
		{ 1,2,0,0,"Carbon"   ,nil},
		{ 1,3,0,0,"Iron"     ,nil},
		{ 1,4,0,0,"Silicon"  ,nil},
		{ 2,1,0,0,"Calcium"  ,nil},
		{ 2,2,0,0,"Chromium" ,nil},
		{ 2,3,0,0,"Copper"   ,nil},
		{ 2,4,0,0,"Sodium"   ,nil}
	};

	-- right display
	--[[
	bars=
	{
		{ 1,1,0,0,"Al-Fe"        ,nil},
		{ 1,2,0,0,"Steel"        ,nil},
		{ 1,3,0,0,"Silumin"      ,nil},
		{ 1,4,0,0,"Polycarbonate",nil},
		{ 2,1,0,0,"Calc.Reinf."  ,nil},
		{ 2,2,0,0,"Stainless"    ,nil},
		{ 2,3,0,0,"Duralumin"    ,nil},
		{ 2,4,0,0,"PolyCalcide"  ,nil}
	};
	]]--

};


local container_data=
{
	{ cont=cont1; bar=display_data.bars[1]; volume=-1; status_bits=0; },
	{ cont=cont2; bar=display_data.bars[2]; volume=-1; status_bits=0; },
	{ cont=cont3; bar=display_data.bars[3]; volume=-1; status_bits=0; },
	{ cont=cont4; bar=display_data.bars[4]; volume=-1; status_bits=0; },
	{ cont=cont5; bar=display_data.bars[5]; volume=-1; status_bits=0; },
	{ cont=cont6; bar=display_data.bars[6]; volume=-1; status_bits=0; },
	{ cont=cont7; bar=display_data.bars[7]; volume=-1; status_bits=0; },
	{ cont=cont8; bar=display_data.bars[8]; volume=-1; status_bits=0; }
};

function UpdateContainers()
	local changed_false;
	for i,c in ipairs(container_data) do
		if c.cont then
			local volume = c.cont.getItemsVolume();
		    local status_table = nil;
			local status_bits  = 0;
			if c.ids then
				local factor=1;
				for j,local_id in ipairs(c.ids) do
				   local info=core.getElementIndustryInfoById(local_id);
				   if info then
						status_bits=status_bits + info.state * factor;
						factor = factor * 10;
				   end
				end
			end
			if status_bits~=c.status_bits then
				c.status_bits=status_bits;
				local bar     = c.bar;
				if bar then
				   bar[data_index_status]=status_bits;
				   changed=true;
				end
			end
			if volume~=nil and volume~=c.volume then
				c.volume=volume;
				if c.max_volume == nil then
					c.max_volume=c.cont.getMaxVolume();
				end
				local percent = c.volume * 100.0 / c.max_volume;
				local bar     = c.bar;
				if percent~=bar[data_index_perc] then
					bar[data_index_perc]=percent;
					bar[data_index_vol ] =volume;
					changed=true;
				end
			end
		end
	end
	if changed then
		display.setScriptInput(json.encode(display_data));
	end
end

-- ****************************************************************

function StartUp()

	local IndustryTypes=
	{
		IndustryUnit=true,
		Industry1   =true,
		Industry2   =true,
		Industry3   =true,
		Industry4   =true,
		Industry5   =true
	};

	local IndustryNames={ };
	for i,c in ipairs(container_data) do
		if c.cont then
			local bar = c.bar;
			local name="Ind_"..bar[data_index_name];
			IndustryNames[name]=c;
		end
	end

	local id_list=core.getElementIdList();
	for i,local_id in ipairs(id_list) do
		local class_name=core.getElementClassById(local_id);
		if IndustryTypes[class_name] then
			local element_name=core.getElementNameById(local_id);
			local c=IndustryNames[element_name];
			if c then
			    if c.ids == nil then c.ids={}; end 
			    insert(c.ids,local_id);
			end
		end
	end
end

-- ****************************************************************

local shutown_display_data=
{
	columns=0;
	rows   =0;
};

local shutdown_string = json.encode(shutown_display_data);

function Shutdown()
	if display~=nil then
		display.setScriptInput(shutdown_string);
	end
end

if display~=nil then
	StartUp();
	UpdateContainers();
	unit.setTimer("ContChecker",1.0);
else
	print("No display found");
end
	