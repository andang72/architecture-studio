<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">    
    <title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "") } | 로그인</title>	
 	<!-- Kendoui with bootstrap theme CSS -->			 
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.common-bootstrap.core.min.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	 
	
	<!-- Bootstrap core CSS -->
	<link href="<@spring.url "/css/bootstrap/3.3.7/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />
	<link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	

	<!-- Bootstrap Theme CSS -->
	<link href="<@spring.url "/css/bootstrap.theme/inspinia/style.css"/>" rel="stylesheet" type="text/css" />	
 	<link href="<@spring.url "/css/bootstrap.theme/inspinia/custom.css"/>" rel="stylesheet" type="text/css" />	
		
	<!-- Community CSS -->
	<link href="<@spring.url "/css/community.ui/community.ui.globals.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/community.ui/community.ui.components.css"/>" rel="stylesheet" type="text/css" />
  	<link href="<@spring.url "/css/community.ui/community.ui.style.css"/>" rel="stylesheet" type="text/css" />	

  	<!-- Depends CSS -->
	<link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet"/>
 			  		
	<!-- Page landing js -->	   	
	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js"/>'></script>  
	<!-- Requirejs for js loading -->
	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>	
	<!-- Application JavaScript
    		================================================== -->    
	<script>
	require.config({
		shim : {
	        "bootstrap" : { "deps" :['jquery'] },
	        "kendo.ui.core.min" : { "deps" :['jquery'] },
	        "kendo.culture.ko-KR.min" : { "deps" :['kendo.ui.core.min'] },
	        "community.ui.core" : { "deps" :['kendo.culture.ko-KR.min'] },
	        "community.data" : { "deps" :['community.ui.core'] }
	    },
		paths : {
			"jquery"    					: "/js/jquery/jquery-2.2.4.min",
			"bootstrap" 					: "/js/bootstrap/3.3.7/bootstrap.min",
			"kendo.ui.core.min" 			: "/js/kendo.ui.core/kendo.ui.core.min",
			"kendo.culture.ko-KR.min"	: "/js/kendo.ui.core/cultures/kendo.culture.ko-KR.min",
			"community.ui.core" 			: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data"
		}
	});	
	
	require([ "jquery", "kendo.ui.core.min",  "kendo.culture.ko-KR.min", "community.data", "community.ui.core", "bootstrap"], function($, kendo ) {			
	
		var setup = community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		if( !e.token.anonymous ){
		  			observable.setUser(e.token);
		  			createAlertBlock(observable.currentUser);
		    		}
		  	}
		});		 
		var observable = new community.ui.observable({ 
			currentUser : new community.model.User(),
			setUser : function( data ){
				var $this = this;
				data.copy($this.currentUser)
			}
		});		
		
		var renderTo = $('form[name=login-form]');
		var validator = community.ui.validator( renderTo, {
			errorTemplate: "<p class='text-danger'>#=message#</p>"
		});
		renderTo.submit(function(e) {
			e.preventDefault();		
			if( validator.validate() ){
				if( $("#signin-status").is(":visible") ){
					$("#signin-status").fadeOut();
				}
				community.ui.progress(renderTo, true);		
				community.ui.ajax("<@spring.url "/accounts/auth/login_check"/>", {
					/*contentType : "application/json",*/
					data: renderTo.serialize(),
					success : function( response ) {   
						if( response.error ){ 
							$("#signin-status").html("입력하신 아이디/메일주소 또는 비밀번호가 잘못되었습니다.");									
							$("#signin-status").fadeIn();									
							$("input[type='password']").val("").focus();				
						} else { 
							$("#signin-status").html("");    
							var returnUrl = response.data.returnUrl
							if( returnUrl != null && returnUrl.length > 0 ){
								location.href= returnUrl ;
							}else{
								location.href="<@spring.url "/display/pages/technical-support.html"/>" ;
							}
						}
					},	
					complete: function(jqXHR, textStatus ){
						community.ui.progress(renderTo, false);		
					}
				});	
			}
		});
		
	});	
	
	function createAlertBlock(currentUser){
		var template = community.ui.template($("#alert-template").html());	
		$('form[name=login-form]').find('fieldset').attr('disabled', 'disabled');
		$(".loginColumns:first").prepend(template(currentUser));			
	}	
	
	</script>	
	<style>
	
		.popover {
			display: block;
			margin: 80px auto;
			right: 0;
			border: 0px solid #a94442;
			background: rgba(55, 58, 71, 0.5);
			color : #fff;
			max-width: 350px;
		    border-radius: 6px!important;	
		}
		
		.popover > .popover-content {
			padding : 15px;
		}
		
		.popover-content > img {
		  border-radius: 80px!important;
		  display: inline-block;
		  height: 80px;
		  margin: -2px 0 0 0;
		  width: 80px;
		}
		
		.popover  p {
			color : #fff;
			font-size:1.4em;
			margin-top : 15px;
			font-weight: 200;
			margin-bottom : 20px;
		}
			
	</style>
