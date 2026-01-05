<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // If already logged in as admin, redirect to admin dashboard
    String currentRole = (String) session.getAttribute("role");
    if ("admin".equals(currentRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    // If logged in as customer, redirect them away
    if (currentRole != null) {
        response.sendRedirect("products");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Admin Login - ShopEase</title>
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

                .login-card {
                    background: #fff;
                    border-radius: 8px;
                    border: 1px solid #eee;
                    max-width: 380px;
                    width: 100%;
                }

                .login-header {
                    background: #333;
                    color: #fff;
                    padding: 1.5rem;
                    text-align: center;
                    border-radius: 8px 8px 0 0;
                }

                .login-header h2 {
                    font-size: 1.25rem;
                    font-weight: 600;
                    margin: 0;
                }

                .login-header p {
                    font-size: 0.85rem;
                    color: #ccc;
                    margin: 0.5rem 0 0;
                }

                .login-body {
                    padding: 1.5rem;
                }

                .form-label {
                    font-size: 0.9rem;
                    font-weight: 500;
                    margin-bottom: 0.4rem;
                }

                .form-control {
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    padding: 0.6rem 0.75rem;
                    font-size: 0.9rem;
                }

                .form-control:focus {
                    border-color: #999;
                    box-shadow: none;
                }

                .btn-admin {
                    background: #333;
                    color: #fff;
                    border: none;
                    border-radius: 4px;
                    padding: 0.7rem;
                    width: 100%;
                    font-size: 0.9rem;
                }

                .btn-admin:hover {
                    background: #555;
                    color: #fff;
                }

                .alert {
                    font-size: 0.85rem;
                    padding: 0.75rem 1rem;
                    border-radius: 4px;
                }

                .back-link {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    gap: 0.5rem;
                    width: 100%;
                    margin-top: 1.25rem;
                    padding: 0.65rem 1.25rem;
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
            </style>
        </head>

        <body>
            <div class="login-card">
                <div class="login-header">
                    <h2>Admin Portal</h2>
                    <p>Authorized access only</p>
                </div>
                <div class="login-body">
                    <% String error=(String) request.getAttribute("error"); %>
                        <% if (error !=null) { %>
                            <div class="alert alert-danger">
                                <%= error %>
                            </div>
                            <% } %>

                                <form action="user" method="post">
                                    <input type="hidden" name="action" value="adminLogin">
                                    <div class="mb-3">
                                        <label class="form-label">Admin Username</label>
                                        <input type="text" class="form-control" name="username"
                                            placeholder="Enter username" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Password</label>
                                        <input type="password" class="form-control" name="password"
                                            placeholder="Enter password" required>
                                    </div>
                                    <button type="submit" class="btn-admin">Log In</button>
                                </form>
                                <a href="index.jsp" class="back-link">← Back to Home</a>
                </div>
            </div>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>