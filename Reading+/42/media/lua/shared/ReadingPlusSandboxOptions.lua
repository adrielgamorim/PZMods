ReadingPlusSandboxOptions = {}

function ReadingPlusSandboxOptions.getSittingRate()
	return getSandboxOptions():getOptionByName("ReadingPlus.SittingSpeedMultiplier"):getValue()
end

function ReadingPlusSandboxOptions.getEnableReadWalking()
	return getSandboxOptions():getOptionByName("ReadingPlus.EnableWhileWalking"):getValue()
end

function ReadingPlusSandboxOptions.getEnableConfirmationDialog()
	return getSandboxOptions():getOptionByName("ReadingPlus.EnableConfirmationDialog"):getValue()
end

function ReadingPlusSandboxOptions.getFilterAlreadyReadBooks()
  return getSandboxOptions():getOptionByName("ReadingPlus.FilterAlreadyReadBooks"):getValue()
end

function ReadingPlusSandboxOptions.getFilterAboveLevelBooks()
  return getSandboxOptions():getOptionByName("ReadingPlus.FilterAboveLevelBooks"):getValue()
end
