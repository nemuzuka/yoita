//祝日管理のjs
$(function(){

	//クライアントのシステム日付を元に、selectを作成
	$("#target_year").empty();
	var dateFormat = new DateFormat("yyyy");
	var targetYyyy = dateFormat.format(new Date());

	$("#target_year").append($('<option>').attr({ value: "" }).text(""));

	for(var i = 0; i < 5; i++) {
		var writeTarget = (targetYyyy - 1) + i;
		$("#target_year").append($('<option>').attr({value: writeTarget}).text(writeTarget));
	}

	$("#target_year").change(function(){
		changeTargetYear();
	});

	$("#target_year").val(targetYyyy);
	$("#target_year").change();

});
//対象年変更時の処理
function changeTargetYear() {

	$("#result_area").empty();

	var selected = $("#target_year").val();
	if(selected == "") {
		return;
	}

	//指定年に紐づく祝日情報を設定する
	var params = {};
	params["target_year"] = selected;

	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/nationalHolidays/get_holidays_info/"
	}).then(
		function(data){
			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}
			var result = data.result;

			var $widgetDisp = $("<div />").addClass("widget");
			var $widgetHeaderDisp = $("<div />").addClass("widget-header").append($("<h2 />").addClass("title").text(selected + "年の祝日"));
			var $widgetContentDisp = $("<div />").addClass("widget-content");

			var $table = $("<table />").attr({"id":"result_list"}).addClass("result_table");

			var $span = $("<span />").text(" 例）01/01").addClass("important-msg");

			//ヘッダ部分作成
			var $thead = $("<thead />")
				.append($("<tr />")
					.append($("<th />").text("対象日付").append($span).attr({width:"200px"}))
					.append($("<th />").text("メモ"))
					.append($("<th />").text("").attr({width:"50px"}))
				);
			$table.append($thead);

			var $tbody = $("<tbody />");
			$.each(result, function(index) {
				var $tr = createHolidayTr(this.target_month_day, this.memo);
				$tbody.append($tr);
			});
			$table.append($tbody);

			//変更するボタンを追加
			var $updateButton = $("<input />").attr({type:"button", value:"変更する"}).addClass("btn btn-primary");
			$updateButton.click(function(){
				updateHoliday();
			});
			var $success = $("<div />").addClass("search_ctrl").append($updateButton);

			//設定追加ボタンの追加
			var $addHolidayDiv = $("<div />").addClass("search_ctrl");
			var $addHoliday = $("<input />").attr({value:"祝日追加",type:"button"}).addClass("btn");
			$addHoliday.click(function(){
				addHoliday();
			});
			$addHolidayDiv.append($addHoliday);

			$widgetContentDisp.append($addHolidayDiv).append($table).append($success);
			$widgetDisp.append($widgetHeaderDisp).append($widgetContentDisp);
			
			$("#result_area").append($widgetDisp);

		}
	);
}

//祝日追加ボタン押下時
function addHoliday() {

	var $tr = createHolidayTr("","");
	$("#result_list tbody").append($tr);
}

//祝日設定行追加
function createHolidayTr(targetDate, memo) {
	var $delButton = $("<input />").attr({type:'button', value:'削除'}).addClass("btn btn-danger btn-mini");
	$delButton.click(function(){
		$(this).parent().parent().remove();
	});

	var $tr = $("<tr />");
	var $targetDate = $("<input />").attr({type:"text", name:"targetDate"}).val(formatDateMMdd(targetDate)).addClass("input-small");
	setMMddFormatEvent($targetDate);
	var $memo = $("<input />").attr({type:"text", name:"memo"}).val(memo).addClass("input-xlarge");

	$tr.append($("<td />").append($targetDate))
		.append($("<td />").append($memo))
		.append($("<td />").append($delButton));
	return $tr;

}

//祝日変更処理
function updateHoliday() {
	//リクエストパラメータを生成
	var params = createParams();

	if(validate(params) == false) {
		return;
	}

	setAjaxDefault();
	$.ajax({
		type: "POST",
		data: params,
		dataType: "json",
		url: '/ajax/nationalHolidays/update'
	}).then(
		function(data){
			//共通エラーチェック
			if(errorCheck(data) == false) {

				if(data.status_code == -1 ) {
					//validateエラーの場合、リトライさせる
					return;
				}
			}

			//メッセージを表示して、再描画
			infoCheck(data);
			changeTargetYear();
		}
	);
}

//パラメータ生成
function createParams() {
	var params={};
	params["target_year"] = $("#target_year").val();
	params["target_day_list"] = getTextArray("targetDate", true);
	params["memo_list"] = getTextArray("memo", false);
	setToken(params)
	return params;
}

//登録validate
function validate(params) {
	var v = new Validate();
	v.addRules({value:params["target_day_list"],option:'day4List',error_args:"対象日付"});
	v.addRules({value:params["memo_list"],option:'maxLength4List',error_args:"メモ", size:1024});
	return v.execute();
}

//textの配列情報を取得します。
function getTextArray(targetName, isUnFormat) {
	var retArray = [];
	$("input[type='text'][name='" + targetName + "']").each(function() {
		
		if(isUnFormat) {
			retArray.push(unFormatDate($(this).val()));
		} else {
			retArray.push($(this).val());
		}
	});
	return retArray;
}
