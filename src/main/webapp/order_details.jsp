<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shopease.entity.Order, com.shopease.entity.Order.OrderItem, java.text.SimpleDateFormat, java.util.Date, java.util.Locale" %>
<%
    // Prevent admin from accessing customer order details page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("orders");
        return;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.ENGLISH);
    String status = order.getStatus();
    String statusClass = "status-pending";
    String statusText = "Pending";
    switch (status != null ? status : "") {
        case "pending": statusClass = "status-pending"; statusText = "Pending"; break;
        case "confirmed": statusClass = "status-confirmed"; statusText = "Confirmed"; break;
        case "shipped": statusClass = "status-shipped"; statusText = "Shipped"; break;
        case "delivered": statusClass = "status-delivered"; statusText = "Delivered"; break;
        case "cancelled": statusClass = "status-cancelled"; statusText = "Cancelled"; break;
        case "completed": statusClass = "status-completed"; statusText = "Completed"; break;
        case "refunded": statusClass = "status-refunded"; statusText = "Refunded"; break;
        default: statusClass = "status-pending"; statusText = "Pending";
    }
    // Payment and refund info
    String paymentMethod = order.getPaymentMethod();
    String paymentStatus = order.getPaymentStatus();
    String refundStatus = order.getRefundStatus();
    boolean isRefundable = order.isRefundable();
    boolean hasRefundRequest = order.hasRefundRequest();
