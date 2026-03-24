package controller.sale.category;

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

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import util.DBContext;

@WebServlet("/sale/category/export")
public class CategoryExportController extends HttpServlet {

    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String status = request.getParameter("status");

        try (Connection conn = DBContext.getConnection()) {
            CategoryDAO dao = new CategoryDAO(conn);
            List<Category> categories = dao.getCategoryListForExport(search, status);

            String filename = "categories_" + LocalDate.now() + ".xlsx";
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            try (XSSFWorkbook workbook = new XSSFWorkbook()) {
                Sheet sheet = workbook.createSheet("Categories");
                CellStyle headerStyle = createHeaderStyle(workbook);

                Row header = sheet.createRow(0);
                String[] headers = { "Category ID", "Category Name", "Description", "Status", "Created At" };
                for (int i = 0; i < headers.length; i++) {
                    Cell cell = header.createCell(i);
                    cell.setCellValue(headers[i]);
                    cell.setCellStyle(headerStyle);
                }

                sheet.createFreezePane(0, 1);

                int rowIndex = 1;
                for (Category c : categories) {
                    Row row = sheet.createRow(rowIndex++);
                    row.createCell(0).setCellValue(c.getCategoryId());
                    row.createCell(1).setCellValue(text(c.getCategoryName()));
                    row.createCell(2).setCellValue(text(c.getDescription()));
                    row.createCell(3).setCellValue(text(c.getStatus()));
                    row.createCell(4).setCellValue(c.getCreatedAt() != null ? c.getCreatedAt().format(DATE_TIME_FORMAT) : "");
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
