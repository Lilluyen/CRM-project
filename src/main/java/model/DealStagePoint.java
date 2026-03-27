package model;

public class DealStagePoint {
    private final String stage;
    private final int total;

    public DealStagePoint(String stage, int total) {
        this.stage = stage;
        this.total = total;
    }

    public String getStage() {
        return stage;
    }

    public int getTotal() {
        return total;
    }
}
