local json = require('dkjson');
local format = string.format;
local print  = system.print;

local display_data=
{
	columns=2;
	rows   =4;

	bars=
	{
		{ col=1,row=1,perc=0,vol=0,name="OreIn" },
		{ col=1,row=2,perc=0,vol=0,name="T1Mix" },
		{ col=2,row=1,perc=0,vol=0,name="Al_Fe" },
		{ col=2,row=2,perc=0,vol=0,name="Silumin" },
		{ col=2,row=3,perc=0,vol=0,name="Steel" },
		{ col=2,row=4,perc=0,vol=0,name="Polycarbonate" },
		{ col=1,row=4,perc=0,vol=0,name="Glas" },
		{ col=1,row=3,perc=0,vol=0,name="Nitron" },
	};
};


local container_data=
{
	{ cont=cont1; bar=display_data.bars[1]; volume=-1; },
	{ cont=cont2; bar=display_data.bars[2]; volume=-1; },
	{ cont=cont3; bar=display_data.bars[3]; volume=-1; },
	{ cont=cont4; bar=display_data.bars[4]; volume=-1; },
	{ cont=cont5; bar=display_data.bars[5]; volume=-1; },
	{ cont=cont6; bar=display_data.bars[6]; volume=-1; },
	{ cont=cont7; bar=display_data.bars[7]; volume=-1; },
	{ cont=cont8; bar=display_data.bars[8]; volume=-1; },

};


function UpdateContainers()
	local changed_false;
	for i,c in ipairs(container_data) do
		if c.cont then
			local volume = c.cont.getItemsVolume();
			if volume~=nil and volume~=c.volume then
				c.volume=volume;
				if c.max_volume == nil then
					c.max_volume=c.cont.getMaxVolume();
				end
				local percent = c.volume * 100.0 / c.max_volume;
				local bar     = c.bar;
				if percent~=bar.perc then
					bar.perc=percent;
					bar.vol =volume;
					changed=true;
				end
			end
		end
	end
	if changed then
		display.setScriptInput(json.encode(display_data));
	end
end

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
	UpdateContainers();
	unit.setTimer("ContChecker",1.0);
else
	print("No display found");
end
