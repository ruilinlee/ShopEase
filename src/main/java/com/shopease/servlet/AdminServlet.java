package com.shopease.servlet;

import com.shopease.entity.Order;
import com.shopease.entity.Order.OrderItem;
import com.shopease.entity.Product;
import com.shopease.entity.User;
import com.shopease.repository.OrderRepository;
import com.shopease.repository.ProductRepository;
import com.shopease.repository.UserRepository;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Handles admin operations: dashboard, product management, user viewing.
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    
    private ProductRepository productRepository;
    private UserRepository userRepository;
    private OrderRepository orderRepository;
    
    @Override
    public void init() throws ServletException {
        productRepository = ProductRepository.getInstance();
        userRepository = UserRepository.getInstance();
        orderRepository = OrderRepository.getInstance();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!isAdmin(request)) {
            response.sendRedirect("admin_login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "dashboard";
        }
        
        switch (action) {
            case "pending":
                showPendingProducts(request, response);
                break;
            case "products":
                showAllProducts(request, response);
                break;
            case "users":
                showAllUsers(request, response);
                break;
            case "orders":
                showAllOrders(request, response);
                break;
            case "approve":
                approveProduct(request, response);
                break;
            case "reject":
                rejectProduct(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            case "updateStatus":
                updateProductStatus(request, response);
                break;
            case "updateOrder":
            case "updateOrderStatus":
                updateOrderStatus(request, response);
                break;
            case "approveRefund":
                handleApproveRefund(request, response);
                break;
            case "rejectRefund":
                handleRejectRefund(request, response);
                break;
            default:
                showDashboard(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Shows admin dashboard with statistics.
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalProducts", productRepository.count());
        stats.put("pendingProducts", productRepository.findPending().size());
        stats.put("approvedProducts", productRepository.findApproved().size());
        stats.put("totalUsers", userRepository.count());
        stats.put("totalOrders", orderRepository.count());
        
        // Calculate total revenue
        double totalRevenue = orderRepository.findAll().stream()
                .mapToDouble(Order::getTotalAmount)
                .sum();
        stats.put("totalRevenue", totalRevenue);
        
        request.setAttribute("stats", stats);
        request.setAttribute("recentOrders", orderRepository.findAllSorted().stream().limit(5).toArray());
        request.setAttribute("pendingProducts", productRepository.findPending());
        
        request.getRequestDispatcher("/admin.jsp").forward(request, response);
    }
    
    /**
     * Shows products pending approval.
     */
    private void showPendingProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Product> pendingProducts = productRepository.findPending();
        request.setAttribute("products", pendingProducts);
        request.setAttribute("viewType", "pending");
        request.getRequestDispatcher("/admin_products.jsp").forward(request, response);
    }
    
    /**
     * Shows all products.
     */
    private void showAllProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Product> products = productRepository.findAll();
        request.setAttribute("products", products);
        request.setAttribute("viewType", "all");
        request.getRequestDispatcher("/admin_products.jsp").forward(request, response);
    }
    
    /**
     * Shows all users.
     */
    private void showAllUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<User> users = userRepository.findAll();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin_users.jsp").forward(request, response);
    }
    
    /**
     * Shows all orders.
     */
    private void showAllOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Order> orders = orderRepository.findAllSorted();
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/admin_orders.jsp").forward(request, response);
    }
    
    /**
     * Approves a pending product.
     */
    private void approveProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String productId = request.getParameter("id");
        if (productId != null) {
            productRepository.approve(productId);
        }
        response.sendRedirect("admin?action=pending");
    }
    
    /**
     * Rejects a pending product.
     */
    private void rejectProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String productId = request.getParameter("id");
        if (productId != null) {
            productRepository.reject(productId);
        }
        response.sendRedirect("admin?action=pending");
    }
    
    /**
     * Deletes a product.
     */
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String productId = request.getParameter("id");
        if (productId != null) {
            productRepository.delete(productId);
        }

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("admin?action=products");
        }
    }

    /**
     * Updates a product's status (available, sold, approved, rejected).
     */
    private void updateProductStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String productId = request.getParameter("id");
        String status = request.getParameter("status");

        if (productId != null && status != null) {
            productRepository.updateStatus(productId, status);
        }

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("admin?action=products");
        }
    }

    /**
     * Updates an order's status.
     */
    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String orderId = request.getParameter("id");
        String status = request.getParameter("status");

        if (orderId != null && status != null) {
            orderRepository.updateStatus(orderId, status);
        }

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("admin?action=orders");
        }
    }

    /**
     * Handles admin approval of refund request.
     */
    private void handleApproveRefund(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String orderId = request.getParameter("id");

        orderRepository.findById(orderId)
                .filter(Order::isRefundRequested)
                .ifPresent(order -> {
                    order.setStatus("refunded");
                    order.setRefundStatus("refunded");
                    order.setPaymentStatus("refunded");
                    order.setRefundProcessedAt(System.currentTimeMillis());
                    restoreOrderStock(order);
                    orderRepository.save(order);
                });

        response.sendRedirect("admin?action=orders");
    }

    /**
     * Handles admin rejection of refund request.
     */
    private void handleRejectRefund(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String orderId = request.getParameter("id");

        orderRepository.findById(orderId)
                .filter(Order::isRefundRequested)
                .ifPresent(order -> {
                    order.setRefundStatus("rejected");
                    order.setRefundProcessedAt(System.currentTimeMillis());
                    orderRepository.save(order);
                });

        response.sendRedirect("admin?action=orders");
    }

    /**
     * Restores product stock when order is refunded.
     */
    private void restoreOrderStock(Order order) {
        ProductRepository productRepository = ProductRepository.getInstance();
        for (OrderItem item : order.getItems()) {
            productRepository.findById(item.getProductId()).ifPresent(product -> {
                product.setStock(product.getStock() + item.getQuantity());
                if ("sold".equals(product.getStatus()) && product.isApproved()) {
                    product.setStatus("available");
                }
                productRepository.save(product);
            });
        }
    }

    /**
     * Checks if current user is an admin.
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        String role = (String) session.getAttribute("role");
        return "admin".equals(role);
    }
}
