package controller.sale.deal;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

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

import dao.DealDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Deal;
import util.DBContext;

@WebServlet(name = "DealExportController", urlPatterns = { "/sale/deal/export" })
public class DealExportController extends HttpServlet {

    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String stage = request.getParameter("stage");

        try (Connection conn = DBContext.getConnection()) {
            DealDAO dao = new DealDAO(conn);
            List<Deal> deals = dao.searchDealsForExport(search, stage);

            String filename = "deals_" + LocalDate.now() + ".xlsx";
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            try (XSSFWorkbook workbook = new XSSFWorkbook()) {
                Sheet sheet = workbook.createSheet("Deals");
                CellStyle headerStyle = createHeaderStyle(workbook);

                Row header = sheet.createRow(0);
                String[] headers = {
                        "Deal ID", "Deal Name", "Customer ID", "Lead ID", "Stage", "Probability", "Expected Value",
                        "Actual Value", "Expected Close Date", "Owner ID", "Updated At"
                };
                for (int i = 0; i < headers.length; i++) {
                    Cell cell = header.createCell(i);
                    cell.setCellValue(headers[i]);
                    cell.setCellStyle(headerStyle);
                }

                sheet.createFreezePane(0, 1);

                int rowIndex = 1;
                for (Deal d : deals) {
                    Row row = sheet.createRow(rowIndex++);
                    row.createCell(0).setCellValue(d.getDealId());
                    row.createCell(1).setCellValue(text(d.getDealName()));
                    row.createCell(2).setCellValue(d.getCustomerId() > 0 ? d.getCustomerId() : 0);
                    row.createCell(3).setCellValue(d.getLeadId() > 0 ? d.getLeadId() : 0);
                    row.createCell(4).setCellValue(text(d.getStage()));
                    row.createCell(5).setCellValue(d.getProbability());
                    row.createCell(6).setCellValue(d.getExpectedValue() != null ? d.getExpectedValue().doubleValue() : 0d);
                    if (d.getActualValue() != null) {
                        row.createCell(7).setCellValue(d.getActualValue().doubleValue());
                    } else {
                        row.createCell(7).setCellValue("");
                    }
                    row.createCell(8).setCellValue(d.getExpectedCloseDate() != null ? d.getExpectedCloseDate().toString() : "");
                    row.createCell(9).setCellValue(d.getOwnerId());
                    row.createCell(10).setCellValue(d.getUpdatedAt() != null ? d.getUpdatedAt().format(DATE_TIME_FORMAT) : "");
                }

                for (int i = 0; i < headers.length; i++) {
                    sheet.autoSizeColumn(i);
                }

                workbook.write(response.getOutputStream());
                response.getOutputStream().flush();
            }

        } catch (Exception e) {
            throw new ServletException(e);
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
