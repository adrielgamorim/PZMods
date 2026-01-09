local modId = "Reading+"

local function getSittingRate()
	return getSandboxOptions():getOptionByName("ReadingPlus.SittingSpeedMultiplier"):getValue()
end

local function getEnableReadWalking()
	return getSandboxOptions():getOptionByName("ReadingPlus.EnableWhileWalking"):getValue()
end

local function isSittingInCar(character)
	local vehicle = character:getVehicle()
	return vehicle ~= nil and
			(not character:isDriving() or
				not vehicle:isDriver(character))
end

local function isSitting(character)
	return character:isSitOnGround() or
			character:isSittingOnFurniture() or
			isSittingInCar(character)
end

local function resumeReading(self)
	self.character:Say(getText("UI_ReadingPlus_ResumeReading"))
	LiteratureQueue:removeFirst()
	ISTimedActionQueue.add(ISReadABook:new(self.character, self.item))
	ReadSelected(self.character:getPlayerNum())
end

local ogISReadABook_getDuration = ISReadABook.getDuration
local ogISReadABook_isValid = ISReadABook.isValid
local ogISReadABook_new = ISReadABook.new
local ogISReadABook_stop = ISReadABook.stop
local ogISReadABook_perform = ISReadABook.perform

function ISReadABook:getDuration()
	local time = ogISReadABook_getDuration(self)

	if isSitting(self.character) then
		time = time * getSittingRate()
	end

	return time
end

function ISReadABook:isValid(...)
	if not ogISReadABook_isValid(self, ...) then
		return false
	end

	if self.character:isTimedActionInstant() then
		return true
	end

	if isSitting(self.character) ~= self[modId]["previousIsSitting"] then
		return false
	end

	return true
end

function ISReadABook:new(character, item, ...)
	local og = ogISReadABook_new(self, character, item, ...)
	og.stopOnWalk = not getEnableReadWalking()

	if not og.character:isTimedActionInstant() then
		local previousIsSitting = isSitting(character)
		og[modId] = { ["previousIsSitting"] = previousIsSitting }
	end

	return og
end

function ISReadABook:stop(...)
	local og = ogISReadABook_stop(self, ...)

	if not self.character:isTimedActionInstant() then
		local isSit = isSitting(self.character)

		if isSit ~= self[modId]["previousIsSitting"] then
			resumeReading(self)
		end
	end

	return og
end

function ISReadABook:perform(...)
	if LiteratureQueue:get(1) == self.item then
		LiteratureQueue:removeFirst()
	end

	return ogISReadABook_perform(self, ...)
end
