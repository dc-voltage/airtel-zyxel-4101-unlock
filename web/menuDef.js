
/**
JSON menu demo
 *https://www.cnblogs.com/tugenhua0707/p/3474791.html
 */


 function AccordionMenu(options) {
	this.config = {
		containerCls        : '.subMenu',   
		containerClss       : '.mainMenu',  
		containerClsss      : '.mleftMenu', 
		menuArrs            :  '',                         
		type                :  'click',                    
		renderCallBack      :  null,                      
		clickItemCallBack   : null                        
	};
	this.cache = {
		
	};
	this.init(options);
 }

 
 AccordionMenu.prototype = {

	constructor: AccordionMenu,

	init: function(options){
		this.config = $.extend(this.config,options || {});
		var self = this,
			_config = self.config,
			_cache = self.cache;
		
		// .LeftMenu
		$(_config.containerCls).each(function(index,item){
			self._renderHTML(item);
			self._bindEnv(item); //Open all of the livel-1, level-2, level-3
			self._bindh2(item); //Hide level-1 h2 title
			
		});

		//.TopMenu
		$(_config.containerClss).each(function(index,item){
			self._renderHTML(item); //Hide level-1 h2 title
		});

		// .MobileMenu
		$(_config.containerClsss).each(function(index,item){
			self._renderHTML_M(item);//Open all of the level-1 h2 title MobilePhone menu
			self._bindEnv(item); //Open all of the livel-1, level-2, level-3
			
		});
	},
    //Only h2 -------- level-1
	_renderHTML: function(container){
		var self = this,
			_config = self.config,
			_cache = self.cache;
		var ulhtml = $('<ul class="menuList hidden-xs hidden-sm"></ul>');
		$(_config.menuArrs).each(function(index,item){
			var lihtml = $('<li><h2>'+item.title+'</h2></li>');

			if(item.submenu && item.submenu.length > 0) {
				self._createSubMenu(item.submenu,lihtml);
			}
			$(ulhtml).append(lihtml);
		});
		$(container).append(ulhtml);
		
		_config.renderCallBack && $.isFunction(_config.renderCallBack) && _config.renderCallBack();
		
		// deal with the hierarchical indentation
		self._levelIndent(ulhtml);
		
	},
	//Only Mobile phone h2 ----- level-1
	_renderHTML_M: function(container){
		var self = this,
			_config = self.config,
			_cache = self.cache;
		var ulhtml_mobile = $('<ul class="leftMenuUl"></ul>');
		$(_config.menuArrs).each(function(index,item){
			var lihtml = $('<li><h2>'+item.title+'</h2></li>');

			if(item.submenu && item.submenu.length > 0) {
				self._createSubMenu(item.submenu,lihtml);
			}
			$(ulhtml_mobile).append(lihtml);
		});
		$(container).append(ulhtml_mobile);
		
		_config.renderCallBack && $.isFunction(_config.renderCallBack) && _config.renderCallBack();
		
		// deal with the hierarchical indentation
		self._levelIndent(ulhtml_mobile);
		
	},
	/**
	 * level-2
	 */
	_createSubMenu: function(submenu,lihtml){
		var self = this,
			_config = self.config,
			_cache = self.cache;
		var subUl = $('<ul></ul>'),
			callee = arguments.callee,
			subLi;


		$(submenu).each(function(index,item){
			var url = item.url || 'javascript:void(0)';

			subLi = $('<li><a href="'+url+'">'+item.title+'</a></li>');
			//if submenu have items the add the menuclose icon
			if(item.submenu && item.submenu.length > 0) {
				$(subLi).children('a').prepend('<i class="menuclose"/></i>');
                callee(item.submenu, subLi);
			}
			$(subUl).append(subLi);
		});
		$(lihtml).append(subUl);
	},
	/**
	 * menu every level padding
	 */
	_levelIndent: function(ulList){
		var self = this,
			_config = self.config,
			_cache = self.cache,
			callee = arguments.callee;
	   
		var initTextIndent =0,
			lev = 1,
			$oUl = $(ulList);
		
		while($oUl.find('ul').length > 0){

			initTextIndent = parseInt(initTextIndent,3) + 18 + 'px'; //level-2
			$oUl.children().children('ul').addClass('lev-' + lev).addClass('conul')
						.find('ul').children('li').children('a').css('padding-left', '20px'); //level-3
			$oUl = $oUl.children().children('ul').css('text-indent', initTextIndent);
			lev++;
		}

		$(ulList).find('ul').hide();
		

	
	},
	_bindh2: function(container) {
		$(container).find('> ul > li > h2').hide();
	},
	/**
	 * bind event
	 */
	_bindEnv: function(container) {
		var self = this,
			_config = self.config;

		
		$('h2,a',container).unbind(_config.type);
		$('h2,a',container).bind(_config.type,function(e){
		
			if($(this).siblings('ul').length > 0) {
				$(this).siblings('ul').stop(true,false).slideToggle('fast').end().children('i').toggleClass('menuclose menuopen');  
			}
            //When current lev-2 selected then hide others lev-2
            //After .end() let the arrow .menuopen to .menuclose           
			$(this).parent('li').siblings().find('ul').slideUp().end().find('i').removeClass('menuopen').addClass('menuclose') ;
			
			//$(this).parent('li').siblings().find('ul').find('img.menuopen').removeClass('menuopen').addClass('menuclose');
			_config.clickItemCallBack && $.isFunction(_config.clickItemCallBack) && _config.clickItemCallBack($(this));


		});

	}
 };



	//mobile menu Leftmenu level and actice color setting start-----
	//each page has this function under html
	function getsubMenu(){
		    var active_li = $('.config-lg-left a[href="' + location.pathname.split("/")[location.pathname.split("/").length-1] + '"] , \
		       				   .mleftMenu a[href="' + location.pathname.split("/")[location.pathname.split("/").length-1] + '"]').parent();
		    
		    //current page li add active and arror icon menuopen
			active_li.addClass('active').parent('ul').show().parent().closest('ul.lev-1').show();
	     	//if current page is in level-2 or lowery, let the current level arrow menu open
			if( !active_li.parent().hasClass('lev-1') ){
				 active_li.parent().parent().find('i').removeClass().addClass('menuopen');
			};
	};

	//Main MENU active
	function homeMenu_active(){ $('.TopMenu, .mleftMenu, .infomleftMenu').find('.menuList > li:nth-child(1) > h2').addClass('active');}
	function mobileNetworkMenu_active(){ $('.TopMenu, .mleftMenu, .infomleftMenu').find('.menuList > li:nth-child(2) > h2').addClass('active');}
	function connectedClientsMenu_active(){ $('.TopMenu, .mleftMenu, .infomleftMenu').find('.menuList > li:nth-child(3) > h2').addClass('active');}
	function settingMenu_active(){ $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(4) > h2').addClass('active');}
	function diagnosticMenu_active(){ $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(5) > h2').addClass('active');}
	function aboutMenu_active(){ $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(6) > h2').addClass('active');}
	//MENU linkage
	function mainMenu_linkage(){
	   var Mhome = $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(1) > h2');
	   var Mnetwork = $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(2) > h2');
	   var MconnectedClients = $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(3) > h2');
	   var Msetting = $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(4) > h2');
	   var Mdignostic = $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(5) > h2');
	   var Mabout = $('.TopMenu, .mleftMenu').find('.menuList > li:nth-child(6) > h2');

	   Mhome.off('click').on('click', function(){
	   	$('.TopMenu, .mleftMenu').find('h2').removeClass('active');
	   	Mhome.addClass('active');
	   	window.location.href='Home_connectionStatus.cgi';
	   });

	   Mnetwork.off('click').on('click', function(){
	   	$('.TopMenu, .mleftMenu').find('h2').removeClass('active');
	   	Mnetwork.addClass('active');
	   	window.location.href='MobileNetworking_ConnectToCells.cgi';
	   });

	   MconnectedClients.off('click').on('click', function(){
	   	$('.TopMenu, .mleftMenu').find('h2').removeClass('active');
	   	MconnectedClients.addClass('active');
	   	window.location.href='connected_clientList.cgi';
	   });

	   Msetting.off('click').on('click', function(){
	   	$('.TopMenu, .mleftMenu').find('h2').removeClass('active');
	   	Msetting.addClass('active');
	   	window.location.href='Setting_lan_dhcpSetting.cgi';
	   });

	   Mdignostic.off('click').on('click', function(){
		$('.TopMenu, .mleftMenu').find('h2').removeClass('active');
		Mdignostic.addClass('active');
		window.location.href='diagnostic_selfTest.cgi';
		});

	   Mabout.off('click').on('click', function(){
		$('.TopMenu, .mleftMenu').find('h2').removeClass('active');
		Mabout.addClass('active');
		window.location.href='About.cgi';
		});
		
	}


function page_ctrl(data_obj) {
  var obj_box=(data_obj.obj_box!== undefined)?data_obj.obj_box:function () {
    return;
  };//翻页容器dom对象,必要参数
  var total_item=(data_obj.total_item!== undefined)?parseInt(data_obj.total_item):0;//数据条目总数,默认为0,组件将不加载
  var per_num=(data_obj.per_num!== undefined)?parseInt(data_obj.per_num):5;//每页显示条数,默认为10条
  var current_page=(data_obj.current_page!== undefined)?parseInt(data_obj.current_page):1;//当前页,默认为1
  var total_page=Math.ceil(total_item/per_num);//计算总页数 ,不足2页,不加载组件
  if(total_page<2){
    return;
  }
  //在指定容器内加载分页数据
  $(obj_box).append('<div class="page_content"></div>');
  //在指定容器内加载分页插件
  $(obj_box).append('<div class="page_ctrl"></div>');
  function page_even() {
    //当前页限定,非数字或小于1跳转到第一页,大于总页数,跳转到最后一页
    var regPos = /^\d+$/; // 非负整数
    if(regPos.test(current_page)){
      current_page=current_page<1?1:(current_page>total_page?total_page:current_page);
    }else{
      current_page=1;
    }
    data_obj.change_content(per_num,current_page);
    var inp_val = ( current_page == total_page+1 )? 1:current_page;//跳转页数,input默认显示值
    var append_html='<button class="prev_page">上一页</button>';
    for(var i=0;i<total_page-1;i++){
      if(total_page>8&&current_page>6&&i<current_page-3){
        if(i<2){
          append_html+='<button class="page_num">'+(i+1)+'</button>';
        }
        else if(i==2){
          append_html+='<span class="page_dot">•••</span>';
        }
      }
      else if(total_page>8&&current_page<total_page-3&&i>current_page+1){
        if(current_page>6&&i==current_page+2){
          append_html+='<span class="page_dot">•••</span>';
        }else if(current_page<7){
          if(i<8){
            append_html+='<button class="page_num">'+(i+1)+'</button>';
          }else if(i==8){
            append_html+='<span class="page_dot">•••</span>';
          }
        }
      }
      else{
        if(i==current_page-1){
          append_html+='<button class="page_num current_page">'+(i+1)+'</button>';
        }
        else{
          append_html+='<button class="page_num">'+(i+1)+'</button>';
        }
      }
    }
    if(current_page==total_page){
      append_html+='<button class="page_num current_page">'+(i+1)+'</button>';
    }else{
      append_html+='<button class="page_num">'+(i+1)+'</button>';
    }
    append_html+='<button class="next_page">下一頁</button><span class="page_total">共 '+total_page+' 頁, 到第</span><input class="input_page_num" type="text" value="'+inp_val+'"><span class="page_text">页</span><button class="to_page_num">确定</button>';
    $(obj_box).children('.page_ctrl').append(append_html);
    if(current_page==1){
      $(obj_box+' .page_ctrl .prev_page').attr('disabled','disabled').addClass('btn_dis');
    }else{
      $(obj_box+' .page_ctrl .prev_page').removeAttr('disabled').removeClass('btn_dis');
    }
    if(current_page==total_page){
      $(obj_box+' .page_ctrl .next_page').attr('disabled','disabled').addClass('btn_dis');
    }else{
      $(obj_box+' .page_ctrl .next_page').removeAttr('disabled').removeClass('btn_dis');
    }
  };
  page_even();
  $(obj_box +' .page_ctrl').on('click','button',function () {
    var page_ctrl=$(this);
    if(page_ctrl.hasClass('prev_page')){
      if(current_page!=1){
        current_page--;
        page_ctrl.parent('.page_ctrl').html('');
        page_even();
      }
    }
    else if(page_ctrl.hasClass('next_page')){
      if(current_page!=total_page){
        current_page++;
        page_ctrl.parent('.page_ctrl').html('');
        page_even();
      }
    }
    else if(page_ctrl.hasClass('page_num')&& !page_ctrl.hasClass('current_page')){
      current_page=parseInt(page_ctrl.html());
      page_ctrl.parent('.page_ctrl').html('');
      page_even();
    }
    else if(page_ctrl.hasClass('to_page_num')){
      current_page=parseInt(page_ctrl.siblings('.input_page_num').val());
      page_ctrl.parent('.page_ctrl').html('');
      page_even();
    }
  });
}
