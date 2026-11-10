document.write("<script language=javascript src='../../html/Airtel_FWA/js/project.js' ></script>");
$(function(){

		///////////////////////////////////////////////
		//Top right actions 
		var topActions = "<ul><li class='help'><a href='FAQ.cgi' target='_blank'>Help</a></li>\
		<li id='logout' data-target='logout' data-toggle='modal'>Logout</li>\
		</ul>"
		$('.dashboardStatus').append(topActions); 


		///////////////////////////////////////////////
		//login
		/* 
		if($('#loginAdmin').length > 0)
		{
			$("body").append(loginPopupWindow);
			$("#id_btnLogin").attr("onclick","window.location=\"Home_connectionStatus.cgi\"");
		}
		*/
		
		//logout 
		$("body").append(logoutPopupWindow);
		$('#logout').click(function () {
			$('.logout').modal('show');
		 });
		 $('#logoutBtn').click(function () {
			var url = "/cgi-bin/login.cgi" ;
			
			var data = {
				logoutValue: 1,
			}
			
			var callback = function(responseData, textStatus) {
			if (textStatus == "success") {
					var newPage = document.open("text/html", "replace");
					newPage.write(responseData);
					newPage.close();
				}
			};
			$.post(url, data, callback, "html");
			
		 });
		
		$("body").append(MsgPopupWindow);
		
		///////////////////////////////////////////////
		//Model Name
		//var ModelName = 'Airtel - AOD450';
		$('.titleNameBk , .deviceName').append(document.createTextNode(ModelName));

		document.title = ModelName + document.title;
		var originalTitle = document.title;
		var prependToTitle = function(prefix) {
		document.title = prefix + originalTitle;
		};


		///////////////////////////////////////////////
		//Footer and Link
		//var copyright = "Customer Support : 1800 103 0405";
		if(copyright)
		{
			$('.footerCopyright').append(document.createTextNode(copyright));
			// $('.footerCopyright').click(function(){
			//       var url = "https://www.airtel.in/";
			//       window.open(url, '_blank');
			// });
		}


		///////////////////////////////////////////////
		//Dropdown Menu
		$('.dropdown').click(function () {
			if ($(this).hasClass('disabled')){
				 	$(this).find('.dropdown-menu').hide();
				} else {
					$(this).attr('tabindex', 1).focus();
			        $(this).find('.dropdown-menu').stop().slideToggle(200);
				}    
		 });

		$('.dropdown').focusout(function (){
		       $(this).find('.dropdown-menu').stop().slideUp(200);  
		 });

		$('.dropdown-menu li').click(function () { 
		       $(this).addClass('active');
		       $(this).siblings('li').removeClass();
		});
		$('.dropdown .dropdown-menu li').click(function () {
		        $(this).parents('.dropdown').find('span').text($(this).text());
		       // $(this).parents('.dropdown').find('input').attr('value', $(this).attr('id'));
		    });
		

		///////////////////////////////////////////////
		//mobile menu hamburger button setting
		var hamburger = $('#hamburger-icon');
  		hamburger.click(function() {
        hamburger.toggleClass('active');
        return false;
        });


	
		///////////////////////////////////////////////
		//Mobile menu slide on/ off
		var _toggle=true;
		$(".mobileButton").on("click",function(data){
			if(_toggle){
				$("body").css({position:"fixed"});
				$("body").animate({"left":300+"px"},300);
				$(".dashboardFooter").animate({"left":0+"px"},300);
				$(".mleftMenu, .infomleftMenu").animate({"left":0+"px"},300);
				_toggle=false;
			}else{			
				$("body,.dashboardFooter").animate({"left":0+"px"},300,function(){
					$("body").removeAttr("style");
				});
				$(".mleftMenu, .infomleftMenu").animate({"left":"-"+300+"px"},300);
				_toggle=true;
			}
			return false;
		});

		///////////////////////////////////////////////
		// Mobile style - scroll top button 
		$("body").append('<div class="uparrowheadicon hidden-sm hidden-md hidden-lg"><img src="../../html/Airtel_FWA/img/uparrowhead.svg" /></div>');
		$(window).on('load scroll resize',function(data){
			var showoption = 120;
			if($(window).scrollTop()>showoption){
				$(".uparrowheadicon").fadeIn("normal");
			}else{
				$(".uparrowheadicon").fadeOut("normal");
			}
		})	
		$(".uparrowheadicon").on("click",function(){
			$("html,body").animate({scrollTop:'0'},500);
			return false;
		});



		///////////////////////////////////////////////
		//tooltip
		$('.tooltip').mouseover(function () {
		if ($('.tooltiptext').is(":hidden")) {
			$('.tooltiptext').show();
		} else {
			$('.tooltiptext').hide()
		}
		});
		$('.tooltip').mouseleave(function(){
		$('.tooltiptext').hide();
		});


		///////////////////////////////////////////////
		//info page Main Menu 
		$('.mainMenuInfo').append(mainMenuInfo); 
		///////////////////////////////////////////////
		//info page Main Menu at Mobile style
		$('.infomleftMenu').append(mainMenuInfo); 
		
		// Singlebar Subtitle
		if($('#idDiv_SignalSubtitle').length > 0)
		{
			$('#idDiv_SignalSubtitle').text(SingleSubtitle);
		}
	});


		///////////////////////////////////////////////
		// loading animation 
		var loadingAnimation = '<div class="loadingCircle show">\
								<div class="col-xs-12">\
								<div class="sk-fading-circle">\
								<div class="sk-circle1 sk-circle"></div>\
								<div class="sk-circle2 sk-circle"></div>\
								<div class="sk-circle3 sk-circle"></div>\
								<div class="sk-circle4 sk-circle"></div>\
								<div class="sk-circle5 sk-circle"></div>\
								<div class="sk-circle6 sk-circle"></div>\
								<div class="sk-circle7 sk-circle"></div>\
								<div class="sk-circle8 sk-circle"></div>\
								<div class="sk-circle9 sk-circle"></div>\
								<div class="sk-circle10 sk-circle"></div>\
								<div class="sk-circle11 sk-circle"></div>\
								<div class="sk-circle12 sk-circle"></div>\
								</div>\</div>'		  

		//logout
		var logoutPopupWindow = '<div class="logout modal fade in" role="dialog">\
									<div class="modal-dialog message modal-dialog-centered">\
										<div class="modal-content">\
											<div class="modal-header">\
												<button type="button" class="close" data-dismiss="modal"></button>\
											<h4 class="modal-title">Confirm</h4>\
											</div>\
											<div class="modal-body">\
											<p>Are you sure you want to log out?</p>\
											</div>\
											<div class="modal-footer">\
											<button type="button" class="btn-cancel left" data-dismiss="modal">Cancel</button>\
											<button type="button" class="btn-default" id="logoutBtn">OK</button>\
											</div>\
										</div>\
									</div>\
								</div>'

		// Info Status with not login
		var infoHome = "../../../cgi-bin/infoHome.cgi";
		var infoMobileNetwork = "../../../cgi-bin/infoMobileNetworking_ConnectToCells.cgi";
		var infoAbout = "../../../cgi-bin/infoAbout.cgi";

		var mainMenuInfo = '<ul class="menuList">\
								<li onclick="window.location.href = infoHome"><h2>Home</h2></li>\
								<li onclick="window.location.href = infoMobileNetwork"><h2>Mobile Netowrk</h2></li>\
								<li onclick="window.location.href = infoAbout"><h2>About</h2></li>\
							</ul>'

