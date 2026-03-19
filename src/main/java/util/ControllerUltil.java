package util;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

public class ControllerUltil {

    private static final Pattern DATE_PATTERN =
            Pattern.compile("^\\d{4}-\\d{2}-\\d{2}$");

    public static void forwardError(HttpServletRequest request,
                                    HttpServletResponse response,
                                    String message) {
        try {
            request.setAttribute("errorMessage", message);
            request.getRequestDispatcher("/view/error/error.jsp")
                    .forward(request, response);
        } catch (ServletException | IOException e) {
            e.printStackTrace();
        }
    }

    public static int parsePage(String value) {
        try {
            int p = Integer.parseInt(value);
            return p <= 0 ? 1 : p;
        } catch (Exception e) {
            return 1;
        }
    }

    public static int parseSize(String value) {
        try {
            int s = Integer.parseInt(value);

            if (s <= 0) {
                return 10;
            }
            if (s > 50) {
                return 50;   // 🔥 hard limit chống abuse
            }
            return s;
        } catch (Exception e) {
            return 10;
        }
    }


    public static LocalDate parseDate(String dateStr) {
        if (dateStr == null || dateStr.isBlank()) {
            return null;
        }

        if (!DATE_PATTERN.matcher(dateStr).matches()) {
            return null;
        }

        try {
            return LocalDate.parse(dateStr);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

}
