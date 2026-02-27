package util;

/**
 * Tính điểm Lead dựa trên các tiêu chí
 */
public class LeadScoringUtil {

    /**
     * Tính leadScore dựa trên thông tin
     * @return score (0-100)
     */
    public static int calculateScore(String email, String phone, String source) {
        int score = 0;

        // Có email công ty (chứa domain không phải gmail, yahoo, etc)
        if (email != null && !email.isEmpty()) {
            if (isCompanyEmail(email)) {
                score += 20;
            } else {
                score += 10; // Email cá nhân
            }
        }

        // Có phone hợp lệ
        if (phone != null && PhoneCheck.isValidPhone(phone)) {
            score += 20;
        }

        // Source scoring
        if (source != null) {
            switch (source.toUpperCase()) {
                case "EVENT":
                    score += 30;
                    break;
                case "FACEBOOK":
                case "INSTAGRAM":
                case "SOCIAL_MEDIA":
                    score += 10;
                    break;
                case "WEBSITE":
                    score += 15;
                    break;
                case "REFERRAL":
                    score += 25;
                    break;
                default:
                    score += 5;
            }
        }

        // Cap score at 100
        return Math.min(score, 100);
    }

    /**
     * Phân loại Lead dựa trên score
     */
    public static String classifyLead(int score) {
        if (score >= 70) {
            return "HOT";
        } else if (score >= 40) {
            return "WARM";
        } else {
            return "COLD";
        }
    }

    /**
     * Check email công ty
     */
    private static boolean isCompanyEmail(String email) {
        String domain = email.substring(email.lastIndexOf("@") + 1);
        return !domain.matches("(gmail|yahoo|hotmail|outlook|tmail)\\.com");
    }
}