//login
var loginPopupWindow =
'<div class="loginModal modal fade" role="dialog">\
	<div class="modal-dialog modal-dialog-login modal-dialog-centered">\
		<div class="modal-content">\
			<div class="modal-header">\
				<button type="button" class="close" data-dismiss="modal"></button>\
			</div>\
			<div class="modal-body">\
				<div class="login">\
					<div class="row">\
						<div class="col-md-4 col-xs-12"></div>\
						<div class="col-md-8 col-xs-12 loginTitle">Enter password to login</div>\
					</div>\
					<div class="row">\
						<div class="col-md-4 col-xs-12 leftTitle">Username</div>\
						<div class="col-md-8 col-xs-12 right-content">\
							<input id="id_formUser" type="text" class="login-input txt">\
						</div>\
					</div>\
					<div class="row">\
						<div class="col-md-4 col-xs-12 leftTitle">Password</div>\
						<div class="col-md-8 col-xs-12 right-content">\
							<input id="id_formPassword" type="password" class="login-input txt">\
							<div id="id_loginPW_error" class="tips-error" style="display:none;">Incorrect password</div>\
						</div>\
					</div>\
					<div class="col-12 mt-20">\
						<button type="button" class="btn-default" onclick="btnLogin()">\
							<span>Log in</span>\
						</button>\
					</div>\
				</div>\
			</div>\
		</div>\
		<div class="modal-footer">\
			<!--   <button type="button" class="btn btn-default" data-dismiss="modal">Close</button> -->\
		</div>\
	</div>\
</div>'

