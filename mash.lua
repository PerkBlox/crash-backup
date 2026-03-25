local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local SOURCE_PLACE_ID = 13901460084
local TARGET_PLACE_ID = 15798401969

local WEBHOOK_URL = "https://discord.com/api/webhooks/891808080814309416/aGnHJNo5ZxjlY3IRm-ySHDOxuWBSZ3E8NxgRDjMfuSWGlot4EUiAgQW-387WeqetQYlt"

-- Teleport logic
if game.PlaceId == SOURCE_PLACE_ID then
    print("[Teleport] In Mashle Academy, teleporting to Magic Council...")
    local success, err = pcall(function()
        TeleportService:Teleport(TARGET_PLACE_ID)
    end)
    if not success then
        warn("[Teleport] Failed: " .. tostring(err))
    end
    return
end

-- Everything below only runs inside Magic Council
if game.PlaceId ~= TARGET_PLACE_ID then
    print("[Monitor] Not in Magic Council or Mashle Academy. Doing nothing.")
    return
end

print("[Monitor] In Magic Council. Starting MagicMarkProgression monitor...")

local sessionStart = os.clock()
local previousValue = nil
local targetPlayer = nil

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%dm %ds", mins, secs)
end

local function sendWebhook(newValue, oldValue)
    local elapsed = os.clock() - sessionStart
    local change = newValue - (oldValue or newValue)
    local changeStr = (change >= 0 and "+" or "") .. tostring(change)

    local payload = HttpService:JSONEncode({
        embeds = {
            {
                title = "MagicMarkProgression Updated",
                color = 0x5865F2,
                fields = {
                    {
                        name = "Player",
                        value = "6afety",
                        inline = true
                    },
                    {
                        name = "Change",
                        value = changeStr,
                        inline = true
                    },
                    {
                        name = "New Total",
                        value = tostring(newValue),
                        inline = true
                    },
                    {
                        name = "Time in Magic Council",
                        value = formatTime(elapsed),
                        inline = true
                    }
                },
                footer = {
                    text = "Magic Council Monitor"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    })

    local success, err = pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)

    if success then
        print("[Webhook] Sent - Change: " .. changeStr .. " | Total: " .. tostring(newValue))
    else
        warn("[Webhook] Failed to send: " .. tostring(err))
    end
end

local function getProgression()
    local success, value = pcall(function()
        return Players["6afety"].Data.MagicMarkProgression.Value
    end)
    if success then
        return value
    end
    -- fallback in case it's not a ValueBase instance
    local success2, value2 = pcall(function()
        return Players["6afety"].Data.MagicMarkProgression
    end)
    if success2 then
        return value2
    end
    return nil
end

local function startMonitor()
    -- wait for player to exist
    local timeout = 0
    while not Players:FindFirstChild("6afety") and timeout < 30 do
        wait(1)
        timeout = timeout + 1
    end

    if not Players:FindFirstChild("6afety") then
        warn("[Monitor] Could not find player 6afety in this server.")
        return
    end

    print("[Monitor] Found 6afety. Watching MagicMarkProgression...")

    -- grab initial value
    previousValue = getProgression()
    if previousValue then
        print("[Monitor] Initial MagicMarkProgression value: " .. tostring(previousValue))
    else
        warn("[Monitor] Could not read initial MagicMarkProgression value.")
    end

    -- try hooking .Changed if it's a ValueBase
    local success, _ = pcall(function()
        local obj = Players["6afety"].Data.MagicMarkProgression
        obj.Changed:Connect(function(newValue)
            print("[Monitor] Changed event fired. New: " .. tostring(newValue))
            sendWebhook(newValue, previousValue)
            previousValue = newValue
        end)
        print("[Monitor] Successfully hooked .Changed event.")
    end)

    -- fallback: poll every 2 seconds in case .Changed isn't accessible
    if not success then
        warn("[Monitor] Could not hook .Changed, falling back to polling every 2s.")
        while Players:FindFirstChild("6afety") do
            wait(2)
            local current = getProgression()
            if current and current ~= previousValue then
                print("[Monitor] Polled change detected.")
                sendWebhook(current, previousValue)
                previousValue = current
            end
        end
    end
end

startMonitor()