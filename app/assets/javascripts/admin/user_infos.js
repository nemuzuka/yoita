//ユーザメンテナンスのjs
$(function(){
	$(window).unload(function(){
		//画面を離れる場合
		unBlockLoadingMsg();
	});
	
	//dialogの登録
	initDialog();
	
	$("#addUserInfosBtn").click(function(){
		openEditDialog("");
	});

	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/userInfos/get_serch_info",
	}).then(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}

			var param = data.result;

			//検索条件の設定
			$("#search_name").val(param.name);
			$("#search_reading_character").val(param.reading_character);
			if(param.admin_only != null && param.admin_only == true) {
				$("#search_admin_only").prop("checked", true);
			} else {
				$("#search_admin_only").prop("checked", false);
			}
			$("input[type='radio'][name='searchType']").val([param.search_type]);

			//検索ボタンを押下していた場合
			if(param.click_search == true) {
				//再検索処理を行う
				reSearchAndRender();
			}
		}
	);
	
	$("#searchUserInfosBtn").click(function(){
		searchUserInfos();
	});

});

//ダイアログ初期化
function initDialog(){
	$("#userInfosDialog").dialog({
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

	$("#userInfosSortDialog").dialog({
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
	
	//date-picker
	$.datepicker.setDefaults($.extend($.datepicker.regional['ja']));
	$("#validity_start_date").datepicker();
	$("#validity_end_date").datepicker();
	
	//登録・更新実行
	$("#userInfosDialog-add").click(function(){
		execute();
	});
	
	$("#userInfosDialog-cancel").click(function(){
		$("#userInfosDialog").dialog("close");
	});
	
	//ソートダイアログ
	$("#sortUserInfosBtn").click(function(){
		openSortDialog();
	});
	$("#sort_up").click(function(){
		upItems("userInfos_to");
	});
	$("#sort_down").click(function(){
		downItems("userInfos_to");
	});
	$("#userInfosSortDialog-execute").click(function(){
		executeSort();
	});
	$("#userInfosSortDialog-cancel").click(function(){
		$("#userInfosSortDialog").dialog("close");
	});
}

//ユーザ検索
function searchUserInfos() {
	var params = {};
	params["name"] = $("#search_name").val();
	params["reading_character"] = $("#search_reading_character").val();
	if($("#search_admin_only").attr("checked") == undefined ) {
		params["admin_only"] = '0';
	} else {
		params["admin_only"] = '1';
	}
	params["search_type"] = $("input[type='radio'][name='searchType']:checked").val();
	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/userInfos/list",
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
		url: "/ajax/userInfos/refresh"
	}).then(
		function(data) {
			render(data);
		}
	);
}

//ページング処理
function turnUserInfos(pageNo, url) {
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
			.append($("<th />").text("ログインID"))
			.append($("<th />").text("ユーザ名").attr({width:"35%"}))
			.append($("<th />").text("ふりがな"))
			.append($("<th />").text("管理者").attr({width:"50px"}))
			.append($("<th />").text("メモ"))
			.append($("<th />").text("").attr({width:"50px"}))
		);
	$table.append($thead);

	$.each(result.list, function() {

		var record = this.record;

		var $delButton = $("<input />").attr({type:'button', value:'削除'}).addClass("btn btn-danger btn-mini");
		var resourceId = record.resource_id;
		var name = record.name;
		var memo = escapeTextArea(record.memo);
		var resource_lock_version = record.resource_lock_version;
		var reading_character = record.reading_character;
		var admin = "◯";
		if(record.admin_flg == '0') {
			admin = ""
		}
		var user_info_lock_version = record.user_info_lock_version;
		var login_lock_version = record.login_lock_version;
		var login_id = record.login_id;
		
		var addClassName = "";
		if(this.disable == true) {
			addClassName = "disableColor";
		}

		var $a = $("<a />").attr({href: "javascript:void(0)"}).text(login_id);
		$a.click(function(){
			openEditDialog(resourceId);
		});

		$delButton.click(function(){
			deleteUserInfos(resourceId, resource_lock_version, 
				user_info_lock_version, login_lock_version, name);
		});

		//※memo、エスケープしているので、html出力可
		var $tr = $("<tr />");
		$tr.append($("<td />").append($a))
			.append($("<td />").text(name))
			.append($("<td />").text(reading_character))
			.append($("<td />").text(admin).attr({align:"center"}))
			.append($("<td />").html(memo))
			.append($("<td />").append($delButton));
		if(addClassName != '') {
			$tr.addClass(addClassName);
		}
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
		title = "ユーザ登録";
		buttonLabel = "登録する";
	} else {
		title = "ユーザ変更";
		buttonLabel = "変更する";
	}
	$("#ui-dialog-title-userInfosDialog").empty();
	$("#ui-dialog-title-userInfosDialog").append(title);
	$("#userInfosDialog-add").attr({value:buttonLabel});
	
	var params = {};
	params["resource_id"] = resourceId;
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "GET",
		url: "/ajax/userInfos/show",
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
			
			//user_info情報
			var user_info = detail.user_info;
			$("#reading_character").val(user_info.reading_character);
			$("#tel").val(user_info.tel);
			$("#mail").val(user_info.mail);
			
			var user_group_list = data.result.user_group_list;
			$("#default_user_group").empty();
			if(user_group_list != null) {
				$.each(user_group_list, function(){
					$("#default_user_group").append($('<option />').attr({value:this.key }).text(this.value));
				});
			}
			$("#default_user_group").val(user_info.default_user_group);

			$("#per_page").val(user_info.per_page);
			$("#validity_start_date").val(formatDateyyyyMMdd(user_info.validity_start_date));
			$("#validity_end_date").val(formatDateyyyyMMdd(user_info.validity_end_date));
			if(user_info.admin_flg != null && user_info.admin_flg == '1') {
				$("#admin_flg").prop("checked", true);
			} else {
				$("#admin_flg").prop("checked", false);
			}
			$("#user_info_lock_version").val(user_info.lock_version);
			
			//login情報の設定
			login = detail.login;
			$("#login_id").val("");
			$("#password").val("");
			$("#confirm_password").val("");
			$("#update_password").val("");
			$("#view_login_id").text("");
			$("#confirm_password").removeClass("required-input")
			if(resource.id == null || resource.id == '') {
				//新規の場合
				$(".ins_area").show();
				$(".upd_area").hide();
				$("#confirm_password").addClass("required-input")
			} else{
				//更新の場合
				$(".ins_area").hide();
				$(".upd_area").show();
				$("#view_login_id").text(login.login_id);
			}
			$("#login_lock_version").val(login.lock_version);

			prependDummyText("userInfosDialog");
			$("#userInfosDialog").dialog("open");
			removeDummyText("userInfosDialog");
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
		url: "/ajax/userInfos/save",
		data: params
	});
	
	//後処理の登録
	//
	task.pipe(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -1 || data.status_code == -5) {
					//validateエラー(含むユーザ入力による一意制約エラー)の場合、処理終了
					//※それ以外の場合、ダイアログをクローズして一覧再描画する
					return;
				}
			}
			//メッセージを表示して、戻る
			infoCheck(data);
			$("#userInfosDialog").dialog("close");
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
	
	params["user_info"] = {}
	var user_info = params["user_info"];
	user_info["reading_character"] = $("#reading_character").val();
	user_info["tel"] = $("#tel").val();
	user_info["mail"] = $("#mail").val();
	user_info["default_user_group"] = $("#default_user_group").val();
	user_info["per_page"] = $("#per_page").val();
	user_info["validity_start_date"] = $("#validity_start_date").val();
	user_info["validity_end_date"] = $("#validity_end_date").val();
	if($("#admin_flg").attr("checked") == undefined ) {
		user_info["admin_flg"] = '0';
	} else {
		user_info["admin_flg"] = '1';
	}
	user_info["lock_version"] = $("#user_info_lock_version").val();
	
	params["login"] = {}
	var login = params["login"];
	login["login_id"] = $("#login_id").val();
	if(resource["id"] == null || resource["id"] == '') {
		//新規の場合
		login["password"] = $("#password").val();
	} else{
		//更新の場合
		login["password"] = $("#update_password").val();
	}
	login["confirm_password"] = $("#confirm_password").val();
	login["lock_version"] = $("#login_lock_version").val();
	setToken(params)
	return params;
}

