<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
     <title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "") } | 로그인</title>	
	<!-- Bootstrap core CSS -->
   	<link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
   	
	<!-- Professional Kendo UI --> 	 
	<link href="<@spring.url "/css/bootstrap.theme/unify-bootstrap-v4/all.css"/>" rel="stylesheet" type="text/css" />	
 	<link href="<@spring.url "/css/kendo/2018.3.911/kendo.bootstrap.mobile.min.css"/>" rel="stylesheet" type="text/css" />	
 	
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
			"bootstrap" 				: "/js/bootstrap/4.0.0/bootstrap.bundle.min",
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "/js/kendo/2018.3.911/kendo.web.min",
			"kendo.culture.min"			: "/js/kendo/2018.3.911/cultures/kendo.culture.ko-KR.min",	
			"kendo.messages.min"		: "/js/kendo.extension/kendo.messages.ko-KR",	
			<!-- community -- >
			"community.ui.core" 		: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data",   
		}
	});	
	
	require([ "jquery", "bootstrap", "community.data", "kendo.messages.min"], function($, kendo ) {	
	
		community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		if( !e.token.anonymous ){
		  			observable.setUser(e.token);
		  			console.log("Hi " +  observable.currentUser.name + "!! you don't have be here." );
		    		}
		  	}
		});	
		
		var renderTo = $('#register');
		
		var validator = $("#register-form").kendoValidator({
			rules : {
				matches: function (input) {
					var matchesPropertyName = input.data("matches");
					if (!matchesPropertyName) return true;
				    	var propertyName = input.prop("kendoBindingTarget").toDestroy[0].bindings.value.path;
				    return (observable.get(matchesPropertyName) === observable.get(propertyName));
				}
			},
			messages : {
				matches: function (input) {
		  			return input.data("matches-msg") || "Does not match";
				}
			},
			errorTemplate: "<p class='text-danger g-font-size-14'><i class='fa fa-info-circle'></i> #=message#</p>"
                            
		}).data("kendoValidator");
		
		var observable = new community.ui.observable({ 
			currentUser : new community.model.User(),
			enabled : true,
			agree : false,
			setUser : function( data ){
				var $this = this;
				data.copy($this.currentUser);
				if(!$this.currentUser.anonymous){
					$this.set('enabled',false);
				}
			},
			signup : function (e){			
				e.preventDefault();		
				console.log("let's signup.");		 
				var $this = this;
				console.log( community.ui.stringify($this.currentUser) );		
				if (validator.validate()) {
					community.ui.progress(renderTo, true);				
					community.ui.ajax( '<@spring.url "/data/accounts/signup-with-user.json" />', {
							data: community.ui.stringify($this.currentUser),
							contentType : "application/json",
							success : function(response){
								if( response.success ){
									// gonguration !!
									location.href="<@spring.url "/accounts/login" />";
								}
							}
					}).always( function () {
						community.ui.progress(renderTo, false);
					});	
				}
			}			
		});		
		
		community.ui.bind(renderTo, observable );
	});	
	</script>
	<style>
	.alert-danger {
	 	margin-top: 15px;
    	margin-bottom: 0px;
    	padding: 5px;
	}
	.text-danger .k-invalid-msg {
		padding-top: 5px;
	}
	</style>
