<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shopease.entity.Product, java.util.List, com.shopease.entity.Review" %>
<%
    // Prevent admin from accessing product details page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("products");
        return;
    }
    boolean loggedIn = session.getAttribute("userId") != null;
    String currentUserId = (String) session.getAttribute("userId");
    boolean isOwner = currentUserId != null && currentUserId.equals(product.getSellerId());
    // Get reviews if available
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    Double avgRating = (Double) request.getAttribute("avgRating");
    Integer reviewCount = (Integer) request.getAttribute("reviewCount");
    Boolean hasUserReviewed = (Boolean) request.getAttribute("hasUserReviewed");
%>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <%= product.getName() %> - ShopEase
                    </title>
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
                            padding: 1rem 0;
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

                        .product-image {
                            width: 100%;
                            max-height: 400px;
                            object-fit: contain;
                            background: #fff;
                            border-radius: 8px;
                            padding: 1rem;
                            border: 1px solid #eee;
                        }

                        .product-card {
                            background: #fff;
                            border-radius: 8px;
                            padding: 1.5rem;
                            border: 1px solid #eee;
                        }

                        .product-name {
                            font-size: 1.5rem;
                            font-weight: 600;
                            margin-bottom: 0.5rem;
                        }

                        .product-price {
                            font-size: 1.75rem;
                            font-weight: 700;
                            color: #333;
                            margin-bottom: 1rem;
                        }

                        .info-row {
                            display: flex;
                            margin-bottom: 0.75rem;
                            font-size: 0.9rem;
                        }

                        .info-label {
                            color: #888;
                            width: 100px;
                            flex-shrink: 0;
                        }

                        .info-value {
                            color: #333;
                        }

                        .status-badge {
                            display: inline-block;
                            padding: 0.25rem 0.75rem;
                            border-radius: 100px;
                            font-size: 0.75rem;
                            font-weight: 500;
                        }

                        .status-available {
                            background: #e8f5e9;
                            color: #2e7d32;
                        }

                        .status-sold {
                            background: #fce4ec;
                            color: #c62828;
                        }

                        .status-pending {
                            background: #fff3e0;
                            color: #e65100;
                        }

                        .desc-section {
                            background: #fff;
                            border-radius: 8px;
                            padding: 1.25rem;
                            margin-top: 1rem;
                            border: 1px solid #eee;
                        }

                        .desc-title {
                            font-weight: 600;
                            font-size: 1rem;
                            margin-bottom: 0.75rem;
                            padding-bottom: 0.5rem;
                            border-bottom: 1px solid #eee;
                        }

                        .desc-content {
                            font-size: 0.9rem;
                            color: #666;
                            line-height: 1.7;
                            white-space: pre-wrap;
                        }

                        .action-area {
                            margin-top: 1.5rem;
                            padding-top: 1.5rem;
                            border-top: 1px solid #eee;
                        }

                        .btn-primary-custom {
                            background: #333;
                            color: #fff;
                            border: none;
                            padding: 0.75rem 2rem;
                            border-radius: 4px;
                            font-size: 0.9rem;
                        }

                        .btn-primary-custom:hover {
                            background: #555;
                            color: #fff;
                        }

                        .btn-outline-custom {
                            background: #fff;
                            color: #333;
                            border: 1px solid #ddd;
                            padding: 0.75rem 1.5rem;
                            border-radius: 4px;
                            font-size: 0.9rem;
                            text-decoration: none;
                        }

                        .btn-outline-custom:hover {
                            background: #f5f5f5;
                            color: #333;
                        }

                        .login-notice {
                            background: #fff3cd;
                            border: 1px solid #ffc107;
                            border-radius: 4px;
                            padding: 0.75rem 1rem;
                            font-size: 0.85rem;
                            color: #856404;
                        }

                        .login-notice a {
                            color: #664d03;
                        }

                        /* Reviews Section */
                        .reviews-section {
                            background: #fff;
                            border-radius: 8px;
                            padding: 1.25rem;
                            border: 1px solid #eee;
                            margin-top: 1.5rem;
                        }

                        .reviews-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 1rem;
                            padding-bottom: 0.75rem;
                            border-bottom: 1px solid #eee;
                        }

                        .reviews-title {
                            font-weight: 600;
                            font-size: 1rem;
                            margin: 0;
                        }

                        .rating-display {
                            display: flex;
                            align-items: center;
                            gap: 0.5rem;
                        }

                        .stars {
                            color: #ffc107;
                            font-size: 1.1rem;
                        }

                        .rating-number {
                            font-weight: 600;
                            font-size: 0.95rem;
                        }

                        .review-count {
                            font-size: 0.85rem;
                            color: #888;
                        }

                        .review-form {
                            margin-bottom: 1.5rem;
                            padding-bottom: 1rem;
                            border-bottom: 1px solid #eee;
                        }

                        .star-rating input {
                            display: none;
                        }

                        .star-rating label {
                            font-size: 1.5rem;
                            color: #ddd;
                            cursor: pointer;
                            transition: color 0.2s;
                        }

                        .star-rating label:hover,
                        .star-rating label:hover~label,
                        .star-rating input:checked~label {
                            color: #ffc107;
                        }

                        .star-rating {
                            display: flex;
                            flex-direction: row-reverse;
                            justify-content: flex-end;
                        }

                        .review-item {
                            padding: 1rem 0;
                            border-bottom: 1px solid #f0f0f0;
                        }

                        .review-item:last-child {
                            border-bottom: none;
                        }

                        .review-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 0.5rem;
                        }

                        .reviewer-name {
                            font-weight: 500;
                            font-size: 0.9rem;
                        }

                        .review-date {
                            font-size: 0.8rem;
                            color: #888;
                        }

                        .review-stars {
                            color: #ffc107;
                            font-size: 0.9rem;
                            margin-bottom: 0.5rem;
                        }

                        .review-comment {
                            font-size: 0.9rem;
                            color: #666;
                            line-height: 1.6;
                        }

                        .delete-review {
                            color: #dc3545;
                            font-size: 0.8rem;
                            text-decoration: none;
                        }

                        .delete-review:hover {
                            text-decoration: underline;
                        }

                        .shipping-info {
                            background: #f8f9fa;
                            border-radius: 4px;
                            padding: 0.75rem 1rem;
                            font-size: 0.85rem;
                            margin-top: 0.75rem;
                            line-height: 1.5;
                        }

                        .shipping-info strong {
                            display: block;
                            margin-top: 0.25rem;
                            white-space: pre-wrap;
                            word-break: break-word;
                        }

                        .shipping-icon {
                            margin-right: 0.5rem;
                        }
                    </style>
                </head>

                <body>
                    <div class="page-header">
                        <div class="container">
                            <a href="products" class="back-link">← Back to Products</a>
                        </div>
                    </div>

                    <main class="container my-4">
                        <div class="row g-4">
                            <div class="col-lg-5">
                                <img src="<%= product.getImageUrl() %>" alt="<%= product.getName() %>"
                                    class="product-image"
                                    onerror="this.src='https://via.placeholder.com/400x300?text=No+Image'">
                            </div>

                            <div class="col-lg-7">
                                <div class="product-card">
                                    <h1 class="product-name">
                                        <%= product.getName() %>
                                    </h1>
                                    <div class="product-price">$<%= String.format("%.2f", product.getPrice()) %>
                                    </div>

                                    <div class="info-row">
                                        <span class="info-label">Status</span>
                                        <span class="info-value">
                                            <% String status=product.getStatus(); String statusClass="status-available"
                                                ; String statusText="Available" ; if ("sold".equals(status)) {
                                                statusClass="status-sold" ; statusText="Sold Out" ; } else if
                                                ("pending".equals(status)) { statusClass="status-pending" ;
                                                statusText="Pending" ; } %>
                                                <span class="status-badge <%= statusClass %>">
                                                    <%= statusText %>
                                                </span>
                                        </span>
                                    </div>

                                    <div class="info-row">
                                        <span class="info-label">Category</span>
                                        <span class="info-value">
                                            <%= product.getCategory() %>
                                        </span>
                                    </div>

                                    <div class="info-row">
                                        <span class="info-label">Stock</span>
                                        <span class="info-value">
                                            <%= product.getStock() %> available
                                        </span>
                                    </div>

                                    <div class="info-row">
                                        <span class="info-label">Seller</span>
                                        <span class="info-value">
                                            <%= product.getSellerName() %>
                                        </span>
                                    </div>

                                    <% if (product.getShippingLocation() !=null) { %>
                                        <div class="shipping-info">
                                            <span class="shipping-icon">📦</span>
                                            Ships from: <strong>
                                                <%= product.getShippingLocation() %>
                                            </strong>
                                        </div>
                                        <% } %>

                                            <div class="action-area">
                                                <% if (!loggedIn) { %>
                                                    <div class="login-notice">
                                                        <a href="login.jsp">Log in</a> to add this item to your cart
                                                    </div>
                                                    <% } else if (isOwner) { %>
                                                        <a href="products?action=publish&edit=<%= product.getId() %>"
                                                            class="btn-outline-custom">Edit Listing</a>
                                                        <% } else if (product.isAvailable() && product.getStock()> 0) {
                                                            %>
                                                            <form action="cart" method="post" style="display:inline;">
                                                                <input type="hidden" name="action" value="add">
                                                                <input type="hidden" name="productId"
                                                                    value="<%= product.getId() %>">
                                                                <button type="submit" class="btn-primary-custom">Add to
                                                                    Cart</button>
                                                            </form>
                                                            <% } else { %>
                                                                <button class="btn-primary-custom" disabled>Not
                                                                    Available</button>
                                                                <% } %>
                                            </div>
                                </div>

                                <% if (product.getDescription() !=null && !product.getDescription().isEmpty()) { %>
                                    <div class="desc-section">
                                        <h5 class="desc-title">Description</h5>
                                        <div class="desc-content">
                                            <%= product.getDescription() %>
                                        </div>
                                    </div>
                                    <% } %>
                            </div>
                        </div>

                        <!-- Reviews Section -->
                        <div class="reviews-section">
                            <div class="reviews-header">
                                <h5 class="reviews-title">Customer Reviews</h5>
                                <div class="rating-display">
                                    <span class="stars">
                                        <% double rating=avgRating !=null ? avgRating : 0; for (int i=1; i <=5; i++) {
                                            if (i <=rating) out.print("★"); else if (i - 0.5 <=rating) out.print("★");
                                            else out.print("☆"); } %>
                                    </span>
                                    <span class="rating-number">
                                        <%= String.format("%.1f", rating) %>
                                    </span>
                                    <span class="review-count">(<%= reviewCount !=null ? reviewCount : 0 %>
                                            reviews)</span>
                                </div>
                            </div>

                            <% if (loggedIn && !isOwner && (hasUserReviewed==null || !hasUserReviewed)) { %>
                                <form action="reviews" method="post" class="review-form">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="productId" value="<%= product.getId() %>">
                                    <div class="mb-3">
                                        <label class="form-label">Your Rating</label>
                                        <div class="star-rating">
                                            <input type="radio" name="rating" id="star5" value="5"><label
                                                for="star5">★</label>
                                            <input type="radio" name="rating" id="star4" value="4"><label
                                                for="star4">★</label>
                                            <input type="radio" name="rating" id="star3" value="3" checked><label
                                                for="star3">★</label>
                                            <input type="radio" name="rating" id="star2" value="2"><label
                                                for="star2">★</label>
                                            <input type="radio" name="rating" id="star1" value="1"><label
                                                for="star1">★</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <textarea name="comment" class="form-control" rows="3"
                                            placeholder="Share your thoughts about this product..." required
                                            maxlength="500"></textarea>
                                    </div>
                                    <button type="submit" class="btn-primary-custom"
                                        style="padding: 0.5rem 1.5rem;">Submit Review</button>
                                </form>
                                <% } else if (loggedIn && hasUserReviewed !=null && hasUserReviewed) { %>
                                    <p class="text-muted mb-3" style="font-size: 0.9rem;">You have already reviewed this
                                        product.</p>
                                    <% } else if (!loggedIn) { %>
                                        <p class="text-muted mb-3" style="font-size: 0.9rem;"><a href="login.jsp">Log
                                                in</a> to leave a review.</p>
                                        <% } %>

                                            <div id="reviewsList">
                                                <% if (reviews !=null && !reviews.isEmpty()) { for (Review review :
                                                    reviews) { %>
                                                    <div class="review-item">
                                                        <div class="review-header">
                                                            <span class="reviewer-name">
                                                                <%= review.getUsername() %>
                                                            </span>
                                                            <div>
                                                                <% if ((currentUserId !=null &&
                                                                    currentUserId.equals(review.getUserId())) || "admin"
                                                                    .equals(userRole)) { %>
                                                                    <a href="reviews?action=delete&id=<%= review.getId() %>&productId=<%= product.getId() %>"
                                                                        class="delete-review"
                                                                        onclick="return confirm('Delete this review?')">Delete</a>
                                                                    <% } %>
                                                            </div>
                                                        </div>
                                                        <div class="review-stars">
                                                            <% for (int i=1; i <=5; i++) { out.print(i
                                                                <=review.getRating() ? "★" : "☆" ); } %>
                                                        </div>
                                                        <div class="review-comment">
                                                            <%= review.getComment() %>
                                                        </div>
                                                    </div>
                                                    <% } } else { %>
                                                        <p class="text-muted text-center py-3">No reviews yet. Be the
                                                            first to review!</p>
                                                        <% } %>
                                            </div>
                        </div>
                    </main>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>