<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.shopease.entity.Product" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (!"admin".equals(userRole)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<Product> pendingProducts = (List<Product>) request.getAttribute("pendingProducts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ShopEase</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
        }
        .sidebar {
            background: #333;
            min-height: 100vh;
            position: fixed;
            width: 220px;
            padding: 1rem;
        }
        .sidebar-brand {
            color: #fff;
            font-weight: 600;
            font-size: 1.1rem;
            padding: 0.5rem 1rem;
            margin-bottom: 1rem;
            border-bottom: 1px solid #444;
            padding-bottom: 1rem;
        }
        .sidebar-brand span { color: #999; font-size: 0.75rem; display: block; }
        .nav-link {
            color: #aaa;
            padding: 0.6rem 1rem;
            border-radius: 4px;
            margin-bottom: 0.25rem;
            font-size: 0.9rem;
        }
        .nav-link:hover, .nav-link.active { background: #444; color: #fff; }
        .nav-link .badge { background: #666; font-size: 0.7rem; }
        .logout-link { color: #dc3545 !important; margin-top: 2rem; }
        
        .main-content { margin-left: 220px; padding: 1.5rem; }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .page-title { font-size: 1.25rem; font-weight: 600; margin: 0; }
        .user-info { font-size: 0.85rem; color: #666; }
        
        .stat-card {
            background: #fff;
            border-radius: 8px;
            padding: 1.25rem;
            border: 1px solid #eee;
        }
        .stat-value { font-size: 2rem; font-weight: 700; }
        .stat-label { font-size: 0.85rem; color: #888; }
        
        .section-title { font-size: 1rem; font-weight: 600; margin-bottom: 1rem; }
        .pending-card {
            background: #fff;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 0.5rem;
            border: 1px solid #eee;
        }
        .pending-card img {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 4px;
        }
        .pending-name { font-weight: 500; font-size: 0.9rem; }
        .pending-price { font-size: 0.85rem; color: #333; }
        .pending-seller { font-size: 0.8rem; color: #888; }
        .btn-approve {
            background: #333;
            color: #fff;
            border: none;
            padding: 0.3rem 0.75rem;
            border-radius: 4px;
            font-size: 0.8rem;
            text-decoration: none;
        }
        .btn-approve:hover { background: #555; color: #fff; }
        .btn-reject {
            background: #fff;
            color: #dc3545;
            border: 1px solid #dc3545;
            padding: 0.3rem 0.75rem;
            border-radius: 4px;
            font-size: 0.8rem;
            text-decoration: none;
        }
        .btn-reject:hover { background: #dc3545; color: #fff; }
        
        .empty-text { text-align: center; padding: 2rem; color: #888; font-size: 0.9rem; }
    </style>
</head>
<body>
    <nav class="sidebar">
        <div class="sidebar-brand">ShopEase<span>Admin Panel</span></div>
        <ul class="nav flex-column">
            <li class="nav-item"><a class="nav-link active" href="admin">Dashboard</a></li>
            <li class="nav-item">
                <a class="nav-link" href="admin?action=pending">
                    Pending Approval
                    <% if (stats != null && (Integer)stats.get("pendingProducts") > 0) { %>
                        <span class="badge float-end"><%= stats.get("pendingProducts") %></span>
                    <% } %>
                </a>
            </li>
            <li class="nav-item"><a class="nav-link" href="admin?action=products">All Products</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=users">Users</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=orders">Orders</a></li>
            <li class="nav-item"><a class="nav-link logout-link" href="user?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="main-content">
        <div class="page-header">
            <h1 class="page-title">Dashboard</h1>
            <span class="user-info">Admin: <%= session.getAttribute("username") %></span>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("totalProducts") : 0 %></div>
                    <div class="stat-label">Total Products</div>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("pendingProducts") : 0 %></div>
                    <div class="stat-label">Pending</div>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("totalUsers") : 0 %></div>
                    <div class="stat-label">Users</div>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("totalOrders") : 0 %></div>
                    <div class="stat-label">Orders</div>
                </div>
            </div>
        </div>

        <h5 class="section-title">Recent Pending Products</h5>
        <% if (pendingProducts != null && !pendingProducts.isEmpty()) {
            for (Product p : pendingProducts) { %>
            <div class="pending-card">
                <div class="row align-items-center">
                    <div class="col-auto">
                        <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>"
                             onerror="this.src='https://via.placeholder.com/50?text=N/A'">
                    </div>
                    <div class="col">
                        <div class="pending-name"><%= p.getName() %></div>
                        <div class="pending-price">$<%= String.format("%.2f", p.getPrice()) %></div>
                    </div>
                    <div class="col-auto">
                        <span class="pending-seller">Seller: <%= p.getSellerName() %></span>
                    </div>
                    <div class="col-auto">
                        <a href="admin?action=approve&id=<%= p.getId() %>" class="btn-approve">Approve</a>
                        <a href="admin?action=reject&id=<%= p.getId() %>" class="btn-reject" 
                           onclick="return confirm('Reject this product?')">Reject</a>
                    </div>
                </div>
            </div>
        <% } } else { %>
            <div class="empty-text">No pending products</div>
        <% } %>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
