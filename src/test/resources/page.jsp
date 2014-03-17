<%@ page language="java"  pageEncoding="utf-8"%>
<%@include file="/WEB-INF/commons/taglibs.jsp" %>
<input type="hidden" name="currentPage" id="currentPage" value="${page.currentPage}"/>
<select name="pageSize" id="pageSize">
		<option value="20">20</option>
		<option value="50">50</option>
		<option value="100">100</option>
</select>
共有${page.totalCount }条记录，第${page.currentPage }页, 共有 ${page.totalPages}页
<a href="javascript:mimo.jumpPage(1)">首页</a>
<c:if test="${page.currentPage gt 1}"><a href="javascript:mimo.jumpPage(${page.currentPage-1})">上一页</a> </c:if>
<c:if test="${page.totalPages gt page.currentPage}"><a href="javascript:mimo.jumpPage(${page.currentPage+1 })">下一页</a></c:if>
<a href="javascript:mimo.jumpPage(${page.totalPages })">末页</a>
<script type="text/javascript">
$(document).ready(function(){
	$("#pageSize").val(${page.pageSize});
});
</script>