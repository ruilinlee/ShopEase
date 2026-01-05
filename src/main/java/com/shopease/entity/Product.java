package com.shopease.entity;

import java.util.UUID;

/**
 * Product entity representing a second-hand item listing.
 */
public class Product {
    private String id;
    private String name;
    private String description;
    private double price;
    private String category;
    private String imageUrl;
    private String sellerId;
    private String sellerName;
    private String status; // "available", "sold" - sale status only
    private String approvalStatus; // "pending", "approved", "rejected" - admin approval status
    private int stock;
    private String detailedAddress;
    private String shippingState;
    private long createdAt;

    public Product() {
        this.id = UUID.randomUUID().toString();
        this.createdAt = System.currentTimeMillis();
        this.status = "available";
        this.approvalStatus = "pending"; // New products require admin approval
        this.stock = 1;
    }

    public Product(String name, String description, double price, String category, String imageUrl, String sellerId) {
        this();
        this.name = name;
        this.description = description;
        this.price = price;
        this.category = category;
        this.imageUrl = imageUrl;
        this.sellerId = sellerId;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getSellerId() {
        return sellerId;
    }

    public void setSellerId(String sellerId) {
        this.sellerId = sellerId;
    }

    public String getSellerName() {
        return sellerName;
    }

    public void setSellerName(String sellerName) {
        this.sellerName = sellerName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(long createdAt) {
        this.createdAt = createdAt;
    }

    public String getDetailedAddress() {
        return detailedAddress;
    }

    public void setDetailedAddress(String detailedAddress) {
        this.detailedAddress = detailedAddress;
    }

    public String getShippingState() {
        return shippingState;
    }

    public void setShippingState(String shippingState) {
        this.shippingState = shippingState;
    }

    public String getShippingLocation() {
        if (detailedAddress != null && !detailedAddress.isEmpty() && shippingState != null && !shippingState.isEmpty()) {
            return detailedAddress + ", " + shippingState;
        } else if (detailedAddress != null && !detailedAddress.isEmpty()) {
            return detailedAddress;
        } else if (shippingState != null && !shippingState.isEmpty()) {
            return shippingState;
        }
        return null;
    }

    // Approval status getter/setter
    public String getApprovalStatus() {
        // For backward compatibility: if approvalStatus is null, derive from old status field
        if (approvalStatus == null) {
            if ("pending".equals(status) || "rejected".equals(status) || "approved".equals(status)) {
                return status;
            }
            return "approved"; // Old products without approvalStatus are considered approved
        }
        return approvalStatus;
    }

    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    /**
     * Checks if product is approved by admin.
     */
    public boolean isApproved() {
        return "approved".equals(getApprovalStatus());
    }

    /**
     * Checks if product is available for sale (approved and has stock).
     */
    public boolean isAvailable() {
        return "available".equals(this.status) && isApproved();
    }

    /**
     * Checks if product is pending admin approval.
     */
    public boolean isPending() {
        return "pending".equals(getApprovalStatus());
    }

    /**
     * Checks if product approval was rejected.
     */
    public boolean isRejected() {
        return "rejected".equals(getApprovalStatus());
    }

    /**
     * Checks if product is sold out.
     */
    public boolean isSold() {
        return "sold".equals(this.status);
    }

    /**
     * Checks if product can be purchased (approved, available status, has stock).
     */
    public boolean canBePurchased() {
        return isApproved() && "available".equals(this.status) && this.stock > 0;
    }
}
