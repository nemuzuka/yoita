function turnResources(pageNo, path) {
	var params={};
	params["page_no"] = pageNo;
	renderMain(params, path);
}

$(function(){

	//初回データ取得
	var params = {};
	params["group_resource_id"] = $("#group_resource_id").val();
	renderMain(params, "/ajax/scheduleWeekGroup/");

	//スケジュール表示切替ボタンを押下された場合の処理
	$("#today").click(function(){
		renderTodaySchedule();
	});
	$("#prev_week").click(function(){
		renderTargetSchedule("prev","week");
	});
	$("#prev_day").click(function(){
		renderTargetSchedule("prev","day");
	});
	$("#next_day").click(function(){
		renderTargetSchedule("next","day");
	});
	$("#next_week").click(function(){
		renderTargetSchedule("next","week");
	});

	$("#groupResource").change(function(){
		changeGroupResource($("#groupResource").val());
	});

	$("#defaultGroupResource").click(function(){
		moveGroupResource("");
	});
});

//週次スケジュール描画
//この関数名は共通処理より呼ばれるので重要です。
function callAjaxAndrenderSchedule(params) {

	//サーバに問い合わせ
	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/scheduleWeekGroup/move_date/"
	}).then(
		function(data){
			successRender(data);
		}
	);
}

//最新データ取得
//この関数名は共通処理より呼ばれるので重要です。
function refresh() {
	var params={};
	renderMain(params, "/ajax/scheduleWeekGroup/refresh/");
}


//グループ指定初回週次スケジュール描画
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

	var result = data.result;
	//再描画
	renderSchedule(result);
	renderPager(result);

	//グループを選択状態にする
	if(result.target_group_resource_id != null) {
		$("#groupResource").val(result.target_group_resource_id);
	}
}

//ページャ部分の表示
function renderPager(result) {
	var $widgetDisp = $("#pager");
	$widgetDisp.empty();
	var $widgetContentDisp = $("<div />");
	var $pager = $("<div />").addClass("pager-area").append($("<span />").addClass("count").text("全" + result.total_count + "件")).append(result.link);

	$widgetContentDisp.append($pager);
	$widgetDisp.append($widgetContentDisp);

}

