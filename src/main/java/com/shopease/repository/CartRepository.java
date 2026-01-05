package com.shopease.repository;

import com.shopease.entity.CartItem;
import java.util.List;
import java.util.Optional;

/**
 * Repository for CartItem entities with specialized query methods.
 */
public class CartRepository extends JsonRepository<CartItem> {
    
    private static CartRepository instance;
    
    public CartRepository() {
        super("carts.json", CartItem.class);
    }
    
    /**
     * Gets the singleton instance.
     */
    public static synchronized CartRepository getInstance() {
        if (instance == null) {
            instance = new CartRepository();
        }
        return instance;
    }
    
    /**
     * Finds all cart items for a specific user.
     * 
     * @param userId The user's ID
     * @return List of cart items for that user
     */
    public List<CartItem> findByUserId(String userId) {
        return findByPredicate(item -> 
            item.getUserId() != null && item.getUserId().equals(userId)
        );
    }
    
    /**
     * Finds a specific cart item by user and product.
     * 
     * @param userId The user's ID
     * @param productId The product's ID
     * @return Optional containing the cart item if found
     */
    public Optional<CartItem> findByUserAndProduct(String userId, String productId) {
        return findByPredicate(item -> 
            item.getUserId() != null && item.getUserId().equals(userId) &&
            item.getProductId() != null && item.getProductId().equals(productId)
        ).stream().findFirst();
    }
    
    /**
     * Clears all cart items for a user.
     * 
     * @param userId The user's ID
     * @return Number of items removed
     */
    public int clearUserCart(String userId) {
        return deleteByPredicate(item -> 
            item.getUserId() != null && item.getUserId().equals(userId)
        );
    }
    
    /**
     * Removes a specific product from a user's cart.
     * 
     * @param userId The user's ID
     * @param productId The product's ID
     * @return true if removed successfully
     */
    public boolean removeFromCart(String userId, String productId) {
        return deleteByPredicate(item -> 
            item.getUserId() != null && item.getUserId().equals(userId) &&
            item.getProductId() != null && item.getProductId().equals(productId)
        ) > 0;
    }
    
    /**
     * Calculates the total price for a user's cart.
     * 
     * @param userId The user's ID
     * @return The total price
     */
    public double calculateTotal(String userId) {
        return findByUserId(userId).stream()
                .mapToDouble(CartItem::getSubtotal)
                .sum();
    }
    
    /**
     * Gets the total number of items in a user's cart.
     * 
     * @param userId The user's ID
     * @return The total item count
     */
    public int getItemCount(String userId) {
        return findByUserId(userId).stream()
                .mapToInt(CartItem::getQuantity)
                .sum();
    }
}
