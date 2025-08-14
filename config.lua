Config = {}

-- Pawnshop Settings
Config.PawnshopName = "Tech Pawn Exchange"
Config.Currency = "cash" -- cash, bank, crypto

-- Pawnshop Locations
Config.Locations = {
    {
        coords = vector3(182.6, -1319.7, 29.3),
        heading = 240.0,
        blip = {
            sprite = 431,
            color = 5,
            scale = 0.8,
            label = "Pawnshop"
        },
        ped = {
            model = "a_m_m_business_01",
            coords = vector4(145.3458, -1336.5972, 29.2105, 8.3931)
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
    showDiscountText = true            -- Show discount notification
}

-- Pawnshop Features
Config.EnableBuying = false -- Set to false to disable buying from pawnshop (sell-only mode)

-- Security Settings
Config.MaxTransactionAmount = 10000 -- Maximum single transaction
Config.MaxBuyQuantity = 100 -- Maximum quantity that can be bought in one transaction
Config.CooldownTime = 5000 -- 5 seconds between transactions
Config.RequireJob = false -- Set to job name if you want to restrict access
Config.AllowedJobs = {} -- {"police", "mechanic"} example
