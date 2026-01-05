<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shopease.entity.Order" %>
<%
    // Prevent admin from accessing order success page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }

    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("orders");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed - ShopEase</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .success-card {
            background: #fff;
            border-radius: 8px;
            border: 1px solid #eee;
            max-width: 450px;
            width: 100%;
            text-align: center;
            padding: 2.5rem;
        }
        .success-icon {
            width: 80px;
            height: 80px;
            background: #e8f5e9;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2.5rem;
            color: #2e7d32;
        }
        .success-title { font-size: 1.5rem; font-weight: 600; margin-bottom: 0.5rem; color: #333; }
        .success-text { color: #666; font-size: 0.9rem; margin-bottom: 1.5rem; }
        .order-info {
            background: #fafafa;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1.5rem;
            text-align: left;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }
        .info-row:last-child { margin-bottom: 0; }
        .info-label { color: #888; }
        .info-value { font-weight: 500; color: #333; }
        
        .btn-primary-custom {
            background: #333;
            color: #fff;
            border: none;
            padding: 0.7rem 2rem;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.9rem;
            display: inline-block;
            margin-right: 0.5rem;
        }
        .btn-primary-custom:hover { background: #555; color: #fff; }
        .btn-outline-custom {
            background: #fff;
            color: #333;
            border: 1px solid #ddd;
            padding: 0.7rem 1.5rem;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.9rem;
            display: inline-block;
        }
        .btn-outline-custom:hover { background: #f5f5f5; color: #333; }
    </style>
</head>
<body>
    <div class="success-card">
        <div class="success-icon">✓</div>
        <h1 class="success-title">Order Confirmed!</h1>
        <p class="success-text">Thank you for your purchase. Your order has been placed.</p>
        
        <div class="order-info">
            <div class="info-row">
                <span class="info-label">Order ID</span>
                <span class="info-value"><%= order.getId().substring(0, 12) %>...</span>
            </div>
            <div class="info-row">
                <span class="info-label">Items</span>
                <span class="info-value"><%= order.getItems() != null ? order.getItems().size() : 0 %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Total</span>
                <span class="info-value">$<%= String.format("%.2f", order.getTotalAmount()) %></span>
            </div>
        </div>

        <div>
            <a href="orders" class="btn-primary-custom">View Orders</a>
            <a href="products" class="btn-outline-custom">Continue Shopping</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
