package controller.manager;

import dto.CustomerCreateDTO;
import exception.DuplicateEmailException;
import exception.DuplicatePhoneException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.CustomerService;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "UpdateCustomerController", urlPatterns = { "/customers/edit" })
public class UpdateCustomerController extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerIdRaw = request.getParameter("customerId");

        if (customerIdRaw == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdRaw);

            request.setAttribute("customerDetail",
                    customerService.getCustomerDetail(customerId));

            request.setAttribute("allStyleTags",
                    customerService.getListStyleTags());

            // Layout attributes
            request.setAttribute("pageTitle", "Customer Edit | Clothes CRM");
            request.setAttribute("contentPage", "customer/edit_customer.jsp");
            request.setAttribute("pageCss", "customer-add.css");
            request.setAttribute("page", "customer-add");

            request.getRequestDispatcher("/view/layout.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<String> errors = new ArrayList<>();

        String customerIdRaw = request.getParameter("customerId");

        int customerId;
        try {
            customerId = Integer.parseInt(customerIdRaw);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Trim trước khi validate
        String name = request.getParameter("name") != null
                ? request.getParameter("name").trim() : null;

        String phone = request.getParameter("phone") != null
                ? request.getParameter("phone").trim() : null;

        String email = request.getParameter("email") != null
                ? request.getParameter("email").trim() : null;

        String gender = request.getParameter("gender");
        String birthdayRaw = request.getParameter("birthday");
        String address = request.getParameter("address");
        String socialLink = request.getParameter("socialLink");
        String[] tagIdsRaw = request.getParameterValues("tagIds");

        // ======================
        // VALIDATION
        // ======================

        if (name == null || name.isEmpty()) {
            errors.add("Name is required");
        }

        if (phone == null || phone.isEmpty()) {
            errors.add("Phone is required");
        } else if (!phone.matches("^[0-9]{9,11}$")) {
            errors.add("Phone must be 9-11 digits");
        }

        if (email == null || email.isEmpty()) {
            errors.add("Email is required");
        } else if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            errors.add("Invalid email format");
        }

        LocalDate birthday = null;

        if (birthdayRaw == null || birthdayRaw.isBlank()) {
            errors.add("Birthday is required");
        } else {
            try {
                birthday = LocalDate.parse(birthdayRaw);
                if (birthday.isAfter(LocalDate.now())) {
                    errors.add("Birthday must be in the past");
                }
            } catch (DateTimeParseException e) {
                errors.add("Invalid birthday format");
            }
        }

        if (gender == null ||
                (!gender.equalsIgnoreCase("Male") &&
                        !gender.equalsIgnoreCase("Female"))) {
            errors.add("Invalid gender");
        }

        // ======================
        // Nếu có lỗi → reload data
        // ======================
        if (!errors.isEmpty()) {

            reloadFormData(request, customerId);

            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/view/customer/edit_customer.jsp")
                    .forward(request, response);
            return;
        }

        try {
            List<Integer> tagIds = new ArrayList<>();

            if (tagIdsRaw != null) {
                for (String id : tagIdsRaw) {
                    tagIds.add(Integer.parseInt(id));
                }
            }

            CustomerCreateDTO dto = new CustomerCreateDTO();
            dto.setName(name);
            dto.setPhone(phone);
            dto.setEmail(email);
            dto.setGender(gender);
            dto.setBirthday(birthday);
            dto.setAddress(address);
            dto.setSocialLink(socialLink);
            dto.setStyleTags(tagIds);

            customerService.updateCustomer(dto, customerId);

            response.sendRedirect(
                    request.getContextPath()
                            + "/customers/detail?customerId=" + customerId);

        } catch (DuplicateEmailException e) {
            errors.add("Email already exists");
        } catch (DuplicatePhoneException e) {
            errors.add("Phone already exists");
        } catch (Exception e) {
            errors.add("System error: " + e.getMessage());
        }

        // Nếu exception xảy ra → reload lại form
        reloadFormData(request, customerId);

        request.setAttribute("errors", errors);
        request.getRequestDispatcher("/view/customer/edit_customer.jsp")
                .forward(request, response);
    }

    private void reloadFormData(HttpServletRequest request, int customerId)
            throws ServletException {

        try {
            request.setAttribute("customerDetail",
                    customerService.getCustomerDetail(customerId));

            request.setAttribute("allStyleTags",
                    customerService.getListStyleTags());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}