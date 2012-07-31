//当日スケジュール描画
function renderTodaySchedule() {
	var params = {};
	params["viewType"] = "today";
	callAjaxAndrenderSchedule(params);
}

//基準日を移動したスケジュール描画
function renderTargetSchedule(viewType, amountType) {
	var params = {};
	params["view_type"] = viewType;
	params["amount_type"] = amountType;
	callAjaxAndrenderSchedule(params);
}

//スケジュール一覧描画
function renderSchedule(result) {

	//select設定
	$("#groupResource").empty();
	$.each(result.group_list, function(){
		$("#groupResource").append($('<option>').attr({ value: this.key }).text(this.value));
	});

	var $table = $("#schedule_area");
	$table.empty();

	//表示期間の設定
	$("#viewDateRange").text(result.view_date_range);

	//ヘッダ部分作成
	var $thead = $("<tr />").append($("<th />").text("").addClass("days"));
	$.each(result.view_date_list, function() {
		var addClass = "";
		if(this.holiday) {
			addClass = "sche_week_holiday";
		} else if(this.saturday) {
			addClass = "sche_week_saturday";
		} else if(this.sunday) {
			addClass = "sche_week_sunday";
		}
		var todayClass = "";
		if(this.today) {
			todayClass = "sche_week_today";
		}
		var $th = $("<th />").addClass("days").addClass(addClass).addClass(todayClass);
		
		var target_date = executeFormatDateyyyyMMdd(this.date_yyyy_mm_dd, "yyyyMMdd", "M/d")
		
		var $dayOfTheWeekSpan = $("<span />");
		var thText = target_date + "(" + this.day_of_the_week_name + ")";
		$dayOfTheWeekSpan.text(thText);
		var $holidayNameSpan = null;
		if(this.holiday_memo != null && this.holiday_memo != '') {
			$holidayNameSpan = $("<span />").text(this.holiday_memo);
		}

		if($holidayNameSpan == null) {
			$th.append($dayOfTheWeekSpan);
		} else {
			$th.append($dayOfTheWeekSpan).append("<br />").append($holidayNameSpan);
		}

		$thead.append($th);
	});
	$table.append($("<thead />").append($thead));

	//body部分作成
	var $tbody = $("<tbody />");
	$.each(result.view_resource_schedule, function(){
		var $tr = $("<tr />");
		var targetResourceId = this.resource_id;

		//リソース情報表示
		var $a = $("<a />").text(this.name).attr({href: "javascript:void(0)"});
		$a.click(function(){
			openResourceDetailDialog(targetResourceId);
		});
		var resourceClass = "td1_schedule";
		if(this.resource_type == "003") {
			resourceClass = "td1_userGroup";
		}
		var $td = $("<td />").addClass(resourceClass).append($a).append("<br />");
		var $img = $("<img />").attr({src:calender_img_path}).css('cursor','pointer');
		$img.attr({"alt":"月の予定を表示します","title":"月の予定を表示します"});
		$img.click(function(){
			moveMonthResource(targetResourceId);
		});
		$td.append($img);
		$tr.append($td);

		//日付情報表示
		var daySchedules = this.schedule_list;
		$.each(daySchedules, function(index){
			$td = $("<td />").addClass(resourceClass);

			//時刻指定無しListを表示
			setSchedule(this.no_time_list, $td);
			//時刻指定有りListを表示
			setSchedule(this.time_list, $td);

			var targetDate = formatDateyyyyMMdd(result.view_date_list[index].date_yyyy_mm_dd);
			setAddImage($td, targetResourceId, targetDate);

			$tr.append($td);
		});
		$tbody.append($tr);
	});
	$table.append($tbody);
}

//リソース情報表示ダイアログ表示
function openResourceDetailDialog(resourceId) {
	var params = {};
	params["resource_id"] = resourceId;

	setAjaxDefault();
	$.ajax({
		type: "GET",
		data: params,
		url: "/ajax/schedule/get_resource_detail/"
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
			renderResourceDetailDialog(result);
		}
	);
}

//指定リソースの詳細ダイアログを表示します
function renderResourceDetailDialog(result) {
	var resource = result.resource;
	if(resource.resource_type == '001') {
		//ユーザの場合
		$("#userName").text(resource.name);
		var user_info = result.user_info;
		$("#readingCharacter").text(user_info.reading_character);

		$("#tel").text(user_info.tel);

		$("#mail").text(user_info.mail);

		$("#belongingUserGroup").text("");
		$.each(result.belong_group_list, function(){
			var $span = $("<span />").text("" + this.value);
			$("#belongingUserGroup").append($span).append("<br />");
		});
		$("#userMemo").html(escapeTextArea(resource.memo));

		prependDummyText("userDetailDialog");
		$("#userDetailDialog").dialog("open");
		removeDummyText("userDetailDialog");

	} else if(resource.resource_type == '002') {
		//設備の場合
		$("#facilitiesName").text(resource.name);
		$("#belongingFacilitiesGroup").text("");
		$.each(result.belong_group_list, function(){
			var $span = $("<span />").text("" + this.value);
			$("#belongingFacilitiesGroup").append($span).append("<br />");
		});
		$("#facilitiesMemo").html(escapeTextArea(resource.memo));

		prependDummyText("facilitiesDetailDialog");
		$("#facilitiesDetailDialog").dialog("open");
		removeDummyText("facilitiesDetailDialog");

	} else if(resource.resource_type == '003') {
		//ユーザグループの場合
		$("#userGroupName").text(resource.name);
		$("#userGroupMemo").html(escapeTextArea(resource.memo));

		prependDummyText("userGroupDetailDialog");
		$("#userGroupDetailDialog").dialog("open");
		removeDummyText("userGroupDetailDialog");
	}
}

//指定リソースに対する月次スケジュール表示
function moveMonthResource(resourceId) {
	//選択リソースに対して月次予定を表示
	viewLoadingMsg();
	document.location.href = "/scheduleMonthResource/?resource_id=" + resourceId;
}