/*
function btnLogin()
{
	var sid = $('#id_SID_Reference').val();
	var url = "/cgi-bin/Account.cgi" ;
			
	if($('#id_formUser').val().length <= 0)
	{
		return ;
	}
			
	if($('#id_formPassword').val().length < 4)
	{
		return ;
	}
	account=$('#id_formUser').val();
	passwd = hex_md5($('#id_formPassword').val()+":"+sid);
	var aurl = window.location.href;
	var index = aurl.lastIndexOf("\/");
	uStr = aurl.substring(index + 1,aurl.length);
	//alert("account = "+account);
	//alert("hiddenPasswd = "+passwd);
	//alert("url = "+window.location.pathname);

	var data = {
		submitValue: 2,
		LoginAccountValue: account,
		LoginPasswordValue: passwd,
		LoginSidValue : sid,
		AURL : uStr,
	}

	var callback = function(responseData, textStatus) {
		
		if (textStatus == "success") {
			//console.log("out:["+responseText+"]");
			if (responseText.indexOf("ACCOUNT_FAIL") == -1)
			{
				var newPage = document.open("text/html", "replace");
				newPage.write(responseData);
				newPage.close();
			}
			else
			{
				$('#id_formUser').val("");
				$('#id_formPassword').val("");
				$('#id_loginPW_error').show();
			}
		}
		else
		{
			$('#id_formUser').val("");
			$('#id_formPassword').val("");
		}
	};
	//$.post(url, data, callback, "html");
	$("#fakeBlock").load(url, data, callback);
}
*/ 

var MsgPopupWindow=' \
<div id="id_PMBox_H" class="modal fade" role="dialog"> \
	<div class="modal-dialog message modal-dialog-centered">\
		<div class="modal-content">\
			<div class="modal-header">\
				<button type="button" class="close" data-dismiss="modal"></button>\
				<h4 id="id_PMBox_Title" class="modal-title">Confirm</h4>\
			</div>\
			<div class="modal-body">\
				<p id="id_PMBox_Body" >This will be delete. Continue?</p>\
			</div>\
			<div class="modal-footer">\
				<button type="button" id="id_PMBox_Btn1" class="btn-cancel left" >Cancel</button>\
				<button type="button" id="id_PMBox_Btn2" class="btn-default" >OK</button>\
			</div>\
		</div>\
	</div>\
</div>' ;

function POP_MsgBoxClose()
{
	var MessageBox=$('#id_PMBox_H'); 
	if(MessageBox.length > 0){ 
		MessageBox.modal('hide');
	}
} 

// ex: POP_MsgBox("Please select update file !!","showA()");
function POP_MsgBox(msg,fun) 
{
	var MessageBox=$('#id_PMBox_H'); 
	var Body=$('#id_PMBox_Body');
	var btn_1=$('#id_PMBox_Btn1');
	var btn_2=$('#id_PMBox_Btn2');
	
	if(MessageBox.length > 0){ 
		MessageBox.modal('show');
		Body.text(msg);
		
		var clickFun="POP_MsgBoxClose();";
		if(fun)
		{
			btn_1.show();
			btn_1.text("Cancel");
			btn_1.attr("onclick",clickFun);
			btn_2.show();
			btn_2.text("OK");
			clickFun=clickFun+fun+";";
			btn_2.attr("onclick",clickFun);
		}
		else
		{
			btn_1.show();
			btn_1.text("OK");
			btn_1.attr("onclick",clickFun);
			btn_2.hide();
		}
	}
	else
	{
		alert(msg);
	}
}


