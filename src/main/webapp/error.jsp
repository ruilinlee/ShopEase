<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - ShopEase</title>
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
        .error-card {
            background: #fff;
            border-radius: 8px;
            border: 1px solid #eee;
            padding: 2.5rem;
            text-align: center;
            max-width: 400px;
            width: 100%;
        }
        .error-icon {
            width: 80px;
            height: 80px;
            background: #ffebee;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2.5rem;
            color: #c62828;
        }
        .error-title { font-size: 1.5rem; font-weight: 600; margin-bottom: 0.5rem; color: #333; }
        .error-text { color: #666; font-size: 0.9rem; margin-bottom: 1.5rem; }
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
    <div class="error-card">
        <div class="error-icon">!</div>
        <h1 class="error-title">Something went wrong</h1>
        <p class="error-text">The page you're looking for might not exist or an error occurred.</p>
        <div>
            <a href="index.jsp" class="btn-primary-custom">Go to Home</a>
            <a href="products" class="btn-outline-custom">Browse Products</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
