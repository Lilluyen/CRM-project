package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet(urlPatterns = "/customers/segments")
public class CustomerSegmentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate monthA = LocalDate.now().withDayOfMonth(1);
        LocalDate monthB = monthA.minusMonths(1);

        // Layout attributes
        request.setAttribute("pageTitle", "Customer Segments | Clothes CRM");
        request.setAttribute("contentPage", "customer/segment_customer.jsp");
        request.setAttribute("pageCss", "segment_customer.css");
        request.setAttribute("pageJs", "SegmentCustomer.js");
        request.setAttribute("page", "customer-segments");

        request.getRequestDispatcher("/view/layout.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

}
