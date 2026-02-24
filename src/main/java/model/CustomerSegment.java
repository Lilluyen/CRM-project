package model;

public class CustomerSegment {

    private int segmentId;
    private String segmentName;
    private String criteriaLogic;

    public CustomerSegment() {
    }

    public int getSegmentId() {
        return segmentId;
    }

    public void setSegmentId(int segmentId) {
        this.segmentId = segmentId;
    }

    public String getSegmentName() {
        return segmentName;
    }

    public void setSegmentName(String segmentName) {
        this.segmentName = segmentName;
    }

    public String getCriteriaLogic() {
        return criteriaLogic;
    }

    public void setCriteriaLogic(String criteriaLogic) {
        this.criteriaLogic = criteriaLogic;
    }
}