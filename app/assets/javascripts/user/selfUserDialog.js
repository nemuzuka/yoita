//ユーザメンテナンスのjs
$(function(){
	//dialogの登録
	initSelfUserDialog();
});

//ダイアログ初期化
function initSelfUserDialog(){
	$("#selfUserDialog").dialog({
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
	
	//更新実行
	$("#selfUserDialog-add").click(function(){
		executeSelfUser();
	});
	
	$("#selfUserDialog-cancel").click(function(){
		$("#selfUserDialog").dialog("close");
	});
}

//更新ダイアログ表示
function openSelfUserDialog() {
	
	var title = "ユーザ情報";
	var buttonLabel = "変更する";

	$("#ui-dialog-title-selfUserDialog").empty();
	$("#ui-dialog-title-selfUserDialog").append(title);
	$("#selfUserDialog-add").attr({value:buttonLabel});
	
	var params = {};
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "GET",
		url: "/ajax/userInfos/show_self"
	});
	
	//後処理の登録
	task.pipe(
		function(data) {
			
			if(errorCheck(data) == false) {
				return;
			}
			
			//form情報の設定
			var detail = data.result.detail;
			var resource = detail.resource;
			$("#self_resource_name").val(resource.name);
			$("#self_resource_memo").val(resource.memo);

			$("#self_resource_lock_version").val(resource.lock_version);
			
			//user_info情報
			var user_info = detail.user_info;
			$("#self_reading_character").val(user_info.reading_character);
			$("#self_tel").val(user_info.tel);
			$("#self_mail").val(user_info.mail);
			
			var user_group_list = data.result.user_group_list;
			$("#self_default_user_group").empty();
			if(user_group_list != null) {
				$.each(user_group_list, function(){
					$("#self_default_user_group").append($('<option />').attr({value:this.key }).text(this.value));
				});
			}
			$("#self_default_user_group").val(user_info.default_user_group);

			$("#self_per_page").val(user_info.per_page);
			$("#self_user_info_lock_version").val(user_info.lock_version);
			
			//login情報の設定
			login = detail.login;
			$("#self_confirm_password").val("");
			$("#self_update_password").val("");
			$("#self_update_confirm_password").val("");
			$("#self_login_lock_version").val(login.lock_version);

			prependDummyText("selfUserDialog");
			$("#selfUserDialog").dialog("open");
			removeDummyText("selfUserDialog");
			return;
		}
	);
}

//登録・更新実行
function executeSelfUser() {
	var params = createExecuteSelfUserParams();
	
	if(validateSelfUser(params) == false) {
		return;
	}
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "POST",
		url: "/ajax/userInfos/save_self",
		data: params
	});
	
	//後処理の登録
	//
	task.pipe(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -1) {
					//validateエラーの場合、処理終了
					//※それ以外の場合、ダイアログをクローズして一覧再描画する
					return;
				}
			}
			//メッセージを表示して、戻る
			infoCheck(data);
			$("#selfUserDialog").dialog("close");
			return;
		}
	);
}

//更新パラメータ設定
function createExecuteSelfUserParams() {
	var params = {};
	params["resource"] = {}
	var resource = params["resource"]
	resource["name"] = $("#self_resource_name").val();
	resource["memo"] = $("#self_resource_memo").val();
	resource["lock_version"] = $("#self_resource_lock_version").val();
	
	params["user_info"] = {}
	var user_info = params["user_info"];
	user_info["reading_character"] = $("#self_reading_character").val();
	user_info["tel"] = $("#self_tel").val();
	user_info["mail"] = $("#self_mail").val();
	user_info["default_user_group"] = $("#self_default_user_group").val();
	user_info["per_page"] = $("#self_per_page").val();
	user_info["lock_version"] = $("#self_user_info_lock_version").val();
	
	params["login"] = {}
	var login = params["login"];
	login["before_confirm_password"] = $("#self_confirm_password").val();
	login["password"] = $("#self_update_password").val();
	login["confirm_password"] = $("#self_update_confirm_password").val();
	login["lock_version"] = $("#self_login_lock_version").val();
	setToken(params)
	return params;
}

//更新validate
function validateSelfUser(params) {
	var v = new Validate();
	var resource = params["resource"];
	v.addRules({value:resource["name"],option:'required',error_args:"ユーザ名"});
	v.addRules({value:resource["name"],option:'maxLength',error_args:"ユーザ名", size:128});
	
	var user_info = params["user_info"];
	v.addRules({value:resource["reading_character"],option:'maxLength',error_args:"ふりがな", size:128});
	
	var login = params["login"];
	//パスワードが入力されている場合
	if(
		(login["before_confirm_password"] != null && login["before_confirm_password"] != '') ||
		(login["password"] != null && login["password"] != '') ||
		(login["confirm_password"] != null && login["confirm_password"] != '') ) {
			
		//必須であること
		v.addRules({value:login["before_confirm_password"],option:'required',error_args:"変更前パスワード"});
			
		//6文字以上であること
		v.addRules({value:login["password"],option:'minLength',error_args:"変更パスワード", size:6});
		//確認用パスワードと一致すること
		v.addRules({value1:login["password"], value2:login["confirm_password"],
			option:'eachValue',error_args:"変更パスワード", error_args2:"変更パスワード(確認用)"});
	}
	v.addRules({value:user_info["tel"],option:'maxLength',error_args:"TEL", size:48});
	v.addRules({value:user_info["mail"],option:'maxLength',error_args:"メールアドレス", size:256});
	
	v.addRules({value:resource["memo"],option:'maxLength',error_args:"メモ", size:1024});
	return v.execute();
}
