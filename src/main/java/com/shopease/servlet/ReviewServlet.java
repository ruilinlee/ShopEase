package com.shopease.servlet;

import com.shopease.entity.Review;
import com.shopease.repository.ReviewRepository;
import com.shopease.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Handles product review operations: add, delete, list.
 */
@WebServlet("/reviews")
public class ReviewServlet extends HttpServlet {

    private ReviewRepository reviewRepository;

    @Override
    public void init() throws ServletException {
        reviewRepository = ReviewRepository.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String productId = request.getParameter("productId");

        if ("list".equals(action) && productId != null) {
            // Return reviews as JSON for AJAX requests
            List<Review> reviews = reviewRepository.findByProductId(productId);
            double avgRating = reviewRepository.getAverageRating(productId);
            int reviewCount = reviews.size();

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();

            StringBuilder json = new StringBuilder();
            json.append("{\"averageRating\":").append(String.format("%.1f", avgRating));
            json.append(",\"reviewCount\":").append(reviewCount);
            json.append(",\"reviews\":[");

            for (int i = 0; i < reviews.size(); i++) {
                Review r = reviews.get(i);
                if (i > 0)
                    json.append(",");
                json.append("{");
                json.append("\"id\":\"").append(escapeJson(r.getId())).append("\",");
                json.append("\"userId\":\"").append(escapeJson(r.getUserId())).append("\",");
                json.append("\"username\":\"").append(escapeJson(r.getUsername())).append("\",");
                json.append("\"rating\":").append(r.getRating()).append(",");
                json.append("\"comment\":\"").append(escapeJson(r.getComment())).append("\",");
                json.append("\"createdAt\":").append(r.getCreatedAt());
                json.append("}");
            }
            json.append("]}");

            out.print(json.toString());
            out.flush();
        } else {
            response.sendRedirect("products");
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

        if ("add".equals(action)) {
            addReview(request, response);
        } else if ("delete".equals(action)) {
            deleteReview(request, response);
        } else {
            response.sendRedirect("products");
        }
    }

    /**
     * Adds a new review for a product.
     */
    private void addReview(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String productId = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");
        String userId = getUserId(request);
        String username = getUsername(request);

        // Validate required fields
        if (productId == null || productId.trim().isEmpty() || ratingStr == null || comment == null) {
            response.sendRedirect("products");
            return;
        }

        // Check if user already reviewed this product
        if (reviewRepository.hasUserReviewedProduct(userId, productId)) {
            response.sendRedirect("products?action=details&id=" + productId + "&error=already_reviewed");
            return;
        }

        // Validate rating using ValidationUtils
        int rating = ValidationUtils.parseAndValidateRating(ratingStr);
        if (rating == -1) {
            rating = 3; // Default to middle rating if invalid
        }

        // Validate and sanitize comment
        comment = comment.trim();
        if (!ValidationUtils.isValidComment(comment)) {
            if (comment.isEmpty()) {
                response.sendRedirect("products?action=details&id=" + productId + "&error=empty_comment");
                return;
            }
            // Truncate if too long
            comment = comment.substring(0, ValidationUtils.MAX_COMMENT_LENGTH);
        }

        Review review = new Review(productId, userId, username, rating, comment);
        reviewRepository.save(review);

        response.sendRedirect("products?action=details&id=" + productId);
    }

    /**
     * Deletes a review (owner or admin only).
     */
    private void deleteReview(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String reviewId = request.getParameter("id");
        String productId = request.getParameter("productId");
        String userId = getUserId(request);
        boolean isAdmin = isAdmin(request);

        // Validate review ID format
        if (reviewId == null || reviewId.trim().isEmpty()) {
            response.sendRedirect("products");
            return;
        }

        reviewRepository.findById(reviewId).ifPresent(review -> {
            // Only owner or admin can delete
            if (review.getUserId().equals(userId) || isAdmin) {
                reviewRepository.delete(reviewId);
            }
        });

        if (productId != null && !productId.trim().isEmpty()) {
            response.sendRedirect("products?action=details&id=" + productId);
        } else {
            response.sendRedirect("products");
        }
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("userId") != null;
    }

    private String getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession();
        return (String) session.getAttribute("userId");
    }

    private String getUsername(HttpServletRequest request) {
        HttpSession session = request.getSession();
        return (String) session.getAttribute("username");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession();
        return "admin".equals(session.getAttribute("role"));
    }

    private String escapeJson(String text) {
        if (text == null)
            return "";
        return text.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
