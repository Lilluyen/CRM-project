package controller.sale;

import dao.*;
import dto.CustomerCreateDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.StyleTag;
import model.User;
import service.CustomerService;
import util.ControllerUltil;
import util.EmailCheck;
import util.NameCheck;
import util.PhoneCheck;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CreateCustomerController", urlPatterns = {"/customers/add-customer"})
public class CreateCustomerController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    CustomerMeasurementDAO customerMeasurementDAO = new CustomerMeasurementDAO();
    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerMeasurementDAO,
            customerSegmentDAO);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // TODO Auto-generated method stub

        try {
            List<StyleTag> styleTagList = customerService.getListStyleTags();

            req.setAttribute("styleTagList", styleTagList);
            req.setAttribute("pageTitle", "Add New Customer | Clothes CRM");
            req.setAttribute("contentPage", "customer/add_customer.jsp");
            req.setAttribute("pageCss", "customer-add.css");
            req.setAttribute("page", "customer-add");

            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException e) {
            log("DB error", e);
            ControllerUltil.forwardError(req, resp,
                    "Database error occurred while retrieving customer list.");

        } catch (ServletException | IOException e) {
            log("View error", e);
            ControllerUltil.forwardError(req, resp,
                    "Internal server error occurred while processing your request.");
        }

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        List<String> errors = new ArrayList<>();
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
                String source = req.getParameter("source");
                String address = req.getParameter("address");
                String birthdayRaw = req.getParameter("birthday");

                // Validate name
                if (!NameCheck.isValidName(name)) {
                    resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                    return;
                }

                if (!PhoneCheck.isValidPhone(phone)) {
                    resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                    return;
                }

                if (email != null && !email.isBlank() && !EmailCheck.isValidEmail(email)) {
                    resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                    return;
                }

                LocalDate birthday = null;

                if (birthdayRaw == null || birthdayRaw.isBlank()) {
                    errors.add("Birthday is required");
                } else {
                    try {
                        birthday = ControllerUltil.parseDate(birthdayRaw);
                        if (birthday.isAfter(LocalDate.now())) {
                            errors.add("Birthday must be in the past");
                            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                            return;
                        }
                    } catch (DateTimeParseException e) {
                        errors.add("Invalid birthday format");
                        resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                        return;
                    }
                }

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
                dto.setSource(source);
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
                resp.sendRedirect(req.getContextPath() + "/customers?status=success");

            } catch (Exception e) {

                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
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

}
