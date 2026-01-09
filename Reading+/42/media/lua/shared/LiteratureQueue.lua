local items = {}

LiteratureQueue = {}

function LiteratureQueue:clear()
	items = {}
end

function LiteratureQueue:add(item)
	table.insert(items, item)
end

function LiteratureQueue:addMultiple(itemList)
	self:clear()
	for _, item in ipairs(itemList) do
		table.insert(items, item)
	end
end

function LiteratureQueue:getAll()
	return items
end

function LiteratureQueue:get(index)
	return items[index]
end

function LiteratureQueue:removeFirst()
	table.remove(items, 1)
end