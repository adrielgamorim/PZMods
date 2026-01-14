function ReadSelected(playerNum)
	local character = getSpecificPlayer(playerNum)
	local queue = LiteratureQueue:getAll()

	if character and queue then
		for i = 1, #queue do
			local entry = queue[i]
			ISInventoryPaneContextMenu.readItem(entry.item, playerNum)
		end
	end

end

local function readSelectedContextMenuOption(playerNum, context, items)
	local actualItems = ISInventoryPane.getActualItems(items)
	LiteratureQueue:clear()

	for _, item in ipairs(actualItems) do
		if instanceof(item, "InventoryItem") and item:getCategory() == "Literature" then
			local container = item:getContainer()
			LiteratureQueue:add(item, container)
		end
	end

	if #LiteratureQueue:getAll() <= 1 then return end

	local readSelectedOption = context:insertOptionAfter(
		getText("ContextMenu_Equip_Secondary"),
		getText("ContextMenu_ReadingPlus_ReadSelectedBooks"),
		playerNum,
		ReadSelected)
	local iconTexture = getTexture("media/ui/ReadingPlus_icon.png")
	readSelectedOption.iconTexture = iconTexture
end

Events.OnFillInventoryObjectContextMenu.Add(readSelectedContextMenuOption)
