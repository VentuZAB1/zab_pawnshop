local qbx = require '@qbx_core/modules/lib'
local isUIOpen = false
local currentPed = nil

-- Create pawnshop peds and interactions
CreateThread(function()
    for _, location in pairs(Config.Locations) do
        -- Create blip
        if location.blip then
            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipColour(blip, location.blip.color)
            SetBlipScale(blip, location.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(location.blip.label)
            EndTextCommandSetBlipName(blip)
        end
        
        -- Request model
        local model = GetHashKey(location.ped.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        
        -- Create ped
        local ped = CreatePed(4, model, location.ped.coords.x, location.ped.coords.y, location.ped.coords.z - 1.0, location.ped.coords.w, false, true)
        SetEntityHeading(ped, location.ped.coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        -- Create interaction based on config
        if Config.InteractionSystem == "ox_target" or Config.InteractionSystem == "both" then
            -- ox_target interaction
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'pawnshop_interact',
                    icon = 'fas fa-handshake',
                    label = 'Open Pawnshop',
                    onSelect = function()
                        openPawnshop()
                    end,
                    distance = 2.0
                }
            })
        end
        
        if Config.InteractionSystem == "ox_lib" or Config.InteractionSystem == "both" then
            -- ox_lib text UI interaction
            local coords = location.coords
            local textUIShown = false
            CreateThread(function()
                while true do
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - coords)
                    
                    if distance < 3.0 then
                        if not textUIShown then
                            -- Show help text
                            lib.showTextUI('[E] Open Pawnshop', {
                                position = "top-center",
                                icon = 'handshake'
                            })
                            textUIShown = true
                        end
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            lib.hideTextUI()
                            textUIShown = false
                            openPawnshop()
                        end
                    else
                        if textUIShown then
                            lib.hideTextUI()
                            textUIShown = false
                        end
                    end
                    
                    Wait(distance < 10.0 and 100 or 1000)
                end
            end)
        end
    end
end)

-- Open pawnshop UI
function openPawnshop()
    if isUIOpen then return end
    
    lib.callback('zab_pawnshop:getPlayerItems', false, function(playerItems)
        if not playerItems then
            lib.notify({
                title = 'Pawnshop',
                description = 'Unable to load your items',
                type = 'error'
            })
            return
        end
        

        
        isUIOpen = true
        SetNuiFocus(true, true)
        
        SendNUIMessage({
            action = 'openPawnshop',
            data = {
                config = {
                    name = Config.PawnshopName,
                    currency = Config.Currency,
                    categories = Config.Categories,
                    ui = Config.UI,
                    sellerQuotes = Config.SellerQuotes,
                    bulkDiscount = Config.BulkDiscount,
                    maxBuyQuantity = Config.MaxBuyQuantity,
                    enableBuying = Config.EnableBuying
                },
                items = playerItems
            }
        })
    end)
end

-- Close pawnshop UI
function closePawnshop()
    if not isUIOpen then return end
    
    isUIOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closePawnshop'
    })
end

-- NUI Callbacks
RegisterNUICallback('closePawnshop', function(data, cb)
    closePawnshop()
    cb('ok')
end)

RegisterNUICallback('sellItem', function(data, cb)
    local itemName = data.item
    local quantity = data.quantity
    
    if not itemName or not quantity or quantity <= 0 then
        cb({success = false, message = "Invalid data"})
        return
    end
    
    lib.callback('zab_pawnshop:sellItem', false, function(result)
        if result.success then
            lib.notify({
                title = 'Pawnshop',
                description = result.message,
                type = 'success'
            })
            
            -- Refresh items after successful sale
            lib.callback('zab_pawnshop:getPlayerItems', false, function(playerItems)
                SendNUIMessage({
                    action = 'updateItems',
                    data = {
                        items = playerItems or {}
                    }
                })
            end)
        else
            lib.notify({
                title = 'Pawnshop',
                description = result.message,
                type = 'error'
            })
        end
        
        cb(result)
    end, itemName, quantity)
end)

RegisterNUICallback('buyItem', function(data, cb)
    local itemName = data.item
    local quantity = data.quantity
    
    if not itemName or not quantity or quantity <= 0 then
        cb({success = false, message = "Invalid data"})
        return
    end
    
    lib.callback('zab_pawnshop:buyItem', false, function(result)
        if result.success then
            lib.notify({
                title = 'Pawnshop',
                description = result.message,
                type = 'success'
            })
            
            -- Refresh items after successful purchase
            lib.callback('zab_pawnshop:getPlayerItems', false, function(playerItems)
                SendNUIMessage({
                    action = 'updateItems',
                    data = {
                        items = playerItems or {}
                    }
                })
            end)
        else
            lib.notify({
                title = 'Pawnshop',
                description = result.message,
                type = 'error'
            })
        end
        
        cb(result)
    end, itemName, quantity)
end)

RegisterNUICallback('showNotification', function(data, cb)
    lib.notify({
        title = 'Pawnshop',
        description = data.message,
        type = data.type
    })
    cb('ok')
end)

-- Handle resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if isUIOpen then
            closePawnshop()
        end
    end
end)

-- Key mapping for interaction (only when ox_lib is enabled)
if Config.InteractionSystem == "ox_lib" or Config.InteractionSystem == "both" then
    RegisterKeyMapping('pawnshop', 'Open Pawnshop', 'keyboard', 'E')
    RegisterCommand('pawnshop', function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, location in pairs(Config.Locations) do
            local distance = #(playerCoords - location.coords)
            if distance < 3.0 then
                openPawnshop()
                break
            end
        end
    end, false)
end
