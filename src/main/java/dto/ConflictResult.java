package dto;

public class ConflictResult {

    private CustomerDetailDTO existingCustomer;
    private CustomerCreateDTO incomingData;
    private String conflictField;
    private String source;          // "create" hoặc "update"
    private Integer incomingId;

    public ConflictResult(CustomerDetailDTO existingCustomer, CustomerCreateDTO incomingData, String conflictField) {
        this.existingCustomer = existingCustomer;
        this.incomingData = incomingData;
        this.conflictField = conflictField;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public Integer getIncomingId() {
        return incomingId;
    }

    public void setIncomingId(Integer incomingId) {
        this.incomingId = incomingId;
    }

    public CustomerDetailDTO getExistingCustomer() {
        return existingCustomer;
    }

    public void setExistingCustomer(CustomerDetailDTO existingCustomer) {
        this.existingCustomer = existingCustomer;
    }

    public CustomerCreateDTO getIncomingData() {
        return incomingData;
    }

    public void setIncomingData(CustomerCreateDTO incomingData) {
        this.incomingData = incomingData;
    }

    public String getConflictField() {
        return conflictField;
    }

    public void setConflictField(String conflictField) {
        this.conflictField = conflictField;
    }
}
