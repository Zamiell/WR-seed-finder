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
  end

  -- Doing a "restart" here does not work for some reason, so mark to do it on the next frame
  WRSeedGetter.restart = true
end

function WRSeedGetter:Check()
  -- We need an Emperor card
  local game = Game()
  local player = game:GetPlayer(0)
  local card = player:GetCard(0)
  if card ~= Card.CARD_EMPEROR then -- 5
    return false
  end

  -- We need Sacrificial Dagger
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER) == false then -- 172
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
end

WRSeedGetter:AddCallback(ModCallbacks.MC_POST_RENDER, WRSeedGetter.PostRender) -- 2
WRSeedGetter:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WRSeedGetter.PostGameStarted) -- 15

Isaac.DebugString("+-----------------------------+")
Isaac.DebugString("| WR Seed Getter initialized. |")
Isaac.DebugString("+-----------------------------+")
