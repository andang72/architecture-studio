<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "") } | 회원가입</title>

	<!-- Bootstrap core CSS -->
	<link href="<@spring.url "/css/bootstrap/3.3.7/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />
	<link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
	    
	<!-- Bootstrap Theme CSS -->
	<link href="<@spring.url "/css/bootstrap.theme/inspinia/style.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/bootstrap.theme/inspinia/custom.css"/>" rel="stylesheet" type="text/css" />			

	<link href="<@spring.url "/css/animate/animate.min.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/jquery.icheck/skins/all.css"/>" rel="stylesheet" type="text/css" />
		
	<!-- Community CSS -->
	<link href="<@spring.url "/css/community.ui/community.ui.globals.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/community.ui/community.ui.components.css"/>" rel="stylesheet" type="text/css" />
  	<link href="<@spring.url "/css/community.ui/community.ui.style.css"/>" rel="stylesheet" type="text/css" />	
  		
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
	        "community.data" : { "deps" :['community.ui.core'] },	  
	        "jquery.icheck" : { "deps" :['jquery'] }
	    },
		paths : {
			"jquery"    					: "/js/jquery/jquery-2.2.4.min",
			"bootstrap" 					: "/js/bootstrap/3.3.7/bootstrap.min",
			"kendo.ui.core.min" 			: "/js/kendo.ui.core/kendo.ui.core.min",
			"kendo.culture.ko-KR.min"	: "/js/kendo.ui.core/cultures/kendo.culture.ko-KR.min",
			"community.ui.core" 			: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data",
			"jquery.icheck"              : "/js/jquery.icheck/1.0.2/icheck.min"
		}
	});
	
	require([ "jquery", "kendo.ui.core.min",  "kendo.culture.ko-KR.min", "community.data", "community.ui.core", "bootstrap", "jquery.icheck"], function($, kendo ) {		
		
		$('.i-checks').iCheck({
            checkboxClass: 'icheckbox_flat-blue',
            radioClass: 'iradio_flat-blue',
        });
            
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
			errorTemplate: '<div class="alert alert-danger">#=message#</div>'			
                            
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
    <div class="middle-box loginscreen   animated fadeInDown">
        <div id="register">
            <div>
                <h1 class="logo-name">${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "리플리카") }</h1>
            </div>
            <h3>Register to ${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "리플리카") }</h3>
            <p>회원가입을 위하여 다음 가입정보를 입력하세요.</p>
            <form class="m-t" role="form" id="register-form" name="register-form" method="POST" accept-charset="utf-8" >
                <div class="form-group">
                    <input type="text" class="form-control" name="name" placeholder="이름"  data-bind="enabled: enabled, value:currentUser.name" required data-required-msg="이름을 입력하여 주십시오." >
                </div>               
                <div class="form-group">
                    <input type="email" class="form-control" name="email" placeholder="메일"  data-bind="enabled: enabled, value:currentUser.email" required data-required-msg="메일주소를 입력하여 주십시오." data-email-msg="메일주소 형식이 바르지 않습니다.">
                </div>
                 <div class="form-group">
                    <input type="text" class="form-control" name="name" placeholder="아이디"  data-bind="enabled: enabled, value:currentUser.username" >
                    <span class="help-block m-b-none">아이디를 입력하지 않는 경우 메일 주소를 아이디로 사용하게 됩니다.</span>
                </div>                
                <div class="form-group">
                    <input type="password" class="form-control" name="password" placeholder="비밀번호" data-bind="enabled: enabled, value:currentUser.password" required  data-required-msg="비밀번호를 입력하여 주십시오.">
                </div>
                <div class="form-group">
                        <div class="checkbox i-checks"><label> <input type="checkbox" name="agree" data-bind="enabled: enabled, "checked: agree""  required validationMessage="회원가입을 위하여 동의가 필요합니다." ><i></i>  이용 약관 및 정책 동의 </label>
                        </div>
                        <p class="text-danger k-invalid-msg" data-for="agree" role="alert"></p>
                </div>
                <button type="button" class="btn btn-success block full-width m-b" data-bind="enabled: enabled, click:signup" >회원가입</button>

                <p class="text-muted text-center"><small>이미 회원인가요 ?</small></p>
                <a class="btn btn-sm btn-white btn-block" href="login" data-bind="enabled: enabled">로그인</a>
            </form>
            <p class="m-t"> <small>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "리플리카") }는 spring, bootstrap 등의 오픈소프 기술을 기반으로 개발되었습니다.</small> </p>
        </div>
    </div>
</body>

</html>
</#compress>