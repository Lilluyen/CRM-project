package controller.manager;

import dao.*;
import dto.ConflictResult;
import dto.CustomerCreateDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ContactValidationResult;
import service.CustomerService;
import util.PhoneCheck;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "UpdateCustomerController", urlPatterns = {"/customers/edit"})
public class UpdateCustomerController extends HttpServlet {

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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerIdRaw = request.getParameter("customerId");
        if (customerIdRaw == null) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdRaw);
            reloadFormData(request, customerId, null, null);
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerIdRaw = request.getParameter("customerId");
        int customerId;

        try {
            customerId = Integer.parseInt(customerIdRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
            return;
        }

        try {
            request.setCharacterEncoding("UTF-8");

            // ── Read raw values ──────────────────────────────────────────
            String name = trim(request.getParameter("name"));
            String phone = trim(request.getParameter("phone"));
            String email = trim(request.getParameter("email"));
            String gender = trim(request.getParameter("gender"));
            String birthdayRaw = trim(request.getParameter("birthday"));
            String address = trim(request.getParameter("address"));
            String source = trim(request.getParameter("source"));

            String[] tagIdsRaw = request.getParameterValues("tagIds");

            // ── Field-level error map ────────────────────────────────────
            Map<String, String> fieldErrors = new LinkedHashMap<>();

            // Name
            if (name == null || name.isBlank()) {
                fieldErrors.put("name", "Full name is required.");
            } else if (name.length() > 100) {
                fieldErrors.put("name", "Name must not exceed 100 characters.");
            }

            // Phone
            if (phone == null || phone.isBlank()) {
                fieldErrors.put("phone", "Phone number is required.");
            } else if (!PhoneCheck.isValidPhone(phone)) {
                fieldErrors.put("phone", "Phone is invalid.");
            }

            // Email
            if (email != null && !email.isBlank() && !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                fieldErrors.put("email", "Invalid email format.");
            }

            // Gender
            if (gender == null || gender.isBlank()) {
                fieldErrors.put("gender", "Please select a gender.");
            } else if (!gender.equalsIgnoreCase("MALE")
                    && !gender.equalsIgnoreCase("FEMALE")
                    && !gender.equalsIgnoreCase("OTHER")) {
                fieldErrors.put("gender", "Invalid gender value.");
            }

            // Birthday
            LocalDate birthday = null;
            if (birthdayRaw == null || birthdayRaw.isBlank()) {
                fieldErrors.put("birthday", "Date of birth is required.");
            } else {
                try {
                    birthday = LocalDate.parse(birthdayRaw);
                    if (birthday.isAfter(LocalDate.now())) {
                        fieldErrors.put("birthday", "Birthday must be in the past.");
                    }
                } catch (DateTimeParseException e) {
                    fieldErrors.put("birthday", "Invalid date format.");
                }
            }


            // ── If errors → reload form ──────────────────────────────────
            if (!fieldErrors.isEmpty()) {
                // Pass old values back
                request.setAttribute("oldName", name);
                request.setAttribute("oldPhone", phone);
                request.setAttribute("oldEmail", email);
                request.setAttribute("oldGender", gender);
                request.setAttribute("oldBirthday", birthdayRaw);
                request.setAttribute("oldSource", source);
                request.setAttribute("oldAddress", address);

                Set<String> selectedTagSet = new HashSet<>();
                if (tagIdsRaw != null) Collections.addAll(selectedTagSet, tagIdsRaw);
                request.setAttribute("selectedTags", selectedTagSet);

                reloadFormData(request, customerId, fieldErrors, null);
                request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
                return;
            }

            // ── Build DTO ────────────────────────────────────────────────
            List<Integer> tagIds = new ArrayList<>();
            if (tagIdsRaw != null) {
                for (String id : tagIdsRaw) tagIds.add(Integer.parseInt(id));
            }

            CustomerCreateDTO dto = new CustomerCreateDTO();
            dto.setCustomerId(customerId);
            dto.setName(name);
            dto.setPhone(phone);
            dto.setEmail(email);
            dto.setGender(gender);
            dto.setBirthday(birthday);
            dto.setAddress(address);
            dto.setSource(source);
            dto.setStyleTags(tagIds);

            ConflictResult conflict = customerService.checkDuplicate(dto, customerId);
            if (conflict != null) {
                conflict.setSource("update");
                conflict.setIncomingId(customerId);
                request.getSession().setAttribute("pendingConflict", conflict);
                response.sendRedirect(request.getContextPath() + "/customers/resolve-conflict");
                return;
            }

// Chỉ gọi 1 lần
            customerService.updateCustomer(dto, customerId);

// Validate và lưu extra contacts
            String[] extraValues = request.getParameterValues("extraContactValue");
            String[] extraTypes = request.getParameterValues("extraContactType");

            if (extraValues != null && extraTypes != null) {
                List<ContactValidationResult> issues =
                        customerService.saveExtraContacts(customerId, extraTypes, extraValues);

                List<ContactValidationResult> contactConflicts = issues.stream()
                        .filter(ContactValidationResult::isConflictOther)
                        .collect(Collectors.toList());

                if (!contactConflicts.isEmpty()) {
                    request.getSession().setAttribute("contactConflictWarning", contactConflicts);
                    response.sendRedirect(request.getContextPath()
                            + "/customers/edit?customerId=" + customerId
                            + "&status=contact-conflict");
                    return;
                }

                List<ContactValidationResult> formatOrSelfIssues = issues.stream()
                        .filter(r -> r.getStatus() == ContactValidationResult.Status.INVALID_FORMAT
                                || r.getStatus() == ContactValidationResult.Status.DUPLICATE_SELF)
                        .collect(Collectors.toList());

                if (!formatOrSelfIssues.isEmpty()) {
                    request.getSession().setAttribute("contactWarnings", formatOrSelfIssues);
                    response.sendRedirect(request.getContextPath()
                            + "/customers/edit?customerId=" + customerId
                            + "&status=contact-warning");
                    return;
                }
            }

// Tất cả OK — chỉ có 1 sendRedirect duy nhất ở đây
            response.sendRedirect(request.getContextPath()
                    + "/customers/detail?customerId=" + customerId);

        } catch (SQLException e) {
            log("DB error", e);
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
        } catch (Exception e) {
            log("Update customer error", e);
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
        }
    }

    // ── Reload form: always fetch fresh customer data from DB ─────────────
    private void reloadFormData(HttpServletRequest request, int customerId,
                                Map<String, String> fieldErrors, String globalMessage)
            throws ServletException {
        try {
            request.setAttribute("customerDetail",
                    customerService.getCustomerDetail(customerId));
            request.setAttribute("allStyleTags",
                    customerService.getListStyleTags());
            if (fieldErrors != null) {
                request.setAttribute("fieldErrors", fieldErrors);
            }
            if (globalMessage != null) {
                request.setAttribute("globalError", globalMessage);
            }
            request.setAttribute("pageTitle", "Customer Edit | Clothes CRM");
            request.setAttribute("contentPage", "customer/edit_customer.jsp");
            request.setAttribute("pageCss", "customer-add.css");
            request.setAttribute("page", "customer-add");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────
    private String trim(String value) {
        if (value == null) return null;
        return value.trim().isEmpty() ? null : value.trim();
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