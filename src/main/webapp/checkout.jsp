<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.CartItem, com.shopease.entity.Address" %>
<%
    // Prevent admin from accessing checkout
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
    List<Address> addresses = (List<Address>) request.getAttribute("addresses");
    Double cartTotal = (Double) request.getAttribute("cartTotal");
    String[] selectedItemIds = (String[]) request.getAttribute("selectedItemIds");

    // Get user profile info for auto-import
    String userFullName = (String) session.getAttribute("fullName");
    String userEmail = (String) session.getAttribute("email");
    String userPhone = (String) session.getAttribute("phone");
    String username = (String) session.getAttribute("username");

    if (cartItems == null || cartItems.isEmpty()) {
        response.sendRedirect("cart");
        return;
    }
%>
                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Checkout - ShopEase</title>
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

                                .checkout-section {
                                    background: #fff;
                                    border-radius: 8px;
                                    padding: 1.5rem;
                                    border: 1px solid #eee;
                                    margin-bottom: 1rem;
                                }

                                .section-title {
                                    font-size: 1rem;
                                    font-weight: 600;
                                    margin-bottom: 1rem;
                                    padding-bottom: 0.5rem;
                                    border-bottom: 1px solid #eee;
                                    display: flex;
                                    justify-content: space-between;
                                    align-items: center;
                                }

                                .step-number {
                                    display: inline-flex;
                                    align-items: center;
                                    justify-content: center;
                                    width: 24px;
                                    height: 24px;
                                    background: #333;
                                    color: #fff;
                                    border-radius: 50%;
                                    font-size: 0.8rem;
                                    margin-right: 0.5rem;
                                }

                                /* Order Items */
                                .order-item {
                                    display: flex;
                                    align-items: center;
                                    padding: 0.75rem 0;
                                    border-bottom: 1px solid #f0f0f0;
                                }

                                .order-item:last-child {
                                    border-bottom: none;
                                }

                                .item-img {
                                    width: 60px;
                                    height: 60px;
                                    object-fit: cover;
                                    border-radius: 4px;
                                    background: #f5f5f5;
                                    margin-right: 0.75rem;
                                }

                                .item-name {
                                    font-size: 0.9rem;
                                    font-weight: 500;
                                }

                                .item-qty {
                                    font-size: 0.8rem;
                                    color: #888;
                                }

                                .item-subtotal {
                                    font-weight: 600;
                                    font-size: 0.9rem;
                                }

                                /* Address Selection */
                                .address-option {
                                    border: 1px solid #ddd;
                                    border-radius: 8px;
                                    padding: 1rem;
                                    margin-bottom: 0.75rem;
                                    cursor: pointer;
                                    transition: border-color 0.2s;
                                }

                                .address-option:hover {
                                    border-color: #999;
                                }

                                .address-option.selected {
                                    border-color: #333;
                                    background: #fafafa;
                                }

                                .address-name {
                                    font-weight: 600;
                                    font-size: 0.95rem;
                                }

                                .address-detail {
                                    font-size: 0.85rem;
                                    color: #666;
                                }

                                /* Payment Methods */
                                .payment-grid {
                                    display: grid;
                                    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
                                    gap: 0.75rem;
                                }

                                .payment-option {
                                    border: 2px solid #ddd;
                                    border-radius: 12px;
                                    padding: 1rem 0.75rem;
                                    text-align: center;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                    position: relative;
                                }

                                .payment-option:hover {
                                    border-color: #999;
                                    transform: translateY(-2px);
                                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                                }

                                .payment-option.selected {
                                    border-color: #2563eb;
                                    background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
                                }

                                .payment-option.selected::after {
                                    content: "✓";
                                    position: absolute;
                                    top: 8px;
                                    right: 8px;
                                    width: 20px;
                                    height: 20px;
                                    background: #2563eb;
                                    color: #fff;
                                    border-radius: 50%;
                                    font-size: 12px;
                                    line-height: 20px;
                                }

                                .payment-icon {
                                    width: 56px;
                                    height: 40px;
                                    object-fit: contain;
                                    margin-bottom: 0.5rem;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                }

                                .payment-icon-svg {
                                    width: 100%;
                                    height: 100%;
                                }

                                .payment-icon-img {
                                    width: 100%;
                                    height: 100%;
                                    object-fit: contain;
                                    border-radius: 4px;
                                }

                                .payment-icon-text {
                                    font-size: 1.75rem;
                                    margin-bottom: 0.25rem;
                                    line-height: 1;
                                }

                                .payment-name {
                                    font-size: 0.85rem;
                                    font-weight: 600;
                                    color: #333;
                                }

                                .payment-desc {
                                    font-size: 0.7rem;
                                    color: #888;
                                    margin-top: 0.25rem;
                                }

                                /* Bank-specific colors */
                                .payment-option[data-method="maybank"] .payment-icon {
                                    background: linear-gradient(135deg, #FFC72C 0%, #FFD700 100%);
                                    border-radius: 6px;
                                }

                                .payment-option[data-method="cimb"] .payment-icon {
                                    background: linear-gradient(135deg, #ED1C24 0%, #C41E3A 100%);
                                    border-radius: 6px;
                                }

                                .payment-option[data-method="publicbank"] .payment-icon {
                                    background: linear-gradient(135deg, #003399 0%, #0056B3 100%);
                                    border-radius: 6px;
                                }

                                .payment-option[data-method="tng"] .payment-icon {
                                    background: linear-gradient(135deg, #0066B3 0%, #004C99 100%);
                                    border-radius: 6px;
                                }

                                .payment-option[data-method="grabpay"] .payment-icon {
                                    background: linear-gradient(135deg, #00B14F 0%, #008C3E 100%);
                                    border-radius: 6px;
                                }

                                .payment-option[data-method="card"] .payment-icon {
                                    background: linear-gradient(135deg, #1A1F71 0%, #2563EB 100%);
                                    border-radius: 6px;
                                }

                                /* Summary */
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

                                .btn-place-order {
                                    background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
                                    color: #fff;
                                    border: none;
                                    padding: 1rem 2rem;
                                    border-radius: 8px;
                                    font-size: 1rem;
                                    font-weight: 600;
                                    width: 100%;
                                    margin-top: 1rem;
                                    transition: all 0.2s;
                                }

                                .btn-place-order:hover {
                                    background: linear-gradient(135deg, #1d4ed8 0%, #1e40af 100%);
                                    color: #fff;
                                    transform: translateY(-1px);
                                    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
                                }

                                .btn-place-order:disabled {
                                    background: #ccc;
                                    transform: none;
                                    box-shadow: none;
                                }

                                .add-address-link {
                                    color: #333;
                                    text-decoration: none;
                                    font-size: 0.85rem;
                                }

                                .add-address-link:hover {
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

                                /* Auto Import Button */
                                .btn-auto-import {
                                    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                                    color: #fff;
                                    border: none;
                                    padding: 0.4rem 0.8rem;
                                    border-radius: 6px;
                                    font-size: 0.8rem;
                                    font-weight: 500;
                                    cursor: pointer;
                                    transition: all 0.2s;
                                }

                                .btn-auto-import:hover {
                                    background: linear-gradient(135deg, #059669 0%, #047857 100%);
                                    transform: translateY(-1px);
                                }

                                .btn-auto-import:disabled {
                                    background: #ccc;
                                    cursor: not-allowed;
                                }

                                /* Quick Add Address Form */
                                .quick-add-form {
                                    background: #f8fafc;
                                    border-radius: 8px;
                                    padding: 1rem;
                                    margin-top: 0.75rem;
                                    border: 1px dashed #cbd5e1;
                                }

                                .quick-add-form .form-control {
                                    font-size: 0.85rem;
                                    padding: 0.5rem 0.75rem;
                                }

                                .quick-add-form .form-label {
                                    font-size: 0.8rem;
                                    font-weight: 500;
                                    margin-bottom: 0.25rem;
                                }

                                .imported-badge {
                                    background: #10b981;
                                    color: #fff;
                                    font-size: 0.7rem;
                                    padding: 0.15rem 0.4rem;
                                    border-radius: 4px;
                                    margin-left: 0.5rem;
                                }

                                /* Payment Modal */
                                .payment-modal-overlay {
                                    display: none;
                                    position: fixed;
                                    top: 0;
                                    left: 0;
                                    right: 0;
                                    bottom: 0;
                                    background: rgba(0, 0, 0, 0.7);
                                    z-index: 9999;
                                    align-items: center;
                                    justify-content: center;
                                }

                                .payment-modal-overlay.active {
                                    display: flex;
                                }

                                .payment-modal {
                                    background: #fff;
                                    border-radius: 16px;
                                    padding: 2rem;
                                    max-width: 400px;
                                    width: 90%;
                                    text-align: center;
                                    animation: slideUp 0.3s ease;
                                }

                                @keyframes slideUp {
                                    from {
                                        opacity: 0;
                                        transform: translateY(20px);
                                    }

                                    to {
                                        opacity: 1;
                                        transform: translateY(0);
                                    }
                                }

                                .payment-processing {
                                    margin: 1.5rem 0;
                                }

                                .spinner {
                                    width: 60px;
                                    height: 60px;
                                    border: 4px solid #e5e7eb;
                                    border-top: 4px solid #2563eb;
                                    border-radius: 50%;
                                    animation: spin 1s linear infinite;
                                    margin: 0 auto 1rem;
                                }

                                @keyframes spin {
                                    0% {
                                        transform: rotate(0deg);
                                    }

                                    100% {
                                        transform: rotate(360deg);
                                    }
                                }

                                .success-icon {
                                    width: 80px;
                                    height: 80px;
                                    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                                    border-radius: 50%;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    margin: 0 auto 1rem;
                                    color: #fff;
                                    font-size: 2.5rem;
                                }

                                .payment-method-display {
                                    background: #f8fafc;
                                    border-radius: 8px;
                                    padding: 0.75rem;
                                    margin-top: 1rem;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    gap: 0.5rem;
                                }

                                /* Secure badge */
                                .secure-badge {
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    gap: 0.5rem;
                                    font-size: 0.8rem;
                                    color: #6b7280;
                                    margin-top: 0.75rem;
                                }

                                .secure-badge svg {
                                    width: 16px;
                                    height: 16px;
                                }
                            </style>
                        </head>

                        <body>
                            <div class="page-header">
                                <div class="container">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <h1 class="page-title">Checkout</h1>
                                        <a href="cart" class="back-link">← Back to Cart</a>
                                    </div>
                                </div>
                            </div>

                            <main class="container my-4">
                                <% if (request.getAttribute("error") !=null) { %>
                                    <div class="error-msg">
                                        <%= request.getAttribute("error") %>
                                    </div>
                                    <% } %>

                                        <form action="orders" method="post" id="checkoutForm">
                                            <input type="hidden" name="action" value="placeOrder">
                                            <% if (selectedItemIds !=null) { for (String itemId : selectedItemIds) { %>
                                                <input type="hidden" name="selectedItems" value="<%= itemId %>">
                                                <% } } %>

                                                    <div class="row">
                                                        <div class="col-lg-8">
                                                            <!-- Step 1: Order Items -->
                                                            <div class="checkout-section">
                                                                <h5 class="section-title">
                                                                    <span><span class="step-number">1</span>Order
                                                                        Items</span>
                                                                </h5>
                                                                <% for (CartItem item : cartItems) { %>
                                                                    <div class="order-item">
                                                                        <img src="<%= item.getImageUrl() %>"
                                                                            alt="<%= item.getProductName() %>"
                                                                            class="item-img"
                                                                            onerror="this.src='https://via.placeholder.com/60?text=N/A'">
                                                                        <div class="flex-grow-1">
                                                                            <div class="item-name">
                                                                                <%= item.getProductName() %>
                                                                            </div>
                                                                            <div class="item-qty">
                                                                                <%= item.getQuantity() %> x $<%=
                                                                                        String.format("%.2f",
                                                                                        item.getPrice()) %>
                                                                            </div>
                                                                        </div>
                                                                        <div class="item-subtotal">$<%=
                                                                                String.format("%.2f",
                                                                                item.getSubtotal()) %>
                                                                        </div>
                                                                    </div>
                                                                    <% } %>
                                                            </div>

                                                            <!-- Step 2: Shipping Address -->
                                                            <div class="checkout-section">
                                                                <h5 class="section-title">
                                                                    <span><span class="step-number">2</span>Shipping
                                                                        Address</span>
                                                                    <% if (userFullName !=null || userPhone !=null) { %>
                                                                        <button type="button" class="btn-auto-import"
                                                                            id="autoImportBtn"
                                                                            onclick="showQuickAddForm()">
                                                                            ⚡ Quick Add from Profile
                                                                        </button>
                                                                        <% } %>
                                                                </h5>

                                                                <% if (addresses != null && !addresses.isEmpty()) { %>
                                                                    <% for (Address addr : addresses) { %>
                                                                        <label class="address-option <%= addr.isDefault() ? "selected" : "" %>">
                                                                            <input type="radio" name="addressId" value="<%= addr.getId() %>" <%= addr.isDefault() ? "checked" : "" %> hidden>
                                                                            <div class="address-name">
                                                                                <%= addr.getRecipientName() %>
                                                                            </div>
                                                                            <div class="address-detail">
                                                                                <%= addr.getPhoneNumber() %>
                                                                            </div>
                                                                            <div class="address-detail">
                                                                                <%= addr.getFullAddress() %>
                                                                            </div>
                                                                        </label>
                                                                        <% } %>
                                                                            <% } else { %>
                                                                                <div class="text-center py-3">
                                                                                    <p class="text-muted mb-2">No saved
                                                                                        addresses</p>
                                                                                    <a href="user?action=profile"
                                                                                        class="add-address-link">+ Add a
                                                                                        shipping address</a>
                                                                                </div>
                                                                                <% } %>

                                                                                    <!-- Quick Add Form (Hidden by default) -->
                                                                                    <div id="quickAddForm"
                                                                                        class="quick-add-form"
                                                                                        style="display: none;">
                                                                                        <h6
                                                                                            style="font-size: 0.9rem; font-weight: 600; margin-bottom: 0.75rem;">
                                                                                            Add New Address
                                                                                            <span class="imported-badge"
                                                                                                id="importedBadge"
                                                                                                style="display: none;">Auto-filled</span>
                                                                                        </h6>
                                                                                        <div class="row g-2">
                                                                                            <div class="col-md-6">
                                                                                                <label
                                                                                                    class="form-label">Recipient
                                                                                                    Name *</label>
                                                                                                <input type="text"
                                                                                                    name="newRecipientName"
                                                                                                    id="newRecipientName"
                                                                                                    class="form-control"
                                                                                                    value="<%= userFullName != null ? userFullName : (username != null ? username : "") %>">
                                                                                            </div>
                                                                                            <div class="col-md-6">
                                                                                                <label
                                                                                                    class="form-label">Phone
                                                                                                    Number *</label>
                                                                                                <input type="tel"
                                                                                                    name="newPhoneNumber"
                                                                                                    id="newPhoneNumber"
                                                                                                    class="form-control"
                                                                                                    value="<%= userPhone != null ? userPhone : "" %>"
                                                                                                    placeholder="+60 12-345 6789">
                                                                                            </div>
                                                                                            <div class="col-12">
                                                                                                <label
                                                                                                    class="form-label">Address
                                                                                                    Line 1 *</label>
                                                                                                <input type="text"
                                                                                                    name="newAddressLine1"
                                                                                                    id="newAddressLine1"
                                                                                                    class="form-control"
                                                                                                    placeholder="Street address, house number">
                                                                                            </div>
                                                                                            <div class="col-12">
                                                                                                <label
                                                                                                    class="form-label">Address
                                                                                                    Line 2</label>
                                                                                                <input type="text"
                                                                                                    name="newAddressLine2"
                                                                                                    id="newAddressLine2"
                                                                                                    class="form-control"
                                                                                                    placeholder="Apartment, unit, building">
                                                                                            </div>
                                                                                            <div class="col-md-4">
                                                                                                <label
                                                                                                    class="form-label">Postal
                                                                                                    Code *</label>
                                                                                                <input type="text"
                                                                                                    name="newPostalCode"
                                                                                                    id="newPostalCode"
                                                                                                    class="form-control"
                                                                                                    maxlength="5"
                                                                                                    placeholder="12345">
                                                                                            </div>
                                                                                            <div class="col-md-4">
                                                                                                <label
                                                                                                    class="form-label">City
                                                                                                    *</label>
                                                                                                <input type="text"
                                                                                                    name="newCity"
                                                                                                    id="newCity"
                                                                                                    class="form-control">
                                                                                            </div>
                                                                                            <div class="col-md-4">
                                                                                                <label
                                                                                                    class="form-label">State
                                                                                                    *</label>
                                                                                                <select name="newState"
                                                                                                    id="newState"
                                                                                                    class="form-control">
                                                                                                    <option value="">
                                                                                                        Select</option>
                                                                                                    <option
                                                                                                        value="Johor">
                                                                                                        Johor</option>
                                                                                                    <option
                                                                                                        value="Kedah">
                                                                                                        Kedah</option>
                                                                                                    <option
                                                                                                        value="Kelantan">
                                                                                                        Kelantan
                                                                                                    </option>
                                                                                                    <option
                                                                                                        value="Kuala Lumpur">
                                                                                                        Kuala Lumpur
                                                                                                    </option>
                                                                                                    <option
                                                                                                        value="Labuan">
                                                                                                        Labuan</option>
                                                                                                    <option
                                                                                                        value="Melaka">
                                                                                                        Melaka</option>
                                                                                                    <option
                                                                                                        value="Negeri Sembilan">
                                                                                                        Negeri Sembilan
                                                                                                    </option>
                                                                                                    <option
                                                                                                        value="Pahang">
                                                                                                        Pahang</option>
                                                                                                    <option
                                                                                                        value="Penang">
                                                                                                        Penang</option>
                                                                                                    <option
                                                                                                        value="Perak">
                                                                                                        Perak</option>
                                                                                                    <option
                                                                                                        value="Perlis">
                                                                                                        Perlis</option>
                                                                                                    <option
                                                                                                        value="Putrajaya">
                                                                                                        Putrajaya
                                                                                                    </option>
                                                                                                    <option
                                                                                                        value="Sabah">
                                                                                                        Sabah</option>
                                                                                                    <option
                                                                                                        value="Sarawak">
                                                                                                        Sarawak</option>
                                                                                                    <option
                                                                                                        value="Selangor">
                                                                                                        Selangor
                                                                                                    </option>
                                                                                                    <option
                                                                                                        value="Terengganu">
                                                                                                        Terengganu
                                                                                                    </option>
                                                                                                </select>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="d-flex gap-2 mt-3">
                                                                                            <button type="button"
                                                                                                class="btn-auto-import"
                                                                                                onclick="saveAndSelectAddress()">Save
                                                                                                & Use This
                                                                                                Address</button>
                                                                                            <button type="button"
                                                                                                class="btn btn-sm btn-outline-secondary"
                                                                                                onclick="hideQuickAddForm()">Cancel</button>
                                                                                        </div>
                                                                                    </div>
                                                            </div>

                                                            <!-- Step 3: Payment Method -->
                                                            <div class="checkout-section">
                                                                <h5 class="section-title">
                                                                    <span><span class="step-number">3</span>Payment
                                                                        Method</span>
                                                                </h5>
                                                                <div class="payment-grid">
                                                                    <!-- Credit/Debit Card -->
                                                                    <label class="payment-option selected"
                                                                        data-method="card">
                                                                        <input type="radio" name="paymentMethod"
                                                                            value="card" checked hidden>
                                                                        <div class="payment-icon">
                                                                            <svg class="payment-icon-svg"
                                                                                viewBox="0 0 48 32" fill="none"
                                                                                xmlns="http://www.w3.org/2000/svg">
                                                                                <rect x="2" y="4" width="44" height="24"
                                                                                    rx="3" fill="white" />
                                                                                <rect x="2" y="8" width="44" height="6"
                                                                                    fill="#374151" />
                                                                                <rect x="6" y="18" width="12" height="3"
                                                                                    rx="1" fill="#D1D5DB" />
                                                                                <rect x="6" y="22" width="8" height="2"
                                                                                    rx="1" fill="#D1D5DB" />
                                                                                <circle cx="36" cy="16" r="5"
                                                                                    fill="#ED1C24" fill-opacity="0.9" />
                                                                                <circle cx="40" cy="16" r="5"
                                                                                    fill="#F79E1B" fill-opacity="0.9" />
                                                                            </svg>
                                                                        </div>
                                                                        <div class="payment-name">Credit/Debit Card
                                                                        </div>
                                                                        <div class="payment-desc">Visa, Mastercard</div>
                                                                    </label>

                                                                    <!-- Maybank -->
                                                                    <label class="payment-option" data-method="maybank">
                                                                        <input type="radio" name="paymentMethod" value="maybank" hidden>
                                                                        <div class="payment-icon">
                                                                            <img src="payment-icons/maybank.svg" alt="Maybank" class="payment-icon-img">
                                                                        </div>
                                                                        <div class="payment-name">Maybank</div>
                                                                        <div class="payment-desc">FPX Banking</div>
                                                                    </label>

                                                                    <!-- CIMB -->
                                                                    <label class="payment-option" data-method="cimb">
                                                                        <input type="radio" name="paymentMethod" value="cimb" hidden>
                                                                        <div class="payment-icon">
                                                                            <img src="payment-icons/cimb.svg" alt="CIMB" class="payment-icon-img">
                                                                        </div>
                                                                        <div class="payment-name">CIMB Bank</div>
                                                                        <div class="payment-desc">FPX Banking</div>
                                                                    </label>

                                                                    <!-- Public Bank -->
                                                                    <label class="payment-option" data-method="publicbank">
                                                                        <input type="radio" name="paymentMethod" value="publicbank" hidden>
                                                                        <div class="payment-icon">
                                                                            <img src="payment-icons/publicbank.svg" alt="Public Bank" class="payment-icon-img">
                                                                        </div>
                                                                        <div class="payment-name">Public Bank</div>
                                                                        <div class="payment-desc">FPX Banking</div>
                                                                    </label>

                                                                    <!-- Touch 'n Go -->
                                                                    <label class="payment-option" data-method="tng">
                                                                        <input type="radio" name="paymentMethod" value="tng" hidden>
                                                                        <div class="payment-icon">
                                                                            <img src="payment-icons/tng.svg" alt="Touch n Go" class="payment-icon-img">
                                                                        </div>
                                                                        <div class="payment-name">Touch 'n Go</div>
                                                                        <div class="payment-desc">eWallet</div>
                                                                    </label>

                                                                    <!-- GrabPay -->
                                                                    <label class="payment-option" data-method="grabpay">
                                                                        <input type="radio" name="paymentMethod" value="grabpay" hidden>
                                                                        <div class="payment-icon">
                                                                            <img src="payment-icons/grabpay.svg" alt="GrabPay" class="payment-icon-img">
                                                                        </div>
                                                                        <div class="payment-name">GrabPay</div>
                                                                        <div class="payment-desc">eWallet</div>
                                                                    </label>
                                                                </div>

                                                                <div class="secure-badge">
                                                                    <svg fill="currentColor" viewBox="0 0 20 20">
                                                                        <path fill-rule="evenodd"
                                                                            d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z"
                                                                            clip-rule="evenodd" />
                                                                    </svg>
                                                                    <span>Your payment is secure and encrypted</span>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="col-lg-4">
                                                            <!-- Order Summary -->
                                                            <div class="checkout-section"
                                                                style="position: sticky; top: 20px;">
                                                                <h5 class="section-title"><span>Order Summary</span>
                                                                </h5>
                                                                <div class="summary-row">
                                                                    <span>Subtotal (<%= cartItems.size() %>
                                                                            items)</span>
                                                                    <span>$<%= cartTotal !=null ? String.format("%.2f",
                                                                            cartTotal) : "0.00" %></span>
                                                                </div>
                                                                <div class="summary-row">
                                                                    <span>Shipping</span>
                                                                    <span style="color:#22c55e;">Free</span>
                                                                </div>
                                                                <div class="summary-row total">
                                                                    <span>Total</span>
                                                                    <span>$<%= cartTotal !=null ? String.format("%.2f",
                                                                            cartTotal) : "0.00" %></span>
                                                                </div>

                                                                <% if (addresses !=null && !addresses.isEmpty()) { %>
                                                                    <button type="button" class="btn-place-order"
                                                                        id="payNowBtn" onclick="processPayment()">
                                                                        <span style="margin-right: 8px;">🔒</span> Place
                                                                        Order
                                                                    </button>
                                                                    <% } else { %>
                                                                        <button type="button" class="btn-place-order"
                                                                            id="payNowBtn" onclick="processPayment()"
                                                                            disabled>
                                                                            Add Address to Continue
                                                                        </button>
                                                                        <% } %>

                                                                            <p class="text-center text-muted mt-3"
                                                                                style="font-size: 0.8rem;">
                                                                                By placing your order, you agree to our
                                                                                Terms of Service
                                                                            </p>
                                                            </div>
                                                        </div>
                                                    </div>
                                        </form>
                            </main>

                            <!-- Payment Processing Modal -->
                            <div class="payment-modal-overlay" id="paymentModal">
                                <div class="payment-modal">
                                    <div id="processingState">
                                        <div class="payment-processing">
                                            <div class="spinner"></div>
                                            <h5>Processing Payment...</h5>
                                            <p class="text-muted">Please wait while we securely process your transaction
                                            </p>
                                        </div>
                                        <div class="payment-method-display">
                                            <span id="selectedPaymentIcon">💳</span>
                                            <span id="selectedPaymentName">Credit Card</span>
                                        </div>
                                    </div>
                                    <div id="successState" style="display: none;">
                                        <div class="success-icon">✓</div>
                                        <h4 style="color: #10b981;">Payment Successful!</h4>
                                        <p class="text-muted">Your order has been placed successfully</p>
                                        <p style="font-size: 0.9rem;">Redirecting to order confirmation...</p>
                                    </div>
                                </div>
                            </div>

                            <script>
                                // Payment method display mapping
                                const paymentInfo = {
                                    'card': { name: 'Credit/Debit Card', color: '#1A1F71', icon: '💳' },
                                    'maybank': { name: 'Maybank', color: '#FFC72C', icon: '🏦' },
                                    'cimb': { name: 'CIMB Bank', color: '#ED1C24', icon: '🏦' },
                                    'publicbank': { name: 'Public Bank', color: '#003399', icon: '🏦' },
                                    'tng': { name: "Touch 'n Go eWallet", color: '#0066B3', icon: '📱' },
                                    'grabpay': { name: 'GrabPay', color: '#00B14F', icon: '📱' }
                                };

                                // Legacy mapping for backward compatibility
                                const paymentIcons = {
                                    'card': '💳',
                                    'maybank': '🏦',
                                    'cimb': '🏦',
                                    'publicbank': '🏦',
                                    'tng': '📱',
                                    'grabpay': '📱'
                                };

                                const paymentNames = {
                                    'card': 'Credit/Debit Card',
                                    'maybank': 'Maybank',
                                    'cimb': 'CIMB Bank',
                                    'publicbank': 'Public Bank',
                                    'tng': "Touch 'n Go eWallet",
                                    'grabpay': 'GrabPay'
                                };

                                // Address selection handling
                                document.querySelectorAll('.address-option').forEach(option => {
                                    option.addEventListener('click', function () {
                                        document.querySelectorAll('.address-option').forEach(o => o.classList.remove('selected'));
                                        this.classList.add('selected');
                                        this.querySelector('input[type="radio"]').checked = true;
                                        updatePayButton();
                                    });
                                });

                                // Payment method selection handling
                                document.querySelectorAll('.payment-option').forEach(option => {
                                    option.addEventListener('click', function () {
                                        document.querySelectorAll('.payment-option').forEach(o => o.classList.remove('selected'));
                                        this.classList.add('selected');
                                        this.querySelector('input[type="radio"]').checked = true;
                                    });
                                });

                                // Quick Add Form functions
                                function showQuickAddForm() {
                                    document.getElementById('quickAddForm').style.display = 'block';
                                    document.getElementById('importedBadge').style.display = 'inline';
                                    document.getElementById('autoImportBtn').disabled = true;
                                    document.getElementById('autoImportBtn').textContent = '✓ Profile Loaded';
                                }

                                function hideQuickAddForm() {
                                    document.getElementById('quickAddForm').style.display = 'none';
                                    document.getElementById('autoImportBtn').disabled = false;
                                    document.getElementById('autoImportBtn').textContent = '⚡ Quick Add from Profile';
                                }

                                function saveAndSelectAddress() {
                                    // Validate required fields
                                    const recipientName = document.getElementById('newRecipientName').value.trim();
                                    const phoneNumber = document.getElementById('newPhoneNumber').value.trim();
                                    const addressLine1 = document.getElementById('newAddressLine1').value.trim();
                                    const postalCode = document.getElementById('newPostalCode').value.trim();
                                    const city = document.getElementById('newCity').value.trim();
                                    const state = document.getElementById('newState').value;

                                    if (!recipientName || !phoneNumber || !addressLine1 || !postalCode || !city || !state) {
                                        alert('Please fill in all required fields');
                                        return;
                                    }

                                    // Create form to save address
                                    const form = document.createElement('form');
                                    form.method = 'POST';
                                    form.action = 'user';

                                    const fields = {
                                        'action': 'addAddress',
                                        'recipientName': recipientName,
                                        'phoneNumber': phoneNumber,
                                        'addressLine1': addressLine1,
                                        'addressLine2': document.getElementById('newAddressLine2').value.trim(),
                                        'postalCode': postalCode,
                                        'city': city,
                                        'state': state,
                                        'setDefault': 'on',
                                        'returnToCheckout': 'true'
                                    };

                                    for (const [key, value] of Object.entries(fields)) {
                                        const input = document.createElement('input');
                                        input.type = 'hidden';
                                        input.name = key;
                                        input.value = value;
                                        form.appendChild(input);
                                    }

                                    document.body.appendChild(form);

                                    // Store checkout info in session storage
                                    sessionStorage.setItem('returnToCheckout', 'true');
                                    form.submit();
                                }

                                function updatePayButton() {
                                    const addressSelected = document.querySelector('input[name="addressId"]:checked');
                                    const payBtn = document.getElementById('payNowBtn');
                                    if (addressSelected) {
                                        payBtn.disabled = false;
                                        payBtn.innerHTML = '<span style="margin-right: 8px;">🔒</span> Place Order';
                                    }
                                }

                                // Payment processing simulation
                                function processPayment() {
                                    const addressSelected = document.querySelector('input[name="addressId"]:checked');
                                    if (!addressSelected) {
                                        alert('Please select a shipping address');
                                        return;
                                    }

                                    const paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;

                                    // Update modal with selected payment method
                                    document.getElementById('selectedPaymentIcon').textContent = paymentIcons[paymentMethod];
                                    document.getElementById('selectedPaymentName').textContent = paymentNames[paymentMethod];

                                    // Show processing modal
                                    document.getElementById('paymentModal').classList.add('active');
                                    document.getElementById('processingState').style.display = 'block';
                                    document.getElementById('successState').style.display = 'none';

                                    // Simulate payment processing (2 seconds)
                                    setTimeout(() => {
                                        // Show success state
                                        document.getElementById('processingState').style.display = 'none';
                                        document.getElementById('successState').style.display = 'block';

                                        // Submit form after showing success (1 second)
                                        setTimeout(() => {
                                            document.getElementById('checkoutForm').submit();
                                        }, 1000);
                                    }, 2000);
                                }

                                // Check if returning from address save
                                if (sessionStorage.getItem('returnToCheckout')) {
                                    sessionStorage.removeItem('returnToCheckout');
                                    // Refresh the page to get updated addresses
                                    window.location.href = 'orders?action=checkout';
                                }
                            </script>
                            <script
                                src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                        </body>

                        </html>