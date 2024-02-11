-- Server Sync
RegisterNetEvent('bbv-slipstream:sync',function(enabled,car)
    TriggerClientEvent('bbv-slipstream:client:sync', -1, enabled, car)
end)