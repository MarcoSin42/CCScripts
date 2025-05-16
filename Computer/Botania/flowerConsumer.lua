local modem = peripheral.find("modem") or error("No modem detected")
local flower = peripheral.find("manaFlower") or error("No flower detected")

local rx = 42
local event, side, channel, replyChannel, message, distance

while true do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    redstone.setOutput("top", 1)
    sleep(0.05)
    redstone.setOutput("top", 0)
    transmit(replyChannel, rx, " ")
end