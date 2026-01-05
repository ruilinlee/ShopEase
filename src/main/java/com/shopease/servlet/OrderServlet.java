package com.shopease.servlet;

import com.shopease.entity.Address;
import com.shopease.entity.CartItem;
import com.shopease.entity.Order;
import com.shopease.entity.Order.OrderItem;
import com.shopease.entity.Product;
import com.shopease.repository.AddressRepository;
import com.shopease.repository.CartRepository;
import com.shopease.repository.OrderRepository;
import com.shopease.repository.ProductRepository;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Handles order operations: checkout, view history.
 */
@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    private OrderRepository orderRepository;
    private CartRepository cartRepository;
    private ProductRepository productRepository;
    private AddressRepository addressRepository;

    @Override
    public void init() throws ServletException {
        orderRepository = OrderRepository.getInstance();
        cartRepository = CartRepository.getInstance();
        productRepository = ProductRepository.getInstance();
        addressRepository = AddressRepository.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("details".equals(action)) {
            showOrderDetails(request, response);
        } else if ("checkout".equals(action)) {
            showCheckoutPage(request, response);
        } else {
            showOrderHistory(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        switch (action != null ? action : "") {
            case "checkout":
                handleCheckout(request, response);
                break;
            case "placeOrder":
                handlePlaceOrder(request, response);
                break;
            case "requestRefund":
                handleRequestRefund(request, response);
                break;
            case "approveRefund":
                handleApproveRefund(request, response);
                break;
            case "rejectRefund":
                handleRejectRefund(request, response);
                break;
            case "confirmOrder":
                handleConfirmOrder(request, response);
                break;
            case "shipOrder":
                handleShipOrder(request, response);
                break;
            case "deliverOrder":
                handleDeliverOrder(request, response);
                break;
            default:
                response.sendRedirect("orders");
        }
    }

    /**
     * Shows order history for the current user.
     */
    private void showOrderHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = getUserId(request);
        List<Order> orders = orderRepository.findByBuyerId(userId);

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }

    /**
     * Shows order details.
     */
    private void showOrderDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("id");
        String userId = getUserId(request);

        if (orderId == null) {
            response.sendRedirect("orders");
            return;
        }

        orderRepository.findById(orderId)
                .filter(order -> order.getBuyerId().equals(userId))
                .ifPresentOrElse(
                        order -> {
                            try {
                                request.setAttribute("order", order);
                                request.getRequestDispatcher("/order_details.jsp").forward(request, response);
                            } catch (ServletException | IOException e) {
                                e.printStackTrace();
                            }
                        },
                        () -> {
                            try {
                                response.sendRedirect("orders");
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        });
    }

    /**
     * Shows checkout page with selected items.
     */
    private void showCheckoutPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = getUserId(request);
        String[] selectedItems = request.getParameterValues("selectedItems");

        List<CartItem> cartItems;
        if (selectedItems != null && selectedItems.length > 0) {
            List<String> selectedIds = Arrays.asList(selectedItems);
            cartItems = cartRepository.findByUserId(userId).stream()
                    .filter(item -> selectedIds.contains(item.getProductId()))
                    .collect(Collectors.toList());
        } else {
            cartItems = cartRepository.findByUserId(userId);
        }

        if (cartItems.isEmpty()) {
            response.sendRedirect("cart");
            return;
        }

        double total = cartItems.stream()
                .mapToDouble(CartItem::getSubtotal)
                .sum();

        List<Address> addresses = addressRepository.findByUserId(userId);

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", total);
        request.setAttribute("addresses", addresses);
        request.setAttribute("selectedItemIds", selectedItems);
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    /**
     * Handles checkout process (legacy - redirects to checkout page).
     */
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        showCheckoutPage(request, response);
    }

    /**
     * Places the final order with payment and shipping info.
     */
    private void handlePlaceOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = getUserId(request);
        String username = (String) request.getSession().getAttribute("username");
        String[] selectedItems = request.getParameterValues("selectedItems");
        String addressId = request.getParameter("addressId");
        String paymentMethod = request.getParameter("paymentMethod");

        // Get cart items (selected or all)
        List<CartItem> cartItems;
        if (selectedItems != null && selectedItems.length > 0) {
            List<String> selectedIds = Arrays.asList(selectedItems);
            cartItems = cartRepository.findByUserId(userId).stream()
                    .filter(item -> selectedIds.contains(item.getProductId()))
                    .collect(Collectors.toList());
        } else {
            cartItems = cartRepository.findByUserId(userId);
        }

        if (cartItems.isEmpty()) {
            response.sendRedirect("cart");
            return;
        }

        // Validate address
        Address shippingAddr = addressRepository.findById(addressId).orElse(null);
        if (shippingAddr == null) {
            request.setAttribute("error", "Please select a shipping address");
            showCheckoutPage(request, response);
            return;
        }

        // Check stock availability
        List<String> unavailableItems = new ArrayList<>();
        for (CartItem cartItem : cartItems) {
            Product product = productRepository.findById(cartItem.getProductId()).orElse(null);
            if (product == null ||
                    product.isSold() ||
                    !product.canBePurchased() ||
                    product.getStock() < cartItem.getQuantity()) {
                unavailableItems.add(cartItem.getProductName());
            }
        }

        if (!unavailableItems.isEmpty()) {
            request.setAttribute("error", "Some items are no longer available: " + String.join(", ", unavailableItems));
            showCheckoutPage(request, response);
            return;
        }

        // Create order items and update stock, collect seller IDs
        List<OrderItem> orderItems = new ArrayList<>();
        String sellerId = null;
        for (CartItem cartItem : cartItems) {
            OrderItem orderItem = new OrderItem(
                    cartItem.getProductId(),
                    cartItem.getProductName(),
                    cartItem.getPrice(),
                    cartItem.getQuantity(),
                    cartItem.getImageUrl());
            orderItems.add(orderItem);

            Product product = productRepository.findById(cartItem.getProductId()).orElse(null);
            if (product != null) {
                // Capture seller ID from first product (for single-seller orders)
                if (sellerId == null) {
                    sellerId = product.getSellerId();
                }
                int newStock = product.getStock() - cartItem.getQuantity();
                if (newStock <= 0) {
                    product.setStock(0);
                    product.setStatus("sold");
                } else {
                    product.setStock(newStock);
                }
                productRepository.save(product);
            }
        }

        // Calculate total
        double total = cartItems.stream()
                .mapToDouble(CartItem::getSubtotal)
                .sum();

        // Create order with payment and shipping info
        Order order = new Order(userId, orderItems, total);
        order.setBuyerName(username);
        order.setSellerId(sellerId);
        order.setPaymentMethod(paymentMethod != null ? paymentMethod : "card");
        order.setPaymentStatus("paid");
        order.setShippingAddressId(addressId);
        order.setShippingAddress(shippingAddr.getFullAddress());
        orderRepository.save(order);

        // Remove only purchased items from cart
        for (CartItem item : cartItems) {
            cartRepository.removeFromCart(userId, item.getProductId());
        }
        request.getSession().setAttribute("cartCount", cartRepository.getItemCount(userId));

        // Redirect to success page
        request.setAttribute("order", order);
        request.getRequestDispatcher("/order_success.jsp").forward(request, response);
    }

    /**
     * Handles refund request from buyer.
     */
    private void handleRequestRefund(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String userId = getUserId(request);
        String orderId = request.getParameter("orderId");
        String reason = request.getParameter("reason");

        orderRepository.findById(orderId)
                .filter(order -> order.getBuyerId().equals(userId))
                .filter(Order::isRefundable)
                .ifPresent(order -> {
                    String status = order.getStatus();

                    // Auto-approve for unshipped orders
                    if ("pending".equals(status) || "confirmed".equals(status)) {
                        order.setRefundStatus("refunded");
                        order.setStatus("cancelled");
                        order.setPaymentStatus("refunded");
                        order.setRefundProcessedAt(System.currentTimeMillis());

                        // Restore stock
                        restoreOrderStock(order);
                    } else {
                        // For shipped/delivered orders, request approval
                        order.setRefundStatus("requested");
                        order.setRefundRequestedAt(System.currentTimeMillis());
                    }
                    order.setRefundReason(reason);
                    orderRepository.save(order);
                });

        response.sendRedirect("orders?action=details&id=" + orderId);
    }

    /**
     * Handles refund approval by seller.
     */
    private void handleApproveRefund(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentUserId = (String) session.getAttribute("userId");
        String orderId = request.getParameter("orderId");

        orderRepository.findById(orderId)
                .filter(Order::hasRefundRequest)
                .filter(order -> currentUserId.equals(order.getSellerId())) // Verify seller permission
                .ifPresent(order -> {
                    order.setRefundStatus("refunded");
                    order.setStatus("refunded");
                    order.setPaymentStatus("refunded");
                    order.setRefundProcessedAt(System.currentTimeMillis());

                    // Restore stock
                    restoreOrderStock(order);
                    orderRepository.save(order);
                });

        response.sendRedirect("products?action=mySales");
    }

    /**
     * Handles refund rejection by seller.
     */
    private void handleRejectRefund(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentUserId = (String) session.getAttribute("userId");
        String orderId = request.getParameter("orderId");

        orderRepository.findById(orderId)
                .filter(Order::hasRefundRequest)
                .filter(order -> currentUserId.equals(order.getSellerId())) // Verify seller permission
                .ifPresent(order -> {
                    order.setRefundStatus("rejected");
                    order.setRefundProcessedAt(System.currentTimeMillis());
                    orderRepository.save(order);
                });

        response.sendRedirect("products?action=mySales");
    }

    /**
     * Handles order confirmation by seller.
     */
    private void handleConfirmOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String currentUserId = getUserId(request);
        String orderId = request.getParameter("orderId");

        orderRepository.findById(orderId)
                .filter(order -> "pending".equals(order.getStatus()))
                .filter(order -> currentUserId.equals(order.getSellerId()))
                .ifPresent(order -> {
                    order.setStatus("confirmed");
                    orderRepository.save(order);
                });

        response.sendRedirect("products?action=mySales");
    }

    /**
     * Handles order shipping by seller.
     */
    private void handleShipOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String currentUserId = getUserId(request);
        String orderId = request.getParameter("orderId");

        orderRepository.findById(orderId)
                .filter(order -> "confirmed".equals(order.getStatus()))
                .filter(order -> currentUserId.equals(order.getSellerId()))
                .ifPresent(order -> {
                    order.setStatus("shipped");
                    orderRepository.save(order);
                });

        response.sendRedirect("products?action=mySales");
    }

    /**
     * Handles marking order as delivered by seller.
     */
    private void handleDeliverOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String currentUserId = getUserId(request);
        String orderId = request.getParameter("orderId");

        orderRepository.findById(orderId)
                .filter(order -> "shipped".equals(order.getStatus()))
                .filter(order -> currentUserId.equals(order.getSellerId()))
                .ifPresent(order -> {
                    order.setStatus("delivered");
                    orderRepository.save(order);
                });

        response.sendRedirect("products?action=mySales");
    }

    /**
     * Restores product stock when order is refunded/cancelled.
     */
    private void restoreOrderStock(Order order) {
        for (OrderItem item : order.getItems()) {
            productRepository.findById(item.getProductId()).ifPresent(product -> {
                product.setStock(product.getStock() + item.getQuantity());
                // Only restore to "available" if product is approved and was marked as "sold"
                if ("sold".equals(product.getStatus()) && product.isApproved()) {
                    product.setStatus("available");
                }
                productRepository.save(product);
            });
        }
    }

    /**
     * Checks if user is logged in.
     */
    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("userId") != null;
    }

    /**
     * Gets the current user's ID from session.
     */
    private String getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession();
        return (String) session.getAttribute("userId");
    }
}
