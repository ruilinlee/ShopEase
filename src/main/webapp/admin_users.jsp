<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.shopease.entity.User" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (!"admin".equals(userRole)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - ShopEase</title>
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
        
        .role-badge {
            display: inline-block;
            padding: 0.2rem 0.5rem;
            border-radius: 100px;
            font-size: 0.7rem;
        }
        .role-admin { background: #e3f2fd; color: #1565c0; }
        .role-user { background: #f5f5f5; color: #666; }
        
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
            <li class="nav-item"><a class="nav-link" href="admin?action=pending">Pending Approval</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=products">All Products</a></li>
            <li class="nav-item"><a class="nav-link active" href="admin?action=users">Users</a></li>
            <li class="nav-item"><a class="nav-link" href="admin?action=orders">Orders</a></li>
            <li class="nav-item"><a class="nav-link logout-link" href="user?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="main-content">
        <div class="page-header">
            <h1 class="page-title">User Management</h1>
        </div>

        <div class="table-card">
            <% if (users != null && !users.isEmpty()) { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Role</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (User u : users) { %>
                    <tr>
                        <td><%= u.getId() %></td>
                        <td><%= u.getUsername() %></td>
                        <td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                        <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                        <td>
                            <span class="role-badge <%= "admin".equals(u.getRole()) ? "role-admin" : "role-user" %>">
                                <%= "admin".equals(u.getRole()) ? "Admin" : "User" %>
                            </span>
                        </td>
                        <td>
                            <% if (!"admin".equals(u.getRole())) { %>
                                <a href="admin?action=deleteUser&id=<%= u.getId() %>" class="btn-sm-custom btn-delete"
                                   onclick="return confirm('Delete this user?')">Delete</a>
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
                    <div style="font-size: 3rem; margin-bottom: 1rem;">👥</div>
                    <h4 style="margin-bottom: 0.5rem;">No users found</h4>
                </div>
            <% } %>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
