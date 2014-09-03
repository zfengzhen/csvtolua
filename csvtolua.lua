----------------------------------------
---- @file csvtolua.lua
---- @brief convert csv file to lua file
---- @author fergus <zfengzhen@gmail.com>
---- @version 
---- @date 2014-09-03
------------------------------------------

-- 去掉字符串左右空白
local function trim(s)
    s = string.gsub(s, "^%s+", "")
    return string.gsub(s, "%s+$", "")
end

-- 判断是否含有空格
local function isHaveBlank(s)
    local ret = string.find(s, "%s")
    if ret == nil then
        return false
    else
        return true
    end
end

-- 解析一行
local function split(str, reps)
    local resultStrsList = {}
    string.gsub(str, "([^" .. reps .."]*)" .. reps,
        function(w)
            local s = trim(w)
            table.insert(resultStrsList, s)
        end
    )
    return resultStrsList
end

-- 解析csv一行数据
local function splitCsvOneRow(str)
    local t = split(str, ",")
    local isNoData = true
    for i, v in ipairs(t) do
        if (v ~= "") then
            isNoData = false
            break
        end
    end

    if (isNoData == true) then
        return nil
    else
        return t
    end
end

-- 解析文件放入table中
local function parseCsvToTable(file)
    local rfile = io.open(file .. ".csv", "r")
    assert(rfile)
    local csv = {}
    for str in rfile:lines() do
        local t = splitCsvOneRow(str, ",")
        if (t ~= nil) then
            table.insert(csv, t)
        end
    end
    if (next(csv) == nil) then
        csv = nil
    end
    return csv
end

