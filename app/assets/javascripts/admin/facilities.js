//設備メンテナンスのjs
$(function(){
	$(window).unload(function(){
		//画面を離れる場合
		unBlockLoadingMsg();
	});
	
	//dialogの登録
	initDialog();
	
	$("#addFacillitiesBtn").click(function(){
		openEditDialog("");
	});

	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/facilities/get_serch_info",
	}).then(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}

			var param = data.result;

			//検索条件の設定
			$("#search_name").val(param.name);

			//検索ボタンを押下していた場合、検索処理を行う
			if(param.click_search == true) {
				//検索処理を行う
				executeSearch(param.view_page_no);
			}
		}
	);
});

//ダイアログ初期化
function initDialog(){
	$("#facillitiesDialog").dialog({
		modal:true,
		autoOpen:false,
		width:600,
		resizable:false,
		open:function(event) {
			openModalDialog();
		},
		close:function(event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});

	$("#facillitiesSortDialog").dialog({
		modal:true,
		autoOpen:false,
		width:600,
		resizable:false,
		open:function(event) {
			openModalDialog();
		},
		close:function(event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});
	
	//登録・更新実行
	$("#facillitiesDialog-add").click(function(){
		execute();
	});
	
	$("#facillitiesDialog-cancel").click(function(){
		$("#facillitiesDialog").dialog("close");
	});
	

	//ソートダイアログ
	$("#sortFacillitiesBtn").click(function(){
		openSortDialog();
	});
	$("#sort_up").click(function(){
		upItems("facillities_to");
	});
	$("#sort_down").click(function(){
		downItems("facillities_to");
	});
	$("#facillitiesSortDialog-execute").click(function(){
		executeSort();
	});
	$("#facillitiesSortDialog-cancel").click(function(){
		$("#facillitiesSortDialog").dialog("close");
	});
}

//登録・更新ダイアログ表示
function openEditDialog(resourceId) {
	
	var title = "";
	var buttonLabel = "";
	if(resourceId == '') {
		title = "設備登録";
		buttonLabel = "登録する";
	} else {
		title = "設備変更";
		buttonLabel = "変更する";
	}
	$("#ui-dialog-title-facillitiesDialog").empty();
	$("#ui-dialog-title-facillitiesDialog").append(title);
	$("#facillitiesDialog-add").attr({value:buttonLabel});
	
	var params = {};
	params["resource_id"] = resourceId;
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "GET",
		url: "/ajax/facilities/show",
		data: params
	});
	
	//後処理の登録
	//表示対象データが存在せず、再検索を行える場合、再検索をします。
	task.pipe(
		function(data) {
			
			if(errorCheck(data) == false) {
				if(data.status_code == -6) {
					//表示対象データが存在しない場合、再検索して表示
					return reSearchAndRender();
				}
				return;
			}
			
			//form情報の設定
			var form = data.result;
			$("#resource_name").val(form.name);
			$("#resource_memo").val(form.memo);

			$("#resource_lock_version").val(form.lock_version);
			$("#resource_id").val(form.id);
			
			prependDummyText("facillitiesDialog");
			$("#facillitiesDialog").dialog("open");
			removeDummyText("facillitiesDialog");
			return;
		}
	);
}


