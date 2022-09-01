----
-------
--  Cloud Simulator by Adam
-------
----


-- Config
local monitor = "monitor_18"
local grayScale = "  .:-=+*#%@"
local amplitude = 1
local frequency = 10
local lacunarity = 2
local gain = 1
local octaves = 4
local seed = 45


-- function defs
function grayCharacter(grayLevel)
    grayLevel = math.min(string.len(grayScale), math.max(0,grayLevel))
    return string.sub(grayScale, grayLevel, grayLevel+1)
end


-- Fractal noise in lua by Thomas M. port of https://www.shadertoy.com/view/Msf3WH
-- The MIT License
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function fract(x)
    return x-math.floor(x)
end

-- Not the best hash, but it doesn't require bitshifts...
-- https://www.shadertoy.com/view/Msf3WH
function hash(x, y)
    x = x * 127.1 + y * 311.7
    y = x * 269.5 + y * 183.3
    return {
        x = -1 + 2 * (fract(math.sin(x)*43758.5453123)),
        y = -1 + 2 * (fract(math.sin(y)*43758.5453123)),
    }
end

-- Original algorithm by Inigo Quilez
-- https://www.shadertoy.com/view/Msf3WH
K1 = 0.366025404; -- (sqrt(3)-1)/2
K2 = 0.211324865; -- (3-sqrt(3))/6
function simplexNoise(x, y)
    ix = math.floor(x + (x+y)*K1)
    iy = math.floor(y + (x+y)*K1)
    ax = x - ix + (ix+iy)*K2
    ay = y - iy + (ix+iy)*K2
    m = 0.0
    if ay <= ax then
        m = 1.0
    end
    bx = ax - m + K2
    by = ay - 1-m + K2
    cx = ax - 1 + 2*K2
    cy = ay - 1 + 2*K2
    hx = math.max(0.5-(ax*ax+ay*ay), 0)
    hy = math.max(0.5-(bx*bx+by*by), 0)
    hz = math.max(0.5-(cx*cx+cy*cy), 0)
    hs1 = hash(ix, iy)
    hs2 = hash(ix+m, iy+1-m)
    hs3 = hash(ix+1, iy+1)
    h4 = hx*hx*hx*hx
    nx = h4*(ax*hs1.x+ay*hs1.y)
    ny = h4*(bx*hs2.x+by*hs2.y)
    nz = h4*(cx*hs3.x+cy*hs3.y)

    return (nx+ny+nz)*70.0
end

function fractalNoise(x, y, maxX, maxY)
    x = x / maxX * 1.0
    y = y / maxY * 1.0

    ret = 0
    g = 1 / 2.0
    for i = 1, 5, 1 do
        ret = ret + g * simplexNoise(x, y)
        x = x * 1.6
        y = y * 1.6
        g = g / 2
    end

    ret = ret * 0.75 + 0.3
    ret = ret*ret*(3-2*ret)
    ret = ret*ret*(3-2*ret)

    if ret < 0.3 then
        return -5
    end

    return ret
end



-- Main Loop
mon = peripheral.wrap(monitor)
mon.setTextScale(0.5)
w,h = mon.getSize()
t = 0
while true do
    for y=1,h do
        for x=1,w do
                mon.setCursorPos(x,y)
                mon.write(grayCharacter(fractalNoise(x+t,y+t*0.23,w,h)*10))
        end
    end
    t = t + 0.05
    os.sleep(0.1)
end
