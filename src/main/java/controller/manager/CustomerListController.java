package controller.manager;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import dto.CustomerPageResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.StyleTag;
import service.CustomerService;
import util.ControllerUltil;

@WebServlet(name = "CustomerListController", urlPatterns = { "/customers" })
public class CustomerListController extends HttpServlet {

    private static final int DEFAULT_SIZE = 10;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {

    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        int page = 1;
        int size = DEFAULT_SIZE;
        try {
            if (request.getParameter("page") != null) {
                page = ControllerUltil.parsePage(request.getParameter("page"));
            }
            if (request.getParameter("size") != null) {
                size = ControllerUltil.parseSize(request.getParameter("size"));
            }

            // Lấy sessionId từ HTTP session (null nếu lần đầu)
            HttpSession httpSession = request.getSession();
            String sessionId = (String) httpSession.getAttribute("customerPagingSession");

            // Nếu JS không gửi lên thì fallback lấy từ HttpSession
            if (sessionId == null || sessionId.isBlank()) {
                sessionId = (String) httpSession.getAttribute("customerFilterSession");
            }

            // Reset session nếu user quay về trang 1
            if (page == 1) {
                sessionId = null;
                httpSession.removeAttribute("customerPagingSession");
            }

            CustomerService customerService = new CustomerService();
            CustomerPageResult result = customerService.getCustomerList(page, size, sessionId);
            List<StyleTag> styleTagList = customerService.getListStyleTags();

            // Lưu sessionId mới vào HTTP session cho request tiếp theo
            if (result.getSessionId() != null) {
                httpSession.setAttribute("customerPagingSession", result.getSessionId());
            }

            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                Gson gson = new GsonBuilder()
                        .registerTypeAdapter(LocalDateTime.class,
                                (JsonSerializer<LocalDateTime>) (src, typeOfSrc,
                                        context) -> new JsonPrimitive(src.toString()))
                        .create();
                response.getWriter().write(gson.toJson(result));
                return;
            }

            request.setAttribute("customerList", result.getData());
            request.setAttribute("totalPages", result.getTotalPages());
            request.setAttribute("totalRecord", result.getTotalRecords());
            request.setAttribute("sessionId", result.getSessionId()); // ← Truyền xuống JSP nếu cần
            request.setAttribute("styleTagList", styleTagList);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageTitle", "Customer List | Clothes CRM");
            request.setAttribute("contentPage", "customer/customerList.jsp");
            request.setAttribute("pageCss", "customerList.css");
            request.setAttribute("pageJs", "CustomerList.js");
            request.setAttribute("page", "customer-list");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
        } catch (SQLException ex) {
            log("DB error", ex);
            ControllerUltil.forwardError(request, response, "Database error.");
        }
    }

}
