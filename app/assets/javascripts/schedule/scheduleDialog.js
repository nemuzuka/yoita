$(function(){

	initScheduleEditDialog();
	initScheduleDetailDialog();
	initUserDetailDialog();
	initFacilitiesDetailDialog();
	initUserGroupDetailDialog();
	initFollowDialog();

});

//フォロー登録ダイアログの初期化
function initFollowDialog(){
	$("#followEditDialog").dialog({
		modal: true,
		autoOpen: false,
		width: 800,
		resizable: false,
		open:function (event) {
			openModalDialog();
		},
		close:function (event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});
	
	$("#followExecute").click(function(){
		followExecute();
	});
	
	$("#followEditDialog-cancel").click(function(){
		$("#followEditDialog").dialog("close");
	});
}

//ユーザグループ詳細ダイアログの初期化
function initUserGroupDetailDialog(){
	$("#userGroupDetailDialog").dialog({
		modal: true,
		autoOpen: false,
		width: 600,
		resizable: false,
		open:function (event) {
			openModalDialog();
		},
		close:function (event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});
	$("#userGroupDetailDialog-cancel").click(function(){
		$("#userGroupDetailDialog").dialog("close");
	})
}

//設備詳細ダイアログの初期化
function initFacilitiesDetailDialog() {
	$("#facilitiesDetailDialog").dialog({
		modal: true,
		autoOpen: false,
		width: 600,
		resizable: false,
		open:function (event) {
			openModalDialog();
		},
		close:function (event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});
	$("#facilitiesDetailDialog-cancel").click(function(){
		$("#facilitiesDetailDialog").dialog("close");
	})
}

//ユーザ詳細ダイアログの初期化
function initUserDetailDialog() {
	$("#userDetailDialog").dialog({
		modal: true,
		autoOpen: false,
		width: 600,
		resizable: false,
		open:function (event) {
			openModalDialog();
		},
		close:function (event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});
	
	$("#userDetailDialog-cancel").click(function(){
		$("#userDetailDialog").dialog("close");
	})
	
}


//スケジュール詳細ダイアログの初期化
function initScheduleDetailDialog() {
	$("#scheduleDetailDialog").dialog({
		modal: true,
		autoOpen: false,
		width: 850,
		resizable: false,
		open:function (event) {
			openModalDialog();
		},
		close:function (event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});

	//変更画面遷移ボタンクリック時
	$("#moveScheduleEdit").click(function(){
		//自ダイアログクローズ
		$("#scheduleDetailDialog").dialog("close");
		//スケジュール変更ダイアログを開く
		openEditDialog($("#scheduleId").val(), "", "");
	});

	//スケジュール削除ボタンクリック時
	$("#scheduleDelete").click(function(){
		scheduleDelete();
	});

	//フォロー追加ボタンクリック時
	$("#addFollow").click(function(){
		openFollowEditDialog();
	});

	$("#scheduleDetailDialog-cancel").click(function(){
		//自ダイアログクローズ
		$("#scheduleDetailDialog").dialog("close");
	});

}

//スケジュール削除
function scheduleDelete() {
	if(window.confirm('スケジュールを削除します。本当によろしいですか？') == false) {
		return;
	}

	var params={};
	params["schedule_id"] = $("#scheduleId").val();
	params["lock_version"] = $("#scheduleDetailVersionNo").val();
	setToken(params);

	setAjaxDefault();
	$.ajax({
		type: "POST",
		data: params,
		dataType: "json",
		url: '/ajax/schedule/delete/'
	}).then(
		function(data){

			//共通エラーチェック
			errorCheck(data);

			//メッセージを表示して、自身をクローズし、
			//呼び出し元を再表示
			infoCheck(data);
			$("#scheduleDetailDialog").dialog("close");
			refresh();
		}
	);
}


//スケジュール詳細ダイアログ描画
function renderScheduleDetailDialog(result) {

	var schedule = result.schedule;

	$("#viewDate").text(result.view_date);
	$("#viewTitle").text(schedule.title);
	$("#viewMemo").html(escapeTextArea(schedule.memo));
	
	$("#userConnList").text("");
	$.each(result.schedule_user_conn_list, function() {
		var $span = $("<span />").text(this.value);
		$("#userConnList").append($span).append("<br />");
	});
	$("#facilitiesConnList").text("");
	$.each(result.schedule_facilities_conn_list, function() {
		var $span = $("<span />").text(this.value);
		$("#facilitiesConnList").append($span).append("<br />");
	});

	var entryUserName = result.entry_resource_name;
	if(entryUserName != '') {
		entryUserName = entryUserName + " (" + result.entry_time + ")";
	}
	$("#entryUserName").text(entryUserName);
	
	var updateUserName = result.update_resource_name;
	if(updateUserName != '') {
		updateUserName = updateUserName + " (" + result.update_time + ")";
	}
	$("#updateUserName").text(updateUserName);

	$("#scheduleDetailVersionNo").val(schedule.lock_version);
	$("#scheduleId").val(schedule.id);

}


//スケジュール登録・更新ダイアログの初期化
function initScheduleEditDialog() {
	$("#scheduleEditDialog").dialog({
		modal: true,
		autoOpen: false,
		width: 850,
		resizable: false,
		open:function(event) {
			openModalDialog();
		},
		close:function(event) {
			closeModelDialog();
		},
		show: 'clip',
        hide: 'clip'
	});

	var dayName = new Array();
	dayName[0] = '日曜日';
	dayName[1] = '月曜日';
	dayName[2] = '火曜日';
	dayName[3] = '水曜日';
	dayName[4] = '木曜日';
	dayName[5] = '金曜日';
	dayName[6] = '土曜日';

	$.datepicker.setDefaults($.extend($.datepicker.regional['ja']));
	$.timepicker.setDefaults($.extend($.timepicker.regional['ja']));

	$("#normal_startDate").datepicker();
	$("#normal_startTime").timepicker();
	//開始日時が変更された時の振る舞いを登録
	$("#normal_startDate").change(function(){
		changeNormalStartDate();
	});
	$("#normal_endDate").datepicker();
	$("#normal_endTime").timepicker();

	$("#repeat_startDate").datepicker();
	$("#repeat_startTime").timepicker();
	$("#repeat_startDate").change(function(){
		changeRepeatStartDate();
	});
	$("#repeat_endDate").datepicker();
	$("#repeat_endTime").timepicker();

	//繰り返しの日付を設定
	$("#repeatWeek").empty();
	for(var i = 0; i < 7; i++) {
		$("#repeatWeek").append($('<option>').attr({ value: i }).text(dayName[i]));
	}
	$("#repeatDay").empty();
	for(var i = 0; i < 31; i++) {
		var dayValue = i + 1;
		var value = "";
		if (dayValue < 10) {
			value = "0" + dayValue;
		} else {
			value = "" + dayValue;
		}
		$("#repeatDay").append($('<option>').attr({ value: value }).text((i+1) + "日"));
	}
	$("#repeatDay").append($('<option>').attr({ value: 32 }).text("月末"));

	//無制限チェックボックスを変更した時
	$("#repeatEndless").change(function(){
		changeRepeatStartTimeDisplay();
	});

	//参加ユーザグループを変更した時
	$("#userGroupList").change(function(){
		changeUserGroupList();
	});

	//参加設備グループを変更した時
	$("#facilitiesGroupList").change(function(){
		changeFacilitiesGroupList();
	});

	//リソース移動のイベント定義
	//ユーザ系
	$("#user_up").click(function(){
		upItems("user_to");
	});
	$("#user_down").click(function(){
		downItems("user_to");
	});
	$("#user_add").click(function(){
		addItems("user_from","user_to");
	});
	$("#user_remove").click(function(){
		removeItems("user_to");
	});
	//設備系
	$("#facilities_up").click(function(){
		upItems("facilities_to");
	});
	$("#facilities_down").click(function(){
		downItems("facilities_to");
	});
	$("#facilities_add").click(function(){
		addItems("facilities_from","facilities_to");
	});
	$("#facilities_remove").click(function(){
		removeItems("facilities_to");
	});

	$("#scheduleExecute").click(function(){
		scheduleExecute();
	});

	//時間入力のタブ化
	$('#schedule_type').tabs();

	$("#scheduleEditDialog-cancel").click(function(){
		$("#scheduleEditDialog").dialog("close");
	});
}


//開始日を変更された際の振る舞い(通常)
function changeNormalStartDate() {
	var orgData = unFormatDate($("#normal_startDate").val());
	$("#normal_endDate").val(formatDateyyyyMMdd(orgData));
}

//開始日を変更された際の振る舞い(繰り返し)
function changeRepeatStartDate() {
	var orgData = unFormatDate($("#repeat_startDate").val());
	if($("#repeatEndless").attr("checked") == undefined ) {
		//無期限がチェック状態で無い場合、日付を設定
		$("#repeat_endDate").val(formatDateyyyyMMdd(orgData));
	}
}

//スケジュール登録する・更新するボタン押下時処理
function scheduleExecute() {
	var params = createParams();

	if(validate(params) == false) {
		return;
	}

	setAjaxDefault();
	$.ajax({
		type: "POST",
		data: params,
		dataType: "json",
		url: '/ajax/schedule/save/'
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -1) {
					//validateエラーの場合
					return;
				}
			}

			//メッセージを表示して、自身をクローズし、
			//呼び出し元を再表示
			infoCheck(data);
			$("#scheduleEditDialog").dialog("close");
			refresh();
		}
	);

}

//リクエストパラメータ生成
function createParams() {
	var params={};
	params["schedule"] = {};
	var schedule = params["schedule"];

	//どちらの画面を表示しているかによって取得元を変更する
	if($("#normal_schedule_area").is(".ui-tabs-hide") == false) {
		params["repeat"] = '0';

		//通常のスケジュール
		schedule["start_date"] = $("#normal_startDate").val();
		schedule["start_time"] = unFormatTime($("#normal_startTime").val());
		schedule["end_date"] = $("#normal_endDate").val();
		schedule["end_time"] = unFormatTime($("#normal_endTime").val());
	} else {
		params["repeat"] = '1';
		
		//繰り返しのスケジュール
		schedule["start_date"] = $("#repeat_startDate").val();
		schedule["start_time"] = unFormatTime($("#repeat_startTime").val());
		schedule["end_date"] = $("#repeat_endDate").val();
		schedule["end_time"] = unFormatTime($("#repeat_endTime").val());
		schedule["repeat_conditions"] = $("input[type='radio'][name='repeat_conditions']:checked").val();
		schedule["repeat_week"] = $("#repeatWeek").val();
		schedule["repeat_day"] = $("#repeatDay").val();
		if($("#repeatEndless").attr("checked") == undefined ) {
			schedule["repeat_endless"] = '0';
		} else {
			schedule["repeat_endless"] = '1';
		}
	}

	schedule["id"] = $("#scheduleId").val();
	schedule["lock_version"] = $("#scheduleVersionNo").val();
	schedule["title"] = $("#title").val();
	schedule["memo"] = $("#memo").val();
	schedule["closed_flg"] = $("input[type='radio'][name='closedFlg']:checked").val();
	var user_conn = getSelectArray("user_to");
	var facilities_conn = getSelectArray("facilities_to");
	params["schedule_conn"] = user_conn.concat(facilities_conn);
	setToken(params);
	return params;
}

//登録validate
function validate(params) {
	var v = new Validate();
	var schedule = params["schedule"];

	v.addRules({value:schedule["start_date"],option:'required',error_args:"スケジュール開始日"});
	v.addRules({value:schedule["start_date"],option:'date',error_args:"スケジュール開始日"});
	v.addRules({value:schedule["start_time"],option:'time',error_args:"スケジュール開始時刻"});
	v.addRules({value:schedule["end_date"],option:'date',error_args:"スケジュール終了日"});
	v.addRules({value:schedule["end_time"],option:'time',error_args:"スケジュール終了時刻"});
	
	v.addRules({value:schedule["title"],option:'required',error_args:"件名"});
	v.addRules({value:schedule["title"],option:'maxLength',error_args:"件名", size:64});
	v.addRules({value:schedule["memo"],option:'maxLength',error_args:"メモ", size:1024});

	if (v.execute() == false){
		return false;
	}
	
	//どちらかの時刻のみの入力はNG
	if ((schedule["start_time"] == '' && schedule["end_time"] != '') || 
		(schedule["start_time"] != '' && schedule["end_time"] == '')) {
		alert("時刻を設定する場合はスケジュール開始時刻とスケジュール終了時刻を入力してください。");
		return false;
	}
	
	if(params["repeat"] == '0') {
		//繰り返しでない場合
		
		//終了日が必須
		if(schedule["end_date"] == '') {
			alert("スケジュール終了日は必須です。");
			return false;
		}
		
		if(schedule["start_date"] > schedule["end_date"]) {
			alert("終了日は開始日以降の日付を指定して下さい。");
			return false;
		}
		
		//開始日＝終了日で、時刻の入力がある場合、開始時刻<=終了時刻でなければエラー
		if(schedule["start_date"] == schedule["end_date"] && schedule["start_time"] != '') {
			if(schedule["start_time"] > schedule["end_time"]) {
				alert("終了時刻は開始時刻以降の時間を指定して下さい。");
				return false;
			}
		}
		
	} else {
		//繰り返しでない場合
		
		//無期限でない時は終了日は必須
		if(schedule["repeat_endless"] != '1') {
			if(schedule["end_date"] == '') {
				alert("スケジュール終了日は必須です。");
				return false;
			} else {
				//開始日 <= 終了日の関係であること
				if(schedule["start_date"] > schedule["end_date"]) {
					alert("終了日は開始日以降の日付を指定して下さい。");
					return false;
				}
			}
		}
		
		//時刻が入力されている場合、開始時刻<=終了時刻でなければエラー
		if(schedule["start_time"] != '') {
			if(schedule["start_time"] > schedule["end_time"]) {
				alert("終了時刻は開始時刻以降の時間を指定して下さい。");
				return false;
			}
		}
	}
	
	if(params["schedule_conn"] == null || params["schedule_conn"].length == 0) {
		alert("スケジュールに紐づくユーザもしくは設備を1件以上設定して下さい。");
		return false;
	}
	return true;
}


//ユーザグループSelect変更時の処理
function changeUserGroupList() {

	var params = {};
	params["selected_group_resource"] = $("#userGroupList").val();

	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/schedule/get_group_conn_list/"
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}
			setFromResource(data.result, "user_from");
		}
	);
}

