<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.shopease.entity.Order" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (!"admin".equals(userRole)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    List<Order> orders = (List<Order>) request.getAttribute("orders");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management - ShopEase</title>
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
        
        .status-badge {
            display: inline-block;
            padding: 0.2rem 0.5rem;
            border-radius: 100px;
            font-size: 0.7rem;
        }
        .status-pending { background: #fff3e0; color: #e65100; }
        .status-confirmed { background: #e3f2fd; color: #1565c0; }
        .status-shipped { background: #f3e5f5; color: #7b1fa2; }
        .status-delivered { background: #e8f5e9; color: #2e7d32; }
        .status-cancelled { background: #ffebee; color: #c62828; }
        .status-refundRequested { background: #fff8e1; color: #f57c00; }
        .status-refunded { background: #fce4ec; color: #c62828; }

        .btn-sm-custom {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
            margin-right: 0.25rem;
        }
        .btn-confirm { color: #1565c0; border: 1px solid #1565c0; background: #fff; }
        .btn-confirm:hover { background: #1565c0; color: #fff; }
        .btn-ship { color: #7b1fa2; border: 1px solid #7b1fa2; background: #fff; }
        .btn-ship:hover { background: #7b1fa2; color: #fff; }
        .btn-deliver { color: #2e7d32; border: 1px solid #2e7d32; background: #fff; }
        .btn-deliver:hover { background: #2e7d32; color: #fff; }
        .btn-approve-refund { color: #2e7d32; border: 1px solid #2e7d32; background: #fff; }
        .btn-approve-refund:hover { background: #2e7d32; color: #fff; }
        .btn-reject-refund { color: #c62828; border: 1px solid #c62828; background: #fff; }
        .btn-reject-refund:hover { background: #c62828; color: #fff; }
        
        .empty-text { text-align: center; padding: 3rem; color: #888; }
    </style>
</head>
<body>
    <nav class="sidebar">
        <div class="sidebar-brand">ShopEase<span>Admin Panel</span></div>
        <ul class="nav flex-column">
            <li class="nav-item"><a class="nav-link" href="admin">Dashboard</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=pending">Pending Approval</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=products">All Products</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=users">Users</a></li>
            <li class="nav-item"><a class="nav-link active" href="admin?action=orders">Orders</a></li>
            <li class="nav-item"><a class="nav-link logout-link" href="user?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="main-content">
        <div class="page-header">
            <h1 class="page-title">Order Management</h1>
        </div>

        <div class="table-card">
            <% if (orders != null && !orders.isEmpty()) { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User</th>
                        <th>Items</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Order o : orders) { %>
                    <tr>
                        <td>#<%= o.getId().substring(0, 8) %></td>
                        <td><%= o.getUsername() != null ? o.getUsername() : "User " + o.getUserId() %></td>
                        <td><%= o.getItems() != null ? o.getItems().size() : 0 %> items</td>
                        <td>$<%= String.format("%.2f", o.getTotalAmount()) %></td>
                        <td>
                            <%
                                String status = o.getStatus();
                                boolean hasRefundRequest = o.isRefundRequested() && !"refunded".equals(status);
                                String statusClass = "";
                                String statusText = "";
                                switch(status != null ? status : "") {
                                    case "pending": statusClass = "status-pending"; statusText = "Pending"; break;
                                    case "confirmed": statusClass = "status-confirmed"; statusText = "Confirmed"; break;
                                    case "shipped": statusClass = "status-shipped"; statusText = "Shipped"; break;
                                    case "delivered": statusClass = "status-delivered"; statusText = "Delivered"; break;
                                    case "cancelled": statusClass = "status-cancelled"; statusText = "Cancelled"; break;
                                    case "refundRequested": statusClass = "status-refundRequested"; statusText = "Refund Requested"; break;
                                    case "refunded": statusClass = "status-refunded"; statusText = "Refunded"; break;
                                    default: statusClass = "status-pending"; statusText = "Unknown";
                                }
                            %>
                            <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                            <% if (hasRefundRequest && !"refundRequested".equals(status)) { %>
                                <span class="status-badge status-refundRequested" style="margin-left: 4px;">Refund Requested</span>
                            <% } %>
                        </td>
                        <td>
                            <%
                                String date = o.getOrderDate();
                                if (date != null && date.length() >= 10) {
                                    out.print(date.substring(0, 10));
                                } else {
                                    out.print("-");
                                }
                            %>
                        </td>
                        <td>
                            <% if (hasRefundRequest) { %>
                                <a href="admin?action=approveRefund&id=<%= o.getId() %>"
                                   class="btn-sm-custom btn-approve-refund"
                                   onclick="return confirm('Approve this refund?')">Approve Refund</a>
                                <a href="admin?action=rejectRefund&id=<%= o.getId() %>"
                                   class="btn-sm-custom btn-reject-refund"
                                   onclick="return confirm('Reject this refund?')">Reject</a>
                            <% } else if ("pending".equals(status)) { %>
                                <a href="admin?action=updateOrder&id=<%= o.getId() %>&status=confirmed" class="btn-sm-custom btn-confirm">Confirm</a>
                            <% } else if ("confirmed".equals(status)) { %>
                                <a href="admin?action=updateOrder&id=<%= o.getId() %>&status=shipped" class="btn-sm-custom btn-ship">Ship</a>
                            <% } else if ("shipped".equals(status)) { %>
                                <a href="admin?action=updateOrder&id=<%= o.getId() %>&status=delivered" class="btn-sm-custom btn-deliver">Deliver</a>
                            <% } else { %>
                                -
                            <% } %>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
                <div class="empty-text">
                    <div style="font-size: 3rem; margin-bottom: 1rem;">📋</div>
                    <h4 style="margin-bottom: 0.5rem;">No orders found</h4>
                    <p style="color: #aaa; font-size: 0.85rem;">Orders will appear here when customers make purchases</p>
                </div>
            <% } %>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
