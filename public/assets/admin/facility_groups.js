//設備グループメンテナンスのjs
function initDialog(){$("#facilityGroupsDialog").dialog({modal:!0,autoOpen:!1,width:700,resizable:!1,open:function(e){openModalDialog()},close:function(e){closeModelDialog()},show:"clip",hide:"clip"}),$("#facilityGroupsSortDialog").dialog({modal:!0,autoOpen:!1,width:600,resizable:!1,open:function(e){openModalDialog()},close:function(e){closeModelDialog()},show:"clip",hide:"clip"}),$("#facilityGroupsDialog-add").click(function(){execute()}),$("#facilityGroupsDialog-cancel").click(function(){$("#facilityGroupsDialog").dialog("close")}),$("#facilities_up").click(function(){upItems("target_facilities")}),$("#facilities_down").click(function(){downItems("target_facilities")}),$("#facilities_add").click(function(){addItems("all_facilities","target_facilities")}),$("#facilities_remove").click(function(){removeItems("target_facilities")}),$("#sortFacilityGroupsBtn").click(function(){openSortDialog()}),$("#sort_up").click(function(){upItems("facilityGroups_to")}),$("#sort_down").click(function(){downItems("facilityGroups_to")}),$("#facilityGroupsSortDialog-execute").click(function(){executeSort()}),$("#facilityGroupsSortDialog-cancel").click(function(){$("#facilityGroupsSortDialog").dialog("close")})}function searchFacilityGroups(){var e={};e.name=$("#search_name").val(),setAjaxDefault(),$.ajax({type:"GET",url:"/ajax/facilityGroups/list",data:e}).then(function(e){render(e)})}function reSearchAndRender(){setAjaxDefault(),$.ajax({type:"GET",url:"/ajax/facilityGroups/refresh"}).then(function(e){render(e)})}function turnFacilityGroups(e,t){setAjaxDefault();var n={};n.page_no=e,$.ajax({type:"GET",url:t,data:n}).then(function(e){render(e)})}function render(e){$("#result_area").empty();var t=e.result;infoCheck(e);if(errorCheck(e)==0||t.total_count==0)return;var n=$("<div />").addClass("widget"),r=$("<div />").addClass("widget-header").append($("<h2 />").addClass("title").text("検索結果")),i=$("<div />").addClass("widget-content"),s=$("<div />").addClass("pager-area").append($("<span />").addClass("count").text("全"+t.total_count+"件")).append(t.link),o=$("<table />").attr({id:"result_list"}).addClass("result_table"),u=$("<tbody />"),a=$("<thead />").append($("<tr />").append($("<th />").text("設備グループ名").attr({width:"35%"})).append($("<th />").text("メモ")).append($("<th />").text("").attr({width:"50px"})));o.append(a),$.each(t.list,function(){var e=$("<input />").attr({type:"button",value:"削除"}).addClass("btn btn-danger btn-mini"),t=this.id,n=this.lock_version,r=this.name,i=escapeTextArea(this.memo),s=$("<a />").attr({href:"javascript:void(0)"}).text(r);s.click(function(){openEditDialog(t)}),e.click(function(){deleteFacilityGroups(t,n,r)});var o=$("<tr />");o.append($("<td />").append(s)).append($("<td />").html(i)).append($("<td />").append(e)),u.append(o)}),o.append(u),i.append(s).append(o),n.append(r).append(i),$("#result_area").append(n).addClass("onload")}function openEditDialog(e){var t="",n="";e==""?(t="設備グループ登録",n="登録する"):(t="設備グループ変更",n="変更する"),$("#ui-dialog-title-facilityGroupsDialog").empty(),$("#ui-dialog-title-facilityGroupsDialog").append(t),$("#facilityGroupsDialog-add").attr({value:n});var r={};r.resource_id=e,setAjaxDefault();var i;i=$.ajax({type:"GET",url:"/ajax/facilityGroups/show",data:r}),i.pipe(function(e){if(errorCheck(e)==0){if(e.status_code==-6)return reSearchAndRender();return}var t=e.result.detail,n=t.resource;$("#resource_name").val(n.name),$("#resource_memo").val(n.memo),$("#resource_lock_version").val(n.lock_version),$("#resource_id").val(n.id);var r=t.resource_conn_list;r==null&&(r=[]),$("#target_facilities").empty(),$.each(r,function(){$("#target_facilities").append($("<option />").attr({value:this.key}).text(this.value))}),reWriteSelect("target_facilities",new Array);var i=e.result.facilities_list;i==null&&(i=[]),$("#all_facilities").empty(),$.each(i,function(){$("#all_facilities").append($("<option />").attr({value:this.key}).text(this.value))}),reWriteSelect("all_facilities",new Array),prependDummyText("facilityGroupsDialog"),$("#facilityGroupsDialog").dialog("open"),removeDummyText("facilityGroupsDialog");return})}function execute(){var e=createExecuteParams();if(validate(e)==0)return;setAjaxDefault();var t;t=$.ajax({type:"POST",url:"/ajax/facilityGroups/save",data:e}),t.pipe(function(e){if(errorCheck(e)==0&&e.status_code==-1)return;return infoCheck(e),$("#facilityGroupsDialog").dialog("close"),reSearchAndRender()})}function createExecuteParams(){var e={};e.resource={};var t=e.resource;return t.name=$("#resource_name").val(),t.memo=$("#resource_memo").val(),t.id=$("#resource_id").val(),t.lock_version=$("#resource_lock_version").val(),e.child_ids=getSelectArray("target_facilities"),setToken(e),e}function validate(e){var t=new Validate,n=e.resource;return t.addRules({value:n.name,option:"required",error_args:"設備グループ名"}),t.addRules({value:n.name,option:"maxLength",error_args:"設備グループ名",size:128}),t.addRules({value:n.memo,option:"maxLength",error_args:"メモ",size:1024}),t.addRules({value:e.child_ids,option:"requiredList",error_args:"参加リソース"}),t.execute()}function deleteFacilityGroups(e,t,n){if(window.confirm("設備グループ「"+n+"」を削除します。本当によろしいですか？")==0)return;var r={};r.resource_id=e,r.lock_version=t,setToken(r),setAjaxDefault();var i;i=$.ajax({type:"POST",url:"/ajax/facilityGroups/destroy",data:r}),i.pipe(function(e){return errorCheck(e),infoCheck(e),reSearchAndRender()})}function openSortDialog(){return setAjaxDefault(),$.ajax({type:"GET",url:"/ajax/facilityGroups/get_sort_info"}).then(function(e){renderSortDialog(e)})}function renderSortDialog(e){$("#facilityGroups_to").empty();if(errorCheck(e)==0)return;infoCheck(e);var t=e.result;if(t.length==0)return;$.each(t,function(){var e=this.id,t=this.name;$("#facilityGroups_to").append($("<option />").attr({value:e}).text(t))}),reWriteSelect("facilityGroups_to",new Array),prependDummyText("facilityGroupsSortDialog"),$("#facilityGroupsSortDialog").dialog("open"),removeDummyText("facilityGroupsSortDialog")}function executeSort(){var e={};e.ids=getSelectArray("facilityGroups_to"),setToken(e),setAjaxDefault();var t;t=$.ajax({type:"POST",url:"/ajax/facilityGroups/update_sort_order",data:e}),t.pipe(function(e){if(errorCheck(e)==0&&e.status_code==-1)return;return infoCheck(e),$("#facilityGroupsSortDialog").dialog("close"),reSearchAndRender()})}$(function(){$(window).unload(function(){unBlockLoadingMsg()}),initDialog(),$("#addFacilityGroupsBtn").click(function(){openEditDialog("")}),setAjaxDefault(),$.ajax({type:"GET",url:"/ajax/facilityGroups/get_serch_info"}).then(function(e){if(errorCheck(e)==0)return;var t=e.result;$("#search_name").val(t.name),t.click_search==1&&reSearchAndRender()}),$("#searchFacilityGroupsBtn").click(function(){searchFacilityGroups()})});