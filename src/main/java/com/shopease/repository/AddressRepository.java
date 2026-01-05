package com.shopease.repository;

import com.shopease.entity.Address;
import java.util.List;
import java.util.Optional;

/**
 * Repository for Address entity operations.
 */
public class AddressRepository extends JsonRepository<Address> {

    private static AddressRepository instance;

    private AddressRepository() {
        super("addresses.json", Address.class);
    }

    public static synchronized AddressRepository getInstance() {
        if (instance == null) {
            instance = new AddressRepository();
        }
        return instance;
    }

    /**
     * Finds all addresses for a specific user.
     */
    public List<Address> findByUserId(String userId) {
        if (userId == null) {
            return java.util.Collections.emptyList();
        }
        return findByPredicate(address -> userId.equals(address.getUserId()));
    }

    /**
     * Finds the default address for a user.
     */
    public Optional<Address> findDefaultByUserId(String userId) {
        if (userId == null) {
            return Optional.empty();
        }
        return findByUserId(userId).stream()
                .filter(Address::isDefault)
                .findFirst();
    }

    /**
     * Sets an address as the default for a user (unsets other defaults).
     */
    public void setAsDefault(String addressId, String userId) {
        List<Address> userAddresses = findByUserId(userId);
        for (Address address : userAddresses) {
            if (address.getId().equals(addressId)) {
                address.setDefault(true);
            } else {
                address.setDefault(false);
            }
            save(address);
        }
    }

    /**
     * Counts addresses for a specific user.
     */
    public int countByUserId(String userId) {
        return findByUserId(userId).size();
    }

    /**
     * Deletes all addresses for a specific user.
     */
    public int deleteByUserId(String userId) {
        return deleteByPredicate(address -> userId.equals(address.getUserId()));
    }
}
