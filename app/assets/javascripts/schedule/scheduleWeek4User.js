$(function(){
	renderTodaySchedule();

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
		url: "/ajax/scheduleWeekUser/"
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}

			var result = data.result;
			//再描画
			renderSchedule(result);
		}
	);
}

//最新データ取得
//この関数名は共通処理より呼ばれるので重要です。
function refresh() {
	//サーバに問い合わせ
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/scheduleWeekUser/refresh/"
	}).then(
		function(data){

			//共通エラーチェック
			if(errorCheck(data) == false) {
				return;
			}
			var result = data.result;
			//再描画
			renderSchedule(result);
		}
	);
}

