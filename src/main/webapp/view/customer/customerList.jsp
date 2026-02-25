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

        <link href="${pageContext.request.contextPath}/assets/css/customerList.css" rel="stylesheet" type="text/css"/>
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

                                        <td class="tags">
                                            <c:forEach items="${c.styleTags}" var="tag" begin="0" end="1">
                                                <span class="tag">${tag}</span>
                                            </c:forEach>

                                            <!-- Nếu còn tag khác thì hiển thị dấu ... -->
                                            <c:if test="${fn:length(c.styleTags) > 2}">
                                                <span class="more">...</span>
                                            </c:if>
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

                <form id="addCustomerForm" method="post" action="${pageContext.request.contextPath}/customers/add-customer">
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
                            <div class="input-group">
                                <label>Giới tính *</label>
                                <select name="gender" required>
                                    <option value="">Chọn giới tính</option>
                                    <option value="MALE">Nam</option>
                                    <option value="FEMALE">Nữ</option>
                                    <option value="OTHER">Khác</option>
                                </select>
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
                        <div class="input-group">
                            <label>Social link</label>
                            <input type="text" name="socialLink" placeholder="Vd: https://www.facebook.com/username">
                        </div>
                        <div class="input-group">
                            <label>Address</label>
                            <input type="text" name="address" placeholder="Vd: 123 Đường ABC, Quận XYZ, TP. HCM">
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

                            <div class="input-group">
                                <label>Bust (cm)</label>
                                <input type="number" name="bust" placeholder="85" />
                            </div>

                            <div class="input-group">
                                <label>Waist (cm)</label>
                                <input type="number" name="waist" placeholder="70" />
                            </div>

                            <div class="input-group">
                                <label>Hips (cm)</label>
                                <input type="number" name="hips" placeholder="90" />
                            </div>
                            <div class="input-group">
                                <label>Shoulder (cm)</label>
                                <input type="number" name="shoulder" placeholder="40" />
                            </div>

                            <div class="input-group">
                                <label>Body shape</label>
                                <select name="bodyShape">
                                    <option value="HOURGLASS">Đồng hồ cát</option>
                                    <option value="PEAR">Trái lê</option>
                                    <option value="APPLE">Trái táo</option>
                                    <option value="RECTANGLE">Chữ nhật</option>
                                    <option value="INVERTED_TRIANGLE">Tam giác ngược</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h3><i class="fas fa-tshirt"></i> Sở thích & Gu</h3>
                        <div class="tag-selector">
                            <c:forEach items="${styleTagList}" var="s" varStatus="loop">
                                <label class="tag-item ${loop.index >= 10 ? 'extra-tag' : ''}">
                                    <input type="checkbox" name="styleTags" value="${s.tagId}" /> ${s.tagName}
                                </label>
                            </c:forEach>
                        </div>
                        <button type="button" id="toggleTags" class="see-more-btn">See more</button>
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

        <div id="toast" class="toast">
            <div class="toast-left">
                <div id="toastIcon" class="toast-icon"></div>
            </div>

            <div class="toast-content">
                <div id="toastMessage" class="toast-message"></div>
            </div>

            <button class="toast-close" onclick="hideToast()">×</button>

            <div class="toast-progress">
                <div id="toastBar"></div>
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


                // Gắn sự kiện xem more tag và less tag
                const toggleBtn = document.getElementById("toggleTags");
                const extraTags = document.querySelectorAll(".extra-tag");

                let expanded = false;

                toggleBtn.addEventListener("click", function () {
                    expanded = !expanded;

                    extraTags.forEach(tag => {
                        tag.style.display = expanded ? "inline-block" : "none";
                    });

                    toggleBtn.textContent = expanded ? "See less" : "See more";
                });


                // thông báo create customer thành công hoặc failed
                let startTime = 0;
                const duration = 3200; // thời gian sống cố định
                let paused = false;
                let pauseStartedAt = 0;
                let rafId = null;

                const toast = document.getElementById("toast");
                const bar = document.getElementById("toastBar");

                function showToast(type, message) {
                    cancelAnimationFrame(rafId);

                    toast.classList.remove("hide");
                    void toast.offsetWidth; // reset animation

                    document.getElementById("toastMessage").innerText = message;

                    if (type === "success") {
                        document.getElementById("toastIcon").innerHTML =
                                `<svg fill="#22c55e" viewBox="0 0 24 24">
            <path d="M9 16.2l-3.5-3.5L4 14.2l5 5 11-11-1.5-1.5z"/>
        </svg>`;
                        bar.style.background = "#22c55e";
                    } else {
                        document.getElementById("toastIcon").innerHTML =
                                `<svg fill="#ef4444" viewBox="0 0 24 24">
            <path d="M18.3 5.71L12 12l6.3 6.29-1.41 1.41L10.59 13.41
                     4.29 19.7 2.88 18.29 9.17 12 2.88 5.71
                     4.29 4.29 10.59 10.59l6.3-6.3z"/>
        </svg>`;
                        bar.style.background = "#ef4444";
                    }

                    bar.style.transform = "scaleX(1)";
                    paused = false;

                    toast.classList.add("show");

                    startTime = performance.now();
                    rafId = requestAnimationFrame(animateBar);
                }

                function easeOutCubic(t) {
                    return 1 - Math.pow(1 - t, 3);
                }

                function animateBar(now) {
                    if (paused)
                        return;

                    const elapsed = now - startTime;
                    let progress = elapsed / duration;

                    progress = Math.min(progress, 1);
                    const eased = easeOutCubic(progress);

                    bar.style.transform = `scaleX(${1 - eased})`;

                    if (progress < 1) {
                        rafId = requestAnimationFrame(animateBar);
                    } else {
                        hideToast();
                    }
                }

                function hideToast() {
                    cancelAnimationFrame(rafId);
                    toast.classList.remove("show");
                    toast.classList.add("hide");
                }

                /* ===== Pause khi hover ===== */
                toast.addEventListener("mouseenter", () => {
                    if (!paused) {
                        paused = true;
                        pauseStartedAt = performance.now();
                    }
                });

                /* ===== Resume khi rời chuột ===== */
                toast.addEventListener("mouseleave", () => {
                    if (paused) {
                        paused = false;

                        const pauseDuration = performance.now() - pauseStartedAt;
                        startTime += pauseDuration; // bù lại thời gian bị pause

                        rafId = requestAnimationFrame(animateBar);
                    }
                });

                /* ===== Trigger từ server ===== */
                const status = "${param.status}";

                if (status === "success") {
                    showToast("success", "Create customer successfully");
                }

                if (status === "failed") {
                    showToast("error", "Create customer failed");
                }
        </script>
    </body>
</html>

