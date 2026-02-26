package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBContext {

    private static final String DB_DRIVER;
    private static final String DB_URL;
    private static final String DB_USERNAME;
    private static final String DB_PASSWORD;

    static {
        try {
            DB_DRIVER = getEnv("DB_DRIVER", "com.microsoft.sqlserver.jdbc.SQLServerDriver");
            DB_URL = getEnv("DB_URL",
                    "jdbc:sqlserver://localhost:1433;databaseName=CRM_System;encrypt=true;trustServerCertificate=true");
            DB_USERNAME = getEnv("DB_USERNAME", "sa");
            DB_PASSWORD = getEnv("DB_PASSWORD", "123");

            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Cannot load database driver", e);
        }
    }

    private DBContext() {
        // Prevent instantiate
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
    }

    private static String getEnv(String key, String defaultValue) {
        String value = System.getenv(key);
        return (value == null || value.isBlank()) ? defaultValue : value;
    }
}
