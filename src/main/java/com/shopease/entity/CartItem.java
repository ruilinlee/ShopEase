package com.shopease.entity;

import java.util.UUID;

/**
 * CartItem entity representing a product in user's shopping cart.
 */
public class CartItem {
    private String id;
    private String userId;
    private String productId;
    private String productName;
    private double price;
    private int quantity;
    private String imageUrl;

    public CartItem() {
        this.id = UUID.randomUUID().toString();
        this.quantity = 1;
    }

    public CartItem(String userId, String productId, String productName, double price, String imageUrl) {
        this();
        this.userId = userId;
        this.productId = productId;
        this.productName = productName;
        this.price = price;
        this.imageUrl = imageUrl;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public double getSubtotal() {
        return price * quantity;
    }

    public void incrementQuantity() {
        this.quantity++;
    }

    public void decrementQuantity() {
        if (this.quantity > 1) {
            this.quantity--;
        }
    }
}
