// Modern Pawnshop UI JavaScript
class PawnshopUI {
    constructor() {
        this.isOpen = false;
        this.config = null;
        this.items = [];
        this.filteredItems = [];
        this.selectedItems = new Set();
        this.currentCategory = null; // Will be set to first available category
        this.currentView = 'grid';
        this.searchQuery = '';
        
        this.initializeEventListeners();
    }

    initializeEventListeners() {
        // Close button
        document.getElementById('close-pawnshop').addEventListener('click', () => {
            this.closePawnshop();
        });

        // Search functionality
        document.getElementById('item-search').addEventListener('input', (e) => {
            this.searchQuery = e.target.value.toLowerCase();
            this.filterItems();
        });

        // View controls
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.currentView = e.target.closest('.view-btn').dataset.view;
                this.updateViewControls();
                this.renderItems();
            });
        });

        // Action buttons removed - they didn't work properly

        // Modal controls
        document.getElementById('close-quantity-modal').addEventListener('click', () => {
            this.closeQuantityModal();
        });

        // Modal button event listeners are now handled dynamically in setupModalButtons()

        // Quantity controls
        document.getElementById('quantity-decrease').addEventListener('click', () => {
            this.adjustQuantity(-1);
        });

        document.getElementById('quantity-increase').addEventListener('click', () => {
            this.adjustQuantity(1);
        });

        document.getElementById('quantity-input').addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            
            if (value && value > 0) {
                if (this.config?.enableBuying) {
                    // In buy mode, limit to maxBuyQuantity
                    const maxBuy = this.config?.maxBuyQuantity || 100;
                    if (value > maxBuy) {
                        e.target.value = maxBuy;
                    }
                } else {
                    // In sell-only mode, limit to what player owns
                    const playerOwns = this.currentModalItem?.count || 0;
                    if (value > playerOwns) {
                        e.target.value = playerOwns;
                    }
                }
                this.updateQuantityPreview();
            } else {
                // If invalid input, reset to 1
                e.target.value = 1;
                this.updateQuantityPreview();
            }
        });

        // ESC key to close
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                if (document.getElementById('quantity-modal').classList.contains('hidden')) {
                    this.closePawnshop();
                } else {
                    this.closeQuantityModal();
                }
            }
        });

        // NUI message listener
        window.addEventListener('message', (event) => {
            const { action, data } = event.data;
            
            switch (action) {
                case 'openPawnshop':
                    this.openPawnshop(data);
                    break;
                case 'closePawnshop':
                    this.closePawnshop();
                    break;
                case 'updateItems':
                    this.updateItems(data.items);
                    break;
            }
        });
    }

    openPawnshop(data) {
        this.config = data.config;
        this.items = data.items || [];
        this.filteredItems = [...this.items];
        this.isOpen = true;

        // Update UI with config
        document.getElementById('pawnshop-title').textContent = this.config.name;
        
        // Apply theme colors
        document.documentElement.style.setProperty('--primary-purple', this.config.ui.primaryColor);
        document.documentElement.style.setProperty('--secondary-purple', this.config.ui.secondaryColor);

        // Show random seller quote
        this.showRandomQuote();
        
        // Start quote rotation timer
        this.startQuoteRotation();

        // Render UI
        this.renderCategories();
        this.filterItems();
        this.updateSelectionInfo();

        // Show container
        document.getElementById('pawnshop-container').classList.remove('hidden');
    }

    closePawnshop() {
        this.isOpen = false;
        this.selectedItems.clear();
        this.currentCategory = null; // Will be set to first available category
        this.searchQuery = '';
        
        // Clear quote rotation timer
        if (this.quoteTimer) {
            clearInterval(this.quoteTimer);
            this.quoteTimer = null;
        }
        
        document.getElementById('pawnshop-container').classList.add('hidden');
        document.getElementById('quantity-modal').classList.add('hidden');
        
        // Send close message to client
        fetch(`https://${GetParentResourceName()}/closePawnshop`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    updateItems(newItems) {
        this.items = newItems || [];
        this.selectedItems.clear();
        this.filterItems();
        this.updateSelectionInfo();
    }

    renderCategories() {
        const container = document.getElementById('categories-list');
        container.innerHTML = '';

        let firstCategory = null;

        // Add configured categories (only enabled ones)
        this.config.categories.forEach(category => {
            if (category.enabled !== false) { // Show category if enabled is true or undefined
                const count = this.items.filter(item => item.category === category.id).length;
                if (count > 0) {
                    // Set first available category as default
                    if (!firstCategory) {
                        firstCategory = category.id;
                    }
                    const categoryElement = this.createCategoryElement(category, count);
                    container.appendChild(categoryElement);
                }
            }
        });

        // Set current category to first available if not set
        if (!this.currentCategory && firstCategory) {
            this.currentCategory = firstCategory;
        }
    }

    createCategoryElement(category, count) {
        const element = document.createElement('div');
        element.className = `category-item ${this.currentCategory === category.id ? 'active' : ''}`;
        element.dataset.category = category.id;
        
        element.innerHTML = `
            <div class="category-icon" style="background-color: ${category.color}">
                <i class="${category.icon}"></i>
            </div>
            <div class="category-info">
                <div class="category-name">${category.label}</div>
                <div class="category-count">${count} items</div>
            </div>
        `;

        element.addEventListener('click', () => {
            this.currentCategory = category.id;
            this.updateCategorySelection();
            this.filterItems();
        });

        return element;
    }

    updateCategorySelection() {
        document.querySelectorAll('.category-item').forEach(item => {
            item.classList.toggle('active', item.dataset.category === this.currentCategory);
        });
    }

    filterItems() {
        this.filteredItems = this.items.filter(item => {
            const matchesCategory = !this.currentCategory || item.category === this.currentCategory;
            const matchesSearch = !this.searchQuery || 
                item.label.toLowerCase().includes(this.searchQuery) ||
                item.item.toLowerCase().includes(this.searchQuery);
            
            return matchesCategory && matchesSearch;
        });

        this.renderItems();
    }

    renderItems() {
        const container = document.getElementById('items-container');
        const noItemsMessage = document.getElementById('no-items');

        if (this.filteredItems.length === 0) {
            container.innerHTML = '';
            noItemsMessage.classList.remove('hidden');
            return;
        }

        noItemsMessage.classList.add('hidden');
        container.innerHTML = '';

        // Update container class based on view
        container.className = `items-container ${this.currentView}-view`;

        this.filteredItems.forEach(item => {
            const itemElement = this.createItemElement(item);
            container.appendChild(itemElement);
        });
    }

    createItemElement(item) {
        const element = document.createElement('div');
        element.className = `item-card ${this.selectedItems.has(item.item) ? 'selected' : ''} ${item.isLocked ? 'locked' : ''}`;
        element.dataset.item = item.item;

        const imagePath = `nui://ox_inventory/web/images/${item.image}`;
        
        element.innerHTML = `
            <div class="item-header">
                <div class="item-image">
                    <img src="${imagePath}" alt="${item.label}" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <i class="fas fa-cube" style="display: none;"></i>
                </div>
                <div class="item-info">
                    <div class="item-name">${item.label}</div>
                    <div class="item-category">${item.category}</div>
                </div>
            </div>
            
            <div class="item-details">
                <div class="item-price">$${item.price.toLocaleString()}</div>
                <div class="item-count">x${item.count}</div>
            </div>
            
            <div class="item-actions">
                <button class="item-btn sell-btn ${item.isLocked ? 'disabled' : ''}">
                    <i class="fas fa-eye"></i>
                    View
                </button>
            </div>
            ${item.isLocked ? '<div class="item-locked-overlay"><div class="lock-icon"><i class="fas fa-lock"></i></div><div class="lock-text">Not Available</div></div>' : ''}
        `;

        // Add click handlers based on locked state
        if (!item.isLocked) {
            element.querySelector('.sell-btn').addEventListener('click', (e) => {
                e.stopPropagation();
                this.openQuantityModal(item);
            });

            element.addEventListener('click', () => {
                this.toggleItemSelection(item.item);
            });
        }

        return element;
    }

    toggleItemSelection(itemName) {
        // All items can be selected for viewing - no restrictions
        if (this.selectedItems.has(itemName)) {
            this.selectedItems.delete(itemName);
        } else {
            this.selectedItems.add(itemName);
        }

        this.updateItemSelection();
        this.updateSelectionInfo();
    }

    updateItemSelection() {
        document.querySelectorAll('.item-card').forEach(card => {
            const itemName = card.dataset.item;
            card.classList.toggle('selected', this.selectedItems.has(itemName));
        });
    }

    updateSelectionInfo() {
        // Function kept for compatibility but does nothing now
    }

    updateViewControls() {
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.view === this.currentView);
        });
    }

    // Removed sellSelectedItems and sellItemsSequentially - didn't work properly

    openQuantityModal(item) {
        this.currentModalItem = item;
        
        // Update modal content
        const maxInfo = this.config?.enableBuying 
            ? `Max buy: ${this.config?.maxBuyQuantity || 100}` 
            : `Max sell: ${Math.min(item.count, item.maxQuantity)}`;
            
        document.getElementById('modal-item-preview').innerHTML = `
            <div class="preview-image">
                <img src="nui://ox_inventory/web/images/${item.image}" alt="${item.label}" 
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                <i class="fas fa-cube" style="display: none;"></i>
            </div>
            <div class="preview-info">
                <h4>${item.label}</h4>
                <p>Available: ${item.count} | ${maxInfo}</p>
            </div>
        `;

        // Set quantity limits
        const quantityInput = document.getElementById('quantity-input');
        quantityInput.value = 1;
        
        document.getElementById('available-quantity').textContent = item.count;
        document.getElementById('max-quantity').textContent = this.config?.enableBuying 
            ? (this.config?.maxBuyQuantity || 100) 
            : Math.min(item.count, item.maxQuantity);
        
        // Setup modal buttons based on config
        this.setupModalButtons();
        
        this.updateQuantityPreview();
        
        // Show modal
        document.getElementById('quantity-modal').classList.remove('hidden');
    }

    setupModalButtons() {
        const modalActions = document.getElementById('modal-actions');
        
        if (this.config?.enableBuying) {
            // Buy & Sell mode
            modalActions.innerHTML = `
                <button class="modal-btn secondary" id="dynamic-sell-btn">
                    <i class="fas fa-handshake"></i>
                    SELL
                </button>
                <button class="modal-btn primary" id="dynamic-buy-btn">
                    <i class="fas fa-shopping-cart"></i>
                    BUY
                </button>
            `;
            
            // Add event listeners
            document.getElementById('dynamic-sell-btn').addEventListener('click', () => {
                this.confirmSale();
            });
            
            document.getElementById('dynamic-buy-btn').addEventListener('click', () => {
                this.confirmBuy();
            });
        } else {
            // Sell-only mode
            modalActions.innerHTML = `
                <button class="modal-btn secondary" id="dynamic-cancel-btn">
                    Cancel
                </button>
                <button class="modal-btn primary" id="dynamic-sell-btn">
                    <i class="fas fa-handshake"></i>
                    SELL
                </button>
            `;
            
            // Add event listeners
            document.getElementById('dynamic-cancel-btn').addEventListener('click', () => {
                this.closeQuantityModal();
            });
            
            document.getElementById('dynamic-sell-btn').addEventListener('click', () => {
                this.confirmSale();
            });
        }
    }

    closeQuantityModal() {
        document.getElementById('quantity-modal').classList.add('hidden');
        this.currentModalItem = null;
    }

    adjustQuantity(change) {
        const input = document.getElementById('quantity-input');
        const currentValue = parseInt(input.value) || 1;
        let newValue = currentValue + change;
        
        // Always keep minimum of 1
        newValue = Math.max(1, newValue);
        
        if (this.config?.enableBuying) {
            // In buy mode, limit to maxBuyQuantity
            const maxBuy = this.config?.maxBuyQuantity || 100;
            newValue = Math.min(maxBuy, newValue);
        } else {
            // In sell-only mode, limit to what player owns
            const playerOwns = this.currentModalItem?.count || 0;
            newValue = Math.min(playerOwns, newValue);
        }
        
        input.value = newValue;
        this.updateQuantityPreview();
    }

    // Removed updateQuantity function - users can now type freely

    updateQuantityPreview() {
        if (!this.currentModalItem) return;
        
        const quantity = parseInt(document.getElementById('quantity-input').value) || 1;
        const sellPrice = this.currentModalItem.price;
        const buyPrice = Math.round(sellPrice * 1.4); // 40% markup for buying
        
        let sellTotal = sellPrice * quantity;
        let buyTotal = buyPrice * quantity;
        let sellDiscountApplied = false;
        let buyDiscountApplied = false;
        let discountPercent = 0;
        
        // Check if bulk discount applies to selling
        if (this.config && this.config.bulkDiscount && this.config.bulkDiscount.enabled && this.config.bulkDiscount.applyToSelling) {
            if (quantity >= this.config.bulkDiscount.itemsNeededForDiscount) {
                discountPercent = this.config.bulkDiscount.discountPercent;
                const discountAmount = sellTotal * discountPercent;
                sellTotal = sellTotal - discountAmount;
                sellDiscountApplied = true;
            }
        }
        
        // Check if bulk discount applies to buying
        if (this.config && this.config.bulkDiscount && this.config.bulkDiscount.enabled && this.config.bulkDiscount.applyToBuying) {
            if (quantity >= this.config.bulkDiscount.itemsNeededForDiscount) {
                discountPercent = this.config.bulkDiscount.discountPercent;
                const discountAmount = buyTotal * discountPercent;
                buyTotal = buyTotal - discountAmount;
                buyDiscountApplied = true;
            }
        }
        
        if (this.config?.enableBuying) {
            // Show both prices when buying is enabled
            document.getElementById('sell-price').textContent = `$${Math.round(sellTotal).toLocaleString()}`;
            document.getElementById('buy-price').textContent = `$${buyTotal.toLocaleString()}`;
        } else {
            // Show only sell price when buying is disabled
            document.getElementById('sell-price').textContent = `$${Math.round(sellTotal).toLocaleString()}`;
            const buyPriceElement = document.getElementById('buy-price');
            if (buyPriceElement) {
                buyPriceElement.parentElement.style.display = 'none';
            }
        }
        
        // Show/hide discount info - only show when buying is enabled
        const discountInfo = document.getElementById('discount-info');
        if (discountInfo) {
            // Only show discount info if buying is enabled and a buy discount would apply
            if (this.config?.enableBuying && buyDiscountApplied) {
                const discountPercentText = Math.floor(discountPercent * 100);
                let discountText = `Buy discount available: ${discountPercentText}%`;
                discountInfo.textContent = discountText;
                discountInfo.style.display = 'block';
            } else {
                discountInfo.style.display = 'none';
            }
        }
    }

    confirmSale() {
        if (!this.currentModalItem) return;
        
        const quantity = parseInt(document.getElementById('quantity-input').value) || 1;
        
        // Check if player has enough items to sell
        if (this.currentModalItem.count < quantity) {
            // Send message to client to show ox_lib notification
            fetch(`https://${GetParentResourceName()}/showNotification`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: `You can't sell more than you have! You only have ${this.currentModalItem.count} ${this.currentModalItem.label}`,
                    type: 'error'
                })
            });
            return;
        }
        
        this.sellItem(this.currentModalItem.item, quantity);
        this.closeQuantityModal();
    }

    confirmBuy() {
        if (!this.currentModalItem) return;
        
        const quantity = parseInt(document.getElementById('quantity-input').value) || 1;
        this.buyItem(this.currentModalItem.item, quantity);
        this.closeQuantityModal();
    }

    sellItem(itemName, quantity, callback) {
        fetch(`https://${GetParentResourceName()}/sellItem`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                item: itemName,
                quantity: quantity
            })
        })
        .then(response => response.json())
        .then(result => {
            // Let the client-side handle notifications via ox_lib
            if (callback) callback();
        })
        .catch(error => {
            console.error('Error selling item:', error);
            if (callback) callback();
        });
    }

    buyItem(itemName, quantity, callback) {
        fetch(`https://${GetParentResourceName()}/buyItem`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                item: itemName,
                quantity: quantity
            })
        })
        .then(response => response.json())
        .then(result => {
            // Let the client-side handle notifications via ox_lib
            if (callback) callback();
        })
        .catch(error => {
            console.error('Error buying item:', error);
            if (callback) callback();
        });
    }

    showRandomQuote() {
        if (!this.config || !this.config.sellerQuotes || this.config.sellerQuotes.length === 0) {
            document.getElementById('seller-quote').textContent = "Welcome to my shop!";
            return;
        }
        
        const randomIndex = Math.floor(Math.random() * this.config.sellerQuotes.length);
        const quote = this.config.sellerQuotes[randomIndex];
        
        const quoteElement = document.getElementById('seller-quote');
        quoteElement.style.opacity = '0';
        
        setTimeout(() => {
            quoteElement.textContent = quote;
            quoteElement.style.opacity = '1';
        }, 200);
    }

    startQuoteRotation() {
        // Change quote every 15 seconds
        this.quoteTimer = setInterval(() => {
            if (this.isOpen) {
                this.showRandomQuote();
            }
        }, 15000);
    }


}

// Initialize the UI
const pawnshopUI = new PawnshopUI();

// Utility function for resource name
function GetParentResourceName() {
    return 'zab_pawnshop';
}
