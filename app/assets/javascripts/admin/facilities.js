//設備メンテナンスのjs
$(function(){
	$(window).unload(function(){
		//画面を離れる場合
		unBlockLoadingMsg();
	});
	
	//dialogの登録
	initDialog();
	
	$("#addFacillitiesBtn").click(function(){
		openEditDialog("");
	});

	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/facilities/get_serch_info",
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
	
	$("#searchFacillitiesBtn").click(function(){
		searchFacillities();
	});

});

//ダイアログ初期化
function initDialog(){
	$("#facillitiesDialog").dialog({
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

	$("#facillitiesSortDialog").dialog({
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
	$("#facillitiesDialog-add").click(function(){
		execute();
	});
	
	$("#facillitiesDialog-cancel").click(function(){
		$("#facillitiesDialog").dialog("close");
	});
	

	//ソートダイアログ
	$("#sortFacillitiesBtn").click(function(){
		openSortDialog();
	});
	$("#sort_up").click(function(){
		upItems("facillities_to");
	});
	$("#sort_down").click(function(){
		downItems("facillities_to");
	});
	$("#facillitiesSortDialog-execute").click(function(){
		executeSort();
	});
	$("#facillitiesSortDialog-cancel").click(function(){
		$("#facillitiesSortDialog").dialog("close");
	});
}

//設備検索
function searchFacillities() {
	var params = {};
	params["name"] = $("#search_name").val();
	
	setAjaxDefault();
	$.ajax({
		type: "GET",
		url: "/ajax/facilities/list",
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
		url: "/ajax/facilities/refresh"
	}).then(
		function(data) {
			render(data);
		}
	);
}

//ページング処理
function turnFacilities(pageNo, url) {
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

	var $pager = $("<div />").addClass("pager").append(
		$("<span />").addClass("count").text("全" + result.total_count + "件")).append(result.link);

	var $table = $("<table />").attr({"id":"result_list"}).addClass("table1 result_table");
	var $tbody = $("<tbody />");

	//ヘッダ部分作成
	var $thead = $("<thead />")
		.append($("<tr />")
			.append($("<th />").text("設備名").addClass("th1"))
			.append($("<th />").text("メモ").addClass("th1"))
			.append($("<th />").text("").addClass("th1"))
		);
	$table.append($thead);

	$.each(result.list, function() {

		var $delButton = $("<input />").attr({type:'button', value:'削除'}).addClass("btn x-mini delete");
		var resourceId = this.id;
		var version = this.lock_version;
		var name = this.name;
		var memo = escapeTextArea(this.memo);

		var $a = $("<a />").attr({href: "javascript:void(0)"}).text(name);
		$a.click(function(){
			openEditDialog(resourceId);
		});

		$delButton.click(function(){
			deleteFacilities(resourceId, version, name);
		});

		//※printMemoは、サーバ側でエスケープしているので、html出力可
		var $tr = $("<tr />");
		$tr.append($("<td />").append($a).addClass("td1"))
			.append($("<td />").html(memo).addClass("td1"))
			.append($("<td />").append($delButton).addClass("td1"));
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
		title = "設備登録";
		buttonLabel = "登録する";
	} else {
		title = "設備変更";
		buttonLabel = "変更する";
	}
	$("#ui-dialog-title-facillitiesDialog").empty();
	$("#ui-dialog-title-facillitiesDialog").append(title);
	$("#facillitiesDialog-add").attr({value:buttonLabel});
	
	var params = {};
	params["resource_id"] = resourceId;
	
	setAjaxDefault();
	var task;
	task = $.ajax({
		type: "GET",
		url: "/ajax/facilities/show",
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
			var form = data.result;
			$("#resource_name").val(form.name);
			$("#resource_memo").val(form.memo);

			$("#resource_lock_version").val(form.lock_version);
			$("#resource_id").val(form.id);
			
			prependDummyText("facillitiesDialog");
			$("#facillitiesDialog").dialog("open");
			removeDummyText("facillitiesDialog");
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
		url: "/ajax/facilities/save",
		data: params
	});
	
	//後処理の登録
	//
	task.pipe(
		function(data) {
			//共通エラーチェック
			if(errorCheck(data) == false) {
				if(data.status == -1 ) {
					//validateエラーの場合、処理終了
					//※それ以外の場合、ダイアログをクローズして一覧再描画する
					return;
				}
				return;
			}
			
			//メッセージを表示して、戻る
			infoCheck(data);
			$("#facillitiesDialog").dialog("close");
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
	setToken(params)
	return params;
}

//登録validate
function validate(params) {
	var v = new Validate();
	var resource = params["resource"]
	v.addRules({value:resource["name"],option:'required',error_args:"設備名"});
	v.addRules({value:resource["name"],option:'maxLength',error_args:"設備名", size:128});

	v.addRules({value:resource["memo"],option:'maxLength',error_args:"メモ", size:1024});
	return v.execute();
}
