package com.shopease.repository;

import com.shopease.entity.Order;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Repository for Order entities with specialized query methods.
 */
public class OrderRepository extends JsonRepository<Order> {
    
    private static OrderRepository instance;
    
    public OrderRepository() {
        super("orders.json", Order.class);
    }
    
    /**
     * Gets the singleton instance.
     */
    public static synchronized OrderRepository getInstance() {
        if (instance == null) {
            instance = new OrderRepository();
        }
        return instance;
    }
    
    /**
     * Finds all orders for a specific buyer.
     * 
     * @param buyerId The buyer's user ID
     * @return List of orders for that buyer, sorted by creation date descending
     */
    public List<Order> findByBuyerId(String buyerId) {
        return findByPredicate(order -> 
            order.getBuyerId() != null && order.getBuyerId().equals(buyerId)
        ).stream()
         .sorted(Comparator.comparingLong(Order::getCreatedAt).reversed())
         .collect(Collectors.toList());
    }
    
    /**
     * Finds orders by status.
     * 
     * @param status The status to filter by
     * @return List of orders with that status
     */
    public List<Order> findByStatus(String status) {
        return findByPredicate(order -> 
            order.getStatus() != null && order.getStatus().equals(status)
        );
    }
    
    /**
     * Gets all orders sorted by creation date descending.
     * 
     * @return Sorted list of all orders
     */
    public List<Order> findAllSorted() {
        return findAll().stream()
                .sorted(Comparator.comparingLong(Order::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }
    
    /**
     * Updates an order's status.
     * 
     * @param orderId The order ID
     * @param status The new status
     * @return true if updated successfully
     */
    public boolean updateStatus(String orderId, String status) {
        return findById(orderId).map(order -> {
            order.setStatus(status);
            save(order);
            return true;
        }).orElse(false);
    }
}