function TITEL_SignalShow()
{
	if ($('#idDiv_SignalArea').length > 0)
	{
		if(($('#InSignal_Title').length > 0) && ($('#InSignal_Title').val() != ""))
		{
			$('#idDiv_SignalArea').show();
			if ($('#idDiv_SignalTitle').length > 0)
			{
				$('#idDiv_SignalTitle').text($('#InSignal_Title').val());
			}
				
			if ($('#idDiv_SignalBar').length > 0)
			{
				$('#idDiv_SignalBar').removeClass('none');
				$('#idDiv_SignalBar').removeClass('bad');
				$('#idDiv_SignalBar').removeClass('ok');
				$('#idDiv_SignalBar').removeClass('good');
						
				if($('#InSignal_Status').val() == "good")
				{
					$('#idDiv_SignalBar').addClass('good');
				}
				else if($('#InSignal_Status').val() == "ok")
				{
					$('#idDiv_SignalBar').addClass('ok');
				}
				else if($('#InSignal_Status').val() == "bad")
				{
					$('#idDiv_SignalBar').addClass('bad');
				}
				else //if($('#InSignal_Status').val() == "none")
				{
					$('#idDiv_SignalBar').addClass('none');
				}
					
			}
		}
		else
		{
			$('#idDiv_SignalArea').hide();
		}
	}
}

