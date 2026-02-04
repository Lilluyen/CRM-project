package model;

import java.time.LocalDateTime;

public class Feedback {
    private int feedbackId;
    private int ticketId;
    private int rating;
    private String comment;
    private LocalDateTime createdAt;

    public Feedback() {
    }

    public Feedback(int feedbackId, int ticketId, int rating, String comment,
                    LocalDateTime createdAt) {
        this.feedbackId = feedbackId;
        this.ticketId = ticketId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
