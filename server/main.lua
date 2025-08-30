local qbx = require '@qbx_core/modules/lib'
local playerCooldowns = {}

-- Security: Validate player and transaction
local function validateTransaction(source, itemName, quantity, totalPrice, basePrice)
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
    
    -- Validate price calculation (with potential bulk discount)
    local expectedBasePrice = itemConfig.price * quantity
    local expectedFinalPrice = expectedBasePrice
    
    -- Check if bulk discount should be applied to selling
    if Config.BulkDiscount.enabled and Config.BulkDiscount.applyToSelling and quantity >= Config.BulkDiscount.itemsNeededForDiscount then
        local discountAmount = expectedBasePrice * Config.BulkDiscount.discountPercent
        expectedFinalPrice = expectedBasePrice - discountAmount
    end
    
    -- Allow small rounding differences
    if math.abs(totalPrice - expectedFinalPrice) > 0.01 then
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
    
    local basePrice = 0
    for _, item in pairs(Config.Items) do
        if item.item == itemName then
            basePrice = item.price
            break
        end
    end
    
    local totalPrice = basePrice * quantity
    local discountApplied = false
    local discountPercent = 0
    
    -- Check if bulk discount should be applied to selling
    print(string.format("[PAWNSHOP DEBUG] Checking sell discount: enabled=%s, applyToSelling=%s, quantity=%d, required=%d", 
        tostring(Config.BulkDiscount.enabled), tostring(Config.BulkDiscount.applyToSelling), quantity, Config.BulkDiscount.itemsNeededForDiscount))
    
    if Config.BulkDiscount.enabled and Config.BulkDiscount.applyToSelling and quantity >= Config.BulkDiscount.itemsNeededForDiscount then
        discountPercent = Config.BulkDiscount.discountPercent
        local discountAmount = totalPrice * discountPercent
        totalPrice = totalPrice - discountAmount
        discountApplied = true
        print(string.format("[PAWNSHOP DEBUG] Sell discount applied! %d%% off, original: $%d, discounted: $%d", 
            math.floor(discountPercent * 100), basePrice * quantity, totalPrice))
    else
        print("[PAWNSHOP DEBUG] No sell discount applied")
    end
    
    local isValid, result = validateTransaction(source, itemName, quantity, totalPrice, basePrice)
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
    
    -- Create success message
    local message = string.format("Sold %dx %s for $%d", quantity, result.label, totalPrice)
    if discountApplied and Config.BulkDiscount.showDiscountText then
        local discountPercentText = math.floor(discountPercent * 100)
        message = message .. string.format(" (Discount applied: %d%%)", discountPercentText)
    end
    
    return {
        success = true, 
        message = message,
        newBalance = newBalance,
        discountApplied = discountApplied,
        discountPercent = discountApplied and math.floor(discountPercent * 100) or 0
    }
end)

-- Secure callback for getting player items
lib.callback.register('zab_pawnshop:getPlayerItems', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return {} end
    
    local playerItems = {}
    local inventory = exports.ox_inventory:GetInventoryItems(source)
    
    -- Show config items based on buying mode
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
        
        -- Items are always shown, but locked state depends on buying mode
        
        -- Determine if item should be locked based on buying mode
        local isLocked = false
        if Config.EnableBuying then
            -- In buy mode, items are never visually locked (players can buy them)
            -- But selling validation happens in confirmSale()
            isLocked = false
        else
            -- In sell-only mode, lock if player doesn't have item (can't sell, can't buy)
            isLocked = not hasItem
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
            isLocked = isLocked
        })
        
        ::continue::
    end
    
    return playerItems
end)

