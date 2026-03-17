package controller.manager;

import dao.*;
import dto.CustomerCreateDTO;
import exception.DuplicateEmailException;
import exception.DuplicatePhoneException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;

@WebServlet(name = "UpdateCustomerController", urlPatterns = {"/customers/edit"})
public class UpdateCustomerController extends HttpServlet {

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

            String heightRaw = trim(request.getParameter("height"));
            String weightRaw = trim(request.getParameter("weight"));
            String preferredSize = request.getParameter("preferred_size");
            String bustRaw = trim(request.getParameter("bust"));
            String waistRaw = trim(request.getParameter("waist"));
            String hipsRaw = trim(request.getParameter("hips"));
            String shoulderRaw = trim(request.getParameter("shoulder"));
            String bodyShape = request.getParameter("bodyShape");

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
            } else if (!phone.matches("^[0-9]{9,15}$")) {
                fieldErrors.put("phone", "Phone must be 9–15 digits.");
            }

            // Email
            if (email == null || email.isBlank()) {
                fieldErrors.put("email", "Email is required.");
            } else if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
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

            // Measurements (optional, positive only)
            BigDecimal height = parseDecimalValidated(heightRaw, "height", fieldErrors);
            BigDecimal weight = parseDecimalValidated(weightRaw, "weight", fieldErrors);
            BigDecimal bust = parseDecimalValidated(bustRaw, "bust", fieldErrors);
            BigDecimal waist = parseDecimalValidated(waistRaw, "waist", fieldErrors);
            BigDecimal hips = parseDecimalValidated(hipsRaw, "hips", fieldErrors);
            BigDecimal shoulder = parseDecimalValidated(shoulderRaw, "shoulder", fieldErrors);

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
                request.setAttribute("oldHeight", heightRaw);
                request.setAttribute("oldWeight", weightRaw);
                request.setAttribute("oldPreferredSize", preferredSize);
                request.setAttribute("oldBust", bustRaw);
                request.setAttribute("oldWaist", waistRaw);
                request.setAttribute("oldHips", hipsRaw);
                request.setAttribute("oldShoulder", shoulderRaw);
                request.setAttribute("oldBodyShape", bodyShape);

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
            dto.setCustomer_id(customerId);
            dto.setName(name);
            dto.setPhone(phone);
            dto.setEmail(email);
            dto.setGender(gender);
            dto.setBirthday(birthday);
            dto.setAddress(address);
            dto.setSource(source);
            dto.setStyleTags(tagIds);
            dto.setHeight(height);
            dto.setWeight(weight);
            dto.setPreferredSize(preferredSize);
            dto.setBust(bust);
            dto.setWaist(waist);
            dto.setHips(hips);
            dto.setShoulder(shoulder);
            dto.setBodyShape(bodyShape);

            customerService.updateCustomer(dto, customerId);
            response.sendRedirect(
                    request.getContextPath() + "/customers/detail?customerId=" + customerId);

        } catch (DuplicateEmailException e) {
            Map<String, String> fieldErrors = new LinkedHashMap<>();
            fieldErrors.put("email", "This email is already registered.");
            reloadFormData(request, customerId, fieldErrors, null);
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (DuplicatePhoneException e) {
            Map<String, String> fieldErrors = new LinkedHashMap<>();
            fieldErrors.put("phone", "This phone number is already registered.");
            reloadFormData(request, customerId, fieldErrors, null);
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

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