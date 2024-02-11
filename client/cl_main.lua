-- Enable Global Slipstream
local cici = false

CreateThread(function()
    Wait(1000)
    SetEnableVehicleSlipstreaming(true)
    if Config.Debug then 
        print("Slip Stream Enabled")
    end
end)

-- Global Loop
CreateThread(function()
    while true do 
        Wait(1000)
        local myped = PlayerPedId()
        if IsPedInAnyVehicle(myped, false) then 
            local mycar = GetVehiclePedIsIn(myped, false)
            local slip = IsVehicleSlipstreamLeader(mycar) == 1
            if slip then 
                if cici then
                    cici = false
                end
                TriggerServerEvent('bbv-slipstream:sync', true, NetworkGetNetworkIdFromEntity(mycar))
            else
                if not cici then
                    TriggerServerEvent('bbv-slipstream:sync', false, NetworkGetNetworkIdFromEntity(mycar))
                    cici = true
                end
            end
            local slipam = GetVehicleCurrentSlipstreamDraft(GetVehiclePedIsIn(PlayerPedId(),false))
            if slipam > 1.0 then 
                ShakeGameplayCam('SKY_DIVING_SHAKE', 0.75)
            else
                StopGameplayCamShaking(true)
            end
        end
    end
end)

RegisterNetEvent('bbv-slipstream:client:sync',function(enabled,car)
    if not NetworkDoesEntityExistWithNetworkId(car) then return end -- neen sync
    local veh = NetworkGetEntityFromNetworkId(car)
    SetVehicleLightTrailEnabled(veh,enabled)
end)


-- trails code from : https://github.com/swcfx/sw-nitro/blob/master/client/trails.lua

local vehicles = {}
local particles = {}

function IsVehicleLightTrailEnabled(vehicle)
    return vehicles[vehicle] == true
end

function SetVehicleLightTrailEnabled(vehicle, enabled)
    if IsVehicleLightTrailEnabled(vehicle) == enabled then
      return
    end
    
    if enabled then
      local ptfxs = {}
      
      local leftTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_l"), 1.0)
      local rightTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_r"), 1.0)
      
      table.insert(ptfxs, leftTrail)
      table.insert(ptfxs, rightTrail)
  
      vehicles[vehicle] = true
      particles[vehicle] = ptfxs
    else
      if particles[vehicle] and #particles[vehicle] > 0 then
        for _, particleId in ipairs(particles[vehicle]) do
          StopVehicleLightTrail(particleId, 500)
        end
      end
  
      vehicles[vehicle] = nil
      particles[vehicle] = nil
    end
  end


function CreateVehicleLightTrail(vehicle, bone, scale)
    UseParticleFxAssetNextCall('core')
    local ptfx = StartParticleFxLoopedOnEntityBone('veh_light_red_trail', vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, bone, scale, false, false, false)
    SetParticleFxLoopedEvolution(ptfx, "speed", 1.0, false)
    return ptfx
  end
  
  function StopVehicleLightTrail(ptfx, duration)
    CreateThread(function()
      local startTime = GetGameTimer()
      local endTime = GetGameTimer() + duration
      while GetGameTimer() < endTime do 
        Wait(0)
        local now = GetGameTimer()
        local scale = (endTime - now) / duration
        SetParticleFxLoopedScale(ptfx, scale)
        SetParticleFxLoopedAlpha(ptfx, scale)
      end
      StopParticleFxLooped(ptfx)
    end)
  end