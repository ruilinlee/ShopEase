<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.Order, com.shopease.entity.Order.OrderItem, java.text.SimpleDateFormat, java.util.Date" %>
<%
    // Prevent admin from accessing seller sales page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Order> sales = (List<Order>) request.getAttribute("sales");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Sales - ShopEase</title>
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

                        .order-card {
                            background: #fff;
                            border-radius: 8px;
                            border: 1px solid #eee;
                            padding: 1.25rem;
                            margin-bottom: 1rem;
                        }

                        .order-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 1rem;
                            padding-bottom: 0.75rem;
                            border-bottom: 1px solid #eee;
                        }

                        .order-id {
                            font-size: 0.85rem;
                            color: #888;
                        }

                        .order-date {
                            font-size: 0.85rem;
                            color: #888;
                        }

                        .status-badge {
                            display: inline-block;
                            padding: 0.25rem 0.6rem;
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
                            background: #e8f5e9;
                            color: #2e7d32;
                        }

                        .status-delivered {
                            background: #e8f5e9;
                            color: #1b5e20;
                        }

                        .status-cancelled {
                            background: #ffebee;
                            color: #c62828;
                        }

                        .status-refunded {
                            background: #fce4ec;
                            color: #c62828;
                        }

                        .refund-badge {
                            background: #fff3e0;
                            color: #e65100;
                            font-size: 0.75rem;
                            padding: 0.2rem 0.5rem;
                            border-radius: 4px;
                            margin-left: 0.5rem;
                        }

                        .order-item {
                            display: flex;
                            align-items: center;
                            padding: 0.5rem 0;
                            border-bottom: 1px solid #f5f5f5;
                        }

                        .order-item:last-child {
                            border-bottom: none;
                        }

                        .item-img {
                            width: 50px;
                            height: 50px;
                            object-fit: cover;
                            border-radius: 4px;
                            margin-right: 0.75rem;
                            background: #f5f5f5;
                        }

                        .item-name {
                            font-size: 0.9rem;
                            font-weight: 500;
                        }

                        .item-qty {
                            font-size: 0.8rem;
                            color: #888;
                        }

                        .order-footer {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-top: 1rem;
                            padding-top: 0.75rem;
                            border-top: 1px solid #eee;
                        }

                        .buyer-info {
                            font-size: 0.85rem;
                            color: #666;
                        }

                        .order-total {
                            font-weight: 600;
                            font-size: 1rem;
                        }

                        .btn-action {
                            background: #333;
                            color: #fff;
                            border: none;
                            padding: 0.4rem 0.8rem;
                            border-radius: 4px;
                            font-size: 0.8rem;
                            cursor: pointer;
                        }

                        .btn-action:hover {
                            background: #555;
                            color: #fff;
                        }

                        .btn-success-action {
                            background: #22c55e;
                            color: #fff;
                        }

                        .btn-success-action:hover {
                            background: #16a34a;
                        }

                        .btn-danger-action {
                            background: #dc3545;
                            color: #fff;
                        }

                        .btn-danger-action:hover {
                            background: #c82333;
                        }

                        .refund-reason {
                            background: #fff3e0;
                            border-radius: 4px;
                            padding: 0.5rem 0.75rem;
                            margin-top: 0.75rem;
                            font-size: 0.85rem;
                        }

                        .empty-state {
                            text-align: center;
                            padding: 4rem 2rem;
                            background: #fff;
                            border-radius: 8px;
                            border: 1px solid #eee;
                            color: #888;
                        }

                        .nav-tabs-custom {
                            border-bottom: 1px solid #eee;
                            margin-bottom: 1.5rem;
                        }

                        .nav-tabs-custom .nav-link {
                            color: #666;
                            border: none;
                            padding: 0.75rem 1rem;
                            font-size: 0.9rem;
                        }

                        .nav-tabs-custom .nav-link.active {
                            color: #333;
                            font-weight: 600;
                            border-bottom: 2px solid #333;
                        }
                    </style>
                </head>

                <body>
                    <div class="page-header">
                        <div class="container">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h1 class="page-title">My Sales</h1>
                                    <a href="products?action=myListings" class="back-link">← Back to My Listings</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <main class="container my-4">
                        <% if (sales !=null && !sales.isEmpty()) { %>
                            <% for (Order order : sales) { String status=order.getStatus(); String
                                statusClass="status-pending" ; String statusText="Pending" ; switch (status !=null ?
                                status : "" ) { case "pending" : statusClass="status-pending" ; statusText="Pending" ;
                                break; case "confirmed" : statusClass="status-confirmed" ; statusText="Confirmed" ;
                                break; case "shipped" : statusClass="status-shipped" ; statusText="Shipped" ; break;
                                case "delivered" : statusClass="status-delivered" ; statusText="Delivered" ; break;
                                case "cancelled" : statusClass="status-cancelled" ; statusText="Cancelled" ; break;
                                case "refunded" : statusClass="status-refunded" ; statusText="Refunded" ; break; }
                                String refundStatus=order.getRefundStatus(); boolean hasRefundRequest="requested"
                                .equals(refundStatus); %>
                                <div class="order-card">
                                    <div class="order-header">
                                        <div>
                                            <span class="order-id">Order #<%= order.getId().substring(0, 8) %></span>
                                            <span class="order-date ms-3">
                                                <%= dateFormat.format(new Date(order.getCreatedAt())) %>
                                            </span>
                                        </div>
                                        <div>
                                            <span class="status-badge <%= statusClass %>">
                                                <%= statusText %>
                                            </span>
                                            <% if (hasRefundRequest) { %>
                                                <span class="refund-badge">Refund Requested</span>
                                                <% } %>
                                        </div>
                                    </div>

                                    <div class="order-items">
                                        <% for (OrderItem item : order.getItems()) { %>
                                            <div class="order-item">
                                                <img src="<%= item.getImageUrl() %>" class="item-img"
                                                    alt="<%= item.getProductName() %>"
                                                    onerror="this.src='https://via.placeholder.com/50?text=N/A'">
                                                <div class="flex-grow-1">
                                                    <div class="item-name">
                                                        <%= item.getProductName() %>
                                                    </div>
                                                    <div class="item-qty">
                                                        <%= item.getQuantity() %> x $<%= String.format("%.2f",
                                                                item.getPrice()) %>
                                                    </div>
                                                </div>
                                                <div class="text-end">
                                                    <strong>$<%= String.format("%.2f", item.getSubtotal()) %></strong>
                                                </div>
                                            </div>
                                            <% } %>
                                    </div>

                                    <% if (hasRefundRequest && order.getRefundReason() !=null) { %>
                                        <div class="refund-reason">
                                            <strong>Refund Reason:</strong>
                                            <%= order.getRefundReason() %>
                                        </div>
                                        <% } %>

                                            <div class="order-footer">
                                                <div class="buyer-info">
                                                    Buyer: <strong>
                                                        <%= order.getBuyerName() %>
                                                    </strong>
                                                    <% if (order.getShippingAddress() !=null) { %>
                                                        <br><small>
                                                            <%= order.getShippingAddress() %>
                                                        </small>
                                                        <% } %>
                                                </div>
                                                <div class="d-flex align-items-center gap-3">
                                                    <span class="order-total">$<%= String.format("%.2f",
                                                            order.getTotalAmount()) %></span>

                                                    <% if (hasRefundRequest) { %>
                                                        <form action="orders" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="approveRefund">
                                                            <input type="hidden" name="orderId"
                                                                value="<%= order.getId() %>">
                                                            <button type="submit" class="btn-action btn-success-action"
                                                                onclick="return confirm('Approve this refund request?')">
                                                                Approve Refund
                                                            </button>
                                                        </form>
                                                        <form action="orders" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="rejectRefund">
                                                            <input type="hidden" name="orderId"
                                                                value="<%= order.getId() %>">
                                                            <button type="submit" class="btn-action btn-danger-action"
                                                                onclick="return confirm('Reject this refund request?')">
                                                                Reject
                                                            </button>
                                                        </form>
                                                    <% } else if ("pending".equals(status)) { %>
                                                        <form action="orders" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="confirmOrder">
                                                            <input type="hidden" name="orderId"
                                                                value="<%= order.getId() %>">
                                                            <button type="submit" class="btn-action"
                                                                onclick="return confirm('Confirm this order?')">
                                                                Confirm Order
                                                            </button>
                                                        </form>
                                                    <% } else if ("confirmed".equals(status)) { %>
                                                        <form action="orders" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="shipOrder">
                                                            <input type="hidden" name="orderId"
                                                                value="<%= order.getId() %>">
                                                            <button type="submit" class="btn-action"
                                                                onclick="return confirm('Mark as shipped?')">
                                                                Ship Order
                                                            </button>
                                                        </form>
                                                    <% } else if ("shipped".equals(status)) { %>
                                                        <form action="orders" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="deliverOrder">
                                                            <input type="hidden" name="orderId"
                                                                value="<%= order.getId() %>">
                                                            <button type="submit" class="btn-action btn-success-action"
                                                                onclick="return confirm('Mark as delivered?')">
                                                                Mark Delivered
                                                            </button>
                                                        </form>
                                                    <% } %>
                                                </div>
                                            </div>
                                </div>
                                <% } %>
                                    <% } else { %>
                                        <div class="empty-state">
                                            <h5>No sales yet</h5>
                                            <p>When customers purchase your products, orders will appear here.</p>
                                            <a href="products?action=publish" class="btn-action"
                                                style="display:inline-block; padding: 0.5rem 1.5rem;">List a Product</a>
                                        </div>
                                        <% } %>
                    </main>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>