//設備グループSelect変更時の処理
function changeFacilitiesGroupList() {
	var params = {};
	params["selected_group_resource"] = $("#facilitiesGroupList").val();

	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/schedule/get_group_conn_list/"
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}
			setFromResource(data.result, "facilities_from");
		}
	);
}

//無制限チェックボックスの状態によって、終了日付の状態を変更します。
function changeRepeatStartTimeDisplay() {
	if($("#repeatEndless").attr("checked") == undefined ) {
		$("#repeat_endDate").removeAttr("disabled");
	} else {
		//チェックされていれば、終了日付をdisableに
		$("#repeat_endDate").attr({disabled:"disabled"})
	}
}

//時間入力領域表示制御
function displayScheduleEditDialogArea(repeatConditions) {

	//繰り返しの指定がなければ通常入力のタブ表示
	if(repeatConditions == null || repeatConditions == '') {
		$('#schedule_type').tabs("select", 0);
	} else {
		//繰り返しの指定があるので繰り返しのタブ表示
		$('#schedule_type').tabs("select", 1);
	}
}

//スケジュール登録・更新ダイアログ情報設定
function renderScheduleDialog(result){

	var schedule = result.schedule

	$("#normal_startDate").val(formatDateyyyyMMdd(schedule.start_date));
	$("#normal_startTime").val(formatTimehhmm(schedule.start_time));
	$("#normal_endDate").val(formatDateyyyyMMdd(schedule.end_date));
	$("#normal_endTime").val(formatTimehhmm(schedule.end_time));

	var repeatConditions = schedule.repeat_conditions;
	displayScheduleEditDialogArea(repeatConditions);
	if(repeatConditions == null || repeatConditions == '') {
		repeatConditions = "1";
	}
	$("input[type='radio'][name='repeat_conditions']").val([repeatConditions]);
	$("#repeat_startDate").val(formatDateyyyyMMdd(schedule.start_date));
	$("#repeat_startTime").val(formatTimehhmm(schedule.start_time));
	$("#repeat_endDate").val(formatDateyyyyMMdd(schedule.end_date));
	$("#repeat_endTime").val(formatTimehhmm(schedule.end_time));
	if(schedule.repeat_endless == '1') {
		$("#repeatEndless").prop("checked", true);
	} else {
		$("#repeatEndless").prop("checked", false);
	}
	changeRepeatStartTimeDisplay();
	$("#repeatWeek").val(schedule.repeat_week);

	var repeatDay = schedule.repeat_day;
	if(repeatDay == null || repeatDay == "") {
		//開始日付を元に初期値を設定
		repeatDay = parseInt(unFormatDate(schedule.start_date).substring(6), 10);
	}
	$("#repeatDay").val(repeatDay);


	$("#title").val(schedule.title);
	$("#memo").val(schedule.memo);
	if(schedule.closed_flg == null || schedule.closed_flg == '') {
		schedule.closed_flg = '0'
	}
	$("input[type='radio'][name='closedFlg']").val([schedule.closed_flg]);

	//スケジュールに紐づくユーザ群
	$("#user_to").empty();
	$.each(result.schedule_user_conn_list, function() {
		$("#user_to").append($('<option>').attr({ value: this.key }).text(this.value));
	});
	reWriteSelect("user_to", new Array());
	$("#userGroupList").empty();
	$.each(result.user_group_list, function() {
		$("#userGroupList").append($('<option>').attr({ value: this.key }).text(this.value));
	});
	$("#userGroupList").val(result.selected_user_group);
	setFromResource(result.user_group_conn_list, "user_from");

	//スケジュールに紐づく設備群
	$("#facilities_to").empty();
	$.each(result.schedule_facilities_conn_list, function() {
		$("#facilities_to").append($('<option>').attr({ value: this.key }).text(this.value));
	});
	reWriteSelect("facilities_to", new Array());
	$("#facilitiesGroupList").empty();
	$.each(result.facilities_group_list, function() {
		$("#facilitiesGroupList").append($('<option>').attr({ value: this.key }).text(this.value));
	});
	$("#facilitiesGroupList").val(result.selected_facilities_group);
	setFromResource(result.facilities_group_conn_list, "facilities_from");

	$("#scheduleId").val(schedule.id);
	$("#scheduleVersionNo").val(schedule.lock_version);

	$("#ui-dialog-title-scheduleEditDialog").empty();
	if($("#scheduleId").val() == '') {
		//新規の場合
		$("#ui-dialog-title-scheduleEditDialog").append("スケジュール登録");
		$("#scheduleExecute").attr({value:"登録する"});

	} else {
		//変更の場合
		$("#ui-dialog-title-scheduleEditDialog").append("スケジュール変更");
		$("#scheduleExecute").attr({value:"変更する"});
	}
}

