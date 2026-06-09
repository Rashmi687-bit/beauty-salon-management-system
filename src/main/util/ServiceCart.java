package com.beauty.util;

import com.beauty.model.CartItem;
import com.beauty.model.Service;
import com.beauty.model.User;

import java.util.LinkedList;
import java.util.Queue;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

/**
 * A utility class that implements a cart for services with file-based persistence
 */
public class ServiceCart {
    private static final ConcurrentHashMap<String, ServiceCart> instances = new ConcurrentHashMap<>();
    private Queue<CartItem> cartItems;
    private String userId;
    private boolean dirty = false; // Flag to track if cart has unsaved changes

    /**
     * Private constructor for singleton pattern
     * @param userId User ID for cart persistence
     */
    private ServiceCart(String userId) {
        this.userId = userId;
        this.cartItems = new LinkedList<>();
        loadFromFile();
    }

    /**
     * Get the singleton instance of ServiceCart for a specific user
     * @param user User object
     * @return ServiceCart instance
     */
    public static synchronized ServiceCart getInstance(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User cannot be null");
        }

        String userId = user.getEmail();
        return getInstance(userId);
    }

    /**
     * Get the singleton instance of ServiceCart for a specific user ID
     * @param userId User ID
     * @return ServiceCart instance
     */
    public static synchronized ServiceCart getInstance(String userId) {
        if (userId == null || userId.isEmpty()) {
            throw new IllegalArgumentException("User ID cannot be null or empty");
        }

        return instances.computeIfAbsent(userId, id -> new ServiceCart(id));
    }

    /**
     * Get the default instance (for backward compatibility)
     * @return ServiceCart instance with default user ID
     */
    public static synchronized ServiceCart getInstance() {
        return getInstance("default");
    }

    /**
     * Load cart items from file
     */
    private void loadFromFile() {
        List<CartItem> loadedItems = CartStorage.loadCart(userId);
        cartItems.clear();
        cartItems.addAll(loadedItems);
        dirty = false;
    }

    /**
     * Save cart items to file
     */
    private void saveToFile() {
        if (dirty) {
            CartStorage.saveCart(userId, getAllItems());
            dirty = false;
        }
    }

    /**
     * Add a service to the cart
     * @param service Service to add
     * @return The added cart item
     */
    public CartItem addService(Service service) {
        CartItem item = new CartItem(service);
        cartItems.add(item);
        dirty = true;
        saveToFile();
        return item;
    }

    /**
     * Add a service to the cart with quantity
     * @param service Service to add
     * @param quantity Quantity
     * @return The added cart item
     */
    public CartItem addService(Service service, int quantity) {
        CartItem item = new CartItem(service, quantity);
        cartItems.add(item);
        dirty = true;
        saveToFile();
        return item;
    }

    /**
     * Add a service to the cart with quantity and options
     * @param service Service to add
     * @param quantity Quantity
     * @param options Map of options
     * @param specialInstructions Special instructions
     * @return The added cart item
     */
    public CartItem addService(Service service, int quantity, Map<String, String> options, String specialInstructions) {
        CartItem item = new CartItem(service, quantity, options, specialInstructions);
        cartItems.add(item);
        dirty = true;
        saveToFile();
        return item;
    }

    /**
     * Remove and return the next cart item from the queue
     * @return The next cart item or null if queue is empty
     */
    public CartItem removeNext() {
        CartItem item = cartItems.poll();
        if (item != null) {
            dirty = true;
            saveToFile();
        }
        return item;
    }

    /**
     * View the next cart item without removing it
     * @return The next cart item or null if queue is empty
     */
    public CartItem peekNext() {
        return cartItems.peek();
    }

    /**
     * Check if the cart is empty
     * @return true if cart is empty, false otherwise
     */
    public boolean isEmpty() {
        return cartItems.isEmpty();
    }

    /**
     * Get the number of items in the cart
     * @return Number of items in the cart
     */
    public int size() {
        return cartItems.size();
    }

    /**
     * Get the total quantity of all items in the cart
     * @return Total quantity
     */
    public int getTotalQuantity() {
        int total = 0;
        for (CartItem item : cartItems) {
            total += item.getQuantity();
        }
        return total;
    }

    /**
     * Clear all items from the cart
     */
    public void clear() {
        cartItems.clear();
        dirty = true;
        saveToFile();
    }

    /**
     * Get all items in the cart as a list (without removing them)
     * @return List of all cart items
     */
    public List<CartItem> getAllItems() {
        return new ArrayList<>(cartItems);
    }

    /**
     * Check if a service with the given ID exists in the cart
     * @param serviceId Service ID to check
     * @return true if service exists in cart, false otherwise
     */
    public boolean containsService(String serviceId) {
        for (CartItem item : cartItems) {
            if (item.hasServiceId(serviceId)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Get a cart item by service ID
     * @param serviceId Service ID
     * @return CartItem if found, null otherwise
     */
    public CartItem getItemByServiceId(String serviceId) {
        for (CartItem item : cartItems) {
            if (item.hasServiceId(serviceId)) {
                return item;
            }
        }
        return null;
    }

    /**
     * Update the quantity of a cart item
     * @param serviceId Service ID
     * @param quantity New quantity
     * @return true if updated, false if not found
     */
    public boolean updateQuantity(String serviceId, int quantity) {
        CartItem item = getItemByServiceId(serviceId);
        if (item != null) {
            item.setQuantity(quantity);
            dirty = true;
            saveToFile();
            return true;
        }
        return false;
    }

    /**
     * Update the options of a cart item
     * @param serviceId Service ID
     * @param options New options
     * @return true if updated, false if not found
     */
    public boolean updateOptions(String serviceId, Map<String, String> options) {
        CartItem item = getItemByServiceId(serviceId);
        if (item != null) {
            item.setOptions(options);
            dirty = true;
            saveToFile();
            return true;
        }
        return false;
    }

    /**
     * Update the special instructions of a cart item
     * @param serviceId Service ID
     * @param specialInstructions New special instructions
     * @return true if updated, false if not found
     */
    public boolean updateSpecialInstructions(String serviceId, String specialInstructions) {
        CartItem item = getItemByServiceId(serviceId);
        if (item != null) {
            item.setSpecialInstructions(specialInstructions);
            dirty = true;
            saveToFile();
            return true;
        }
        return false;
    }

    /**
     * Remove a specific cart item by service ID
     * @param serviceId Service ID to remove
     * @return true if item was removed, false if not found
     */
    public boolean removeService(String serviceId) {
        boolean removed = cartItems.removeIf(item -> item.hasServiceId(serviceId));
        if (removed) {
            dirty = true;
            saveToFile();
        }
        return removed;
    }

    /**
     * Get the total price of all items in the cart
     * @return Total price
     */
    public double getTotalPrice() {
        double total = 0;
        for (CartItem item : cartItems) {
            total += item.getTotalPrice();
        }
        return total;
    }

    /**
     * Get the total duration of all items in the cart
     * @return Total duration in minutes
     */
    public int getTotalDuration() {
        int total = 0;
        for (CartItem item : cartItems) {
            total += item.getTotalDuration();
        }
        return total;
    }
}
