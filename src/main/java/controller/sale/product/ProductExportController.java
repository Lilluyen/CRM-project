package controller.sale.product;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

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

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;
import util.DBContext;

@WebServlet(name = "ProductExportController", urlPatterns = { "/sale/product/export" })
public class ProductExportController extends HttpServlet {

    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String status = request.getParameter("status");

        try (Connection conn = DBContext.getConnection()) {
            ProductDAO dao = new ProductDAO(conn);
            List<Product> products = dao.searchProductsForExport(search, status);

            String filename = "products_" + LocalDate.now() + ".xlsx";
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            try (XSSFWorkbook workbook = new XSSFWorkbook()) {
                Sheet sheet = workbook.createSheet("Products");
                CellStyle headerStyle = createHeaderStyle(workbook);

                Row header = sheet.createRow(0);
                String[] headers = { "Product ID", "Name", "SKU", "Price", "Status", "Categories", "Updated At" };
                for (int i = 0; i < headers.length; i++) {
                    Cell cell = header.createCell(i);
                    cell.setCellValue(headers[i]);
                    cell.setCellStyle(headerStyle);
                }

                sheet.createFreezePane(0, 1);

                int rowIndex = 1;
                for (Product p : products) {
                    Row row = sheet.createRow(rowIndex++);
                    row.createCell(0).setCellValue(p.getProductId());
                    row.createCell(1).setCellValue(text(p.getName()));
                    row.createCell(2).setCellValue(text(p.getSku()));
                    row.createCell(3).setCellValue(p.getPrice() != null ? p.getPrice().doubleValue() : 0d);
                    row.createCell(4).setCellValue(text(p.getStatus()));
                    row.createCell(5).setCellValue(categoriesText(p.getCategories()));
                    row.createCell(6).setCellValue(p.getUpdatedAt() != null ? p.getUpdatedAt().format(DATE_TIME_FORMAT) : "");
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

    private String categoriesText(List<Category> categories) {
        if (categories == null || categories.isEmpty()) {
            return "";
        }
        return categories.stream().map(Category::getCategoryName).collect(Collectors.joining(", "));
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
