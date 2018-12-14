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
	require.config({
		shim : { 
			<!-- Bootstrap -->
			"jquery.cookie" 			: { "deps" :['jquery'] },
	        "bootstrap" 				: { "deps" :['jquery'] },
			<!-- Professional Kendo UI -->
			"kendo.web.min" 			: { "deps" :['jquery'] },
	        "kendo.culture.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	   
	        "kendo.messages.min" 		: { "deps" :['jquery', 'kendo.web.min'] },	  
	        "jquery.slimscroll.min" 	: { "deps" :['jquery'] },
			<!-- community -- >
	        "community.ui.core"			: { "deps" :['jquery', 'kendo.web.min', 'kendo.culture.min' ] },
	        "community.data" 			: { "deps" :['jquery', 'kendo.web.min', 'community.ui.core' ] },
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	  
		},
		paths : {
			"jquery"    				: "<@spring.url "/js/jquery/jquery-3.1.1.min"/>",
			"jquery.cookie"    			: "<@spring.url "/js/jquery.cookie/1.4.1/jquery.cookie"/>",
			"bootstrap" 				: "<@spring.url "/js/bootstrap/4.1.3/bootstrap.bundle.min"/>", 
			<!-- Professional Kendo UI --> 
			"kendo.web.min"	 			: "<@spring.url "/js/kendo/2018.3.1017/kendo.web.min"/>",
			"kendo.culture.min"			: "<@spring.url "/js/kendo/2018.3.1017/cultures/kendo.culture.ko-KR.min"/>",	
			"kendo.messages.min"		: "<@spring.url "/js/kendo.extension/kendo.messages.ko-KR"/>",	
			
			<!-- community -- >
			"community.ui.core" 		: "<@spring.url "/js/community.ui/community.ui.core"/>",
			"community.data" 			: "<@spring.url "/js/community.ui/community.data"/>",   						
			"community.ui.admin" 		: "<@spring.url "/js/community.ui/community.ui.admin"/>", 
			"ace" 						: "<@spring.url "/js/ace/ace"/>", 
			"dropzone"					: "<@spring.url "/js/dropzone/dropzone"/>"
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
			userAvatarSrc : "<@spring.url "/images/no-avatar.png"/>",
			userDisplayName : "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
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
				{ text: "강사", value: "22" }
			],			
			filter : {
				NAME : "",
				OBJECT_TYPE : 0,
				OBJECT_ID : "0"
			},
			find : function (){
				var $this = this, filters = [];
				if( $this.filter.NAME != null && $this.filter.NAME.length > 0 ){
					if( filters.length > 0 ) 
						filters.push({ field: "NAME", operator: "startswith", value: $this.filter.NAME , logic : "AND"});
					else
						filters.push({ field: "NAME", operator: "startswith", value: $this.filter.NAME });	
				}
				if( $this.filter.OBJECT_TYPE != null && $this.filter.OBJECT_TYPE > 0 ){
					if( filters.length > 0 )
						filters.push({ field: "OBJECT_TYPE", operator: "eq", value: $this.filter.OBJECT_TYPE, logic : "AND" });
					else
					    filters.push({ field: "OBJECT_TYPE", operator: "eq", value: $this.filter.OBJECT_TYPE });
				}
				if( $this.filter.OBJECT_ID != null && $this.filter.OBJECT_ID > 0 ){
					if( filters.length > 0 )
						filters.push({ field: "OBJECT_ID", operator: "eq", value: $this.filter.OBJECT_ID , logic : "AND" });
					else
					    filters.push({ field: "OBJECT_ID", operator: "eq", value: $this.filter.OBJECT_ID });
				}								
				community.ui.listview( $('#images-listview') ).dataSource.filter( filters );
			}
		});
		
		community.ui.bind( $('#js-header') , observable );        
		
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	   
	 	
	 	var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		
		
		renderTo.on("click", ".sorting[data-kind=image], a[data-object-type=image]", function(e){			
			var $this = $(this);
			var actionType = $this.data("action");	
			if( actionType == 'sort'){
				if( $this.data('dir') == 'asc' )
					$this.data('dir', 'desc' );
				else if 	( $this.data('dir') == 'desc' )
					$this.data('dir', 'asc' );
				community.ui.listview( $('#images-listview') ).dataSource.sort({ field:$this.data('field'), dir:$this.data('dir') });				
				return false;
			}else if (actionType == 'edit' || actionType == 'create' ){
				var objectId = $this.data("object-id");		
				/*
				var targetObject = new community.model.Image();
				if ( objectId > 0 ) {
					targetObject = community.ui.listview( $('#images-listview') ).dataSource.get( objectId );				
				}
				openImageEditorModal( targetObject );
				*/
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/image-editor" />", { imageId: $this.data("object-id") });	
				return false;
			}else if (actionType == 'delete'){
				var objectId = $this.data("object-id");
				if ( objectId > 0 ) {
					var targetObject = community.ui.listview( $('#images-listview') ).dataSource.get( objectId );		
					community.ui.confirm( "이미지 <span class='text-danger'>" + targetObject.name + "</span> 를 <br/> 삭제하시겠습니까?").done(function(){
		            		community.ui.progress(renderTo, true);
		            		community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/images/" />' + objectId + '/delete.json', {
							contentType : "application/json",
							data : community.ui.stringify({}) ,
							success : function(response){		
								community.ui.listview( $('#images-listview') ).dataSource.read();						
							}
						}).always( function () {
							community.ui.progress(renderTo, false);
						});			            		
		        		});		
				}
			}
			return false;		
		});	 
		
		createImageListView();
		
	});
	
	function createImageListView(){
		console.log("create image listview.");
		var renderTo = $('#images-listview');	
		var listview = community.ui.listview( renderTo , {
			dataSource: community.ui.datasource('<@spring.url "/data/api/mgmt/v1/images/list.json"/>', {
				transport: { 
					read:{
						contentType: "application/json; charset=utf-8"
					},
					parameterMap: function (options, operation){	 
						return community.ui.stringify(options);
					}
				},
				serverFiltering:true,
				serverSorting: true,
				schema: {
					total: "totalCount",
					data:  "items",
					model: community.model.Image
				}
			}),
			dataBound: function() {
				if( this.items().length == 0)
					renderTo.html('<tr class="g-height-50"><td colspan="7" class="align-middle g-font-weight-300 g-color-black text-center">조건에 해당하는 데이터가 없습니다.</td></tr>');
			},
			template: community.ui.template($("#template").html())
		}); 			
		
		community.ui.pager( $("#images-listview-pager"), {
            dataSource: listview.dataSource
        }); 	
	}
		
	function openImageEditorModal (data){ 
		var renderTo = $('#image-editor-modal');
		if( !renderTo.data("model") ){
		
			var featuresTo = $('#image-editor-modal .modal-content');
			var observable = new community.ui.observable({
				isNew : false,		
				editable : false,	
				image : new community.model.Image(),
				imageThumbnailUrl : null,
				imageLink : null,
				setSource : function(data){
					var $this = this;
					data.copy( $this.image ); 
					$this.set('imageLink', null);
					if(  $this.image.imageId > 0 ){
						$this.set('isNew', false );
						$this.set('editable' , true);
						$this.set('imageThumbnailUrl' , community.data.getImageUrl(data, {thumbnail:false}) );
						//renderTo.find("#image-thumbnail").css('background-image', 'url(' + $this.get('imageThumbnailUrl') +  ')' );
					}else{
						$this.set('isNew', true ); 
						$this.set('editable' , false);
						$this.set('imageThumbnailUrl' , "/images/no-image.jpg");
					}	
				},
				getImageLink : function(){
					var $this = this;
					if( $this.image.imageId > 0 ){
						community.ui.progress(featuresTo, true);
						community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/images/" />' + $this.image.imageId + '/link.json?create=true', {
							data: community.ui.stringify($this.menu),
							contentType : "application/json",
							success : function(response){
								$this.set('imageLink', response.linkId );
							}
						}).always( function () {
							community.ui.progress(featuresTo, false);
						});	
					}	
					return false;
				}
			});
			renderTo.data("model", observable );	
			community.ui.bind( renderTo, observable );	
			createImageDropzone(observable);
			
		}
		renderTo.data("model").setSource(data);
		renderTo.modal('show');			
	}
	

	function createImageDropzone( observable, renderTo ){	
		renderTo = renderTo || $('#image-file-dropzone');	
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
			community.ui.listview( $('#images-listview') ).dataSource.read();
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
	<#include "includes/admin-header-v2.ftl">
	<!-- End Header -->
	
	<section class="container-fluid px-0 g-pt-65">	
	<div class="row no-gutters g-pos-rel g-overflow-x-hidden">
		<!-- Sidebar Nav -->
		<#include "includes/admin-sidebar-v2.ftl">
		<!-- End Sidebar Nav -->		
		<div class="col g-ml-45 g-ml-0--lg g-pb-65--md">
			<!-- Breadcrumb-v1 -->
			<div class="g-hidden-sm-down g-bg-gray-light-v8 g-pa-20">
				<ul class="u-list-inline g-color-gray-dark-v6">
					<li class="list-inline-item g-mr-10">
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">리소스</a> <i class="hs-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
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
					<div class="row text-center">
						<div class="col-6 text-left">
							<p class="text-danger g-font-weight-100">등록된 이미지 파일들을 관리합니다.</p>
						</div>
						<div class="col-6 text-right">
							<a href="#!" class="btn btn-xl u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10" data-action="create" data-object-type="image" data-object-id="0">이미지 업로드</a>
						</div>
					</div>				
					
					<!-- Search -->
					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">						
						<div class="media flex-wrap g-mb-30">
			              <div class="d-flex align-self-center align-items-center"> 
			               <input data-role="dropdownlist"
						                   data-auto-bind="false"
						                   data-value-primitive="true"
						                   data-text-field="text"
						                   data-value-field="value"
						                   data-bind="value:filter.OBJECT_TYPE, source: objectTypes"
						                   style="width: 150px" />  
			              </div>
			
			              <div class="d-flex align-self-center align-items-center g-ml-10 g-ml-20--md g-ml-40--lg g-mr-20"> 		
			                <input data-role="numerictextbox" placeholder="객체 ID" data-min="-1" data-format="###" data-bind="value:filter.OBJECT_ID" style="width: 100%"/>
			              </div>
			              <div class="d-flex g-hidden-md-up w-100"></div>
			              <div class="media-body align-self-center g-mt-10 g-mt-0--md">
			                <div class="input-group g-pos-rel g-max-width-380 float-right">
			                  <input class="form-control g-font-size-default g-brd-gray-light-v7 g-brd-lightblue-v3--focus g-rounded-20 g-pl-20 g-pr-50 g-py-10" type="text" placeholder="파일" data-bind="value:filter.NAME" >
			                  <button class="btn g-pos-abs g-top-0 g-right-0 g-z-index-2 g-width-60 h-100 g-bg-transparent g-font-size-16 g-color-lightred-v2 g-color-lightblue-v3--hover rounded-0" type="button" data-bind="click:find">
			                    <i class="hs-admin-search g-absolute-centered"></i>
			                  </button>
			                </div>
			              </div>
			            </div>
					</div>					
					<!-- End Search -->
					
					<div class="row">
	                		<div class="table-responsive">
							<table class="table w-100 g-mb-0">
								<thead class="g-hidden-sm-down g-color-gray-dark-v6">
									<tr class="g-height-50">
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15 g-width-100 sorting" data-kind="image" data-action="sort" data-dir="asc" data-field="IMAGE_ID" >
											<div class="media">
												<div class="d-flex align-self-center">ID.</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="hs-admin-angle-up"></i>
													</a>
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="hs-admin-angle-down"></i>
													</a>
													</span>
												</div>
											</div>	
										</th>
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15 sorting" data-kind="image" data-action="sort" data-dir="asc" data-field="FILE_NAME">
			                             	<div class="media">
												<div class="d-flex align-self-center">파일</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="hs-admin-angle-up"></i>
													</a>
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="hs-admin-angle-down"></i>
													</a>
													</span>
												</div>
											</div>	
			                             </th>
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15">크기</th>			                             
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15" width="100">생성자</th>
			                             
										<th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15 g-width-100 sorting" data-kind="image" data-action="sort" data-dir="asc" data-field="CREATION_DATE">
											<div class="media">
												<div class="d-flex align-self-center">생성일</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
														<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
															<i class="hs-admin-angle-up"></i>
														</a>
														<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
															<i class="hs-admin-angle-down"></i>
														</a>
													</span>
												</div>
											</div>
										</th>			                             
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15 g-width-100 sorting" data-kind="image" data-action="sort" data-dir="asc" data-field="MODIFIED_DATE">
											<div class="media">
												<div class="d-flex align-self-center">수정일</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
														<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
															<i class="hs-admin-angle-up"></i>
														</a>
														<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
															<i class="hs-admin-angle-down"></i>
														</a>
													</span>
												</div>
											</div>
										</th> 		
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-brd-bottom-none g-py-15 g-pr-25 g-width-100"></th>								
									</tr>
								</thead>
								<tbody id="images-listview" class="u-listview g-brd-none">
								</tbody>
							</table>
						</div>
						<div id="images-listview-pager" class="g-brd-top-none g-brd-left-none g-brd-right-none" style="width:100%;"></div>
            			</div>
				</div>
				<!-- End Content Body -->
			</div>
			<!-- Footer -->
			<#include "includes/admin-footer.ftl">
			<!-- End Footer -->
		</div>
	</div>
	</section>

	<!-- Image Modal -->
	<div class="modal fade" id="image-editor-modal" tabindex="-1" role="dialog" aria-labelledby="image-editor-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">			
			<div class="modal-content">			
				<!-- .modal-header -->
				<div class="modal-header">
					<h2 class="modal-title">이미지</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button>			       
		      	</div>
			    <!-- /.modal-header -->
			    <!-- .modal-body -->
				<div class="modal-body">
					<div class="g-brd-around g-brd-gray-light-v4 g-pa-30 g-mb-30" >         
					<!-- Image Preview -->       
					<article class="row align-items-center g-mb-30">
		              <div class="col-md-4 g-mb-30 g-mb-0--lg">
		                <figure class="g-pos-rel">
		                  <img class="img-fluid g-rounded-5 g-width-150" data-bind="attr:{src: imageThumbnailUrl }" alt="Image description">
		                </figure>
		              </div>
		              <div class="col-md-8">
		                <div class="g-pa-30--md">
		                		<h3 class="h6 g-color-black g-mb-25" data-bind="text: image.name"></h3>
		                </div>
		              </div>
		            </article>    
		            <!-- End Image Preview -->          			
					<div class="form-inline row" data-bind="invisible: isNew ">
						<div class="form-group col-sm-10">
							<input type="text" class="form-control form-control-sm rounded-0 form-control-md g-width-400" placeholder="이미지 링크" data-bind="value: imageLink">
						</div>
						<button type="button" class="btn btn-md u-btn-primary rounded-0" data-bind="click:getImageLink">링크 생성</button>
					</div>
                    
					<hr class="g-brd-gray-light-v4 g-mx-minus-30"/>			
			
					<div class="alert alert-dismissible fade show g-bg-gray-dark-v2 g-color-white rounded-0" role="alert" data-bind="visible:isNew">
						<button type="button" class="close u-alert-close--light" data-dismiss="alert" aria-label="Close">
							<span class="g-color-white" aria-hidden="true">×</span>
						</button>
						<div class="media">
							<span class="d-flex g-mr-10 g-mt-5"><i class="icon-question g-font-size-25"></i></span>
							<span class="media-body align-self-center">
							웹 페이지와 관련된 이미지를 업로드하는 경우 객체유형 값 14 , 객체 ID 값은 페이지 ID 값으로 입력하여 주세요.
							</span>
						</div>
					</div>

					<div class="row">
						<div class="col">
							<h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-black g-mb-5">객체유형</h3>
							<input data-role="numerictextbox" placeholder="객체유형" data-min="-1" data-max="100"  data-format="###" data-bind="value:image.objectType" style="width: 100%"/>
						</div>
						<div class="col">
							<h3 class="d-flex align-self-center text-uppercase g-font-size-12 g-font-size-default--md g-color-black g-mb-5">객체 ID</h3>
							<input data-role="numerictextbox" placeholder="객체 ID" data-min="-1" data-format="###" data-bind="value:image.objectId" style="width: 100%"/>
						</div>
					</div>
            			</div>	
		            <!-- Advanced File Input -->            
		 			<div class="form-group g-mt-10 g-mb-0">
		 			<form action="" method="post" enctype="multipart/form-data" id="image-file-dropzone" class="u-dropzone u-file-attach-v3 g-mb-15">
						<div class="dz-default dz-message">
							<p><i class="icon-svg icon-svg-dusk-upload"></i></p>
							<h3 class="g-font-size-16 g-color-gray-dark-v2 mb-0">업로드할 이미지 파일은 이곳에 드레그 <span class="g-color-primary">Drag & Drop</span> 하여 놓아주세요.</h3>               				
		                  	<p class="g-font-size-14 g-color-gray-light-v2 mb-0">최대파일 크기는 10MB 입니다.</p>
						</div>       
						<div class="dropzone-previews"></div>                 
						<div class="fallback">
							<input name="file" type="file" multiple style="display:none;"/>
						</div>
					</form> 	
					</div>							                              
					<!-- End Advanced File Input -->
				</div>
		      	<!-- /.modal-body -->		
		      	<div class="modal-footer">
			        <button type="button" class="btn btn-primary"  data-dismiss="modal" >확인</button>
		      	</div><!-- /.modal-footer --> 	
	    		</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /.modal -->		
	<!-- End Image Modal -->		
	
	<script type="text/x-kendo-template" id="template">   
	<tr class="u-listview-item">
		<td class="g-hidden-sm-down g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-pl-25">
		#: imageId #
		</td>
		<td class="g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-px-5 g-px-10--sm">
			<div class="media g-mb-20">
				<div class="d-flex">
					<!-- Figure Image -->
					<div class="g-width-100 g-width-100--md g-width-100 g-height-100--md g-brd-2 g-brd-transparent g-brd-lightblue-v3--parent-opened g-mr-20--sm">
                          <img class="g-width-100 g-width-100--md g-width-100 g-height-100--md g-brd-2 g-brd-transparent g-brd-lightblue-v3--parent-opened g-mr-20--sm" src="#= community.data.getImageUrl(data, {thumbnail:true}) #"  alt="Image Description">
					</div>
					<!-- Figure Image -->
				</div>
				<div class="media-body">
					<!-- Figure Info -->
					<h5 class="g-font-weight-100 g-mb-0">
					<a class="u-link-v5 g-color-black g-color-lightblue-v3--hover g-color-lightblue-v3--opened g-mr-15" href="\#!" data-action="edit" data-object-type="image" data-object-id="#= imageId #">
					#= name #
					</a>
					</h5> 
					<div class="d-block g-mt-5">
                          <i class="g-color-primary g-font-size-default icon-location-pin"></i>
                          <span class="u-label g-bg-bluegray g-mr-10 g-mb-15">#= objectType #</span>
                          <span class="u-label g-bg-black g-mr-10 g-mb-15">#= objectId #</span>
					</div>
					<!-- End Figure Info -->
				</div>
            </div>
		</td>
		<td class="g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-py-15 g-py-30--md"> 
		#= community.data.bytesToSize(size	) # 
		</td>
			<td class="g-hidden-sm-down g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-py-15 g-py-30--md g-px-5 g-px-10--sm">
			#if( !user.anonymous ){  #
				<div class="media">
	            		<div class="d-flex align-self-center">
	                    <img class="g-width-36 g-height-36 rounded-circle g-mr-15" src="#= community.data.getUserProfileImage(user) #" >
	                </div>
					<div class="media-body align-self-center text-left">#: user.name #</div>
	            </div>
			#}#
		</td>
		<td class="g-hidden-sm-down g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-py-15 g-py-30--md g-px-5 g-px-10--sm"> #: community.data.getFormattedDate( creationDate)  # </td>
		<td class="g-hidden-sm-down g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-py-15 g-py-30--md g-px-5 g-px-10--sm">#: community.data.getFormattedDate( modifiedDate)  #</td>
		<td class="g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-py-15 g-py-30--md g-px-5 g-px-10--sm">
			<div class="d-flex align-items-center g-line-height-1">
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover g-mr-15" href="\#!" data-action="edit" data-object-type="image" data-object-id="#= imageId #">
					<i class="hs-admin-pencil g-font-size-18"></i>
				</a>
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover" href="\#!" data-action="delete" data-object-type="image" data-object-id="#= imageId #">
					<i class="hs-admin-trash g-font-size-18"></i>
				</a>
			</div>
		</td>
	</tr>
	</script>	
</body>
</html>
</#compress>