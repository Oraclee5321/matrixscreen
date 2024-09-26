local components = require("component")
function getMatrix ()
    local maddress = ""
    for address,name in components.list("induction_matrix",true) do
        maddress = address
    end
    return maddress
end

function getCurrentPower (matrix)
    local storedpower = components.invoke(matrix,"getEnergy") -- Gets energy stored in EU
    storedpower = storedpower * 4 -- Convert to RF
    return storedpower
end

function getMaxPower (matrix)
    local maxpower = components.invoke(matrix,"getMaxEnergy")
    maxpower = maxpower * 4
    return maxpower
end

function drawData(matrix,term,pbar)
    local energy = getCurrentPower(matrix)
    term.clear()
    pbar.gpu.set(5, 10, "Current Power: " .. ("%.2f"):format(energy))
    pbar.gpu.set(5, 11, "          Max: " .. pbar.payload.max)

    pbar.payload.value = energy

    pbar:draw()
end

local charts = require("charts")
local term = require("term")
local event = require("event")
local matrix = getMatrix()
local gpu = components.gpu
local w,h = gpu.getResolution()


local pbar = charts.Container {
    x = 1,
    y = 1,
    width = 50,
    height = 2,
    payload = charts.ProgressBar{
        direction = charts.sides.RIGHT,
        max = getMaxPower(matrix),
        value=getCurrentPower(matrix),
        colorFunc = function(_, perc)
            if perc >= .9 then
                return 0x20afff
            elseif perc >= .75 then
                return 0x20ff2
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


repeat
    drawData(matrix,term,pbar)
until
    event.pull(0.05, "interrupted")


event.pull("interrupted")
term.clear()


