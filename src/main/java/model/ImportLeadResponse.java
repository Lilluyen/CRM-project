package model;

import java.util.ArrayList;
import java.util.List;

/**
 * Response khi import leads
 */
public class ImportLeadResponse {

    private boolean success;
    private int totalImported;
    private int totalLinked;  // Lead cũ được gắn vào campaign mới
    private int totalFailed;
    private String message;
    private List<String> errors; // Danh sách lỗi chi tiết

    public ImportLeadResponse() {
        this.errors = new ArrayList<>();
    }

    public ImportLeadResponse(boolean success, int totalImported, int totalFailed, String message) {
        this.success = success;
        this.totalImported = totalImported;
        this.totalFailed = totalFailed;
        this.message = message;
        this.errors = new ArrayList<>();
    }

    public int getTotalLinked() {
        return totalLinked;
    }

    public void setTotalLinked(int totalLinked) {
        this.totalLinked = totalLinked;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public int getTotalImported() {
        return totalImported;
    }

    public void setTotalImported(int totalImported) {
        this.totalImported = totalImported;
    }

    public int getTotalFailed() {
        return totalFailed;
    }

    public void setTotalFailed(int totalFailed) {
        this.totalFailed = totalFailed;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<String> getErrors() {
        return errors;
    }

    public void setErrors(List<String> errors) {
        this.errors = errors;
    }

    public void addError(String error) {
        this.errors.add(error);
    }
}
