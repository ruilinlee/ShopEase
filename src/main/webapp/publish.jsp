<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shopease.entity.Product" %>
<%
    // Prevent admin from accessing publish page - only customers can publish
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Product editProduct = (Product) request.getAttribute("editProduct");
    boolean isEdit = editProduct != null;
    String editCategory = "";
    if (isEdit && editProduct.getCategory() != null) {
        editCategory = editProduct.getCategory().toLowerCase();
        if ("other".equals(editCategory)) {
            editCategory = "others";
        }
    }
    String editState = isEdit && editProduct.getShippingState() != null ? editProduct.getShippingState() : "";
%>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <%= isEdit ? "Edit Product" : "Sell Item" %> - ShopEase
                </title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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

                    .form-card {
                        background: #fff;
                        border-radius: 8px;
                        padding: 1.5rem;
                        border: 1px solid #eee;
                    }

                    .form-section {
                        margin-bottom: 1.5rem;
                        padding-bottom: 1.5rem;
                        border-bottom: 1px solid #eee;
                    }

                    .form-section:last-child {
                        margin-bottom: 0;
                        padding-bottom: 0;
                        border-bottom: none;
                    }

                    .section-title {
                        font-size: 1rem;
                        font-weight: 600;
                        margin-bottom: 1rem;
                    }

                    .form-label {
                        font-size: 0.9rem;
                        font-weight: 500;
                        margin-bottom: 0.4rem;
                    }

                    .form-control,
                    .form-select {
                        border: 1px solid #ddd;
                        border-radius: 4px;
                        font-size: 0.9rem;
                        padding: 0.6rem 0.75rem;
                    }

                    .form-control:focus,
                    .form-select:focus {
                        border-color: #999;
                        box-shadow: none;
                    }

                    .form-text {
                        font-size: 0.8rem;
                        color: #888;
                    }

                    .required::after {
                        content: "*";
                        color: #dc3545;
                        margin-left: 2px;
                    }

                    .image-preview {
                        width: 100%;
                        max-width: 200px;
                        height: 150px;
                        border: 2px dashed #ddd;
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background: #fafafa;
                        overflow: hidden;
                        margin-bottom: 0.5rem;
                    }

                    .image-preview img {
                        max-width: 100%;
                        max-height: 100%;
                        object-fit: contain;
                    }

                    .image-preview-text {
                        color: #999;
                        font-size: 0.85rem;
                    }

                    .btn-submit {
                        background: #333;
                        color: #fff;
                        border: none;
                        padding: 0.75rem 2rem;
                        border-radius: 4px;
                        font-size: 0.9rem;
                    }

                    .btn-submit:hover {
                        background: #555;
                        color: #fff;
                    }

                    .btn-cancel {
                        background: #fff;
                        color: #333;
                        border: 1px solid #ddd;
                        padding: 0.75rem 1.5rem;
                        border-radius: 4px;
                        text-decoration: none;
                        font-size: 0.9rem;
                    }

                    .btn-cancel:hover {
                        background: #f5f5f5;
                        color: #333;
                    }

                    .error-msg {
                        background: #ffebee;
                        border: 1px solid #ef9a9a;
                        border-radius: 4px;
                        padding: 0.75rem 1rem;
                        font-size: 0.85rem;
                        color: #c62828;
                        margin-bottom: 1rem;
                    }

                    .success-msg {
                        background: #e8f5e9;
                        border: 1px solid #a5d6a7;
                        border-radius: 4px;
                        padding: 0.75rem 1rem;
                        font-size: 0.85rem;
                        color: #2e7d32;
                        margin-bottom: 1rem;
                    }
                </style>
            </head>

            <body>
                <div class="page-header">
                    <div class="container">
                        <div class="d-flex justify-content-between align-items-center">
                            <h1 class="page-title">
                                <%= isEdit ? "Edit Product" : "Sell an Item" %>
                            </h1>
                            <a href="products" class="back-link">← Back to Products</a>
                        </div>
                    </div>
                </div>

                <main class="container my-4" style="max-width: 700px;">
                    <% if (request.getAttribute("error") !=null) { %>
                        <div class="error-msg">
                            <%= request.getAttribute("error") %>
                        </div>
                        <% } %>
                            <% if (request.getAttribute("success") !=null) { %>
                                <div class="success-msg">
                                    <%= request.getAttribute("success") %>
                                </div>
                                <% } %>

                                    <form action="products?action=publish" method="post" enctype="multipart/form-data"
                                        class="form-card" id="publishForm">
                                        <input type="hidden" name="action" value="<%= isEdit ? " update" : "add" %>">
                                        <% if (isEdit) { %>
                                            <input type="hidden" name="productId" value="<%= editProduct.getId() %>">
                                            <% } %>

                                                <div class="form-section">
                                                    <h5 class="section-title">Basic Information</h5>
                                                    <div class="mb-3">
                                                        <label class="form-label required">Product Name</label>
                                                        <input type="text" name="name" class="form-control" required
                                                            maxlength="100" placeholder="Enter product name"
                                                            value="<%= isEdit ? editProduct.getName() : "" %>">
                                                        <div class="form-text">Max 100 characters</div>
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label required">Category</label>
                                                            <select name="category" class="form-select" required>
                                                                <option value="">Select category</option>
                                                                <option value="electronics" <%="electronics"
                                                                    .equals(editCategory) ? "selected" : "" %>
                                                                    >Electronics</option>
                                                                <option value="books" <%="books" .equals(editCategory)
                                                                    ? "selected" : "" %>>Books</option>
                                                                <option value="clothing" <%="clothing"
                                                                    .equals(editCategory) ? "selected" : "" %>>Clothing
                                                                </option>
                                                                <option value="sports" <%="sports" .equals(editCategory)
                                                                    ? "selected" : "" %>>Sports</option>
                                                                <option value="furniture" <%="furniture"
                                                                    .equals(editCategory) ? "selected" : "" %>>Furniture
                                                                </option>
                                                                <option value="others" <%="others" .equals(editCategory)
                                                                    ? "selected" : "" %>>Others</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label required">Status</label>
                                                            <select name="status" class="form-select" required>
                                                                <option value="available" <%=!isEdit || "available"
                                                                    .equals(editProduct.getStatus()) ? "selected" : ""
                                                                    %>>Available</option>
                                                                <option value="sold" <%=isEdit && "sold"
                                                                    .equals(editProduct.getStatus()) ? "selected" : ""
                                                                    %>>Sold</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="form-section">
                                                    <h5 class="section-title">Price & Stock</h5>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label required">Price ($)</label>
                                                            <input type="number" name="price" class="form-control"
                                                                required step="0.01" min="0.01" max="999999"
                                                                placeholder="0.00"
                                                                value="<%= isEdit ? editProduct.getPrice() : "" %>">
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label required">Stock</label>
                                                            <input type="number" name="stock" class="form-control"
                                                                required min="0" max="9999" placeholder="1"
                                                                value="<%= isEdit ? editProduct.getStock() : " 1" %>">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="form-section">
                                                    <h5 class="section-title">Product Image</h5>
                                                    <div class="image-preview" id="imagePreview">
                                                        <% if (isEdit && editProduct.getImageUrl() !=null &&
                                                            !editProduct.getImageUrl().isEmpty()) { %>
                                                            <img src="<%= editProduct.getImageUrl() %>" alt="Preview">
                                                            <% } else { %>
                                                                <span class="image-preview-text">Image Preview</span>
                                                                <% } %>
                                                    </div>
                                                    <input type="file" name="image" class="form-control"
                                                        accept="image/*" onchange="previewImage(this)" id="imageInput">
                                                    <div class="form-text">JPG, PNG format. Recommended size: 800x600px
                                                    </div>
                                                    <% if (isEdit && editProduct.getImageUrl() !=null) { %>
                                                        <input type="hidden" name="existingImage"
                                                            value="<%= editProduct.getImageUrl() %>">
                                                        <% } %>
                                                </div>

                                                <div class="form-section">
                                                    <h5 class="section-title">Description</h5>
                                                    <div class="mb-3">
                                                        <textarea name="description" class="form-control" rows="5"
                                                            maxlength="2000"
                                                            placeholder="Describe your item - condition, age, reason for selling, etc."><%= isEdit && editProduct.getDescription() != null ? editProduct.getDescription() : "" %></textarea>
                                                        <div class="form-text">Max 2000 characters</div>
                                                    </div>
                                                </div>

                                                <div class="form-section">
                                                    <h5 class="section-title">Shipping Location</h5>
                                                    <p class="form-text">Let buyers know where you are shipping from</p>
                                                    <div class="mb-3">
                                                        <label class="form-label">Detailed Address</label>
                                                        <textarea name="detailedAddress" class="form-control" rows="3"
                                                            maxlength="500"
                                                            placeholder="Enter full shipping address (e.g., No. 123, Jalan Merdeka, Taman Sentosa, 47300 Petaling Jaya)"><%= isEdit && editProduct.getDetailedAddress() != null ? editProduct.getDetailedAddress() : "" %></textarea>
                                                        <div class="form-text">Include street address, building number,
                                                            area, and postal code. Max 500 characters</div>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">State/Region</label>
                                                        <select name="shippingState" class="form-select">
                                                            <option value="">Select state</option>
                                                            <option value="Johor" <%="Johor" .equals(editState)
                                                                ? "selected" : "" %>>Johor</option>
                                                            <option value="Kedah" <%="Kedah" .equals(editState)
                                                                ? "selected" : "" %>>Kedah</option>
                                                            <option value="Kelantan" <%="Kelantan" .equals(editState)
                                                                ? "selected" : "" %>>Kelantan
                                                            </option>
                                                            <option value="Kuala Lumpur" <%="Kuala Lumpur"
                                                                .equals(editState) ? "selected" : "" %>>Kuala Lumpur
                                                            </option>
                                                            <option value="Labuan" <%="Labuan" .equals(editState)
                                                                ? "selected" : "" %>>Labuan</option>
                                                            <option value="Melaka" <%="Melaka" .equals(editState)
                                                                ? "selected" : "" %>>Melaka</option>
                                                            <option value="Negeri Sembilan" <%="Negeri Sembilan"
                                                                .equals(editState) ? "selected" : "" %>>Negeri
                                                                Sembilan</option>
                                                            <option value="Pahang" <%="Pahang" .equals(editState)
                                                                ? "selected" : "" %>>Pahang</option>
                                                            <option value="Penang" <%="Penang" .equals(editState)
                                                                ? "selected" : "" %>>Penang</option>
                                                            <option value="Perak" <%="Perak" .equals(editState)
                                                                ? "selected" : "" %>>Perak</option>
                                                            <option value="Perlis" <%="Perlis" .equals(editState)
                                                                ? "selected" : "" %>>Perlis</option>
                                                            <option value="Putrajaya" <%="Putrajaya" .equals(editState)
                                                                ? "selected" : "" %>>Putrajaya
                                                            </option>
                                                            <option value="Sabah" <%="Sabah" .equals(editState)
                                                                ? "selected" : "" %>>Sabah</option>
                                                            <option value="Sarawak" <%="Sarawak" .equals(editState)
                                                                ? "selected" : "" %>>Sarawak</option>
                                                            <option value="Selangor" <%="Selangor" .equals(editState)
                                                                ? "selected" : "" %>>Selangor
                                                            </option>
                                                            <option value="Terengganu" <%="Terengganu"
                                                                .equals(editState) ? "selected" : "" %>>Terengganu
                                                            </option>
                                                        </select>
                                                    </div>
                                                </div>

                                                <div class="d-flex gap-3">
                                                    <button type="submit" class="btn-submit">
                                                        <%= isEdit ? "Save Changes" : "List Item" %>
                                                    </button>
                                                    <a href="products" class="btn-cancel">Cancel</a>
                                                </div>
                                    </form>
                </main>

                <script>
                    function previewImage(input) {
                        var preview = document.getElementById('imagePreview');
                        if (input.files && input.files[0]) {
                            var reader = new FileReader();
                            reader.onload = function (e) {
                                preview.innerHTML = '<img src="' + e.target.result + '" alt="Preview">';
                            };
                            reader.readAsDataURL(input.files[0]);
                        }
                    }

                    document.getElementById('publishForm').addEventListener('submit', function (e) {
                        var name = this.querySelector('[name="name"]').value.trim();
                        var price = parseFloat(this.querySelector('[name="price"]').value);
                        var stock = parseInt(this.querySelector('[name="stock"]').value);

                        if (name.length < 2) {
                            alert('Product name must be at least 2 characters');
                            e.preventDefault();
                            return;
                        }
                        if (isNaN(price) || price <= 0) {
                            alert('Please enter a valid price');
                            e.preventDefault();
                            return;
                        }
                        if (isNaN(stock) || stock < 0) {
                            alert('Please enter a valid stock quantity');
                            e.preventDefault();
                            return;
                        }
                    });
                </script>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>