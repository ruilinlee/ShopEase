package com.shopease.entity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

/**
 * Order entity representing a completed purchase.
 */
public class Order {
    private String id;
    private String buyerId;
    private String buyerName;
    private String userId; // Alias for buyerId for compatibility
    private String username; // Alias for buyerName for compatibility
    private List<OrderItem> items;
    private double totalAmount;
    private String status; // "pending", "confirmed", "shipped", "delivered", "cancelled"
    private long createdAt;

    // Payment and shipping fields
    private String paymentMethod;
    private String paymentStatus; // "pending", "paid", "refunded"
    private String shippingAddressId;
    private String shippingAddress; // Denormalized full address string

    // Seller field (for seller-side order management)
    private String sellerId;

    // Refund fields
    private String refundStatus; // null, "requested", "approved", "rejected", "refunded"
    private String refundReason;
    private long refundRequestedAt;
    private long refundProcessedAt;

    public Order() {
        this.id = UUID.randomUUID().toString();
        this.createdAt = System.currentTimeMillis();
        this.status = "pending";
        this.paymentStatus = "pending";
        this.items = new ArrayList<>();
    }

    public Order(String buyerId, List<OrderItem> items, double totalAmount) {
        this();
        this.buyerId = buyerId;
        this.userId = buyerId;
        this.items = items != null ? items : new ArrayList<>();
        this.totalAmount = totalAmount;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getBuyerId() {
        return buyerId;
    }

    public void setBuyerId(String buyerId) {
        this.buyerId = buyerId;
        this.userId = buyerId;
    }

    public String getBuyerName() {
        return buyerName;
    }

    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
        this.username = buyerName;
    }

    public String getUserId() {
        return userId != null ? userId : buyerId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
        if (this.buyerId == null)
            this.buyerId = userId;
    }

    public String getUsername() {
        return username != null ? username : buyerName;
    }

    public void setUsername(String username) {
        this.username = username;
        if (this.buyerName == null)
            this.buyerName = username;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(long createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Gets the order date as a formatted string.
     */
    public String getOrderDate() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(new Date(createdAt));
    }

    public void addItem(OrderItem item) {
        this.items.add(item);
        calculateTotal();
    }

    public void calculateTotal() {
        this.totalAmount = items.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();
    }

    // Payment and shipping getters/setters
    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getShippingAddressId() {
        return shippingAddressId;
    }

    public void setShippingAddressId(String shippingAddressId) {
        this.shippingAddressId = shippingAddressId;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    // Seller getter/setter
    public String getSellerId() {
        return sellerId;
    }

    public void setSellerId(String sellerId) {
        this.sellerId = sellerId;
    }

    // Refund getters/setters
    public String getRefundStatus() {
        return refundStatus;
    }

    public void setRefundStatus(String refundStatus) {
        this.refundStatus = refundStatus;
    }

    public String getRefundReason() {
        return refundReason;
    }

    public void setRefundReason(String refundReason) {
        this.refundReason = refundReason;
    }

    public long getRefundRequestedAt() {
        return refundRequestedAt;
    }

    public void setRefundRequestedAt(long refundRequestedAt) {
        this.refundRequestedAt = refundRequestedAt;
    }

    public long getRefundProcessedAt() {
        return refundProcessedAt;
    }

    public void setRefundProcessedAt(long refundProcessedAt) {
        this.refundProcessedAt = refundProcessedAt;
    }

    public boolean isRefundable() {
        // Must be paid and not already refunded/requested
        return refundStatus == null &&
                "paid".equals(paymentStatus) &&
                ("pending".equals(status) || "confirmed".equals(status) ||
                        "shipped".equals(status) || "delivered".equals(status));
    }

    public boolean hasRefundRequest() {
        return "requested".equals(refundStatus);
    }

    /**
     * Checks if refund was requested (alias for hasRefundRequest for Admin use).
     */
    public boolean isRefundRequested() {
        return "requested".equals(refundStatus);
    }

    /**
     * Sets whether refund was approved.
     */
    public void setRefundApproved(boolean approved) {
        if (approved) {
            this.refundStatus = "refunded";
        }
    }

    /**
     * Sets refund requested status (for compatibility).
     */
    public void setRefundRequested(boolean requested) {
        if (requested) {
            this.refundStatus = "requested";
        } else {
            this.refundStatus = null;
        }
    }

    /**
     * Nested class for order line items.
     */
    public static class OrderItem {
        private String productId;
        private String productName;
        private double price;
        private int quantity;
        private String imageUrl;

        public OrderItem() {
        }

        public OrderItem(String productId, String productName, double price, int quantity, String imageUrl) {
            this.productId = productId;
            this.productName = productName;
            this.price = price;
            this.quantity = quantity;
            this.imageUrl = imageUrl;
        }

        // Getters and Setters
        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public double getPrice() {
            return price;
        }

        public void setPrice(double price) {
            this.price = price;
        }

        public int getQuantity() {
            return quantity;
        }

        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }

        public String getImageUrl() {
            return imageUrl;
        }

        public void setImageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
        }

        public double getSubtotal() {
            return price * quantity;
        }
    }
}
