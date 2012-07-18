//ユーザグループメンテナンスのjs
$(function(){
	$(window).unload(function(){
		//画面を離れる場合
		unBlockLoadingMsg();
	});
	
	//dialogの登録
	initDialog();
	
	$("#addUserGroupsBtn").click(function(){
		openEditDialog("");
	});

	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/userGroups/get_serch_info",
	}).then(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}

			var param = data.result;

			//検索条件の設定
			$("#search_name").val(param.name);

			//検索ボタンを押下していた場合
			if(param.click_search == true) {
				//再検索処理を行う
				reSearchAndRender();
			}
		}
	);
	
	$("#searchUserGroupsBtn").click(function(){
		searchUserGroups();
	});

});

//ダイアログ初期化
function initDialog(){
	$("#userGroupsDialog").dialog({
		modal:true,
		autoOpen:false,
		width:700,
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

	$("#userGroupsSortDialog").dialog({
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
	$("#userGroupsDialog-add").click(function(){
		execute();
	});
	
	$("#userGroupsDialog-cancel").click(function(){
		$("#userGroupsDialog").dialog("close");
	});
	
	//各種ボタンの制御
	$("#users_up").click(function(){
		upItems("target_users");
	});
	$("#users_down").click(function(){
		downItems("target_users");
	});
	$("#users_add").click(function(){
		addItems("all_users","target_users");
	});
	$("#users_remove").click(function(){
		removeItems("target_users");
	});

	//ソートダイアログ
	$("#sortUserGroupsBtn").click(function(){
		openSortDialog();
	});
	$("#sort_up").click(function(){
		upItems("userGroups_to");
	});
	$("#sort_down").click(function(){
		downItems("userGroups_to");
	});
	$("#userGroupsSortDialog-execute").click(function(){
		executeSort();
	});
	$("#userGroupsSortDialog-cancel").click(function(){
		$("#userGroupsSortDialog").dialog("close");
	});
}

//ユーザグループ検索
function searchUserGroups() {
	var params = {};
	params["name"] = $("#search_name").val();
	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/userGroups/list",
		data: params
	}).then(
		function(data) {
			render(data);
		}
	);
}

//再検索
function reSearchAndRender() {
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/userGroups/refresh"
	}).then(
		function(data) {
			render(data);
		}
	);
}

//ページング処理
function turnUserGroups(pageNo, url) {
	setAjaxDefault();
	
	var params = {};
	params["page_no"] = pageNo;
	
	$.ajax({
		type: "GET",
		url: url,
		data: params
	}).then(
		function(data) {
			render(data);
		}
	);
}


//一覧描画
function render(data) {
	//tableをクリア
	$("#result_area").empty();
	
	var result = data.result;

	//共通エラーチェック
	infoCheck(data);
	if(errorCheck(data) == false || result.total_count == 0) {
		return;
	}
	
	//該当件数とリンクを表示
	var $widgetDisp = $("<div />").addClass("widget");
	var $widgetHeaderDisp = $("<div />").addClass("widget-header").append(
		$("<h2 />").addClass("title").text("検索結果"));
	var $widgetContentDisp = $("<div />").addClass("widget-content");

	var $pager = $("<div />").addClass("pager-area").append(
		$("<span />").addClass("count").text("全" + result.total_count + "件")).append(result.link);

	var $table = $("<table />").attr({"id":"result_list"}).addClass("result_table");
	var $tbody = $("<tbody />");

	//ヘッダ部分作成
	var $thead = $("<thead />")
		.append($("<tr />")
			.append($("<th />").text("ユーザグループ名").attr({width:"35%"}))
			.append($("<th />").text("メモ"))
			.append($("<th />").text("").attr({width:"50px"}))
		);
	$table.append($thead);

	$.each(result.list, function() {

		var $delButton = $("<input />").attr({type:'button', value:'削除'}).addClass("btn btn-danger btn-mini");
		var resourceId = this.id;
		var version = this.lock_version;
		var name = this.name;
		var memo = escapeTextArea(this.memo);

		var $a = $("<a />").attr({href: "javascript:void(0)"}).text(name);
		$a.click(function(){
			openEditDialog(resourceId);
		});

		$delButton.click(function(){
			deleteUserGroups(resourceId, version, name);
		});

		//※memo、エスケープしているので、html出力可
		var $tr = $("<tr />");
		$tr.append($("<td />").append($a))
			.append($("<td />").html(memo))
			.append($("<td />").append($delButton));
		$tbody.append($tr);
	});

	$table.append($tbody);
	$widgetContentDisp.append($pager).append($table);
	$widgetDisp.append($widgetHeaderDisp).append($widgetContentDisp);

	$("#result_area").append($widgetDisp).addClass("onload");
}


