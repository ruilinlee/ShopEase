<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.Product" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // Prevent admin from accessing customer shop page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Products - ShopEase</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        background: #f5f5f5;
                        color: #333;
                    }

                    .navbar {
                        background: #fff;
                        border-bottom: 1px solid #eee;
                        padding: 0.8rem 0;
                    }

                    .navbar-brand {
                        font-weight: 600;
                        color: #333 !important;
                    }

                    .nav-link {
                        color: #666 !important;
                        font-size: 0.9rem;
                    }

                    .nav-link:hover {
                        color: #333 !important;
                    }

                    .btn-nav {
                        background: #333;
                        color: #fff !important;
                        padding: 0.4rem 1rem;
                        border-radius: 4px;
                        font-size: 0.85rem;
                    }

                    .btn-nav:hover {
                        background: #555;
                    }

                    .btn-outline-nav {
                        border: 1px solid #ddd;
                        color: #666 !important;
                        padding: 0.4rem 1rem;
                        border-radius: 4px;
                        font-size: 0.85rem;
                    }

                    .btn-outline-nav:hover {
                        background: #f5f5f5;
                    }

                    .page-header {
                        background: #fff;
                        padding: 1.5rem 0;
                        border-bottom: 1px solid #eee;
                        margin-bottom: 1.5rem;
                    }

                    .page-title {
                        font-size: 1.25rem;
                        font-weight: 600;
                        margin: 0;
                    }

                    .search-box {
                        display: flex;
                        gap: 0.5rem;
                    }

                    .search-input {
                        border: 1px solid #ddd;
                        border-radius: 4px;
                        padding: 0.5rem 0.75rem;
                        font-size: 0.9rem;
                        width: 200px;
                    }

                    .search-input:focus {
                        outline: none;
                        border-color: #999;
                    }

                    .btn-search {
                        background: #333;
                        color: #fff;
                        border: none;
                        padding: 0.5rem 1rem;
                        border-radius: 4px;
                        font-size: 0.9rem;
                    }

                    .filter-tabs {
                        display: flex;
                        gap: 0.5rem;
                        flex-wrap: wrap;
                    }

                    .filter-tab {
                        padding: 0.4rem 0.8rem;
                        border: 1px solid #ddd;
                        border-radius: 4px;
                        font-size: 0.85rem;
                        color: #666;
                        text-decoration: none;
                        background: #fff;
                    }

                    .filter-tab:hover {
                        background: #f5f5f5;
                        color: #333;
                    }

                    .filter-tab.active {
                        background: #333;
                        color: #fff;
                        border-color: #333;
                    }

                    .product-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                        gap: 1.25rem;
                    }

                    .product-card {
                        background: #fff;
                        border-radius: 8px;
                        overflow: hidden;
                        border: 1px solid #eee;
                    }

                    .product-img {
                        width: 100%;
                        height: 160px;
                        object-fit: cover;
                        background: #f5f5f5;
                    }

                    .product-body {
                        padding: 1rem;
                    }

                    .product-category {
                        font-size: 0.75rem;
                        color: #888;
                        margin-bottom: 0.25rem;
                    }

                    .product-name {
                        font-size: 0.95rem;
                        font-weight: 500;
                        color: #333;
                        margin-bottom: 0.25rem;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }

                    .product-desc {
                        font-size: 0.8rem;
                        color: #888;
                        margin-bottom: 0.5rem;
                        display: -webkit-box;
                        -webkit-line-clamp: 2;
                        -webkit-box-orient: vertical;
                        overflow: hidden;
                    }

                    .product-price {
                        font-size: 1.1rem;
                        font-weight: 600;
                        color: #333;
                    }

                    .product-seller {
                        font-size: 0.8rem;
                        color: #999;
                        margin-top: 0.5rem;
                    }

                    .product-actions {
                        display: flex;
                        gap: 0.5rem;
                        margin-top: 0.75rem;
                    }

                    .btn-view {
                        flex: 1;
                        padding: 0.5rem;
                        font-size: 0.8rem;
                        text-align: center;
                        border: 1px solid #ddd;
                        border-radius: 4px;
                        color: #666;
                        text-decoration: none;
                    }

                    .btn-view:hover {
                        background: #f5f5f5;
                        color: #333;
                    }

                    .btn-cart {
                        flex: 1;
                        padding: 0.5rem;
                        font-size: 0.8rem;
                        text-align: center;
                        background: #333;
                        border-radius: 4px;
                        color: #fff;
                        text-decoration: none;
                        border: none;
                    }

                    .btn-cart:hover {
                        background: #555;
                        color: #fff;
                    }

                    .empty-state {
                        text-align: center;
                        padding: 4rem 2rem;
                        color: #888;
                    }

                    .guest-banner {
                        background: #fffbeb;
                        border: 1px solid #fde68a;
                        color: #92400e;
                        padding: 0.75rem 1rem;
                        border-radius: 4px;
                        margin-bottom: 1rem;
                        font-size: 0.85rem;
                    }

                    .guest-banner a {
                        color: #92400e;
                        font-weight: 500;
                    }

                    .cart-badge {
                        background: #dc3545;
                        color: #fff;
                        font-size: 0.7rem;
                        padding: 0.15rem 0.4rem;
                        border-radius: 10px;
                        margin-left: 0.25rem;
                    }

                    footer {
                        background: #fff;
                        border-top: 1px solid #eee;
                        padding: 1.5rem 0;
                        margin-top: 3rem;
                        text-align: center;
                        color: #888;
                        font-size: 0.85rem;
                    }
                </style>
            </head>

            <body>
                <nav class="navbar sticky-top">
                    <div class="container">
                        <a class="navbar-brand" href="index.jsp">ShopEase</a>
                        <div class="d-flex align-items-center gap-3">
                            <a href="index.jsp" class="nav-link">Home</a>
                            <% if (session.getAttribute("userId") !=null) { %>
                                <a href="cart" class="nav-link">
                                    Cart
                                    <% Object cartCount=session.getAttribute("cartCount"); %>
                                        <% if (cartCount !=null && !cartCount.equals(0)) { %>
                                            <span class="cart-badge">
                                                <%= cartCount %>
                                            </span>
                                            <% } %>
                                </a>
                                <a href="orders" class="nav-link">My Orders</a>
                                <a href="products?action=myListings" class="nav-link">My Listings</a>
                                <a href="products?action=mySales" class="nav-link">My Sales</a>
                                <a href="publish.jsp" class="btn-nav">Sell Item</a>
                                <div class="dropdown">
                                    <a class="btn-outline-nav dropdown-toggle" href="#" role="button"
                                        data-bs-toggle="dropdown">
                                        <c:out value="${sessionScope.username}" />
                                    </a>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li><a class="dropdown-item" href="user?action=profile">My Profile</a></li>
                                        <li>
                                            <hr class="dropdown-divider">
                                        </li>
                                        <li><a class="dropdown-item" href="user?action=logout">Logout</a></li>
                                    </ul>
                                </div>
                                <% } else { %>
                                    <a href="login.jsp" class="btn-nav">Log In</a>
                                    <a href="register.jsp" class="btn-outline-nav">Register</a>
                                    <% } %>
                        </div>
                    </div>
                </nav>

                <div class="page-header">
                    <div class="container">
                        <div class="row align-items-center">
                            <div class="col-md-3">
                                <h1 class="page-title">Products</h1>
                            </div>
                            <div class="col-md-5">
                                <form action="products" method="get" class="search-box">
                                    <input type="text" name="search" class="search-input" placeholder="Search products..." value="<c:out value='${searchQuery}' default='' />">
                                    <button type="submit" class="btn-search">Search</button>
                                </form>
                            </div>
                            <div class="col-md-4 text-end">
                                <div class="filter-tabs">
                                    <a href="products" class="filter-tab <%= request.getAttribute("selectedCategory")==null ? "active" : "" %>">All</a>
                                    <%
                                        String[] categories = {"electronics", "books", "clothing", "sports", "furniture", "others"};
                                        String[] categoryNames = {"Electronics", "Books", "Clothing", "Sports", "Furniture", "Others"};
                                        String selected = (String) request.getAttribute("selectedCategory");
                                        if (selected != null) {
                                            selected = selected.toLowerCase();
                                        }
                                        for (int i = 0; i < categories.length; i++) {
                                    %>
                                    <a href="products?category=<%= categories[i] %>" class="filter-tab <%= categories[i].equals(selected) ? "active" : "" %>"><%= categoryNames[i] %></a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <main class="container">
                    <% if (session.getAttribute("userId")==null) { %>
                        <div class="guest-banner">
                            You are browsing as a guest. <a href="login.jsp">Log in</a> to add items to cart or make
                            purchases.
                        </div>
                        <% } %>

                    <%
                        List<Product> products = (List<Product>) request.getAttribute("products");
                        if (products != null && !products.isEmpty()) {
                    %>
                    <div class="product-grid">
                        <%
                            for (Product p : products) {
                                String pStatus = p.getStatus();
                                if (!"available".equals(pStatus) && !"approved".equals(pStatus)) continue;
                        %>
                        <div class="product-card">
                            <%
                                pageContext.setAttribute("pImageUrl", p.getImageUrl());
                                pageContext.setAttribute("pName", p.getName());
                                pageContext.setAttribute("pDesc", p.getDescription() != null ? p.getDescription() : "");
                                pageContext.setAttribute("pSellerName", p.getSellerName() != null ? p.getSellerName() : "Unknown");
                                pageContext.setAttribute("pPrice", String.format("%.2f", p.getPrice()));
                                pageContext.setAttribute("pId", p.getId());
                            %>
                            <img src="${fn:escapeXml(pImageUrl)}" alt="${fn:escapeXml(pName)}" class="product-img" onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                            <div class="product-body">
                                <div class="product-category">
                                    <%
                                        String cat = p.getCategory();
                                        String catValue = cat != null ? cat.toLowerCase() : "";
                                        String catName;
                                        switch(catValue) {
                                            case "electronics": catName = "Electronics"; break;
                                            case "books": catName = "Books"; break;
                                            case "clothing": catName = "Clothing"; break;
                                            case "sports": catName = "Sports"; break;
                                            case "furniture": catName = "Furniture"; break;
                                            case "others": catName = "Others"; break;
                                            case "other": catName = "Others"; break;
                                            default: catName = "Others";
                                        }
                                    %>
                                    <%= catName %>
                                                    </div>
                                                    <div class="product-name">
                                                        ${fn:escapeXml(pName)}
                                                    </div>
                                                    <div class="product-desc">
                                                        ${fn:escapeXml(pDesc)}
                                                    </div>
                                                    <div class="product-price">$${pPrice}</div>
                                                    <div class="product-seller">Seller: ${fn:escapeXml(pSellerName)}</div>
                                                    <div class="product-actions">
                                                        <a href="products?action=details&id=${pId}" class="btn-view">View</a>
                                                        <% if (session.getAttribute("userId") !=null) { %>
                                                            <form action="cart" method="post" style="flex:1;margin:0;">
                                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                <input type="hidden" name="action" value="add">
                                                                <input type="hidden" name="productId" value="${pId}">
                                                                <input type="hidden" name="quantity" value="1">
                                                                <button type="submit" class="btn-cart" style="width:100%;">Add to Cart</button>
                                                            </form>
                                                        <% } else { %>
                                                            <a href="login.jsp" class="btn-cart">Add to Cart</a>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </div>
                                            <% } %>
                                    </div>
                                    <% } else { %>
                                        <div class="empty-state">
                                            <h4>No products found</h4>
                                            <p>Try adjusting your search or browse a different category.</p>
                                        </div>
                                        <% } %>
                </main>

                <footer>
                    <div class="container">
                        <p>&copy; 2024 ShopEase. Campus Second-hand Trading Platform.</p>
                    </div>
                </footer>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>