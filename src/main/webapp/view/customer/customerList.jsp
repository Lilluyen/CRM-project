<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8" />
        <title>Customer List | Clothes CRM</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link rel="stylesheet" href="../assets/css/customerList.css"/>
    </head>


    <body>

        <div class="layout container-fluid">

            <div class="row">
                <div class="sidebar col-2">
                    <h2>Menu</h2>
                    <ul>
                        <li><a href="#">Dashboard</a></li>
                        <li><a href="#">Khách hàng</a></li>
                        <li><a href="#">Đơn hàng</a></li>
                        <li><a href="#">Sản phẩm</a></li>
                        <li><a href="#">Báo cáo</a></li>
                    </ul>

                </div>

                <div class="content col-10">

                    <h1>Khách hàng trung tâm</h1>
                    <div class="sub">Quản lý ${fn:length(customerList)} khách hàng & hồ sơ vóc dáng</div>

                    <div class="top-bar">
                        <div>
                            <div class="search-box">
                                <input type="text" placeholder="Tìm theo tên, SĐT hoặc Gu thời trang..."/>
                                <button class="btn btn-filter">Lọc</button>
                            </div>
                        </div>

                        <button class="btn btn-add">+ Thêm khách mới</button>
                    </div>

                    <div class="card">

                        <table>
                            <thead>
                                <tr>
                                    <th>Khách hàng</th>
                                    <th>Hạng & RFM</th>
                                    <th>Số đo (Fit)</th>
                                    <th>Gu & Sở thích</th>
                                    <th>Hoàn hàng</th>
                                    <th>Mua cuối</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${customerList}">
                                    <tr class="card-body-row">

                                        <!-- Customer -->
                                        <td class="customer-info">
                                            <div class="avatar">
                                                <c:if test="${not empty c.name}">
                                                    ${fn:toUpperCase(fn:substring(c.name,0,2))}
                                                </c:if>
                                            </div>
                                            <div>
                                                <div><strong>${c.name}</strong></div>
                                                <div class="muted">${c.phone}</div>
                                            </div>
                                        </td>

                                        <!-- Loyalty -->
                                        <td >
                                            <span class="loyalty-badge
                                                  <c:choose>
                                                      <c:when test="${c.loyaltyTier == 'GOLD'}">gold</c:when>
                                                      <c:when test="${c.loyaltyTier == 'BLACKLIST'}">blacklist</c:when>
                                                  </c:choose>">
                                                ${c.loyaltyTier}
                                            </span>
                                            <div class="muted">RFM Score: ${c.rfmScore}</div>
                                        </td>

                                        <!-- Fit -->
                                        <td >
                                            <div><strong>${c.preferredSize}</strong></div>
                                            <div class="muted">${c.bodyShape}</div>
                                        </td>

                                        <!-- Tags -->
                                        <td class="tags" >
                                            <c:forEach items="${c.styleTags}" var="tag">
                                                <span>${tag}</span>
                                            </c:forEach>
                                        </td>

                                        <!-- Return -->
                                        <td >
                                            <div>${c.returnRate}%</div>

                                            <div class="progress">
                                                <div class="progress-bar
                                                     <c:if test="${c.returnRate > 30}">high-return</c:if>"
                                                     style="width:${c.returnRate}%">
                                                </div>
                                            </div>
                                        </td>

                                        <!-- Last purchase -->
                                        <td >
                                            ${c.lastPurchase}
                                        </td>

                                        <%-- Thêm cột thao tác vào cuối bảng --%>

                                        <td class="actions">
                                            <i class="fa-regular fa-eye" title="Chi tiết"></i>
                                            <i class="fa-solid fa-shirt" title="Gợi ý phối đồ"></i>
                                            <i class="fa-solid fa-ellipsis-vertical"></i>
                                        </td>
                                    </tr>


                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div id="customerModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Hồ sơ khách hàng mới</h2>
                    <span class="close-btn" onclick="toggleModal()">&times;</span>
                </div>

                <form id="addCustomerForm">
                    <div class="form-section">
                        <h3><i class="fas fa-id-card"></i> Thông tin cơ bản</h3>
                        <div class="grid-2">
                            <div class="input-group">
                                <label>Họ và tên *</label>
                                <input
                                    type="text"
                                    name="name"
                                    placeholder="Vd: Nguyễn Lan Anh"
                                    required />
                            </div>
                            <div class="input-group">
                                <label>Số điện thoại *</label>
                                <input
                                    type="tel"
                                    name="phone"
                                    placeholder="Vd: 0901234567"
                                    required />
                            </div>
                        </div>
                        <div class="grid-2">
                            <div class="input-group">
                                <label>Email</label>
                                <input
                                    type="email"
                                    name="email"
                                    placeholder="example@gmail.com" />
                            </div>
                            <div class="input-group">
                                <label>Ngày sinh</label>
                                <input type="date" name="birthday" />
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h3>
                            <i class="fas fa-ruler-combined"></i> Chỉ số vóc dáng (Fit
                            Profile)
                        </h3>
                        <div class="grid-3">
                            <div class="input-group">
                                <label>Chiều cao (cm)</label>
                                <input type="number" name="height" placeholder="165" />
                            </div>
                            <div class="input-group">
                                <label>Cân nặng (kg)</label>
                                <input type="number" name="weight" placeholder="55" />
                            </div>
                            <div class="input-group">
                                <label>Size ưu tiên</label>
                                <select name="preferred_size">
                                    <option value="S">Size S</option>
                                    <option value="M" selected>Size M</option>
                                    <option value="L">Size L</option>
                                    <option value="XL">Size XL</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h3><i class="fas fa-tshirt"></i> Sở thích & Gu</h3>
                        <div class="tag-selector">
                            <label><input type="checkbox" value="#Vintage" /> #Vintage</label>
                            <label
                                ><input type="checkbox" value="#Minimalism" />
                                #Minimalism</label
                            >
                            <label><input type="checkbox" value="#Office" /> #Office</label>
                            <label
                                ><input type="checkbox" value="#Streetwear" />
                                #Streetwear</label
                            >
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn-cancel" onclick="toggleModal()">
                            Hủy bỏ
                        </button>
                        <button type="submit" class="btn-save">Lưu hồ sơ</button>
                    </div>
                </form>
            </div>
        </div>


        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                function toggleModal() {
                    const modal = document.getElementById("customerModal");
                    modal.style.display =
                            modal.style.display === "block" ? "none" : "block";
                }

                // Gắn sự kiện cho nút "Thêm khách mới" ở trang danh sách
                document.querySelector(".btn-add").addEventListener("click", toggleModal);
        </script>
    </body>
</html>