//ユーザリソース情報設定
function setFromResource(list, targetId) {
	$("#" + targetId).empty();
	$.each(list, function() {
		$("#" + targetId).append($('<option>').attr({ value: this.key }).text(this.value));
	});
	reWriteSelect(targetId, new Array());
}

//スケジュール登録・変更画面表示
function openEditDialog(scheduleId, resourceId, targetDate) {
	var params = {};
	params["schedule_id"] = scheduleId;
	params["selected_resource_id"] = resourceId;
	params["target_date"] = targetDate;

	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/schedule/get_info/"
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -6) {
					//該当データが存在しない or 参照できない場合、一覧再描画
					refresh();
				}
				return;
			}
			var result = data.result;
			renderScheduleDialog(result);
			prependDummyText("scheduleEditDialog");
			$("#scheduleEditDialog").dialog("open");
			removeDummyText("scheduleEditDialog");
		}
	);

}

//スケジュール詳細画面表示
function openDetailDialog(scheduleId) {
	var params = {};
	params["schedule_id"] = scheduleId;

	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/schedule/get_info/"
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status_code == -6) {
					//該当データが存在しない or 参照できない場合、一覧再描画
					refresh();
				}
				return;
			}
			var result = data.result;
			renderScheduleDetailDialog(result);
			
			refreshFollowList().pipe(
				function() {
					prependDummyText("scheduleDetailDialog");
					$("#scheduleDetailDialog").dialog("open");
					removeDummyText("scheduleDetailDialog");
				}
			);
		}
	);
}

