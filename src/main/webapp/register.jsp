<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // If already logged in, redirect based on role
    String currentRole = (String) session.getAttribute("role");
    if ("admin".equals(currentRole)) {
        response.sendRedirect("admin.jsp");
        return;
    } else if (currentRole != null) {
        response.sendRedirect("products");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - ShopEase</title>
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
        .register-card {
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
        .card-header small { color: #888; font-size: 0.85rem; }
        .card-body { padding: 1.5rem; }
        .form-label {
            font-size: 0.9rem;
            color: #555;
            margin-bottom: 0.5rem;
        }
        .required::after { content: "*"; color: #dc3545; margin-left: 2px; }
        .form-control {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 0.7rem 0.9rem;
            font-size: 0.9rem;
        }
        .form-control:focus { border-color: #999; box-shadow: none; }
        .form-text { font-size: 0.8rem; color: #888; }
        .btn-register {
            background: #333;
            border: none;
            color: #fff;
            padding: 0.7rem;
            border-radius: 4px;
            font-size: 0.9rem;
            width: 100%;
        }
        .btn-register:hover { background: #555; color: #fff; }
        .card-footer {
            padding: 1rem 1.5rem;
            background: #fafafa;
            border-top: 1px solid #eee;
            text-align: center;
            font-size: 0.85rem;
            color: #666;
        }
        .card-footer a { color: #333; text-decoration: none; }
        .card-footer a:hover { text-decoration: underline; }
        .alert { font-size: 0.85rem; padding: 0.75rem; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <div class="register-card">
        <div class="card-header">
            <h4>Create Account</h4>
            <small>Join ShopEase today</small>
        </div>
        <div class="card-body">
            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger"><%= error %></div>
            <% } %>
            
            <form action="user" method="post" id="registerForm">
                <input type="hidden" name="action" value="register">
                
                <div class="mb-3">
                    <label class="form-label required">Username</label>
                    <input type="text" class="form-control" name="username" placeholder="Choose a username" 
                           required minlength="3" maxlength="20">
                    <div class="form-text">3-20 characters</div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label required">Email</label>
                    <input type="email" class="form-control" name="email" placeholder="Enter your email" required>
                </div>
                
                <div class="mb-3">
                    <label class="form-label required">Password</label>
                    <input type="password" class="form-control" name="password" id="password"
                           placeholder="Create a password" required minlength="6">
                    <div class="form-text">At least 6 characters</div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label required">Confirm Password</label>
                    <input type="password" class="form-control" name="confirmPassword" id="confirmPassword"
                           placeholder="Re-enter password" required>
                </div>
                
                <button type="submit" class="btn-register">Register</button>
            </form>
        </div>
        <div class="card-footer">
            Already have an account? <a href="login.jsp">Log In</a>
        </div>
    </div>
    
    <script>
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            var pwd = document.getElementById('password').value;
            var confirmPwd = document.getElementById('confirmPassword').value;
            if (pwd !== confirmPwd) {
                alert('Passwords do not match');
                e.preventDefault();
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
