# csvtolua
Convert csv to lua script for game res  

### example
building.xls  
<table>
    <tr>
        <td>name</td>
        <td>use_money</td>
        <td>use_food</td>
        <td>is_init</td>
        <td>defense</td>
    </tr>
    <tr>
        <td>string</td>
        <td>number</td>
        <td>number</td>
        <td>bool</td>
        <td>number</td>
    </tr>
    <tr>
        <td>名字</td>
        <td>使用金币数</td>
        <td>使用食物数</td>
        <td>是否初始化</td>
        <td>防御力</td>
    </tr>
    <tr>
        <td>house</td>
        <td>1000</td>
        <td>123</td>
        <td>TRUE</td>
        <td>100</td>
    </tr>
    <tr>
        <td></td>
        <td>123</td>
        <td></td>
        <td></td>
        <td>120</td>
    </tr>
    <tr>
        <td></td>
        <td>456</td>
        <td></td>
        <td></td>
        <td>130</td>
    </tr>
    <tr>
        <td>farm</td>
        <td>100</td>
        <td>234</td>
        <td>FALSE</td>
        <td>200</td>
    </tr> 
    <tr>
        <td></td>
        <td>200</td>
        <td></td>
        <td></td>
        <td></td>
    </tr>
    <tr>
        <td></td>
        <td>200</td>
        <td></td>
        <td></td>
        <td></td>
    </tr>          
</table>
lua csvtolua.lua building.csv

### NOTICE:
> The **first row** must be **title**.  
> The **second row** must be **type**(**number**, **string**, **bool**) 
> The **third row** must be interpretation.    
> The **first column** must be **Name**.  

### LUA SCRIPT
```lua
local building = {}

building.house = {
    use_money = 1000,
    use_food = 123,
    is_init = true,
}

building.house[1] = {
    use_money = 1000,
    use_food = 123,
    is_init = true,
}

building.house[2] = {
    use_money = 123,
}

building.house[3] = {
    use_money = 456,
}

building.farm = {
    use_money = 100,
    use_food = 234,
    is_init = false,
}

building.farm[1] = {
    use_money = 100,
    use_food = 234,
    is_init = false,
}

building.farm[2] = {
    use_money = 200,
}

building.farm[3] = {
    use_money = 200,
}

building.all_type = {}
local all_type = building.all_type
all_type[1] = house
all_type[2] = farm



for i=1, #(building.all_type) do
    local item = building.all_type[i]
    for j=1, #item do
        item[j].__index = item[j]
        if j < #item then
            setmetatable(item[j+1], item[j])
        end
    end
end


return building

```

### HOW TO USE LUA SCRIPT
```lua
local building = require("building")

print(building.farm[1].use_money)
print(building.farm.use_money)
```
The console will print    
**100**   
**100**   