//フォロー一覧再描画
function refreshFollowList() {

	var params = {};
	params["schedule_id"] = $("#scheduleId").val();

	setAjaxDefault();
	return $.ajax({
		type: "GET",
		data: params,
		url: "/ajax/schedule/get_schedule_follows/"
	}).then(
		function(data) {
			var result = data.result;
			if(result.length == 0) {
				$("#followViewArea").empty();
				return;
			}
			
			var $h2 = $("<h2 />").addClass("title small").text("コメント").css({"margin-top":"1em"});
			var $table = $("<table />").addClass("table table-bordered result_table comment_list_table");
			var $tbody = $("<tbody />");
			$.each(result, function(){
				
				var entry_time = this.entry_time;
				var follow = this.schedule_follow.memo;
				var follow_id = this.schedule_follow.id;
				var delete_follow = this.delete_follow;
				var entry_resource_name = this.entry_resource_name;
		
				var $delBtn = $("<input />").attr({type:"button", value:"削"}).addClass("btn btn-danger btn-mini");
				$delBtn.click(function(){
					deleteFollow(follow_id);
				});
				
				var $tr = $("<tr />");
				$tr.append($("<td />").html(escapeTextArea(follow)))
				    .append($("<td />").text(entry_resource_name).attr({width:"120px"}))
					.append($("<td />").text(entry_time).attr({width:"100px"}))
					.append($("<td />").append($delBtn).attr({width:"50px"}));
				$tbody.append($tr)
			});
			$table.append($tbody);
			$("#followViewArea").empty();
			$("#followViewArea").append($h2).append($table);
		}
	);
}

