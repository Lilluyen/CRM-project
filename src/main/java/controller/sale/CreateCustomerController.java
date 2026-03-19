package controller.sale;

import dao.*;
import dto.CustomerCreateDTO;
import exception.DuplicateEmailException;
import exception.DuplicatePhoneException;
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
import java.util.*;

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
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            req.setCharacterEncoding("UTF-8");

            // ── Read raw values ──────────────────────────────────────────
            String name = trim(req.getParameter("name"));
            String phone = trim(req.getParameter("phone"));
            String email = trim(req.getParameter("email"));
            String gender = trim(req.getParameter("gender"));
            String birthdayRaw = trim(req.getParameter("birthday"));
            String source = trim(req.getParameter("source"));
            String address = trim(req.getParameter("address"));

            String heightRaw = trim(req.getParameter("height"));
            String weightRaw = trim(req.getParameter("weight"));
            String preferredSize = req.getParameter("preferred_size");
            String bustRaw = trim(req.getParameter("bust"));
            String waistRaw = trim(req.getParameter("waist"));
            String hipsRaw = trim(req.getParameter("hips"));
            String shoulderRaw = trim(req.getParameter("shoulder"));
            String bodyShape = req.getParameter("bodyShape");

            String[] tagParams = req.getParameterValues("styleTags");

            // ── Field-level error map  key = field name ──────────────────
            Map<String, String> fieldErrors = new LinkedHashMap<>();

            // Validate name
            if (name == null || name.isBlank()) {
                fieldErrors.put("name", "Full name is required.");
            } else if (!NameCheck.isValidName(name)) {
                fieldErrors.put("name", "Name contains invalid characters.");
            }

            // Validate phone
            if (phone == null || phone.isBlank()) {
                fieldErrors.put("phone", "Phone number is required.");
            } else if (!PhoneCheck.isValidPhone(phone)) {
                fieldErrors.put("phone", "Phone must be 9–15 digits.");
            }

            // Validate email (optional but must be valid if given)
            if (email != null && !email.isBlank() && !EmailCheck.isValidEmail(email)) {
                fieldErrors.put("email", "Invalid email format.");
            }

            // Validate gender
            if (gender == null || gender.isBlank()) {
                fieldErrors.put("gender", "Please select a gender.");
            }

            // Validate birthday
            LocalDate birthday = null;
            if (birthdayRaw == null || birthdayRaw.isBlank()) {
                fieldErrors.put("birthday", "Date of birth is required.");
            } else {
                try {
                    birthday = ControllerUltil.parseDate(birthdayRaw);
                    if (birthday.isAfter(LocalDate.now())) {
                        fieldErrors.put("birthday", "Birthday must be in the past.");
                    }
                } catch (DateTimeParseException e) {
                    fieldErrors.put("birthday", "Invalid date format.");
                }
            }

            // Validate measurements (optional, but must be positive numbers if given)
            BigDecimal height = parseDecimalValidated(heightRaw, "height", fieldErrors);
            BigDecimal weight = parseDecimalValidated(weightRaw, "weight", fieldErrors);
            BigDecimal bust = parseDecimalValidated(bustRaw, "bust", fieldErrors);
            BigDecimal waist = parseDecimalValidated(waistRaw, "waist", fieldErrors);
            BigDecimal hips = parseDecimalValidated(hipsRaw, "hips", fieldErrors);
            BigDecimal shoulder = parseDecimalValidated(shoulderRaw, "shoulder", fieldErrors);

            // ── If validation failed → forward back with errors + old values ──
            if (!fieldErrors.isEmpty()) {
                reloadFormOnError(req, fieldErrors,
                        name, phone, email, gender, birthdayRaw, source, address,
                        heightRaw, weightRaw, preferredSize,
                        bustRaw, waistRaw, hipsRaw, shoulderRaw, bodyShape,
                        tagParams);
                req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
                return;
            }

            // ── Build style tag list ─────────────────────────────────────
            List<Integer> styleTags = new ArrayList<>();
            if (tagParams != null) {
                for (String tagId : tagParams) {
                    styleTags.add(Integer.valueOf(tagId));
                }
            }

            // ── Map DTO ──────────────────────────────────────────────────
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

            // ── Call service ─────────────────────────────────────────────
            customerService.createCustomer(dto, user.getUserId());
            resp.sendRedirect(req.getContextPath() + "/customers?status=success");

        } catch (DuplicatePhoneException e) {
            Map<String, String> fieldErrors = new LinkedHashMap<>();
            fieldErrors.put("phone", "This phone number is already registered.");
            reloadFormOnError(req, fieldErrors,
                    trim(req.getParameter("name")),
                    trim(req.getParameter("phone")),
                    trim(req.getParameter("email")),
                    trim(req.getParameter("gender")),
                    trim(req.getParameter("birthday")),
                    trim(req.getParameter("source")),
                    trim(req.getParameter("address")),
                    trim(req.getParameter("height")),
                    trim(req.getParameter("weight")),
                    req.getParameter("preferred_size"),
                    trim(req.getParameter("bust")),
                    trim(req.getParameter("waist")),
                    trim(req.getParameter("hips")),
                    trim(req.getParameter("shoulder")),
                    req.getParameter("bodyShape"),
                    req.getParameterValues("styleTags"));
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (DuplicateEmailException e) {
            Map<String, String> fieldErrors = new LinkedHashMap<>();
            fieldErrors.put("email", "This email is already registered.");
            reloadFormOnError(req, fieldErrors,
                    trim(req.getParameter("name")),
                    trim(req.getParameter("phone")),
                    trim(req.getParameter("email")),
                    trim(req.getParameter("gender")),
                    trim(req.getParameter("birthday")),
                    trim(req.getParameter("source")),
                    trim(req.getParameter("address")),
                    trim(req.getParameter("height")),
                    trim(req.getParameter("weight")),
                    req.getParameter("preferred_size"),
                    trim(req.getParameter("bust")),
                    trim(req.getParameter("waist")),
                    trim(req.getParameter("hips")),
                    trim(req.getParameter("shoulder")),
                    req.getParameter("bodyShape"),
                    req.getParameterValues("styleTags"));
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (Exception e) {
            log("Create customer error", e);
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }

    // ── Reload form with errors + previously typed values ────────────────
    private void reloadFormOnError(HttpServletRequest req,
                                   Map<String, String> fieldErrors,
                                   String name, String phone, String email,
                                   String gender, String birthday,
                                   String source, String address,
                                   String height, String weight, String preferredSize,
                                   String bust, String waist, String hips, String shoulder,
                                   String bodyShape, String[] selectedTags)
            throws ServletException {
        try {
            // Errors
            req.setAttribute("fieldErrors", fieldErrors);

            // Old values
            req.setAttribute("oldName", name);
            req.setAttribute("oldPhone", phone);
            req.setAttribute("oldEmail", email);
            req.setAttribute("oldGender", gender);
            req.setAttribute("oldBirthday", birthday);
            req.setAttribute("oldSource", source);
            req.setAttribute("oldAddress", address);
            req.setAttribute("oldHeight", height);
            req.setAttribute("oldWeight", weight);
            req.setAttribute("oldPreferredSize", preferredSize);
            req.setAttribute("oldBust", bust);
            req.setAttribute("oldWaist", waist);
            req.setAttribute("oldHips", hips);
            req.setAttribute("oldShoulder", shoulder);
            req.setAttribute("oldBodyShape", bodyShape);

            // Selected tag IDs as a Set for easy lookup in JSP
            Set<String> selectedTagSet = new HashSet<>();
            if (selectedTags != null) {
                Collections.addAll(selectedTagSet, selectedTags);
            }
            req.setAttribute("selectedTags", selectedTagSet);

            // Reload tag list
            req.setAttribute("styleTagList", customerService.getListStyleTags());

            // Layout
            req.setAttribute("pageTitle", "Add New Customer | Clothes CRM");
            req.setAttribute("contentPage", "customer/add_customer.jsp");
            req.setAttribute("pageCss", "customer-add.css");
            req.setAttribute("page", "customer-add");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────
    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private BigDecimal parseDecimalValidated(String value, String fieldName,
                                             Map<String, String> errors) {
        if (value == null || value.isBlank()) return null;
        try {
            BigDecimal bd = new BigDecimal(value);
            if (bd.compareTo(BigDecimal.ZERO) < 0) {
                errors.put(fieldName, "Value must be greater than 0.");
                return null;
            }
            return bd;
        } catch (NumberFormatException e) {
            errors.put(fieldName, "Invalid number.");
            return null;
        }
    }
}