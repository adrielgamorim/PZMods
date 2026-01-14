local modId = "Reading+"

local function getSittingRate()
	return getSandboxOptions():getOptionByName("ReadingPlus.SittingSpeedMultiplier"):getValue()
end

local function getEnableReadWalking()
	return getSandboxOptions():getOptionByName("ReadingPlus.EnableWhileWalking"):getValue()
end

local function getEnableConfirmationDialog()
	return getSandboxOptions():getOptionByName("ReadingPlus.EnableConfirmationDialog"):getValue()
end

local function resumeReading(self, isFirstQueueItemOnInventory)
	if getEnableConfirmationDialog() then
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
local ogISTimedActionQueue_tick = nil

function ISReadABook:getDuration()
	local time = ogISReadABook_getDuration(self)

	if IsSitting(self.character) then
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

	if IsSitting(self.character) ~= self[modId]["previousIsSitting"] then
		return false
	end

	return true
end

function ISReadABook:new(character, item, ...)
	local og = ogISReadABook_new(self, character, item, ...)
	og.stopOnWalk = not getEnableReadWalking()

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
	if firstItem == self.item then
		LiteratureQueue:removeFirst()
	end

	return ogISReadABook_perform(self, ...)
end

-- if ISTimedActionQueue and ISTimedActionQueue.tick then
-- 	ogISTimedActionQueue_tick = ISTimedActionQueue.tick
-- end

-- print('Reading+: ' .. ISTimedActionQueue, ogISTimedActionQueue_tick)
-- if ISTimedActionQueue and ogISTimedActionQueue_tick then
-- 	function ISTimedActionQueue:tick()
-- 		local action = self.queue[1]
-- 		if action == nil then
-- 			self:clearQueue()
-- 			return
-- 		end
-- 		if not action.character:getCharacterActions():contains(action.action) then
-- 			print('Reading+: ISTimedActionQueue:tick: Literature queue: ' .. tostring(#LiteratureQueue:getAll()))
-- 			if not LiteratureQueue:isEmpty() then
-- 				print('Reading+: ISTimedActionQueue:tick: bugged action, but LiteratureQueue not empty, resuming reading')
-- 				self:resetQueue()
-- 				local character = action.character
-- 				local litQueue = LiteratureQueue:getAll()
-- 				local firstItem = litQueue[1]
-- 				local isFirstQueueItemOnInventory = character:getInventory():contains(firstItem)
-- 				resumeReading({ character = character, item = firstItem }, isFirstQueueItemOnInventory)
-- 				return
-- 			end
-- 		end

-- 		return ogISTimedActionQueue_tick(self)
-- 	end
-- end
