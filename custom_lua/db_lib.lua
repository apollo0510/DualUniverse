local DBLib=
{
    system   = nil;
    unit     = nil;
    databank = nil;
    data     = { };
};

function DBLib:Start(system,unit,data_bank)
    self.system  =system;
    self.unit    =unit;
    self.data_bank=data_bank;
    self:Load();
end

function DBLib:Stop()
    self:Save();
end

function DBLib:Load()
    local data_bank=self.data_bank;
    if data_bank then
        local loaded_key_count = 0;
        local data = {}
        local key_list=data_bank.getKeyList();
        for index,key in ipairs(key_list) do
            local key_value_text=data_bank.getStringValue(key);
            data[key]=json.decode(key_value_text);
            loaded_key_count = loaded_key_count + 1;
        end
        self.data=data;
        self.system.print("Loaded "..loaded_key_count.." from data bank");
    else
        self.system.print("no data bank for loading data");
    end
end

function DBLib:Save()
    local data_bank=self.data_bank;
    if data_bank then
        local saved_key_count = 0;
        for key,value in pairs(self.data) do
            if value.update or data_bank.hasKey(key)~=1 then    
                local key_value_text=json.encode(value);
                data_bank.setStringValue(key,key_value_text);   
                saved_key_count = saved_key_count + 1;
            end
        end
        self.system.print("Saved "..saved_key_count.." to data bank");
    else
        self.system.print("no data bank for saving data");
    end
end

function DBLib:GetKey(key,default_data,version)
    local key_data=self.data[key];
    if not key_data or key_data.version~=version then
        key_data = default_data;
        key_data.update  = true;
        key_data.version = version;
        self.data[key]= key_data;
        self.system.print("created key "..key.." in data bank");
    end
    return key_data;
end

return DBLib;