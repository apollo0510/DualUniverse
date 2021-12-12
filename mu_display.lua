local unit_classes =
{
    CoreUnit         = { need = 1; meta = nil; },
    ScreenUnit       = { need = 1; meta = nil; },
};
local unit_lib_req = require("unit_lib");
local unit_lib     = unit_lib_req.new(system,unit,unit_classes);