//フォロー登録ダイアログ
function openFollowEditDialog() {
	$("#follow_memo").val("");
	$("#followEditDialog").dialog("open");
}

//スケジュールフォロー追加
function followExecute() {
	var params={};
	params["schedule_follow"] = {};
	var schedule_follow = params["schedule_follow"];
	schedule_follow["schedule_id"] = $("#scheduleId").val();
	schedule_follow["memo"] = $("#follow_memo").val();
	schedule_follow["parent_schedule_follow_id"] = "";
	setToken(params);

	if(validateFollow(params) == false) {
		return;
	}

	setAjaxDefault();
	$.ajax({
		type: "POST",
		data: params,
		dataType: "json",
		url: '/ajax/schedule/save_follow/'
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {

				if(data.status_code == -1) {
					//validateエラーの場合、もう一度リトライさせる
					return;
				} else {
					//該当スケジュールが存在しない場合、本ダイアログをクローズし、詳細ダイアログをクローズし、
					//画面を再描画する
					closeScheduleAndFollowDialog();
				}
				return;
			}

			//メッセージを表示し、スケジュールフォローを再描画
			$("#followEditDialog").dialog("close");
			infoCheck(data);
			refreshFollowList();
		}
	);
}

//Follow登録validate
function validateFollow(params) {
	var v = new Validate();
	var schedule_follow = params["schedule_follow"];

	v.addRules({value:schedule_follow["memo"],option:'required',error_args:"フォロー"});
	v.addRules({value:schedule_follow["memo"],option:'maxLength',error_args:"フォロー", size:1024});
	return v.execute();
}

