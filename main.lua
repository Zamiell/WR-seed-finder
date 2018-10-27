-- WR Seed Getter
-- by Zamiel

-- This mod will look for a world record seed.
local WRSeedGetter = RegisterMod("Racing+", 1)

-- Global variables
WRSeedGetter.restart = false
WRSeedGetter.attempts = 0

-- ModCallbacks.MC_POST_RENDER (2)
function WRSeedGetter:PostRender()
  if WRSeedGetter.restart then
    WRSeedGetter.restart = false
    WRSeedGetter.attempts = WRSeedGetter.attempts + 1
    if WRSeedGetter.attempts % 1000 == 0 then
      Isaac.DebugString("On attempt: " .. tostring(WRSeedGetter.attempts))
    end
    Isaac.ExecuteCommand("restart")
    return
  end
end

-- ModCallbacks.MC_POST_GAME_STARTED (15)
function WRSeedGetter:PostGameStarted(saveState)
  if WRSeedGetter:Check() then
    local game = Game()
    local seeds = game:GetSeeds()
    local seed = seeds:GetStartSeedString()
    Isaac.DebugString("Found good seed: " .. seed)
  else
    -- Doing a "restart" here does not work for some reason, so mark to do it on the next frame
    WRSeedGetter.restart = true
  end
end

function WRSeedGetter:Check()
  -- We need an Emperor card
  local game = Game()
  local player = game:GetPlayer(0)
  local card = player:GetCard(0)
  if card ~= Card.CARD_EMPEROR then -- 5
    return false
  end

  -- We need Scapular and Mega Blast
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SCAPULAR) == false or -- 142
     player:HasCollectible(CollectibleType.COLLECTIBLE_MEGA_SATANS_BREATH) == false then -- 441

    return false
  end

  -- We need a Sacrifice Room attached
  local room = game:GetRoom()
  local sacRoomAttached = false
  for i = 0, 3 do -- The starting room will only ever have 4 doors
    local door = room:GetDoor(i)
    if door ~= nil and
       door.TargetRoomType == RoomType.ROOM_SACRIFICE then -- 13

      sacRoomAttached = true
      break
    end
  end
  if sacRoomAttached == false then
    return false
  end

  return true

  -- This other method is probably slower
  --[[
  -- We need a seed with at least 2 red heart containers
  local maxHearts = player:GetMaxHearts()
  if maxHearts < 4 then
    return false
  end

  -- Check for the presence of a Sacrifice Room
  local level = game:GetLevel()
  local rooms = level:GetRooms()
  local foundSacRoom = false
  for i = 0, rooms.Size - 1 do -- This is 0 indexed
    local roomDesc = rooms:Get(i)
    local roomData = roomDesc.Data
    local roomType = roomData.Type
    local roomVariant = roomData.Variant
    if roomType == RoomType.ROOM_SACRIFICE and -- 13
       roomVariant == 9 then -- This is the room with 4 Scared Hearts

      foundSacRoom = true
      break
    end
  end
  if foundSacRoom == false then
    return false
  end
  Isaac.DebugString("Found good Sacrifice Room on attempt: " .. tostring(WRSeedGetter.attempts))

  -- Make sure that we have a good card
  local card = player:GetCard(0)
  local deck = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_STARTER_DECK) then -- 251
    deck = true
  end
  if card ~= Card.CARD_EMPEROR and -- 5
     deck == false then

    return false
  end
  local chaos = false
  if deck then
    -- Find the identity of the dropped card
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, -- 5.300
                                      -1, false, false)
    local droppedCard = entities[1].SubType
    if (card == Card.CARD_EMPEROR and -- 5
        droppedCard == Card.CARD_CHAOS) or -- 42
       (card == Card.CARD_CHAOS and -- 42
        droppedCard == Card.CARD_EMPEROR) then -- 5

      chaos = true
    end
    if chaos == false then
      return false
    end
  end
  Isaac.DebugString("Found good Sacrifice Room AND good card(s) on attempt: " .. tostring(WRSeedGetter.attempts))

  -- We need a seed with killing power
  local knife = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then -- 114
    knife = true
  end
  local dagger = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER) then -- 172
    dagger = true
  end
  local bloodRights = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_RIGHTS) then -- 186
    bloodRights = true
  end
  local isaacsHeart = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_ISAACS_HEART) then -- 276
    isaacsHeart = true
  end
  local megaBlast = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MEGA_SATANS_BREATH) then -- 441
    megaBlast = true
  end
  local planC = false
  if player:HasCollectible(CollectibleType.COLLECTIBLE_PLAN_C) then -- 475
    planC = true
  end

  if chaos or
     knife or
     dagger or
     (bloodRights and isaacsHeart) or
     megaBlast then

    return true
  end
  --]]
end

WRSeedGetter:AddCallback(ModCallbacks.MC_POST_RENDER, WRSeedGetter.PostRender) -- 2
WRSeedGetter:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WRSeedGetter.PostGameStarted) -- 15

Isaac.DebugString("+-----------------------------+")
Isaac.DebugString("| WR Seed Getter initialized. |")
Isaac.DebugString("+-----------------------------+")
