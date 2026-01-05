package com.shopease.repository;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.io.*;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * Generic JSON-based repository for CRUD operations.
 * Provides thread-safe file I/O using ReentrantReadWriteLock.
 * 
 * @param <T> The entity type this repository manages
 */
public class JsonRepository<T> {
    
    private final String filePath;
    private final Class<T> entityClass;
    private final Type listType;
    private final ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
    private final Gson gson;
    
    // Cache for better performance
    private List<T> cache = null;
    private long lastModified = 0;
    
    /**
     * Creates a new JsonRepository for the specified entity type.
     * 
     * @param fileName The JSON file name (e.g., "users.json")
     * @param entityClass The class of the entity
     */
    public JsonRepository(String fileName, Class<T> entityClass) {
        this.entityClass = entityClass;
        this.listType = TypeToken.getParameterized(ArrayList.class, entityClass).getType();
        this.gson = new GsonBuilder()
                .setPrettyPrinting()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                .create();
        
        // Determine data directory path
        String dataDir = getDataDirectory();
        this.filePath = dataDir + File.separator + fileName;
        
        // Ensure file exists
        ensureFileExists();
    }
    
    /**
     * Gets the data directory path, checking multiple possible locations.
     */
    private String getDataDirectory() {
        // Check system property first (highest priority)
        String sysProperty = System.getProperty("shopease.data.dir");
        if (sysProperty != null && !sysProperty.isEmpty()) {
            File dir = new File(sysProperty);
            if (dir.exists() && dir.isDirectory()) {
                return dir.getAbsolutePath();
            }
        }

        // Try CATALINA_HOME/data for Tomcat deployment
        String catalinaHome = System.getProperty("catalina.home");
        if (catalinaHome != null) {
            File tomcatData = new File(catalinaHome, "data");
            if (tomcatData.exists() && tomcatData.isDirectory()) {
                return tomcatData.getAbsolutePath();
            }
        }

        // Try relative paths for development
        String[] possiblePaths = {
            "data",
            "src/main/webapp/WEB-INF/data",
            "../data"
        };

        for (String path : possiblePaths) {
            File dir = new File(path);
            if (dir.exists() && dir.isDirectory()) {
                return dir.getAbsolutePath();
            }
        }

        // Default: create data directory in current working directory
        File dataDir = new File("data");
        if (!dataDir.exists()) {
            dataDir.mkdirs();
        }
        return dataDir.getAbsolutePath();
    }
    
    /**
     * Ensures the JSON file exists, creating it with empty array if not.
     */
    private void ensureFileExists() {
        File file = new File(filePath);
        try {
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                Files.write(file.toPath(), "[]".getBytes(StandardCharsets.UTF_8));
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to initialize JSON file: " + filePath, e);
        }
    }
    
    /**
     * Reads all entities from the JSON file.
     * 
     * @return List of all entities
     */
    public List<T> findAll() {
        lock.readLock().lock();
        try {
            return readFromFile();
        } finally {
            lock.readLock().unlock();
        }
    }
    
    /**
     * Finds an entity by its ID.
     * 
     * @param id The entity ID
     * @return Optional containing the entity if found
     */
    public Optional<T> findById(String id) {
        lock.readLock().lock();
        try {
            return readFromFile().stream()
                    .filter(entity -> getEntityId(entity).equals(id))
                    .findFirst();
        } finally {
            lock.readLock().unlock();
        }
    }
    
    /**
     * Finds entities matching a predicate.
     * 
     * @param predicate The filter condition
     * @return List of matching entities
     */
    public List<T> findByPredicate(Predicate<T> predicate) {
        lock.readLock().lock();
        try {
            return readFromFile().stream()
                    .filter(predicate)
                    .collect(Collectors.toList());
        } finally {
            lock.readLock().unlock();
        }
    }
    