//スケジュール、スケジュールフォローダイアログクローズ
function closeScheduleAndFollowDialog() {
	$("#followEditDialog").dialog("close");
	$("#scheduleDetailDialog").dialog("close");
	refresh();
}

//フォロー削除
function deleteFollow(id) {
	if(window.confirm('フォローを削除します。本当によろしいですか？') == false) {
		return;
	}

	var params={};
	params["schedule_id"] = $("#scheduleId").val();
	params["schedule_follow_id"] = id;
	setToken(params);

	setAjaxDefault();
	$.ajax({
		type: "POST",
		data: params,
		dataType: "json",
		url: '/ajax/schedule/delete_follow/'
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {

				//エラーが存在する場合、ダイアログクローズ
				closeScheduleAndFollowDialog();
				return;
			}

			//メッセージを表示し、スケジュールフォローを再描画
			infoCheck(data);
			refreshFollowList();
		}
	);
}


//空き時間確認画面表示
//・hidden情報に選択済みのリソース、選択状態のりソースIDを設定
//・通常か繰り返しのどちらを開いているか判断して対象日を設定
//(不正な日付の場合、システム日付を設定)
//・指定した日付、リソースに対してスケジュールを描画します
function openScheduleFreeTime() {

	$("#scheduleFreeTimeForm").empty();

	//選択済みのリソース群を取得
	var userResources = getSelectArray("user_to");
	var userSelected = getSelectedResourceArray("user_from");
	var facilitiesResources = getSelectArray("facilities_to");
	var facilitiesSelected = getSelectedResourceArray("facilities_from");
	var resources = mergeResource(userResources, userSelected, facilitiesResources, facilitiesSelected);

	//hidden領域に設定
	setFreeTimeTargetResourceIdArea(resources);

	//日付を設定
	var targetDate = setFreeTargetDate();

	var viewType = setScheduleFreeTimeViewType();

	//取得方法を設定
	var param = {};
	param["baseDate"] = targetDate;
	param["resourceIds"] = getValues4Name("resourceIds");
	param["viewType"] = viewType;

	//入力チェックし、エラーが無い場合、windowを開く
	checkScheduleFreeTimeParam(param);
}

