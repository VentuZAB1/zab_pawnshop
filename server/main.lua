local qbx = require '@qbx_core/modules/lib'
local playerCooldowns = {}

-- Security: Validate player and transaction
local function validateTransaction(source, itemName, quantity, totalPrice)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    -- Check cooldown
    local playerId = Player.PlayerData.citizenid
    if playerCooldowns[playerId] and (GetGameTimer() - playerCooldowns[playerId]) < Config.CooldownTime then
        return false, "Transaction cooldown active"
    end
    
    -- Validate item exists in config
    local itemConfig = nil
    for _, item in pairs(Config.Items) do
        if item.item == itemName then
            itemConfig = item
            break
        end
    end
    
    if not itemConfig then
        return false, "Invalid item"
    end
    
    -- Validate quantity
    if quantity <= 0 or quantity > itemConfig.maxQuantity then
        return false, "Invalid quantity"
    end
    
    -- Validate price calculation
    local expectedPrice = itemConfig.price * quantity
    if totalPrice ~= expectedPrice then
        return false, "Price mismatch"
    end
    
    -- Check max transaction amount
    if totalPrice > Config.MaxTransactionAmount then
        return false, "Transaction amount too high"
    end
    
    -- Check if player has the item (handle non-stackable items)
    local inventory = exports.ox_inventory:GetInventoryItems(source)
    local totalCount = 0
    
    if inventory then
        for _, invItem in pairs(inventory) do
            if invItem.name == itemName and invItem.count > 0 then
                totalCount = totalCount + invItem.count
            end
        end
    end
    
    if totalCount < quantity then
        return false, "Insufficient items"
    end
    
    return true, itemConfig
end

-- Secure callback for selling items
lib.callback.register('zab_pawnshop:sellItem', function(source, itemName, quantity)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return {success = false, message = "Player not found"} end
    
    local totalPrice = 0
    for _, item in pairs(Config.Items) do
        if item.item == itemName then
            totalPrice = item.price * quantity
            break
        end
    end
    
    local isValid, result = validateTransaction(source, itemName, quantity, totalPrice)
    if not isValid then
        return {success = false, message = result}
    end
    
    -- Set cooldown
    local playerId = Player.PlayerData.citizenid
    playerCooldowns[playerId] = GetGameTimer()
    
    -- Remove item from inventory
    local removed = exports.ox_inventory:RemoveItem(source, itemName, quantity)
    if not removed then
        return {success = false, message = "Failed to remove item"}
    end
    
    -- Add money to player using ox_inventory
    local moneyAdded = false
    if Config.Currency == "cash" then
        moneyAdded = exports.ox_inventory:AddItem(source, 'money', totalPrice)
    elseif Config.Currency == "bank" then
        -- For bank, still use QBCore as it's account-based
        moneyAdded = Player.Functions.AddMoney('bank', totalPrice)
    else
        -- For custom currency, use ox_inventory
        moneyAdded = exports.ox_inventory:AddItem(source, Config.Currency, totalPrice)
    end
    
    if not moneyAdded then
        -- Rollback: give item back
        exports.ox_inventory:AddItem(source, itemName, quantity)
        return {success = false, message = "Failed to process payment"}
    end
    
    -- Log transaction for security
    print(string.format("[PAWNSHOP] Player %s (%s) sold %dx %s for $%d", 
        Player.PlayerData.name, Player.PlayerData.citizenid, quantity, itemName, totalPrice))
    
    -- Get updated balance
    local newBalance = 0
    if Config.Currency == "bank" then
        newBalance = Player.PlayerData.money.bank or 0
    else
        -- For cash/custom currency, get from ox_inventory
        local moneyCount = exports.ox_inventory:GetItemCount(source, Config.Currency == "cash" and "money" or Config.Currency)
        newBalance = moneyCount or 0
    end
    
    return {
        success = true, 
        message = string.format("Sold %dx %s for $%d", quantity, result.label, totalPrice),
        newBalance = newBalance
    }
end)

-- Secure callback for getting player items
lib.callback.register('zab_pawnshop:getPlayerItems', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return {} end
    
    local playerItems = {}
    local inventory = exports.ox_inventory:GetInventoryItems(source)
    
    -- Show all config items, but only from enabled categories
    for _, configItem in pairs(Config.Items) do
        -- Check if the category is enabled
        local categoryEnabled = false
        for _, category in pairs(Config.Categories) do
            if category.id == configItem.category and category.enabled then
                categoryEnabled = true
                break
            end
        end
        
        -- Skip items from disabled categories
        if not categoryEnabled then
            goto continue
        end
        
        local playerCount = 0
        local hasItem = false
        
        -- Check if player has this item in inventory (handle non-stackable items)
        if inventory then
            for _, invItem in pairs(inventory) do
                if invItem.name == configItem.item and invItem.count > 0 then
                    playerCount = playerCount + invItem.count
                    hasItem = true
                    -- Don't break here - continue counting all instances for non-stackable items
                end
            end
        end
        
        table.insert(playerItems, {
            item = configItem.item,
            label = configItem.label,
            count = playerCount,
            price = configItem.price,
            maxQuantity = hasItem and math.min(configItem.maxQuantity, playerCount) or 0,
            category = configItem.category,
            image = configItem.image,
            hasItem = hasItem,
            locked = not hasItem
        })
        
        ::continue::
    end
    
    return playerItems
end)

-- Security: Anti-spam protection
AddEventHandler('playerDropped', function()
    local source = source
    local Player = exports.qbx_core:GetPlayer(source)
    if Player then
        playerCooldowns[Player.PlayerData.citizenid] = nil
    end
end)

-- Server doesn't handle blips - moved to client-side
