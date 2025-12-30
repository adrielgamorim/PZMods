local modId = "Reading+"
local rate = 0.1

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

local ogISReadABookIs_valid = ISReadABook.isValid
local ogISReadABook_new = ISReadABook.new
local ogISReadABook_stop = ISReadABook.stop

function ISReadABook:isValid(...)
	return ogISReadABookIs_valid(self, ...) and
    (self.character:isTimedActionInstant() or
    isSitting(self.character) == self[modId]["previousIsSitting"])
end

function ISReadABook:stop(...)
	local og = ogISReadABook_stop(self, ...)

	if not self.character:isTimedActionInstant() then
		local isSitting = isSitting(self.character)
		if isSitting and isSitting ~= self[modId]["previousIsSitting"] then
			ISTimedActionQueue.add(ISReadABook:new(self.character, self.item, self.initialTime))
		end
	end

	return og
end

function ISReadABook:new(character, item, time, ...)
	local og = ogISReadABook_new(self, character, item, time, ...)
  og.stopOnWalk = false;

	if not og.character:isTimedActionInstant() then
		local previousIsSitting = isSitting(character)
		og[modId] = {["previousIsSitting"] = previousIsSitting}
		if previousIsSitting then
			og.maxTime = math.floor(og.maxTime * rate)
		end
	end

	return og
end
