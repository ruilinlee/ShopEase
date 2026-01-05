package com.shopease.repository;

import com.shopease.entity.User;
import java.util.Optional;

/**
 * Repository for User entities with specialized query methods.
 */
public class UserRepository extends JsonRepository<User> {
    
    private static UserRepository instance;
    
    public UserRepository() {
        super("users.json", User.class);
    }
    
    /**
     * Gets the singleton instance.
     */
    public static synchronized UserRepository getInstance() {
        if (instance == null) {
            instance = new UserRepository();
        }
        return instance;
    }
    
    /**
     * Finds a user by username.
     * 
     * @param username The username to search for
     * @return Optional containing the user if found
     */
    public Optional<User> findByUsername(String username) {
        return findByPredicate(user -> 
            user.getUsername() != null && user.getUsername().equals(username)
        ).stream().findFirst();
    }
    
    /**
     * Finds a user by email.
     * 
     * @param email The email to search for
     * @return Optional containing the user if found
     */
    public Optional<User> findByEmail(String email) {
        return findByPredicate(user -> 
            user.getEmail() != null && user.getEmail().equals(email)
        ).stream().findFirst();
    }
    
    /**
     * Validates user credentials.
     * 
     * @param username The username
     * @param password The password
     * @return Optional containing the user if credentials are valid
     */
    public Optional<User> authenticate(String username, String password) {
        return findByPredicate(user -> 
            user.getUsername() != null && 
            user.getUsername().equals(username) &&
            user.getPassword() != null &&
            user.getPassword().equals(password)
        ).stream().findFirst();
    }
    
    /**
     * Checks if a username is already taken.
     * 
     * @param username The username to check
     * @return true if username exists
     */
    public boolean usernameExists(String username) {
        return findByUsername(username).isPresent();
    }
    
    /**
     * Checks if an email is already registered.
     * 
     * @param email The email to check
     * @return true if email exists
     */
    public boolean emailExists(String email) {
        return findByEmail(email).isPresent();
    }
}
