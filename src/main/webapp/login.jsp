<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <% String currentRole=(String) session.getAttribute("role"); if (currentRole !=null) { if
        ("admin".equals(currentRole)) { response.sendRedirect("admin.jsp"); } else { response.sendRedirect("products");
        } return; } String errorParam=request.getParameter("error"); String errorMsg=(String)
        request.getAttribute("error"); if (errorMsg==null && "unauthorized" .equals(errorParam)) {
        errorMsg="Access denied. Please login with appropriate credentials." ; } String selectedRole="customer" ; String
        roleParam=request.getParameter("loginRole"); if (roleParam==null || roleParam.trim().isEmpty()) {
        roleParam=request.getParameter("role"); } if ("admin".equalsIgnoreCase(roleParam)) { selectedRole="admin" ; } %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Login - ShopEase</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: #f5f5f5;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 2rem;
                }

                .login-card {
                    background: #fff;
                    border-radius: 8px;
                    border: 1px solid #eee;
                    max-width: 400px;
                    width: 100%;
                }

                .card-header {
                    padding: 1.5rem;
                    border-bottom: 1px solid #eee;
                    text-align: center;
                }

                .card-header h4 {
                    margin: 0;
                    font-size: 1.25rem;
                    font-weight: 600;
                    color: #333;
                }

                .card-header small {
                    color: #888;
                    font-size: 0.85rem;
                }

                .card-body {
                    padding: 1.5rem;
                }

                .form-label {
                    font-size: 0.9rem;
                    color: #555;
                    margin-bottom: 0.5rem;
                }

                .form-control {
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    padding: 0.7rem 0.9rem;
                    font-size: 0.9rem;
                }

                .form-control:focus {
                    border-color: #999;
                    box-shadow: none;
                }

                .btn-login {
                    background: #333;
                    border: none;
                    color: #fff;
                    padding: 0.7rem;
                    border-radius: 4px;
                    font-size: 0.9rem;
                    width: 100%;
                }

                .btn-login:hover {
                    background: #555;
                    color: #fff;
                }

                .card-footer {
                    padding: 1rem 1.5rem;
                    background: #fafafa;
                    border-top: 1px solid #eee;
                    text-align: center;
                    font-size: 0.85rem;
                    color: #666;
                }

                .card-footer a {
                    color: #333;
                    text-decoration: none;
                }

                .card-footer a:hover {
                    text-decoration: underline;
                }

                .alert {
                    font-size: 0.85rem;
                    padding: 0.75rem;
                    margin-bottom: 1rem;
                }

                .back-link {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    gap: 0.5rem;
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
                    width: 100%;
                }

                .back-link:hover {
                    background: #dbeafe;
                    border-color: #93c5fd;
                    color: #1d4ed8;
                    transform: translateY(-1px);
                    box-shadow: 0 2px 8px rgba(37, 99, 235, 0.15);
                }

                .role-selector {
                    display: flex;
                    gap: 1rem;
                    margin-bottom: 1rem;
                    padding: 0.75rem;
                    background: #f8f9fa;
                    border-radius: 6px;
                    border: 1px solid #eee;
                }

                .role-option {
                    flex: 1;
                    text-align: center;
                    position: relative;
                }

                .role-option input[type="radio"] {
                    position: absolute;
                    opacity: 0;
                    pointer-events: none;
                }

                .role-option label {
                    display: block;
                    padding: 0.6rem 1rem;
                    border-radius: 4px;
                    cursor: pointer;
                    font-size: 0.9rem;
                    font-weight: 500;
                    color: #666;
                    border: 2px solid transparent;
                    transition: all 0.2s;
                }

                .role-option input[type="radio"]:checked+label {
                    background: #333;
                    color: #fff;
                    border-color: #333;
                }

                .role-option label:hover {
                    background: #eee;
                }

                .role-option input[type="radio"]:checked+label:hover {
                    background: #444;
                }
            </style>
        </head>

        <body>
            <div class="login-card">
                <div class="card-header">
                    <h4>Welcome to ShopEase</h4>
                    <small>Sign in to your account</small>
                </div>
                <div class="card-body">
                    <% if (errorMsg !=null) { %>
                        <div class="alert alert-danger">
                            <%= errorMsg %>
                        </div>
                        <% } %>

                            <form action="user" method="post">
                                <input type="hidden" name="action" value="login">

                                <!-- Role Selector -->
                                <div class="mb-3">
                                    <label class="form-label">Login as</label>
                                    <div class="role-selector">
                                        <div class="role-option">
                                            <input type="radio" id="roleCustomer" name="loginRole" value="customer"
                                                <%="customer" .equals(selectedRole) ? "checked" : "" %>>
                                            <label for="roleCustomer">Customer</label>
                                        </div>
                                        <div class="role-option">
                                            <input type="radio" id="roleAdmin" name="loginRole" value="admin" <%="admin"
                                                .equals(selectedRole) ? "checked" : "" %>>
                                            <label for="roleAdmin">Admin</label>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Username</label>
                                    <input type="text" class="form-control" name="username" placeholder="Enter username"
                                        required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Password</label>
                                    <input type="password" class="form-control" name="password"
                                        placeholder="Enter password" required>
                                </div>

                                <button type="submit" class="btn-login">Log In</button>
                            </form>

                            <a href="products" class="back-link">← Browse as guest</a>
                </div>
                <div class="card-footer">
                    Don't have an account? <a href="register.jsp">Register as Customer</a>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>