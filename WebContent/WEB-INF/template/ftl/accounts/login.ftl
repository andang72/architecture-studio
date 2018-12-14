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
	<!-- Bootstrap core CSS -->
   	<link href="<@spring.url "/css/bootstrap/4.1.3/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
   	
	<!-- Professional Kendo UI --> 	 
	<link href="<@spring.url "/css/bootstrap.theme/unify-bootstrap-v4/all.css"/>" rel="stylesheet" type="text/css" />	
 	<link href="<@spring.url "/css/kendo/2018.3.1017/kendo.bootstrap.mobile.min.css"/>" rel="stylesheet" type="text/css" />	
 	
	<!-- Fonts & Icons CSS -->
	<link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />		
	<link href="<@spring.url "/css/community.ui/community.ui.icons.min.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/animate/animate.min.css"/>" rel="stylesheet" type="text/css" />		
	<!-- CSS Bootstrap Theme Unify -->		    
    <link href="<@spring.url "/assets/vendor/icon-hs/style.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/assets/vendor/hs-megamenu/src/hs.megamenu.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/assets/vendor/hamburgers/hamburgers.min.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/assets/vendor/icon-line/css/simple-line-icons.css"/>" rel="stylesheet" type="text/css" />			 
	<link href="<@spring.url "/assets/vendor/icon-line-pro/style.css"/>" rel="stylesheet" type="text/css" />
	
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/unify-core.css"/>">
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/unify-components.css"/>">
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/unify-globals.css"/>"> 
	
	<link rel="stylesheet" href="<@spring.url "/css/bootstrap.theme/unify/custom.css"/>">
		
	<!-- Page landing js -->	   	
	<link rel="stylesheet" href="<@spring.url "/css/pace/pace-theme-flash.css"/>">
	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js"/>'></script>   	
	
	<!-- Requirejs for js loading -->
	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>
	<!-- Application JavaScript
    		================================================== -->    
	<script>
	require.config({
		shim : {
			<!-- Bootstrap -->
			"jquery.cookie" 			: { "deps" :['jquery'] },
	        "bootstrap" 				: { "deps" :['jquery'] },
			<!-- Professional Kendo UI -->
			"kendo.web.min" 			: { "deps" :['jquery'] },
	        "kendo.culture.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	   
	        "kendo.messages.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	  
			<!-- community -- >
	        "community.ui.core"			: { "deps" :['jquery', 'kendo.web.min', 'kendo.culture.min' ] },
	        "community.data" 			: { "deps" :['jquery', 'kendo.web.min', 'community.ui.core' ] }
	    },
		paths : {
			"jquery"    				: "/js/jquery/jquery-3.1.1.min",
			"jquery.cookie"    			: "/js/jquery.cookie/1.4.1/jquery.cookie",
			"bootstrap" 				: "/js/bootstrap/4.1.3/bootstrap.bundle.min",
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "/js/kendo/2018.3.1017/kendo.web.min",
			"kendo.culture.min"			: "/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min",	
			"kendo.messages.min"		: "/js/kendo.extension/kendo.messages.ko-KR",	
			<!-- community -- >
			"community.ui.core" 		: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data",   
		}
	});	
	
	require([ "jquery", "bootstrap", "community.data", "kendo.messages.min"], function($, kendo ) {			
	
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
			errorTemplate: "<p class='text-danger g-font-size-14'><i class='fa fa-info-circle'></i> #=message#</p>"
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
							$("#signin-status").html('입력하신 아이디/메일주소 또는 비밀번호가 잘못되었습니다.');									
							$("#signin-status").fadeIn();									
							$("input[type='password']").val("").focus();				
						} else { 
							$("#signin-status").html("");    
							var returnUrl = response.data.returnUrl
							if( returnUrl != null && returnUrl.length > 0 ){
								location.href= returnUrl ;
							}else{
								location.href="<@spring.url "/"/>" ;
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
		$("section:first").prepend(template(currentUser));			
	}	
	
	</script>	
	<style>
 
		.popover {
			display: block;
		/*	margin: 80px auto; */
			right: 0;
		/*		border: 0px solid #a94442; */
			background: rgba(55, 58, 71, 0.8);
			color : #fff;
			max-width: 100%;
			height:100%;
			/*border-radius: 6px!important;	*/
		}
		
		.popover > .popover-content {
			margin: 80px auto;
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
			font-weight: 400;
			margin-bottom : 20px;
		}
					
	</style>
</head>
<body class="gray-bg skin-2">

    <!-- Login -->    
    <section class="g-height-100vh d-flex align-items-center g-bg-size-cover g-bg-pos-top-center" 
    	<#if (__page?? && __page.getBooleanProperty( "header.image.random", false) ) >
		style="background-image: url( '<@spring.url "/download/images/" />${ CommunityContextHelper.getCustomQueryService().queryForString("COMMUNITY_CS.SELECT_IMAGE_ID_RANDOMLY" ) }' );"
		<#else>
		style="height: 120%; background-image: url(  /images/bg/endless_streets_by_andreasrocha-d3fhbhg.jpg );"
		</#if>>
      <div class="container g-py-100 g-pos-rel g-z-index-1">
        <div class="row justify-content-center">
          <div class="col-sm-8 col-lg-5">
            <div class="g-bg-white rounded g-py-40 g-px-30">
              <header class="text-center mb-4">
                <h2 class="h2 g-color-black g-font-weight-600">Welcome to ${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "") }</h2>
                <p>
                    서비스 이용하시려면 회원가입이 필요합니다. 아직 아이디가 없으시면 회원가입후 서비스를 이용하세요.
                </p>
              </header>
			  <div id="signin-status" class="alert alert-danger g-font-size-15 rounded-2x no-border" style="display:none;"></div>
			  	  
              <!-- Form -->
              <form class="g-py-15" method="post" action="<@spring.url "/accounts/auth/login_check"/>" name="login-form">
                <div class="mb-4">
                  <input class="form-control g-color-black g-bg-white g-bg-white--focus g-brd-gray-light-v4 g-brd-primary--hover rounded g-py-15 g-px-15 mb-3" 
                  	id="username" name="username" required validationMessage="아이디 또는 이메일 주소를 입력하여 주세요." autofocus
                  	type="text" placeholder="아이디">
                  	<span class="k-invalid-msg g-mt-10" data-for="username"></span>
                </div>

                <div class="g-mb-35">
                  <input class="form-control g-color-black g-bg-white g-bg-white--focus g-brd-gray-light-v4 g-brd-primary--hover rounded g-py-15 g-px-15 mb-3" 
                  	id="password" name="password" required  validationMessage="비밀번호를 입력하여 주세요."
                  	type="password" placeholder="비밀번호" >
                  <span class="k-invalid-msg g-mt-10" data-for="password"></span>	
                  <div class="row justify-content-between">
                    <div class="col align-self-center">
                      <label class="form-check-inline u-check g-color-gray-dark-v5 g-font-size-12 g-pl-25 mb-0">
                        <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" name="remember-me">
                        <div class="u-check-icon-checkbox-v6 g-absolute-centered--y g-left-0">
                          <i class="fa" data-check-icon="&#xf00c"></i>
                        </div>
                        로그인상태유지
                      </label>
                    </div>
                    <!--
                    <div class="col align-self-center text-right">
                      <a class="g-font-size-12" href="#!">Forgot password?</a>
                    </div>
                    -->
                  </div>
                </div>

                <div class="mb-4">
                  <button class="btn btn-md btn-block u-btn-primary rounded g-py-13"  type="submit" >로그인</button>
                </div>
              </form>
              <!-- End Form -->

              <footer class="text-center">
                <p class="g-color-gray-dark-v5 g-font-size-13 mb-0">아직 회원이 아니신가요? <a class="g-font-weight-600" href="join">회원가입</a>
                </p>
              </footer>
            </div>
          </div>
        </div>
      </div>
    </section>
    <!-- End Login -->

    <script type="text/x-kendo-template" id="alert-template">
	<div class="popover pull-right animated zoomIn">
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