<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.Product" %>
<%
    // Prevent admin from accessing seller listings page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
%>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Listings - ShopEase</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <style>
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                            background: #f5f5f5;
                            color: #333;
                        }

                        .page-header {
                            background: #fff;
                            border-bottom: 1px solid #eee;
                            padding: 1.25rem 0;
                        }

                        .page-title {
                            font-size: 1.25rem;
                            font-weight: 600;
                            margin: 0;
                        }

                        .back-link {
                            display: inline-flex;
                            align-items: center;
                            gap: 0.4rem;
                            padding: 0.5rem 1rem;
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

                        .btn-primary-custom {
                            background: #333;
                            color: #fff;
                            border: none;
                            padding: 0.4rem 1rem;
                            border-radius: 4px;
                            text-decoration: none;
                            font-size: 0.85rem;
                        }

                        .btn-primary-custom:hover {
                            background: #555;
                            color: #fff;
                        }

                        .listing-card {
                            background: #fff;
                            border-radius: 8px;
                            border: 1px solid #eee;
                            padding: 1rem;
                            margin-bottom: 0.9rem;
                            display: flex;
                            gap: 1rem;
                            align-items: center;
                        }

                        .listing-img {
                            width: 90px;
                            height: 90px;
                            border-radius: 6px;
                            object-fit: cover;
                            background: #f5f5f5;
                            flex-shrink: 0;
                        }

                        .listing-title {
                            font-size: 1rem;
                            font-weight: 600;
                            margin-bottom: 0.25rem;
                        }

                        .listing-price {
                            font-weight: 600;
                            font-size: 1rem;
                            margin-top: 0.25rem;
                        }

                        .listing-meta {
                            font-size: 0.85rem;
                            color: #666;
                            display: flex;
                            gap: 0.75rem;
                            flex-wrap: wrap;
                        }

                        .status-badge {
                            display: inline-block;
                            padding: 0.2rem 0.5rem;
                            border-radius: 100px;
                            font-size: 0.7rem;
                            font-weight: 500;
                        }

                        .status-available {
                            background: #e8f5e9;
                            color: #2e7d32;
                        }

                        .status-approved {
                            background: #e3f2fd;
                            color: #1565c0;
                        }

                        .status-pending {
                            background: #fff3e0;
                            color: #e65100;
                        }

                        .status-sold {
                            background: #fce4ec;
                            color: #c62828;
                        }

                        .status-rejected {
                            background: #ffebee;
                            color: #c62828;
                        }

                        .listing-actions {
                            margin-left: auto;
                            display: flex;
                            gap: 0.5rem;
                            flex-wrap: wrap;
                        }

                        .btn-outline {
                            border: 1px solid #ddd;
                            color: #333;
                            background: #fff;
                            padding: 0.35rem 0.8rem;
                            border-radius: 4px;
                            font-size: 0.8rem;
                            text-decoration: none;
                        }

                        .btn-outline:hover {
                            background: #f5f5f5;
                            color: #333;
                        }

                        .btn-danger {
                            border: 1px solid #dc3545;
                            color: #dc3545;
                            background: #fff;
                            padding: 0.35rem 0.8rem;
                            border-radius: 4px;
                            font-size: 0.8rem;
                            text-decoration: none;
                        }

                        .btn-danger:hover {
                            background: #dc3545;
                            color: #fff;
                        }

                        .empty-state {
                            text-align: center;
                            padding: 4rem 2rem;
                            background: #fff;
                            border-radius: 8px;
                            border: 1px solid #eee;
                            color: #888;
                        }
                    </style>
                </head>

                <body>
                    <div class="page-header">
                        <div class="container">
                            <div class="d-flex justify-content-between align-items-center">
                                <h1 class="page-title">My Listings</h1>
                                <div class="d-flex align-items-center gap-3">
                                    <a href="products" class="back-link">← Back to Products</a>
                                    <a href="products?action=publish" class="btn-primary-custom">Add Listing</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <main class="container my-4">
                        <% if (products !=null && !products.isEmpty()) { %>
                            <% for (Product p : products) { %>
                                <% String cat=p.getCategory(); String catValue=cat !=null ? cat.toLowerCase() : "" ;
                                    String catName; switch (catValue) { case "electronics" : catName="Electronics" ;
                                    break; case "books" : catName="Books" ; break; case "clothing" : catName="Clothing"
                                    ; break; case "sports" : catName="Sports" ; break; case "furniture" :
                                    catName="Furniture" ; break; case "others" : case "other" : catName="Others" ;
                                    break; default: catName="Others" ; }

                                    // Sale status (available/sold)
                                    String saleStatus=p.getStatus();
                                    String saleStatusClass="status-available";
                                    String saleStatusText="Available";
                                    if ("sold".equals(saleStatus)) {
                                        saleStatusClass="status-sold";
                                        saleStatusText="Sold";
                                    }

                                    // Approval status (pending/approved/rejected)
                                    String approvalStatus=p.getApprovalStatus();
                                    String approvalClass="status-pending";
                                    String approvalText="Pending";
                                    if ("approved".equals(approvalStatus)) {
                                        approvalClass="status-approved";
                                        approvalText="Approved";
                                    } else if ("rejected".equals(approvalStatus)) {
                                        approvalClass="status-rejected";
                                        approvalText="Rejected";
                                    }
                                %>
                                    <div class="listing-card">
                                        <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" class="listing-img"
                                            onerror="this.src='https://via.placeholder.com/90?text=N/A'">
                                        <div>
                                            <div class="listing-title">
                                                <%= p.getName() %>
                                            </div>
                                            <div class="listing-meta">
                                                <span class="status-badge <%= approvalClass %>">
                                                    <%= approvalText %>
                                                </span>
                                                <span class="status-badge <%= saleStatusClass %>">
                                                    <%= saleStatusText %>
                                                </span>
                                                <span>Category: <%= catName %></span>
                                                <span>Stock: <%= p.getStock() %></span>
                                            </div>
                                            <div class="listing-price">$<%= String.format("%.2f", p.getPrice()) %>
                                            </div>
                                        </div>
                                        <div class="listing-actions">
                                            <a href="products?action=details&id=<%= p.getId() %>"
                                                class="btn-outline">View</a>
                                            <a href="products?action=publish&edit=<%= p.getId() %>"
                                                class="btn-outline">Edit</a>
                                            <a href="products?action=delete&id=<%= p.getId() %>" class="btn-danger"
                                                onclick="return confirm('Delete this listing?')">Delete</a>
                                        </div>
                                    </div>
                                    <% } %>
                                        <% } else { %>
                                            <div class="empty-state">
                                                <h5>No listings yet</h5>
                                                <p>Create your first listing to start selling.</p>
                                                <a href="products?action=publish" class="btn-primary-custom">Add
                                                    Listing</a>
                                            </div>
                                            <% } %>
                    </main>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>