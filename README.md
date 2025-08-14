# 🏪 ZAB Pawnshop - Modern Tech Exchange

<div align="center">

![FiveM](https://img.shields.io/badge/FiveM-Compatible-blue?style=for-the-badge&logo=fivem)
![QBox](https://img.shields.io/badge/QBox-Framework-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-orange?style=for-the-badge)

**A premium pawnshop system for QBox Framework featuring a sleek, modern tech UI with professional design and bulletproof security.**

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Security](#-security) • [Support](#-support)

</div>

---

## 🎯 **Overview**

ZAB Pawnshop transforms the traditional pawnshop experience with a cutting-edge interface and robust backend. Built specifically for QBox Framework, it offers players an immersive trading experience while providing administrators with powerful configuration options and enterprise-grade security.

## ✨ **Features**

### 🎨 **Modern Tech UI**
- **Custom Purple Theme** - Professional gradient design with configurable colors
- **Performance Optimized** - No blur effects, optimized for FiveM
- **Responsive Design** - Adapts to all screen sizes seamlessly
- **Dual View Modes** - Switch between grid and list layouts
- **Real-time Search** - Instant item filtering and categorization
- **Dynamic Quotes** - Randomized seller dialogue for immersion

### 🔒 **Enterprise Security**
- **Multi-layer Validation** - Server-side verification of all transactions
- **Anti-spam Protection** - Configurable cooldown system
- **Price Manipulation Prevention** - Server validates all calculations
- **Inventory Verification** - Real-time stock checking
- **Transaction Limits** - Configurable maximum amounts
- **Audit Logging** - Complete transaction history

### ⚙️ **Advanced Configuration**
- **Dynamic Item Management** - Easy addition/removal of sellable items
- **Category System** - Organize items with custom icons and colors
- **Enable/Disable Categories** - Control what can be sold per server
- **Multiple Locations** - Support for multiple pawnshop branches
- **Currency Options** - Cash, bank, or custom currency support
- **Flexible Pricing** - Individual item pricing and quantity limits

### 🛠️ **Framework Integration**
- **QBox Framework** - Native QBCore compatibility
- **ox_lib** - Modern notifications and callbacks
- **ox_inventory** - Seamless inventory integration
- **ox_target** - Interactive targeting system

## 📸 **Screenshots**

<div align="center">

| Modern Interface | Category System | Item Management |
|:---:|:---:|:---:|
| ![Interface](https://via.placeholder.com/300x200/8b45c1/ffffff?text=Modern+UI) | ![Categories](https://via.placeholder.com/300x200/9333ea/ffffff?text=Categories) | ![Items](https://via.placeholder.com/300x200/a855f7/ffffff?text=Items) |

</div>

## 🚀 **Installation**

### Prerequisites
- QBox Framework (qbx_core)
- ox_lib
- ox_inventory
- ox_target (optional)

### Quick Setup
1. **Download** the latest release
2. **Extract** to your `resources` folder
3. **Add** to your `server.cfg`:
   ```cfg
   ensure zab_pawnshop
   ```
4. **Configure** items and locations in `config.lua`
5. **Restart** your server

## ⚙️ **Configuration**

### Adding Items
```lua
{
    item = "phone",              -- Item name from inventory
    label = "Smartphone",        -- Display name
    price = 150,                -- Sell price
    maxQuantity = 5,            -- Max quantity per transaction
    category = "electronics",    -- Category for organization
    image = "phone.png"         -- Image from ox_inventory/web/images
}
```

### Managing Categories
```lua
{
    id = "electronics",
    label = "Electronics",
    icon = "fas fa-mobile-alt",
    color = "#00d4ff",
    enabled = true              -- Set to false to disable
}
```

### Customizing Seller Quotes
```lua
Config.SellerQuotes = {
    "Howdy, whatchu want me to buy?",
    "U got goods? Let me buy them",
    "Those ain't stolen right?",
    -- Add your own custom quotes
}
```

### UI Theme Customization
```lua
Config.UI = {
    primaryColor = "#8b45c1",      -- Main purple
    secondaryColor = "#9333ea",    -- Secondary purple
    accentColor = "#a855f7",       -- Accent color
    -- Customize all colors
}
```

## 🛡️ **Security Architecture**

Our security system implements multiple layers of protection:

- **🔐 Server-Side Validation** - All transactions verified server-side
- **⏱️ Anti-Spam Protection** - Configurable cooldown system
- **💰 Price Verification** - Prevents economic manipulation
- **📦 Inventory Checking** - Real-time stock verification
- **🚫 Transaction Limits** - Configurable maximum amounts
- **📝 Audit Logging** - Complete transaction history
- **🔄 Rollback Protection** - Atomic transactions prevent duplication

## 🎮 **Usage**

### For Players
1. **Approach** any pawnshop location
2. **Interact** with the NPC or press `E`
3. **Browse** items by category or use search
4. **Select** items to sell (supports multi-select)
5. **Choose** quantity in the modal
6. **Confirm** transaction and receive payment

### For Administrators
- **Configure** items and prices in `config.lua`
- **Enable/disable** categories as needed
- **Set** transaction limits and cooldowns
- **Monitor** transactions via server logs
- **Customize** UI colors and branding

## 📁 **File Structure**

```
zab_pawnshop/
├── 📁 client/
│   └── main.lua              # Client-side logic
├── 📁 server/
│   └── main.lua              # Server-side logic & security
├── 📁 web/
│   ├── index.html            # UI structure
│   ├── style.css             # Modern styling
│   └── script.js             # UI functionality
├── config.lua                # Configuration
├── fxmanifest.lua           # Resource manifest
└── README.md                # Documentation
```

## 🔧 **Commands**

| Command | Description | Usage |
|---------|-------------|-------|
| `/pawnshop` | Open pawnshop interface | When near location |
| `E` | Interact with pawnshop | Default key (configurable) |

## 🤝 **Contributing**

We welcome contributions! Please:

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Open** a Pull Request

## 📋 **Changelog**

### v1.0.0 (Latest)
- ✅ Initial release
- ✅ Modern tech UI with purple theme
- ✅ QBox Framework integration
- ✅ Multi-layer security system
- ✅ Dynamic seller quotes
- ✅ Category management system
- ✅ Dual view modes (grid/list)

## 🐛 **Known Issues**

- None currently reported

## 📞 **Support**
- **Discord**: > Discord => VentuZAB

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Credits**

- **Developer**: VentuZAB
- **Framework**: QBox Team
- **Libraries**: ox_lib, ox_inventory
- **Inspiration**: Modern tech aesthetics

---

<div align="center">

**⭐ If you like this project, please give it a star! ⭐**

Made with ❤️ for the FiveM community

</div>