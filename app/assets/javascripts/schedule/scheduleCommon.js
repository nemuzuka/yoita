//スケジュール追加image追加
function setAddImage(td, targetResourceId, targetDate) {
	var $img = $("<img />").attr({src:"/images/write20.gif"}).css('cursor','pointer');
	$img.attr({"alt":"スケジュールを追加します","title":"スケジュールを追加します"});
	$img.click(function(){
		openEditDialog("", targetResourceId, targetDate);
	});
	td.append($img);
}


//ユーザグループリストを変更した際の処理
function changeGroupResource(selectedValue) {
	if(selectedValue == '') {
		return;
	}
	moveGroupResource(selectedValue);
}

//指定ユーザグループリストに対する週次スケジュール表示
function moveGroupResource(selectedValue) {
	//選択ユーザグループリストに対して週次予定を表示
	viewLoadingMsg();
	var appendstr = "";
	if(selectedValue != "") {
		appendstr = "?group_resource_id=" + selectedValue;
	}
	document.location.href = "/scheduleWeekGroup/" + appendstr;
}

//スケジュール情報追加
function setSchedule(list, td) {
	$.each(list, function(){
		var $a = $("<a />").text(this.view_title).attr({href: "javascript:void(0)"});
		var scheduleId = this.schedule_id;
		$a.click(function(){
			openDetailDialog(scheduleId);
		});
		var $duplicate = $("<span />").addClass("duplicate");
		if(this.duplicate) {
			$duplicate.text("×");
		}

		if(scheduleId == null) {
			//スケジュールIDがnullの場合(非公開で自分が含まれていない)
			$a = $("<span />").text(this.view_title);
		}

		var $span = $("<span />").append($duplicate).append($a);
		var $div = $("<div />").css({"height":"5px"});
		td.append($span).append($("<br />")).append($div);
	});
}