//登録validate
function validate(params) {
	var v = new Validate();
	var resource = params["resource"];
	v.addRules({value:resource["name"],option:'required',error_args:"ユーザ名"});
	v.addRules({value:resource["name"],option:'maxLength',error_args:"ユーザ名", size:128});
	
	var user_info = params["user_info"];
	v.addRules({value:resource["reading_character"],option:'maxLength',error_args:"ふりがな", size:128});
	
	var login = params["login"];
	//新規の場合
	if(resource["id"] == null || resource["id"] == '') {
		v.addRules({value:login["login_id"],option:'required',error_args:"ログインID"});
		v.addRules({value:login["login_id"],option:'maxLength',error_args:"ログインID", size:256});
		
		//パスワードが必須
		v.addRules({value:login["password"],option:'required',error_args:"パスワード"});
		//6文字以上であること
		v.addRules({value:login["password"],option:'minLength',error_args:"パスワード", size:6});
		//確認用パスワードと一致すること
		v.addRules({value1:login["password"], value2:login["confirm_password"],
			option:'eachValue',error_args:"パスワード", error_args2:"確認用パスワード"});
	} else {
		
		//パスワードが入力されている場合
		if(login["password"] != null && login["password"] != '') {
			//6文字以上であること
			v.addRules({value:login["password"],option:'minLength',error_args:"パスワード", size:6});
			//確認用パスワードと一致すること
			v.addRules({value1:login["password"], value2:login["confirm_password"],
				option:'eachValue',error_args:"パスワード", error_args2:"パスワード(確認用)"});
		}
	}
	v.addRules({value:user_info["tel"],option:'maxLength',error_args:"TEL", size:48});
	v.addRules({value:user_info["mail"],option:'maxLength',error_args:"メールアドレス", size:256});
	
	//有効開始日
	v.addRules({value:user_info["validity_start_date"],option:'required',error_args:"有効開始日"});
	v.addRules({value:user_info["validity_start_date"],option:'date',error_args:"有効開始日"});
	
	//有効終了日
	v.addRules({value:user_info["validity_end_date"],option:'date',error_args:"有効終了日"});
	
	//終了日が入力されている場合、開始日＞終了日の関係でない場合、エラー
	if(user_info["validity_end_date"] != null && user_info["validity_end_date"] != '') {
		v.addRules({fromValue:user_info["validity_start_date"], toValue:user_info["validity_end_date"],
			option:'dateRange', error_args:"有効開始日", error_args2:"有効終了日", error_args3:"日付"});
	}
	
	v.addRules({value:resource["memo"],option:'maxLength',error_args:"メモ", size:1024});
	return v.execute();
}

