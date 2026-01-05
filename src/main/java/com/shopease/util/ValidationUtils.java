package com.shopease.util;

/**
 * Utility class for comprehensive data validation.
 * Provides validation methods for common e-commerce data types.
 */
public class ValidationUtils {

    // Price validation constants
    public static final double MIN_PRICE = 0.01;
    public static final double MAX_PRICE = 999999.99;

    // Stock validation constants
    public static final int MIN_STOCK = 0;
    public static final int MAX_STOCK = 9999;

    // Quantity validation constants
    public static final int MIN_QUANTITY = 1;
    public static final int MAX_QUANTITY = 100;

    // Text length constants
    public static final int MIN_NAME_LENGTH = 2;
    public static final int MAX_NAME_LENGTH = 100;
    public static final int MAX_DESCRIPTION_LENGTH = 2000;
    public static final int MAX_COMMENT_LENGTH = 500;
    public static final int MIN_PASSWORD_LENGTH = 6;
    public static final int MAX_PASSWORD_LENGTH = 100;

    // Phone validation pattern (Malaysian format)
    public static final String PHONE_PATTERN = "^(\\+?6?0)[0-9]{1,2}[-\\s]?[0-9]{7,8}$";

    // Email validation pattern
    public static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

    // Postal code pattern (Malaysian 5 digits)
    public static final String POSTAL_CODE_PATTERN = "^[0-9]{5}$";

