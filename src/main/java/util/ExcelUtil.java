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
     * Đọc Leads từ file XLSX
     * 
     * Format Excel:
     * fullName | email | phone | companyName | interest | source
     */
    public static List<Lead> readLeadsFromExcel(InputStream inputStream) throws Exception {
        List<Lead> leads = new ArrayList<>();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);

            // Row 0 là header, bắt đầu từ row 1
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    String fullName = getCellValue(row.getCell(0));
                    String email = getCellValue(row.getCell(1));
                    String phone = getCellValue(row.getCell(2));
                    String companyName = getCellValue(row.getCell(3));
                    String interest = getCellValue(row.getCell(4));
                    String source = getCellValue(row.getCell(5));

                    // Validation
                    if (fullName == null || fullName.trim().isEmpty()) {
                        throw new Exception("Row " + (i + 1) + ": Tên không được để trống");
                    }
                    if (email == null || !EmailCheck.isValidEmail(email)) {
                        throw new Exception("Row " + (i + 1) + ": Email không hợp lệ");
                    }
                    if (phone != null && !phone.isEmpty() && !PhoneCheck.isValidPhone(phone)) {
                        throw new Exception("Row " + (i + 1) + ": Số điện thoại không hợp lệ");
                    }

                    Lead lead = new Lead();
                    lead.setFullName(fullName);
                    lead.setEmail(email);
                    lead.setPhone(phone);
                    lead.setInterest(interest);
                    lead.setSource(source != null ? source : "IMPORT");
                    lead.setStatus("NEW_LEAD");

                    leads.add(lead);

                } catch (Exception e) {
                    throw new Exception("Row " + (i + 1) + ": " + e.getMessage());
                }
            }
        }

        return leads;
    }

    /**
     * Lấy giá trị từ cell
     */
    private static String getCellValue(Cell cell) {
        if (cell == null) return null;

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                return String.valueOf((int) cell.getNumericCellValue());
            default:
                return null;
        }
    }
}