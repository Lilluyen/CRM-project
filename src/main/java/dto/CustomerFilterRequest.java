package dto;

import java.util.List;


public class CustomerFilterRequest {

    private int page;
    private int pageSize;
    private String keyword;

    private List<String> loyaltyTiers;
    private List<String> bodyShapes;
    private List<String> sizes;
    private List<Integer> tagIds;

    private String returnRateMode;

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public List<String> getLoyaltyTiers() {
        return loyaltyTiers;
    }

    public void setLoyaltyTiers(List<String> loyaltyTiers) {
        this.loyaltyTiers = loyaltyTiers;
    }

    public List<String> getBodyShapes() {
        return bodyShapes;
    }

    public void setBodyShapes(List<String> bodyShapes) {
        this.bodyShapes = bodyShapes;
    }

    public List<String> getSizes() {
        return sizes;
    }

    public void setSizes(List<String> sizes) {
        this.sizes = sizes;
    }

    public List<Integer> getTagIds() {
        return tagIds;
    }

    public void setTagIds(List<Integer> tagIds) {
        this.tagIds = tagIds;
    }

    public String getReturnRateMode() {
        return returnRateMode;
    }

    public void setReturnRateMode(String returnRateMode) {
        this.returnRateMode = returnRateMode;
    }

    
    
}