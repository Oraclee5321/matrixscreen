require("component")
function getMatrix ()
    local maddress = ""
    for address,name in component.list("induction_matrix",true) do
        maddress = address
    end
    return maddress
end

function getCurrentPower (matrix)
    local storedpower = component.invoke(matrix,"getEnergy") -- Gets energy stored in EU
    storedpower = storedpower * 4 -- Convert to RF
    return storedpowwer
end

function getMaxPower (matrix)
    local maxpower = component.invoke(matrix,"getMaxPower")
    maxpower = maxpower * 4
    return maxpower
end
local charts = require("charts")
local matrix = getMatrix()
local gpu = component.gpu
local w,h = gpu.getResolution()
local powerbar = charts.container {
    x = 1,
    y = 1,
    width = 50,
    height = 2,
    payload = charts.ProgressBar{
        direction = charts.sides.LEFT,
        max = getMaxPower(matrix),
        value=0,
        colorFunc = function(_, perc)
            if perc >= .9 then
                return 0x20afff
            elseif perc >= .75 then
                return 0x20ff20
            elseif perc >= .5 then
                return 0xafff20
            elseif perc >= .25 then
                return 0xffff20
            elseif perc >= .1 then
                return 0xffaf20
            else
                return 0xff2020
            end
        end
    }
}