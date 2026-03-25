package controller.sale;

import dao.*;
import dto.ConflictResult;
import dto.CustomerCreateDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ContactValidationResult;
import model.StyleTag;
import model.User;
import service.CustomerService;
import util.ControllerUltil;
import util.CustomerActivityUtil;
import util.EmailCheck;
import util.NameCheck;
import util.PhoneCheck;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "CreateCustomerController", urlPatterns = { "/customers/add-customer" })
public class CreateCustomerController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();
    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerSegmentDAO,
            contactDAO, noteDAO);

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

            String[] tagParams = req.getParameterValues("styleTags");

            // ── Field-level error map key = field name ──────────────────
            Map<String, String> fieldErrors = new LinkedHashMap<>();

            // Validate name
            if (name == null || name.isBlank()) {
                fieldErrors.put("name", "Full name is required.");
            } else if (!NameCheck.isValidName(name)) {
                fieldErrors.put("name", "Name contains invalid characters.");
            } else if (!name.matches(
                    "^[a-zA-Z\\s\\-'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđa-z]+$")) {
                fieldErrors.put("name", "Name must only contain letters, spaces, hyphens, and apostrophes.");
            }

            // Validate phone
            if (phone == null || phone.isBlank()) {
                fieldErrors.put("phone", "Phone number is required.");
            } else if (!PhoneCheck.isValidPhone(phone)) {
                fieldErrors.put("phone", "Phone is invalid.");
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
            if (birthdayRaw != null && !birthdayRaw.isBlank()) {
                try {
                    birthday = ControllerUltil.parseDate(birthdayRaw);
                    if (birthday != null && birthday.isAfter(LocalDate.now())) {
                        fieldErrors.put("birthday", "Birthday must be in the past.");
                    }
                } catch (Exception e) {
                    fieldErrors.put("birthday", "Invalid date format.");
                }
            }

            // ── If validation failed → forward back with errors + old values ──
            if (!fieldErrors.isEmpty()) {
                reloadFormOnError(req, fieldErrors,
                        name, phone, email, gender, birthdayRaw, source, address, tagParams);
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
            dto.setStyleTags(styleTags);

            // ── Call service ─────────────────────────────────────────────

            ConflictResult conflict = customerService.checkDuplicate(dto);
            if (conflict != null) {
                conflict.setSource("create");
                // Lưu vào session, redirect sang trang resolve
                req.getSession().setAttribute("pendingConflict", conflict);
                resp.sendRedirect(req.getContextPath() + "/customers/resolve-conflict");
                return;
            }

            // Không có conflict → tạo bình thường
            int newId = customerService.createCustomer(dto, user.getUserId());
            if (newId != 0) {
                String description = (phone != null && !phone.isBlank() ? "Created customer with phone: " + phone
                        : (null + ", ")) +
                        (email != null && !email.isBlank() ? ", with email: " + email : (null)) +
                        (gender != null && !gender.isBlank() ? ", with gender: " + gender : (null)) +
                        (birthday != null && birthday.isBefore(LocalDate.now())
                                ? ", with birthday: " + birthday.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
                                : null)
                        +

                        (source != null && !source.isBlank() ? ", from: " + source : (null)) +
                        (address != null && !address.isBlank() ? ", address: " + address : (null));
                CustomerActivityUtil.logCustomerActivity(newId, "CREATE", "Customer created", description + ".",
                        user);
            }

            // Lưu extra contacts nếu có
            String[] extraValues = req.getParameterValues("extraContactValue");
            String[] extraTypes = req.getParameterValues("extraContactType");

            if (extraValues != null && extraTypes != null) {
                List<ContactValidationResult> issues = customerService.saveExtraContacts(newId, extraTypes,
                        extraValues);

                List<ContactValidationResult> contactConflicts = issues.stream()
                        .filter(ContactValidationResult::isConflictOther)
                        .collect(Collectors.toList());

                if (!contactConflicts.isEmpty()) {
                    req.getSession().setAttribute("contactConflictWarning", contactConflicts);
                    resp.sendRedirect(req.getContextPath()
                            + "/customers/edit?customerId=" + newId
                            + "&status=contact-conflict");
                    return;
                }

                List<ContactValidationResult> formatOrSelfIssues = issues.stream()
                        .filter(r -> r.getStatus() == ContactValidationResult.Status.INVALID_FORMAT
                                || r.getStatus() == ContactValidationResult.Status.DUPLICATE_SELF)
                        .collect(Collectors.toList());

                if (!formatOrSelfIssues.isEmpty()) {
                    req.getSession().setAttribute("contactWarnings", formatOrSelfIssues);
                    resp.sendRedirect(req.getContextPath()
                            + "/customers/edit?customerId=" + newId
                            + "&status=contact-warning");
                    return;
                }
            }

            // Tất cả OK — chỉ có 1 sendRedirect duy nhất ở đây
            resp.sendRedirect(req.getContextPath()
                    + "/customers/detail?customerId=" + newId);

        } catch (SQLException e) {
            log("DB error", e);
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
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
            String source, String address, String[] selectedTags)
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
        if (value == null)
            return null;
        return value.trim().isEmpty() ? null : value.trim();
    }

    private BigDecimal parseDecimalValidated(String value, String fieldName,
            Map<String, String> errors) {
        if (value == null || value.isBlank())
            return null;
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