local queue = {}

LiteratureQueue = {}

function LiteratureQueue:clear()
	queue = {}
end

function LiteratureQueue:add(item, container)
	if not LiteratureQueue:getByName(item:getName()) then
		table.insert(queue, { item = item, container = container })
	end
end

function LiteratureQueue:getAll()
	return queue
end

function LiteratureQueue:get(index)
	return queue[index]
end

function LiteratureQueue:getByName(name)
	for i, entry in ipairs(queue) do
		if entry.item:getName() == name then
			return entry, i
		end
	end
	return nil
end

function LiteratureQueue:getItem(index)
	if queue[index] then
		return queue[index].item
	end
	return nil
end

function LiteratureQueue:getContainer(index)
	if queue[index] then
		return queue[index].container
	end
	return nil
end

function LiteratureQueue:removeFirst()
	table.remove(queue, 1)
end

function LiteratureQueue:filter(character, filter)
	local indexesToRemove = {}

	for i, entry in ipairs(queue) do
		local skillBook = SkillBook[entry.item:getSkillTrained()]
		local isSkillBook = skillBook ~= nil
		local isTooAdvanced
		if entry.item:getLvlSkillTrained() ~= -1 or (skillBook and skillBook.perk) then
			isTooAdvanced = entry.item:getLvlSkillTrained() > character:getPerkLevel(skillBook.perk) + 1
		end
		local wasAlreadyRead
		if isSkillBook then
			wasAlreadyRead = entry.item:getAlreadyReadPages() >= entry.item:getNumberOfPages()
		else
			wasAlreadyRead = ISInventoryPane:isLiteratureRead(character, entry.item)
		end

		if filter == "advanced" then
			if isTooAdvanced then table.insert(indexesToRemove, i) end
		elseif filter == "alreadyRead" then
			if wasAlreadyRead then table.insert(indexesToRemove, i) end
		end
	end

	table.sort(indexesToRemove, function(a, b)
		return a > b
	end)
	for _, index in ipairs(indexesToRemove) do
		table.remove(queue, index)
	end

	indexesToRemove = {}
end

function LiteratureQueue:isEmpty()
	return #queue <= 0
end