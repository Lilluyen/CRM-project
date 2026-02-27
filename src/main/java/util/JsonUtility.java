// util/JsonUtility.java
package util;

import com.google.gson.*;
import java.lang.reflect.Type;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Centralized, reusable JSON serialization utility.
 * 
 * This class is responsible for converting any object to JSON.
 * It is completely generic and entity-agnostic.
 * 
 * Key responsibilities:
 * - Centralize JSON configuration (date format, null handling, etc.)
 * - Provide consistent JSON output across ALL endpoints
 * - Be reusable by any servlet or controller in the application
 * 
 * Architectural principle: This is a SHARED INFRASTRUCTURE COMPONENT.
 * It must not depend on specific entities like Task, Activity, Customer, etc.
 */
public class JsonUtility {

    private static final Gson gson = buildGson();

    /**
     * Build and configure the Gson instance with centralized settings.
     * This is where ALL JSON configuration lives—a single source of truth.
     */
    private static Gson buildGson() {
        GsonBuilder builder = new GsonBuilder();
        
        // 1. Configure date/time formatting (single place, consistent everywhere)
        builder.registerTypeAdapter(LocalDate.class, new JsonSerializer<LocalDate>() {
            @Override
            public JsonElement serialize(LocalDate src, Type typeOfSrc, JsonSerializationContext context) {
                return new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE)); // "2026-02-27"
            }
        });
        
        builder.registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
            @Override
            public JsonElement serialize(LocalDateTime src, Type typeOfSrc, JsonSerializationContext context) {
                return new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)); // "2026-02-27T10:30:00"
            }
        });
        
        // 2. Configure null handling (explicit strategy)
        builder.serializeNulls(); // Include null values in JSON output
        
        // 3. Configure field naming strategy (optional, for snake_case if needed)
        // builder.setFieldNamingStrategy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES);
        
        // 4. Pretty printing for readability (optional, remove in production for performance)
        // builder.setPrettyPrinting();
        
        return builder.create();
    }

    /**
     * Serialize any object to JSON.
     * Completely generic—works with Task, Activity, Customer, or any object.
     * 
     * @param object Any object to serialize
     * @return JSON string
     */
    public static String toJson(Object object) {
        if (object == null) {
            return "null";
        }
        return gson.toJson(object);
    }

    /**
     * Serialize a list of objects to JSON.
     * 
     * @param objects List of objects
     * @return JSON array string
     */
    public static <T> String toJsonArray(java.util.List<T> objects) {
        if (objects == null) {
            return "[]";
        }
        return gson.toJson(objects);
    }

    /**
     * Create a JSON response wrapper for consistent API responses.
     * This provides a standard envelope for all API responses.
     * 
     * Example: { "success": true, "data": [...], "message": "OK" }
     */
    public static String createSuccessResponse(Object data) {
        JsonObject response = new JsonObject();
        response.addProperty("success", true);
        response.add("data", gson.toJsonTree(data));
        response.addProperty("message", "OK");
        return response.toString();
    }

    /**
     * Create a JSON error response.
     * Example: { "success": false, "message": "Error description" }
     */
    public static String createErrorResponse(String errorMessage) {
        JsonObject response = new JsonObject();
        response.addProperty("success", false);
        response.addProperty("message", errorMessage);
        return response.toString();
    }
}