package controller.marketing;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Lead;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import service.LeadService;

@WebServlet(name = "LeadExportController", urlPatterns = {"/marketing/leads/export"})
public class LeadExportController extends HttpServlet {

    private final LeadService leadService = new LeadService();
    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("search");
        String status = request.getParameter("status");
        String interest = request.getParameter("interest");

        int campaignId = 0;
        try {
            if (request.getParameter("campaignId") != null) {
                campaignId = Integer.parseInt(request.getParameter("campaignId"));
            }
        } catch (NumberFormatException ignored) {
        }

        List<Lead> leads = leadService.searchLeadsForExport(keyword, status, campaignId, interest);

        String filename = "leads_" + LocalDate.now() + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Leads");
            CellStyle headerStyle = createHeaderStyle(workbook);

            Row header = sheet.createRow(0);
            String[] headers = {
                "Mã Lead", "Họ tên", "Email", "Điện thoại", "Điểm số", "Trạng thái",
                "Quan tâm", "Campaign", "Nguồn", "Ngày tạo", "Ngày cập nhật"
            };
            for (int i = 0; i < headers.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Giữ cố định hàng tiêu đề khi cuộn dữ liệu.
            sheet.createFreezePane(0, 1);

            int rowIndex = 1;
            for (Lead lead : leads) {
                Row row = sheet.createRow(rowIndex++);
                row.createCell(0).setCellValue(lead.getLeadId());
                row.createCell(1).setCellValue(text(lead.getFullName()));
                row.createCell(2).setCellValue(text(lead.getEmail()));
                row.createCell(3).setCellValue(text(lead.getPhone()));
                row.createCell(4).setCellValue(lead.getScore());
                row.createCell(5).setCellValue(text(lead.getStatus()));
                row.createCell(6).setCellValue(text(lead.getInterest()));
                row.createCell(7).setCellValue(text(lead.getCampaignName()));
                row.createCell(8).setCellValue(text(lead.getSource()));
                row.createCell(9).setCellValue(lead.getCreatedAt() != null
                        ? lead.getCreatedAt().format(DATE_TIME_FORMAT) : "");
                row.createCell(10).setCellValue(lead.getUpdatedAt() != null
                        ? lead.getUpdatedAt().format(DATE_TIME_FORMAT) : "");
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(response.getOutputStream());
            response.getOutputStream().flush();
        }
    }

    private String text(String value) {
        return value != null ? value : "";
    }

    private CellStyle createHeaderStyle(XSSFWorkbook workbook) {
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerFont.setColor(IndexedColors.WHITE.getIndex());

        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFont(headerFont);
        headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);
        headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        return headerStyle;
    }
}
