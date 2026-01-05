package com.shopease.servlet;

import com.shopease.entity.CartItem;
import com.shopease.entity.Product;
import com.shopease.repository.CartRepository;
import com.shopease.repository.ProductRepository;
import com.shopease.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Handles shopping cart operations: add, remove, update, clear.
 */
@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private CartRepository cartRepository;
    private ProductRepository productRepository;

    @Override
    public void init() throws ServletException {
        cartRepository = CartRepository.getInstance();
        productRepository = ProductRepository.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            showCart(request, response);
            return;
        }

        switch (action) {
            case "add":
                addToCart(request, response);
                break;
            case "remove":
                removeFromCart(request, response);
                break;
            case "increase":
                updateQuantity(request, response, 1);
                break;
            case "decrease":
                updateQuantity(request, response, -1);
                break;
            case "clear":
                clearCart(request, response);
                break;
            default:
                showCart(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Shows the shopping cart page.
     */
    private void showCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = getUserId(request);
        List<CartItem> cartItems = cartRepository.findByUserId(userId);
        double total = cartRepository.calculateTotal(userId);

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", total);
        request.setAttribute("itemCount", cartRepository.getItemCount(userId));
        updateCartCount(request, userId);

        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    /**
     * Adds a product to the cart.
     */
    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String userId = getUserId(request);
        String productId = request.getParameter("productId");
        if (productId == null) {
            productId = request.getParameter("id");
        }

        if (productId == null) {
            response.sendRedirect("products");
            return;
        }

        // Check if product exists and is available
        final String pid = productId;
        productRepository.findById(pid)
                .filter(p -> (p.isApproved() || p.isAvailable()) && p.getStock() > 0)
                .filter(p -> p.getSellerId() == null || !p.getSellerId().equals(userId))
                .ifPresent(product -> {
                    // Check if already in cart
                    cartRepository.findByUserAndProduct(userId, pid)
                            .ifPresentOrElse(
                                    existing -> {
                                        // Increment quantity
                                        if (existing.getQuantity() < product.getStock()) {
                                            existing.incrementQuantity();
                                            cartRepository.save(existing);
                                        }
                                    },
                                    () -> {
                                        // Add new cart item
                                        CartItem cartItem = new CartItem(
                                                userId,
                                                product.getId(),
                                                product.getName(),
                                                product.getPrice(),
                                                product.getImageUrl());
                                        cartRepository.save(cartItem);
                                    });
                });

        updateCartCount(request, userId);

        // Check referer to return to previous page
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("cart");
        }
    }

    /**
     * Removes a product from the cart.
     */
    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String userId = getUserId(request);
        String productId = request.getParameter("id");

        if (productId != null) {
            cartRepository.removeFromCart(userId, productId);
        }
        updateCartCount(request, userId);

        response.sendRedirect("cart");
    }

    /**
     * Updates cart item quantity.
     */
    private void updateQuantity(HttpServletRequest request, HttpServletResponse response, int delta)
            throws IOException {

        String userId = getUserId(request);
        String productId = request.getParameter("id");

        // Validate product ID format
        if (productId == null || !ValidationUtils.isValidUUID(productId)) {
            response.sendRedirect("cart");
            return;
        }

        cartRepository.findByUserAndProduct(userId, productId)
                .ifPresent(item -> {
                    int newQuantity = item.getQuantity() + delta;
                    if (newQuantity <= 0) {
                        cartRepository.delete(item.getId());
                    } else {
                        Product product = productRepository.findById(productId).orElse(null);
                        if (product != null &&
                                (product.isApproved() || product.isAvailable())) {
                            // Validate quantity against stock and max limit
                            int maxAllowed = Math.min(product.getStock(), ValidationUtils.MAX_QUANTITY);
                            if (newQuantity <= maxAllowed) {
                                item.setQuantity(newQuantity);
                                cartRepository.save(item);
                            }
                        }
                    }
                });

        updateCartCount(request, userId);
        response.sendRedirect("cart");
    }

    /**
     * Clears all items from the cart.
     */
    private void clearCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String userId = getUserId(request);
        cartRepository.clearUserCart(userId);
        updateCartCount(request, userId);
        response.sendRedirect("cart");
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

    private void updateCartCount(HttpServletRequest request, String userId) {
        int count = cartRepository.getItemCount(userId);
        request.getSession().setAttribute("cartCount", count);
    }
}
