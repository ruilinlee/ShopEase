<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    } else if (session.getAttribute("userId") != null) {
        response.sendRedirect("products");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEase - Campus Second-hand Trading</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
            margin: 0;
        }
        .hero {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 2rem;
            background: #fff;
        }
        .logo {
            font-size: 2rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 0.5rem;
        }
        .tagline {
            color: #666;
            font-size: 1rem;
            margin-bottom: 2rem;
        }
        .desc {
            color: #888;
            max-width: 400px;
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        .btn-group-custom {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            justify-content: center;
        }
        .btn-main {
            background: #333;
            color: #fff;
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.9rem;
        }
        .btn-main:hover { background: #555; color: #fff; }
        .btn-secondary-custom {
            background: #fff;
            color: #333;
            border: 1px solid #ddd;
            padding: 0.75rem 2rem;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.9rem;
        }
        .btn-secondary-custom:hover { background: #f5f5f5; color: #333; }
        .guest-notice {
            margin-top: 2rem;
            padding: 1rem;
            background: #fafafa;
            border-radius: 4px;
            font-size: 0.85rem;
            color: #666;
            max-width: 400px;
        }
        .admin-link {
            position: fixed;
            bottom: 1rem;
            right: 1rem;
            color: #999;
            text-decoration: none;
            font-size: 0.8rem;
        }
        .admin-link:hover { color: #666; }
    </style>
</head>
<body>
    <section class="hero">
        <h1 class="logo">ShopEase</h1>
        <p class="tagline">Campus Second-hand Trading Platform</p>
        <p class="desc">A safe and convenient platform for students to buy and sell second-hand items. Save money and reduce waste.</p>
        
        <div class="btn-group-custom">
            <a href="products" class="btn-main">Browse Products</a>
            <a href="login.jsp" class="btn-secondary-custom">Log In</a>
        </div>
        
        <div class="guest-notice">
            <strong>Note:</strong> Guests can browse products, but you need to log in to publish items, add to cart, or make purchases.
        </div>
    </section>
    
    <a href="admin_login.jsp" class="admin-link">Admin Portal</a>
</body>
</html>
