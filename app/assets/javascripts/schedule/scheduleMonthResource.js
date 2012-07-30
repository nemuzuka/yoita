$(function(){

	//初回データ取得
	var params = {};
	renderMain(params, "/ajax/scheduleMonthResource/");

	//スケジュール表示切替ボタンを押下された場合の処理
	$("#thisMonth").click(function(){
		renderThisMonthSchedule();
	});
	$("#prev").click(function(){
		renderTargetSchedule("prev");
	});
	$("#next").click(function(){
		renderTargetSchedule("next");
	});

	$("#groupResource").change(function(){
		changeGroupResource($("#groupResource").val());
	});

	$("#defaultGroupResource").click(function(){
		moveGroupResource("");
	});
});

//今月スケジュール描画
function renderThisMonthSchedule() {
	var params = {};
	params["view_type"] = "today";
	callAjaxAndrenderSchedule(params);
}

//基準月を移動したスケジュール描画
function renderTargetSchedule(viewType) {
	var params = {};
	params["view_type"] = viewType;
	callAjaxAndrenderSchedule(params);
}

//月次スケジュール描画
function callAjaxAndrenderSchedule(params) {

	//サーバに問い合わせ
	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/scheduleMonthResource/move_month/"
	}).then(
		function(data, status){
			successRender(data);
		}
	);
}

//最新データ取得
//この関数名は共通処理より呼ばれるので重要です。
function refresh() {
	var params={};
	renderMain(params, "/ajax/scheduleMonthResource/");
}


//月次スケジュール描画
function renderMain(params, path) {

	//サーバに問い合わせ
	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: path
	}).then(
		function(data){
			successRender(data);
		}
	);

}


//成功時の描画
function successRender(data) {
	//共通エラーチェック
	if(errorCheck(data) == false) {
		return;
	}

	var scheduleView4Month = data.result;
	//描画
	renderSchedule(scheduleView4Month);

}

//描画メイン
function renderSchedule(result) {

	$("#viewMonth").text(result.view_date_range);
	var resourceSchedule = result.view_resource_schedule[0];
	var targetResourceId = resourceSchedule.resource_id;
	$("#targetResourceName").text(resourceSchedule.name);

	//select設定
	$("#groupResource").empty();
	$.each(result.group_list, function(){
		$("#groupResource").append($('<option>').attr({ value: this.key }).text(this.value));
	});

	var $table = $("#schedule_area");
	$table.empty();

	//ヘッダ部分描画
	var $thead = $("<tr />")
		.append($("<th />").text("日").addClass("sche_week_sunday"))
		.append($("<th />").text("月").addClass("sche_week_monday"))
		.append($("<th />").text("火").addClass("sche_week_tuesday"))
		.append($("<th />").text("水").addClass("sche_week_wednesday"))
		.append($("<th />").text("木").addClass("sche_week_theseday"))
		.append($("<th />").text("金").addClass("sche_week_friday"))
		.append($("<th />").text("土").addClass("sche_week_saturday"));
	$table.append($thead);

	//body部分作成
	var tdCount = 0;
	var $tr = $("<tr />");
	$.each(result.view_date_list, function(index){

		var holidayName = this.holiday_memo;
		if(holidayName == null) {
			holidayName = "";
		}
		var addClass = "";
		if(this.today) {
			addClass = "sche_month_today";
		} else if(this.holiday) {
			addClass = "sche_month_holiday";
		} else if(this.saturday) {
			addClass = "sche_month_saturday";
		} else if(this.sunday) {
			addClass = "sche_month_sunday";
		} else if(this.target_month) {
			addClass = "sche_terget_month";
		}

		//対象年月でない場合、class指定を初期値にする
		if(this.target_month == false) {
			addClass = "";
		}

		var target_date = executeFormatDateyyyyMMdd(this.date_yyyy_mm_dd, "yyyyMMdd", "d")

		var $span = $("<span />").text(target_date + " " + holidayName);
		var $td = $("<td />").append($span).append("<br />").addClass("td1_schedule").addClass(addClass);

		//時刻指定無しListを表示
		var noTimeList = resourceSchedule.schedule_list[index].no_time_list;
		setSchedule(noTimeList, $td);

		//時刻指定有りListを表示
		var timeList = resourceSchedule.schedule_list[index].time_list;
		setSchedule(timeList, $td);

		var targetDate = formatDateyyyyMMdd(this.date_yyyy_mm_dd);
		setAddImage($td, targetResourceId, targetDate);

		$tr.append($td);
		tdCount++;
		if(tdCount >= 7) {
			//テーブルに追加し、新たにtrを作成する
			$table.append($tr);
			tdCount = 0;
			$tr = $("<tr />");
		}
	});
}
