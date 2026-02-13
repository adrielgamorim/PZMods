ReadingPlusHelpers = {}

function ReadingPlusHelpers:getLiteratureState(character, item)
	local skillBook = SkillBook[item:getSkillTrained()]
	local isSkillBook = skillBook ~= nil
	local isTooAdvanced
	if item:getLvlSkillTrained() ~= -1 or (skillBook and skillBook.perk) then
		isTooAdvanced = item:getLvlSkillTrained() > character:getPerkLevel(skillBook.perk) + 1
	end
	local wasAlreadyRead
	if isSkillBook then
		local readPages = character:getAlreadyReadPages(item:getFullType())
		wasAlreadyRead = readPages >= item:getNumberOfPages()
	else
		wasAlreadyRead = ISInventoryPane:isLiteratureRead(character, item)
	end

	return {
		isTooAdvanced = isTooAdvanced,
		wasAlreadyRead = wasAlreadyRead,
	}
end
