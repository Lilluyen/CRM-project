package util;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import model.Lead;

/**
 * Utility để đọc dữ liệu từ file Excel
 */
public class ExcelUtil {

    /**
     * Đọc Leads từ file XLSX Trả về List<Lead> và collect các lỗi vào
     * List<String>
     *
     * Format Excel: fullName | email | phone | interest
     */
    public static List<Lead> readLeadsFromExcel(InputStream inputStream, List<String> errors) throws Exception {
        List<Lead> leads = new ArrayList<>();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);

            // Row 0 là header, bắt đầu từ row 1
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) {
                    continue;
                }

                try {
                    String fullName = getCellValue(row.getCell(0));
                    String email = getCellValue(row.getCell(1));
                    String phone = getCellValue(row.getCell(2));
                    String interest = getCellValue(row.getCell(3)); // SỬA: 4 → 3, file chỉ có 4 cột

                    // Chỉ parse dữ liệu thô, KHÔNG validate ở đây
                    // Validation tập trung ở LeadImportService để tránh double validation
                    Lead lead = new Lead();
                    lead.setFullName(fullName != null ? fullName.trim() : null);
                    lead.setEmail(email != null ? email.trim() : null);
                    lead.setPhone(phone != null ? phone.trim() : null);
                    lead.setInterest(interest);
                    lead.setSource("IMPORT"); // hardcode vì file không có cột source
                    lead.setStatus("NEW_LEAD");

                    leads.add(lead);

                } catch (Exception e) {
                    // Collect error nhưng tiếp tục xử lý các row khác
                    errors.add("Row " + (i + 1) + ": " + e.getMessage());
                }
            }
        }

        return leads;
    }

    /**
     * Overload for backward compatibility - throws exception if any row has
     * error
     */
    public static List<Lead> readLeadsFromExcel(InputStream inputStream) throws Exception {
        List<String> errors = new ArrayList<>();
        List<Lead> leads = readLeadsFromExcel(inputStream, errors);
        if (!errors.isEmpty()) {
            throw new Exception(String.join("; ", errors));
        }
        return leads;
    }

    /**
     * Lấy giá trị từ cell
     */
    private static String getCellValue(Cell cell) {
        if (cell == null) {
            return null;
        }

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                // SỬA: Giữ số 0 đầu cho số điện thoại VN
                long longVal = (long) cell.getNumericCellValue();
                String numStr = String.valueOf(longVal);
                // Số điện thoại VN 9 chữ số → thêm lại số 0 đầu bị mất
                if (numStr.length() == 9) {
                    numStr = "0" + numStr;
                }
                return numStr;
            default:
                return null;
        }
    }
}