    /**
     * Saves an entity (insert or update).
     * 
     * @param entity The entity to save
     * @return The saved entity
     */
    public T save(T entity) {
        lock.writeLock().lock();
        try {
            List<T> entities = readFromFile();
            String entityId = getEntityId(entity);
            
            // Check if entity exists (update) or is new (insert)
            boolean found = false;
            for (int i = 0; i < entities.size(); i++) {
                if (getEntityId(entities.get(i)).equals(entityId)) {
                    entities.set(i, entity);
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                entities.add(entity);
            }
            
            writeToFile(entities);
            return entity;
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    /**
     * Saves multiple entities at once.
     * 
     * @param newEntities The entities to save
     * @return List of saved entities
     */
    public List<T> saveAll(List<T> newEntities) {
        lock.writeLock().lock();
        try {
            List<T> entities = readFromFile();
            
            for (T entity : newEntities) {
                String entityId = getEntityId(entity);
                boolean found = false;
                
                for (int i = 0; i < entities.size(); i++) {
                    if (getEntityId(entities.get(i)).equals(entityId)) {
                        entities.set(i, entity);
                        found = true;
                        break;
                    }
                }
                
                if (!found) {
                    entities.add(entity);
                }
            }
            
            writeToFile(entities);
            return newEntities;
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    /**
     * Deletes an entity by ID.
     * 
     * @param id The entity ID to delete
     * @return true if entity was deleted, false if not found
     */
    public boolean delete(String id) {
        lock.writeLock().lock();
        try {
            List<T> entities = readFromFile();
            int originalSize = entities.size();
            
            entities.removeIf(entity -> getEntityId(entity).equals(id));
            
            if (entities.size() < originalSize) {
                writeToFile(entities);
                return true;
            }
            return false;
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    /**
     * Deletes all entities matching a predicate.
     * 
     * @param predicate The filter condition
     * @return Number of entities deleted
     */
    public int deleteByPredicate(Predicate<T> predicate) {
        lock.writeLock().lock();
        try {
            List<T> entities = readFromFile();
            int originalSize = entities.size();
            
            entities.removeIf(predicate);
            
            int deleted = originalSize - entities.size();
            if (deleted > 0) {
                writeToFile(entities);
            }
            return deleted;
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    /**
     * Counts all entities.
     * 
     * @return Number of entities
     */
    public long count() {
        lock.readLock().lock();
        try {
            return readFromFile().size();
        } finally {
            lock.readLock().unlock();
        }
    }
    
    /**
     * Checks if an entity with the given ID exists.
     * 
     * @param id The entity ID
     * @return true if exists
     */
    public boolean existsById(String id) {
        return findById(id).isPresent();
    }
    
    /**
     * Deletes all entities.
     */
    public void deleteAll() {
        lock.writeLock().lock();
        try {
            writeToFile(new ArrayList<>());
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    // ========== Private Helper Methods ==========
    
    private List<T> readFromFile() {
        try {
            File file = new File(filePath);
            
            // Check cache validity
            if (cache != null && file.lastModified() == lastModified) {
                return new ArrayList<>(cache);
            }
            
            String content = new String(Files.readAllBytes(file.toPath()), StandardCharsets.UTF_8);
            if (content.trim().isEmpty()) {
                content = "[]";
            }
            
            List<T> entities = gson.fromJson(content, listType);
            
            // Update cache
            cache = new ArrayList<>(entities != null ? entities : new ArrayList<>());
            lastModified = file.lastModified();
            
            return new ArrayList<>(cache);
        } catch (IOException e) {
            throw new RuntimeException("Failed to read JSON file: " + filePath, e);
        }
    }
    
    private void writeToFile(List<T> entities) {
        try {
            String json = gson.toJson(entities);
            Files.write(Paths.get(filePath), json.getBytes(StandardCharsets.UTF_8));
            
            // Invalidate cache
            cache = new ArrayList<>(entities);
            lastModified = new File(filePath).lastModified();
        } catch (IOException e) {
            throw new RuntimeException("Failed to write JSON file: " + filePath, e);
        }
    }
    
    /**
     * Gets the ID field value from an entity using reflection.
     */
    private String getEntityId(T entity) {
        try {
            java.lang.reflect.Method getIdMethod = entityClass.getMethod("getId");
            Object id = getIdMethod.invoke(entity);
            return id != null ? id.toString() : "";
        } catch (Exception e) {
            throw new RuntimeException("Entity must have a getId() method", e);
        }
    }
}
