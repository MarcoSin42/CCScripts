local modem = peripheral.find("modem") or error("No modem detected")
local flower = peripheral.find("manaFlower") or error("No flower detected")

local function delay(seconds)
	-- safe version of 'sleep' - will requeue dropped events
	local timer = os.startTimer(seconds)
	local q = {}
	while true do
		local data = {os.pullEvent()}
		if data[1] == "timer" and data[2] == timer then
			break
		else
			table.insert(q, data)
		end
	end
	for i,v in ipairs(q) do
		os.queueEvent(unpack(v))
	end
end

local rx = os.getComputerID()
local tx = 42
modem.open(rx)
print("My ID is: ",rx)
while true do
    if flower.isEmpty() then
        print("flowerEmpty")
        modem.transmit(tx, rx, rx)
        print("Transmitted msg")
        delay(4)
        -- Waits until request is fulfilled before checking again
        local event, side, channel, replyChannel, message, distance
        repeat
            event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        until channel == rx
        print("Cleared")
    end
end
