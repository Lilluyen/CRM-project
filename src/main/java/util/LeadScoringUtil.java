package util;

/**
 * Tính điểm Lead dựa trên các tiêu chí - Họ tên: +20 - Email: +20 - Phone: +20
 * - Campaign: +10 Max: 70
 */
public class LeadScoringUtil {

    private LeadScoringUtil() {}

    /**
     * Tính leadScore dựa trên thông tin
     *
     * @return score (0-80)
     */
    public static int calculateScore(String fullName, String email, String phone, int campaignId, String interest) {
        int score = 0;

        // Có họ tên
        if (fullName != null && !fullName.trim().isEmpty()) {
            score += 20;
        }

        // Có email
        if (email != null && !email.trim().isEmpty()) {
            score += 20;
        }

        // Có số điện thoại hợp lệ
        // Normalize: nếu phone là 9 chữ số (do Excel đọc mất số 0 đầu) → thêm lại 0
        if (phone != null && !phone.trim().isEmpty()) {
            String normalizedPhone = phone.trim();
            if (normalizedPhone.length() == 9 && normalizedPhone.matches("\\d{9}")) {
                normalizedPhone = "0" + normalizedPhone;
            }
            if (PhoneCheck.isValidPhone(normalizedPhone)) {
                score += 20;
            }
        }

        // Thuộc campaign
        if (campaignId > 0) {
            score += 10;
        }

        if (interest != null && !interest.trim().isEmpty()) {
            score += 10;
        }

        return Math.min(score, 80);
    }

    /**
     * Xác định trạng thái Lead tự động dựa trên score < 20: LOST < 40: NEW_LEAD
     * < 70:  NURTURING
     * >= 70: QUALIFIED
     */
    public static String determineStatus(int score) {
        if (score < 20) {
            return "LOST";
        } else if (score < 40) {
            return "NEW_LEAD";
        } else if (score < 70) {
            return "NURTURING";
        } else {
            return "QUALIFIED";
        }
    }
}
