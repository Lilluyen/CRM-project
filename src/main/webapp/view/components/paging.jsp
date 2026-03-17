<%--
  paging.jsp ? Reusable pagination bar.

  Required request attributes (set by the controller before forwarding):
    currentPage  (int)  ? 1-based current page number
    totalPages   (int)  ? total number of pages
    totalRecords (int)  ? total matching records
    pageSize     (int)  ? records per page  (optional, for display)

  Optional request attributes:
    pagingFormId (String) ? id of the <form> to submit when changing page
                            (default: "searchForm")

  Usage in a JSP that already has a search <form id="searchForm">:
    <%@ include file="/frontend/paging.jsp" %>

  The form must contain:
    <input type="hidden" name="page" id="h_page" value="1">

  Alternatively this component can also build GET URL links if no form is present
  by appending ?page=N to the current query string.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>
<%
    int _cp  = request.getAttribute("currentPage")  != null ? (Integer) request.getAttribute("currentPage")  : 1;
    int _tp  = request.getAttribute("totalPages")   != null ? (Integer) request.getAttribute("totalPages")   : 1;
    int _tr  = request.getAttribute("totalRecords") != null ? (Integer) request.getAttribute("totalRecords") : 0;
    int _ps  = request.getAttribute("pageSize")     != null ? (Integer) request.getAttribute("pageSize")     : 10;
    String _formId = request.getAttribute("pagingFormId") != null
                   ? (String) request.getAttribute("pagingFormId")
                   : "searchForm";
    int _from = (_cp - 1) * _ps + 1;
    int _to   = Math.min(_cp * _ps, _tr);
    if (_tr == 0) { _from = 0; _to = 0; }
    pageContext.setAttribute("_cp",  _cp);
    pageContext.setAttribute("_tp",  _tp);
    pageContext.setAttribute("_tr",  _tr);
    pageContext.setAttribute("_from",_from);
    pageContext.setAttribute("_to",  _to);
    pageContext.setAttribute("_fid", _formId);
%>
<c:if test="${_tp > 0}">
<div class="d-flex align-items-center justify-content-between flex-wrap gap-2">

  <!-- Record count summary -->
  <div class="text-muted small">
    <c:choose>
      <c:when test="${_tr == 0}">No records found</c:when>
      <c:otherwise>
        Showing <strong>${_from}</strong>?<strong>${_to}</strong>
        of <strong>${_tr}</strong> record<c:if test="${_tr != 1}">s</c:if>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- Pagination links -->
  <c:if test="${_tp > 1}">
  <nav aria-label="Page navigation">
    <ul class="pagination pagination-sm mb-0">

      <%-- First --%>
      <li class="page-item${_cp == 1 ? ' disabled' : ''}">
        <a class="page-link" href="javascript:void(0);"
           onclick="goPage(1, '${_fid}')" aria-label="First">&laquo;</a>
      </li>

      <%-- Previous --%>
      <li class="page-item${_cp == 1 ? ' disabled' : ''}">
        <a class="page-link" href="javascript:void(0);"
           onclick="goPage(${_cp - 1}, '${_fid}')" aria-label="Previous">&lsaquo;</a>
      </li>

      <%-- Window: show up to 5 pages around current --%>
      <%
          int _win  = 2;   // pages on each side of current
          int _lo   = Math.max(1, _cp - _win);
          int _hi   = Math.min(_tp, _cp + _win);
          // extend window when near edges
          if (_cp - _win < 1)  _hi = Math.min(_tp, _hi + (_win - (_cp - 1)));
          if (_cp + _win > _tp) _lo = Math.max(1,  _lo - (_win - (_tp - _cp)));
          for (int _i = _lo; _i <= _hi; _i++) {
              pageContext.setAttribute("_pi", _i);
              pageContext.setAttribute("_active", (_i == _cp));
      %>
      <li class="page-item${_active ? ' active' : ''}">
        <a class="page-link" href="javascript:void(0);"
           onclick="goPage(${_pi}, '${_fid}')">${_pi}</a>
      </li>
      <% } %>

      <%-- Next --%>
      <li class="page-item${_cp == _tp ? ' disabled' : ''}">
        <a class="page-link" href="javascript:void(0);"
           onclick="goPage(${_cp + 1}, '${_fid}')" aria-label="Next">&rsaquo;</a>
      </li>

      <%-- Last --%>
      <li class="page-item${_cp == _tp ? ' disabled' : ''}">
        <a class="page-link" href="javascript:void(0);"
           onclick="goPage(${_tp}, '${_fid}')" aria-label="Last">&raquo;</a>
      </li>

    </ul>
  </nav>
  </c:if>

</div>
</c:if>

<script>
/**
 * goPage(pageNum, formId)
 * Sets the hidden #h_page input and submits the search form.
 * Requires: the containing <form> has <input type="hidden" name="page" id="h_page">
 */
function goPage(pageNum, formId) {
    var form = document.getElementById(formId || 'searchForm');
    if (!form) return;
    var inp = document.getElementById('h_page');
    if (inp) inp.value = pageNum;
    form.submit();
}
</script>
