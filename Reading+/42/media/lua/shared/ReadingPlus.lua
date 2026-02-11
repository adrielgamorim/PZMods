local modId = "Reading+"

local function isSittingInCar(character)
    local vehicle = character:getVehicle()
    return vehicle ~= nil and
            (not character:isDriving() or
                not vehicle:isDriver(character))
end

function IsSitting(character)
    return character:isSitOnGround() or
            character:isSittingOnFurniture() or
            isSittingInCar(character)
end

local function resumeReading(self, isFirstQueueItemOnInventory)
	if ReadingPlusSandboxOptions.getEnableConfirmationDialog() then
		self.character:Say(getText("UI_ReadingPlus_ResumeReading"))
	end
	if isFirstQueueItemOnInventory then
		ISTimedActionQueue.add(ISReadABook:new(self.character, self.item))
		ISCraftingUI.ReturnItemToContainer(self.character, LiteratureQueue:getItem(1), LiteratureQueue:getContainer(1))
		LiteratureQueue:removeFirst()
	end
	ReadSelected(self.character:getPlayerNum())
end

local ogISReadABook_getDuration = ISReadABook.getDuration
local ogISReadABook_isValid = ISReadABook.isValid
local ogISReadABook_new = ISReadABook.new
local ogISReadABook_stop = ISReadABook.stop
local ogISReadABook_perform = ISReadABook.perform

function ISReadABook:getDuration()
	local time = ogISReadABook_getDuration(self)

	if IsSitting(self.character) then
		time = time * ReadingPlusSandboxOptions.getSittingRate()
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

	if IsSitting(self.character) ~= self[modId]["previousIsSitting"] then
		return false
	end

	return true
end

function ISReadABook:new(character, item, ...)
	local og = ogISReadABook_new(self, character, item, ...)
	og.stopOnWalk = not ReadingPlusSandboxOptions.getEnableReadWalking()

	if not og.character:isTimedActionInstant() then
		local previousIsSitting = IsSitting(character)
		og[modId] = { ["previousIsSitting"] = previousIsSitting }
	end

	return og
end

function ISReadABook:stop(...)
	local og = ogISReadABook_stop(self, ...)

	if not self.character:isTimedActionInstant() then
		local isSit = IsSitting(self.character)

		if isSit ~= self[modId]["previousIsSitting"] then
			resumeReading(self, true)
		end
	end

	return og
end

function ISReadABook:perform(...)
	local firstItem = LiteratureQueue:getItem(1)
	if firstItem and firstItem:getName() == self.item:getName() then
		LiteratureQueue:removeFirst()
	end

	return ogISReadABook_perform(self, ...)
end
