package util;

/**
 * Tính điểm Lead dựa trên các tiêu chí - Họ tên: +20 - Email: +20 - Phone: +20
 * - Campaign: +10 Max: 70
 */
public class LeadScoringUtil {

    /**
     * Tính leadScore dựa trên thông tin
     *
     * @return score (0-70)
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
        if (phone != null && !phone.trim().isEmpty() && PhoneCheck.isValidPhone(phone)) {
            score += 20;
        }

        // Thuộc campaign
        if (campaignId > 0) {
            score += 10;
        }

        if (interest != null && !interest.trim().isEmpty()) {
            score += 10;
        }

        return Math.min(score, 100);
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
