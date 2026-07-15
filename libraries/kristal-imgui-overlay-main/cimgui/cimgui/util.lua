local env = {
    assert = assert,
    type = type,
    tonumber = tonumber,
    tostring = tostring,
    require = require,
    error = error,
    getmetatable = getmetatable,
    setmetatable = setmetatable,
    string = string,
    table = table,
    math = math,
    love = love,
    jit = jit,
}
setfenv(1, env)

local path = (...):gsub("[^%.]*$", "")
---@class (partial) imgui
local M = require(path .. "master")
local ffi = require("ffi")
local bit = require("bit")

---@return integer
function M.color(r,g,b,a)
    if type(r) == "table" then
        local alpha = r[4] or 1
        if type(g) == "number" then
            alpha = alpha * g
        end
        r,g,b,a = r[1] or 1, r[2] or 1, r[3] or 1, alpha
    end
    r,g,b,a = r*255, g*255, b*255, a*255
    return M.color255(r,g,b,a)
end

---@return integer
function M.color255(r,g,b,a)
    if type(r) == "table" then
        local alpha = r[4] or 1
        if type(g) == "number" then
            alpha = alpha * g
        end
        r,g,b,a = r[1] or 1, r[2] or 1, r[3] or 1, alpha
    end
    r,g,b,a = r,g,b,a
    return bit.bor(
        bit.lshift(r, 0),
        bit.lshift(g, 8),
        bit.lshift(b, 16),
        bit.lshift(a, 24)
    )
end

---@alias CdataWrapper<T> {[0]:T}

---@param initial boolean
---@return CdataWrapper<boolean>
function M.bool(initial)
    return ffi.new("bool[1]", initial)
end
