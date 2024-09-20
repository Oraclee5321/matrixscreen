local components = require("component")
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
    return storedpower
end

function getMaxPower (matrix)
    local maxpower = component.invoke(matrix,"getMaxEnergy")
    maxpower = maxpower * 4
    return maxpower
end
local charts = require("charts")
local term = require("term")
local event = require("event")
local matrix = getMatrix()
local gpu = component.gpu
local w,h = gpu.getResolution()


local pbarleft = charts.Container {
    x = 1,
    y = 1,
    width = 50,
    height = 2,
    payload = charts.ProgressBar{
        direction = charts.sides.LEFT,
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

local pbarright = charts.Container {
    x = 1,
    y = 4,
    width = 50,
    height = 2,
    payload = charts.ProgressBar {
      direction = charts.sides.RIGHT,
      value = 0,
      colorFunc = cleft.payload.colorFunc
    }
  }
  local energy = getCurrentPower(matrix)
  term.clear()
  pbarleft.gpu.set(5, 10, "Value: " .. ("%.2f"):format(energy / 100) .. " [" .. ("%3d"):format(energy) .. "%]")
  pbarleft.gpu.set(5, 11, "Max:   " .. pbarleft.payload.min)
  pbarleft.gpu.set(5, 12, "Min:   " .. pbarleft.payload.max)

  cleft.payload.value, cright.payload.value = energy / 100, energy / 100

  pbarleft:draw()
  pbaright:draw()

  if event.pull(0.05, "interrupted") then
      term.clear()
      os.exit()
  end

  event.pull("interrupted")
  term.clear()