//ユーザ削除
function deleteUserInfos(resourceId, resource_lock_version, 
	user_info_lock_version, login_lock_version, name) {
	if(window.confirm("ユーザ「" + name + "」を削除します。本当によろしいですか？") == false) {
		return;
	}
	
	var params = {};
	params["resource"] = {};
	var resource = params["resource"];
	resource["id"] = resourceId;
	resource["lock_version"] = resource_lock_version;
	
	params["user_info"] = {};
	var user_info = params["user_info"];
	user_info["lock_version"] = user_info_lock_version;
	
	params["login"] = {};
	var login = params["login"];
	login["lock_version"] = login_lock_version;
	setToken(params)
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "POST",
		url: "/ajax/userInfos/destroy",
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
		url: "/ajax/userInfos/get_sort_info"
	}).then(
		function(data) {
			renderSortDialog(data);
		}
	);
}

//ソートダイアログデータ設定 & Open
function renderSortDialog(data) {
	$("#userInfos_to").empty();

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
		$("#userInfos_to").append($('<option />').attr({value:resourceId }).text(name));
	});
	reWriteSelect("userInfos_to", new Array());
	
	prependDummyText("userInfosSortDialog");
	$("#userInfosSortDialog").dialog("open");
	removeDummyText("userInfosSortDialog");
}

//ソート情報変更
function executeSort() {
	var params = {};
	params["ids"] = getSelectArray("userInfos_to");
	setToken(params)

	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "POST",
		url: "/ajax/userInfos/update_sort_order",
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
			$("#userInfosSortDialog").dialog("close");
			return reSearchAndRender();
		}
	);
}
