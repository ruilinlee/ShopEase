package com.shopease.entity;

import java.util.UUID;

/**
 * Review entity for product reviews/comments.
 */
public class Review {
    private String id;
    private String productId;
    private String userId;
    private String username;
    private int rating; // 1-5 stars
    private String comment;
    private long createdAt;

    public Review() {
        this.id = UUID.randomUUID().toString();
        this.createdAt = System.currentTimeMillis();
        this.rating = 5;
    }

    public Review(String productId, String userId, String username, int rating, String comment) {
        this();
        this.productId = productId;
        this.userId = userId;
        this.username = username;
        this.rating = Math.max(1, Math.min(5, rating)); // Clamp between 1-5
        this.comment = comment;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = Math.max(1, Math.min(5, rating));
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(long createdAt) {
        this.createdAt = createdAt;
    }
}
