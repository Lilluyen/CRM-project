/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;
import java.io.File;
import java.util.Properties;

/**
 * Email service for sending emails with support for plain text, HTML content,
 * file attachments, and email templates.
 *
 * Configuration is loaded from email.properties file in the classpath.
 *
 * @author Pham Minh Quan
 */
public class EmailService {
    private static Session session;

    static {
        initializeSession();
    }

    /**
     * Initialize mail session with SMTP configuration
     */
    private static void initializeSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", EmailConfig.getSmtpHost());
        props.put("mail.smtp.port", EmailConfig.getSmtpPort());
        props.put("mail.smtp.auth", EmailConfig.isSmtpAuthEnabled());
        props.put("mail.smtp.starttls.enable", EmailConfig.isStartTlsEnabled());
        props.put("mail.smtp.starttls.required", EmailConfig.isStartTlsRequired());
        props.put("mail.smtp.connectiontimeout", 5000);
        props.put("mail.smtp.timeout", 5000);

        Authenticator auth = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(
                        EmailConfig.getSmtpUser(),
                        EmailConfig.getSmtpPassword()
                );
            }
        };

        session = Session.getInstance(props, auth);
    }

    /**
     * Send a simple email with the provided Email object
     *
     * @param email Email object containing recipient, subject, and body
     * @return true if email was sent successfully, false otherwise
     */
    public static boolean send(Email email) {
        try {
            email.validate();
            MimeMessage message = createMimeMessage(email);
            Transport.send(message);
            System.out.println("Email sent successfully to: " + email.getTo());
            return true;
        } catch (MessagingException e) {
            System.err.println("Failed to send email: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (IllegalArgumentException e) {
            System.err.println("Email validation error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Send multiple emails
     *
     * @param emails List of Email objects
     * @return number of emails sent successfully
     */
    public static int sendBatch(java.util.List<Email> emails) {
        int successCount = 0;
        for (Email email : emails) {
            if (send(email)) {
                successCount++;
            }
        }
        return successCount;
    }

    /**
     * Send an email using a template with variables
     *
     * @param to Recipient email address
     * @param subject Email subject
     * @param template EmailTemplate object with variables
     * @param isHtml Whether the rendered template should be treated as HTML
     * @return true if email was sent successfully
     */
    public static boolean sendFromTemplate(String to, String subject,
                                          EmailTemplate template, boolean isHtml) {
        Email email = new Email();
        email.setTo(to);
        email.setSubject(subject);

        String renderedContent = template.render();
        if (isHtml) {
            email.setBodyHtml(renderedContent);
        } else {
            email.setBodyText(renderedContent);
        }

        return send(email);
    }

    /**
     * Create a MimeMessage from an Email object
     *
     * @param email Email object
     * @return MimeMessage ready to be sent
     * @throws MessagingException if message creation fails
     */
    private static MimeMessage createMimeMessage(Email email) throws MessagingException {
        MimeMessage message = new MimeMessage(session);

        // Set sender
        message.setFrom(new InternetAddress(
                EmailConfig.getFromAddress(),
                EmailConfig.getFromName()
        ));

        // Set recipient
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email.getTo()));

        // Set CC if provided
        if (email.getCc() != null && !email.getCc().trim().isEmpty()) {
            message.setRecipients(Message.RecipientType.CC, InternetAddress.parse(email.getCc()));
        }

        // Set BCC if provided
        if (email.getBcc() != null && !email.getBcc().trim().isEmpty()) {
            message.setRecipients(Message.RecipientType.BCC, InternetAddress.parse(email.getBcc()));
        }

        // Set subject
        message.setSubject(email.getSubject(), "UTF-8");

        // Set content based on email type and attachments
        if (email.getAttachments().isEmpty()) {
            // No attachments, simple message
            if (email.isHtml()) {
                message.setContent(email.getBodyHtml(), "text/html; charset=UTF-8");
            } else {
                message.setText(email.getBodyText(), "UTF-8");
            }
        } else {
            // With attachments, use multipart
            MimeMultipart multipart = new MimeMultipart();

            // Add body part
            MimeBodyPart bodyPart = new MimeBodyPart();
            if (email.isHtml()) {
                bodyPart.setContent(email.getBodyHtml(), "text/html; charset=UTF-8");
            } else {
                bodyPart.setText(email.getBodyText(), "UTF-8");
            }
            multipart.addBodyPart(bodyPart);

            // Add attachments
            for (File attachment : email.getAttachments()) {
                MimeBodyPart attachmentPart = new MimeBodyPart();
                attachmentPart.attachFile(attachment);
                multipart.addBodyPart(attachmentPart);
            }

            message.setContent(multipart);
        }

        // Set timestamp
        message.setSentDate(new java.util.Date());

        return message;
    }

    /**
     * Check if SMTP connection is working
     *
     * @return true if connection is successful
     */
    public static boolean testConnection() {
        try {
            Transport transport = session.getTransport("smtp");
            transport.connect();
            transport.close();
            System.out.println("SMTP connection test successful");
            return true;
        } catch (MessagingException e) {
            System.err.println("SMTP connection test failed: " + e.getMessage());
            return false;
        }
    }
}
