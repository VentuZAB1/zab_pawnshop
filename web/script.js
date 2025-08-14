// Modern Pawnshop UI JavaScript
class PawnshopUI {
    constructor() {
        this.isOpen = false;
        this.config = null;
        this.items = [];
        this.filteredItems = [];
        this.selectedItems = new Set();
        this.currentCategory = 'all';
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

        document.getElementById('cancel-sell').addEventListener('click', () => {
            this.closeQuantityModal();
        });

        document.getElementById('confirm-sell').addEventListener('click', () => {
            this.confirmSale();
        });

        // Quantity controls
        document.getElementById('quantity-decrease').addEventListener('click', () => {
            this.adjustQuantity(-1);
        });

        document.getElementById('quantity-increase').addEventListener('click', () => {
            this.adjustQuantity(1);
        });

        document.getElementById('quantity-input').addEventListener('input', (e) => {
            this.updateQuantity(parseInt(e.target.value) || 1);
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
        this.currentCategory = 'all';
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

        // Add "All" category
        const allCategory = this.createCategoryElement({
            id: 'all',
            label: 'All Items',
            icon: 'fas fa-th-large',
            color: '#6b7280'
        }, this.items.length);
        
        container.appendChild(allCategory);

        // Add configured categories (only enabled ones)
        this.config.categories.forEach(category => {
            if (category.enabled !== false) { // Show category if enabled is true or undefined
                const count = this.items.filter(item => item.category === category.id).length;
                if (count > 0) {
                    const categoryElement = this.createCategoryElement(category, count);
                    container.appendChild(categoryElement);
                }
            }
        });
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
            const matchesCategory = this.currentCategory === 'all' || item.category === this.currentCategory;
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
        const isLocked = item.locked || item.count === 0;
        element.className = `item-card ${this.selectedItems.has(item.item) ? 'selected' : ''} ${isLocked ? 'locked' : ''}`;
        element.dataset.item = item.item;

        const imagePath = `nui://ox_inventory/web/images/${item.image}`;
        
        element.innerHTML = `
            <div class="item-header">
                <div class="item-image">
                    <img src="${imagePath}" alt="${item.label}" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <i class="fas fa-cube" style="display: none;"></i>
                    ${isLocked ? '<div class="lock-overlay"><i class="fas fa-lock"></i></div>' : ''}
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
                <button class="item-btn sell-btn ${isLocked ? 'disabled' : ''}" ${isLocked ? 'disabled' : ''}>
                    <i class="fas fa-${isLocked ? 'lock' : 'handshake'}"></i>
                    ${isLocked ? 'Not Available' : 'Sell Item'}
                </button>
            </div>
            
            ${isLocked ? '<div class="item-locked-overlay"></div>' : ''}
        `;

        // Add click handlers only if not locked
        if (!isLocked) {
            element.querySelector('.sell-btn').addEventListener('click', (e) => {
                e.stopPropagation();
                this.openQuantityModal(item);
            });

            element.addEventListener('click', () => {
                this.toggleItemSelection(item.item);
            });
        } else {
            // Show tooltip for locked items
            element.addEventListener('click', () => {
                // Send message to client to show ox_lib notification
                fetch(`https://${GetParentResourceName()}/showNotification`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        message: `You don't have any ${item.label} to sell`,
                        type: 'warning'
                    })
                });
            });
        }

        return element;
    }

    toggleItemSelection(itemName) {
        // Check if item is locked
        const item = this.items.find(i => i.item === itemName);
        if (item && (item.locked || item.count === 0)) {
            // Send message to client to show ox_lib notification
            fetch(`https://${GetParentResourceName()}/showNotification`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: `You don't have any ${item.label} to sell`,
                    type: 'warning'
                })
            });
            return;
        }

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
        document.getElementById('modal-item-preview').innerHTML = `
            <div class="preview-image">
                <img src="nui://ox_inventory/web/images/${item.image}" alt="${item.label}" 
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                <i class="fas fa-cube" style="display: none;"></i>
            </div>
            <div class="preview-info">
                <h4>${item.label}</h4>
                <p>Available: ${item.count} | Max per transaction: ${item.maxQuantity}</p>
            </div>
        `;

        // Set quantity limits
        const maxQuantity = Math.min(item.count, item.maxQuantity);
        const quantityInput = document.getElementById('quantity-input');
        quantityInput.max = maxQuantity;
        quantityInput.value = 1;
        
        document.getElementById('available-quantity').textContent = item.count;
        document.getElementById('max-quantity').textContent = item.maxQuantity;
        
        this.updateQuantityPreview();
        
        // Show modal
        document.getElementById('quantity-modal').classList.remove('hidden');
    }

    closeQuantityModal() {
        document.getElementById('quantity-modal').classList.add('hidden');
        this.currentModalItem = null;
    }

    adjustQuantity(change) {
        const input = document.getElementById('quantity-input');
        const currentValue = parseInt(input.value) || 1;
        const newValue = Math.max(1, Math.min(parseInt(input.max), currentValue + change));
        
        input.value = newValue;
        this.updateQuantityPreview();
    }

    updateQuantity(value) {
        const input = document.getElementById('quantity-input');
        const maxValue = parseInt(input.max);
        const newValue = Math.max(1, Math.min(maxValue, value));
        
        input.value = newValue;
        this.updateQuantityPreview();
    }

    updateQuantityPreview() {
        if (!this.currentModalItem) return;
        
        const quantity = parseInt(document.getElementById('quantity-input').value) || 1;
        const unitPrice = this.currentModalItem.price;
        const totalPrice = unitPrice * quantity;
        
        document.getElementById('unit-price').textContent = `$${unitPrice.toLocaleString()}`;
        document.getElementById('total-price').textContent = `$${totalPrice.toLocaleString()}`;
    }

    confirmSale() {
        if (!this.currentModalItem) return;
        
        const quantity = parseInt(document.getElementById('quantity-input').value) || 1;
        this.sellItem(this.currentModalItem.item, quantity);
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
