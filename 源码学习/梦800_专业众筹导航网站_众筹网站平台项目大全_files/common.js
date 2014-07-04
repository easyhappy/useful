$(function(){
//滚动吸顶
topDistanceTm = function(fixBox , scrollHeight , fixClass){
	var d=document.documentElement;
	var b=document.body;
	$(window).bind("scroll", function(){set()});
	function set(){		
		var scrollTop = window.pageYOffset || d.scrollTop || b.scrollTop || 0;
		if (scrollTop < scrollHeight) {
			$(fixBox).removeClass(fixClass);
		} else {
			$(fixBox).addClass(fixClass);
		}
	};
	set();
}
//返回顶部
backTop=function (btnId){
    var btn=document.getElementById(btnId);
	var d=document.documentElement;
	var b=document.body;
	$(window).bind("scroll", function(){set()});
	 btn.onclick=function (){
        window.onscroll=null;
        this.timer=setInterval(function(){
            d.scrollTop-=Math.ceil((d.scrollTop+b.scrollTop)*0.1);
            b.scrollTop-=Math.ceil((d.scrollTop+b.scrollTop)*0.1);
            if((d.scrollTop+b.scrollTop)==0) clearInterval(btn.timer,window.onscroll=set);
        },10);
        $(this).find("img").animate({height:140}, 1000); 
        $(this).animate({opacity:0}, 2000);      
    };
	function set(){
		var scrollTop = window.pageYOffset || d.scrollTop || b.scrollTop || 0;
		btn.style.display= scrollTop > 300 ? 'block':"none";	
		if(scrollTop < 100){
			$("#"+btnId).css('display','none').animate({opacity:1}, 0); 
			$("#"+btnId).find('img').animate({height:0}, 0);
		}	
	};	
	set();
};
//滚动吸顶  筛选条
//topDistanceTm(".screen-nav","500","fixedSet-screen");
//滚动吸顶  菜单
topDistanceTm(".side-header","140","fixedSet-menu");
//返回顶部
backTop('gotop');
//banner 轮播
(function(){
var len = 7;
var banner = $("#JS-banner");
var liBanner = $("#JS-banner li");
var winWidth = $(window).width();
banner.css("width", len * winWidth);
liBanner.css("width", winWidth);
var sindex = 0;
var inanimate = false;
var inHover = false;
$(window).bind("resize", initsize);
function initsize() {
	if (inanimate) {
    	banner.stop(true,true);
    }
	winWidth = $(window).width();
	banner.css("width", len * winWidth);
	liBanner.css("width", winWidth);
}
initsize();
function moveByDirect(to_right) {
	if (inanimate) return;
	inanimate = true;
	var start = 0;
	var end = - winWidth;
	if (!to_right) {
		start = -winWidth;
		end = 0;
		loadBannerImg(banner.children().last().prev());
		banner.children().last().insertBefore(banner.children().first());
	} else {
		loadBannerImg(banner.children().first().next());
	}
	banner.css("margin-left", start);
	banner.animate({"margin-left": end}, 500, function(){
		inanimate = false;
		if (to_right) {
			banner.children().first().insertAfter(banner.children().last());
		}
		banner.css("margin-left", 0);
		autoScroll();
 	});
}
$("#JS-banner-pre").bind("click", function(){
	moveByDirect(false);
});
$("#JS-banner-next").bind("click", function(){
	moveByDirect(true);
});
$("#JS-banner").bind("mouseover", function(){
	inHover = true;
});
$("#JS-banner").bind("mouseout", function(){
	inHover = false;
});
$("#JS-banner img").bind("load", function(){
	$(this).attr("data-load","ok");
});
$(".banner").hover(
	function(){
	  	$('.focus-btn').css('display','block');
		$('.describe').animate({bottom:0}, 500);
	},
	function(){
   		$('.focus-btn').css('display','none');
		$('.describe').animate({bottom:'-150px'}, 100);
}); 
var timer = null;
function clearAutoScroll() {
	if (timer) {
		clearTimeout(timer);
		timer = null;
	}
}
window.loadBannerImg = function(p){
	var o = p.children().children("img");
	if (o.attr("data-init")!="ok"){
		o.attr({"src":o.data("src"),"data-init":"ok"});
	}
}
function autoScroll(init) {
	clearAutoScroll();
	timer = setTimeout(function() {
		if (inHover || 
			banner.children().first().next().children().attr("background-image")!="ok"
			//banner.children().first().next().children().attr("data-load").attr("data-load")!="ok"
				) {
			moveByDirect(true);
		} else {
			moveByDirect(true);
		}
	}, 6000);
	if (!init){
		loadBannerImg(banner.children().first().next());
	}
}
autoScroll(1);
//设置鼠标滑过 停止轮播
$(".banner").hover(function(){
	clearTimeout(timer);
},function(){
	autoScroll(1);
});

})();
$(function(){
	loadBannerImg($("#JS-banner").children().first().next());
	$("#JS-banner img").each(function(){
		//$(this).attr("src",$(this).attr("data-src"));
	});
});
});