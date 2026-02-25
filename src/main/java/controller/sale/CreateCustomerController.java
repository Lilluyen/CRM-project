package controller.sale;

import dto.CustomerCreateDTO;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.User;
import service.CustomerService;

@WebServlet(name = "CreateCustomerController", urlPatterns = {"/customers/add-customer"})
public class CreateCustomerController extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // TODO Auto-generated method stub
        
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session != null) {
            User user = (User) session.getAttribute("user");

            try {
                req.setCharacterEncoding("UTF-8");

                // ===== 1. BASIC INFO =====
                String name = req.getParameter("name");
                String phone = req.getParameter("phone");
                String gender = req.getParameter("gender");
                String email = req.getParameter("email");
                String socialLink = req.getParameter("socialLink");
                String address = req.getParameter("address");

                LocalDate birthday = parseDate(req.getParameter("birthday"));

                // ===== 2. FIT PROFILE (BigDecimal) =====
                BigDecimal height = parseDecimal(req.getParameter("height"));
                BigDecimal weight = parseDecimal(req.getParameter("weight"));
                String preferredSize = req.getParameter("preferred_size");

                BigDecimal bust = parseDecimal(req.getParameter("bust"));
                BigDecimal waist = parseDecimal(req.getParameter("waist"));
                BigDecimal hips = parseDecimal(req.getParameter("hips"));
                BigDecimal shoulder = parseDecimal(req.getParameter("shoulder"));

                String bodyShape = req.getParameter("bodyShape");

                // ===== 3. STYLE TAGS (List<Integer>) =====
                List<Integer> styleTags = new ArrayList<>();
                String[] tagParams = req.getParameterValues("styleTags");

                if (tagParams != null) {
                    for (String tagId : tagParams) {
                        styleTags.add(Integer.valueOf(tagId));
                    }
                }

                // ===== 4. MAP DTO =====
                CustomerCreateDTO dto = new CustomerCreateDTO();
                dto.setName(name);
                dto.setPhone(phone);
                dto.setGender(gender);
                dto.setEmail(email);
                dto.setBirthday(birthday);
                dto.setSocialLink(socialLink);
                dto.setAddress(address);

                dto.setHeight(height);
                dto.setWeight(weight);
                dto.setPreferredSize(preferredSize);

                dto.setBust(bust);
                dto.setWaist(waist);
                dto.setHips(hips);
                dto.setShoulder(shoulder);
                dto.setBodyShape(bodyShape);

                dto.setStyleTags(styleTags);

                // ===== 5. CALL SERVICE =====
                customerService.createCustomer(dto, user.getUserId());

                // ===== 6. REDIRECT (tránh submit lại form) =====
                resp.sendRedirect(req.getContextPath() + "/customers?add-customer=true");

            } catch (Exception e) {

                req.setAttribute("errorMessage", e.getMessage());
                req.getRequestDispatcher("/view/customer/customerList.jsp")
                        .forward(req, resp);
            }
        }

    }

    // ================= HELPER =================
    private BigDecimal parseDecimal(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return new BigDecimal(value);
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return LocalDate.parse(value);
    }
}
