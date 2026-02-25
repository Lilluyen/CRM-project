package model;

public class CategoryProduct {

    private int categoryId;
    private int productId;

    public CategoryProduct() {
    }

    public CategoryProduct(int categoryId, int productId) {
        this.categoryId = categoryId;
        this.productId = productId;
    }

    // Getters and Setters
    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }
}
