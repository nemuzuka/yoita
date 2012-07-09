//設備メンテナンスのjs

$(function(){
	$(window).unload(function(){
		//画面を離れる場合
		unBlockLoadingMsg();
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

			//検索ボタンを押下していた場合、検索処理を行う
			if(param.click_search == true) {
				//検索処理を行う
				executeSearch(param.view_page_no);
			}
		}
	);
});

