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
    love = love,
    jit = jit,
}
setfenv(1, env)

local path = (...):gsub("[^%.]*$", "")
---@class (partial) imgui
local M = require(path .. "master")
local ffi = require("ffi")

local C = M.C
local _common = M._common

-- add metamethods to ImVec2 and ImVec4

local ct = ffi.typeof("ImVec2")
local ImVec2 = {}
function ImVec2.__add(u, v)
    assert(type(u) == type(v) and ffi.istype(u, v), "One of the summands in not an ImVec2.")
    return ct(u.x + v.x, u.y + v.y)
end
function ImVec2.__sub(u, v)
    assert(type(u) == type(v) and ffi.istype(u, v), "One of the summands in not an ImVec2.")
    return ct( u.x - v.x, u.y - v.y)
end
function ImVec2.__unm(u)
    return ct(-u.x, -u.y)
end
function ImVec2.__mul(u, v)
    local nu, nv = tonumber(u), tonumber(v)
    if nu then
        return ct(nu*v.x, nu*v.y)
    elseif nv then
        return ct(nv*u.x, nv*u.y)
    else
        error("ImVec2 can only be multipliead by a numerical type.")
    end
end
function ImVec2.__div(u, a)
    a = assert(tonumber(a), "ImVec2 can only be divided by a numerical type.")
    return ct(u.x/a, u.y/a)
end

local ct = ffi.typeof("ImVec4")
local ImVec4 = {}
function ImVec4.__add(u, v)
    assert(type(u) == type(v) and ffi.istype(u, v), "One of the summands in not an ImVec4.")
    return ct(u.x + v.x, u.y + v.y, u.z + v.z, u.w + v.w)
end
function ImVec4.__sub(u, v)
    assert(type(u) == type(v) and ffi.istype(u, v), "One of the summands in not an ImVec4.")
    return ct(u.x - v.x, u.y - v.y, u.z - v.z, u.w - v.w)
end
function ImVec4.__unm(u)
    return ct(-u.x, -u.y, -u.z, -u.w)
end
function ImVec4.__mul(u, v)
    local nu, nv = tonumber(u), tonumber(v)
    if nu then
        return v:__new(nu*v.x, nu*v.y, nu*v.z, nu*v.w)
    elseif nv then
        return ct(nv*u.x, nv*u.y, nv*u.z, nv*u.w)
    else
        error("ImVec4 can only be multipliead by a numerical type.")
    end
end
function ImVec4.__div(u, a)
    a = assert(tonumber(a), "ImVec4 can only be divided by a numerical type.")
    return ct(u.x/a, u.y/a, u.z/a, u.w/a)
end

-- wrap FLT_MIN, FLT_MAX

local FLT_MIN, FLT_MAX = C.igGET_FLT_MIN(), C.igGET_FLT_MAX()
M.FLT_MIN, M.FLT_MAX = FLT_MIN, FLT_MAX

-- handwritten functions

M.ImVector_ImWchar = function()
    jit.off(true)
    local p = C.ImVector_ImWchar_create()
    return ffi.gc(p[0], C.ImVector_ImWchar_destroy)
end

-----------------------
-- BEGIN GENERATED CODE
-----------------------

---@class imgui.ImColor
local ImColor = ImColor or {}
ImColor.__index = ImColor
function ImColor.HSV(h, s, v, a)
    jit.off(true)
    if a == nil then a = 1.0 end
    local o1 = M.ImColor_Nil()
    local out = C.ImColor_HSV(o1, h, s, v, a)
    return o1, out
end
function ImColor.SetHSV(self, h, s, v, a)
    jit.off(true)
    if a == nil then a = 1.0 end
    local out = C.ImColor_SetHSV(self, h, s, v, a)
    return out
end
---@return imgui.ImColor
M.ImColor_Nil = M.ImColor_Nil  or function()
    jit.off(true)
    local p = C.ImColor_ImColor_Nil()
    return ffi.gc(p[0], C.ImColor_destroy)
end
---@return imgui.ImColor
M.ImColor_Float = M.ImColor_Float  or function(r, g, b, a)
    jit.off(true)
    local p = C.ImColor_ImColor_Float(r, g, b, a)
    return ffi.gc(p[0], C.ImColor_destroy)
end
---@return imgui.ImColor
M.ImColor_Vec4 = M.ImColor_Vec4  or function(col)
    jit.off(true)
    local p = C.ImColor_ImColor_Vec4(col)
    return ffi.gc(p[0], C.ImColor_destroy)
end
---@return imgui.ImColor
M.ImColor_Int = M.ImColor_Int  or function(r, g, b, a)
    jit.off(true)
    local p = C.ImColor_ImColor_Int(r, g, b, a)
    return ffi.gc(p[0], C.ImColor_destroy)
end
---@return imgui.ImColor
M.ImColor_U32 = M.ImColor_U32  or function(rgba)
    jit.off(true)
    local p = C.ImColor_ImColor_U32(rgba)
    return ffi.gc(p[0], C.ImColor_destroy)
end
M.ImColor = ImColor
ffi.metatype("ImColor", ImColor)

---@class imgui.ImDrawCmd
local ImDrawCmd = ImDrawCmd or {}
ImDrawCmd.__index = ImDrawCmd
function ImDrawCmd.GetTexID(self)
    jit.off(true)
    local out = C.ImDrawCmd_GetTexID(self)
    return out
end
local mt = getmetatable(ImDrawCmd) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImDrawCmd_ImDrawCmd()
    return ffi.gc(p[0], C.ImDrawCmd_destroy)
end
setmetatable(ImDrawCmd, mt)
M.ImDrawCmd = ImDrawCmd
ffi.metatype("ImDrawCmd", ImDrawCmd)

---@class imgui.ImDrawData
local ImDrawData = ImDrawData or {}
ImDrawData.__index = ImDrawData
function ImDrawData.AddDrawList(self, draw_list)
    jit.off(true)
    local out = C.ImDrawData_AddDrawList(self, draw_list)
    return out
end
function ImDrawData.Clear(self)
    jit.off(true)
    local out = C.ImDrawData_Clear(self)
    return out
end
function ImDrawData.DeIndexAllBuffers(self)
    jit.off(true)
    local out = C.ImDrawData_DeIndexAllBuffers(self)
    return out
end
function ImDrawData.ScaleClipRects(self, fb_scale)
    jit.off(true)
    local out = C.ImDrawData_ScaleClipRects(self, fb_scale)
    return out
end
local mt = getmetatable(ImDrawData) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImDrawData_ImDrawData()
    return ffi.gc(p[0], C.ImDrawData_destroy)
end
setmetatable(ImDrawData, mt)
M.ImDrawData = ImDrawData
ffi.metatype("ImDrawData", ImDrawData)

