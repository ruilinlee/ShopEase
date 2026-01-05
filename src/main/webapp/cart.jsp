<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.CartItem" %>
<%
    // Prevent admin from accessing cart
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    Double cartTotal = (Double) request.getAttribute("cartTotal");
%>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Shopping Cart - ShopEase</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <style>
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                            background: #f5f5f5;
                            color: #333;
                        }

                        .page-header {
                            background: #fff;
                            border-bottom: 1px solid #eee;
                            padding: 1.25rem 0;
                        }

                        .page-title {
                            font-size: 1.25rem;
                            font-weight: 600;
                            margin: 0;
                        }

                        .back-link {
                            display: inline-flex;
                            align-items: center;
                            gap: 0.4rem;
                            padding: 0.5rem 1rem;
                            color: #2563eb;
                            font-size: 0.9rem;
                            font-weight: 500;
                            text-decoration: none;
                            background: #eff6ff;
                            border: 1px solid #bfdbfe;
                            border-radius: 6px;
                            transition: all 0.2s ease;
                        }

                        .back-link:hover {
                            background: #dbeafe;
                            border-color: #93c5fd;
                            color: #1d4ed8;
                            transform: translateY(-1px);
                            box-shadow: 0 2px 8px rgba(37, 99, 235, 0.15);
                        }

                        .cart-item {
                            background: #fff;
                            border-radius: 8px;
                            padding: 1rem;
                            margin-bottom: 0.75rem;
                            border: 1px solid #eee;
                        }

                        .cart-item img {
                            width: 70px;
                            height: 70px;
                            object-fit: cover;
                            border-radius: 4px;
                            background: #f5f5f5;
                        }

                        .item-name {
                            font-weight: 500;
                            font-size: 0.95rem;
                        }

                        .item-price {
                            font-size: 0.85rem;
                            color: #888;
                        }

                        .qty-btn {
                            width: 28px;
                            height: 28px;
                            border: 1px solid #ddd;
                            background: #fff;
                            border-radius: 4px;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            color: #666;
                            text-decoration: none;
                            font-size: 0.9rem;
                        }

                        .qty-btn:hover {
                            background: #f5f5f5;
                            color: #333;
                        }

                        .qty-value {
                            display: inline-block;
                            min-width: 30px;
                            text-align: center;
                            font-weight: 500;
                        }

                        .item-subtotal {
                            font-weight: 600;
                            font-size: 1rem;
                        }

                        .remove-link {
                            color: #dc3545;
                            font-size: 0.8rem;
                            text-decoration: none;
                        }

                        .remove-link:hover {
                            text-decoration: underline;
                        }

                        .summary-card {
                            background: #fff;
                            border-radius: 8px;
                            padding: 1.25rem;
                            border: 1px solid #eee;
                            position: sticky;
                            top: 20px;
                        }

                        .summary-title {
                            font-size: 1rem;
                            font-weight: 600;
                            margin-bottom: 1rem;
                            padding-bottom: 0.75rem;
                            border-bottom: 1px solid #eee;
                        }

                        .summary-row {
                            display: flex;
                            justify-content: space-between;
                            margin-bottom: 0.5rem;
                            font-size: 0.9rem;
                        }

                        .summary-row.total {
                            font-weight: 600;
                            font-size: 1.1rem;
                            margin-top: 0.75rem;
                            padding-top: 0.75rem;
                            border-top: 1px solid #eee;
                        }

                        .btn-checkout {
                            background: #333;
                            color: #fff;
                            border: none;
                            padding: 0.75rem;
                            border-radius: 4px;
                            width: 100%;
                            font-size: 0.9rem;
                            margin-top: 1rem;
                        }

                        .btn-checkout:hover {
                            background: #555;
                            color: #fff;
                        }

                        .btn-checkout:disabled {
                            background: #ccc;
                        }

                        .empty-cart {
                            text-align: center;
                            padding: 4rem 2rem;
                            background: #fff;
                            border-radius: 8px;
                            border: 1px solid #eee;
                        }

                        .clear-link {
                            color: #dc3545;
                            font-size: 0.85rem;
                            text-decoration: none;
                        }

                        .clear-link:hover {
                            text-decoration: underline;
                        }

                        .error-msg {
                            background: #ffebee;
                            border: 1px solid #ef9a9a;
                            border-radius: 4px;
                            padding: 0.75rem 1rem;
                            font-size: 0.85rem;
                            color: #c62828;
                            margin-bottom: 1rem;
                        }

                        .item-checkbox {
                            width: 18px;
                            height: 18px;
                            cursor: pointer;
                            accent-color: #333;
                        }

                        .select-all-bar {
                            background: #fff;
                            border-radius: 8px;
                            padding: 0.75rem 1rem;
                            margin-bottom: 0.75rem;
                            border: 1px solid #eee;
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                        }

                        .select-all-bar label {
                            font-size: 0.9rem;
                            font-weight: 500;
                            cursor: pointer;
                            margin: 0;
                        }

                        .cart-item.unselected {
                            opacity: 0.6;
                        }
                    </style>
                </head>

                <body>
                    <div class="page-header">
                        <div class="container">
                            <div class="d-flex justify-content-between align-items-center">
                                <h1 class="page-title">Shopping Cart</h1>
                                <a href="products" class="back-link">← Continue Shopping</a>
                            </div>
                        </div>
                    </div>

                    <main class="container my-4">
                        <% if (request.getAttribute("error") !=null) { %>
                            <div class="error-msg">
                                <%= request.getAttribute("error") %>
                            </div>
                            <% } %>
                                <div class="row g-4">
                                    <div class="col-lg-8">
                                        <% if (cartItems !=null && !cartItems.isEmpty()) { %>
                                            <div class="select-all-bar">
                                                <input type="checkbox" id="selectAll" class="item-checkbox" checked>
                                                <label for="selectAll">Select All</label>
                                            </div>
                                            <% for (CartItem item : cartItems) { %>
                                                <div class="cart-item" data-product-id="<%= item.getProductId() %>"
                                                    data-price="<%= item.getPrice() %>"
                                                    data-quantity="<%= item.getQuantity() %>">
                                                    <div class="row align-items-center">
                                                        <div class="col-auto">
                                                            <input type="checkbox" name="selectedItems"
                                                                value="<%= item.getProductId() %>"
                                                                class="item-checkbox item-select" checked>
                                                        </div>
                                                        <div class="col-auto">
                                                            <img src="<%= item.getImageUrl() %>"
                                                                alt="<%= item.getProductName() %>"
                                                                onerror="this.src='https://via.placeholder.com/70?text=N/A'">
                                                        </div>
                                                        <div class="col">
                                                            <div class="item-name">
                                                                <%= item.getProductName() %>
                                                            </div>
                                                            <div class="item-price">$<%= String.format("%.2f",
                                                                    item.getPrice()) %> each</div>
                                                        </div>
                                                        <div class="col-auto">
                                                            <a href="cart?action=decrease&id=<%= item.getProductId() %>"
                                                                class="qty-btn">−</a>
                                                            <span class="qty-value">
                                                                <%= item.getQuantity() %>
                                                            </span>
                                                            <a href="cart?action=increase&id=<%= item.getProductId() %>"
                                                                class="qty-btn">+</a>
                                                        </div>
                                                        <div class="col-auto text-end" style="min-width:100px;">
                                                            <div class="item-subtotal">$<%= String.format("%.2f",
                                                                    item.getSubtotal()) %>
                                                            </div>
                                                            <a href="cart?action=remove&id=<%= item.getProductId() %>"
                                                                class="remove-link">Remove</a>
                                                        </div>
                                                    </div>
                                                </div>
                                                <% } %>
                                                    <div class="text-end mt-2">
                                                        <a href="cart?action=clear" class="clear-link"
                                                            onclick="return confirm('Clear cart?')">Clear Cart</a>
                                                    </div>
                                                    <% } else { %>
                                                        <div class="empty-cart">
                                                            <h5>Your cart is empty</h5>
                                                            <p class="text-muted">Browse products and add items to your
                                                                cart</p>
                                                            <a href="products" class="btn-checkout"
                                                                style="display:inline-block;width:auto;padding:0.5rem 2rem;">Browse
                                                                Products</a>
                                                        </div>
                                                        <% } %>
                                    </div>

                                    <div class="col-lg-4">
                                        <div class="summary-card">
                                            <h5 class="summary-title">Order Summary</h5>
                                            <div class="summary-row">
                                                <span>Selected Items</span>
                                                <span id="selectedCount">
                                                    <%= request.getAttribute("itemCount") !=null ?
                                                        request.getAttribute("itemCount") : 0 %>
                                                </span>
                                            </div>
                                            <div class="summary-row">
                                                <span>Shipping</span>
                                                <span style="color:#22c55e;">Free</span>
                                            </div>
                                            <div class="summary-row total">
                                                <span>Total</span>
                                                <span id="selectedTotal">$<%= cartTotal !=null ? String.format("%.2f",
                                                        cartTotal) : "0.00" %></span>
                                            </div>
                                            <% if (cartItems !=null && !cartItems.isEmpty()) { %>
                                                <form action="orders" method="get" id="checkoutForm">
                                                    <input type="hidden" name="action" value="checkout">
                                                    <div id="selectedItemsContainer"></div>
                                                    <button type="submit" class="btn-checkout" id="checkoutBtn">
                                                        Proceed to Checkout
                                                    </button>
                                                </form>
                                                <% } else { %>
                                                    <button class="btn-checkout" disabled>Cart is Empty</button>
                                                    <% } %>
                                        </div>
                                    </div>
                                </div>
                    </main>

                    <script>
                        function updateSummary() {
                            const checkboxes = document.querySelectorAll('.item-select');
                            let selectedCount = 0;
                            let selectedTotal = 0;
                            const container = document.getElementById('selectedItemsContainer');
                            container.innerHTML = '';

                            checkboxes.forEach(cb => {
                                const cartItem = cb.closest('.cart-item');
                                if (cb.checked) {
                                    selectedCount++;
                                    const price = parseFloat(cartItem.dataset.price);
                                    const quantity = parseInt(cartItem.dataset.quantity);
                                    selectedTotal += price * quantity;
                                    cartItem.classList.remove('unselected');

                                    // Add hidden input for selected item
                                    const input = document.createElement('input');
                                    input.type = 'hidden';
                                    input.name = 'selectedItems';
                                    input.value = cartItem.dataset.productId;
                                    container.appendChild(input);
                                } else {
                                    cartItem.classList.add('unselected');
                                }
                            });

                            document.getElementById('selectedCount').textContent = selectedCount;
                            document.getElementById('selectedTotal').textContent = '$' + selectedTotal.toFixed(2);
                            document.getElementById('checkoutBtn').disabled = selectedCount === 0;
                        }

                        // Select All checkbox
                        document.getElementById('selectAll')?.addEventListener('change', function () {
                            const checkboxes = document.querySelectorAll('.item-select');
                            checkboxes.forEach(cb => cb.checked = this.checked);
                            updateSummary();
                        });

                        // Individual item checkboxes
                        document.querySelectorAll('.item-select').forEach(cb => {
                            cb.addEventListener('change', function () {
                                const allChecked = document.querySelectorAll('.item-select:checked').length ===
                                    document.querySelectorAll('.item-select').length;
                                document.getElementById('selectAll').checked = allChecked;
                                updateSummary();
                            });
                        });

                        // Initialize on page load
                        updateSummary();
                    </script>
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>