package com.shopease.repository;

import com.shopease.entity.Review;
import java.util.List;
import java.util.Comparator;
import java.util.stream.Collectors;

/**
 * Repository for Review entity operations.
 */
public class ReviewRepository extends JsonRepository<Review> {

    private static ReviewRepository instance;

    private ReviewRepository() {
        super("reviews.json", Review.class);
    }

    public static synchronized ReviewRepository getInstance() {
        if (instance == null) {
            instance = new ReviewRepository();
        }
        return instance;
    }

    /**
     * Finds all reviews for a specific product, sorted by newest first.
     */
    public List<Review> findByProductId(String productId) {
        return findByPredicate(review -> productId.equals(review.getProductId()))
                .stream()
                .sorted(Comparator.comparingLong(Review::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }

    /**
     * Finds all reviews by a specific user.
     */
    public List<Review> findByUserId(String userId) {
        return findByPredicate(review -> userId.equals(review.getUserId()));
    }

    /**
     * Checks if a user has already reviewed a product.
     */
    public boolean hasUserReviewedProduct(String userId, String productId) {
        return findByPredicate(review -> userId.equals(review.getUserId()) &&
                productId.equals(review.getProductId()))
                .size() > 0;
    }

    /**
     * Gets the average rating for a product.
     */
    public double getAverageRating(String productId) {
        List<Review> reviews = findByProductId(productId);
        if (reviews.isEmpty()) {
            return 0.0;
        }
        double sum = reviews.stream().mapToInt(Review::getRating).sum();
        return sum / reviews.size();
    }

    /**
     * Gets the review count for a product.
     */
    public int getReviewCount(String productId) {
        return findByProductId(productId).size();
    }

    /**
     * Deletes all reviews for a product.
     */
    public int deleteByProductId(String productId) {
        return deleteByPredicate(review -> productId.equals(review.getProductId()));
    }

    /**
     * Deletes all reviews by a user.
     */
    public int deleteByUserId(String userId) {
        return deleteByPredicate(review -> userId.equals(review.getUserId()));
    }
}
