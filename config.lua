Config = {}

-- Pawnshop Settings
Config.PawnshopName = "Tech Pawn Exchange"
Config.Currency = "cash" -- cash, bank, crypto

-- Pawnshop Locations
Config.Locations = {
    {
        coords = vector3(910.3431, 3652.9900, 32.6897),
        heading = 240.0,
        blip = {
            sprite = 431,
            color = 5,
            scale = 0.8,
            label = "Pawnshop"
        },
        ped = {
            model = "a_m_m_business_01",
            coords = vector4(910.3431, 3652.9900, 32.6897, 186.5656)
        }
    }
}

-- Items Configuration
Config.Items = {
    -- Electronics
    {
        item = "phone",
        label = "Smartphone",
        price = 150,
        maxQuantity = 5,
        category = "electronics",
        image = "phone.png"
    },
    {
        item = "tablet",
        label = "Tablet Device",
        price = 300,
        maxQuantity = 3,
        category = "electronics",
        image = "tablet.png"
    },
    {
        item = "laptop",
        label = "Gaming Laptop",
        price = 800,
        maxQuantity = 2,
        category = "electronics",
        image = "laptop.png"
    },
    
    -- Jewelry
    {
        item = "goldchain",
        label = "Gold Chain",
        price = 250,
        maxQuantity = 10,
        category = "jewelry",
        image = "goldchain.png"
    },
    {
        item = "diamond_ring",
        label = "Diamond Ring",
        price = 500,
        maxQuantity = 5,
        category = "jewelry",
        image = "diamond_ring.png"
    },
    {
        item = "rolex",
        label = "Luxury Watch",
        price = 1200,
        maxQuantity = 2,
        category = "jewelry",
        image = "rolex.png"
    },
    
    -- Weapons (if enabled)
    {
        item = "weapon_pistol",
        label = "Pistol",
        price = 2500,
        maxQuantity = 1,
        category = "weapons",
        image = "weapon_pistol.png"
    },
    
    -- Misc Items
    {
        item = "lockpick",
        label = "Lockpick Set",
        price = 50,
        maxQuantity = 20,
        category = "tools",
        image = "lockpick.png"
    },
    {
        item = "drill",
        label = "Power Drill",
        price = 180,
        maxQuantity = 8,
        category = "tools",
        image = "drill.png"
    },
    {
        item = "advancedlockpick",
        label = "Advanced Lockpick",
        price = 120,
        maxQuantity = 10,
        category = "tools",
        image = "advancedlockpick.png"
    },
    
    -- Miner Items
    {
        item = "gold",
        label = "Gold Ore",
        price = 45,
        maxQuantity = 50,
        category = "miner",
        image = "gold.png"
    },
    {
        item = "steel",
        label = "Steel Ingot",
        price = 35,
        maxQuantity = 40,
        category = "miner",
        image = "steel.png"
    },
    {
        item = "diamond",
        label = "Raw Diamond",
        price = 85,
        maxQuantity = 20,
        category = "miner",
        image = "diamond.png"
    },
    {
        item = "iron",
        label = "Iron Ore",
        price = 25,
        maxQuantity = 60,
        category = "miner",
        image = "iron.png"
    },
    
    -- Builder Items
    {
        item = "aluminum",
        label = "Aluminum Sheet",
        price = 40,
        maxQuantity = 30,
        category = "builder",
        image = "aluminum.png"
    },
    {
        item = "rubber",
        label = "Rubber Material",
        price = 15,
        maxQuantity = 50,
        category = "builder",
        image = "rubber.png"
    },
    
    -- Recycler Items
    {
        item = "copper",
        label = "Copper Wire",
        price = 20,
        maxQuantity = 40,
        category = "recycler",
        image = "copper.png"
    },
    {
        item = "metalscrap",
        label = "Metal Scrap",
        price = 12,
        maxQuantity = 60,
        category = "recycler",
        image = "metalscrap.png"
    },
    {
        item = "plastic",
        label = "Plastic Waste",
        price = 8,
        maxQuantity = 80,
        category = "recycler",
        image = "plastic.png"
    },
    {
        item = "glass",
        label = "Glass Shards",
        price = 10,
        maxQuantity = 70,
        category = "recycler",
        image = "glass.png"
    }
}