// Zyxel NR7002 Enterprise 5G Live Hook & Cell Lock Engine
$(function() {
    function pollLiveCellular() {
        $.getJSON('/cgi-bin/cellular_status.cgi', function(data) {
            if (!data || !data.carrier) return;

            // 1. Top Header Signal Widget
            $('#idDiv_SignalArea').show();
            $('#idDiv_SignalTitle').text(data.carrier + ' (' + data.rat + ')');
            if ($('#idDiv_SignalSubtitle').length > 0) {
                $('#idDiv_SignalSubtitle').text(data.band + ' | ' + data.rsrp + ' | SINR: ' + data.sinr);
            }
            var p = parseInt(data.signal_percent) || 0;
            var cls = 'good';
            if (p < 25) cls = 'bad';
            else if (p < 50) cls = 'ok';
            $('#idDiv_SignalBar').removeClass('good ok bad none').addClass(cls);

            // 2. Home Connection Status Page
            if ($('#val_status').length > 0) {
                $('#val_status').html('<span style="color:#00a854; font-weight:bold;"><i class="glyphicon glyphicon-ok-circle"></i> ' + (data.status || 'Connected (5G Live)') + '</span>');
                $('#val_network').text((data.carrier || 'Reliance Jio') + ' (' + (data.band || 'n78') + ')');
                $('#val_plmn').text((data.plmn || '405862') + ' (Jio Infocomm Ltd)');
                if (data.uptime) $('#val_time').text(data.uptime);
                $('#val_service').html('<span style="color:#00a854; font-weight:bold;">Normal Service (5G NR SA)</span>');
                if (data.ipv4) $('#val_wan_ipv4').text(data.ipv4);
                if (data.gateway) $('#val_gateway').text(data.gateway);
                if (data.subnet) $('#val_subnet').text(data.subnet);
                if (data.dns_ipv4) {
                    var dns = data.dns_ipv4.split(',');
                    $('#val_dns1').text(dns[0].trim());
                    if (dns.length > 1 && $('#id_DNSv4_2').length > 0) $('#id_DNSv4_2').text(dns[1].trim());
                }
                if (data.ipv6) $('#val_ipv6').text(data.ipv6);
                if (data.dns_ipv6) {
                    var v6dns = data.dns_ipv6.split(',');
                    $('#val_ipv6_dns1').text(v6dns[0].trim());
                    if (v6dns.length > 1 && $('#id_DNSv6_2').length > 0) $('#id_DNSv6_2').text(v6dns[1].trim());
                }
                if (data.lan_ip) $('#val_lan_ip').text(data.lan_ip);
            }

            // 3. About Page
            if ($('#val_about_model').length > 0) {
                if (data.model) $('#val_about_model').text(data.model);
                if (data.serial) $('#val_about_sn').text(data.serial);
                if (data.imei) $('#val_about_imei').text(data.imei);
                if (data.imsi) $('#val_about_imsi').text(data.imsi);
                if (data.iccid) $('#val_about_iccid').text(data.iccid);
                if (data.imsi && $('#val_sim_imsi').length > 0) $('#val_sim_imsi').text(data.imsi);
                if (data.iccid && $('#val_sim_iccid').length > 0) $('#val_sim_iccid').text(data.iccid);
            }

            // 4. Mobile Networking Connect to Cells Page
            if ($('#idTD_5G_Network').length > 0) {
                $('#idTD_5G_Cell').text('PCell (Primary)');
                $('#idTD_5G_Network').text(data.carrier);
                $('#idTD_5G_DIC_NCI').text('PLMN ' + data.plmn);
                $('#idTD_5G_PCI').text(data.pci || '464');
                $('#idP_Band5G').text(data.band);
                $('#idP_Bandwidth5G').text('100 MHz');
                $('#idTD_5G_EARFCN').text(data.arfcn || '627264');
                $('#idP_5G_RSRP').text(data.rsrp);
                $('#idP_5G_RSRQ').text(data.rsrq);
                $('#idP_5G_SINR').text(data.sinr);
                $('#idTD_5G_Signal').html('<span style="color:#00a854; font-weight:bold;">Active / In-Sync</span>');

                // Keep hidden inputs sync'd so native timer doesn't wipe them
                $('#In5G_CELL').val('PCell (Primary)');
                $('#In5G_Network').val(data.carrier);
                $('#In5G_DCI_NCI').val('PLMN ' + data.plmn);
                $('#In5G_PCI').val(data.pci || '464');
                $('#In5G_BAND').val(data.band);
                $('#In5G_BANDWIDTH').val('100 MHz');
                $('#In5G_EARFCN').val(data.arfcn || '627264');
                $('#In5G_RSRP').val((data.rsrp || '-108').replace(/[^0-9\-]/g, ''));
                $('#In5G_RSRQ').val((data.rsrq || '-11').replace(/[^0-9\-]/g, ''));
                $('#In5G_SINR').val((data.sinr || '14').replace(/[^0-9\-]/g, ''));
                $('#In5G_Signal').val('Active / In-Sync');
            }
        });
    }

    // 5. Connect To Cells Lock/Unlock Event Handlers
    $(document).on('click', '#idBtn_LockTower', function() {
        var arfcn = $('#idInput_ARFCN').val() || '627264';
        var pci = $('#idInput_PCI').val() || '464';
        var fb = $('#idDiv_LockFeedback');
        fb.show().css({'background-color': '#e0f2fe', 'color': '#0369a1'}).html('Applying 5G Cell Lock (ARFCN: ' + arfcn + ', PCI: ' + pci + ')...');
        
        $.post('/cgi-bin/cell_lock.cgi', { action: 'lock', arfcn: arfcn, pci: pci }, function(res) {
            fb.css({'background-color': '#dcfce7', 'color': '#15803d'}).html('<i class="glyphicon glyphicon-ok"></i> 5G Cell Lock Applied Successfully! Baseband locked to ARFCN: ' + arfcn + ', PCI: ' + pci);
            setTimeout(pollLiveCellular, 2000);
        }).fail(function() {
            fb.css({'background-color': '#fee2e2', 'color': '#b91c1c'}).html('Failed to execute Cell Lock command.');
        });
    });

    $(document).on('click', '#idBtn_UnlockTower', function() {
        var fb = $('#idDiv_LockFeedback');
        fb.show().css({'background-color': '#e0f2fe', 'color': '#0369a1'}).html('Unlocking Tower... Reverting modem to Auto Selection...');
        
        $.post('/cgi-bin/cell_lock.cgi', { action: 'unlock' }, function(res) {
            fb.css({'background-color': '#dcfce7', 'color': '#15803d'}).html('<i class="glyphicon glyphicon-ok"></i> Cell Lock Cleared! Modem is now in Auto Selection Mode.');
            setTimeout(pollLiveCellular, 2000);
        }).fail(function() {
            fb.css({'background-color': '#fee2e2', 'color': '#b91c1c'}).html('Failed to execute Unlock command.');
        });
    });

    $(document).on('click', '#idBtn_ApplyRAT', function() {
        var rat = $('#idSelect_RAT').val();
        var fb = $('#idDiv_LockFeedback');
        fb.show().css({'background-color': '#e0f2fe', 'color': '#0369a1'}).html('Applying RAT Mode: ' + rat + '...');
        
        $.post('/cgi-bin/cell_lock.cgi', { action: 'rat', rat: rat }, function(res) {
            fb.css({'background-color': '#dcfce7', 'color': '#15803d'}).html('<i class="glyphicon glyphicon-ok"></i> RAT Mode Applied Successfully!');
            setTimeout(pollLiveCellular, 2000);
        }).fail(function() {
            fb.css({'background-color': '#fee2e2', 'color': '#b91c1c'}).html('Failed to set RAT mode.');
        });
    });

    pollLiveCellular();
    setInterval(pollLiveCellular, 10000);
});
