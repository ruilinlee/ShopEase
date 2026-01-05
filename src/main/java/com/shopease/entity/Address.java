package com.shopease.entity;

import java.util.UUID;

/**
 * Address entity for user shipping addresses.
 */
public class Address {
    private String id;
    private String userId;
    private String recipientName;
    private String phoneNumber;
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String state;
    private String postalCode;
    private String country;
    private boolean isDefault;
    private long createdAt;

    public Address() {
        this.id = UUID.randomUUID().toString();
        this.createdAt = System.currentTimeMillis();
        this.country = "Malaysia";
        this.isDefault = false;
    }

    public Address(String userId, String recipientName, String phoneNumber,
            String addressLine1, String city, String state, String postalCode) {
        this();
        this.userId = userId;
        this.recipientName = recipientName;
        this.phoneNumber = phoneNumber;
        this.addressLine1 = addressLine1;
        this.city = city;
        this.state = state;
        this.postalCode = postalCode;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAddressLine1() {
        return addressLine1;
    }

    public void setAddressLine1(String addressLine1) {
        this.addressLine1 = addressLine1;
    }

    public String getAddressLine2() {
        return addressLine2;
    }

    public void setAddressLine2(String addressLine2) {
        this.addressLine2 = addressLine2;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(long createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Returns fully formatted address string.
     */
    public String getFullAddress() {
        StringBuilder sb = new StringBuilder();

        if (addressLine1 != null && !addressLine1.isEmpty()) {
            sb.append(addressLine1);
        }
        if (addressLine2 != null && !addressLine2.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(addressLine2);
        }
        if (postalCode != null && !postalCode.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(postalCode);
        }
        if (city != null && !city.isEmpty()) {
            if (sb.length() > 0) sb.append(" ");
            sb.append(city);
        }
        if (state != null && !state.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(state);
        }
        if (country != null && !country.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(country);
        }

        return sb.toString();
    }
}
