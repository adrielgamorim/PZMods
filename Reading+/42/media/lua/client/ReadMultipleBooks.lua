function ReadSelected(playerNum)
	local character = getSpecificPlayer(playerNum)
	local items = LiteratureQueue:getAll()

	if character and items then
		for i = 1, #items do
			local item = items[i]
			ISInventoryPaneContextMenu.readItem(item, playerNum)
		end
	end

end

local function readSelectedContextMenuOption(playerNum, context, items)
	local actualItems = ISInventoryPane.getActualItems(items)
	LiteratureQueue:clear()

	for _, item in ipairs(actualItems) do
		if instanceof(item, "InventoryItem") and item:getCategory() == "Literature" then
			LiteratureQueue:add(item)
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
