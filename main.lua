local components = require("component")
function getMatrix ()
    local maddress = ""
    for address,name in components.list("induction_matrix",true) do
        maddress = address
    end
    return maddress
end

function getInput(matrix)
    local input = components.invoke(matrix,"getInput")
    input = input * 4
    return input
end

function getOutput(matrix)
    local output = components.invoke(matrix,"getOutput")
    output = output * 4
    return output
end

function getDeviation(matrix)
    local input = getInput(matrix)
    local output = getOutput(matrix)
    local deviation = input - output
    return deviation
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

function drawData(energy,pbar)
    pbar.gpu.set(5, 9, "   Percentage: " .. string.format("%.0f",(energy / pbar.payload.max)*100) .. "%")
    pbar.gpu.set(5, 10, "Current Power: " .. energy .. " RF")
    pbar.gpu.set(5, 11, "          Max: " .. pbar.payload.max .. " RF")


    pbar.payload.value = energy
end

function energyDeviation(matrix,pbar)
    local deviation = getDeviation(matrix)
    if deviation < 0 then
        pbar.gpu.set(5, 12, "  Energy Loss: " .. deviation .. " RF")
    else
        pbar.gpu.set(5, 12, "  Energy Gain: +" .. deviation .. " RF")
    end
end

function timeEstimate(matrix,pbar,energy)
    local deviation = getDeviation(matrix)
    local a = 0
    if deviation == nil or deviation == 0 then
        return
    end

    if deviation < 0 then
        a = (((pbar.payload.max + energy)/ deviation) /20) / 60
    else
        a = (((pbar.payload.max - energy)/ deviation) /20) / 60
    end
    if deviation < 0 then
        pbar.gpu.set(5, 13, "    Time Left: " .. string.format("%.1f",a * -1) .. " Min")
    else
        pbar.gpu.set(5, 13, "  Time To Fill: " .. string.format("%.1f",a) .. " Min")
    end
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
    term.clear()
    local energy = getCurrentPower(matrix)
    drawData(energy,pbar)
    energyDeviation(matrix,pbar)
    timeEstimate(matrix,pbar,energy)
    pbar:draw()
until
    event.pull(0.05, "interrupted")


event.pull("interrupted")
term.clear()


