package com.beauty.util;

import com.beauty.model.CartItem;
import com.beauty.model.Service;
import com.beauty.model.User;
import com.beauty.service.ServiceService;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

/**
 * Utility class for storing and retrieving cart data from files
 */
public class CartStorage {
    private static final String STORAGE_DIR = "cart_data";
    private static final String FILE_EXTENSION = ".cart";
    private static ServiceService serviceService = new ServiceService();

    /**
     * Initialize the storage directory
     */
    static {
        try {
            Path storagePath = Paths.get(getStorageDirectory());
            if (!Files.exists(storagePath)) {
                Files.createDirectories(storagePath);
            }
        } catch (IOException e) {
            System.err.println("Failed to create cart storage directory: " + e.getMessage());
        }
    }

    /**
     * Get the absolute path to the storage directory
     * @return Storage directory path
     */
    private static String getStorageDirectory() {
        // Get the application's root directory
        String rootPath = System.getProperty("catalina.base");
        if (rootPath == null) {
            rootPath = System.getProperty("user.dir");
        }
        return rootPath + File.separator + STORAGE_DIR;
    }

    /**
     * Get the cart file path for a specific user
     * @param userId User ID
     * @return File path
     */
    private static String getCartFilePath(String userId) {
        // Sanitize userId to prevent path traversal attacks
        String sanitizedUserId = userId.replaceAll("[^a-zA-Z0-9_\\-\\.]", "_");
        return getStorageDirectory() + File.separator + sanitizedUserId + FILE_EXTENSION;
    }

    /**
     * Save cart items to a file
     * @param userId User ID
     * @param cartItems List of cart items
     * @return true if successful, false otherwise
     */
    public static boolean saveCart(String userId, List<CartItem> cartItems) {
        if (userId == null || userId.isEmpty()) {
            return false;
        }

        try (FileOutputStream fos = new FileOutputStream(getCartFilePath(userId));
             ObjectOutputStream oos = new ObjectOutputStream(fos)) {

            // Convert CartItem objects to serializable format
            List<SerializableCartItem> serializableItems = new ArrayList<>();
            for (CartItem item : cartItems) {
                serializableItems.add(new SerializableCartItem(item));
            }

            oos.writeObject(serializableItems);
            return true;
        } catch (IOException e) {
            System.err.println("Failed to save cart: " + e.getMessage());
            return false;
        }
    }

    /**
     * Load cart items from a file
     * @param userId User ID
     * @return List of cart items or empty list if file doesn't exist
     */
    @SuppressWarnings("unchecked")
    public static List<CartItem> loadCart(String userId) {
        if (userId == null || userId.isEmpty()) {
            return new ArrayList<>();
        }

        String filePath = getCartFilePath(userId);
        File cartFile = new File(filePath);

        if (!cartFile.exists()) {
            return new ArrayList<>();
        }

        try (FileInputStream fis = new FileInputStream(filePath);
             ObjectInputStream ois = new ObjectInputStream(fis)) {

            List<SerializableCartItem> serializableItems = (List<SerializableCartItem>) ois.readObject();
            List<CartItem> cartItems = new ArrayList<>();

            // Convert serializable items back to CartItem objects
            for (SerializableCartItem serItem : serializableItems) {
                CartItem item = serItem.toCartItem();
                if (item != null) {
                    cartItems.add(item);
                }
            }

            return cartItems;
        } catch (IOException | ClassNotFoundException e) {
            System.err.println("Failed to load cart: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    /**
     * Delete a user's cart file
     * @param userId User ID
     * @return true if successful, false otherwise
     */
    public static boolean deleteCart(String userId) {
        if (userId == null || userId.isEmpty()) {
            return false;
        }

        File cartFile = new File(getCartFilePath(userId));
        return !cartFile.exists() || cartFile.delete();
    }

    /**
     * Serializable version of CartItem for file storage
     */
    private static class SerializableCartItem implements Serializable {
        private static final long serialVersionUID = 1L;

        private String serviceId;
        private int quantity;
        private Map<String, String> options;
        private String specialInstructions;

        public SerializableCartItem(CartItem item) {
            this.serviceId = item.getService().getId();
            this.quantity = item.getQuantity();
            this.options = new HashMap<>(item.getOptions());
            this.specialInstructions = item.getSpecialInstructions();
        }

        public CartItem toCartItem() {
            Service service = serviceService.getServiceById(serviceId);
            if (service == null) {
                return null;
            }

            return new CartItem(service, quantity, options, specialInstructions);
        }
    }
}
