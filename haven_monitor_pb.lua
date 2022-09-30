local json = require('dkjson');
local format = string.format;
local print  = system.print;


if display~=nil then

	local display_data=
	{
		columns=2;
		rows   =4;

		bars=
		{
			{ col=1,row=1,perc=0,name="OreIn" },
			{ col=1,row=2,perc=0,name="T1Mix" },
			{ col=2,row=1,perc=0,name="Al_Fe" },
			{ col=2,row=2,perc=0,name="Silumin" },
			{ col=2,row=3,perc=0,name="Steel" },
			{ col=2,row=4,perc=0,name="Polycarbonate" },
			{ col=1,row=4,perc=0,name="Glas" },
			{ col=1,row=3,perc=0,name="Nitron" },
		};
	};

	display.setScriptInput(json.encode(display_data));
else
	print("No display found");
end