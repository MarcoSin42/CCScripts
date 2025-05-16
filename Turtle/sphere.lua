local pi = math.pi
local cos = math.cos
local round = function(n)
    return math.floor(n + 0.5)
end
local sin = math.sin
local vec = vector.new
local controller = require("controller")


local r = 5
-- origin
local cx = 0
local cy = 0
local cz = 0

-- Theta refers to the lattitude angle [0,pi]
-- Gamma refers to the horizontal angle [0,2pi]
local settings = {

    setRadius = function(new_r)
        r = new_r
    end,
    setOrigin = function(x,y,z)
        cx = x
        cy = y
        cz = z
    end,
    getRadius = function()
        return r
    end,
}

local function getX(theta, gamma)
    return round(r * sin(theta) * cos(gamma) + cx)
end

local function getY(theta, gamma)
    return round(r * cos(theta) + cy)
end
local function getZ(theta, gamma)
    return round(r * sin(theta) * sin(gamma) + cz)
end

local function generatePoint(theta, gamma)
    return vec(getX(theta, gamma), getY(theta, gamma), getZ(theta, gamma))
end

local function generateSpherePath()
    local result = {}
    local scale = 10
    local dt = 1.0 / (scale*r)
    for theta=pi,0,-dt*scale do
        for gamma=0,2*pi,dt do
            local newPoint = generatePoint(theta, gamma)
            if newPoint ~= result[#result] then
                table.insert(result, newPoint)
            end
        end
    end

    return result
end
-- sphere = require("sphere")
-- sphere.settings.setOrigin(-691,73,-7692)
-- sphere.se
local function generateSemiSpherePath()
    local result = {}
    local scale = 10
    local dt = 1.0 / (r*scale)
    for theta=pi/2,0,-dt*scale do
        for gamma=0,2*pi,dt do
            local newPoint = generatePoint(theta, gamma)
            if newPoint ~= result[#result] then
                table.insert(result, newPoint)
            end
        end
    end

    return result
end

local function makeSemiSphere()
    path = generateSemiSpherePath()
    for _,point in pairs(path) do
        print("Placing at: ",point)
        controller.placeDown(point, controller.chests.a)
    end
end


local function makeSphere()
    path = generateSpherePath()
    for _,point in pairs(path) do
        controller.placeDown(point, controller.chests.a)
    end
end


local function makeCircle()
end

return {
    generatePath = generatePath,
    makeSemi = makeSemiSphere,
    makeSphere = makeSphere,
    settings = settings,
}
