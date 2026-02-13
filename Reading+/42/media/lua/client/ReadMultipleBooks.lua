function SitAndOrWaitForSit(character, doFunction, doSit)
	if doSit then
		ISTimedActionQueue.add(ISSitOnGround:new(character))
	end
	local function checkSitting()
		if character:isSitOnGround() then
			doFunction()
			Events.OnPlayerUpdate.Remove(checkSitting)
		end
	end
	Events.OnPlayerUpdate.Add(checkSitting)
end

function ReadSelected(playerNum, doSit)
	local character = getSpecificPlayer(playerNum)
	local queue = LiteratureQueue:getAll()

	if character and queue then
		local function queueReading()
			for i = 1, #queue do
				local entry = queue[i]
				ISInventoryPaneContextMenu.readItem(entry.item, playerNum)
			end
		end

		if doSit == nil then
			queueReading()
		else
			SitAndOrWaitForSit(character, queueReading, doSit)
		end
	end
end

local function readSelectedContextMenuOption(playerNum, context, items)
	local actualItems = ISInventoryPane.getActualItems(items)
	local character = getSpecificPlayer(playerNum)
	LiteratureQueue:clear()

	for _, item in ipairs(actualItems) do
		if instanceof(item, "InventoryItem") and item:getCategory() == "Literature" then
			if not LiteratureQueue:getByName(item:getName()) then
				LiteratureQueue:add(item, item:getContainer())
			end
		end
	end

	local function createButtonForSingleLiteratureItem()
		if not IsSitting(character) then
			local sitAndRead = context:insertOptionAfter(
				getText("ContextMenu_Read"),
				getText("ContextMenu_ReadingPlus_SitAndReadBook"),
				playerNum,
				ReadSelected,
				true)
			sitAndRead.iconTexture = LiteratureQueue:getItem(1):getTexture()
			local literatureState = ReadingPlusHelpers:getLiteratureState(character, LiteratureQueue:getItem(1))
			local cannotRead = literatureState.isTooAdvanced or literatureState.wasAlreadyRead
			if cannotRead then sitAndRead.notAvailable = true end
		end
	end

	if #LiteratureQueue:getAll() == 1 then
		createButtonForSingleLiteratureItem()
		return
	end

	if ReadingPlusSandboxOptions.getFilterAboveLevelBooks() then
		LiteratureQueue:filter(character, "advanced")
	end
	if ReadingPlusSandboxOptions.getFilterAlreadyReadBooks() then
		LiteratureQueue:filter(character, "alreadyRead")
	end

	if #LiteratureQueue:getAll() == 1 then
		createButtonForSingleLiteratureItem()
		return
	end

	if LiteratureQueue:isEmpty() then return end

	local iconTexture = getTexture("media/ui/ReadingPlus_icon.png")

	local readSelectedOption = context:insertOptionAfter(
		getText("ContextMenu_Equip_Secondary"),
		getText("ContextMenu_ReadingPlus_ReadSelectedBooks"),
		playerNum,
		ReadSelected)
	readSelectedOption.iconTexture = iconTexture

	if not IsSitting(character) then
		local sitAndReadSelectedOption = context:insertOptionAfter(
			getText("ContextMenu_ReadingPlus_ReadSelectedBooks"),
			getText("ContextMenu_ReadingPlus_SitAndReadSelectedBooks"),
			playerNum,
			ReadSelected,
			true)
		sitAndReadSelectedOption.iconTexture = iconTexture
	end
end

Events.OnFillInventoryObjectContextMenu.Add(readSelectedContextMenuOption)