-- Secure callback for buying items from pawnshop
lib.callback.register('zab_pawnshop:buyItem', function(source, itemName, quantity)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return {success = false, message = "Player not found"} end
    
    -- Find item in config
    local itemConfig = nil
    for _, item in pairs(Config.Items) do
        if item.item == itemName then
            itemConfig = item
            break
        end
    end
    
    if not itemConfig then
        return {success = false, message = "Item not available for purchase"}
    end
    
    -- Check cooldown
    local playerId = Player.PlayerData.citizenid
    if playerCooldowns[playerId] and (GetGameTimer() - playerCooldowns[playerId]) < Config.CooldownTime then
        return {success = false, message = "Transaction cooldown active"}
    end
    
    -- Validate quantity
    if quantity <= 0 then
        return {success = false, message = "Invalid quantity"}
    end
    
    -- Check max buy quantity
    if quantity > Config.MaxBuyQuantity then
        return {success = false, message = string.format("Maximum buy quantity is %d per transaction", Config.MaxBuyQuantity)}
    end
    
    local buyPrice = math.floor(itemConfig.price * 1.4) -- 40% markup for buying
    local totalPrice = buyPrice * quantity
    local discountApplied = false
    local discountPercent = 0
    
    -- Check if bulk discount should be applied to buying
    print(string.format("[PAWNSHOP DEBUG] Checking buy discount: enabled=%s, applyToBuying=%s, quantity=%d, required=%d", 
        tostring(Config.BulkDiscount.enabled), tostring(Config.BulkDiscount.applyToBuying), quantity, Config.BulkDiscount.itemsNeededForDiscount))
    
    if Config.BulkDiscount.enabled and Config.BulkDiscount.applyToBuying and quantity >= Config.BulkDiscount.itemsNeededForDiscount then
        discountPercent = Config.BulkDiscount.discountPercent
        local discountAmount = totalPrice * discountPercent
        totalPrice = totalPrice - discountAmount
        discountApplied = true
        print(string.format("[PAWNSHOP DEBUG] Buy discount applied! %d%% off, original: $%d, discounted: $%d", 
            math.floor(discountPercent * 100), buyPrice * quantity, totalPrice))
    else
        print("[PAWNSHOP DEBUG] No buy discount applied")
    end
    
    -- Check if player has enough money
    local playerMoney = 0
    if Config.Currency == "cash" then
        playerMoney = exports.ox_inventory:GetItemCount(source, 'money') or 0
    elseif Config.Currency == "bank" then
        playerMoney = Player.PlayerData.money.bank or 0
    else
        playerMoney = exports.ox_inventory:GetItemCount(source, Config.Currency) or 0
    end
    
    if playerMoney < totalPrice then
        return {success = false, message = "Insufficient funds"}
    end
    
    -- Remove money from player
    local moneyRemoved = false
    if Config.Currency == "cash" then
        moneyRemoved = exports.ox_inventory:RemoveItem(source, 'money', totalPrice)
    elseif Config.Currency == "bank" then
        moneyRemoved = Player.Functions.RemoveMoney('bank', totalPrice)
    else
        moneyRemoved = exports.ox_inventory:RemoveItem(source, Config.Currency, totalPrice)
    end
    
    if not moneyRemoved then
        return {success = false, message = "Failed to process payment"}
    end
    
    -- Add item to player inventory
    local itemAdded = exports.ox_inventory:AddItem(source, itemName, quantity)
    if not itemAdded then
        -- Rollback: give money back
        if Config.Currency == "cash" then
            exports.ox_inventory:AddItem(source, 'money', totalPrice)
        elseif Config.Currency == "bank" then
            Player.Functions.AddMoney('bank', totalPrice)
        else
            exports.ox_inventory:AddItem(source, Config.Currency, totalPrice)
        end
        return {success = false, message = "Failed to add item to inventory"}
    end
    
    -- Set cooldown
    playerCooldowns[playerId] = GetGameTimer()
    
    -- Log transaction
    print(string.format("[PAWNSHOP] Player %s (%s) bought %dx %s for $%d", 
        Player.PlayerData.name, Player.PlayerData.citizenid, quantity, itemName, totalPrice))
    
    -- Create success message
    local message = string.format("Purchased %dx %s for $%d", quantity, itemConfig.label, totalPrice)
    if discountApplied and Config.BulkDiscount.showDiscountText then
        local discountPercentText = math.floor(discountPercent * 100)
        message = message .. string.format(" (Discount applied: %d%%)", discountPercentText)
    end
    
    return {
        success = true,
        message = message,
        discountApplied = discountApplied,
        discountPercent = discountApplied and math.floor(discountPercent * 100) or 0
    }
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
