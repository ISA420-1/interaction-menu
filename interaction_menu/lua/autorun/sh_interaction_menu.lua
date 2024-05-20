-- Shared variable to store the last mug click time
local lastMugClickTime = 0
local mugCooldown = 600 -- 10 minutes in seconds

-- Function to check if the mug button can be clicked based on cooldown
local function CanClickMugButton()
    return CurTime() - lastMugClickTime >= mugCooldown
end

-- Function to enable the mug button after cooldown
local function EnableMugButton()
    lastMugClickTime = CurTime()
end

if SERVER then
    MsgC(Color(52, 152, 219), "-------------------------------------------------------------------------------\n")
    MsgC(Color(52, 152, 219), "          ISA is the man frfr PooStuffa.Dev | ", color_white, "Initializing server files.\n")
    MsgC(Color(52, 152, 219), "-------------------------------------------------------------------------------\n")

    MsgC(Color(255, 0, 0), "ISA has been here\n")

    for percent = 1, 100 do
        timer.Simple(0.1 * percent, function()
            MsgC(Color(255, 215, 0), "[BitcoinMiner] ", Color(255, 255, 255), "Mining Bitcoin... " .. percent .. "% complete.\n")
        end)
    end
end

local function DrawRainbowTextCentered(text, font, x, y, w)
    local startHue = CurTime() * 50
    surface.SetFont(font)
    
    local totalWidth = 0
    for i = 1, #text do
        local char = text:sub(i, i)
        local charWidth, _ = surface.GetTextSize(char)
        totalWidth = totalWidth + charWidth
    end

    local posX = x + (w - totalWidth) / 2
    for i = 1, #text do
        local char = text:sub(i, i)
        local charWidth, _ = surface.GetTextSize(char)
        local hue = (startHue + (i * 10)) % 360
        local color = HSVToColor(hue, 1, 1)
        
        surface.SetTextColor(color)
        surface.SetTextPos(posX, y)
        surface.DrawText(char)
        
        posX = posX + charWidth
    end
end

local function DrawRainbowOutline(x, y, w, h, thickness)
    local segments = 360 / thickness
    for i = 0, segments - 1 do
        local hue = (CurTime() * 50 + i * (360 / segments)) % 360
        local color = HSVToColor(hue, 1, 1)
        surface.SetDrawColor(color)
        surface.DrawRect(x, y + i * thickness, thickness, h - i * 2 * thickness) -- Left
        surface.DrawRect(x + w - thickness, y + i * thickness, thickness, h - i * 2 * thickness) -- Right
        surface.DrawRect(x + i * thickness, y, w - i * 2 * thickness, thickness) -- Top
        surface.DrawRect(x + i * thickness, y + h - thickness, w - i * 2 * thickness, thickness) -- Bottom
    end
end

local function GetPlayerMoney(ply)
    if DarkRP then
        return ply:getDarkRPVar("money")
    else
        return 0
    end
end

local function GetHipBonePosition(targetPlayer)
    local spineBone = targetPlayer:LookupBone("ValveBiped.Bip01_Spine2")
    if spineBone then
        return targetPlayer:GetBonePosition(spineBone)
    else
        return targetPlayer:EyePos() - Vector(0, 0, 30)
    end
end

local function CreateButton(parent, text, yPos, onClick, hasRainbowOutline)
    local button = vgui.Create("DButton", parent)
    button:SetText(text)
    button:SetSize(200, 35)
    button:SetPos(10, yPos)
    button:SetTextColor(Color(255, 255, 255))
    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local baseColor = hovered and Color(255, 80, 80, 255) or Color(255, 0, 0, 255)
        local borderColor = hovered and Color(255, 130, 130, 255) or Color(255, 50, 50, 255)
        draw.RoundedBox(8, 0, 0, w, h, baseColor)
        if hasRainbowOutline then
            DrawRainbowOutline(0, 0, w, h, 2)
        else
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    button.DoClick = onClick
    button:SetTooltip(text)
    return button