</head>
<body class="gray-bg skin-2">
    <div class="loginColumns">
        <div class="row">
            <div class="col-md-6">
                <h2 class="font-bold">Welcome to ${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "") }</h2>
                <p>
                    서비스 이용하시려면 회원가입이 필요합니다. 아직 아이디가 없으시면 회원가입후 서비스를 이용하세요.
                </p>
            </div>
            <div class="col-md-6">
                <div class="ibox-content">
                		<div id="signin-status" class="alert alert-danger rounded-2x no-border" style="display:none;"></div>
                    <form class="m-t" role="form" method="post" action="/accounts/auth/login_check" name="login-form" >
                    	<fieldset>
                        <div class="form-group">
                            <input type="text" id="usrname" name="username"  type="text" class="form-control" placeholder="아이디" required validationMessage="아이디 또는 이메일 주소를 입력하여 주세요." autofocus >
                       		<span class="k-invalid-msg g-mt-10" data-for="usrname"></span>
                        </div>
                        <div class="form-group">
                            <input id="password" name="password" type="password" class="form-control" placeholder="비밀번호" required  validationMessage="비밀번호를 입력하여 주세요.">
                            <span class="k-invalid-msg g-mt-10" data-for="password"></span>
                        </div>
                        <div class="form-group"> 
					        <div class="checkbox">
					          <label>
					            <input type="checkbox" name="remember-me">로그인상태유지
					          </label>
					        </div>
                        </div>                        
                        <button type="submit" class="btn btn-success btn-block m-b ">로그인</button>
                        <a href="#">
                            <small>계정찾기</small>
                        </a>
                        <p class="text-muted text-center">
                            <small>아직 회원이 아니신가요?</small>
                        </p>
                        <a class="btn btn-sm btn-white btn-block" href="join">회원가입</a>
                    </form>
                    <p class="m-t">
                        <small>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "리플리카") } 서비스는 여러 오픈소프 기술을 기반으로 개발되었습니다.</small>
                    </p>
                    </fieldset>
                </div>
            </div>
        </div>
        <hr/>
        <div class="row">
            <div class="col-md-6">
                ${ CommunityContextHelper.getConfigService().getApplicationProperty("website.copyright", "") }
            </div>
            <div class="col-md-6 text-right">
               <small>© 2017 - 2018 </small>
            </div>
        </div>
    </div>
    <script type="text/x-kendo-template" id="alert-template">
	<div class="popover pull-right animated bounceInDown">
		<!--<h3 class="popover-title">로그인 상태입니다.</h3>-->
			<div class="popover-content text-center">		
			<img class="img-rounded" src="#= community.data.getUserProfileImage(data) #">	
			<p>#:name # 님은 로그인 상태입니다. 본인이 아니라면 로그아웃을 클릭하십시오.</p>
			<a href="<@spring.url "/" />" class="btn btn-info btn-flat btn-lg g-font-weight-100">메인으로 이동</a>
			<a href="<@spring.url "/accounts/logout" />" class="m-l-sm btn btn-danger btn-flat btn-lg g-font-weight-100">로그아웃</a>		
		</div>
	</div>
    </script>
</body>	
</html>
</#compress>