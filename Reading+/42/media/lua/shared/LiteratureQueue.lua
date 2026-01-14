local queue = {}

LiteratureQueue = {}

function LiteratureQueue:clear()
	queue = {}
end

function LiteratureQueue:add(item, container)
	table.insert(queue, { item = item, container = container })
end

function LiteratureQueue:addMultiple(itemList)
	self:clear()
	for _, entry in ipairs(itemList) do
		table.insert(queue, entry)
	end
end

function LiteratureQueue:getAll()
	return queue
end

function LiteratureQueue:get(index)
	return queue[index]
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

function LiteratureQueue:isEmpty()
	return #queue == 0
end