</head>
<body class="gray-bg skin-2">

	<!-- Signup -->
    <section class="g-min-height-100vh g-flex-centered g-bg-img-hero g-bg-pos-top-center" 
    	<#if (__page?? && __page.getBooleanProperty( "header.image.random", false) ) >
		style="background-image: url( '<@spring.url "/download/images/" />${ CommunityContextHelper.getCustomQueryService().queryForString("COMMUNITY_CS.SELECT_IMAGE_ID_RANDOMLY" ) }' );"
		<#else>
		style="height: 120%; background-image: url(  /download/images/ceubBQ91fak0ndHZNtlsMx0FiqDhYev6mbrFsOK9eHwGvnIRpyAKeCKQBxwnb6mk );"
		</#if>>
      <div class="container g-py-50 g-pos-rel g-z-index-1">
        <div class="row justify-content-center u-box-shadow-v24">
          <div class="col-sm-10 col-md-9 col-lg-6">
            <div class="g-bg-white rounded g-py-40 g-px-30">
              <header class="text-center mb-4">
                <h2 class="h2 g-color-black g-font-weight-600">${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "") } 회원가입</h2>
                 <p>회원가입을 위하여 다음 가입정보를 입력하세요.</p>
              </header> 
              <!-- Form -->
              <form class="g-py-15" role="form" id="register-form" name="register-form" method="POST" accept-charset="utf-8" >
                <div class="row">
                  <div class="col-xs-12 col-sm-6 mb-4">
                    <input class="form-control g-color-black g-bg-white g-bg-white--focus g-brd-gray-light-v4 g-brd-primary--hover rounded g-py-15 g-px-15" type="text"
                    	id="name" name="name" placeholder="이름"  data-bind="enabled: enabled, value:currentUser.name" required data-required-msg="이름을 입력하여 주십시오.">
                    <span class="k-invalid-msg g-mt-10" data-for="name"></span>	
                  </div> 
                  <div class="col-xs-12 col-sm-6 mb-4">
					<input class="form-control g-color-black g-bg-white g-bg-white--focus g-brd-gray-light-v4 g-brd-primary--hover rounded g-py-15 g-px-15" type="email" 
						placeholder="메일"  data-bind="enabled: enabled, value:currentUser.email" required data-required-msg="메일주소를 입력하여 주십시오." data-email-msg="메일주소 형식이 바르지 않습니다.">	
                  </div>
                </div>
                <div class="mb-4">
                  <input class="form-control g-color-black g-bg-white g-bg-white--focus g-brd-gray-light-v4 g-brd-primary--hover rounded g-py-15 g-px-15" type="text" 
                  	id="username" name="username" placeholder="아이디"  data-bind="enabled: enabled, value:currentUser.username">
                  <span class="help-block m-b-none g-font-size-13">아이디를 입력하지 않는 경우 메일 주소를 아이디로 사용하게 됩니다.</span>	
                </div>
                <div class="mb-4"> 
                    <input class="form-control g-color-black g-bg-white g-bg-white--focus g-brd-gray-light-v4 g-brd-primary--hover rounded g-py-15 g-px-15" type="password" 
                    	name="password" placeholder="비밀번호" data-bind="enabled: enabled, value:currentUser.password" required  data-required-msg="비밀번호를 입력하여 주십시오."> 
                </div> 
                <div class="mb-4"> 
					<label class="form-check-inline u-check g-color-gray-dark-v5 g-font-size-12 g-pl-25">
                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" name="agree" data-bind="enabled: enabled, "checked: agree""  required validationMessage="회원가입을 위하여 동의가 필요합니다."  >
                      <div class="u-check-icon-checkbox-v6 g-absolute-centered--y g-left-0">
                        <i class="fa g-rounded-2" data-check-icon=""></i>
                      </div>
                     <span class="g-font-size-16"><a href="/display/pages/privacy.html" > 이용약관 및 정책 </a> 동의</span>
                    </label>
                    <p class="text-danger k-invalid-msg" data-for="agree" role="alert"></p>
                </div>
                 
                <div class="row justify-content-between mb-5">
                  <div class="col align-self-center"></div>
                  <div class="col align-self-center text-right">
                    <button class="btn btn-md u-btn-primary rounded g-py-13 g-px-25" type="button" data-bind="enabled: enabled, click:signup" >회원가입</button>
                  </div>
                </div>
              </form>
              <!-- End Form --> 
              <footer class="text-center">
                <p class="g-color-gray-dark-v5 g-font-size-13 mb-0">이미 회원인가요? <a class="g-font-weight-600" href="login">로그인 바로가기</a></p>
              </footer>
            </div>
          </div>
        </div>
      </div>
    </section>
    <!-- End Signup -->
    <div class="u-outer-spaces-helper"></div>
</body>

</html>
</#compress>