//登録・更新ダイアログ表示
function openEditDialog(resourceId) {
	
	var title = "";
	var buttonLabel = "";
	if(resourceId == '') {
		title = "ユーザグループ登録";
		buttonLabel = "登録する";
	} else {
		title = "ユーザグループ変更";
		buttonLabel = "変更する";
	}
	$("#ui-dialog-title-userGroupsDialog").empty();
	$("#ui-dialog-title-userGroupsDialog").append(title);
	$("#userGroupsDialog-add").attr({value:buttonLabel});
	
	var params = {};
	params["resource_id"] = resourceId;
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "GET",
		url: "/ajax/userGroups/show",
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
			var detail = data.result.detail;
			var resource = detail.resource;
			$("#resource_name").val(resource.name);
			$("#resource_memo").val(resource.memo);

			$("#resource_lock_version").val(resource.lock_version);
			$("#resource_id").val(resource.id);
			
			var resource_conn_list = detail.resource_conn_list;
			if(resource_conn_list == null) {
				resource_conn_list = [];
			}
			$("#target_users").empty();
			$.each(resource_conn_list, function(){
				$("#target_users").append($('<option />').attr({value:this.key }).text(this.value));
			});
			reWriteSelect("target_users", new Array());
			
			var user_infos_list = data.result.user_infos_list;
			if(user_infos_list == null) {
				user_infos_list = [];
			}
			$("#all_users").empty();
			$.each(user_infos_list, function(){
				$("#all_users").append($('<option />').attr({value:this.key }).text(this.value));
			});
			reWriteSelect("all_users", new Array());
			
			prependDummyText("userGroupsDialog");
			$("#userGroupsDialog").dialog("open");
			removeDummyText("userGroupsDialog");
			return;
		}
	);
}

//登録・更新実行
function execute() {
	var params = createExecuteParams();
	
	if(validate(params) == false) {
		return;
	}
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "POST",
		url: "/ajax/userGroups/save",
		data: params
	});
	
	//後処理の登録
	//
	task.pipe(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -1 ) {
					//validateエラーの場合、処理終了
					//※それ以外の場合、ダイアログをクローズして一覧再描画する
					return;
				}
			}
			//メッセージを表示して、戻る
			infoCheck(data);
			$("#userGroupsDialog").dialog("close");
			return reSearchAndRender();
		}
	);
}

//登録パラメータ設定
function createExecuteParams() {
	var params = {};
	params["resource"] = {}
	var resource = params["resource"]
	resource["name"] = $("#resource_name").val();
	resource["memo"] = $("#resource_memo").val();
	resource["id"] = $("#resource_id").val();
	resource["lock_version"] = $("#resource_lock_version").val();
	params["child_ids"] = getSelectArray("target_users");
	setToken(params)
	return params;
}

//登録validate
function validate(params) {
	var v = new Validate();
	var resource = params["resource"]
	v.addRules({value:resource["name"],option:'required',error_args:"ユーザグループ名"});
	v.addRules({value:resource["name"],option:'maxLength',error_args:"ユーザグループ名", size:128});

	v.addRules({value:resource["memo"],option:'maxLength',error_args:"メモ", size:1024});
	
	v.addRules({value:params["child_ids"],option:'requiredList',error_args:"参加リソース"});
	return v.execute();
}

//ユーザグループ削除
function deleteUserGroups(id, version, name) {
	if(window.confirm("ユーザグループ「" + name + "」を削除します。本当によろしいですか？") == false) {
		return;
	}
	
	var params = {};
	params["resource_id"] = id;
	params["lock_version"] = version;
	setToken(params)
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "POST",
		url: "/ajax/userGroups/destroy",
		data: params
	});
	
	//後処理の登録
	//
	task.pipe(
		function(data) {
			//共通エラーチェック
			errorCheck(data);
			//メッセージを表示して、戻る
			infoCheck(data);
			return reSearchAndRender();
		}
	);
}

//ソート処理
function openSortDialog() {
	setAjaxDefault();
	return $.ajax({
		type: "GET",
		url: "/ajax/userGroups/get_sort_info"
	}).then(
		function(data) {
			renderSortDialog(data);
		}
	);
}

//ソートダイアログデータ設定 & Open
function renderSortDialog(data) {
	$("#userGroups_to").empty();

	//共通エラーチェック
	if(errorCheck(data) == false) {
		return;
	}
	infoCheck(data);
	
	var result = data.result;
	if(result.length == 0) {
		return;
	}

	$.each(result, function(){
		var resourceId = this.id;
		var name = this.name;
		$("#userGroups_to").append($('<option />').attr({value:resourceId }).text(name));
	});
	reWriteSelect("userGroups_to", new Array());
	
	prependDummyText("userGroupsSortDialog");
	$("#userGroupsSortDialog").dialog("open");
	removeDummyText("userGroupsSortDialog");
}

//ソート情報変更
function executeSort() {
	var params = {};
	params["ids"] = getSelectArray("userGroups_to");
	setToken(params)

	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "POST",
		url: "/ajax/userGroups/update_sort_order",
		data: params
	});
	
	//後処理の登録
	//
	task.pipe(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -1 ) {
					return;
				}
			}

			//メッセージを表示して、ダイアログを閉じて、再検索
			infoCheck(data);
			$("#userGroupsSortDialog").dialog("close");
			return reSearchAndRender();
		}
	);
}