-- 检查csv结构
local function checkCsv(csv)
    if (#csv < 4) then
        return false, "Csv文件行小于4行"
    elseif (#csv[1] < 1) then
        return false, "Csv文件列小于1列"
    elseif (string.lower(csv[1][1]) ~= "name") then
        return false, "Csv第一个字段必须为Name"
    end

    -- 检查字段
    for i, v in ipairs(csv[1]) do
        if (isHaveBlank(v) == true) then
            local errorStr = "row[" .. 1 .. "] colum[" .. i .. "] Key have blanks"
            return false, errorStr
        end
    end

    -- 检查类型
    if (string.lower(csv[2][1]) ~= "string") then
        return false, "Name typeKey must be [string]"
    end

    for i, v in ipairs(csv[2]) do
        local typeKey = string.lower(v)
        if (typeKey ~= "string" and typeKey ~= "bool" and typeKey ~= "number") then
            local errorStr = "row[" .. 2 .. "] colum[" .. i .. "] typeKey must be [number] or [bool] or [string]"
            return false, errorStr
        end
    end

    for i, v in ipairs(csv[4]) do
        if (v == "") then
            return false, "数据第一行必须都有值 row[4] colum[" .. i .. "] is empty."
        end
    end

    -- 检查具体数据
    for rowIdx, row in ipairs(csv) do
        if (rowIdx >= 4) then
            for columIdx, colum in ipairs(csv[rowIdx]) do
                if (csv[rowIdx][columIdx] ~= "" and csv[2][columIdx] == "number") then
                    if (tonumber(csv[rowIdx][columIdx]) == nil) then
                        local errorStr = "row[" .. rowIdx .. "] colum[" .. columIdx .. "] is not a [number]"
                        return false, errorStr
                    end
                elseif (csv[rowIdx][columIdx] ~= "" and csv[2][columIdx] == "string") then
                    -- string不需要判断
                elseif (csv[rowIdx][columIdx] ~= "" and csv[2][columIdx] == "bool") then
                    local boolValue = string.lower(trim(csv[rowIdx][columIdx]))
                    if (boolValue ~= "true" and boolValue ~= "false") then
                        local errorStr = "row[" .. rowIdx .. "] colum[" .. columIdx .. "] [" .. boolValue .."] is not a [bool]"
                        return false, errorStr
                    end
                end
            end
        end
    end

    return true
end


-- 解析csv文件
local function parseCsv(file, outPath)
    local csv = parseCsvToTable(file)
    local ret, errorStr = checkCsv(csv)
    if (ret == false) then
        print(errorStr)
        return
    end

    local wfile = io.open(outPath .. "/" .. file .. ".lua", "w")
    assert(wfile)
    wfile:write("local " .. file .. " = {}\n\n")
    local name = csv[4][1]
    local isChangeName = false
    local level = 1
    for rowIdx, row in ipairs(csv) do
        if (rowIdx >= 4) then
            if (csv[rowIdx][1] ~= "") then
                name = csv[rowIdx][1]
                isChangeName = true
                level = 1
            end
            
            if (isChangeName == true) then
                wfile:write(file .. "." .. name .. " = {\n")
                for columIdx, colum in ipairs(csv[rowIdx]) do
                    if (columIdx >= 2) then
                        local typeKey = string.lower(csv[2][columIdx])
                        if (csv[rowIdx][columIdx] ~= "") then
                            if (typeKey == "number") then
                                wfile:write("    " .. csv[1][columIdx] .. " = " .. csv[rowIdx][columIdx] .. ",\n")
                            elseif (typeKey == "string") then
                                wfile:write("    " .. csv[1][columIdx] .. " = \"" .. csv[rowIdx][columIdx] .. "\",\n")
                            elseif (typeKey == "bool") then
                                wfile:write("    " .. csv[1][columIdx] .. " = " .. string.lower(csv[rowIdx][columIdx]) .. ",\n")
                            end
                        end
                    end
                end
                wfile:write("}\n\n")
                isChangeName = false
            end

            wfile:write(file .. "." .. name .. "[" .. level .. "] = {\n")
            for columIdx, colum in ipairs(csv[rowIdx]) do
                if (columIdx >= 2) then
                    local typeKey = string.lower(csv[2][columIdx])
                    if (csv[rowIdx][columIdx] ~= "") then
                        if (typeKey == "number") then
                            wfile:write("    " .. csv[1][columIdx] .. " = " .. csv[rowIdx][columIdx] .. ",\n")
                        elseif (typeKey == "string") then
                            wfile:write("    " .. csv[1][columIdx] .. " = \"" .. csv[rowIdx][columIdx] .. "\",\n")
                        elseif (typeKey == "bool") then
                            wfile:write("    " .. csv[1][columIdx] .. " = " .. string.lower(csv[rowIdx][columIdx]) .. ",\n")
                        end
                    end
                end
            end
            wfile:write("}\n\n")
            
            level = level + 1 
        end -- rowIdx >= 4
    end

    wfile:write(file .. ".all_type = {}\n")
    wfile:write("local all_type = " .. file .. ".all_type\n")
    local idx = 1

    -- 增加全局类型
    for rowIdx, row in ipairs(csv) do
        if (rowIdx >= 4) then
            if (row[1] ~= "") then
                wfile:write("all_type[" .. idx .. "] = " .. row[1] .. "\n")
                idx = idx + 1
            end
        end
    end
    wfile:write("\n")

    -- 增加metatable
   wfile:write("\n\
for i=1, #(" .. file .. ".all_type) do\
    local item = " .. file .. ".all_type[i]\
    for j=1, #item do\
        item[j].__index = item[j]\
        if j < #item then\
            setmetatable(item[j+1], item[j])\
        end\
    end\
end\
\
\
") 

    wfile:write("return " .. file)
    wfile:close()
end


-- 判断是否有输入文件
if (#arg == 0) then
    error("no input file!!!")
end

local fileTable = {}
local outPath = "."

for key, args in ipairs(arg) do
    local start_, end_, file = string.find(args, "([%w_]+)%.csv$")
    if (file) then
        table.insert(fileTable, file)
    end

    local start_, end_, findOutPath = string.find(args, "%-%-out_path=(.+)")
    print(args)
    if (findOutPath) then
        outPath = findOutPath
    end
end

print("outPath[" .. outPath .. "]")
for i, v in ipairs(fileTable) do
    print("parse csv[" .. v .. "] start...")
    parseCsv(v, outPath)
    print("parse csv[" .. v .. "] end...")
end

