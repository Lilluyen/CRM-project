package dto;

import java.time.LocalDate;


public class TimeCondition {

    private String field;
    private String operator;
    private LocalDate date;
    private String subCondition;

    public TimeCondition(String field, String operator, LocalDate date, String subCondition) {
        this.field = field;
        this.operator = operator;
        this.date = date;
        this.subCondition = subCondition;
    }

    public String getField() {
        return field;
    }

    public void setField(String field) {
        this.field = field;
    }

    public String getSubCondition() {
        return subCondition;
    }

    public void setSubCondition(String subCondition) {
        this.subCondition = subCondition;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getOperator() {
        return operator;
    }

    public void setOperator(String operator) {
        this.operator = operator;
    }
}