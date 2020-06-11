GWNotifications = {}
GWNotifications.ActiveNotifications = {}

function GWNotifications:Add(uuid, header, text, duration, ply)
    if SERVER then
        net.Start("gwSendNotification")
        net.WriteString(uuid)
        net.WriteString(header)
        net.WriteString(text)
        net.WriteFloat(duration)
        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
        return
    end

    if text ~= "" then
        text = markup.Parse(text, GWNotifications:GetMaxWidth())
    else
        text = nil
    end

    GWNotifications.ActiveNotifications[uuid] = {
        text = text,
        header = markup.Parse(header, GWNotifications:GetMaxWidth()),
        duration = math.max(duration, self:GetMinDuration()),
        startTime = SysTime(),
    }
end

net.Receive("gwSendNotification", function(len)
    GWNotifications:Add(
        net.ReadString(uuid),
        net.ReadString(header),
        net.ReadString(text),
        net.ReadFloat(duration)
    )
end)

function GWNotifications:GetMaxWidth()
    return ScrW() / 6
end

function GWNotifications:GetFadeDuration()
    return 0.75
end

function GWNotifications:GetMinDuration()
    return self:GetFadeDuration() * 4
end

function GWNotifications:Remove(uuid)
    GWNotifications.ActiveNotifications[uuid] = nil
end

function GWNotifications:Draw()
    local yoffset  = ScrH() / 2 - 100
    local padding = 10
    local xStart = ScrW() - GWNotifications:GetMaxWidth() - padding * 2
    local width = GWNotifications:GetMaxWidth() + padding * 2 + 2 -- +2 because of weird gap

    for uuid, notifcation in pairs(self.ActiveNotifications) do
        if notifcation.startTime + notifcation.duration < SysTime() then
            self.ActiveNotifications[uuid] = nil
        else
            local height = notifcation.header:GetHeight() + padding * 2

            if notifcation.text then
                height = height + notifcation.text:GetHeight()  + padding * 2
            end

            local lifeTime = (SysTime() - notifcation.startTime)

            local timeRatio = lifeTime / notifcation.duration

            local fadeDuration = GWNotifications:GetFadeDuration()

            local xStartAnimated = xStart
            if lifeTime <= fadeDuration then
                xStartAnimated = xStartAnimated + width * (fadeDuration - lifeTime) * (1 / fadeDuration)
            end
            if notifcation.duration - lifeTime <= fadeDuration then
                xStartAnimated = xStartAnimated + width * math.abs(notifcation.duration - lifeTime - fadeDuration) * (1 / fadeDuration)
            end

            surface.SetDrawColor(clrs.darkgreybg)
            surface.DrawRect(xStartAnimated, yoffset, width, height + 5)
            surface.SetDrawColor(team.GetColor(LocalPlayer():Team()))
            surface.DrawRect(xStartAnimated + width * timeRatio, yoffset + height, width, 5)

            notifcation.header:Draw(xStartAnimated + padding + GWNotifications:GetMaxWidth() / 2 - notifcation.header:GetWidth() / 2, yoffset + padding, 0, 0)

            if notifcation.text then
                notifcation.text:Draw(xStartAnimated + padding, yoffset + notifcation.header:GetHeight() + padding * 2, 0, 0)
            end

            yoffset = yoffset + height
        end
    end
end

hook.Add( "HUDPaint", "CHuntHUDNotifications", function() GWNotifications:Draw() end)

