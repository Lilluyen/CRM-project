package controller.api;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import util.Email;
import util.EmailService;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet for handling email sending requests
 */
@WebServlet("/email/send")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 10,  // 10 MB
    maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
public class EmailSendServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get form parameters
            String to = request.getParameter("to");
            String cc = request.getParameter("cc");
            String bcc = request.getParameter("bcc");
            String subject = request.getParameter("subject");
            String body = request.getParameter("body");

            // Create Email object
            Email email = new Email();
            email.setTo(to);
            email.setSubject(subject);
            email.setBodyText(body);

            if (cc != null && !cc.trim().isEmpty()) {
                email.setCc(cc);
            }

            if (bcc != null && !bcc.trim().isEmpty()) {
                email.setBcc(bcc);
            }

            // Handle file attachments
            List<File> attachments = new ArrayList<>();
            for (Part part : request.getParts()) {
                if (part.getName().equals("attachments") && part.getSize() > 0) {
                    String fileName = getFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Save attachment to temporary file
                        File tempFile = File.createTempFile("email_attachment_", "_" + fileName);
                        part.write(tempFile.getAbsolutePath());
                        attachments.add(tempFile);
                    }
                }
            }

            if (!attachments.isEmpty()) {
                email.setAttachments(attachments);
            }

            // Send email
            boolean success = EmailService.send(email);

            // Clean up temporary files
            for (File attachment : attachments) {
                if (attachment.exists()) {
                    attachment.delete();
                }
            }

            if (success) {
                // Redirect back with success message
                response.sendRedirect(request.getContextPath() + "/send-email.jsp?status=success");
            } else {
                // Redirect back with error message
                response.sendRedirect(request.getContextPath() + "/send-email.jsp?status=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/send-email.jsp?status=error");
        }
    }

    /**
     * Extract filename from multipart header
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
}