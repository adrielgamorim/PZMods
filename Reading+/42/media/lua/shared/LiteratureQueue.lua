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
		local state = ReadingPlusHelpers:getLiteratureState(character, entry.item)

		if filter == "advanced" then
			if state.isTooAdvanced then table.insert(indexesToRemove, i) end
		elseif filter == "alreadyRead" then
			if state.wasAlreadyRead then table.insert(indexesToRemove, i) end
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