//パラメータチェック
function checkScheduleFreeTimeParam(params) {

	setAjaxDefault();
	$.ajax({
		type: "POST",
		data: params,
		dataType: "json",
		url: contextPath + '/groupware/scheduleDaily4ResourceAjax/checkData/',
		success: function(data, status){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}
			//子画面表示
			openScheduleFreeTimeWindow();
		}
	});
}

//空き時間確認子画面表示
//windowをopenし、それをターゲットとしてSubmit
function openScheduleFreeTimeWindow() {
	window.open('about:blank', 'scheduleFreeTime', 'width=750, height=500, resizable=yes');

	$("#scheduleFreeTimeForm").attr({"action":contextPath + "/groupware/scheduleDaily4Resource/"});
	$("#scheduleFreeTimeForm")[0].submit(function () {
		return false;
	});
}

//参照方法設定
function setScheduleFreeTimeViewType() {
	var type = "appointment"
	var $hidden = $("<input />").attr({type:"hidden", name:"viewType", value:type});
	$("#scheduleFreeTimeForm").append($hidden);

	return type;

}

//日付設定
function setFreeTargetDate() {
	var targetDate = "";
	//どちらの画面を表示しているかによって取得元を変更する
	if($("#normal_schedule_area").is(".ui-tabs-hide") == false) {
		//通常のスケジュール
		targetDate = $("#normal_startDate").val();
	} else {
		//繰り返しのスケジュール
		targetDate = $("#repeat_startDate").val();
	}

	var checkedDate = unFormatDate(targetDate);
	var afterDate = formatDateyyyyMMdd(checkedDate);

	if(targetDate == '' || checkedDate == afterDate) {
		//不正な日付の場合、システム日付を対象日付とする
		var dataFormat = new DateFormat("yyyy/MM/dd");
		targetDate = dataFormat.format(new Date());
	}

	targetDate = unFormatDate(targetDate);

	var $hidden = $("<input />").attr({type:"hidden", name:"baseDate", value:targetDate});
	$("#scheduleFreeTimeForm").append($hidden);

	return targetDate;
}

//hidden領域設定
function setFreeTimeTargetResourceIdArea(resources) {
	$.each(resources, function(){
		var $hidden = $("<input />").attr({type:"hidden", name:"resourceIds", value:this});
		$("#scheduleFreeTimeForm").append($hidden);
	});
}

//マージ処理
function mergeResource(userResources, userSelected, facilitiesResources, facilitiesSelected) {
	var ret = {};
	var index = 0;
	$.each(userResources, function(){
		ret[index] = this;
		index++;
	});
	$.each(userSelected, function(){
		ret[index] = this;
		index++;
	});
	$.each(facilitiesResources, function(){
		ret[index] = this;
		index++;
	});
	$.each(facilitiesSelected, function(){
		ret[index] = this;
		index++;
	});
	return ret;
}

