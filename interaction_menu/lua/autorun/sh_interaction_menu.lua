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

local function DrawRainbowText(text, font, x, y, alignment)
    local startHue = CurTime() * 50
    surface.SetFont(font)
    local width, _ = surface.GetTextSize(text)
    
    for i = 1, string.len(text) do
        local char = string.sub(text, i, i)
        local hue = (startHue + (i * 10)) % 360
        local color = HSVToColor(hue, 1, 1)
        draw.SimpleText(char, font, x + (i - 1) * (width / string.len(text)), y, color, alignment)
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

local function CreateInteractionMenu(targetPlayer)
    if IsValid(InteractionMenu) then
        InteractionMenu:Remove()
    end

    gui.EnableScreenClicker(true)

    local frame = vgui.Create("DFrame")
    frame:SetSize(200, 250)
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetMinWidth(200)
    frame:SetMinHeight(250)
    frame:SetPos(-1000, -1000)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 220))

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
            DrawRainbowText(rank, "DermaLarge", w / 2 - rankTextWidth / 2, 5, TEXT_ALIGN_LEFT)
        else
            draw.SimpleText(rank, "DermaLarge", w / 2, 5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("Money: $" .. string.Comma(GetPlayerMoney(targetPlayer)), "DermaDefaultBold", 10, h - 80, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        draw.SimpleText("FPS: " .. tostring(math.Round(1 / RealFrameTime(), 0)), "DermaDefaultBold", 10, h - 50, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        draw.SimpleText("Ping: " .. tostring(targetPlayer:Ping()), "DermaDefaultBold", 10, h - 30, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    end

    local function CreateButton(parent, text, yPos, onClick)
        local button = vgui.Create("DButton", parent)
        button:SetText(text)
        button:SetSize(180, 30)
        button:SetPos(10, yPos)
        button:SetTextColor(Color(255, 255, 255))
        button.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(70, 70, 70, 200) or Color(50, 50, 50, 200)
            draw.RoundedBox(8, 0, 0, w, h, color)
        end
        button.DoClick = onClick
        button:SetTooltip(text)
        return button
    end

    CreateButton(frame, "Give Money", 40, function()
        local trace = LocalPlayer():GetEyeTrace()
        if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
            local amountMenu = vgui.Create("DFrame")
            amountMenu:SetSize(200, 100)
            amountMenu:SetTitle("Enter Amount")
            amountMenu:Center()
            amountMenu:MakePopup()
            amountMenu.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 220))
            end

            local amountEntry = vgui.Create("DTextEntry", amountMenu)
            amountEntry:SetSize(180, 30)
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
            end)
        end
    end)

    CreateButton(frame, "Mug", 90, function()
        local mugMenu = vgui.Create("DFrame")
        mugMenu:SetSize(200, 250)
        mugMenu:Center()
        mugMenu:MakePopup()
        mugMenu:SetTitle("Mug Menu")
        mugMenu:SetDraggable(false)
        mugMenu.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 220))
        end

        local mugAmounts = {10000, 25000, 50000, 75000, 100000}
        for i, amount in ipairs(mugAmounts) do
            CreateButton(mugMenu, "Mug $" .. string.Comma(amount), 40 + (i - 1) * 40, function()
                RunConsoleCommand("say", "/advert Mug " .. targetPlayer:Nick() .. " $" .. string.Comma(amount))
                mugMenu:Close()
            end)
        end
    end)

    frame:SetMouseInputEnabled(true)
    InteractionMenu = frame

    hook.Add("Think", "UpdateInteractionMenuPosition", function()
        if IsValid(targetPlayer) and IsValid(frame) then
            local hipPos = GetHipBonePosition(targetPlayer)
            local pos = hipPos:ToScreen()
            frame:SetPos(pos.x - 400, pos.y - 200)

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