%>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Order Details - ShopEase</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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

                    .summary-card {
                        background: #fff;
                        border-radius: 8px;
                        border: 1px solid #eee;
                        padding: 1rem;
                        margin-bottom: 1rem;
                    }

                    .summary-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                        gap: 1rem;
                    }

                    .summary-item {
                        font-size: 0.9rem;
                        color: #666;
                    }

                    .summary-item strong {
                        color: #333;
                        font-weight: 600;
                        display: block;
                        margin-top: 0.25rem;
                    }

                    .status-badge {
                        display: inline-block;
                        padding: 0.2rem 0.6rem;
                        border-radius: 100px;
                        font-size: 0.75rem;
                        font-weight: 500;
                    }

                    .status-pending {
                        background: #fff3e0;
                        color: #e65100;
                    }

                    .status-confirmed {
                        background: #e3f2fd;
                        color: #1565c0;
                    }

                    .status-shipped {
                        background: #f3e5f5;
                        color: #7b1fa2;
                    }

                    .status-delivered {
                        background: #e8f5e9;
                        color: #2e7d32;
                    }

                    .status-cancelled {
                        background: #ffebee;
                        color: #c62828;
                    }

                    .status-completed {
                        background: #e8f5e9;
                        color: #2e7d32;
                    }

                    .status-refunded {
                        background: #fce4ec;
                        color: #c62828;
                    }

                    .item-card {
                        background: #fff;
                        border-radius: 8px;
                        border: 1px solid #eee;
                        padding: 1rem;
                        margin-bottom: 1rem;
                    }

                    .card-title {
                        font-weight: 600;
                        font-size: 0.95rem;
                        margin-bottom: 0.75rem;
                        padding-bottom: 0.5rem;
                        border-bottom: 1px solid #eee;
                    }

                    .order-item {
                        display: flex;
                        align-items: center;
                        padding: 0.6rem 0;
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
                        font-size: 0.95rem;
                        font-weight: 500;
                    }

                    .item-qty {
                        font-size: 0.8rem;
                        color: #888;
                    }

                    .item-subtotal {
                        font-weight: 600;
                        font-size: 0.95rem;
                    }

                    .info-row {
                        display: flex;
                        margin-bottom: 0.5rem;
                        font-size: 0.9rem;
                    }

                    .info-label {
                        color: #888;
                        width: 120px;
                        flex-shrink: 0;
                    }

                    .info-value {
                        color: #333;
                    }

                    .refund-section {
                        background: #fff;
                        border-radius: 8px;
                        border: 1px solid #eee;
                        padding: 1rem;
                        margin-top: 1rem;
                    }

                    .refund-warning {
                        background: #fff3e0;
                        border: 1px solid #ffcc80;
                        border-radius: 4px;
                        padding: 0.75rem;
                        font-size: 0.85rem;
                        color: #e65100;
                        margin-bottom: 1rem;
                    }

                    .refund-info {
                        background: #e3f2fd;
                        border-radius: 4px;
                        padding: 0.75rem;
                        font-size: 0.85rem;
                        color: #1565c0;
                    }

                    .refund-rejected {
                        background: #ffebee;
                        color: #c62828;
                    }

                    .refund-approved {
                        background: #e8f5e9;
                        color: #2e7d32;
                    }

                    .btn-refund {
                        background: #dc3545;
                        color: #fff;
                        border: none;
                        padding: 0.5rem 1.25rem;
                        border-radius: 4px;
                        font-size: 0.9rem;
                        cursor: pointer;
                    }

                    .btn-refund:hover {
                        background: #c82333;
                        color: #fff;
                    }
                </style>
            </head>

            <body>
                <div class="page-header">
                    <div class="container">
                        <div class="d-flex justify-content-between align-items-center">
                            <h1 class="page-title">Order Details</h1>
                            <div class="d-flex align-items-center gap-3">
                                <a href="orders" class="back-link">← Back to Orders</a>
                                <span class="status-badge <%= statusClass %>">
                                    <%= statusText %>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <main class="container my-4">
                    <div class="row">
                        <div class="col-lg-8">
                            <!-- Order Summary -->
                            <div class="summary-card">
                                <div class="summary-grid">
                                    <div class="summary-item">
                                        Order ID
                                        <strong>#<%= order.getId().substring(0, 8) %></strong>
                                    </div>
                                    <div class="summary-item">
                                        Date
                                        <strong>
                                            <%= sdf.format(new Date(order.getCreatedAt())) %>
                                        </strong>
                                    </div>
                                    <div class="summary-item">
                                        Items
                                        <strong>
                                            <%= order.getItems() !=null ? order.getItems().size() : 0 %>
                                        </strong>
                                    </div>
                                    <div class="summary-item">
                                        Total
                                        <strong>$<%= String.format("%.2f", order.getTotalAmount()) %></strong>
                                    </div>
                                </div>
                            </div>

                            <!-- Order Items -->
                            <div class="item-card">
                                <h5 class="card-title">Order Items</h5>
                                <% if (order.getItems() !=null) { for (OrderItem item : order.getItems()) { %>
                                    <div class="order-item">
                                        <img src="<%= item.getImageUrl() %>" class="item-img"
                                            alt="<%= item.getProductName() %>"
                                            onerror="this.src='https://via.placeholder.com/60?text=N/A'">
                                        <div class="flex-grow-1">
                                            <div class="item-name">
                                                <%= item.getProductName() %>
                                            </div>
                                            <div class="item-qty">
                                                <%= item.getQuantity() %> x $<%= String.format("%.2f", item.getPrice())
                                                        %>
                                            </div>
                                        </div>
                                        <div class="item-subtotal">$<%= String.format("%.2f", item.getSubtotal()) %>
                                        </div>
                                    </div>
                                    <% } } %>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <!-- Payment Info -->
                            <div class="item-card">
                                <h5 class="card-title">Payment Information</h5>
                                <div class="info-row">
                                    <span class="info-label">Method</span>
                                    <span class="info-value">
                                        <% String methodDisplay="Credit Card" ; if ("maybank".equals(paymentMethod))
                                            methodDisplay="Maybank" ; else if ("cimb".equals(paymentMethod))
                                            methodDisplay="CIMB Bank" ; else if ("publicbank".equals(paymentMethod))
                                            methodDisplay="Public Bank" ; else if ("tng".equals(paymentMethod))
                                            methodDisplay="Touch 'n Go" ; else if ("grabpay".equals(paymentMethod))
                                            methodDisplay="GrabPay" ; else if ("card".equals(paymentMethod))
                                            methodDisplay="Credit/Debit Card" ; %>
                                            <%= methodDisplay %>
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Status</span>
                                    <span class="info-value">
                                        <% if ("paid".equals(paymentStatus)) { %>
                                            <span class="status-badge status-delivered">Paid</span>
                                            <% } else if ("refunded".equals(paymentStatus)) { %>
                                                <span class="status-badge status-cancelled">Refunded</span>
                                                <% } else { %>
                                                    <span class="status-badge status-pending">Pending</span>
                                                    <% } %>
                                    </span>
                                </div>
                            </div>

                            <!-- Shipping Address -->
                            <% if (order.getShippingAddress() !=null) { %>
                                <div class="item-card">
                                    <h5 class="card-title">Shipping Address</h5>
                                    <p style="font-size: 0.9rem; color: #666; margin: 0; line-height: 1.6;">
                                        <%= order.getShippingAddress() %>
                                    </p>
                                </div>
                                <% } %>

                                    <!-- Refund Section -->
                                    <div class="refund-section">
                                        <h5 class="card-title">Refund</h5>
                                        <% if ("refunded".equals(refundStatus)) { %>
                                            <div class="refund-info refund-approved">
                                                <strong>Refund Approved</strong><br>
                                                Your refund has been processed successfully.
                                            </div>
                                            <% } else if ("rejected".equals(refundStatus)) { %>
                                                <div class="refund-info refund-rejected">
                                                    <strong>Refund Rejected</strong><br>
                                                    Your refund request was not approved by the seller.
                                                </div>
                                                <% } else if (hasRefundRequest) { %>
                                                    <div class="refund-info">
                                                        <strong>Refund Requested</strong><br>
                                                        Your refund request is being reviewed by the seller.
                                                        <% if (order.getRefundReason() !=null) { %>
                                                            <br><small>Reason: <%= order.getRefundReason() %></small>
                                                            <% } %>
                                                    </div>
                                                    <% } else if (isRefundable) { %>
                                                        <div class="refund-warning">
                                                            <strong>Note:</strong> Refund requests for orders that
                                                            haven't been shipped are automatically approved.
                                                            For shipped/delivered orders, the seller will review your
                                                            request.
                                                        </div>
                                                        <form action="orders" method="post">
                                                            <input type="hidden" name="action" value="requestRefund">
                                                            <input type="hidden" name="orderId"
                                                                value="<%= order.getId() %>">
                                                            <div class="mb-3">
                                                                <label class="form-label"
                                                                    style="font-size: 0.9rem;">Reason for refund</label>
                                                                <textarea name="reason" class="form-control" rows="3"
                                                                    placeholder="Please describe why you want a refund..."
                                                                    required maxlength="500"></textarea>
                                                            </div>
                                                            <button type="submit" class="btn-refund"
                                                                onclick="return confirm('Are you sure you want to request a refund?')">
                                                                Request Refund
                                                            </button>
                                                        </form>
                                                        <% } else { %>
                                                            <p style="font-size: 0.9rem; color: #888; margin: 0;">
                                                                This order is not eligible for refund.
                                                            </p>
                                                            <% } %>
                                    </div>
                        </div>
                    </div>
                </main>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>