-- Categories for UI organization
-- To enable/disable a category, set enabled = true/false
-- Disabled categories will not show in the UI and their items cannot be sold
Config.Categories = {
    {
        id = "electronics",
        label = "Electronics",
        icon = "fas fa-mobile-alt",
        color = "#00d4ff",
        enabled = true -- Set to false to disable this category
    },
    {
        id = "jewelry",
        label = "Jewelry",
        icon = "fas fa-gem",
        color = "#ffd700",
        enabled = true -- Set to false to disable this category
    },
    {
        id = "weapons",
        label = "Weapons",
        icon = "fas fa-crosshairs",
        color = "#ff4757",
        enabled = false -- DISABLED - Set to true to enable weapons category
    },
    {
        id = "tools",
        label = "Tools",
        icon = "fas fa-tools",
        color = "#7bed9f",
        enabled = true -- Set to false to disable this category
    },
    {
        id = "miner",
        label = "Mining Materials",
        icon = "fas fa-mountain",
        color = "#ffa500",
        enabled = true -- Set to false to disable this category
    },
    {
        id = "builder",
        label = "Construction Materials",
        icon = "fas fa-hammer",
        color = "#4169e1",
        enabled = true -- Set to false to disable this category
    },
    {
        id = "recycler",
        label = "Recycled Materials",
        icon = "fas fa-recycle",
        color = "#32cd32",
        enabled = true -- Set to false to disable this category
    }
}

-- UI Settings
Config.UI = {
    primaryColor = "#8b45c1",
    secondaryColor = "#9333ea",
    accentColor = "#a855f7",
    backgroundColor = "rgba(255, 255, 255, 0.05)",
    textColor = "#ffffff",
    successColor = "#10b981",
    errorColor = "#ef4444",
    warningColor = "#f59e0b"
}

-- Seller Quotes (random messages from the pawnshop owner)
Config.SellerQuotes = {
    "Howdy, whatchu want me to buy?",
    "U got goods? Let me buy them",
    "Those ain't stolen right?",
    "What treasures you bringing me today?",
    "Cash for your junk, that's my business",
    "I don't ask questions, just show me the goods",
    "Everything has a price, what's yours?",
    "One man's trash is my treasure",
    "Got something shiny for me?",
    "I buy anything... for the right price",
    "No receipts needed here, partner",
    "Quality goods get quality cash",
    "What's in the bag today?",
    "I've seen it all, surprise me",
    "Fair prices for fair goods"
}

-- Bulk Discount System
Config.BulkDiscount = {
    enabled = true,                    -- Enable/disable bulk discount system
    itemsNeededForDiscount = 5,        -- Minimum items needed for discount
    discountPercent = 0.15,            -- Discount percentage (0.15 = 15% off)
    showDiscountText = true,           -- Show discount notification
    applyToSelling = false,            -- Apply discount when selling TO pawnshop
    applyToBuying = true               -- Apply discount when buying FROM pawnshop
}

-- Pawnshop Features
Config.EnableBuying = false -- Set to false to disable buying from pawnshop (sell-only mode)

-- Interaction System Configuration
Config.InteractionSystem = "ox_target" -- Options: "ox_target", "ox_lib", "both"
-- ox_target: Uses targeting system (3D eye icon)
-- ox_lib: Uses text UI with key press (E key)
-- both: Uses both systems simultaneously (not recommended)

-- Security Settings
Config.MaxTransactionAmount = 10000 -- Maximum single transaction
Config.MaxBuyQuantity = 100 -- Maximum quantity that can be bought in one transaction
Config.CooldownTime = 5000 -- 5 seconds between transactions
Config.RequireJob = false -- Set to job name if you want to restrict access
Config.AllowedJobs = {} -- {"police", "mechanic"} example
