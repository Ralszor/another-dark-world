---@class DarkEquipMenu : Object
---@overload fun(...) : DarkEquipMenu
local DarkEquipMenu, super = Utils.hookScript(DarkEquipMenu)

function DarkEquipMenu:init()
    super.init(self)

    self.ui_cant_select_flowery = Assets.newSound("voiceclips/nonono")
end

function DarkEquipMenu:update()
    if self.state == "PARTY" and Input.pressed("confirm") then
        local party = self.party:getSelected()

        if party and party.name == "Flowery" then
            self.ui_cant_select_flowery:stop()
            self.ui_cant_select_flowery:play()

            Input.clear("confirm")
        end
    end

    super.update(self)
end

return DarkEquipMenu