---@class imgui.ImDrawList
local ImDrawList = ImDrawList or {}
ImDrawList.__index = ImDrawList
function ImDrawList.AddBezierCubic(self, p1, p2, p3, p4, col, thickness, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_AddBezierCubic(self, p1, p2, p3, p4, col, thickness, num_segments)
    return out
end
function ImDrawList.AddBezierQuadratic(self, p1, p2, p3, col, thickness, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_AddBezierQuadratic(self, p1, p2, p3, col, thickness, num_segments)
    return out
end
function ImDrawList.AddCallback(self, callback, userdata, userdata_size)
    jit.off(true)
    if userdata_size == nil then userdata_size = 0 end
    if not ffi.istype("ImDrawCallback", callback) then
        local str = tostring(callback)
        _common.callbacks[str] = callback
        callback = ffi.cast("ImDrawCallback", str)
    end
    local out = C.ImDrawList_AddCallback(self, callback, userdata, userdata_size)
    return out
end
function ImDrawList.AddCircle(self, center, radius, col, num_segments, thickness)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddCircle(self, center, radius, col, num_segments, thickness)
    return out
end
function ImDrawList.AddCircleFilled(self, center, radius, col, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_AddCircleFilled(self, center, radius, col, num_segments)
    return out
end
function ImDrawList.AddConcavePolyFilled(self, points, num_points, col)
    jit.off(true)
    local out = C.ImDrawList_AddConcavePolyFilled(self, points, num_points, col)
    return out
end
function ImDrawList.AddConvexPolyFilled(self, points, num_points, col)
    jit.off(true)
    local out = C.ImDrawList_AddConvexPolyFilled(self, points, num_points, col)
    return out
end
function ImDrawList.AddDrawCmd(self)
    jit.off(true)
    local out = C.ImDrawList_AddDrawCmd(self)
    return out
end
function ImDrawList.AddEllipse(self, center, radius, col, rot, num_segments, thickness)
    jit.off(true)
    if rot == nil then rot = 0.0 end
    if num_segments == nil then num_segments = 0 end
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddEllipse(self, center, radius, col, rot, num_segments, thickness)
    return out
end
function ImDrawList.AddEllipseFilled(self, center, radius, col, rot, num_segments)
    jit.off(true)
    if rot == nil then rot = 0.0 end
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_AddEllipseFilled(self, center, radius, col, rot, num_segments)
    return out
end
function ImDrawList.AddImage(self, tex_ref, p_min, p_max, uv_min, uv_max, col)
    jit.off(true)
    if uv_min == nil then uv_min = M.ImVec2_Float(0, 0) end
    if uv_max == nil then uv_max = M.ImVec2_Float(1, 1) end
    if col == nil then col = 4294967295 end
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.ImDrawList_AddImage(self, tex_ref, p_min, p_max, uv_min, uv_max, col)
    return out
end
function ImDrawList.AddImageQuad(self, tex_ref, p1, p2, p3, p4, uv1, uv2, uv3, uv4, col)
    jit.off(true)
    if uv1 == nil then uv1 = M.ImVec2_Float(0, 0) end
    if uv2 == nil then uv2 = M.ImVec2_Float(1, 0) end
    if uv3 == nil then uv3 = M.ImVec2_Float(1, 1) end
    if uv4 == nil then uv4 = M.ImVec2_Float(0, 1) end
    if col == nil then col = 4294967295 end
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.ImDrawList_AddImageQuad(self, tex_ref, p1, p2, p3, p4, uv1, uv2, uv3, uv4, col)
    return out
end
function ImDrawList.AddImageRounded(self, tex_ref, p_min, p_max, uv_min, uv_max, col, rounding, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.ImDrawList_AddImageRounded(self, tex_ref, p_min, p_max, uv_min, uv_max, col, rounding, flags)
    return out
end
function ImDrawList.AddLine(self, p1, p2, col, thickness)
    jit.off(true)
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddLine(self, p1, p2, col, thickness)
    return out
end
function ImDrawList.AddNgon(self, center, radius, col, num_segments, thickness)
    jit.off(true)
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddNgon(self, center, radius, col, num_segments, thickness)
    return out
end
function ImDrawList.AddNgonFilled(self, center, radius, col, num_segments)
    jit.off(true)
    local out = C.ImDrawList_AddNgonFilled(self, center, radius, col, num_segments)
    return out
end
function ImDrawList.AddPolyline(self, points, num_points, col, flags, thickness)
    jit.off(true)
    local out = C.ImDrawList_AddPolyline(self, points, num_points, col, flags, thickness)
    return out
end
function ImDrawList.AddQuad(self, p1, p2, p3, p4, col, thickness)
    jit.off(true)
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddQuad(self, p1, p2, p3, p4, col, thickness)
    return out
end
function ImDrawList.AddQuadFilled(self, p1, p2, p3, p4, col)
    jit.off(true)
    local out = C.ImDrawList_AddQuadFilled(self, p1, p2, p3, p4, col)
    return out
end
function ImDrawList.AddRect(self, p_min, p_max, col, rounding, flags, thickness)
    jit.off(true)
    if rounding == nil then rounding = 0.0 end
    if flags == nil then flags = 0 end
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddRect(self, p_min, p_max, col, rounding, flags, thickness)
    return out
end
function ImDrawList.AddRectFilled(self, p_min, p_max, col, rounding, flags)
    jit.off(true)
    if rounding == nil then rounding = 0.0 end
    if flags == nil then flags = 0 end
    local out = C.ImDrawList_AddRectFilled(self, p_min, p_max, col, rounding, flags)
    return out
end
function ImDrawList.AddRectFilledMultiColor(self, p_min, p_max, col_upr_left, col_upr_right, col_bot_right, col_bot_left)
    jit.off(true)
    local out = C.ImDrawList_AddRectFilledMultiColor(self, p_min, p_max, col_upr_left, col_upr_right, col_bot_right, col_bot_left)
    return out
end
function ImDrawList.AddText_Vec2(self, pos, col, text_begin, text_end)
    jit.off(true)
    local out = C.ImDrawList_AddText_Vec2(self, pos, col, text_begin, text_end)
    return out
end
function ImDrawList.AddText_FontPtr(self, font, font_size, pos, col, text_begin, text_end, wrap_width, cpu_fine_clip_rect)
    jit.off(true)
    if wrap_width == nil then wrap_width = 0.0 end
    local out = C.ImDrawList_AddText_FontPtr(self, font, font_size, pos, col, text_begin, text_end, wrap_width, cpu_fine_clip_rect)
    return out
end
function ImDrawList.AddTriangle(self, p1, p2, p3, col, thickness)
    jit.off(true)
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_AddTriangle(self, p1, p2, p3, col, thickness)
    return out
end
function ImDrawList.AddTriangleFilled(self, p1, p2, p3, col)
    jit.off(true)
    local out = C.ImDrawList_AddTriangleFilled(self, p1, p2, p3, col)
    return out
end
function ImDrawList.ChannelsMerge(self)
    jit.off(true)
    local out = C.ImDrawList_ChannelsMerge(self)
    return out
end
function ImDrawList.ChannelsSetCurrent(self, n)
    jit.off(true)
    local out = C.ImDrawList_ChannelsSetCurrent(self, n)
    return out
end
function ImDrawList.ChannelsSplit(self, count)
    jit.off(true)
    local out = C.ImDrawList_ChannelsSplit(self, count)
    return out
end
function ImDrawList.CloneOutput(self)
    jit.off(true)
    local out = C.ImDrawList_CloneOutput(self)
    return out
end
function ImDrawList.GetClipRectMax(self)
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.ImDrawList_GetClipRectMax(o1, self)
    return o1, out
end
function ImDrawList.GetClipRectMin(self)
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.ImDrawList_GetClipRectMin(o1, self)
    return o1, out
end
function ImDrawList.PathArcTo(self, center, radius, a_min, a_max, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_PathArcTo(self, center, radius, a_min, a_max, num_segments)
    return out
end
function ImDrawList.PathArcToFast(self, center, radius, a_min_of_12, a_max_of_12)
    jit.off(true)
    local out = C.ImDrawList_PathArcToFast(self, center, radius, a_min_of_12, a_max_of_12)
    return out
end
function ImDrawList.PathBezierCubicCurveTo(self, p2, p3, p4, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_PathBezierCubicCurveTo(self, p2, p3, p4, num_segments)
    return out
end
function ImDrawList.PathBezierQuadraticCurveTo(self, p2, p3, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_PathBezierQuadraticCurveTo(self, p2, p3, num_segments)
    return out
end
function ImDrawList.PathClear(self)
    jit.off(true)
    local out = C.ImDrawList_PathClear(self)
    return out
end
function ImDrawList.PathEllipticalArcTo(self, center, radius, rot, a_min, a_max, num_segments)
    jit.off(true)
    if num_segments == nil then num_segments = 0 end
    local out = C.ImDrawList_PathEllipticalArcTo(self, center, radius, rot, a_min, a_max, num_segments)
    return out
end
function ImDrawList.PathFillConcave(self, col)
    jit.off(true)
    local out = C.ImDrawList_PathFillConcave(self, col)
    return out
end
function ImDrawList.PathFillConvex(self, col)
    jit.off(true)
    local out = C.ImDrawList_PathFillConvex(self, col)
    return out
end
function ImDrawList.PathLineTo(self, pos)
    jit.off(true)
    local out = C.ImDrawList_PathLineTo(self, pos)
    return out
end
function ImDrawList.PathLineToMergeDuplicate(self, pos)
    jit.off(true)
    local out = C.ImDrawList_PathLineToMergeDuplicate(self, pos)
    return out
end
function ImDrawList.PathRect(self, rect_min, rect_max, rounding, flags)
    jit.off(true)
    if rounding == nil then rounding = 0.0 end
    if flags == nil then flags = 0 end
    local out = C.ImDrawList_PathRect(self, rect_min, rect_max, rounding, flags)
    return out
end
function ImDrawList.PathStroke(self, col, flags, thickness)
    jit.off(true)
    if flags == nil then flags = 0 end
    if thickness == nil then thickness = 1.0 end
    local out = C.ImDrawList_PathStroke(self, col, flags, thickness)
    return out
end
function ImDrawList.PopClipRect(self)
    jit.off(true)
    local out = C.ImDrawList_PopClipRect(self)
    return out
end
function ImDrawList.PopTexture(self)
    jit.off(true)
    local out = C.ImDrawList_PopTexture(self)
    return out
end
function ImDrawList.PrimQuadUV(self, a, b, c, d, uv_a, uv_b, uv_c, uv_d, col)
    jit.off(true)
    local out = C.ImDrawList_PrimQuadUV(self, a, b, c, d, uv_a, uv_b, uv_c, uv_d, col)
    return out
end
function ImDrawList.PrimRect(self, a, b, col)
    jit.off(true)
    local out = C.ImDrawList_PrimRect(self, a, b, col)
    return out
end
function ImDrawList.PrimRectUV(self, a, b, uv_a, uv_b, col)
    jit.off(true)
    local out = C.ImDrawList_PrimRectUV(self, a, b, uv_a, uv_b, col)
    return out
end
function ImDrawList.PrimReserve(self, idx_count, vtx_count)
    jit.off(true)
    local out = C.ImDrawList_PrimReserve(self, idx_count, vtx_count)
    return out
end
function ImDrawList.PrimUnreserve(self, idx_count, vtx_count)
    jit.off(true)
    local out = C.ImDrawList_PrimUnreserve(self, idx_count, vtx_count)
    return out
end
function ImDrawList.PrimVtx(self, pos, uv, col)
    jit.off(true)
    local out = C.ImDrawList_PrimVtx(self, pos, uv, col)
    return out
end
function ImDrawList.PrimWriteIdx(self, idx)
    jit.off(true)
    local out = C.ImDrawList_PrimWriteIdx(self, idx)
    return out
end
function ImDrawList.PrimWriteVtx(self, pos, uv, col)
    jit.off(true)
    local out = C.ImDrawList_PrimWriteVtx(self, pos, uv, col)
    return out
end
function ImDrawList.PushClipRect(self, clip_rect_min, clip_rect_max, intersect_with_current_clip_rect)
    jit.off(true)
    if intersect_with_current_clip_rect == nil then intersect_with_current_clip_rect = false end
    local out = C.ImDrawList_PushClipRect(self, clip_rect_min, clip_rect_max, intersect_with_current_clip_rect)
    return out
end
function ImDrawList.PushClipRectFullScreen(self)
    jit.off(true)
    local out = C.ImDrawList_PushClipRectFullScreen(self)
    return out
end
function ImDrawList.PushTexture(self, tex_ref)
    jit.off(true)
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.ImDrawList_PushTexture(self, tex_ref)
    return out
end
function ImDrawList._CalcCircleAutoSegmentCount(self, radius)
    jit.off(true)
    local out = C.ImDrawList__CalcCircleAutoSegmentCount(self, radius)
    return out
end
function ImDrawList._ClearFreeMemory(self)
    jit.off(true)
    local out = C.ImDrawList__ClearFreeMemory(self)
    return out
end
function ImDrawList._OnChangedClipRect(self)
    jit.off(true)
    local out = C.ImDrawList__OnChangedClipRect(self)
    return out
end
function ImDrawList._OnChangedTexture(self)
    jit.off(true)
    local out = C.ImDrawList__OnChangedTexture(self)
    return out
end
function ImDrawList._OnChangedVtxOffset(self)
    jit.off(true)
    local out = C.ImDrawList__OnChangedVtxOffset(self)
    return out
end
function ImDrawList._PathArcToFastEx(self, center, radius, a_min_sample, a_max_sample, a_step)
    jit.off(true)
    local out = C.ImDrawList__PathArcToFastEx(self, center, radius, a_min_sample, a_max_sample, a_step)
    return out
end
function ImDrawList._PathArcToN(self, center, radius, a_min, a_max, num_segments)
    jit.off(true)
    local out = C.ImDrawList__PathArcToN(self, center, radius, a_min, a_max, num_segments)
    return out
end
function ImDrawList._PopUnusedDrawCmd(self)
    jit.off(true)
    local out = C.ImDrawList__PopUnusedDrawCmd(self)
    return out
end
function ImDrawList._ResetForNewFrame(self)
    jit.off(true)
    local out = C.ImDrawList__ResetForNewFrame(self)
    return out
end
function ImDrawList._SetDrawListSharedData(self, data)
    jit.off(true)
    local out = C.ImDrawList__SetDrawListSharedData(self, data)
    return out
end
function ImDrawList._SetTexture(self, tex_ref)
    jit.off(true)
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.ImDrawList__SetTexture(self, tex_ref)
    return out
end
function ImDrawList._TryMergeDrawCmds(self)
    jit.off(true)
    local out = C.ImDrawList__TryMergeDrawCmds(self)
    return out
end
local mt = getmetatable(ImDrawList) or {}
mt.__call = mt.__call or function(self, shared_data)
    jit.off(true)
    local p = C.ImDrawList_ImDrawList(shared_data)
    return ffi.gc(p[0], C.ImDrawList_destroy)
end
setmetatable(ImDrawList, mt)
M.ImDrawList = ImDrawList
ffi.metatype("ImDrawList", ImDrawList)

---@class imgui.ImDrawListSplitter
local ImDrawListSplitter = ImDrawListSplitter or {}
ImDrawListSplitter.__index = ImDrawListSplitter
function ImDrawListSplitter.Clear(self)
    jit.off(true)
    local out = C.ImDrawListSplitter_Clear(self)
    return out
end
function ImDrawListSplitter.ClearFreeMemory(self)
    jit.off(true)
    local out = C.ImDrawListSplitter_ClearFreeMemory(self)
    return out
end
function ImDrawListSplitter.Merge(self, draw_list)
    jit.off(true)
    local out = C.ImDrawListSplitter_Merge(self, draw_list)
    return out
end
function ImDrawListSplitter.SetCurrentChannel(self, draw_list, channel_idx)
    jit.off(true)
    local out = C.ImDrawListSplitter_SetCurrentChannel(self, draw_list, channel_idx)
    return out
end
function ImDrawListSplitter.Split(self, draw_list, count)
    jit.off(true)
    local out = C.ImDrawListSplitter_Split(self, draw_list, count)
    return out
end
local mt = getmetatable(ImDrawListSplitter) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImDrawListSplitter_ImDrawListSplitter()
    return ffi.gc(p[0], C.ImDrawListSplitter_destroy)
end
setmetatable(ImDrawListSplitter, mt)
M.ImDrawListSplitter = ImDrawListSplitter
ffi.metatype("ImDrawListSplitter", ImDrawListSplitter)

---@class imgui.ImFont
local ImFont = ImFont or {}
ImFont.__index = ImFont
function ImFont.AddRemapChar(self, from_codepoint, to_codepoint)
    jit.off(true)
    local out = C.ImFont_AddRemapChar(self, from_codepoint, to_codepoint)
    return out
end
function ImFont.CalcTextSizeA(self, size, max_width, wrap_width, text_begin, text_end, remaining)
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.ImFont_CalcTextSizeA(o1, self, size, max_width, wrap_width, text_begin, text_end, remaining)
    return o1, out
end
function ImFont.CalcWordWrapPosition(self, size, text, text_end, wrap_width)
    jit.off(true)
    local out = C.ImFont_CalcWordWrapPosition(self, size, text, text_end, wrap_width)
    return out
end
function ImFont.ClearOutputData(self)
    jit.off(true)
    local out = C.ImFont_ClearOutputData(self)
    return out
end
function ImFont.GetDebugName(self)
    jit.off(true)
    local out = C.ImFont_GetDebugName(self)
    return out
end
function ImFont.GetFontBaked(self, font_size, density)
    jit.off(true)
    if density == nil then density = -1.0 end
    local out = C.ImFont_GetFontBaked(self, font_size, density)
    return out
end
function ImFont.IsGlyphInFont(self, c)
    jit.off(true)
    local out = C.ImFont_IsGlyphInFont(self, c)
    return out
end
function ImFont.IsGlyphRangeUnused(self, c_begin, c_last)
    jit.off(true)
    local out = C.ImFont_IsGlyphRangeUnused(self, c_begin, c_last)
    return out
end
function ImFont.IsLoaded(self)
    jit.off(true)
    local out = C.ImFont_IsLoaded(self)
    return out
end
function ImFont.RenderChar(self, draw_list, size, pos, col, c, cpu_fine_clip)
    jit.off(true)
    local out = C.ImFont_RenderChar(self, draw_list, size, pos, col, c, cpu_fine_clip)
    return out
end
function ImFont.RenderText(self, draw_list, size, pos, col, clip_rect, text_begin, text_end, wrap_width, cpu_fine_clip)
    jit.off(true)
    if wrap_width == nil then wrap_width = 0.0 end
    if cpu_fine_clip == nil then cpu_fine_clip = false end
    local out = C.ImFont_RenderText(self, draw_list, size, pos, col, clip_rect, text_begin, text_end, wrap_width, cpu_fine_clip)
    return out
end
local mt = getmetatable(ImFont) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFont_ImFont()
    return ffi.gc(p[0], C.ImFont_destroy)
end
setmetatable(ImFont, mt)
M.ImFont = ImFont
ffi.metatype("ImFont", ImFont)

---@class imgui.ImFontAtlas
local ImFontAtlas = ImFontAtlas or {}
ImFontAtlas.__index = ImFontAtlas
function ImFontAtlas.AddCustomRect(self, width, height, out_r)
    jit.off(true)
    local out = C.ImFontAtlas_AddCustomRect(self, width, height, out_r)
    return out
end
function ImFontAtlas.AddFont(self, font_cfg)
    jit.off(true)
    local out = C.ImFontAtlas_AddFont(self, font_cfg)
    return out
end
function ImFontAtlas.AddFontDefault(self, font_cfg)
    jit.off(true)
    local out = C.ImFontAtlas_AddFontDefault(self, font_cfg)
    return out
end
function ImFontAtlas.AddFontFromFileTTF(self, filename, size_pixels, font_cfg, glyph_ranges)
    jit.off(true)
    if size_pixels == nil then size_pixels = 0.0 end
    local out = C.ImFontAtlas_AddFontFromFileTTF(self, filename, size_pixels, font_cfg, glyph_ranges)
    return out
end
function ImFontAtlas.AddFontFromMemoryCompressedBase85TTF(self, compressed_font_data_base85, size_pixels, font_cfg, glyph_ranges)
    jit.off(true)
    if size_pixels == nil then size_pixels = 0.0 end
    local out = C.ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self, compressed_font_data_base85, size_pixels, font_cfg, glyph_ranges)
    return out
end
function ImFontAtlas.AddFontFromMemoryCompressedTTF(self, compressed_font_data, compressed_font_data_size, size_pixels, font_cfg, glyph_ranges)
    jit.off(true)
    if size_pixels == nil then size_pixels = 0.0 end
    local out = C.ImFontAtlas_AddFontFromMemoryCompressedTTF(self, compressed_font_data, compressed_font_data_size, size_pixels, font_cfg, glyph_ranges)
    return out
end
function ImFontAtlas.AddFontFromMemoryTTF(self, font_data, font_data_size, size_pixels, font_cfg, glyph_ranges)
    jit.off(true)
    if size_pixels == nil then size_pixels = 0.0 end
    local out = C.ImFontAtlas_AddFontFromMemoryTTF(self, font_data, font_data_size, size_pixels, font_cfg, glyph_ranges)
    return out
end
function ImFontAtlas.Clear(self)
    jit.off(true)
    local out = C.ImFontAtlas_Clear(self)
    return out
end
function ImFontAtlas.ClearFonts(self)
    jit.off(true)
    local out = C.ImFontAtlas_ClearFonts(self)
    return out
end
function ImFontAtlas.ClearInputData(self)
    jit.off(true)
    local out = C.ImFontAtlas_ClearInputData(self)
    return out
end
function ImFontAtlas.ClearTexData(self)
    jit.off(true)
    local out = C.ImFontAtlas_ClearTexData(self)
    return out
end
function ImFontAtlas.CompactCache(self)
    jit.off(true)
    local out = C.ImFontAtlas_CompactCache(self)
    return out
end
function ImFontAtlas.GetCustomRect(self, id, out_r)
    jit.off(true)
    local out = C.ImFontAtlas_GetCustomRect(self, id, out_r)
    return out
end
function ImFontAtlas.GetGlyphRangesDefault(self)
    jit.off(true)
    local out = C.ImFontAtlas_GetGlyphRangesDefault(self)
    return out
end
function ImFontAtlas.RemoveCustomRect(self, id)
    jit.off(true)
    local out = C.ImFontAtlas_RemoveCustomRect(self, id)
    return out
end
function ImFontAtlas.RemoveFont(self, font)
    jit.off(true)
    local out = C.ImFontAtlas_RemoveFont(self, font)
    return out
end
local mt = getmetatable(ImFontAtlas) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFontAtlas_ImFontAtlas()
    return ffi.gc(p[0], C.ImFontAtlas_destroy)
end
setmetatable(ImFontAtlas, mt)
M.ImFontAtlas = ImFontAtlas
ffi.metatype("ImFontAtlas", ImFontAtlas)

---@class imgui.ImFontAtlasRect
local ImFontAtlasRect = ImFontAtlasRect or {}
ImFontAtlasRect.__index = ImFontAtlasRect
local mt = getmetatable(ImFontAtlasRect) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFontAtlasRect_ImFontAtlasRect()
    return ffi.gc(p[0], C.ImFontAtlasRect_destroy)
end
setmetatable(ImFontAtlasRect, mt)
M.ImFontAtlasRect = ImFontAtlasRect
ffi.metatype("ImFontAtlasRect", ImFontAtlasRect)

---@class imgui.ImFontBaked
local ImFontBaked = ImFontBaked or {}
ImFontBaked.__index = ImFontBaked
function ImFontBaked.ClearOutputData(self)
    jit.off(true)
    local out = C.ImFontBaked_ClearOutputData(self)
    return out
end
function ImFontBaked.FindGlyph(self, c)
    jit.off(true)
    local out = C.ImFontBaked_FindGlyph(self, c)
    return out
end
function ImFontBaked.FindGlyphNoFallback(self, c)
    jit.off(true)
    local out = C.ImFontBaked_FindGlyphNoFallback(self, c)
    return out
end
function ImFontBaked.GetCharAdvance(self, c)
    jit.off(true)
    local out = C.ImFontBaked_GetCharAdvance(self, c)
    return out
end
function ImFontBaked.IsGlyphLoaded(self, c)
    jit.off(true)
    local out = C.ImFontBaked_IsGlyphLoaded(self, c)
    return out
end
local mt = getmetatable(ImFontBaked) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFontBaked_ImFontBaked()
    return ffi.gc(p[0], C.ImFontBaked_destroy)
end
setmetatable(ImFontBaked, mt)
M.ImFontBaked = ImFontBaked
ffi.metatype("ImFontBaked", ImFontBaked)

---@class imgui.ImFontConfig
local ImFontConfig = ImFontConfig or {}
ImFontConfig.__index = ImFontConfig
local mt = getmetatable(ImFontConfig) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFontConfig_ImFontConfig()
    return ffi.gc(p[0], C.ImFontConfig_destroy)
end
setmetatable(ImFontConfig, mt)
M.ImFontConfig = ImFontConfig
ffi.metatype("ImFontConfig", ImFontConfig)

---@class imgui.ImFontGlyph
local ImFontGlyph = ImFontGlyph or {}
ImFontGlyph.__index = ImFontGlyph
local mt = getmetatable(ImFontGlyph) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFontGlyph_ImFontGlyph()
    return ffi.gc(p[0], C.ImFontGlyph_destroy)
end
setmetatable(ImFontGlyph, mt)
M.ImFontGlyph = ImFontGlyph
ffi.metatype("ImFontGlyph", ImFontGlyph)

---@class imgui.ImFontGlyphRangesBuilder
local ImFontGlyphRangesBuilder = ImFontGlyphRangesBuilder or {}
ImFontGlyphRangesBuilder.__index = ImFontGlyphRangesBuilder
function ImFontGlyphRangesBuilder.AddChar(self, c)
    jit.off(true)
    local out = C.ImFontGlyphRangesBuilder_AddChar(self, c)
    return out
end
function ImFontGlyphRangesBuilder.AddRanges(self, ranges)
    jit.off(true)
    local out = C.ImFontGlyphRangesBuilder_AddRanges(self, ranges)
    return out
end
function ImFontGlyphRangesBuilder.AddText(self, text, text_end)
    jit.off(true)
    local out = C.ImFontGlyphRangesBuilder_AddText(self, text, text_end)
    return out
end
function ImFontGlyphRangesBuilder.BuildRanges(self)
    jit.off(true)
    local o1 = M.ImVector_ImWchar()
    local out = C.ImFontGlyphRangesBuilder_BuildRanges(self, o1)
    return o1, out
end
function ImFontGlyphRangesBuilder.Clear(self)
    jit.off(true)
    local out = C.ImFontGlyphRangesBuilder_Clear(self)
    return out
end
function ImFontGlyphRangesBuilder.GetBit(self, n)
    jit.off(true)
    local out = C.ImFontGlyphRangesBuilder_GetBit(self, n)
    return out
end
function ImFontGlyphRangesBuilder.SetBit(self, n)
    jit.off(true)
    local out = C.ImFontGlyphRangesBuilder_SetBit(self, n)
    return out
end
local mt = getmetatable(ImFontGlyphRangesBuilder) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder()
    return ffi.gc(p[0], C.ImFontGlyphRangesBuilder_destroy)
end
setmetatable(ImFontGlyphRangesBuilder, mt)
M.ImFontGlyphRangesBuilder = ImFontGlyphRangesBuilder
ffi.metatype("ImFontGlyphRangesBuilder", ImFontGlyphRangesBuilder)

---@class imgui.ImGuiIO
local ImGuiIO = ImGuiIO or {}
ImGuiIO.__index = ImGuiIO
function ImGuiIO.AddFocusEvent(self, focused)
    jit.off(true)
    local out = C.ImGuiIO_AddFocusEvent(self, focused)
    return out
end
function ImGuiIO.AddInputCharacter(self, c)
    jit.off(true)
    local out = C.ImGuiIO_AddInputCharacter(self, c)
    return out
end
function ImGuiIO.AddInputCharacterUTF16(self, c)
    jit.off(true)
    local out = C.ImGuiIO_AddInputCharacterUTF16(self, c)
    return out
end
function ImGuiIO.AddInputCharactersUTF8(self, str)
    jit.off(true)
    local out = C.ImGuiIO_AddInputCharactersUTF8(self, str)
    return out
end
function ImGuiIO.AddKeyAnalogEvent(self, key, down, v)
    jit.off(true)
    local out = C.ImGuiIO_AddKeyAnalogEvent(self, key, down, v)
    return out
end
function ImGuiIO.AddKeyEvent(self, key, down)
    jit.off(true)
    local out = C.ImGuiIO_AddKeyEvent(self, key, down)
    return out
end
function ImGuiIO.AddMouseButtonEvent(self, button, down)
    jit.off(true)
    local out = C.ImGuiIO_AddMouseButtonEvent(self, button, down)
    return out
end
function ImGuiIO.AddMousePosEvent(self, x, y)
    jit.off(true)
    local out = C.ImGuiIO_AddMousePosEvent(self, x, y)
    return out
end
function ImGuiIO.AddMouseSourceEvent(self, source)
    jit.off(true)
    local out = C.ImGuiIO_AddMouseSourceEvent(self, source)
    return out
end
function ImGuiIO.AddMouseViewportEvent(self, id)
    jit.off(true)
    local out = C.ImGuiIO_AddMouseViewportEvent(self, id)
    return out
end
function ImGuiIO.AddMouseWheelEvent(self, wheel_x, wheel_y)
    jit.off(true)
    local out = C.ImGuiIO_AddMouseWheelEvent(self, wheel_x, wheel_y)
    return out
end
function ImGuiIO.ClearEventsQueue(self)
    jit.off(true)
    local out = C.ImGuiIO_ClearEventsQueue(self)
    return out
end
function ImGuiIO.ClearInputKeys(self)
    jit.off(true)
    local out = C.ImGuiIO_ClearInputKeys(self)
    return out
end
function ImGuiIO.ClearInputMouse(self)
    jit.off(true)
    local out = C.ImGuiIO_ClearInputMouse(self)
    return out
end
function ImGuiIO.SetAppAcceptingEvents(self, accepting_events)
    jit.off(true)
    local out = C.ImGuiIO_SetAppAcceptingEvents(self, accepting_events)
    return out
end
function ImGuiIO.SetKeyEventNativeData(self, key, native_keycode, native_scancode, native_legacy_index)
    jit.off(true)
    if native_legacy_index == nil then native_legacy_index = -1 end
    local out = C.ImGuiIO_SetKeyEventNativeData(self, key, native_keycode, native_scancode, native_legacy_index)
    return out
end
local mt = getmetatable(ImGuiIO) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiIO_ImGuiIO()
    return ffi.gc(p[0], C.ImGuiIO_destroy)
end
setmetatable(ImGuiIO, mt)
M.ImGuiIO = ImGuiIO
ffi.metatype("ImGuiIO", ImGuiIO)

---@class imgui.ImGuiInputTextCallbackData
local ImGuiInputTextCallbackData = ImGuiInputTextCallbackData or {}
ImGuiInputTextCallbackData.__index = ImGuiInputTextCallbackData
function ImGuiInputTextCallbackData.ClearSelection(self)
    jit.off(true)
    local out = C.ImGuiInputTextCallbackData_ClearSelection(self)
    return out
end
function ImGuiInputTextCallbackData.DeleteChars(self, pos, bytes_count)
    jit.off(true)
    local out = C.ImGuiInputTextCallbackData_DeleteChars(self, pos, bytes_count)
    return out
end
function ImGuiInputTextCallbackData.HasSelection(self)
    jit.off(true)
    local out = C.ImGuiInputTextCallbackData_HasSelection(self)
    return out
end
function ImGuiInputTextCallbackData.InsertChars(self, pos, text, text_end)
    jit.off(true)
    local out = C.ImGuiInputTextCallbackData_InsertChars(self, pos, text, text_end)
    return out
end
function ImGuiInputTextCallbackData.SelectAll(self)
    jit.off(true)
    local out = C.ImGuiInputTextCallbackData_SelectAll(self)
    return out
end
local mt = getmetatable(ImGuiInputTextCallbackData) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiInputTextCallbackData_ImGuiInputTextCallbackData()
    return ffi.gc(p[0], C.ImGuiInputTextCallbackData_destroy)
end
setmetatable(ImGuiInputTextCallbackData, mt)
M.ImGuiInputTextCallbackData = ImGuiInputTextCallbackData
ffi.metatype("ImGuiInputTextCallbackData", ImGuiInputTextCallbackData)

---@class imgui.ImGuiListClipper
local ImGuiListClipper = ImGuiListClipper or {}
ImGuiListClipper.__index = ImGuiListClipper
function ImGuiListClipper.Begin(self, items_count, items_height)
    jit.off(true)
    if items_height == nil then items_height = -1.0 end
    local out = C.ImGuiListClipper_Begin(self, items_count, items_height)
    return out
end
function ImGuiListClipper.End(self)
    jit.off(true)
    local out = C.ImGuiListClipper_End(self)
    return out
end
function ImGuiListClipper.IncludeItemByIndex(self, item_index)
    jit.off(true)
    local out = C.ImGuiListClipper_IncludeItemByIndex(self, item_index)
    return out
end
function ImGuiListClipper.IncludeItemsByIndex(self, item_begin, item_end)
    jit.off(true)
    local out = C.ImGuiListClipper_IncludeItemsByIndex(self, item_begin, item_end)
    return out
end
function ImGuiListClipper.SeekCursorForItem(self, item_index)
    jit.off(true)
    local out = C.ImGuiListClipper_SeekCursorForItem(self, item_index)
    return out
end
function ImGuiListClipper.Step(self)
    jit.off(true)
    local out = C.ImGuiListClipper_Step(self)
    return out
end
local mt = getmetatable(ImGuiListClipper) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiListClipper_ImGuiListClipper()
    return ffi.gc(p[0], C.ImGuiListClipper_destroy)
end
setmetatable(ImGuiListClipper, mt)
M.ImGuiListClipper = ImGuiListClipper
ffi.metatype("ImGuiListClipper", ImGuiListClipper)

---@class imgui.ImGuiOnceUponAFrame
local ImGuiOnceUponAFrame = ImGuiOnceUponAFrame or {}
ImGuiOnceUponAFrame.__index = ImGuiOnceUponAFrame
local mt = getmetatable(ImGuiOnceUponAFrame) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiOnceUponAFrame_ImGuiOnceUponAFrame()
    return ffi.gc(p[0], C.ImGuiOnceUponAFrame_destroy)
end
setmetatable(ImGuiOnceUponAFrame, mt)
M.ImGuiOnceUponAFrame = ImGuiOnceUponAFrame
ffi.metatype("ImGuiOnceUponAFrame", ImGuiOnceUponAFrame)

---@class imgui.ImGuiPayload
local ImGuiPayload = ImGuiPayload or {}
ImGuiPayload.__index = ImGuiPayload
function ImGuiPayload.Clear(self)
    jit.off(true)
    local out = C.ImGuiPayload_Clear(self)
    return out
end
function ImGuiPayload.IsDataType(self, type)
    jit.off(true)
    local out = C.ImGuiPayload_IsDataType(self, type)
    return out
end
function ImGuiPayload.IsDelivery(self)
    jit.off(true)
    local out = C.ImGuiPayload_IsDelivery(self)
    return out
end
function ImGuiPayload.IsPreview(self)
    jit.off(true)
    local out = C.ImGuiPayload_IsPreview(self)
    return out
end
local mt = getmetatable(ImGuiPayload) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiPayload_ImGuiPayload()
    return ffi.gc(p[0], C.ImGuiPayload_destroy)
end
setmetatable(ImGuiPayload, mt)
M.ImGuiPayload = ImGuiPayload
ffi.metatype("ImGuiPayload", ImGuiPayload)

---@class imgui.ImGuiPlatformIO
local ImGuiPlatformIO = ImGuiPlatformIO or {}
ImGuiPlatformIO.__index = ImGuiPlatformIO
local mt = getmetatable(ImGuiPlatformIO) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiPlatformIO_ImGuiPlatformIO()
    return ffi.gc(p[0], C.ImGuiPlatformIO_destroy)
end
setmetatable(ImGuiPlatformIO, mt)
M.ImGuiPlatformIO = ImGuiPlatformIO
ffi.metatype("ImGuiPlatformIO", ImGuiPlatformIO)

---@class imgui.ImGuiPlatformImeData
local ImGuiPlatformImeData = ImGuiPlatformImeData or {}
ImGuiPlatformImeData.__index = ImGuiPlatformImeData
local mt = getmetatable(ImGuiPlatformImeData) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiPlatformImeData_ImGuiPlatformImeData()
    return ffi.gc(p[0], C.ImGuiPlatformImeData_destroy)
end
setmetatable(ImGuiPlatformImeData, mt)
M.ImGuiPlatformImeData = ImGuiPlatformImeData
ffi.metatype("ImGuiPlatformImeData", ImGuiPlatformImeData)

---@class imgui.ImGuiPlatformMonitor
local ImGuiPlatformMonitor = ImGuiPlatformMonitor or {}
ImGuiPlatformMonitor.__index = ImGuiPlatformMonitor
local mt = getmetatable(ImGuiPlatformMonitor) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiPlatformMonitor_ImGuiPlatformMonitor()
    return ffi.gc(p[0], C.ImGuiPlatformMonitor_destroy)
end
setmetatable(ImGuiPlatformMonitor, mt)
M.ImGuiPlatformMonitor = ImGuiPlatformMonitor
ffi.metatype("ImGuiPlatformMonitor", ImGuiPlatformMonitor)

---@class imgui.ImGuiSelectionBasicStorage
local ImGuiSelectionBasicStorage = ImGuiSelectionBasicStorage or {}
ImGuiSelectionBasicStorage.__index = ImGuiSelectionBasicStorage
function ImGuiSelectionBasicStorage.ApplyRequests(self, ms_io)
    jit.off(true)
    local out = C.ImGuiSelectionBasicStorage_ApplyRequests(self, ms_io)
    return out
end
function ImGuiSelectionBasicStorage.Clear(self)
    jit.off(true)
    local out = C.ImGuiSelectionBasicStorage_Clear(self)
    return out
end
function ImGuiSelectionBasicStorage.Contains(self, id)
    jit.off(true)
    local out = C.ImGuiSelectionBasicStorage_Contains(self, id)
    return out
end
function ImGuiSelectionBasicStorage.GetNextSelectedItem(self, opaque_it)
    jit.off(true)
    local o1 = ffi.new("ImGuiID[1]")
    local out = C.ImGuiSelectionBasicStorage_GetNextSelectedItem(self, opaque_it, o1)
    return o1[0], out
end
function ImGuiSelectionBasicStorage.GetStorageIdFromIndex(self, idx)
    jit.off(true)
    local out = C.ImGuiSelectionBasicStorage_GetStorageIdFromIndex(self, idx)
    return out
end
function ImGuiSelectionBasicStorage.SetItemSelected(self, id, selected)
    jit.off(true)
    local out = C.ImGuiSelectionBasicStorage_SetItemSelected(self, id, selected)
    return out
end
function ImGuiSelectionBasicStorage.Swap(self, r)
    jit.off(true)
    local out = C.ImGuiSelectionBasicStorage_Swap(self, r)
    return out
end
local mt = getmetatable(ImGuiSelectionBasicStorage) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage()
    return ffi.gc(p[0], C.ImGuiSelectionBasicStorage_destroy)
end
setmetatable(ImGuiSelectionBasicStorage, mt)
M.ImGuiSelectionBasicStorage = ImGuiSelectionBasicStorage
ffi.metatype("ImGuiSelectionBasicStorage", ImGuiSelectionBasicStorage)

---@class imgui.ImGuiSelectionExternalStorage
local ImGuiSelectionExternalStorage = ImGuiSelectionExternalStorage or {}
ImGuiSelectionExternalStorage.__index = ImGuiSelectionExternalStorage
function ImGuiSelectionExternalStorage.ApplyRequests(self, ms_io)
    jit.off(true)
    local out = C.ImGuiSelectionExternalStorage_ApplyRequests(self, ms_io)
    return out
end
local mt = getmetatable(ImGuiSelectionExternalStorage) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage()
    return ffi.gc(p[0], C.ImGuiSelectionExternalStorage_destroy)
end
setmetatable(ImGuiSelectionExternalStorage, mt)
M.ImGuiSelectionExternalStorage = ImGuiSelectionExternalStorage
ffi.metatype("ImGuiSelectionExternalStorage", ImGuiSelectionExternalStorage)

---@class imgui.ImGuiStorage
local ImGuiStorage = ImGuiStorage or {}
ImGuiStorage.__index = ImGuiStorage
function ImGuiStorage.BuildSortByKey(self)
    jit.off(true)
    local out = C.ImGuiStorage_BuildSortByKey(self)
    return out
end
function ImGuiStorage.Clear(self)
    jit.off(true)
    local out = C.ImGuiStorage_Clear(self)
    return out
end
function ImGuiStorage.GetBool(self, key, default_val)
    jit.off(true)
    if default_val == nil then default_val = false end
    local out = C.ImGuiStorage_GetBool(self, key, default_val)
    return out
end
function ImGuiStorage.GetBoolRef(self, key, default_val)
    jit.off(true)
    if default_val == nil then default_val = false end
    local out = C.ImGuiStorage_GetBoolRef(self, key, default_val)
    return out
end
function ImGuiStorage.GetFloat(self, key, default_val)
    jit.off(true)
    if default_val == nil then default_val = 0.0 end
    local out = C.ImGuiStorage_GetFloat(self, key, default_val)
    return out
end
function ImGuiStorage.GetFloatRef(self, key, default_val)
    jit.off(true)
    if default_val == nil then default_val = 0.0 end
    local out = C.ImGuiStorage_GetFloatRef(self, key, default_val)
    return out
end
function ImGuiStorage.GetInt(self, key, default_val)
    jit.off(true)
    if default_val == nil then default_val = 0 end
    local out = C.ImGuiStorage_GetInt(self, key, default_val)
    return out
end
function ImGuiStorage.GetIntRef(self, key, default_val)
    jit.off(true)
    if default_val == nil then default_val = 0 end
    local out = C.ImGuiStorage_GetIntRef(self, key, default_val)
    return out
end
function ImGuiStorage.GetVoidPtr(self, key)
    jit.off(true)
    local out = C.ImGuiStorage_GetVoidPtr(self, key)
    return out
end
function ImGuiStorage.GetVoidPtrRef(self, key, default_val)
    jit.off(true)
    local out = C.ImGuiStorage_GetVoidPtrRef(self, key, default_val)
    return out
end
function ImGuiStorage.SetAllInt(self, val)
    jit.off(true)
    local out = C.ImGuiStorage_SetAllInt(self, val)
    return out
end
function ImGuiStorage.SetBool(self, key, val)
    jit.off(true)
    local out = C.ImGuiStorage_SetBool(self, key, val)
    return out
end
function ImGuiStorage.SetFloat(self, key, val)
    jit.off(true)
    local out = C.ImGuiStorage_SetFloat(self, key, val)
    return out
end
function ImGuiStorage.SetInt(self, key, val)
    jit.off(true)
    local out = C.ImGuiStorage_SetInt(self, key, val)
    return out
end
function ImGuiStorage.SetVoidPtr(self, key, val)
    jit.off(true)
    local out = C.ImGuiStorage_SetVoidPtr(self, key, val)
    return out
end
M.ImGuiStorage = ImGuiStorage
ffi.metatype("ImGuiStorage", ImGuiStorage)

---@class imgui.ImGuiStoragePair
local ImGuiStoragePair = ImGuiStoragePair or {}
ImGuiStoragePair.__index = ImGuiStoragePair
---@return imgui.ImGuiStoragePair
M.ImGuiStoragePair_Int = M.ImGuiStoragePair_Int  or function(_key, _val)
    jit.off(true)
    local p = C.ImGuiStoragePair_ImGuiStoragePair_Int(_key, _val)
    return ffi.gc(p[0], C.ImGuiStoragePair_destroy)
end
---@return imgui.ImGuiStoragePair
M.ImGuiStoragePair_Float = M.ImGuiStoragePair_Float  or function(_key, _val)
    jit.off(true)
    local p = C.ImGuiStoragePair_ImGuiStoragePair_Float(_key, _val)
    return ffi.gc(p[0], C.ImGuiStoragePair_destroy)
end
---@return imgui.ImGuiStoragePair
M.ImGuiStoragePair_Ptr = M.ImGuiStoragePair_Ptr  or function(_key, _val)
    jit.off(true)
    local p = C.ImGuiStoragePair_ImGuiStoragePair_Ptr(_key, _val)
    return ffi.gc(p[0], C.ImGuiStoragePair_destroy)
end
M.ImGuiStoragePair = ImGuiStoragePair
ffi.metatype("ImGuiStoragePair", ImGuiStoragePair)

---@class imgui.ImGuiStyle
local ImGuiStyle = ImGuiStyle or {}
ImGuiStyle.__index = ImGuiStyle
function ImGuiStyle.ScaleAllSizes(self, scale_factor)
    jit.off(true)
    local out = C.ImGuiStyle_ScaleAllSizes(self, scale_factor)
    return out
end
local mt = getmetatable(ImGuiStyle) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiStyle_ImGuiStyle()
    return ffi.gc(p[0], C.ImGuiStyle_destroy)
end
setmetatable(ImGuiStyle, mt)
M.ImGuiStyle = ImGuiStyle
ffi.metatype("ImGuiStyle", ImGuiStyle)

---@class imgui.ImGuiTableColumnSortSpecs
local ImGuiTableColumnSortSpecs = ImGuiTableColumnSortSpecs or {}
ImGuiTableColumnSortSpecs.__index = ImGuiTableColumnSortSpecs
local mt = getmetatable(ImGuiTableColumnSortSpecs) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs()
    return ffi.gc(p[0], C.ImGuiTableColumnSortSpecs_destroy)
end
setmetatable(ImGuiTableColumnSortSpecs, mt)
M.ImGuiTableColumnSortSpecs = ImGuiTableColumnSortSpecs
ffi.metatype("ImGuiTableColumnSortSpecs", ImGuiTableColumnSortSpecs)

---@class imgui.ImGuiTableSortSpecs
local ImGuiTableSortSpecs = ImGuiTableSortSpecs or {}
ImGuiTableSortSpecs.__index = ImGuiTableSortSpecs
local mt = getmetatable(ImGuiTableSortSpecs) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiTableSortSpecs_ImGuiTableSortSpecs()
    return ffi.gc(p[0], C.ImGuiTableSortSpecs_destroy)
end
setmetatable(ImGuiTableSortSpecs, mt)
M.ImGuiTableSortSpecs = ImGuiTableSortSpecs
ffi.metatype("ImGuiTableSortSpecs", ImGuiTableSortSpecs)

---@class imgui.ImGuiTextBuffer
local ImGuiTextBuffer = ImGuiTextBuffer or {}
ImGuiTextBuffer.__index = ImGuiTextBuffer
function ImGuiTextBuffer.append(self, str, str_end)
    jit.off(true)
    local out = C.ImGuiTextBuffer_append(self, str, str_end)
    return out
end
function ImGuiTextBuffer.appendf(self, fmt, ...)
    jit.off(true)
    local out = C.ImGuiTextBuffer_appendf(self, fmt, ...)
    return out
end
function ImGuiTextBuffer.begin(self)
    jit.off(true)
    local out = C.ImGuiTextBuffer_begin(self)
    return out
end
function ImGuiTextBuffer.c_str(self)
    jit.off(true)
    local out = C.ImGuiTextBuffer_c_str(self)
    return out
end
function ImGuiTextBuffer.clear(self)
    jit.off(true)
    local out = C.ImGuiTextBuffer_clear(self)
    return out
end
function ImGuiTextBuffer.empty(self)
    jit.off(true)
    local out = C.ImGuiTextBuffer_empty(self)
    return out
end
ImGuiTextBuffer["end"] = ImGuiTextBuffer["end"]  or function(self)
    jit.off(true)
    local out = C.ImGuiTextBuffer_end(self)
    return out
end
ImGuiTextBuffer.c_end = ImGuiTextBuffer["end"] 
function ImGuiTextBuffer.reserve(self, capacity)
    jit.off(true)
    local out = C.ImGuiTextBuffer_reserve(self, capacity)
    return out
end
function ImGuiTextBuffer.resize(self, size)
    jit.off(true)
    local out = C.ImGuiTextBuffer_resize(self, size)
    return out
end
function ImGuiTextBuffer.size(self)
    jit.off(true)
    local out = C.ImGuiTextBuffer_size(self)
    return out
end
local mt = getmetatable(ImGuiTextBuffer) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiTextBuffer_ImGuiTextBuffer()
    return ffi.gc(p[0], C.ImGuiTextBuffer_destroy)
end
setmetatable(ImGuiTextBuffer, mt)
M.ImGuiTextBuffer = ImGuiTextBuffer
ffi.metatype("ImGuiTextBuffer", ImGuiTextBuffer)

---@class imgui.ImGuiTextFilter
local ImGuiTextFilter = ImGuiTextFilter or {}
ImGuiTextFilter.__index = ImGuiTextFilter
function ImGuiTextFilter.Build(self)
    jit.off(true)
    local out = C.ImGuiTextFilter_Build(self)
    return out
end
function ImGuiTextFilter.Clear(self)
    jit.off(true)
    local out = C.ImGuiTextFilter_Clear(self)
    return out
end
function ImGuiTextFilter.Draw(self, label, width)
    jit.off(true)
    if label == nil then label = "Filter(inc,-exc)" end
    if width == nil then width = 0.0 end
    local out = C.ImGuiTextFilter_Draw(self, label, width)
    return out
end
function ImGuiTextFilter.IsActive(self)
    jit.off(true)
    local out = C.ImGuiTextFilter_IsActive(self)
    return out
end
function ImGuiTextFilter.PassFilter(self, text, text_end)
    jit.off(true)
    local out = C.ImGuiTextFilter_PassFilter(self, text, text_end)
    return out
end
local mt = getmetatable(ImGuiTextFilter) or {}
mt.__call = mt.__call or function(self, default_filter)
    jit.off(true)
    local p = C.ImGuiTextFilter_ImGuiTextFilter(default_filter)
    return ffi.gc(p[0], C.ImGuiTextFilter_destroy)
end
setmetatable(ImGuiTextFilter, mt)
M.ImGuiTextFilter = ImGuiTextFilter
ffi.metatype("ImGuiTextFilter", ImGuiTextFilter)

---@class imgui.ImGuiTextRange
local ImGuiTextRange = ImGuiTextRange or {}
ImGuiTextRange.__index = ImGuiTextRange
function ImGuiTextRange.empty(self)
    jit.off(true)
    local out = C.ImGuiTextRange_empty(self)
    return out
end
function ImGuiTextRange.split(self, separator, out)
    jit.off(true)
    local out = C.ImGuiTextRange_split(self, separator, out)
    return out
end
---@return imgui.ImGuiTextRange
M.ImGuiTextRange_Nil = M.ImGuiTextRange_Nil  or function()
    jit.off(true)
    local p = C.ImGuiTextRange_ImGuiTextRange_Nil()
    return ffi.gc(p[0], C.ImGuiTextRange_destroy)
end
---@return imgui.ImGuiTextRange
M.ImGuiTextRange_Str = M.ImGuiTextRange_Str  or function(_b, _e)
    jit.off(true)
    local p = C.ImGuiTextRange_ImGuiTextRange_Str(_b, _e)
    return ffi.gc(p[0], C.ImGuiTextRange_destroy)
end
M.ImGuiTextRange = ImGuiTextRange
ffi.metatype("ImGuiTextRange", ImGuiTextRange)

---@class imgui.ImGuiViewport
local ImGuiViewport = ImGuiViewport or {}
ImGuiViewport.__index = ImGuiViewport
function ImGuiViewport.GetCenter(self)
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.ImGuiViewport_GetCenter(o1, self)
    return o1, out
end
function ImGuiViewport.GetWorkCenter(self)
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.ImGuiViewport_GetWorkCenter(o1, self)
    return o1, out
end
local mt = getmetatable(ImGuiViewport) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiViewport_ImGuiViewport()
    return ffi.gc(p[0], C.ImGuiViewport_destroy)
end
setmetatable(ImGuiViewport, mt)
M.ImGuiViewport = ImGuiViewport
ffi.metatype("ImGuiViewport", ImGuiViewport)

---@class imgui.ImGuiWindowClass
local ImGuiWindowClass = ImGuiWindowClass or {}
ImGuiWindowClass.__index = ImGuiWindowClass
local mt = getmetatable(ImGuiWindowClass) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImGuiWindowClass_ImGuiWindowClass()
    return ffi.gc(p[0], C.ImGuiWindowClass_destroy)
end
setmetatable(ImGuiWindowClass, mt)
M.ImGuiWindowClass = ImGuiWindowClass
ffi.metatype("ImGuiWindowClass", ImGuiWindowClass)

---@class imgui.ImTextureData
local ImTextureData = ImTextureData or {}
ImTextureData.__index = ImTextureData
function ImTextureData.Create(self, format, w, h)
    jit.off(true)
    local out = C.ImTextureData_Create(self, format, w, h)
    return out
end
function ImTextureData.DestroyPixels(self)
    jit.off(true)
    local out = C.ImTextureData_DestroyPixels(self)
    return out
end
function ImTextureData.GetPitch(self)
    jit.off(true)
    local out = C.ImTextureData_GetPitch(self)
    return out
end
function ImTextureData.GetPixels(self)
    jit.off(true)
    local out = C.ImTextureData_GetPixels(self)
    return out
end
function ImTextureData.GetPixelsAt(self, x, y)
    jit.off(true)
    local out = C.ImTextureData_GetPixelsAt(self, x, y)
    return out
end
function ImTextureData.GetSizeInBytes(self)
    jit.off(true)
    local out = C.ImTextureData_GetSizeInBytes(self)
    return out
end
function ImTextureData.GetTexID(self)
    jit.off(true)
    local out = C.ImTextureData_GetTexID(self)
    return out
end
function ImTextureData.GetTexRef(pOut, self)
    jit.off(true)
    local out = C.ImTextureData_GetTexRef(pOut, self)
    return out
end
function ImTextureData.SetStatus(self, status)
    jit.off(true)
    local out = C.ImTextureData_SetStatus(self, status)
    return out
end
function ImTextureData.SetTexID(self, tex_id)
    jit.off(true)
    local out = C.ImTextureData_SetTexID(self, tex_id)
    return out
end
local mt = getmetatable(ImTextureData) or {}
mt.__call = mt.__call or function(self)
    jit.off(true)
    local p = C.ImTextureData_ImTextureData()
    return ffi.gc(p[0], C.ImTextureData_destroy)
end
setmetatable(ImTextureData, mt)
M.ImTextureData = ImTextureData
ffi.metatype("ImTextureData", ImTextureData)

---@class imgui.ImTextureRef
local ImTextureRef = ImTextureRef or {}
ImTextureRef.__index = ImTextureRef
function ImTextureRef.GetTexID(self)
    jit.off(true)
    local out = C.ImTextureRef_GetTexID(self)
    return out
end
---@return imgui.ImTextureRef
M.ImTextureRef_Nil = M.ImTextureRef_Nil  or function()
    jit.off(true)
    local p = C.ImTextureRef_ImTextureRef_Nil()
    return ffi.gc(p[0], C.ImTextureRef_destroy)
end
---@return imgui.ImTextureRef
M.ImTextureRef_TextureID = M.ImTextureRef_TextureID  or function(tex_id)
    jit.off(true)
    local p = C.ImTextureRef_ImTextureRef_TextureID(tex_id)
    return ffi.gc(p[0], C.ImTextureRef_destroy)
end
M.ImTextureRef = ImTextureRef
ffi.metatype("ImTextureRef", ImTextureRef)

---@class imgui.ImVec2
local ImVec2 = ImVec2 or {}
ImVec2.__index = ImVec2
---@return imgui.ImVec2
M.ImVec2_Nil = M.ImVec2_Nil  or function()
    jit.off(true)
    local p = C.ImVec2_ImVec2_Nil()
    return ffi.gc(p[0], C.ImVec2_destroy)
end
---@return imgui.ImVec2
M.ImVec2_Float = M.ImVec2_Float  or function(_x, _y)
    jit.off(true)
    local p = C.ImVec2_ImVec2_Float(_x, _y)
    return ffi.gc(p[0], C.ImVec2_destroy)
end
M.ImVec2 = ImVec2
ffi.metatype("ImVec2", ImVec2)

---@class imgui.ImVec4
local ImVec4 = ImVec4 or {}
ImVec4.__index = ImVec4
---@return imgui.ImVec4
M.ImVec4_Nil = M.ImVec4_Nil  or function()
    jit.off(true)
    local p = C.ImVec4_ImVec4_Nil()
    return ffi.gc(p[0], C.ImVec4_destroy)
end
---@return imgui.ImVec4
M.ImVec4_Float = M.ImVec4_Float  or function(_x, _y, _z, _w)
    jit.off(true)
    local p = C.ImVec4_ImVec4_Float(_x, _y, _z, _w)
    return ffi.gc(p[0], C.ImVec4_destroy)
end
M.ImVec4 = ImVec4
ffi.metatype("ImVec4", ImVec4)

M.ImGuiFreeType_DebugEditFontLoaderFlags = M.ImGuiFreeType_DebugEditFontLoaderFlags  or function(p_font_loader_flags)
    jit.off(true)
    local out = C.ImGuiFreeType_DebugEditFontLoaderFlags(p_font_loader_flags)
    return out
end
M.ImGuiFreeType_GetFontLoader = M.ImGuiFreeType_GetFontLoader  or function()
    jit.off(true)
    local out = C.ImGuiFreeType_GetFontLoader()
    return out
end
M.ImGuiFreeType_SetAllocatorFunctions = M.ImGuiFreeType_SetAllocatorFunctions  or function(alloc_func, free_func, user_data)
    jit.off(true)
    local out = C.ImGuiFreeType_SetAllocatorFunctions(alloc_func, free_func, user_data)
    return out
end
M.AcceptDragDropPayload = M.AcceptDragDropPayload  or function(type, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igAcceptDragDropPayload(type, flags)
    return out
end
M.AlignTextToFramePadding = M.AlignTextToFramePadding  or function()
    jit.off(true)
    local out = C.igAlignTextToFramePadding()
    return out
end
M.ArrowButton = M.ArrowButton  or function(str_id, dir)
    jit.off(true)
    local out = C.igArrowButton(str_id, dir)
    return out
end
M.Begin = M.Begin  or function(name, p_open, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBegin(name, p_open, flags)
    return out
end
M.BeginChild_Str = M.BeginChild_Str  or function(str_id, size, child_flags, window_flags)
    jit.off(true)
    if size == nil then size = M.ImVec2_Float(0, 0) end
    if child_flags == nil then child_flags = 0 end
    if window_flags == nil then window_flags = 0 end
    local out = C.igBeginChild_Str(str_id, size, child_flags, window_flags)
    return out
end
M.BeginChild_ID = M.BeginChild_ID  or function(id, size, child_flags, window_flags)
    jit.off(true)
    if size == nil then size = M.ImVec2_Float(0, 0) end
    if child_flags == nil then child_flags = 0 end
    if window_flags == nil then window_flags = 0 end
    local out = C.igBeginChild_ID(id, size, child_flags, window_flags)
    return out
end
M.BeginCombo = M.BeginCombo  or function(label, preview_value, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBeginCombo(label, preview_value, flags)
    return out
end
M.BeginDisabled = M.BeginDisabled  or function(disabled)
    jit.off(true)
    if disabled == nil then disabled = true end
    local out = C.igBeginDisabled(disabled)
    return out
end
M.BeginDragDropSource = M.BeginDragDropSource  or function(flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBeginDragDropSource(flags)
    return out
end
M.BeginDragDropTarget = M.BeginDragDropTarget  or function()
    jit.off(true)
    local out = C.igBeginDragDropTarget()
    return out
end
M.BeginGroup = M.BeginGroup  or function()
    jit.off(true)
    local out = C.igBeginGroup()
    return out
end
M.BeginItemTooltip = M.BeginItemTooltip  or function()
    jit.off(true)
    local out = C.igBeginItemTooltip()
    return out
end
M.BeginListBox = M.BeginListBox  or function(label, size)
    jit.off(true)
    if size == nil then size = M.ImVec2_Float(0, 0) end
    local out = C.igBeginListBox(label, size)
    return out
end
M.BeginMainMenuBar = M.BeginMainMenuBar  or function()
    jit.off(true)
    local out = C.igBeginMainMenuBar()
    return out
end
M.BeginMenu = M.BeginMenu  or function(label, enabled)
    jit.off(true)
    if enabled == nil then enabled = true end
    local out = C.igBeginMenu(label, enabled)
    return out
end
M.BeginMenuBar = M.BeginMenuBar  or function()
    jit.off(true)
    local out = C.igBeginMenuBar()
    return out
end
M.BeginMultiSelect = M.BeginMultiSelect  or function(flags, selection_size, items_count)
    jit.off(true)
    if selection_size == nil then selection_size = -1 end
    if items_count == nil then items_count = -1 end
    local out = C.igBeginMultiSelect(flags, selection_size, items_count)
    return out
end
M.BeginPopup = M.BeginPopup  or function(str_id, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBeginPopup(str_id, flags)
    return out
end
M.BeginPopupContextItem = M.BeginPopupContextItem  or function(str_id, popup_flags)
    jit.off(true)
    if popup_flags == nil then popup_flags = 1 end
    local out = C.igBeginPopupContextItem(str_id, popup_flags)
    return out
end
M.BeginPopupContextVoid = M.BeginPopupContextVoid  or function(str_id, popup_flags)
    jit.off(true)
    if popup_flags == nil then popup_flags = 1 end
    local out = C.igBeginPopupContextVoid(str_id, popup_flags)
    return out
end
M.BeginPopupContextWindow = M.BeginPopupContextWindow  or function(str_id, popup_flags)
    jit.off(true)
    if popup_flags == nil then popup_flags = 1 end
    local out = C.igBeginPopupContextWindow(str_id, popup_flags)
    return out
end
M.BeginPopupModal = M.BeginPopupModal  or function(name, p_open, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBeginPopupModal(name, p_open, flags)
    return out
end
M.BeginTabBar = M.BeginTabBar  or function(str_id, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBeginTabBar(str_id, flags)
    return out
end
M.BeginTabItem = M.BeginTabItem  or function(label, p_open, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igBeginTabItem(label, p_open, flags)
    return out
end
M.BeginTable = M.BeginTable  or function(str_id, columns, flags, outer_size, inner_width)
    jit.off(true)
    if flags == nil then flags = 0 end
    if outer_size == nil then outer_size = M.ImVec2_Float(0.0, 0.0) end
    if inner_width == nil then inner_width = 0.0 end
    local out = C.igBeginTable(str_id, columns, flags, outer_size, inner_width)
    return out
end
M.BeginTooltip = M.BeginTooltip  or function()
    jit.off(true)
    local out = C.igBeginTooltip()
    return out
end
M.Bullet = M.Bullet  or function()
    jit.off(true)
    local out = C.igBullet()
    return out
end
M.BulletText = M.BulletText  or function(fmt, ...)
    jit.off(true)
    local out = C.igBulletText(fmt, ...)
    return out
end
M.Button = M.Button  or function(label, size)
    jit.off(true)
    if size == nil then size = M.ImVec2_Float(0, 0) end
    local out = C.igButton(label, size)
    return out
end
M.CalcItemWidth = M.CalcItemWidth  or function()
    jit.off(true)
    local out = C.igCalcItemWidth()
    return out
end
M.CalcTextSize = M.CalcTextSize  or function(text, text_end, hide_text_after_double_hash, wrap_width)
    jit.off(true)
    if hide_text_after_double_hash == nil then hide_text_after_double_hash = false end
    if wrap_width == nil then wrap_width = -1.0 end
    local o1 = M.ImVec2_Nil()
    local out = C.igCalcTextSize(o1, text, text_end, hide_text_after_double_hash, wrap_width)
    return o1, out
end
M.Checkbox = M.Checkbox  or function(label, v)
    jit.off(true)
    local out = C.igCheckbox(label, v)
    return out
end
M.CheckboxFlags_IntPtr = M.CheckboxFlags_IntPtr  or function(label, flags, flags_value)
    jit.off(true)
    local out = C.igCheckboxFlags_IntPtr(label, flags, flags_value)
    return out
end
M.CheckboxFlags_UintPtr = M.CheckboxFlags_UintPtr  or function(label, flags, flags_value)
    jit.off(true)
    local out = C.igCheckboxFlags_UintPtr(label, flags, flags_value)
    return out
end
M.CloseCurrentPopup = M.CloseCurrentPopup  or function()
    jit.off(true)
    local out = C.igCloseCurrentPopup()
    return out
end
M.CollapsingHeader_TreeNodeFlags = M.CollapsingHeader_TreeNodeFlags  or function(label, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igCollapsingHeader_TreeNodeFlags(label, flags)
    return out
end
M.CollapsingHeader_BoolPtr = M.CollapsingHeader_BoolPtr  or function(label, p_visible, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igCollapsingHeader_BoolPtr(label, p_visible, flags)
    return out
end
M.ColorButton = M.ColorButton  or function(desc_id, col, flags, size)
    jit.off(true)
    if flags == nil then flags = 0 end
    if size == nil then size = M.ImVec2_Float(0, 0) end
    local out = C.igColorButton(desc_id, col, flags, size)
    return out
end
M.ColorConvertFloat4ToU32 = M.ColorConvertFloat4ToU32  or function(c_in)
    jit.off(true)
    local out = C.igColorConvertFloat4ToU32(c_in)
    return out
end
M.ColorConvertHSVtoRGB = M.ColorConvertHSVtoRGB  or function(h, s, v)
    jit.off(true)
    local o1 = ffi.new("float[1]")
    local o2 = ffi.new("float[1]")
    local o3 = ffi.new("float[1]")
    local out = C.igColorConvertHSVtoRGB(h, s, v, o1, o2, o3)
    return o1[0], o2[0], o3[0], out
end
M.ColorConvertRGBtoHSV = M.ColorConvertRGBtoHSV  or function(r, g, b)
    jit.off(true)
    local o1 = ffi.new("float[1]")
    local o2 = ffi.new("float[1]")
    local o3 = ffi.new("float[1]")
    local out = C.igColorConvertRGBtoHSV(r, g, b, o1, o2, o3)
    return o1[0], o2[0], o3[0], out
end
M.ColorConvertU32ToFloat4 = M.ColorConvertU32ToFloat4  or function(c_in)
    jit.off(true)
    local o1 = M.ImVec4_Nil()
    local out = C.igColorConvertU32ToFloat4(o1, c_in)
    return o1, out
end
M.ColorEdit3 = M.ColorEdit3  or function(label, col, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igColorEdit3(label, col, flags)
    return out
end
M.ColorEdit4 = M.ColorEdit4  or function(label, col, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igColorEdit4(label, col, flags)
    return out
end
M.ColorPicker3 = M.ColorPicker3  or function(label, col, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igColorPicker3(label, col, flags)
    return out
end
M.ColorPicker4 = M.ColorPicker4  or function(label, col, flags, ref_col)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igColorPicker4(label, col, flags, ref_col)
    return out
end
M.Columns = M.Columns  or function(count, id, borders)
    jit.off(true)
    if count == nil then count = 1 end
    if borders == nil then borders = true end
    local out = C.igColumns(count, id, borders)
    return out
end
M.Combo_Str_arr = M.Combo_Str_arr  or function(label, current_item, items, items_count, popup_max_height_in_items)
    jit.off(true)
    if popup_max_height_in_items == nil then popup_max_height_in_items = -1 end
    local out = C.igCombo_Str_arr(label, current_item, items, items_count, popup_max_height_in_items)
    return out
end
M.Combo_Str = M.Combo_Str  or function(label, current_item, items_separated_by_zeros, popup_max_height_in_items)
    jit.off(true)
    if popup_max_height_in_items == nil then popup_max_height_in_items = -1 end
    local out = C.igCombo_Str(label, current_item, items_separated_by_zeros, popup_max_height_in_items)
    return out
end
M.Combo_FnStrPtr = M.Combo_FnStrPtr  or function(label, current_item, getter, user_data, items_count, popup_max_height_in_items)
    jit.off(true)
    if popup_max_height_in_items == nil then popup_max_height_in_items = -1 end
    local out = C.igCombo_FnStrPtr(label, current_item, getter, user_data, items_count, popup_max_height_in_items)
    return out
end
M.CreateContext = M.CreateContext  or function(shared_font_atlas)
    jit.off(true)
    local out = C.igCreateContext(shared_font_atlas)
    return out
end
M.DebugCheckVersionAndDataLayout = M.DebugCheckVersionAndDataLayout  or function(version_str, sz_io, sz_style, sz_vec2, sz_vec4, sz_drawvert, sz_drawidx)
    jit.off(true)
    local out = C.igDebugCheckVersionAndDataLayout(version_str, sz_io, sz_style, sz_vec2, sz_vec4, sz_drawvert, sz_drawidx)
    return out
end
M.DebugFlashStyleColor = M.DebugFlashStyleColor  or function(idx)
    jit.off(true)
    local out = C.igDebugFlashStyleColor(idx)
    return out
end
M.DebugLog = M.DebugLog  or function(fmt, ...)
    jit.off(true)
    local out = C.igDebugLog(fmt, ...)
    return out
end
M.DebugStartItemPicker = M.DebugStartItemPicker  or function()
    jit.off(true)
    local out = C.igDebugStartItemPicker()
    return out
end
M.DebugTextEncoding = M.DebugTextEncoding  or function(text)
    jit.off(true)
    local out = C.igDebugTextEncoding(text)
    return out
end
M.DestroyContext = M.DestroyContext  or function(ctx)
    jit.off(true)
    local out = C.igDestroyContext(ctx)
    return out
end
M.DestroyPlatformWindows = M.DestroyPlatformWindows  or function()
    jit.off(true)
    local out = C.igDestroyPlatformWindows()
    return out
end
M.DockSpace = M.DockSpace  or function(dockspace_id, size, flags, window_class)
    jit.off(true)
    if size == nil then size = M.ImVec2_Float(0, 0) end
    if flags == nil then flags = 0 end
    local out = C.igDockSpace(dockspace_id, size, flags, window_class)
    return out
end
M.DockSpaceOverViewport = M.DockSpaceOverViewport  or function(dockspace_id, viewport, flags, window_class)
    jit.off(true)
    if dockspace_id == nil then dockspace_id = 0 end
    if flags == nil then flags = 0 end
    local out = C.igDockSpaceOverViewport(dockspace_id, viewport, flags, window_class)
    return out
end
M.DragFloat = M.DragFloat  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0.0 end
    if v_max == nil then v_max = 0.0 end
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igDragFloat(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragFloat2 = M.DragFloat2  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0.0 end
    if v_max == nil then v_max = 0.0 end
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igDragFloat2(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragFloat3 = M.DragFloat3  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0.0 end
    if v_max == nil then v_max = 0.0 end
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igDragFloat3(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragFloat4 = M.DragFloat4  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0.0 end
    if v_max == nil then v_max = 0.0 end
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igDragFloat4(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragFloatRange2 = M.DragFloatRange2  or function(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0.0 end
    if v_max == nil then v_max = 0.0 end
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igDragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags)
    return out
end
M.DragInt = M.DragInt  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0 end
    if v_max == nil then v_max = 0 end
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igDragInt(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragInt2 = M.DragInt2  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0 end
    if v_max == nil then v_max = 0 end
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igDragInt2(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragInt3 = M.DragInt3  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0 end
    if v_max == nil then v_max = 0 end
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igDragInt3(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragInt4 = M.DragInt4  or function(label, v, v_speed, v_min, v_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0 end
    if v_max == nil then v_max = 0 end
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igDragInt4(label, v, v_speed, v_min, v_max, format, flags)
    return out
end
M.DragIntRange2 = M.DragIntRange2  or function(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if v_min == nil then v_min = 0 end
    if v_max == nil then v_max = 0 end
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igDragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags)
    return out
end
M.DragScalar = M.DragScalar  or function(label, data_type, p_data, v_speed, p_min, p_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if flags == nil then flags = 0 end
    local out = C.igDragScalar(label, data_type, p_data, v_speed, p_min, p_max, format, flags)
    return out
end
M.DragScalarN = M.DragScalarN  or function(label, data_type, p_data, components, v_speed, p_min, p_max, format, flags)
    jit.off(true)
    if v_speed == nil then v_speed = 1.0 end
    if flags == nil then flags = 0 end
    local out = C.igDragScalarN(label, data_type, p_data, components, v_speed, p_min, p_max, format, flags)
    return out
end
M.Dummy = M.Dummy  or function(size)
    jit.off(true)
    local out = C.igDummy(size)
    return out
end
M.End = M.End  or function()
    jit.off(true)
    local out = C.igEnd()
    return out
end
M.EndChild = M.EndChild  or function()
    jit.off(true)
    local out = C.igEndChild()
    return out
end
M.EndCombo = M.EndCombo  or function()
    jit.off(true)
    local out = C.igEndCombo()
    return out
end
M.EndDisabled = M.EndDisabled  or function()
    jit.off(true)
    local out = C.igEndDisabled()
    return out
end
M.EndDragDropSource = M.EndDragDropSource  or function()
    jit.off(true)
    local out = C.igEndDragDropSource()
    return out
end
M.EndDragDropTarget = M.EndDragDropTarget  or function()
    jit.off(true)
    local out = C.igEndDragDropTarget()
    return out
end
M.EndFrame = M.EndFrame  or function()
    jit.off(true)
    local out = C.igEndFrame()
    return out
end
M.EndGroup = M.EndGroup  or function()
    jit.off(true)
    local out = C.igEndGroup()
    return out
end
M.EndListBox = M.EndListBox  or function()
    jit.off(true)
    local out = C.igEndListBox()
    return out
end
M.EndMainMenuBar = M.EndMainMenuBar  or function()
    jit.off(true)
    local out = C.igEndMainMenuBar()
    return out
end
M.EndMenu = M.EndMenu  or function()
    jit.off(true)
    local out = C.igEndMenu()
    return out
end
M.EndMenuBar = M.EndMenuBar  or function()
    jit.off(true)
    local out = C.igEndMenuBar()
    return out
end
M.EndMultiSelect = M.EndMultiSelect  or function()
    jit.off(true)
    local out = C.igEndMultiSelect()
    return out
end
M.EndPopup = M.EndPopup  or function()
    jit.off(true)
    local out = C.igEndPopup()
    return out
end
M.EndTabBar = M.EndTabBar  or function()
    jit.off(true)
    local out = C.igEndTabBar()
    return out
end
M.EndTabItem = M.EndTabItem  or function()
    jit.off(true)
    local out = C.igEndTabItem()
    return out
end
M.EndTable = M.EndTable  or function()
    jit.off(true)
    local out = C.igEndTable()
    return out
end
M.EndTooltip = M.EndTooltip  or function()
    jit.off(true)
    local out = C.igEndTooltip()
    return out
end
M.FindViewportByID = M.FindViewportByID  or function(id)
    jit.off(true)
    local out = C.igFindViewportByID(id)
    return out
end
M.FindViewportByPlatformHandle = M.FindViewportByPlatformHandle  or function(platform_handle)
    jit.off(true)
    local out = C.igFindViewportByPlatformHandle(platform_handle)
    return out
end
M.GetAllocatorFunctions = M.GetAllocatorFunctions  or function(p_alloc_func, p_free_func, p_user_data)
    jit.off(true)
    local out = C.igGetAllocatorFunctions(p_alloc_func, p_free_func, p_user_data)
    return out
end
M.GetBackgroundDrawList = M.GetBackgroundDrawList  or function(viewport)
    jit.off(true)
    local out = C.igGetBackgroundDrawList(viewport)
    return out
end
M.GetClipboardText = M.GetClipboardText  or function()
    jit.off(true)
    local out = C.igGetClipboardText()
    return out
end
M.GetColorU32_Col = M.GetColorU32_Col  or function(idx, alpha_mul)
    jit.off(true)
    if alpha_mul == nil then alpha_mul = 1.0 end
    local out = C.igGetColorU32_Col(idx, alpha_mul)
    return out
end
M.GetColorU32_Vec4 = M.GetColorU32_Vec4  or function(col)
    jit.off(true)
    local out = C.igGetColorU32_Vec4(col)
    return out
end
M.GetColorU32_U32 = M.GetColorU32_U32  or function(col, alpha_mul)
    jit.off(true)
    if alpha_mul == nil then alpha_mul = 1.0 end
    local out = C.igGetColorU32_U32(col, alpha_mul)
    return out
end
M.GetColumnIndex = M.GetColumnIndex  or function()
    jit.off(true)
    local out = C.igGetColumnIndex()
    return out
end
M.GetColumnOffset = M.GetColumnOffset  or function(column_index)
    jit.off(true)
    if column_index == nil then column_index = -1 end
    local out = C.igGetColumnOffset(column_index)
    return out
end
M.GetColumnWidth = M.GetColumnWidth  or function(column_index)
    jit.off(true)
    if column_index == nil then column_index = -1 end
    local out = C.igGetColumnWidth(column_index)
    return out
end
M.GetColumnsCount = M.GetColumnsCount  or function()
    jit.off(true)
    local out = C.igGetColumnsCount()
    return out
end
M.GetContentRegionAvail = M.GetContentRegionAvail  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetContentRegionAvail(o1)
    return o1, out
end
M.GetCurrentContext = M.GetCurrentContext  or function()
    jit.off(true)
    local out = C.igGetCurrentContext()
    return out
end
M.GetCursorPos = M.GetCursorPos  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetCursorPos(o1)
    return o1, out
end
M.GetCursorPosX = M.GetCursorPosX  or function()
    jit.off(true)
    local out = C.igGetCursorPosX()
    return out
end
M.GetCursorPosY = M.GetCursorPosY  or function()
    jit.off(true)
    local out = C.igGetCursorPosY()
    return out
end
M.GetCursorScreenPos = M.GetCursorScreenPos  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetCursorScreenPos(o1)
    return o1, out
end
M.GetCursorStartPos = M.GetCursorStartPos  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetCursorStartPos(o1)
    return o1, out
end
M.GetDragDropPayload = M.GetDragDropPayload  or function()
    jit.off(true)
    local out = C.igGetDragDropPayload()
    return out
end
M.GetDrawData = M.GetDrawData  or function()
    jit.off(true)
    local out = C.igGetDrawData()
    return out
end
M.GetDrawListSharedData = M.GetDrawListSharedData  or function()
    jit.off(true)
    local out = C.igGetDrawListSharedData()
    return out
end
M.GetFont = M.GetFont  or function()
    jit.off(true)
    local out = C.igGetFont()
    return out
end
M.GetFontBaked = M.GetFontBaked  or function()
    jit.off(true)
    local out = C.igGetFontBaked()
    return out
end
M.GetFontSize = M.GetFontSize  or function()
    jit.off(true)
    local out = C.igGetFontSize()
    return out
end
M.GetFontTexUvWhitePixel = M.GetFontTexUvWhitePixel  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetFontTexUvWhitePixel(o1)
    return o1, out
end
M.GetForegroundDrawList = M.GetForegroundDrawList  or function(viewport)
    jit.off(true)
    local out = C.igGetForegroundDrawList(viewport)
    return out
end
M.GetFrameCount = M.GetFrameCount  or function()
    jit.off(true)
    local out = C.igGetFrameCount()
    return out
end
M.GetFrameHeight = M.GetFrameHeight  or function()
    jit.off(true)
    local out = C.igGetFrameHeight()
    return out
end
M.GetFrameHeightWithSpacing = M.GetFrameHeightWithSpacing  or function()
    jit.off(true)
    local out = C.igGetFrameHeightWithSpacing()
    return out
end
M.GetID_Str = M.GetID_Str  or function(str_id)
    jit.off(true)
    local out = C.igGetID_Str(str_id)
    return out
end
M.GetID_StrStr = M.GetID_StrStr  or function(str_id_begin, str_id_end)
    jit.off(true)
    local out = C.igGetID_StrStr(str_id_begin, str_id_end)
    return out
end
M.GetID_Ptr = M.GetID_Ptr  or function(ptr_id)
    jit.off(true)
    local out = C.igGetID_Ptr(ptr_id)
    return out
end
M.GetID_Int = M.GetID_Int  or function(int_id)
    jit.off(true)
    local out = C.igGetID_Int(int_id)
    return out
end
M.GetIO = M.GetIO  or function()
    jit.off(true)
    local out = C.igGetIO()
    return out
end
M.GetItemID = M.GetItemID  or function()
    jit.off(true)
    local out = C.igGetItemID()
    return out
end
M.GetItemRectMax = M.GetItemRectMax  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetItemRectMax(o1)
    return o1, out
end
M.GetItemRectMin = M.GetItemRectMin  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetItemRectMin(o1)
    return o1, out
end
M.GetItemRectSize = M.GetItemRectSize  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetItemRectSize(o1)
    return o1, out
end
M.GetKeyName = M.GetKeyName  or function(key)
    jit.off(true)
    local out = C.igGetKeyName(key)
    return out
end
M.GetKeyPressedAmount = M.GetKeyPressedAmount  or function(key, repeat_delay, rate)
    jit.off(true)
    local out = C.igGetKeyPressedAmount(key, repeat_delay, rate)
    return out
end
M.GetMainViewport = M.GetMainViewport  or function()
    jit.off(true)
    local out = C.igGetMainViewport()
    return out
end
M.GetMouseClickedCount = M.GetMouseClickedCount  or function(button)
    jit.off(true)
    local out = C.igGetMouseClickedCount(button)
    return out
end
M.GetMouseCursor = M.GetMouseCursor  or function()
    jit.off(true)
    local out = C.igGetMouseCursor()
    return out
end
M.GetMouseDragDelta = M.GetMouseDragDelta  or function(button, lock_threshold)
    jit.off(true)
    if button == nil then button = 0 end
    if lock_threshold == nil then lock_threshold = -1.0 end
    local o1 = M.ImVec2_Nil()
    local out = C.igGetMouseDragDelta(o1, button, lock_threshold)
    return o1, out
end
M.GetMousePos = M.GetMousePos  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetMousePos(o1)
    return o1, out
end
M.GetMousePosOnOpeningCurrentPopup = M.GetMousePosOnOpeningCurrentPopup  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetMousePosOnOpeningCurrentPopup(o1)
    return o1, out
end
M.GetPlatformIO = M.GetPlatformIO  or function()
    jit.off(true)
    local out = C.igGetPlatformIO()
    return out
end
M.GetScrollMaxX = M.GetScrollMaxX  or function()
    jit.off(true)
    local out = C.igGetScrollMaxX()
    return out
end
M.GetScrollMaxY = M.GetScrollMaxY  or function()
    jit.off(true)
    local out = C.igGetScrollMaxY()
    return out
end
M.GetScrollX = M.GetScrollX  or function()
    jit.off(true)
    local out = C.igGetScrollX()
    return out
end
M.GetScrollY = M.GetScrollY  or function()
    jit.off(true)
    local out = C.igGetScrollY()
    return out
end
M.GetStateStorage = M.GetStateStorage  or function()
    jit.off(true)
    local out = C.igGetStateStorage()
    return out
end
M.GetStyle = M.GetStyle  or function()
    jit.off(true)
    local out = C.igGetStyle()
    return out
end
M.GetStyleColorName = M.GetStyleColorName  or function(idx)
    jit.off(true)
    local out = C.igGetStyleColorName(idx)
    return out
end
M.GetStyleColorVec4 = M.GetStyleColorVec4  or function(idx)
    jit.off(true)
    local out = C.igGetStyleColorVec4(idx)
    return out
end
M.GetTextLineHeight = M.GetTextLineHeight  or function()
    jit.off(true)
    local out = C.igGetTextLineHeight()
    return out
end
M.GetTextLineHeightWithSpacing = M.GetTextLineHeightWithSpacing  or function()
    jit.off(true)
    local out = C.igGetTextLineHeightWithSpacing()
    return out
end
M.GetTime = M.GetTime  or function()
    jit.off(true)
    local out = C.igGetTime()
    return out
end
M.GetTreeNodeToLabelSpacing = M.GetTreeNodeToLabelSpacing  or function()
    jit.off(true)
    local out = C.igGetTreeNodeToLabelSpacing()
    return out
end
M.GetVersion = M.GetVersion  or function()
    jit.off(true)
    local out = C.igGetVersion()
    return out
end
M.GetWindowDockID = M.GetWindowDockID  or function()
    jit.off(true)
    local out = C.igGetWindowDockID()
    return out
end
M.GetWindowDpiScale = M.GetWindowDpiScale  or function()
    jit.off(true)
    local out = C.igGetWindowDpiScale()
    return out
end
M.GetWindowDrawList = M.GetWindowDrawList  or function()
    jit.off(true)
    local out = C.igGetWindowDrawList()
    return out
end
M.GetWindowHeight = M.GetWindowHeight  or function()
    jit.off(true)
    local out = C.igGetWindowHeight()
    return out
end
M.GetWindowPos = M.GetWindowPos  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetWindowPos(o1)
    return o1, out
end
M.GetWindowSize = M.GetWindowSize  or function()
    jit.off(true)
    local o1 = M.ImVec2_Nil()
    local out = C.igGetWindowSize(o1)
    return o1, out
end
M.GetWindowViewport = M.GetWindowViewport  or function()
    jit.off(true)
    local out = C.igGetWindowViewport()
    return out
end
M.GetWindowWidth = M.GetWindowWidth  or function()
    jit.off(true)
    local out = C.igGetWindowWidth()
    return out
end
M.Image = M.Image  or function(tex_ref, image_size, uv0, uv1)
    jit.off(true)
    if uv0 == nil then uv0 = M.ImVec2_Float(0, 0) end
    if uv1 == nil then uv1 = M.ImVec2_Float(1, 1) end
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.igImage(tex_ref, image_size, uv0, uv1)
    return out
end
M.ImageButton = M.ImageButton  or function(str_id, tex_ref, image_size, uv0, uv1, bg_col, tint_col)
    jit.off(true)
    if uv0 == nil then uv0 = M.ImVec2_Float(0, 0) end
    if uv1 == nil then uv1 = M.ImVec2_Float(1, 1) end
    if bg_col == nil then bg_col = M.ImVec4_Float(0, 0, 0, 0) end
    if tint_col == nil then tint_col = M.ImVec4_Float(1, 1, 1, 1) end
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.igImageButton(str_id, tex_ref, image_size, uv0, uv1, bg_col, tint_col)
    return out
end
M.ImageWithBg = M.ImageWithBg  or function(tex_ref, image_size, uv0, uv1, bg_col, tint_col)
    jit.off(true)
    if uv0 == nil then uv0 = M.ImVec2_Float(0, 0) end
    if uv1 == nil then uv1 = M.ImVec2_Float(1, 1) end
    if bg_col == nil then bg_col = M.ImVec4_Float(0, 0, 0, 0) end
    if tint_col == nil then tint_col = M.ImVec4_Float(1, 1, 1, 1) end
    if not ffi.istype("ImTextureRef", tex_ref) then
        tex_ref = M.love.TextureRef(tex_ref)
    end
    local out = C.igImageWithBg(tex_ref, image_size, uv0, uv1, bg_col, tint_col)
    return out
end
M.Indent = M.Indent  or function(indent_w)
    jit.off(true)
    if indent_w == nil then indent_w = 0.0 end
    local out = C.igIndent(indent_w)
    return out
end
M.InputDouble = M.InputDouble  or function(label, v, step, step_fast, format, flags)
    jit.off(true)
    if step == nil then step = 0.0 end
    if step_fast == nil then step_fast = 0.0 end
    if format == nil then format = "%.6f" end
    if flags == nil then flags = 0 end
    local out = C.igInputDouble(label, v, step, step_fast, format, flags)
    return out
end
M.InputFloat = M.InputFloat  or function(label, v, step, step_fast, format, flags)
    jit.off(true)
    if step == nil then step = 0.0 end
    if step_fast == nil then step_fast = 0.0 end
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igInputFloat(label, v, step, step_fast, format, flags)
    return out
end
M.InputFloat2 = M.InputFloat2  or function(label, v, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igInputFloat2(label, v, format, flags)
    return out
end
M.InputFloat3 = M.InputFloat3  or function(label, v, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igInputFloat3(label, v, format, flags)
    return out
end
M.InputFloat4 = M.InputFloat4  or function(label, v, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igInputFloat4(label, v, format, flags)
    return out
end
M.InputInt = M.InputInt  or function(label, v, step, step_fast, flags)
    jit.off(true)
    if step == nil then step = 1 end
    if step_fast == nil then step_fast = 100 end
    if flags == nil then flags = 0 end
    local out = C.igInputInt(label, v, step, step_fast, flags)
    return out
end
M.InputInt2 = M.InputInt2  or function(label, v, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputInt2(label, v, flags)
    return out
end
M.InputInt3 = M.InputInt3  or function(label, v, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputInt3(label, v, flags)
    return out
end
M.InputInt4 = M.InputInt4  or function(label, v, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputInt4(label, v, flags)
    return out
end
M.InputScalar = M.InputScalar  or function(label, data_type, p_data, p_step, p_step_fast, format, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputScalar(label, data_type, p_data, p_step, p_step_fast, format, flags)
    return out
end
M.InputScalarN = M.InputScalarN  or function(label, data_type, p_data, components, p_step, p_step_fast, format, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputScalarN(label, data_type, p_data, components, p_step, p_step_fast, format, flags)
    return out
end
M.InputText = M.InputText  or function(label, buf, buf_size, flags, callback, user_data)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputText(label, buf, buf_size, flags, callback, user_data)
    return out
end
M.InputTextMultiline = M.InputTextMultiline  or function(label, buf, buf_size, size, flags, callback, user_data)
    jit.off(true)
    if size == nil then size = M.ImVec2_Float(0, 0) end
    if flags == nil then flags = 0 end
    local out = C.igInputTextMultiline(label, buf, buf_size, size, flags, callback, user_data)
    return out
end
M.InputTextWithHint = M.InputTextWithHint  or function(label, hint, buf, buf_size, flags, callback, user_data)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInputTextWithHint(label, hint, buf, buf_size, flags, callback, user_data)
    return out
end
M.InvisibleButton = M.InvisibleButton  or function(str_id, size, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igInvisibleButton(str_id, size, flags)
    return out
end
M.IsAnyItemActive = M.IsAnyItemActive  or function()
    jit.off(true)
    local out = C.igIsAnyItemActive()
    return out
end
M.IsAnyItemFocused = M.IsAnyItemFocused  or function()
    jit.off(true)
    local out = C.igIsAnyItemFocused()
    return out
end
M.IsAnyItemHovered = M.IsAnyItemHovered  or function()
    jit.off(true)
    local out = C.igIsAnyItemHovered()
    return out
end
M.IsAnyMouseDown = M.IsAnyMouseDown  or function()
    jit.off(true)
    local out = C.igIsAnyMouseDown()
    return out
end
M.IsItemActivated = M.IsItemActivated  or function()
    jit.off(true)
    local out = C.igIsItemActivated()
    return out
end
M.IsItemActive = M.IsItemActive  or function()
    jit.off(true)
    local out = C.igIsItemActive()
    return out
end
M.IsItemClicked = M.IsItemClicked  or function(mouse_button)
    jit.off(true)
    if mouse_button == nil then mouse_button = 0 end
    local out = C.igIsItemClicked(mouse_button)
    return out
end
M.IsItemDeactivated = M.IsItemDeactivated  or function()
    jit.off(true)
    local out = C.igIsItemDeactivated()
    return out
end
M.IsItemDeactivatedAfterEdit = M.IsItemDeactivatedAfterEdit  or function()
    jit.off(true)
    local out = C.igIsItemDeactivatedAfterEdit()
    return out
end
M.IsItemEdited = M.IsItemEdited  or function()
    jit.off(true)
    local out = C.igIsItemEdited()
    return out
end
M.IsItemFocused = M.IsItemFocused  or function()
    jit.off(true)
    local out = C.igIsItemFocused()
    return out
end
M.IsItemHovered = M.IsItemHovered  or function(flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igIsItemHovered(flags)
    return out
end
M.IsItemToggledOpen = M.IsItemToggledOpen  or function()
    jit.off(true)
    local out = C.igIsItemToggledOpen()
    return out
end
M.IsItemToggledSelection = M.IsItemToggledSelection  or function()
    jit.off(true)
    local out = C.igIsItemToggledSelection()
    return out
end
M.IsItemVisible = M.IsItemVisible  or function()
    jit.off(true)
    local out = C.igIsItemVisible()
    return out
end
M.IsKeyChordPressed = M.IsKeyChordPressed  or function(key_chord)
    jit.off(true)
    local out = C.igIsKeyChordPressed(key_chord)
    return out
end
M.IsKeyDown = M.IsKeyDown  or function(key)
    jit.off(true)
    local out = C.igIsKeyDown(key)
    return out
end
M.IsKeyPressed = M.IsKeyPressed  or function(key, c_repeat)
    jit.off(true)
    if c_repeat == nil then c_repeat = true end
    local out = C.igIsKeyPressed(key, c_repeat)
    return out
end
M.IsKeyReleased = M.IsKeyReleased  or function(key)
    jit.off(true)
    local out = C.igIsKeyReleased(key)
    return out
end
M.IsMouseClicked = M.IsMouseClicked  or function(button, c_repeat)
    jit.off(true)
    if c_repeat == nil then c_repeat = false end
    local out = C.igIsMouseClicked(button, c_repeat)
    return out
end
M.IsMouseDoubleClicked = M.IsMouseDoubleClicked  or function(button)
    jit.off(true)
    local out = C.igIsMouseDoubleClicked(button)
    return out
end
M.IsMouseDown = M.IsMouseDown  or function(button)
    jit.off(true)
    local out = C.igIsMouseDown(button)
    return out
end
M.IsMouseDragging = M.IsMouseDragging  or function(button, lock_threshold)
    jit.off(true)
    if lock_threshold == nil then lock_threshold = -1.0 end
    local out = C.igIsMouseDragging(button, lock_threshold)
    return out
end
M.IsMouseHoveringRect = M.IsMouseHoveringRect  or function(r_min, r_max, clip)
    jit.off(true)
    if clip == nil then clip = true end
    local out = C.igIsMouseHoveringRect(r_min, r_max, clip)
    return out
end
M.IsMousePosValid = M.IsMousePosValid  or function(mouse_pos)
    jit.off(true)
    local out = C.igIsMousePosValid(mouse_pos)
    return out
end
M.IsMouseReleased = M.IsMouseReleased  or function(button)
    jit.off(true)
    local out = C.igIsMouseReleased(button)
    return out
end
M.IsMouseReleasedWithDelay = M.IsMouseReleasedWithDelay  or function(button, delay)
    jit.off(true)
    local out = C.igIsMouseReleasedWithDelay(button, delay)
    return out
end
M.IsPopupOpen = M.IsPopupOpen  or function(str_id, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igIsPopupOpen(str_id, flags)
    return out
end
M.IsRectVisible_Nil = M.IsRectVisible_Nil  or function(size)
    jit.off(true)
    local out = C.igIsRectVisible_Nil(size)
    return out
end
M.IsRectVisible_Vec2 = M.IsRectVisible_Vec2  or function(rect_min, rect_max)
    jit.off(true)
    local out = C.igIsRectVisible_Vec2(rect_min, rect_max)
    return out
end
M.IsWindowAppearing = M.IsWindowAppearing  or function()
    jit.off(true)
    local out = C.igIsWindowAppearing()
    return out
end
M.IsWindowCollapsed = M.IsWindowCollapsed  or function()
    jit.off(true)
    local out = C.igIsWindowCollapsed()
    return out
end
M.IsWindowDocked = M.IsWindowDocked  or function()
    jit.off(true)
    local out = C.igIsWindowDocked()
    return out
end
M.IsWindowFocused = M.IsWindowFocused  or function(flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igIsWindowFocused(flags)
    return out
end
M.IsWindowHovered = M.IsWindowHovered  or function(flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igIsWindowHovered(flags)
    return out
end
M.LabelText = M.LabelText  or function(label, fmt, ...)
    jit.off(true)
    local out = C.igLabelText(label, fmt, ...)
    return out
end
M.ListBox_Str_arr = M.ListBox_Str_arr  or function(label, current_item, items, items_count, height_in_items)
    jit.off(true)
    if height_in_items == nil then height_in_items = -1 end
    local out = C.igListBox_Str_arr(label, current_item, items, items_count, height_in_items)
    return out
end
M.ListBox_FnStrPtr = M.ListBox_FnStrPtr  or function(label, current_item, getter, user_data, items_count, height_in_items)
    jit.off(true)
    if height_in_items == nil then height_in_items = -1 end
    local out = C.igListBox_FnStrPtr(label, current_item, getter, user_data, items_count, height_in_items)
    return out
end
M.LoadIniSettingsFromDisk = M.LoadIniSettingsFromDisk  or function(ini_filename)
    jit.off(true)
    local out = C.igLoadIniSettingsFromDisk(ini_filename)
    return out
end
M.LoadIniSettingsFromMemory = M.LoadIniSettingsFromMemory  or function(ini_data, ini_size)
    jit.off(true)
    if ini_size == nil then ini_size = 0 end
    local out = C.igLoadIniSettingsFromMemory(ini_data, ini_size)
    return out
end
M.LogButtons = M.LogButtons  or function()
    jit.off(true)
    local out = C.igLogButtons()
    return out
end
M.LogFinish = M.LogFinish  or function()
    jit.off(true)
    local out = C.igLogFinish()
    return out
end
M.LogText = M.LogText  or function(fmt, ...)
    jit.off(true)
    local out = C.igLogText(fmt, ...)
    return out
end
M.LogToClipboard = M.LogToClipboard  or function(auto_open_depth)
    jit.off(true)
    if auto_open_depth == nil then auto_open_depth = -1 end
    local out = C.igLogToClipboard(auto_open_depth)
    return out
end
M.LogToFile = M.LogToFile  or function(auto_open_depth, filename)
    jit.off(true)
    if auto_open_depth == nil then auto_open_depth = -1 end
    local out = C.igLogToFile(auto_open_depth, filename)
    return out
end
M.LogToTTY = M.LogToTTY  or function(auto_open_depth)
    jit.off(true)
    if auto_open_depth == nil then auto_open_depth = -1 end
    local out = C.igLogToTTY(auto_open_depth)
    return out
end
M.MemAlloc = M.MemAlloc  or function(size)
    jit.off(true)
    local out = C.igMemAlloc(size)
    return out
end
M.MemFree = M.MemFree  or function(ptr)
    jit.off(true)
    local out = C.igMemFree(ptr)
    return out
end
M.MenuItem_Bool = M.MenuItem_Bool  or function(label, shortcut, selected, enabled)
    jit.off(true)
    if selected == nil then selected = false end
    if enabled == nil then enabled = true end
    local out = C.igMenuItem_Bool(label, shortcut, selected, enabled)
    return out
end
M.MenuItem_BoolPtr = M.MenuItem_BoolPtr  or function(label, shortcut, p_selected, enabled)
    jit.off(true)
    if enabled == nil then enabled = true end
    local out = C.igMenuItem_BoolPtr(label, shortcut, p_selected, enabled)
    return out
end
M.NewFrame = M.NewFrame  or function()
    jit.off(true)
    local out = C.igNewFrame()
    return out
end
M.NewLine = M.NewLine  or function()
    jit.off(true)
    local out = C.igNewLine()
    return out
end
M.NextColumn = M.NextColumn  or function()
    jit.off(true)
    local out = C.igNextColumn()
    return out
end
M.OpenPopup_Str = M.OpenPopup_Str  or function(str_id, popup_flags)
    jit.off(true)
    if popup_flags == nil then popup_flags = 0 end
    local out = C.igOpenPopup_Str(str_id, popup_flags)
    return out
end
M.OpenPopup_ID = M.OpenPopup_ID  or function(id, popup_flags)
    jit.off(true)
    if popup_flags == nil then popup_flags = 0 end
    local out = C.igOpenPopup_ID(id, popup_flags)
    return out
end
M.OpenPopupOnItemClick = M.OpenPopupOnItemClick  or function(str_id, popup_flags)
    jit.off(true)
    if popup_flags == nil then popup_flags = 1 end
    local out = C.igOpenPopupOnItemClick(str_id, popup_flags)
    return out
end
M.PlotHistogram_FloatPtr = M.PlotHistogram_FloatPtr  or function(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride)
    jit.off(true)
    if values_offset == nil then values_offset = 0 end
    if scale_min == nil then scale_min = FLT_MAX end
    if scale_max == nil then scale_max = FLT_MAX end
    if graph_size == nil then graph_size = M.ImVec2_Float(0, 0) end
    if stride == nil then stride = ffi.sizeof("float") end
    local out = C.igPlotHistogram_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride)
    return out
end
M.PlotHistogram_FnFloatPtr = M.PlotHistogram_FnFloatPtr  or function(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size)
    jit.off(true)
    if values_offset == nil then values_offset = 0 end
    if scale_min == nil then scale_min = FLT_MAX end
    if scale_max == nil then scale_max = FLT_MAX end
    if graph_size == nil then graph_size = M.ImVec2_Float(0, 0) end
    local out = C.igPlotHistogram_FnFloatPtr(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size)
    return out
end
M.PlotLines_FloatPtr = M.PlotLines_FloatPtr  or function(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride)
    jit.off(true)
    if values_offset == nil then values_offset = 0 end
    if scale_min == nil then scale_min = FLT_MAX end
    if scale_max == nil then scale_max = FLT_MAX end
    if graph_size == nil then graph_size = M.ImVec2_Float(0, 0) end
    if stride == nil then stride = ffi.sizeof("float") end
    local out = C.igPlotLines_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride)
    return out
end
M.PlotLines_FnFloatPtr = M.PlotLines_FnFloatPtr  or function(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size)
    jit.off(true)
    if values_offset == nil then values_offset = 0 end
    if scale_min == nil then scale_min = FLT_MAX end
    if scale_max == nil then scale_max = FLT_MAX end
    if graph_size == nil then graph_size = M.ImVec2_Float(0, 0) end
    local out = C.igPlotLines_FnFloatPtr(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size)
    return out
end
M.PopClipRect = M.PopClipRect  or function()
    jit.off(true)
    local out = C.igPopClipRect()
    return out
end
M.PopFont = M.PopFont  or function()
    jit.off(true)
    local out = C.igPopFont()
    return out
end
M.PopID = M.PopID  or function()
    jit.off(true)
    local out = C.igPopID()
    return out
end
M.PopItemFlag = M.PopItemFlag  or function()
    jit.off(true)
    local out = C.igPopItemFlag()
    return out
end
M.PopItemWidth = M.PopItemWidth  or function()
    jit.off(true)
    local out = C.igPopItemWidth()
    return out
end
M.PopStyleColor = M.PopStyleColor  or function(count)
    jit.off(true)
    if count == nil then count = 1 end
    local out = C.igPopStyleColor(count)
    return out
end
M.PopStyleVar = M.PopStyleVar  or function(count)
    jit.off(true)
    if count == nil then count = 1 end
    local out = C.igPopStyleVar(count)
    return out
end
M.PopTextWrapPos = M.PopTextWrapPos  or function()
    jit.off(true)
    local out = C.igPopTextWrapPos()
    return out
end
M.ProgressBar = M.ProgressBar  or function(fraction, size_arg, overlay)
    jit.off(true)
    if size_arg == nil then size_arg = M.ImVec2_Float(-FLT_MIN, 0) end
    local out = C.igProgressBar(fraction, size_arg, overlay)
    return out
end
M.PushClipRect = M.PushClipRect  or function(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect)
    jit.off(true)
    local out = C.igPushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect)
    return out
end
M.PushFont = M.PushFont  or function(font, font_size_base_unscaled)
    jit.off(true)
    local out = C.igPushFont(font, font_size_base_unscaled)
    return out
end
M.PushID_Str = M.PushID_Str  or function(str_id)
    jit.off(true)
    local out = C.igPushID_Str(str_id)
    return out
end
M.PushID_StrStr = M.PushID_StrStr  or function(str_id_begin, str_id_end)
    jit.off(true)
    local out = C.igPushID_StrStr(str_id_begin, str_id_end)
    return out
end
M.PushID_Ptr = M.PushID_Ptr  or function(ptr_id)
    jit.off(true)
    local out = C.igPushID_Ptr(ptr_id)
    return out
end
M.PushID_Int = M.PushID_Int  or function(int_id)
    jit.off(true)
    local out = C.igPushID_Int(int_id)
    return out
end
M.PushItemFlag = M.PushItemFlag  or function(option, enabled)
    jit.off(true)
    local out = C.igPushItemFlag(option, enabled)
    return out
end
M.PushItemWidth = M.PushItemWidth  or function(item_width)
    jit.off(true)
    local out = C.igPushItemWidth(item_width)
    return out
end
M.PushStyleColor_U32 = M.PushStyleColor_U32  or function(idx, col)
    jit.off(true)
    local out = C.igPushStyleColor_U32(idx, col)
    return out
end
M.PushStyleColor_Vec4 = M.PushStyleColor_Vec4  or function(idx, col)
    jit.off(true)
    local out = C.igPushStyleColor_Vec4(idx, col)
    return out
end
M.PushStyleVar_Float = M.PushStyleVar_Float  or function(idx, val)
    jit.off(true)
    local out = C.igPushStyleVar_Float(idx, val)
    return out
end
M.PushStyleVar_Vec2 = M.PushStyleVar_Vec2  or function(idx, val)
    jit.off(true)
    local out = C.igPushStyleVar_Vec2(idx, val)
    return out
end
M.PushStyleVarX = M.PushStyleVarX  or function(idx, val_x)
    jit.off(true)
    local out = C.igPushStyleVarX(idx, val_x)
    return out
end
M.PushStyleVarY = M.PushStyleVarY  or function(idx, val_y)
    jit.off(true)
    local out = C.igPushStyleVarY(idx, val_y)
    return out
end
M.PushTextWrapPos = M.PushTextWrapPos  or function(wrap_local_pos_x)
    jit.off(true)
    if wrap_local_pos_x == nil then wrap_local_pos_x = 0.0 end
    local out = C.igPushTextWrapPos(wrap_local_pos_x)
    return out
end
M.RadioButton_Bool = M.RadioButton_Bool  or function(label, active)
    jit.off(true)
    local out = C.igRadioButton_Bool(label, active)
    return out
end
M.RadioButton_IntPtr = M.RadioButton_IntPtr  or function(label, v, v_button)
    jit.off(true)
    local out = C.igRadioButton_IntPtr(label, v, v_button)
    return out
end
M.Render = M.Render  or function()
    jit.off(true)
    local out = C.igRender()
    return out
end
M.RenderPlatformWindowsDefault = M.RenderPlatformWindowsDefault  or function(platform_render_arg, renderer_render_arg)
    jit.off(true)
    local out = C.igRenderPlatformWindowsDefault(platform_render_arg, renderer_render_arg)
    return out
end
M.ResetMouseDragDelta = M.ResetMouseDragDelta  or function(button)
    jit.off(true)
    if button == nil then button = 0 end
    local out = C.igResetMouseDragDelta(button)
    return out
end
M.SameLine = M.SameLine  or function(offset_from_start_x, spacing)
    jit.off(true)
    if offset_from_start_x == nil then offset_from_start_x = 0.0 end
    if spacing == nil then spacing = -1.0 end
    local out = C.igSameLine(offset_from_start_x, spacing)
    return out
end
M.SaveIniSettingsToDisk = M.SaveIniSettingsToDisk  or function(ini_filename)
    jit.off(true)
    local out = C.igSaveIniSettingsToDisk(ini_filename)
    return out
end
M.SaveIniSettingsToMemory = M.SaveIniSettingsToMemory  or function()
    jit.off(true)
    local o1 = ffi.new("size_t[1]")
    local out = C.igSaveIniSettingsToMemory(o1)
    return o1[0], out
end
M.Selectable_Bool = M.Selectable_Bool  or function(label, selected, flags, size)
    jit.off(true)
    if selected == nil then selected = false end
    if flags == nil then flags = 0 end
    if size == nil then size = M.ImVec2_Float(0, 0) end
    local out = C.igSelectable_Bool(label, selected, flags, size)
    return out
end
M.Selectable_BoolPtr = M.Selectable_BoolPtr  or function(label, p_selected, flags, size)
    jit.off(true)
    if flags == nil then flags = 0 end
    if size == nil then size = M.ImVec2_Float(0, 0) end
    local out = C.igSelectable_BoolPtr(label, p_selected, flags, size)
    return out
end
M.Separator = M.Separator  or function()
    jit.off(true)
    local out = C.igSeparator()
    return out
end
M.SeparatorText = M.SeparatorText  or function(label)
    jit.off(true)
    local out = C.igSeparatorText(label)
    return out
end
M.SetAllocatorFunctions = M.SetAllocatorFunctions  or function(alloc_func, free_func, user_data)
    jit.off(true)
    local out = C.igSetAllocatorFunctions(alloc_func, free_func, user_data)
    return out
end
M.SetClipboardText = M.SetClipboardText  or function(text)
    jit.off(true)
    local out = C.igSetClipboardText(text)
    return out
end
M.SetColorEditOptions = M.SetColorEditOptions  or function(flags)
    jit.off(true)
    local out = C.igSetColorEditOptions(flags)
    return out
end
M.SetColumnOffset = M.SetColumnOffset  or function(column_index, offset_x)
    jit.off(true)
    local out = C.igSetColumnOffset(column_index, offset_x)
    return out
end
M.SetColumnWidth = M.SetColumnWidth  or function(column_index, width)
    jit.off(true)
    local out = C.igSetColumnWidth(column_index, width)
    return out
end
M.SetCurrentContext = M.SetCurrentContext  or function(ctx)
    jit.off(true)
    local out = C.igSetCurrentContext(ctx)
    return out
end
M.SetCursorPos = M.SetCursorPos  or function(local_pos)
    jit.off(true)
    local out = C.igSetCursorPos(local_pos)
    return out
end
M.SetCursorPosX = M.SetCursorPosX  or function(local_x)
    jit.off(true)
    local out = C.igSetCursorPosX(local_x)
    return out
end
M.SetCursorPosY = M.SetCursorPosY  or function(local_y)
    jit.off(true)
    local out = C.igSetCursorPosY(local_y)
    return out
end
M.SetCursorScreenPos = M.SetCursorScreenPos  or function(pos)
    jit.off(true)
    local out = C.igSetCursorScreenPos(pos)
    return out
end
M.SetDragDropPayload = M.SetDragDropPayload  or function(type, data, sz, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetDragDropPayload(type, data, sz, cond)
    return out
end
M.SetItemDefaultFocus = M.SetItemDefaultFocus  or function()
    jit.off(true)
    local out = C.igSetItemDefaultFocus()
    return out
end
M.SetItemKeyOwner = M.SetItemKeyOwner  or function(key)
    jit.off(true)
    local out = C.igSetItemKeyOwner(key)
    return out
end
M.SetItemTooltip = M.SetItemTooltip  or function(fmt, ...)
    jit.off(true)
    local out = C.igSetItemTooltip(fmt, ...)
    return out
end
M.SetKeyboardFocusHere = M.SetKeyboardFocusHere  or function(offset)
    jit.off(true)
    if offset == nil then offset = 0 end
    local out = C.igSetKeyboardFocusHere(offset)
    return out
end
M.SetMouseCursor = M.SetMouseCursor  or function(cursor_type)
    jit.off(true)
    local out = C.igSetMouseCursor(cursor_type)
    return out
end
M.SetNavCursorVisible = M.SetNavCursorVisible  or function(visible)
    jit.off(true)
    local out = C.igSetNavCursorVisible(visible)
    return out
end
M.SetNextFrameWantCaptureKeyboard = M.SetNextFrameWantCaptureKeyboard  or function(want_capture_keyboard)
    jit.off(true)
    local out = C.igSetNextFrameWantCaptureKeyboard(want_capture_keyboard)
    return out
end
M.SetNextFrameWantCaptureMouse = M.SetNextFrameWantCaptureMouse  or function(want_capture_mouse)
    jit.off(true)
    local out = C.igSetNextFrameWantCaptureMouse(want_capture_mouse)
    return out
end
M.SetNextItemAllowOverlap = M.SetNextItemAllowOverlap  or function()
    jit.off(true)
    local out = C.igSetNextItemAllowOverlap()
    return out
end
M.SetNextItemOpen = M.SetNextItemOpen  or function(is_open, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetNextItemOpen(is_open, cond)
    return out
end
M.SetNextItemSelectionUserData = M.SetNextItemSelectionUserData  or function(selection_user_data)
    jit.off(true)
    local out = C.igSetNextItemSelectionUserData(selection_user_data)
    return out
end
M.SetNextItemShortcut = M.SetNextItemShortcut  or function(key_chord, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igSetNextItemShortcut(key_chord, flags)
    return out
end
M.SetNextItemStorageID = M.SetNextItemStorageID  or function(storage_id)
    jit.off(true)
    local out = C.igSetNextItemStorageID(storage_id)
    return out
end
M.SetNextItemWidth = M.SetNextItemWidth  or function(item_width)
    jit.off(true)
    local out = C.igSetNextItemWidth(item_width)
    return out
end
M.SetNextWindowBgAlpha = M.SetNextWindowBgAlpha  or function(alpha)
    jit.off(true)
    local out = C.igSetNextWindowBgAlpha(alpha)
    return out
end
M.SetNextWindowClass = M.SetNextWindowClass  or function(window_class)
    jit.off(true)
    local out = C.igSetNextWindowClass(window_class)
    return out
end
M.SetNextWindowCollapsed = M.SetNextWindowCollapsed  or function(collapsed, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetNextWindowCollapsed(collapsed, cond)
    return out
end
M.SetNextWindowContentSize = M.SetNextWindowContentSize  or function(size)
    jit.off(true)
    local out = C.igSetNextWindowContentSize(size)
    return out
end
M.SetNextWindowDockID = M.SetNextWindowDockID  or function(dock_id, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetNextWindowDockID(dock_id, cond)
    return out
end
M.SetNextWindowFocus = M.SetNextWindowFocus  or function()
    jit.off(true)
    local out = C.igSetNextWindowFocus()
    return out
end
M.SetNextWindowPos = M.SetNextWindowPos  or function(pos, cond, pivot)
    jit.off(true)
    if cond == nil then cond = 0 end
    if pivot == nil then pivot = M.ImVec2_Float(0, 0) end
    local out = C.igSetNextWindowPos(pos, cond, pivot)
    return out
end
M.SetNextWindowScroll = M.SetNextWindowScroll  or function(scroll)
    jit.off(true)
    local out = C.igSetNextWindowScroll(scroll)
    return out
end
M.SetNextWindowSize = M.SetNextWindowSize  or function(size, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetNextWindowSize(size, cond)
    return out
end
M.SetNextWindowSizeConstraints = M.SetNextWindowSizeConstraints  or function(size_min, size_max, custom_callback, custom_callback_data)
    jit.off(true)
    local out = C.igSetNextWindowSizeConstraints(size_min, size_max, custom_callback, custom_callback_data)
    return out
end
M.SetNextWindowViewport = M.SetNextWindowViewport  or function(viewport_id)
    jit.off(true)
    local out = C.igSetNextWindowViewport(viewport_id)
    return out
end
M.SetScrollFromPosX = M.SetScrollFromPosX  or function(local_x, center_x_ratio)
    jit.off(true)
    if center_x_ratio == nil then center_x_ratio = 0.5 end
    local out = C.igSetScrollFromPosX(local_x, center_x_ratio)
    return out
end
M.SetScrollFromPosY = M.SetScrollFromPosY  or function(local_y, center_y_ratio)
    jit.off(true)
    if center_y_ratio == nil then center_y_ratio = 0.5 end
    local out = C.igSetScrollFromPosY(local_y, center_y_ratio)
    return out
end
M.SetScrollHereX = M.SetScrollHereX  or function(center_x_ratio)
    jit.off(true)
    if center_x_ratio == nil then center_x_ratio = 0.5 end
    local out = C.igSetScrollHereX(center_x_ratio)
    return out
end
M.SetScrollHereY = M.SetScrollHereY  or function(center_y_ratio)
    jit.off(true)
    if center_y_ratio == nil then center_y_ratio = 0.5 end
    local out = C.igSetScrollHereY(center_y_ratio)
    return out
end
M.SetScrollX = M.SetScrollX  or function(scroll_x)
    jit.off(true)
    local out = C.igSetScrollX(scroll_x)
    return out
end
M.SetScrollY = M.SetScrollY  or function(scroll_y)
    jit.off(true)
    local out = C.igSetScrollY(scroll_y)
    return out
end
M.SetStateStorage = M.SetStateStorage  or function(storage)
    jit.off(true)
    local out = C.igSetStateStorage(storage)
    return out
end
M.SetTabItemClosed = M.SetTabItemClosed  or function(tab_or_docked_window_label)
    jit.off(true)
    local out = C.igSetTabItemClosed(tab_or_docked_window_label)
    return out
end
M.SetTooltip = M.SetTooltip  or function(fmt, ...)
    jit.off(true)
    local out = C.igSetTooltip(fmt, ...)
    return out
end
M.SetWindowCollapsed_Bool = M.SetWindowCollapsed_Bool  or function(collapsed, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetWindowCollapsed_Bool(collapsed, cond)
    return out
end
M.SetWindowCollapsed_Str = M.SetWindowCollapsed_Str  or function(name, collapsed, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetWindowCollapsed_Str(name, collapsed, cond)
    return out
end
M.SetWindowFocus_Nil = M.SetWindowFocus_Nil  or function()
    jit.off(true)
    local out = C.igSetWindowFocus_Nil()
    return out
end
M.SetWindowFocus_Str = M.SetWindowFocus_Str  or function(name)
    jit.off(true)
    local out = C.igSetWindowFocus_Str(name)
    return out
end
M.SetWindowPos_Vec2 = M.SetWindowPos_Vec2  or function(pos, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetWindowPos_Vec2(pos, cond)
    return out
end
M.SetWindowPos_Str = M.SetWindowPos_Str  or function(name, pos, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetWindowPos_Str(name, pos, cond)
    return out
end
M.SetWindowSize_Vec2 = M.SetWindowSize_Vec2  or function(size, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetWindowSize_Vec2(size, cond)
    return out
end
M.SetWindowSize_Str = M.SetWindowSize_Str  or function(name, size, cond)
    jit.off(true)
    if cond == nil then cond = 0 end
    local out = C.igSetWindowSize_Str(name, size, cond)
    return out
end
M.Shortcut = M.Shortcut  or function(key_chord, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igShortcut(key_chord, flags)
    return out
end
M.ShowAboutWindow = M.ShowAboutWindow  or function(p_open)
    jit.off(true)
    local out = C.igShowAboutWindow(p_open)
    return out
end
M.ShowDebugLogWindow = M.ShowDebugLogWindow  or function(p_open)
    jit.off(true)
    local out = C.igShowDebugLogWindow(p_open)
    return out
end
M.ShowDemoWindow = M.ShowDemoWindow  or function(p_open)
    jit.off(true)
    local out = C.igShowDemoWindow(p_open)
    return out
end
M.ShowFontSelector = M.ShowFontSelector  or function(label)
    jit.off(true)
    local out = C.igShowFontSelector(label)
    return out
end
M.ShowIDStackToolWindow = M.ShowIDStackToolWindow  or function(p_open)
    jit.off(true)
    local out = C.igShowIDStackToolWindow(p_open)
    return out
end
M.ShowMetricsWindow = M.ShowMetricsWindow  or function(p_open)
    jit.off(true)
    local out = C.igShowMetricsWindow(p_open)
    return out
end
M.ShowStyleEditor = M.ShowStyleEditor  or function(ref)
    jit.off(true)
    local out = C.igShowStyleEditor(ref)
    return out
end
M.ShowStyleSelector = M.ShowStyleSelector  or function(label)
    jit.off(true)
    local out = C.igShowStyleSelector(label)
    return out
end
M.ShowUserGuide = M.ShowUserGuide  or function()
    jit.off(true)
    local out = C.igShowUserGuide()
    return out
end
M.SliderAngle = M.SliderAngle  or function(label, v_rad, v_degrees_min, v_degrees_max, format, flags)
    jit.off(true)
    if v_degrees_min == nil then v_degrees_min = -360.0 end
    if v_degrees_max == nil then v_degrees_max = 360.0 end
    if format == nil then format = "%.0f deg" end
    if flags == nil then flags = 0 end
    local out = C.igSliderAngle(label, v_rad, v_degrees_min, v_degrees_max, format, flags)
    return out
end
M.SliderFloat = M.SliderFloat  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igSliderFloat(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderFloat2 = M.SliderFloat2  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igSliderFloat2(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderFloat3 = M.SliderFloat3  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igSliderFloat3(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderFloat4 = M.SliderFloat4  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igSliderFloat4(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderInt = M.SliderInt  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igSliderInt(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderInt2 = M.SliderInt2  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igSliderInt2(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderInt3 = M.SliderInt3  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igSliderInt3(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderInt4 = M.SliderInt4  or function(label, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igSliderInt4(label, v, v_min, v_max, format, flags)
    return out
end
M.SliderScalar = M.SliderScalar  or function(label, data_type, p_data, p_min, p_max, format, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igSliderScalar(label, data_type, p_data, p_min, p_max, format, flags)
    return out
end
M.SliderScalarN = M.SliderScalarN  or function(label, data_type, p_data, components, p_min, p_max, format, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igSliderScalarN(label, data_type, p_data, components, p_min, p_max, format, flags)
    return out
end
M.SmallButton = M.SmallButton  or function(label)
    jit.off(true)
    local out = C.igSmallButton(label)
    return out
end
M.Spacing = M.Spacing  or function()
    jit.off(true)
    local out = C.igSpacing()
    return out
end
M.StyleColorsClassic = M.StyleColorsClassic  or function(dst)
    jit.off(true)
    local out = C.igStyleColorsClassic(dst)
    return out
end
M.StyleColorsDark = M.StyleColorsDark  or function(dst)
    jit.off(true)
    local out = C.igStyleColorsDark(dst)
    return out
end
M.StyleColorsLight = M.StyleColorsLight  or function(dst)
    jit.off(true)
    local out = C.igStyleColorsLight(dst)
    return out
end
M.TabItemButton = M.TabItemButton  or function(label, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igTabItemButton(label, flags)
    return out
end
M.TableAngledHeadersRow = M.TableAngledHeadersRow  or function()
    jit.off(true)
    local out = C.igTableAngledHeadersRow()
    return out
end
M.TableGetColumnCount = M.TableGetColumnCount  or function()
    jit.off(true)
    local out = C.igTableGetColumnCount()
    return out
end
M.TableGetColumnFlags = M.TableGetColumnFlags  or function(column_n)
    jit.off(true)
    if column_n == nil then column_n = -1 end
    local out = C.igTableGetColumnFlags(column_n)
    return out
end
M.TableGetColumnIndex = M.TableGetColumnIndex  or function()
    jit.off(true)
    local out = C.igTableGetColumnIndex()
    return out
end
M.TableGetColumnName = M.TableGetColumnName  or function(column_n)
    jit.off(true)
    if column_n == nil then column_n = -1 end
    local out = C.igTableGetColumnName(column_n)
    return out
end
M.TableGetHoveredColumn = M.TableGetHoveredColumn  or function()
    jit.off(true)
    local out = C.igTableGetHoveredColumn()
    return out
end
M.TableGetRowIndex = M.TableGetRowIndex  or function()
    jit.off(true)
    local out = C.igTableGetRowIndex()
    return out
end
M.TableGetSortSpecs = M.TableGetSortSpecs  or function()
    jit.off(true)
    local out = C.igTableGetSortSpecs()
    return out
end
M.TableHeader = M.TableHeader  or function(label)
    jit.off(true)
    local out = C.igTableHeader(label)
    return out
end
M.TableHeadersRow = M.TableHeadersRow  or function()
    jit.off(true)
    local out = C.igTableHeadersRow()
    return out
end
M.TableNextColumn = M.TableNextColumn  or function()
    jit.off(true)
    local out = C.igTableNextColumn()
    return out
end
M.TableNextRow = M.TableNextRow  or function(row_flags, min_row_height)
    jit.off(true)
    if row_flags == nil then row_flags = 0 end
    if min_row_height == nil then min_row_height = 0.0 end
    local out = C.igTableNextRow(row_flags, min_row_height)
    return out
end
M.TableSetBgColor = M.TableSetBgColor  or function(target, color, column_n)
    jit.off(true)
    if column_n == nil then column_n = -1 end
    local out = C.igTableSetBgColor(target, color, column_n)
    return out
end
M.TableSetColumnEnabled = M.TableSetColumnEnabled  or function(column_n, v)
    jit.off(true)
    local out = C.igTableSetColumnEnabled(column_n, v)
    return out
end
M.TableSetColumnIndex = M.TableSetColumnIndex  or function(column_n)
    jit.off(true)
    local out = C.igTableSetColumnIndex(column_n)
    return out
end
M.TableSetupColumn = M.TableSetupColumn  or function(label, flags, init_width_or_weight, user_id)
    jit.off(true)
    if flags == nil then flags = 0 end
    if init_width_or_weight == nil then init_width_or_weight = 0.0 end
    if user_id == nil then user_id = 0 end
    local out = C.igTableSetupColumn(label, flags, init_width_or_weight, user_id)
    return out
end
M.TableSetupScrollFreeze = M.TableSetupScrollFreeze  or function(cols, rows)
    jit.off(true)
    local out = C.igTableSetupScrollFreeze(cols, rows)
    return out
end
M.Text = M.Text  or function(fmt, ...)
    jit.off(true)
    local out = C.igText(fmt, ...)
    return out
end
M.TextColored = M.TextColored  or function(col, fmt, ...)
    jit.off(true)
    local out = C.igTextColored(col, fmt, ...)
    return out
end
M.TextDisabled = M.TextDisabled  or function(fmt, ...)
    jit.off(true)
    local out = C.igTextDisabled(fmt, ...)
    return out
end
M.TextLink = M.TextLink  or function(label)
    jit.off(true)
    local out = C.igTextLink(label)
    return out
end
M.TextLinkOpenURL = M.TextLinkOpenURL  or function(label, url)
    jit.off(true)
    local out = C.igTextLinkOpenURL(label, url)
    return out
end
M.TextUnformatted = M.TextUnformatted  or function(text, text_end)
    jit.off(true)
    local out = C.igTextUnformatted(text, text_end)
    return out
end
M.TextWrapped = M.TextWrapped  or function(fmt, ...)
    jit.off(true)
    local out = C.igTextWrapped(fmt, ...)
    return out
end
M.TreeNode_Str = M.TreeNode_Str  or function(label)
    jit.off(true)
    local out = C.igTreeNode_Str(label)
    return out
end
M.TreeNode_StrStr = M.TreeNode_StrStr  or function(str_id, fmt, ...)
    jit.off(true)
    local out = C.igTreeNode_StrStr(str_id, fmt, ...)
    return out
end
M.TreeNode_Ptr = M.TreeNode_Ptr  or function(ptr_id, fmt, ...)
    jit.off(true)
    local out = C.igTreeNode_Ptr(ptr_id, fmt, ...)
    return out
end
M.TreeNodeEx_Str = M.TreeNodeEx_Str  or function(label, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igTreeNodeEx_Str(label, flags)
    return out
end
M.TreeNodeEx_StrStr = M.TreeNodeEx_StrStr  or function(str_id, flags, fmt, ...)
    jit.off(true)
    local out = C.igTreeNodeEx_StrStr(str_id, flags, fmt, ...)
    return out
end
M.TreeNodeEx_Ptr = M.TreeNodeEx_Ptr  or function(ptr_id, flags, fmt, ...)
    jit.off(true)
    local out = C.igTreeNodeEx_Ptr(ptr_id, flags, fmt, ...)
    return out
end
M.TreePop = M.TreePop  or function()
    jit.off(true)
    local out = C.igTreePop()
    return out
end
M.TreePush_Str = M.TreePush_Str  or function(str_id)
    jit.off(true)
    local out = C.igTreePush_Str(str_id)
    return out
end
M.TreePush_Ptr = M.TreePush_Ptr  or function(ptr_id)
    jit.off(true)
    local out = C.igTreePush_Ptr(ptr_id)
    return out
end
M.Unindent = M.Unindent  or function(indent_w)
    jit.off(true)
    if indent_w == nil then indent_w = 0.0 end
    local out = C.igUnindent(indent_w)
    return out
end
M.UpdatePlatformWindows = M.UpdatePlatformWindows  or function()
    jit.off(true)
    local out = C.igUpdatePlatformWindows()
    return out
end
M.VSliderFloat = M.VSliderFloat  or function(label, size, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%.3f" end
    if flags == nil then flags = 0 end
    local out = C.igVSliderFloat(label, size, v, v_min, v_max, format, flags)
    return out
end
M.VSliderInt = M.VSliderInt  or function(label, size, v, v_min, v_max, format, flags)
    jit.off(true)
    if format == nil then format = "%d" end
    if flags == nil then flags = 0 end
    local out = C.igVSliderInt(label, size, v, v_min, v_max, format, flags)
    return out
end
M.VSliderScalar = M.VSliderScalar  or function(label, size, data_type, p_data, p_min, p_max, format, flags)
    jit.off(true)
    if flags == nil then flags = 0 end
    local out = C.igVSliderScalar(label, size, data_type, p_data, p_min, p_max, format, flags)
    return out
end
M.Value_Bool = M.Value_Bool  or function(prefix, b)
    jit.off(true)
    local out = C.igValue_Bool(prefix, b)
    return out
end
M.Value_Int = M.Value_Int  or function(prefix, v)
    jit.off(true)
    local out = C.igValue_Int(prefix, v)
    return out
end
M.Value_Uint = M.Value_Uint  or function(prefix, v)
    jit.off(true)
    local out = C.igValue_Uint(prefix, v)
    return out
end
M.Value_Float = M.Value_Float  or function(prefix, v, float_format)
    jit.off(true)
    local out = C.igValue_Float(prefix, v, float_format)
    return out
end