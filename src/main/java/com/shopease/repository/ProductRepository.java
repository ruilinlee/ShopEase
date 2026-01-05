package com.shopease.repository;

import com.shopease.entity.Product;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Repository for Product entities with specialized query methods.
 */
public class ProductRepository extends JsonRepository<Product> {
    
    private static ProductRepository instance;
    
    public ProductRepository() {
        super("products.json", Product.class);
    }
    
    /**
     * Gets the singleton instance.
     */
    public static synchronized ProductRepository getInstance() {
        if (instance == null) {
            instance = new ProductRepository();
        }
        return instance;
    }
    
    /**
     * Finds all approved products.
     *
     * @return List of approved products
     */
    public List<Product> findApproved() {
        return findByPredicate(p -> p.isApproved() || p.isAvailable());
    }

    /**
     * Finds all available products.
     *
     * @return List of available products
     */
    public List<Product> findAvailable() {
        return findByPredicate(Product::isAvailable);
    }
    
    /**
     * Finds all pending products (awaiting admin approval).
     * 
     * @return List of pending products
     */
    public List<Product> findPending() {
        return findByPredicate(Product::isPending);
    }
    
    /**
     * Finds products by category.
     *
     * @param category The category to filter by
     * @return List of products in the category
     */
    public List<Product> findByCategory(String category) {
        String normalizedCategory = normalizeCategory(category);
        return findByPredicate(product ->
            !normalizedCategory.isEmpty() &&
            normalizedCategory.equals(normalizeCategory(product.getCategory())) &&
            (product.isApproved() || product.isAvailable())
        );
    }

    private String normalizeCategory(String category) {
        if (category == null) {
            return "";
        }
        String normalized = category.trim().toLowerCase();
        if ("other".equals(normalized)) {
            return "others";
        }
        return normalized;
    }
    
    /**
     * Finds products by seller ID.
     * 
     * @param sellerId The seller's user ID
     * @return List of products from that seller
     */
    public List<Product> findBySellerId(String sellerId) {
        return findByPredicate(product -> 
            product.getSellerId() != null && product.getSellerId().equals(sellerId)
        );
    }
    
    /**
     * Searches products by name or description keyword.
     *
     * @param keyword The search keyword
     * @return List of matching products
     */
    public List<Product> search(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return findApproved();
        }

        String lowerKeyword = keyword.toLowerCase().trim();
        return findByPredicate(product ->
            (product.isApproved() || product.isAvailable()) && (
                (product.getName() != null && product.getName().toLowerCase().contains(lowerKeyword)) ||
                (product.getDescription() != null && product.getDescription().toLowerCase().contains(lowerKeyword))
            )
        );
    }
    
    /**
     * Updates a product's sale status (available, sold).
     * 
     * @param productId The product ID
     * @param status The new sale status
     * @return true if updated successfully
     */
    public boolean updateStatus(String productId, String status) {
        return findById(productId).map(product -> {
            // Handle legacy status values by routing to approvalStatus
            if ("approved".equals(status) || "pending".equals(status) || "rejected".equals(status)) {
                product.setApprovalStatus(status);
            } else {
                product.setStatus(status);
            }
            save(product);
            return true;
        }).orElse(false);
    }
    
    /**
     * Updates a product's approval status (pending, approved, rejected).
     * 
     * @param productId The product ID
     * @param approvalStatus The new approval status
     * @return true if updated successfully
     */
    public boolean updateApprovalStatus(String productId, String approvalStatus) {
        return findById(productId).map(product -> {
            product.setApprovalStatus(approvalStatus);
            save(product);
            return true;
        }).orElse(false);
    }
    
    /**
     * Marks a product as sold.
     * 
     * @param productId The product ID
     * @return true if updated successfully
     */
    public boolean markAsSold(String productId) {
        return updateStatus(productId, "sold");
    }
    
    /**
     * Approves a pending product.
     * 
     * @param productId The product ID
     * @return true if approved successfully
     */
    public boolean approve(String productId) {
        return updateApprovalStatus(productId, "approved");
    }
    
    /**
     * Rejects a pending product.
     * 
     * @param productId The product ID
     * @return true if rejected successfully
     */
    public boolean reject(String productId) {
        return updateApprovalStatus(productId, "rejected");
    }
}
