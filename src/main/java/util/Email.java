package util;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Email message builder and model
 * @author Pham Minh Quan
 */
public class Email {
    private String to;
    private String cc;
    private String bcc;
    private String subject;
    private String bodyText;
    private String bodyHtml;
    private List<File> attachments;
    private boolean isHtml;

    public Email() {
        this.attachments = new ArrayList<>();
        this.isHtml = false;
    }

    public Email setTo(String to) {
        this.to = to;
        return this;
    }

    public Email setCc(String cc) {
        this.cc = cc;
        return this;
    }

    public Email setBcc(String bcc) {
        this.bcc = bcc;
        return this;
    }

    public Email setSubject(String subject) {
        this.subject = subject;
        return this;
    }

    public Email setBodyText(String bodyText) {
        this.bodyText = bodyText;
        this.isHtml = false;
        return this;
    }

    public Email setBodyHtml(String bodyHtml) {
        this.bodyHtml = bodyHtml;
        this.isHtml = true;
        return this;
    }

    public Email addAttachment(File file) {
        if (file != null && file.exists()) {
            this.attachments.add(file);
        }
        return this;
    }

    public Email addAttachment(String filePath) {
        File file = new File(filePath);
        if (file.exists()) {
            this.attachments.add(file);
        }
        return this;
    }

    public String getTo() {
        return to;
    }

    public String getCc() {
        return cc;
    }

    public String getBcc() {
        return bcc;
    }

    public String getSubject() {
        return subject;
    }

    public String getBodyText() {
        return bodyText;
    }

    public String getBodyHtml() {
        return bodyHtml;
    }

    public List<File> getAttachments() {
        return attachments;
    }

    public boolean isHtml() {
        return isHtml;
    }

    public void validate() throws IllegalArgumentException {
        if (to == null || to.trim().isEmpty()) {
            throw new IllegalArgumentException("Recipient email address is required");
        }
        if (subject == null || subject.trim().isEmpty()) {
            throw new IllegalArgumentException("Email subject is required");
        }
        if ((bodyText == null || bodyText.trim().isEmpty()) &&
            (bodyHtml == null || bodyHtml.trim().isEmpty())) {
            throw new IllegalArgumentException("Email body is required (either text or HTML)");
        }
    }
}
