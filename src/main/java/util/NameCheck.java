package util;

public class NameCheck {

    /**
     * Validate customer name
     * Requirements:
     * - Not null or empty
     * - Length between 2 and 100 characters
     * - Only allows letters, numbers, spaces, hyphens, and apostrophes
     * - Must contain at least one letter
     */
    public static boolean isValidName(String name) {
        // Check if name is null or empty
        if (name == null || name.trim().isEmpty()) {
            return false;
        }

        name = name.trim();

        // Check length (2-100 characters)
        if (name.length() < 2 || name.length() > 100) {
            return false;
        }

        // Only allow letters (including Vietnamese), numbers, spaces, hyphens, and
        // apostrophes
        if (!name.matches(
                "^[a-zA-Z0-9\\s\\-'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđa-z]+$")) {
            return false;
        }

        // Must contain at least one letter
        if (!name.matches(".*[a-zA-Zàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ].*")) {
            return false;
        }

        return true;
    }

}
