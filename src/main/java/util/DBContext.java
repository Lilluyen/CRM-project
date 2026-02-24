package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Database connection manager following enterprise design standards.
 * Handles SQL Server connections with secure credential management and proper resource lifecycle.
 */
public class DBContext {
    private static final Logger LOGGER = LoggerFactory.getLogger(DBContext.class);

    // Configuration from environment variables (with fallback defaults for development)
    private static final String DB_DRIVER = getConfigValue("DB_DRIVER", "com.microsoft.sqlserver.jdbc.SQLServerDriver");
    private static final String DB_URL = getConfigValue("DB_URL", "jdbc:sqlserver://localhost:1433;databaseName=CRM_System;encrypt=true;trustServerCertificate=true");
    private static final String DB_USERNAME = getConfigValue("DB_USERNAME", null);
    private static final String DB_PASSWORD = getConfigValue("DB_PASSWORD", null);

    private final Connection connection;

    /**
     * Initialize database connection.
     * Credentials should be provided via environment variables for production use.
     * 
     * @throws RuntimeException if connection fails
     */
    public DBContext() {
        this.connection = initializeConnection();
    }

    /**
     * Establish and return a new database connection.
     * 
     * @return active database connection
     * @throws RuntimeException if connection cannot be established
     */
    private Connection initializeConnection() {
        try {
            Class.forName(DB_DRIVER);
            LOGGER.info("Initializing database connection to {}", DB_URL);
            
            Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
            LOGGER.info("Database connection established successfully");
            return conn;
            
        } catch (ClassNotFoundException ex) {
            LOGGER.error("Database driver not found: {}", DB_DRIVER, ex);
            throw new RuntimeException("Failed to load database driver: " + DB_DRIVER, ex);
        } catch (SQLException ex) {
            LOGGER.error("Failed to establish database connection to {}", DB_URL, ex);
            throw new RuntimeException("Database connection failed: " + ex.getMessage(), ex);
        }
    }

    /**
     * Get the current database connection.
     * 
     * @return active connection
     */
    public Connection getConnection() {
        return connection;
    }

    /**
     * Close the database connection and free resources.
     */
    public void close() {
        if (connection != null) {
            try {
                connection.close();
                LOGGER.info("Database connection closed");
            } catch (SQLException ex) {
                LOGGER.error("Error closing database connection", ex);
            }
        }
    }

    /**
     * Retrieve configuration value from environment variable with fallback.
     * 
     * @param key environment variable key
     * @param defaultValue value to use if environment variable is not set
     * @return configuration value
     */
    private static String getConfigValue(String key, String defaultValue) {
        String value = System.getenv(key);
        if (value == null) {
            LOGGER.debug("Environment variable {} not set, using default", key);
            return defaultValue;
        }
        return value;
    }
}
