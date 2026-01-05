<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.shopease.entity.Product" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (!"admin".equals(userRole)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    String viewType = (String) request.getAttribute("viewType");
    boolean isPendingView = "pending".equals(viewType);
    String pageTitle = isPendingView ? "Pending Approval" : "Product Management";
    String emptyMessage = isPendingView ? "No pending products awaiting approval" : "No products found";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - ShopEase</title>
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
        .logout-link { color: #dc3545 !important; margin-top: 2rem; }
        
        .main-content { margin-left: 220px; padding: 1.5rem; }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .page-title { font-size: 1.25rem; font-weight: 600; margin: 0; }
        
        .table-card {
            background: #fff;
            border-radius: 8px;
            border: 1px solid #eee;
            overflow: hidden;
        }
        .table { margin: 0; font-size: 0.9rem; }
        .table th {
            background: #fafafa;
            font-weight: 500;
            border-bottom: 1px solid #eee;
            padding: 0.75rem 1rem;
        }
        .table td { padding: 0.75rem 1rem; vertical-align: middle; }
        .table img {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border-radius: 4px;
        }
        .status-badge {
            display: inline-block;
            padding: 0.2rem 0.5rem;
            border-radius: 100px;
            font-size: 0.7rem;
        }
        .status-available { background: #e8f5e9; color: #2e7d32; }
        .status-pending { background: #fff3e0; color: #e65100; }
        .status-approved { background: #e3f2fd; color: #1565c0; }
        .status-rejected { background: #ffebee; color: #c62828; }
        .status-sold { background: #fce4ec; color: #c62828; }
        
        .btn-sm-custom {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
            border-radius: 4px;
            text-decoration: none;
        }
        .btn-delete {
            color: #dc3545;
            border: 1px solid #dc3545;
            background: #fff;
        }
        .btn-delete:hover { background: #dc3545; color: #fff; }
        
        .empty-text { text-align: center; padding: 3rem; color: #888; }
    </style>
</head>
<body>
    <nav class="sidebar">
        <div class="sidebar-brand">ShopEase<span>Admin Panel</span></div>
        <ul class="nav flex-column">
            <li class="nav-item"><a class="nav-link" href="admin">Dashboard</a></li>
            <li class="nav-item"><a class="nav-link <%= isPendingView ? "active" : "" %>" href="admin?action=pending">Pending Approval</a></li>
            <li class="nav-item"><a class="nav-link <%= !isPendingView ? "active" : "" %>" href="admin?action=products">All Products</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=users">Users</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=orders">Orders</a></li>
            <li class="nav-item"><a class="nav-link logout-link" href="user?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="main-content">
        <div class="page-header">
            <h1 class="page-title"><%= pageTitle %></h1>
        </div>

        <div class="table-card">
            <% if (products != null && !products.isEmpty()) { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Name</th>
                        <th>Price</th>
                        <th>Category</th>
                        <th>Stock</th>
                        <th>Approval</th>
                        <th>Sale Status</th>
                        <th>Seller</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Product p : products) { %>
                    <tr>
                        <td>
                            <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>"
                                 onerror="this.src='https://via.placeholder.com/40?text=N/A'">
                        </td>
                        <td>
                            <a href="products?action=details&id=<%= p.getId() %>" target="_blank" style="text-decoration: none; color: inherit;">
                                <%= p.getName() %> ↗
                            </a>
                        </td>
                        <td>$<%= String.format("%.2f", p.getPrice()) %></td>
                        <td>
                            <%
                                String cat = p.getCategory();
                                String catName;
                                switch(cat != null ? cat : "") {
                                    case "electronics": catName = "Electronics"; break;
                                    case "books": catName = "Books"; break;
                                    case "clothing": catName = "Clothing"; break;
                                    case "sports": catName = "Sports"; break;
                                    case "furniture": catName = "Furniture"; break;
                                    default: catName = "Other";
                                }
                            %>
                            <%= catName %>
                        </td>
                        <td><%= p.getStock() %></td>
                        <td>
                            <%
                                String approvalStatus = p.getApprovalStatus();
                                String approvalClass = "status-pending";
                                String approvalText = "Pending";
                                if ("approved".equals(approvalStatus)) {
                                    approvalClass = "status-approved";
                                    approvalText = "Approved";
                                } else if ("rejected".equals(approvalStatus)) {
                                    approvalClass = "status-rejected";
                                    approvalText = "Rejected";
                                }
                            %>
                            <select class="form-select form-select-sm"
                                    onchange="updateApproval('<%= p.getId() %>', this.value)"
                                    style="font-size: 0.75rem; padding: 0.25rem 1.75rem 0.25rem 0.5rem; width: auto;">
                                <option value="pending" <%= "pending".equals(approvalStatus) ? "selected" : "" %>>Pending</option>
                                <option value="approved" <%= "approved".equals(approvalStatus) ? "selected" : "" %>>Approved</option>
                                <option value="rejected" <%= "rejected".equals(approvalStatus) ? "selected" : "" %>>Rejected</option>
                            </select>
                        </td>
                        <td>
                            <%
                                String saleStatus = p.getStatus();
                                String saleClass = "status-available";
                                String saleText = "Available";
                                if ("sold".equals(saleStatus)) {
                                    saleClass = "status-sold";
                                    saleText = "Sold";
                                }
                            %>
                            <span class="status-badge <%= saleClass %>"><%= saleText %></span>
                        </td>
                        <td><%= p.getSellerName() != null ? p.getSellerName() : "-" %></td>
                        <td>
                            <a href="admin?action=delete&id=<%= p.getId() %>" class="btn-sm-custom btn-delete"
                               onclick="return confirm('Delete this product?')">Delete</a>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
                <div class="empty-text">
                    <div style="font-size: 3rem; margin-bottom: 1rem;">📦</div>
                    <h4 style="margin-bottom: 0.5rem;"><%= emptyMessage %></h4>
                    <% if (isPendingView) { %>
                        <p style="color: #aaa; font-size: 0.85rem;">All products have been reviewed</p>
                    <% } %>
                </div>
            <% } %>
        </div>
    </main>

    <script>
        function updateApproval(productId, approvalStatus) {
            window.location.href = 'admin?action=updateStatus&id=' + productId + '&status=' + approvalStatus;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
