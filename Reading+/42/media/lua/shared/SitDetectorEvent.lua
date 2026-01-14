local SitDetector = {}
SitDetector.wasSitting = {}

if not Events.OnPlayerSitDown then
    LuaEventManager.AddEvent("OnPlayerSitDown")
end

if not Events.OnPlayerStandUp then
    LuaEventManager.AddEvent("OnPlayerStandUp")
end

local function isSittingInCar(character)
    local vehicle = character:getVehicle()
    return vehicle ~= nil and
            (not character:isDriving() or
                not vehicle:isDriver(character))
end

function IsSitting(character)
    return character:isSitOnGround() or
            character:isSittingOnFurniture() or
            isSittingInCar(character)
end

function OnPlayerUpdate(player)
    local playerIndex = player:getPlayerNum()
    local wasSitting = SitDetector.wasSitting[playerIndex] or false
    local isSitting = IsSitting(player)

    if not wasSitting and isSitting then
        print("Reading+: Player sat down!")
        triggerEvent("OnPlayerSitDown", player)
    end

    if wasSitting and not isSitting then
        print("Reading+: Player stood up!")
        triggerEvent("OnPlayerStandUp", player)
    end

    SitDetector.wasSitting[playerIndex] = isSitting
end

Events.OnPlayerUpdate.Add(OnPlayerUpdate)

return SitDetector
