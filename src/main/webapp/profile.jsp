<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.shopease.entity.Address" %>
<%
    // Prevent admin from accessing customer profile page
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("admin.jsp");
        return;
    }
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    String email = (String) session.getAttribute("email");
    String phone = (String) session.getAttribute("phone");
    String fullName = (String) session.getAttribute("fullName");
    List<Address> addresses = (List<Address>) request.getAttribute("addresses");
%>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Profile - ShopEase</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                        rel="stylesheet">
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

                        .nav-icon {
                            font-size: 1.1rem;
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

                        .cart-badge {
                            background: #dc3545;
                            color: #fff;
                            font-size: 0.7rem;
                            padding: 0.15rem 0.4rem;
                            border-radius: 10px;
                            margin-left: 0.25rem;
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

                        .profile-card {
                            background: #fff;
                            border-radius: 8px;
                            padding: 1.5rem;
                            border: 1px solid #eee;
                            margin-bottom: 1.5rem;
                        }

                        .section-title {
                            font-size: 1rem;
                            font-weight: 600;
                            margin-bottom: 1rem;
                            padding-bottom: 0.5rem;
                            border-bottom: 1px solid #eee;
                        }

                        .form-label {
                            font-size: 0.9rem;
                            font-weight: 500;
                            margin-bottom: 0.4rem;
                        }

                        .form-control {
                            border: 1px solid #ddd;
                            border-radius: 4px;
                            font-size: 0.9rem;
                            padding: 0.6rem 0.75rem;
                        }

                        .form-control:focus {
                            border-color: #999;
                            box-shadow: none;
                        }

                        .btn-primary-custom {
                            background: #333;
                            color: #fff;
                            border: none;
                            padding: 0.5rem 1.5rem;
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
                            padding: 0.5rem 1.5rem;
                            border-radius: 4px;
                            font-size: 0.9rem;
                        }

                        .btn-outline-custom:hover {
                            background: #f5f5f5;
                            color: #333;
                        }

                        .btn-danger-custom {
                            background: #dc3545;
                            color: #fff;
                            border: none;
                            padding: 0.35rem 0.8rem;
                            border-radius: 4px;
                            font-size: 0.8rem;
                        }

                        .btn-danger-custom:hover {
                            background: #c82333;
                        }

                        .address-card {
                            background: #fafafa;
                            border-radius: 6px;
                            padding: 1rem;
                            margin-bottom: 0.75rem;
                            border: 1px solid #eee;
                        }

                        .address-card.default {
                            border-color: #333;
                        }

                        .address-name {
                            font-weight: 600;
                            font-size: 0.95rem;
                        }

                        .address-detail {
                            font-size: 0.85rem;
                            color: #666;
                            margin-top: 0.25rem;
                        }

                        .default-badge {
                            background: #333;
                            color: #fff;
                            font-size: 0.7rem;
                            padding: 0.15rem 0.5rem;
                            border-radius: 4px;
                            margin-left: 0.5rem;
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

                        .error-msg {
                            background: #ffebee;
                            border: 1px solid #ef9a9a;
                            border-radius: 4px;
                            padding: 0.75rem 1rem;
                            font-size: 0.85rem;
                            color: #c62828;
                            margin-bottom: 1rem;
                        }

                        .modal-header {
                            border-bottom: 1px solid #eee;
                        }

                        .modal-footer {
                            border-top: 1px solid #eee;
                        }
                    </style>
                </head>

                <body>
                    <nav class="navbar sticky-top">
                        <div class="container">
                            <a class="navbar-brand" href="index.jsp">ShopEase</a>
                            <div class="d-flex align-items-center gap-3">
                                <a href="products" class="nav-link">Products</a>
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
                                <a href="publish.jsp" class="btn-nav">Sell Item</a>
                                <a href="user?action=logout" class="btn-outline-nav">Logout</a>
                            </div>
                        </div>
                    </nav>

                    <div class="page-header">
                        <div class="container">
                            <div class="d-flex justify-content-between align-items-center">
                                <h1 class="page-title">My Profile</h1>
                                <a href="products" class="back-link">← Back to Products</a>
                            </div>
                        </div>
                    </div>

                    <main class="container my-4">
                        <% if (request.getAttribute("success") !=null) { %>
                            <div class="success-msg">
                                <%= request.getAttribute("success") %>
                            </div>
                            <% } %>
                                <% if (request.getAttribute("error") !=null) { %>
                                    <div class="error-msg">
                                        <%= request.getAttribute("error") %>
                                    </div>
                                    <% } %>

                                        <div class="row">
                                            <div class="col-lg-6">
                                                <!-- Profile Information -->
                                                <div class="profile-card">
                                                    <h5 class="section-title">Profile Information</h5>
                                                    <form action="user" method="post">
                                                        <input type="hidden" name="action" value="updateProfile">
                                                        <div class="mb-3">
                                                            <label class="form-label">Username</label>
                                                            <input type="text" class="form-control"
                                                                value="<%= username %>" disabled>
                                                            <div class="form-text">Username cannot be changed</div>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Full Name</label>
                                                            <input type="text" name="fullName" class="form-control"
                                                                value="<%= fullName != null ? fullName : "" %>"
                                                                placeholder="Enter your full name">
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Email</label>
                                                            <input type="email" name="email" class="form-control"
                                                                value="<%= email != null ? email : "" %>"
                                                                placeholder="your@email.com">
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Phone Number</label>
                                                            <input type="tel" name="phone" class="form-control"
                                                                value="<%= phone != null ? phone : "" %>"
                                                                placeholder="+60 12-345 6789">
                                                        </div>
                                                        <button type="submit" class="btn-primary-custom">Save
                                                            Changes</button>
                                                    </form>
                                                </div>

                                                <!-- Change Password -->
                                                <div class="profile-card">
                                                    <h5 class="section-title">Change Password</h5>
                                                    <form action="user" method="post">
                                                        <input type="hidden" name="action" value="changePassword">
                                                        <div class="mb-3">
                                                            <label class="form-label">Current Password</label>
                                                            <input type="password" name="currentPassword"
                                                                class="form-control" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">New Password</label>
                                                            <input type="password" name="newPassword"
                                                                class="form-control" required minlength="6">
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Confirm New Password</label>
                                                            <input type="password" name="confirmPassword"
                                                                class="form-control" required minlength="6">
                                                        </div>
                                                        <button type="submit" class="btn-primary-custom">Update
                                                            Password</button>
                                                    </form>
                                                </div>
                                            </div>

                                            <div class="col-lg-6">
                                                <!-- Address Book -->
                                                <div class="profile-card">
                                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                                        <h5 class="section-title mb-0"
                                                            style="border-bottom: none; padding-bottom: 0;">Address Book
                                                        </h5>
                                                        <button type="button" class="btn-primary-custom"
                                                            data-bs-toggle="modal" data-bs-target="#addAddressModal">
                                                            Add Address
                                                        </button>
                                                    </div>

                                                    <% if (addresses !=null && !addresses.isEmpty()) { %>
                                                        <% for (Address addr : addresses) { %>
                                                            <div class="address-card <%= addr.isDefault() ? " default"
                                                                : "" %>">
                                                                <div
                                                                    class="d-flex justify-content-between align-items-start">
                                                                    <div>
                                                                        <span class="address-name">
                                                                            <%= addr.getRecipientName() %>
                                                                        </span>
                                                                        <% if (addr.isDefault()) { %>
                                                                            <span class="default-badge">Default</span>
                                                                            <% } %>
                                                                                <div class="address-detail">
                                                                                    <%= addr.getPhoneNumber() %>
                                                                                </div>
                                                                                <div class="address-detail">
                                                                                    <%= addr.getFullAddress() %>
                                                                                </div>
                                                                    </div>
                                                                    <div class="d-flex gap-2">
                                                                        <% if (!addr.isDefault()) { %>
                                                                            <form action="user" method="post"
                                                                                style="display:inline;">
                                                                                <input type="hidden" name="action"
                                                                                    value="setDefaultAddress">
                                                                                <input type="hidden" name="addressId"
                                                                                    value="<%= addr.getId() %>">
                                                                                <button type="submit"
                                                                                    class="btn-outline-custom"
                                                                                    style="padding: 0.25rem 0.5rem; font-size: 0.75rem;">Set
                                                                                    Default</button>
                                                                            </form>
                                                                            <% } %>
                                                                                <form action="user" method="post"
                                                                                    style="display:inline;">
                                                                                    <input type="hidden" name="action"
                                                                                        value="deleteAddress">
                                                                                    <input type="hidden"
                                                                                        name="addressId"
                                                                                        value="<%= addr.getId() %>">
                                                                                    <button type="submit"
                                                                                        class="btn-danger-custom"
                                                                                        onclick="return confirm('Delete this address?')">Delete</button>
                                                                                </form>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <% } %>
                                                                <% } else { %>
                                                                    <div class="text-center py-4 text-muted">
                                                                        <p>No saved addresses</p>
                                                                        <p class="small">Add an address for faster
                                                                            checkout</p>
                                                                    </div>
                                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                    </main>

                    <!-- Add Address Modal -->
                    <div class="modal fade" id="addAddressModal" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Add New Address</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <form action="user" method="post">
                                    <input type="hidden" name="action" value="addAddress">
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label">Recipient Name</label>
                                            <input type="text" name="recipientName" class="form-control" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Phone Number</label>
                                            <input type="tel" name="phoneNumber" class="form-control" required
                                                placeholder="+60 12-345 6789">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Address Line 1</label>
                                            <input type="text" name="addressLine1" class="form-control" required
                                                placeholder="Street address, house number">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Address Line 2 (Optional)</label>
                                            <input type="text" name="addressLine2" class="form-control"
                                                placeholder="Apartment, unit, building, floor">
                                        </div>
                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label class="form-label">Postal Code</label>
                                                <input type="text" name="postalCode" class="form-control" required
                                                    maxlength="5" pattern="[0-9]{5}" placeholder="12345">
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label class="form-label">City</label>
                                                <input type="text" name="city" class="form-control" required>
                                            </div>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">State</label>
                                            <select name="state" class="form-control" required>
                                                <option value="">Select state</option>
                                                <option value="Johor">Johor</option>
                                                <option value="Kedah">Kedah</option>
                                                <option value="Kelantan">Kelantan</option>
                                                <option value="Kuala Lumpur">Kuala Lumpur</option>
                                                <option value="Labuan">Labuan</option>
                                                <option value="Melaka">Melaka</option>
                                                <option value="Negeri Sembilan">Negeri Sembilan</option>
                                                <option value="Pahang">Pahang</option>
                                                <option value="Penang">Penang</option>
                                                <option value="Perak">Perak</option>
                                                <option value="Perlis">Perlis</option>
                                                <option value="Putrajaya">Putrajaya</option>
                                                <option value="Sabah">Sabah</option>
                                                <option value="Sarawak">Sarawak</option>
                                                <option value="Selangor">Selangor</option>
                                                <option value="Terengganu">Terengganu</option>
                                            </select>
                                        </div>
                                        <div class="form-check">
                                            <input type="checkbox" name="setDefault" class="form-check-input"
                                                id="setDefaultCheck">
                                            <label class="form-check-label" for="setDefaultCheck">Set as default
                                                address</label>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn-outline-custom"
                                            data-bs-dismiss="modal">Cancel</button>
                                        <button type="submit" class="btn-primary-custom">Save Address</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>