local lib = {}

---@class KristalImgui
local Imgui = _G.Imgui or {}
_G.Imgui = Imgui

Imgui.first_update = false

function lib:preInit()
    Imgui.init()
end

function lib:onRegistered()
    self.applet_classes = {}
    for _,path,applet in Registry.iterScripts("applets") do
        assert(applet ~= nil, '"applets/'..path..'.lua" does not return value')
        applet.id = applet.id or path
        self.applet_classes[applet.id] = applet
    end
end

function lib:init()
    self.applets = {} ---@type table<string, ImguiApplet>
    for key, value in pairs(self.applet_classes) do
        self.applets[key] = value()
    end
    -- TODO: Remove this when Kristal calls unload after errors
    HookSystem.hook(Kristal, "errorHandler", function(orig, ...)
        local loop = orig(...)
        xpcall(function()
            self:unload()
        end, function(msg)
            print("Failed to unload imgui after an error:\n" .. debug.traceback(tostring(msg)))
        end)
        return loop
    end)
end

function Imgui.firstInit()
    -- this is the worst thing i've ever done
    package.path = package.path .. ";"..love.filesystem.getSaveDirectory().."/?.lua"
    local os = require("ffi").os
    local ext = ((function()
        if os == "Windows" then
            return "dll"
        elseif os == "Linux" then
            return "so"
        elseif os == "OSX" then -- TODO: Is "OSX" correct?
            return "dylib"
        else
            error("\"" ..os.."\" isn't supported, sorry! If you're a player, tell the dev to remove the imgui stuff.")
        end
    end)())
    local new_cpath = love.filesystem.getSaveDirectory().."/?."..ext
    if os == "Windows" then
        new_cpath = new_cpath:gsub("/", "\\")
    end
    package.cpath = package.cpath .. ";"..new_cpath
    ---@type boolean
    Imgui.active = true
    local ok, imlib = xpcall(libRequire, debug.traceback, "imgui", "cimgui.cimgui.init")
    if not ok then
        local info = lib.info
        TableUtils.clear(lib)
        lib.info = info
        _G.Imgui = nil
        Imgui.initialized = true
        Kristal.Console:error(imlib)
        return
    end
    ---@type imgui
    Imgui.lib = imlib
end

function Imgui.init()
    if Imgui.lib == nil then
        Imgui.firstInit()
    end
    if not Imgui.initialized then
        Imgui.lib.love.Init()

        Imgui.initialized = true
        local io = Imgui.lib.C.igGetIO()
        io.ConfigFlags = bit.bor(
            io.ConfigFlags,
            Imgui.lib.ImGuiConfigFlags_NavEnableGamepad,
            Imgui.lib.ImGuiConfigFlags_DockingEnable,
        0)
        -- TODO: Add a proper config for this. I personally prefer
        -- light theme since it's useful with the offset editor on dark
        -- world sprites, but I realise not everyone feels the same way.
        if Kristal.Config["forceImguiLibLightThemeThisIsTempIdkHowToDoThisBetter"] then
            Imgui.lib.StyleColorsLight()
        end
    end
end

function Imgui.preDraw() end

function lib:show()
    if self.error_state then
        self:showError()
    else
        xpcall(Imgui.showNormal, function (msg)
            self.error_state = debug.traceback(msg)
            Imgui.lib.love.Shutdown()
            Imgui.initialized = false
            Imgui.first_update = false
            Imgui.init()
        end)
    end
end

function lib:showError()
    Imgui.lib.Text(self.error_state)
    if Imgui.lib.Button("Ignore") then
        self.error_state = nil
    end
    Imgui.lib.SameLine()
    if Imgui.lib.Button("Restart Applets") then
        self.applets = {}
        for key, value in pairs(self.applet_classes) do
            self.applets[key] = value()
        end
        self.error_state = nil
    end
end

function Imgui.showNormal()
    if not (Imgui.active and not Kristal.callEvent("drawImgui")) then return end
    if Imgui.lib.BeginMainMenuBar() then
        if Imgui.lib.BeginMenu("Applets") then
            for index, value in pairs(lib.applets) do
                if Imgui.lib.MenuItem_Bool(value:getTitle(), nil, value:isOpen()) then
                    value:setOpen(not value:isOpen())
                end
            end
            Imgui.lib.EndMenu()
        end
        Imgui.lib.EndMainMenuBar()
    end
    for key, value in pairs(lib.applets) do
        value:fullShow()
    end
end

function Imgui.draw()
    if not Imgui.first_update then
        return
    end
    lib:show()
    if not Imgui.first_update then
        return
    end
    Imgui.lib.Render()
    Imgui.lib.love.RenderDrawLists()
end

function Imgui.update()
    if not (Imgui.initialized) then
        return
    end
    Imgui.lib.love.Update(DT)
    if Imgui.lib.love.GetWantCaptureKeyboard() then
        love.keyboard.setTextInput(true)
        Imgui.captured_keyboard = true
    end
    if Imgui.captured_keyboard and not Imgui.lib.love.GetWantCaptureKeyboard() then
        love.keyboard.setTextInput(false)
        Imgui.captured_keyboard = false
    end
    Imgui.lib.NewFrame()
    Imgui.first_update = true
end

function lib:unload()
    if not Imgui.initialized then
        return
    end
    Imgui.first_update = false
    Imgui.initialized = false
    Imgui.lib.love.Shutdown()
end

function lib:onKeyPressed(key)
    if key == "f10" then
        Imgui.active = not Imgui.active
    end
end

return lib
