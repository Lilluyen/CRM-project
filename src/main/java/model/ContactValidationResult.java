package model;

public class ContactValidationResult {
    public enum Status {OK, INVALID_FORMAT, DUPLICATE_SELF, CONFLICT_OTHER}

    private final Status status;
    private final String type;    // "PHONE" hoặc "EMAIL"
    private final String value;
    private final Integer conflictCustomerId; // chỉ có khi status = CONFLICT_OTHER

    public ContactValidationResult(Status status, String type, String value,
                                   Integer conflictCustomerId) {
        this.status = status;
        this.type = type;
        this.value = value;
        this.conflictCustomerId = conflictCustomerId;
    }

    public boolean isOk() {
        return status == Status.OK;
    }

    public boolean isConflictOther() {
        return status == Status.CONFLICT_OTHER;
    }

    public Status getStatus() {
        return status;
    }

    public String getType() {
        return type;
    }

    public String getValue() {
        return value;
    }

    public Integer getConflictCustomerId() {
        return conflictCustomerId;
    }
}
