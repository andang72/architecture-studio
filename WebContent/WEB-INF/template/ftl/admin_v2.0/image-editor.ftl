<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>
	<!-- Bootstrap CSS -->
    <link href="<@spring.url "/css/bootstrap/4.1.3/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />
    		
	<!-- Professional Kendo UI --> 	
	<link href="<@spring.url "/css/kendo/2018.3.1017/kendo.bootstrap-v4.min.css"/>" rel="stylesheet" type="text/css" />	
	

    <!-- Bootstrap Theme CSS -->
	<link href="<@spring.url "/fonts/nanumgothic.min.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
    
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/assets/vendor/icon-line-pro/style.css"/>" rel="stylesheet" type="text/css" />
	 
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/vendor/hs-admin-icons/hs-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/bootstrap.theme/unify-admin/unify-admin.css"/>" rel="stylesheet" type="text/css" />	
 
	 	      	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>
 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	var __imageId = <#if RequestParameters.imageId?? >${RequestParameters.imageId}<#else>0</#if>;
	
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
	        "community.data" 			: { "deps" :['jquery', 'kendo.web.min', 'community.ui.core' ] },
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	 
		},
		paths : {
			"jquery"    					: "<@spring.url "/js/jquery/jquery-3.1.1.min"/>",
			"jquery.cookie"    				: "<@spring.url "/js/jquery.cookie/1.4.1/jquery.cookie"/>",
			"bootstrap" 				: "<@spring.url "/js/bootstrap/4.1.3/bootstrap.bundle.min"/>",
			
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "<@spring.url "/js/kendo/2018.3.1017/kendo.web.min"/>",
			"kendo.culture.min"			: "<@spring.url "/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min"/>",	
			"kendo.messages.min"		: "<@spring.url "/js/kendo.extension/kendo.messages.ko-KR"/>",	
			
			<!-- community -- >
			"community.ui.core" 		: "<@spring.url "/js/community.ui/community.ui.core"/>",
			"community.data" 			: "<@spring.url "/js/community.ui/community.data"/>",   						
			"community.ui.admin" 		: "<@spring.url "/js/community.ui/community.ui.admin"/>",
			
			"ace" 						 : "<@spring.url "/js/ace/ace"/>", 
			"dropzone"					 : "<@spring.url "/js/dropzone/dropzone"/>"	
		}
	});
	require([ "jquery", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin", "dropzone"], function($, kendo ) { 
	
		community.ui.setup({
		  	features : {
				accounts: true
		  	},
		  	'features.accounts.authenticate' :function(e){
		  		observable.setUser(e.token);
		  	}
		});
		
		var observable = new community.ui.observable({ 
			currentUser : new community.model.User(),
			userAvatarSrc : "/images/no-avatar.png",
			userDisplayName : "",
			visible : false,
			editable : false,
			isNew : true,
			image : new community.model.Image(), 
			autherAvatarUrl : "/images/no-avatar.png", 
			autherDisplayName : "",
			imageThumbnailUrl :"/images/no-image.jpg", 
			formatedCreationDate : "",
			formatedModifiedDate: "",
			imageLink: "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
				$this.load(__imageId);
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-images" />");
				return false;
			},
			cancle : function(){
				var $this = this;
				if( $this.get('image.imageId') > 0 ){
					$this.set('editable', false );	 
				}else{
					$this.back();
				}
			},
			edit : function(e){
			 	var $this = this;
			 	$this.set('editable', true );
		 	},
		 	saveOrUpdate : function(e){				
				var $this = this;						
			},
			refresh : function(){
				var $this = this;		
				if( $this.get('image.imageId') > 0 )
					$this.load( $this.get('image.imageId')  ); 
				return false;
			},
			objectTypes : [
				{ text: "정의되지 않음", value: "0" },
				{ text: "사용자", value: "1" },
				{ text: "카테고리", value: "4" },
				{ text: "게시글", value: "7" },
				{ text: "덧글", value: "8" },
				{ text: "공지", value: "9" },
				{ text: "페이지", value: "14" },
				{ text: "이슈", value: "18" },
				{ text: "과정", value: "23" },
				{ text: "강사", value: "22" },
				{ text: "교육장", value: "25" }
			],
			setSource : function( data ){
				var $this = this;
				if( data.get('imageId') > 0 ){
					data.copy( $this.image );
					$this.set('editable', false ); 
					$this.set('isNew', false );
					$this.set('autherAvatarUrl', community.data.getUserProfileImage( $this.image.user ) );
					$this.set('autherDisplayName', community.data.getUserDisplayName( $this.image.user ) );		
					$this.set('imageThumbnailUrl' , community.data.getImageUrl($this.image, {thumbnail:false}) );
					createImagePropsGrid($this); 
					$this.getImageLink();
				}else{
					$this.set('editable', true );	
					$this.set('isNew', true ); 
					$this.set('autherAvatarUrl', $this.userAvatarSrc );
					$this.set('autherDisplayName', $this.userDisplayName  ); 
				}
				$this.set('formatedCreationDate' , community.data.getFormattedDate( $this.image.creationDate) );
				$this.set('formatedModifiedDate' , community.data.getFormattedDate( $this.image.modifiedDate) ); 
				if( !$this.get('visible') ) 
					$this.set('visible' , true );
			},
			saveOrUpdate : function(e){				
				var $this = this;
				community.ui.progress(renderTo, true);	
				community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/images/save-or-update.json" />', {
					data: community.ui.stringify($this.image),
					contentType : "application/json",
					success : function(response){ 
						$this.setSource( new community.model.Image( response ) );
					}
				}).always( function () {
					community.ui.progress(renderTo, false); 
				});	
			},	
			getImageLink : function(){
					var $this = this;
					if( $this.image.imageId > 0 ){
						community.ui.progress(renderTo, true);
						community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/images/" />' + $this.image.imageId + '/link.json?create=true', {
							data: community.ui.stringify($this.menu),
							contentType : "application/json",
							success : function(response){
								$this.set('imageLink', '<@spring.url "/download/images/" />' + response.linkId );
							}
						}).always( function () {
							community.ui.progress(renderTo, false);
						});	
					}	
					return false;
			},			
			load : function(objectId){
				var $this = this;		
				if( objectId > 0 ){
					community.ui.progress(renderTo, true);	
					community.ui.ajax('<@spring.url "/data/api/mgmt/v1/images/"/>' + objectId + '/get.json', {
						success: function(data){	
							$this.setSource( new community.model.Image(data) );
						}	
					}).always( function () {
						community.ui.progress(renderTo, false);
					});	
				}else{
					$this.setSource( new community.model.Image() );
				}								
			}, 
		});
		
		community.ui.bind( $('#js-header') , observable );    
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
 
  		var renderTo = $('#features');
		community.ui.bind( renderTo , observable ); 
		createImageDropzone(observable);	
		
		renderTo.on("click", "a[data-kind=properties]", function(e){			
			var $this = $(this);
			var actionType = $this.data("action");	
			console.log("clicked.." + observable.get('image.imageId') + " " + actionType );
			if( actionType == 'refresh'){
				if( observable.get('image.imageId') > 0 )
					community.ui.grid($('#image-props-grid')).dataSource.read();
			}
			return false;
		});
		
	});
	
	
	function createImagePropsGrid( observable ){
		var renderTo = $('#image-props-grid');
		if( !community.ui.exists(renderTo) ){ 
			community.ui.grid(renderTo, { 
				dataSource: {
							transport: { 
								read:    { url:'<@spring.url "/data/api/mgmt/v1/images/"/>' + observable.get('image.imageId') + '/properties/list.json'  , type:'post', contentType : "application/json" },
								create:  { url:'<@spring.url "/data/api/mgmt/v1/images/"/>' + observable.get('image.imageId') + '/properties/update.json', type:'post',  contentType : "application/json" },
								update:  { url:'<@spring.url "/data/api/mgmt/v1/images/"/>' + observable.get('image.imageId') + '/properties/update.json', type:'post',  contentType : "application/json"  },
								destroy: { url:'<@spring.url "/data/api/mgmt/v1/images/"/>' + observable.get('image.imageId') + '/properties/delete.json', type:'post',  contentType : "application/json" },
								parameterMap: function (options, operation){			
									if (operation !== "read" && options.models) {
										return kendo.stringify(options.models);
									} 
								}
							},						
							batch: true, 
							sort: { field: "name", dir: "asc" },
							schema: {
								model: community.model.Property
							}
						},
						columns: [
							{ title: "이름", field: "name", width: 250 },
							{ title: "값",   field: "value", filterable: false, sortable:false },
							{ command:  { name: "destroy", template:'<a class="btn btn-sm u-btn-outline-darkgray  k-delete-button k-grid-delete" href="\\#!" >삭제</a>' },  title: "&nbsp;", width: 80 }
						],
						editable : true,
						scrollable: true,
						filterable: true,
						sortable: true,
						height:500,
						toolbar: kendo.template('<div class="p-sm"><div class="g-color-white"><a href="\\#"class="btn u-btn-darkgray g-mr-5 k-grid-add">속성 추가</a><a href="\\#"class="btn u-btn-darkgray g-mr-5 k-grid-save-changes">저장</a><a href="\\#"class="btn u-btn-darkgray g-mr-5 k-grid-cancel-changes">취소</a><a class="pull-right community-admin-reload u-link-v5 g-font-size-20 g-color-gray-light-v3 g-color-secondary--hover g-mt-7 g-mr-5" data-kind="properties" data-action="refresh"></a></div></div>'),    
						change: function(e) {
						}			
			}); 
		}
	}
	
	function createImageDropzone( observable ){	
		renderTo = $('#image-file-dropzone');	
		console.log( "create dropzone" );
		// image dorpzone
		var myDropzone = new Dropzone("#image-file-dropzone", {
			url: '<@spring.url "/data/api/v1/images/upload_image_and_link.json"/>',
			paramName: 'file',
			maxFilesize: 10,
			previewsContainer: '#image-file-dropzone .dropzone-previews'	,
			previewTemplate: '<div class="dz-preview dz-file-preview"><div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div></div>'
		});
		
		var featuresTo = $('#image-editor-modal .modal-content');
		  		
		myDropzone.on("sending", function(file, xhr, formData) {
			console.log( community.ui.stringify(observable.image) );
			formData.append("objectType", observable.image.objectType);
			formData.append("objectId", observable.image.objectId);
			formData.append("imageId", observable.image.imageId);
		});			
		myDropzone.on("success", function(file, response) {
			file.previewElement.innerHTML = "";
			$.each( response, function( index , item  ) {
		    	observable.image.imageId = item.imageId;
		    	observable.set('image.name', item.filename);
		    	observable.set('isNew', false );
		    	observable.set('imageThumbnailUrl', community.data.getImageUrl(observable.image, {thumbnail:false}) );
			});
			community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/image-editor" />", { imageId: observable.get("image.imageId") });	
		});
		myDropzone.on("maxfilesexceeded", function() {
			console.log( "maxfilesexceeded" );
		});	
		myDropzone.on("addedfile", function(file) {
			community.ui.progress(featuresTo, true);
			console.log( "file added" );
		});		
		myDropzone.on("complete", function() {
			community.ui.progress(featuresTo, false);
		});			
	}
		
	
	</script> 	