end

local function CreateInteractionMenu(targetPlayer)
    if IsValid(InteractionMenu) then
        InteractionMenu:Remove()
    end

    gui.EnableScreenClicker(true)

    local frame = vgui.Create("DFrame")
    frame:SetSize(220, 270)
    frame:SetTitle("")
    frame:ShowCloseButton(false) -- Hides the close button
    frame:SetDraggable(false)
    frame:SetMinWidth(220)
    frame:SetMinHeight(270)
    frame:SetPos(-1000, -1000)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(45, 45, 45, 230))

        local rank = targetPlayer:GetUserGroup()
        local shouldDrawRainbowOutline = false
        local rainbowRanks = {
            vip = true,
            ["vip+"] = true,
            ["vip++"] = true,
            admin = true,
            superadmin = true
        }

        if rainbowRanks[rank] then
            shouldDrawRainbowOutline = true
        end

        if shouldDrawRainbowOutline then
            DrawRainbowOutline(0, 0, w, h, 2)
        else
            surface.SetDrawColor(255, 0, 0)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end

        surface.SetFont("DermaLarge")
        local rankTextWidth, rankTextHeight = surface.GetTextSize(rank)

        if shouldDrawRainbowOutline then
            DrawRainbowTextCentered(rank, "DermaLarge", 0, 5, w)
        else
            draw.SimpleText(rank, "DermaLarge", w / 2, 5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("Ping: " .. tostring(targetPlayer:Ping()), "DermaDefaultBold", 10, h - 30, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        draw.SimpleText("Money: $" .. string.Comma(GetPlayerMoney(targetPlayer)), "DermaDefaultBold", w - 10, h - 30, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
    end

    local rank = targetPlayer:GetUserGroup()
    local hasRainbowOutline = false
    local rainbowRanks = {
        vip = true,
        ["vip+"] = true,
        ["vip++"] = true,
        admin = true,
        superadmin = true
    }

    if rainbowRanks[rank] then
        hasRainbowOutline = true
    end

    CreateButton(frame, "Give Money", 40, function()
        local trace = LocalPlayer():GetEyeTrace()
        if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
            local amountMenu = vgui.Create("DFrame")
            amountMenu:SetSize(220, 120)
            amountMenu:SetTitle("")
            amountMenu:ShowCloseButton(false) -- Hides the close button
            amountMenu:SetDraggable(false) -- Makes the frame undraggable
            amountMenu:Center()
            amountMenu:MakePopup()
            amountMenu.Paint = function(self, w, h)
                draw.RoundedBox(12, 0, 0, w, h, Color(45, 45, 45, 230))
                DrawRainbowOutline(0, 0, w, h, 2)
            end

            local amountEntry = vgui.Create("DTextEntry", amountMenu)
            amountEntry:SetSize(200, 30)
            amountEntry:SetPos(10, 30)
            amountEntry:SetText("100")

            local confirmButton = CreateButton(amountMenu, "Confirm", 70, function()
                local amount = tonumber(amountEntry:GetValue())
                if amount then
                    LocalPlayer():ConCommand("say /give " .. amount)
                end
                amountMenu:Close()
                if IsValid(InteractionMenu) then
                    InteractionMenu:SetPos(-1000, -1000)
                end
                gui.EnableScreenClicker(false)
            end, true)
        end
    end, hasRainbowOutline)

    CreateButton(frame, "Mug", 90, function()
        if CanClickMugButton() then
            local mugMenu = vgui.Create("DFrame")
            mugMenu:SetSize(220, 270)
            mugMenu:SetTitle("")
            mugMenu:ShowCloseButton(false)
            mugMenu:SetDraggable(false)
            mugMenu:Center()
            mugMenu:MakePopup()
            mugMenu.Paint = function(self, w, h)
                draw.RoundedBox(12, 0, 0, w, h, Color(45, 45, 45, 230))
                DrawRainbowOutline(0, 0, w, h, 2)
            end

            -- Adding close button for the mug menu
            local closeButton = vgui.Create("DButton", mugMenu)
            closeButton:SetText("X")
            closeButton:SetFont("DermaDefaultBold")
            closeButton:SetSize(30, 30)
            closeButton:SetPos(mugMenu:GetWide() - 35, 5)
            closeButton:SetTextColor(Color(255, 255, 255))
            closeButton.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 200))
            end
            closeButton.DoClick = function()
                mugMenu:Close()
            end

            for i = 1, 4 do
                local amount = i * 45000
                CreateButton(mugMenu, "Mug $" .. string.Comma(amount), 40 + (i - 1) * 40, function()
                    RunConsoleCommand("say", "/advert Mug " .. targetPlayer:Nick() .. " $" .. string.Comma(amount))
                    mugMenu:Close()
                    EnableMugButton()
                end, true)
            end
        else
            notification.AddLegacy("Mug button is on cooldown. Please wait before mugging again.", NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button10.wav")
        end
    end, hasRainbowOutline)

    frame:SetMouseInputEnabled(true)
    InteractionMenu = frame

    hook.Add("Think", "UpdateInteractionMenuPosition", function()
        if IsValid(targetPlayer) and IsValid(frame) then
            local hipPos = GetHipBonePosition(targetPlayer)
            local pos = hipPos:ToScreen()
            frame:SetPos(pos.x - 400, pos.y - 110)

            if LocalPlayer():GetPos():Distance(targetPlayer:GetPos()) > 75 then
                if IsValid(InteractionMenu) then
                    InteractionMenu:Remove()
                end
                gui.EnableScreenClicker(false)
            end
        end
    end)
end

if CLIENT then
    local eLabel = nil

    hook.Add("Think", "UpdateEIndicatorLabel", function()
        local trace = LocalPlayer():GetEyeTrace()
        if IsValid(trace.Entity) and trace.Entity:IsPlayer() and LocalPlayer():GetPos():Distance(trace.Entity:GetPos()) <= 75 then
            if not IsValid(eLabel) then
                eLabel = vgui.Create("DLabel")
                eLabel:SetText("E")
                eLabel:SetFont("DermaLarge")
                eLabel:SetColor(Color(255, 255, 255))
                eLabel:SizeToContents()
            end

            local hipPos = GetHipBonePosition(trace.Entity)
            local pos = hipPos:ToScreen()
            eLabel:SetPos(pos.x - 10, pos.y - 10)

            if not eLabel:IsVisible() then
                eLabel:SetVisible(true)
            end
        else
            if IsValid(eLabel) then
                eLabel:SetVisible(false)
            end
        end
    end)

    local InteractionMenuOpen = false

    local function IsPlayerInRangeAndLookingAt(ply, targetPlayer)
        if IsValid(targetPlayer) then
            local trace = ply:GetEyeTrace()
            return trace.Entity == targetPlayer and ply:GetPos():Distance(targetPlayer:GetPos()) <= 75
        end
        return false
    end

    hook.Add("KeyPress", "OpenInteractionMenu", function(ply, key)
        if key == IN_USE and not InteractionMenuOpen then
            local maxDistance = 75

            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), maxDistance)) do
                if IsValid(ent) and ent:IsPlayer() and ent ~= ply and ent:Alive() then
                    if IsPlayerInRangeAndLookingAt(ply, ent) then
                        CreateInteractionMenu(ent)
                        InteractionMenuOpen = true
                        break
                    end
                end
            end
        end
    end)

    hook.Add("KeyRelease", "CloseInteractionMenu", function(ply, key)
        if key == IN_USE then
            if IsValid(InteractionMenu) then
                InteractionMenu:Remove()
                gui.EnableScreenClicker(false)
            end
            InteractionMenuOpen = false
        end
    end)
end
