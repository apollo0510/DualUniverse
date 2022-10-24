local json = require('dkjson');
local format = string.format;
local layer        = createLayer();
local xres,yres    = getResolution();
local font         = loadFont("Play",40);
local font_small   = loadFont("Play",20);
local column_width = 0;
local row_height   = 0;
local input_string = getInput();
local padding      = 4;
local text_pad     = 5;

-- *****************************************************************
local data_index_col        =1;
local data_index_row        =2;
local data_index_perc       =3;
local data_index_vol        =4;
local data_index_name       =5;
local data_index_blueprints =6;
-- *****************************************************************


function GetCell(col,row,padding)
	return { x0=(col-1)*column_width + padding,
		    x1=(col-0)*column_width - padding,
		    y0=(row-1)*row_height + padding,
		    y1=(row-0)*row_height - padding,
		    w=column_width - 2*padding,
		    h=row_height - 2*padding };
end

if(type(input_string)=="string") then
	local input        = json.decode(input_string);
	if(type(input)=="table") then
		if( (input.columns~=nil) and (input.rows~=nil) ) then

			if input.columns>0 and input.rows>0 then

				column_width = xres/input.columns;
				row_height   = yres/input.rows;

				setDefaultFillColor  (layer,Shape_Box,0,0,0,0);
				setDefaultStrokeColor(layer,Shape_Box,1,1,1,1);
				setDefaultStrokeWidth(layer,Shape_Box,2);
		
				local cell;
				for col=1,input.columns do
					for row=1,input.rows do
						cell = GetCell(col,row,padding);
						addBox(layer,cell.x0,cell.y0,cell.w,cell.h);
					end
				end

				setDefaultFillColor  (layer,Shape_Box,0,0,0.3,1);
				setDefaultStrokeColor(layer,Shape_Box,0,0,0,0);
				setDefaultStrokeWidth(layer,Shape_Box,0);
				setDefaultTextAlign(layer, AlignH_Center, AlignV_Middle);

				if input.bars then
					for i,bar in ipairs(input.bars) do
						cell = GetCell(bar[data_index_col],bar[data_index_row],padding+2);
						local w=cell.w*bar[data_index_perc]/100;
						addBox(layer,cell.x0,cell.y0,w,cell.h);
						local x=cell.x0+cell.w/2;
						local y=cell.y0+cell.h/2;
					
						setNextTextAlign(layer, AlignH_Center, AlignV_Middle);
						addText(layer,font,bar[data_index_name],x,y);
					
						local text=format("%.2f%%",bar[data_index_perc]);
						setNextTextAlign(layer, AlignH_Left, AlignV_Top);
						addText(layer,font_small,text,cell.x0+text_pad,cell.y0+text_pad);

						local text=format("%.3fkL",bar[data_index_vol]/1000.0);
						setNextTextAlign(layer, AlignH_Left, AlignV_Bottom);
						addText(layer,font_small,text,cell.x0+text_pad,cell.y1-text_pad);

						local blueprints=bar[data_index_blueprints];
						if blueprints~=nil then
							local text=format("%d",blueprints);
							setNextTextAlign(layer, AlignH_Right, AlignV_Bottom);
							addText(layer,font_small,text,cell.x1-text_pad,cell.y1-text_pad);
						end

					end
				else
					logMessage("Bars definitions missing");
				end
			else
				addText(layer,font,"Offline",xres/2,yres/2);
			end
		else
			logMessage("Cols and Rows missing");
		end
	else
		logMessage("Can not decode Input String");
	end
else
	logMessage("No Input String");
end