</head>
<body class="">
	<!-- Header -->
	<#include "includes/admin-header.ftl">
	<!-- End Header -->
	
	<section class="container-fluid px-0 g-pt-65">	
	<div class="row no-gutters g-pos-rel g-overflow-x-hidden">
		<!-- Sidebar Nav -->
		<#include "includes/admin-sidebar.ftl">
		<!-- End Sidebar Nav -->		
		<div class="col g-ml-45 g-ml-0--lg g-pb-65--md">
			<!-- Breadcrumb-v1 -->
			<div class="g-hidden-sm-down g-bg-gray-light-v8 g-pa-20">
				<ul class="u-list-inline g-color-gray-dark-v6">
					<li class="list-inline-item g-mr-10">
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">리소스</a> <i class="community-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">이미지</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">이미지 관리</h1>
				<!-- Content Body -->
				<div id="features" class="container-fluid">
					
					<div class="row g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-12">
							<div class="media-md align-items-center g-mb-30">
		              			<div class="d-flex g-mb-15 g-mb-0--md">
									<header class="g-mb-10">
						            	<div class="u-heading-v6-2 text-uppercase" >
						              <h2 class="h4 u-heading-v6__title g-font-weight-300" data-bind="text:image.name"></h2>
						            	</div>
						            	<div class="g-pl-90"> 
						            	</div>
						          	</header>		                				
		             	 		</div>	
								<div class="media d-md-flex align-items-center ml-auto">
					                <a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-bind="click:back">
					                  	<i class="community-admin-angle-left g-font-size-18"></i>
					                 	<span class="g-hidden-sm-down g-ml-10">뒤로가기</span>
					                </a>			
					                <a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-bind="click:refresh"  >
					                  	<i class="community-admin-reload g-font-size-18"></i>
					                 	<span class="g-hidden-sm-down g-ml-10">새로고침</span>
					                </a>
								</div>
		            		</div>
	                  	</div> 
					</div>
					
					<!-- Image Editor -->

					<div class="row">
						<div class="col-lg-9 g-mt-20 g-mb-10">
							<section data-bind="invisible:isNew" style="display:none;"> 
							<div class="form-group">
	                    		<label class="g-mb-10 g-font-weight-600">콘텐츠 유형</label>
								<div class="g-pos-rel">
			                      <span class="form-control form-control-md g-brd-none g-brd-bottom g-brd-gray-light-v7 g-brd-gray-light-v3--focus rounded-0 px-0 g-py-10 g-pl-10" data-bind="text:image.contentType" ></span>
			                    </div>
	                  		</div>  
							<div class="form-group">
			                   	<label class="g-mb-10 g-font-weight-600">이름</label>	
			                	<div class="g-pos-rel">
			                	<input id="input-page-name" class="form-control form-control-md g-brd-none g-brd-bottom g-brd-gray-light-v7 g-brd-gray-light-v3--focus rounded-0 px-0 g-py-10 g-pl-10" type="text" placeholder="파일명을 입력하세요" data-bind="value: image.name, enabled:editable">
		                    	</div>
			                </div>	
			                <!-- File Size --> 
			                <div class="form-group g-mb-30">
		                    	<label class="g-mb-10 g-font-weight-600" >크기 (bytes)</label>
			                    <div class="g-pos-rel">
			                    	<span class="form-control form-control-md g-brd-none g-brd-bottom g-brd-gray-light-v7 g-brd-gray-light-v3--focus rounded-0 px-0 g-py-10 g-pl-10" data-bind="text:image.size" data-format="##,#">0</span>
			                    </div>
		                  	</div>			   
			                <!-- End File Size -->	
							<div class="form-group g-mb-30">
			                    <label class="g-mb-10" >이미지 Url</label>
			                    <div class="g-pos-rel">
			                      <button class="btn u-input-btn--v1 g-width-40 g-bg-primary" type="button" data-bind="click:getImageLink">
			                        <i class="community-admin-cloud-down g-absolute-centered g-font-size-16 g-color-white"></i>
			                      </button>
			                      
			                      <input class="form-control form-control-md g-brd-none g-brd-bottom g-brd-gray-light-v7 g-brd-gray-light-v3--focus rounded-0 px-0 g-py-10" type="text" placeholder="이미지 URL" data-bind="value:imageLink">
			                      
			                    </div>
			                    <small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">아이콘을 클릭하면 이미지 링크를 생성할 수 있습니다.</small>
			                  </div>			                
			                </section>
			                
			                <div class="row">
								<div class="col">
									<label class="g-mb-10 g-font-weight-600" >이미지를 소유하는 객체 종류</label>
									<input data-role="dropdownlist"
						                   data-auto-bind="false"
						                   data-value-primitive="true"
						                   data-text-field="text"
						                   data-value-field="value"
						                   data-bind="value: image.objectType,
						                              source: objectTypes,
						                              enabled: editable"
						                   style="width: 100%;"
						            /> 
								</div>
								<div class="col">
									<label class="g-mb-10 g-font-weight-600" >이미지를 소유하는 객체 ID</label>
									<input data-role="numerictextbox" placeholder="객체 ID" data-min="-1" data-format="###" data-bind="value:image.objectId, enabled:editable" style="width: 100%"/>
								</div>
							</div>
							
							<hr/>
			                			                	                  		 			                	                  		 
	                  		<!-- EDITOR START-->	                  		
							<div class="card g-brd-gray-light-v7 g-rounded-3 g-mb-30">
			                  <div class="card-block g-pa-15" >
								<div class="row">
									<div class="col-md-6"> 
										<figure class="g-pos-rel">
										<img class="img-fluid g-rounded-5" data-bind="attr:{src: imageThumbnailUrl }" alt="" src="/images/no-image.jpg">
										</figure> 	
									</div>
									<div class="col-md-6">
										<!-- Dropdown -->	
										<form action="" method="post" enctype="multipart/form-data" id="image-file-dropzone" class="u-dropzone u-file-attach-v3 g-mb-15 dz-clickable">
										<div class="dz-default dz-message">
										<p><i class="icon-svg icon-svg-dusk-upload"></i></p>
										<h3 class="g-font-size-16 g-font-weight-400 g-color-gray-dark-v2 mb-0">업로드할 이미지 파일은 이곳에 드레그 <span class="g-color-primary">Drag &amp; Drop</span> 하여 놓아주세요. 또는 클릭하여 파일을 선택하여 주세요.</h3>
										<p class="g-font-size-14 g-color-gray-light-v2 mb-0">최대파일 크기는 10MB 입니다.</p>
										</div>
										<div class="dropzone-previews"></div>
										</form>	
										<!-- End Dropdown -->
									</div>
								</div>
			                  </div>
			                </div>	 
	                  		<!-- EDITOR END -->

							<!-- Image Properties -->
							<div class="card g-brd-gray-light-v7 g-rounded-3 g-mb-30" data-bind="invisible:isNew" style="display:none;">
			                  <header class="card-header g-brd-bottom-1 g-px-15 g-px-30--sm g-pt-15 g-pt-20--sm g-pb-10 g-pb-15--sm">
			                    <div class="media">
			                      <h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-black g-mr-10 mb-0">이미지 속성</h3> 
			                      <div class="media-body d-flex justify-content-end"> 
			                        <a class="community-admin-reload u-link-v5 g-font-size-20 g-color-gray-light-v3 g-color-secondary--hover g-ml-20" href="#!" data-kind="properties" data-action="refresh" ></a>
			                      </div>
			                    </div>
			                  </header> 
			                  <div class="card-block g-pa-0 g-brd-top-1">
			                  	<div id="image-props-grid" class="g-brd-0"></div>
			                  </div>
			                </div>	                  		
	                  		<!-- End Image Properties -->	                  			                  		
	                  			                  			                  		
						</div>
						<div class="g-brd-left--lg g-brd-gray-light-v4 col-md-3 g-mb-10 g-mb-0--md">
							<section class="g-mb-10 g-mt-20">			
								<div class="media g-mb-20">
			                        <div class="d-flex align-self-center">
			                          <img class="g-width-36 g-height-36 rounded-circle g-mr-15" data-bind="attr:{ src: autherAvatarUrl }" src="/images/no-avatar.png" alt="Image description">
			                        </div>
			                        <div class="media-body align-self-center text-left" data-bind="text:autherDisplayName"></div>
								</div> 
								<p>
								생성일 : <span class="g-color-gray-dark-v4 " data-bind="text: formatedCreationDate"> </span>
								</p>
								<p data-bind="invisible:isNew" >
								수정일 : <span class="g-color-gray-dark-v4" data-bind="text: formatedModifiedDate"> </span>
								</p>	
								<div data-bind="invisible:isNew" style="display:none;">				
								<p class="g-color-primary">파일 이름, 객체 종류, 객체 ID값을 변경하려면 수정을 클릭하세요. <p>		
								<button class="btn u-btn-outline-blue g-mr-10 g-mb-15" type="button" role="button" data-bind="click:edit, invisible:editable">수정</button>
								<button class="btn u-btn-outline-darkgray g-mr-5 g-mb-15" type="button" role="button" data-bind="click:cancle, visible:editable" style="display:none;">최소</button>
								<button class="btn u-btn-outline-blue g-mr-10 g-mb-15" type="button" role="button" data-bind="click:saveOrUpdate, visible:editable" style="display:none;">확인</button>
								</div>
							</section> 	
						</div>		
					</div>			
															
						
					<!-- End Image Editor -->	
				</div>
				<!-- End Content Body -->
			</div>
			<!-- Footer -->
			<#include "includes/admin-footer.ftl">
			<!-- End Footer -->
		</div>
	</div>
	</section>	 	
</body>
</html>
</#compress> 	