    /**
     * Validates price value.
     * 
     * @param price The price to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPrice(double price) {
        return price >= MIN_PRICE && price <= MAX_PRICE && !Double.isNaN(price) && !Double.isInfinite(price);
    }

    /**
     * Validates price string and parses it.
     * 
     * @param priceStr The price string to validate
     * @return The parsed price, or -1 if invalid
     */
    public static double parseAndValidatePrice(String priceStr) {
        if (priceStr == null || priceStr.trim().isEmpty()) {
            return -1;
        }
        try {
            double price = Double.parseDouble(priceStr.trim());
            return isValidPrice(price) ? price : -1;
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Validates stock quantity.
     * 
     * @param stock The stock quantity to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidStock(int stock) {
        return stock >= MIN_STOCK && stock <= MAX_STOCK;
    }

    /**
     * Validates stock string and parses it.
     * 
     * @param stockStr The stock string to validate
     * @return The parsed stock, or -1 if invalid
     */
    public static int parseAndValidateStock(String stockStr) {
        if (stockStr == null || stockStr.trim().isEmpty()) {
            return -1;
        }
        try {
            int stock = Integer.parseInt(stockStr.trim());
            return isValidStock(stock) ? stock : -1;
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Validates cart item quantity.
     * 
     * @param quantity The quantity to validate
     * @param maxStock Maximum available stock
     * @return true if valid, false otherwise
     */
    public static boolean isValidQuantity(int quantity, int maxStock) {
        return quantity >= MIN_QUANTITY && quantity <= Math.min(MAX_QUANTITY, maxStock);
    }

    /**
     * Validates quantity string and parses it.
     * 
     * @param quantityStr The quantity string to validate
     * @param maxStock    Maximum available stock
     * @return The parsed quantity, or -1 if invalid
     */
    public static int parseAndValidateQuantity(String quantityStr, int maxStock) {
        if (quantityStr == null || quantityStr.trim().isEmpty()) {
            return -1;
        }
        try {
            int quantity = Integer.parseInt(quantityStr.trim());
            return isValidQuantity(quantity, maxStock) ? quantity : -1;
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Validates product name.
     * 
     * @param name The name to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidProductName(String name) {
        if (name == null)
            return false;
        String trimmed = name.trim();
        return trimmed.length() >= MIN_NAME_LENGTH && trimmed.length() <= MAX_NAME_LENGTH;
    }

    /**
     * Validates description text.
     * 
     * @param description The description to validate
     * @return true if valid (or null/empty), false if too long
     */
    public static boolean isValidDescription(String description) {
        if (description == null || description.isEmpty())
            return true;
        return description.length() <= MAX_DESCRIPTION_LENGTH;
    }

    /**
     * Validates review comment.
     * 
     * @param comment The comment to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidComment(String comment) {
        if (comment == null || comment.trim().isEmpty())
            return false;
        return comment.length() <= MAX_COMMENT_LENGTH;
    }

    /**
     * Validates rating value (1-5 stars).
     * 
     * @param rating The rating to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidRating(int rating) {
        return rating >= 1 && rating <= 5;
    }

    /**
     * Validates rating string and parses it.
     * 
     * @param ratingStr The rating string to validate
     * @return The parsed rating, or -1 if invalid
     */
    public static int parseAndValidateRating(String ratingStr) {
        if (ratingStr == null || ratingStr.trim().isEmpty()) {
            return -1;
        }
        try {
            int rating = Integer.parseInt(ratingStr.trim());
            return isValidRating(rating) ? rating : -1;
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Validates email format.
     * 
     * @param email The email to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty())
            return false;
        return email.matches(EMAIL_PATTERN);
    }

    /**
     * Validates phone number format (Malaysian).
     * 
     * @param phone The phone number to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty())
            return true; // Phone is optional
        String cleaned = phone.replaceAll("[\\s-]", "");
        return cleaned.matches(PHONE_PATTERN.replaceAll("[\\[\\]\\s-]", ""));
    }

    /**
     * Validates postal code format (Malaysian 5 digits).
     * 
     * @param postalCode The postal code to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPostalCode(String postalCode) {
        if (postalCode == null || postalCode.trim().isEmpty())
            return false;
        return postalCode.matches(POSTAL_CODE_PATTERN);
    }

    /**
     * Validates password strength.
     * 
     * @param password The password to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPassword(String password) {
        if (password == null)
            return false;
        return password.length() >= MIN_PASSWORD_LENGTH && password.length() <= MAX_PASSWORD_LENGTH;
    }

    /**
     * Validates username format.
     * 
     * @param username The username to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty())
            return false;
        String trimmed = username.trim();
        // Username should be 3-30 characters, alphanumeric and underscores only
        return trimmed.length() >= 3 && trimmed.length() <= 30
                && trimmed.matches("^[a-zA-Z0-9_]+$");
    }

    /**
     * Validates that a required string is not null or empty.
     * 
     * @param value The string to validate
     * @return true if not null and not empty, false otherwise
     */
    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }

    /**
     * Validates that a string is within max length.
     * 
     * @param value     The string to validate
     * @param maxLength Maximum allowed length
     * @return true if valid, false otherwise
     */
    public static boolean isWithinMaxLength(String value, int maxLength) {
        if (value == null)
            return true;
        return value.length() <= maxLength;
    }

    /**
     * Sanitizes string input to prevent XSS attacks.
     * 
     * @param input The input string to sanitize
     * @return Sanitized string
     */
    public static String sanitizeString(String input) {
        if (input == null)
            return null;
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    /**
     * Validates UUID format.
     * 
     * @param id The ID string to validate
     * @return true if valid UUID format, false otherwise
     */
    public static boolean isValidUUID(String id) {
        if (id == null || id.trim().isEmpty())
            return false;
        try {
            java.util.UUID.fromString(id);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * Validates category value.
     * 
     * @param category The category to validate
     * @return true if valid category, false otherwise
     */
    public static boolean isValidCategory(String category) {
        if (category == null || category.trim().isEmpty())
            return false;
        String[] validCategories = { "electronics", "books", "clothing", "sports", "furniture", "others" };
        for (String valid : validCategories) {
            if (valid.equalsIgnoreCase(category.trim())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Validates order status value.
     * 
     * @param status The status to validate
     * @return true if valid status, false otherwise
     */
    public static boolean isValidOrderStatus(String status) {
        if (status == null || status.trim().isEmpty())
            return false;
        String[] validStatuses = { "pending", "confirmed", "shipped", "delivered", "cancelled", "completed" };
        for (String valid : validStatuses) {
            if (valid.equalsIgnoreCase(status.trim())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Validates payment method value.
     * 
     * @param method The payment method to validate
     * @return true if valid payment method, false otherwise
     */
    public static boolean isValidPaymentMethod(String method) {
        if (method == null || method.trim().isEmpty())
            return false;
        String[] validMethods = { "card", "paypal", "maybank", "cimb", "publicbank", "tng", "grabpay" };
        for (String valid : validMethods) {
            if (valid.equalsIgnoreCase(method.trim())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Validates refund reason text.
     * 
     * @param reason The refund reason to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidRefundReason(String reason) {
        if (reason == null || reason.trim().isEmpty())
            return false;
        return reason.length() <= MAX_COMMENT_LENGTH;
    }
}
