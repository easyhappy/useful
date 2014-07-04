var isloading = false;
var p = 1;//当前页码
//查询条件
var search = function(){
	p = 0;
	get_ajax_data('search');
};

//获取数据
var get_ajax_data = function(type){//type =1 getnext  type = 2 search
	var data = get_post_data();
	//console.log(data);
	$.post('/Api/browse',data,function(rs){
		isloading = false;
		if(type == 'next'){//
			if(!rs){
				isloading = true;
				$("#ajax_data_content").append('<p class="fl" style="width:100%;">已加载完所有对应项目。。。</p>');
				return false;
			}
			$("#ajax_data_content").append(rs);
		}
		if(type == 'search'){
			if(!rs){
				$("#ajax_data_content").html('没有找到对应项目。。。');
				isloading = true;
				return false;
			}
			$("#ajax_data_content").html(rs);
		}
		
		$("._js_show").fadeIn('500');
	},
	'html');
};

var get_post_data = function(){
	var pageSize = 6;
	var status = '';
	$("._js_where.select").each(function(){
		status += $(this).attr("data-where") + ",";
	});
	status = status.substr(0,status.length-1);
	var column = $("._js_order.select").attr("data-order");
	var order = $("._js_order.select").hasClass("down")?"asc":"desc";
	var data = {
			pageSize:pageSize,
			pageStart:pageSize*p,
			keyword:$("#_js_keyword").val(),
			prdType:$("._js_type.select").attr("data-type"),
			prdDetailStatus:status,
			sortedOrder:order,
			sortedColumn:column
			};
	return data;
}
$(function(){

	$(window).scroll(function(){
		var over = $(window).height()*2;
		if($(window).scrollTop() >= ($(document).height() - over) ){
			getnext();
		}
	});
	
	//排序规则
	$("._js_order").click(function(){
		$("._js_order").removeClass("select");
		$(this).addClass("select");
		if($(this).hasClass("down")){
			$(this).removeClass("down");
		}else{
			$(this).addClass("down");
		}
		search();
	});
	
	//where 条件 
	$("._js_where").click(function(){
		if($(this).hasClass("select")){
			$(this).removeClass("select");
		}else{
			$(this).addClass("select");
		}
		search();
	});
	
	//keyword
	$("#keyword_search").click(function(){
		search();
	});
	$("#_js_keyword").keydown(function(e){
		if(e.keyCode==13){
			search();
		}
	});
	
	//获取下一页内容
	var getnext = function(){
		if(isloading){
			return;
		}
		p++;
		isloading = true;
		get_ajax_data('next');
	};
	
	
	
	//页面初始化
	//search();
});//start


