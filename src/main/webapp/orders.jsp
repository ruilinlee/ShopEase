<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.Order, com.shopease.entity.Order.OrderItem, java.text.SimpleDateFormat, java.util.Date, java.util.Locale" %>
<%
    // Prevent admin from accessing customer orders page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.ENGLISH);
%>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Orders - ShopEase</title>
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
                            margin-bottom: 1rem;
                            border: 1px solid #eee;
                            overflow: hidden;
                        }

                        .order-header {
                            background: #fafafa;
                            padding: 0.75rem 1rem;
                            border-bottom: 1px solid #eee;
                        }

                        .order-id {
                            font-size: 0.8rem;
                            color: #888;
                            font-family: monospace;
                        }

                        .order-date {
                            font-size: 0.85rem;
                            color: #666;
                        }

                        .order-body {
                            padding: 1rem;
                        }

                        .order-item {
                            display: flex;
                            align-items: center;
                            padding: 0.5rem 0;
                            border-bottom: 1px solid #f0f0f0;
                        }

                        .order-item:last-child {
                            border-bottom: none;
                        }

                        .item-img {
                            width: 50px;
                            height: 50px;
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
                            font-weight: 500;
                            font-size: 0.9rem;
                        }

                        .order-status {
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

                        .refund-badge {
                            background: #fff8e1;
                            color: #f57c00;
                            padding: 0.2rem 0.5rem;
                            border-radius: 100px;
                            font-size: 0.7rem;
                            margin-left: 0.5rem;
                        }

                        .order-total {
                            font-weight: 600;
                            font-size: 1rem;
                        }

                        .order-footer {
                            background: #fafafa;
                            padding: 0.75rem 1rem;
                            border-top: 1px solid #eee;
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            gap: 0.75rem;
                            flex-wrap: wrap;
                        }

                        .details-link {
                            border: 1px solid #ddd;
                            color: #333;
                            text-decoration: none;
                            padding: 0.25rem 0.6rem;
                            border-radius: 4px;
                            font-size: 0.8rem;
                        }

                        .details-link:hover {
                            background: #f5f5f5;
                            color: #333;
                        }

                        .empty-orders {
                            text-align: center;
                            padding: 4rem 2rem;
                            background: #fff;
                            border-radius: 8px;
                            border: 1px solid #eee;
                        }

                        .btn-shop {
                            background: #333;
                            color: #fff;
                            border: none;
                            padding: 0.5rem 1.5rem;
                            border-radius: 4px;
                            text-decoration: none;
                            font-size: 0.9rem;
                            display: inline-block;
                            margin-top: 1rem;
                        }

                        .btn-shop:hover {
                            background: #555;
                            color: #fff;
                        }
                    </style>
                </head>

                <body>
                    <div class="page-header">
                        <div class="container">
                            <div class="d-flex justify-content-between align-items-center">
                                <h1 class="page-title">My Orders</h1>
                                <a href="products" class="back-link">← Continue Shopping</a>
                            </div>
                        </div>
                    </div>

                    <main class="container my-4">
                        <% if (orders !=null && !orders.isEmpty()) { for (Order order : orders) { %>
                            <div class="order-card">
                                <div class="order-header">
                                    <div class="row align-items-center">
                                        <div class="col">
                                            <span class="order-id">Order: <%= order.getId().substring(0, 8) %>...</span>
                                        </div>
                                        <div class="col-auto">
                                            <span class="order-date">
                                                <%= sdf.format(new Date(order.getCreatedAt())) %>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="order-body">
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
                                            <div class="item-subtotal">$<%= String.format("%.2f", item.getSubtotal()) %>
                                            </div>
                                        </div>
                                        <% } %>
                                </div>
                                <div class="order-footer">
                                    <% String status=order.getStatus();
                                        boolean hasRefundRequest = order.hasRefundRequest();
                                        String statusClass="status-pending";
                                        String statusText="Pending";
                                        switch(status !=null ? status : "" ) {
                                            case "pending" : statusClass="status-pending" ; statusText="Pending" ; break;
                                            case "confirmed" : statusClass="status-confirmed" ; statusText="Confirmed" ; break;
                                            case "shipped" : statusClass="status-shipped" ; statusText="Shipped" ; break;
                                            case "delivered" : statusClass="status-delivered" ; statusText="Delivered" ; break;
                                            case "cancelled" : statusClass="status-cancelled" ; statusText="Cancelled" ; break;
                                            case "completed" : statusClass="status-completed" ; statusText="Completed" ; break;
                                            case "refunded" : statusClass="status-refunded" ; statusText="Refunded" ; break;
                                            default: statusClass="status-pending" ; statusText="Pending" ;
                                        } %>
                                        <div>
                                            <span class="order-status <%= statusClass %>">
                                                <%= statusText %>
                                            </span>
                                            <% if (hasRefundRequest) { %>
                                                <span class="refund-badge">Refund Requested</span>
                                            <% } %>
                                        </div>
                                        <a href="orders?action=details&id=<%= order.getId() %>"
                                            class="details-link">View Details</a>
                                        <span class="order-total">Total: $<%= String.format("%.2f",
                                                order.getTotalAmount()) %></span>
                                </div>
                            </div>
                            <% } } else { %>
                                <div class="empty-orders">
                                    <h5>No orders yet</h5>
                                    <p class="text-muted">You haven't made any purchases</p>
                                    <a href="products" class="btn-shop">Browse Products</a>
                                </div>
                                <% } %>
                    </main>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>