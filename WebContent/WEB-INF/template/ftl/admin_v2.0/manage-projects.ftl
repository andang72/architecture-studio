<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>
	
    <!-- Kendoui with bootstrap theme CSS -->			
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.common-bootstrap.core.css"/>" rel="stylesheet" type="text/css" />	
	<link href="<@spring.url "/css/kendo.ui.core/web/kendo.bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
	
	<!-- Bootstrap CSS -->
    <link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />	
    
    <!-- Bootstrap Theme CSS -->
    
    <link href="<@spring.url "/fonts/font-awesome.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/animate/animate.css"/>" rel="stylesheet" type="text/css" />	
    
    <!-- Community Admin CSS -->
    <link href="<@spring.url "/css/community.ui.admin/community-ui-admin-icons.css"/>" rel="stylesheet" type="text/css" />	
    <link href="<@spring.url "/css/community.ui.admin/community.ui.admin.css"/>" rel="stylesheet" type="text/css" />	
  	     
 	<script data-pace-options='{ "ajax": false }' src='<@spring.url "/js/pace/pace.min.js'"/>></script>
 	<script src="<@spring.url "/js/require.js/2.3.5/require.js"/>" type="text/javascript"></script>

 	<!-- Application JavaScript
    		================================================== -->    	
	<script>
	require.config({
		shim : {
			"bootstrap" 					: { "deps" :['jquery', 'popper'] },
			"jquery.cookie" 				: { "deps" :['jquery'] },
	        "kendo.ui.core.min" 			: { "deps" :['jquery'] },
	        "kendo.culture.ko-KR.min" 	: { "deps" :['jquery', 'kendo.ui.core.min'] },
	        "community.ui.core" 			: { "deps" :['jquery', 'kendo.culture.ko-KR.min'] },
	        "community.data" 			: { "deps" :['jquery', 'community.ui.core'] },	 
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] }	   
		},
		paths : {
			"jquery"    					: "/js/jquery/jquery-3.1.1.min",
			"jquery.cookie"    			: "/js/jquery.cookie/1.4.1/jquery.cookie",
			"popper" 	   				: "/js/bootstrap/4.0.0/bootstrap.bundle",
			"bootstrap" 					: "/js/bootstrap/4.0.0/bootstrap.min",
			"kendo.ui.core.min" 			: "/js/kendo.ui.core/kendo.ui.core.min",
			"kendo.culture.ko-KR.min"	: "/js/kendo.ui.core/cultures/kendo.culture.ko-KR.min",
			"community.ui.admin" 		: "/js/community.ui.components/community.ui.admin",
			"community.ui.core" 			: "/js/community.ui/community.ui.core",
			"community.data" 			: "/js/community.ui/community.data"
		}
	});
	require([ "jquery", "popper", "kendo.ui.core.min", "community.ui.core", "community.data", "community.ui.admin"], function($, kendo ) { 
	
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
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
			},
			contractorDataSource : community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/codeset/CONTRACTOR/list.json" />' , {} )
		});
				
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	   

		community.ui.bind( $('#js-header') , observable );       
		var renderTo = $('#features');
		community.ui.bind( renderTo , observable );
		renderTo.data("model", observable );	
		
		observable.contractorDataSource.fetch(function(e){
			createProjectListView();
		});
	 	
		renderTo.on("click", "button[data-object-type=project], .sorting[data-kind=project], a[data-object-type=project]", function(e){			
			var $this = $(this);
			var actionType = $this.data("action");	
			if( actionType == 'sort'){
				if( $this.data('dir') == 'asc' )
					$this.data('dir', 'desc' );
				else if 	( $this.data('dir') == 'desc' )
					$this.data('dir', 'asc' );
				community.ui.listview( $('#project-listview') ).dataSource.sort({ field:$this.data('field'), dir:$this.data('dir') });				
				return false;				
			}else if (actionType == 'view' || actionType == 'create'  || actionType == 'edit'  ){
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/project-editor" />", { projectId: $this.data("object-id") });
				return false;
			}
			
			var objectId = $this.data("object-id");	
			var targetObject = new community.model.Project();
			if ( objectId > 0 ) {
				targetObject = community.ui.listview( $('#project-listview') ).dataSource.get( objectId );				
			}				
 			openProjectEditorModal(targetObject);			
			return false;		
		});	
			 	
	});

	function getContractorName(code){
		var name = "";
		if( code == null )
			return "";
		console.log( code );
		var renderTo = $('#features');
		$.each( renderTo.data("model").contractorDataSource.data(), function( index, value ){
			if( value.code == code )
			{
				name = value.name;
				return ;
			}
		} );
		return name;
	}

	function createProjectListView(){
		var renderTo = $('#project-listview');		
		var listview = community.ui.listview( renderTo , {
			dataSource: community.ui.datasource('<@spring.url "/data/api/mgmt/v1/projects/list.json"/>', {
				transport: { 
					read:{
						contentType: "application/json; charset=utf-8"
					},
					parameterMap: function (options, operation){	 
						return community.ui.stringify(options);
					}
				},
				schema: {
					total: "totalCount",
					data:  "items",
					model: community.model.Project
				},
				pageSize : 15,
				serverPaging : false,
			}),
			template: community.ui.template($("#template").html()),
			dataBound: function() {
				if( this.items().length == 0)
					renderTo.html('<tr class="g-height-50"><td colspan="5" class="align-middle g-font-weight-300 g-color-black text-center">조건에 해당하는 데이터가 없습니다.</td></tr>');
			}
		}); 	
		community.ui.pager( $("#project-listview-pager"), {
            dataSource: listview.dataSource
        });  	
	}
	
		
	function openProjectEditorModal (data){ 
		//console.log( community.ui.stringify(data) );
		var renderTo = $('#project-editor-modal');
		var renderTo2 = $('#project-editor-perms-listview');
		if( !renderTo.data("model") ){
			var observable = new community.ui.observable({ 
				isNew : false,				
				permissionToType : "",  
				permissionToDisabled	: true,					
				enabledSelectRole : false,
				accessControlEntry: new community.model.ObjectAccessControlEntry(),
				project : new community.model.Project(),
				setSource : function (data){
					var $this = this;
					var orgProjectId = $this.project.projectId ;
					data.copy( $this.project ); 
					if(  $this.project.projectId > 0 ){
						$this.set('isNew', false );
						if( $this.project.projectId != orgProjectId ){
							if( community.ui.exists(renderTo2) ){
								community.ui.listview(renderTo2).destroy();	
							}					
							community.ui.listview( renderTo2, {
								dataSource: community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/permissions/19/"/>'+ $this.project.get('projectId') +'/list.json' , {
									schema: {
										total: "totalCount",
										data: "items",
										model: community.model.ObjectAccessControlEntry
									}
								}),
								template: community.ui.template($("#perms-template").html())
							});
						}
					}else{
						$this.set('isNew', true ); 
					}
					$this.resetAccessControlEntry();								
				},
				resetAccessControlEntry : function(e){
					var $this = this;
					$this.set('permissionToType', 'user');
					$this.set('permissionToDisabled' , false);
					$this.set('enabledSelectRole', false);
					$this.accessControlEntry.set('id' , 0);	
					$this.accessControlEntry.set('grantedAuthority' , "USER");					
					$this.accessControlEntry.set('grantedAuthorityOwner' , "");			
					$this.accessControlEntry.set('permission' , "");		
					$this.accessControlEntry.set('domainObjectId' , $this.project.projectId);					
				},
				addPermission : function (e){
					var $this = this;
					if( $this.accessControlEntry.get('grantedAuthorityOwner').length > 0  && $this.accessControlEntry.get('permission').length > 0 ){
						community.ui.progress(renderTo, true);	
						community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/permissions/19/" />' + $this.project.get('projectId') +'/add.json' , {
							data: community.ui.stringify($this.accessControlEntry),
							contentType : "application/json",
							success : function(response){
								community.ui.listview( renderTo2 ).dataSource.read();
							}
						}).always( function () {
							community.ui.progress(renderTo, false);
						});							
						$this.resetAccessControlEntry();
					}
					return false;
				},
				removePermission : function (data) {
					var $this = this;
					community.ui.progress(renderTo, true);	
					community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/permissions/19/" />' + $this.project.get('projectId') +'/remove.json', {
						data:community.ui.stringify(data),
						contentType : "application/json",
						success : function(response){
							community.ui.listview( renderTo2 ).dataSource.read();
						}
					}).always( function () {
						community.ui.progress(renderTo, false);
					});	
					return false;	
				},
				saveOrUpdate : function(e){				
					var $this = this;
					community.ui.progress(renderTo, true);	
					community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/projects/save-or-update.json" />', {
						data: community.ui.stringify($this.project),
						contentType : "application/json",
						success : function(response){
							community.ui.listview( $('#project-listview') ).dataSource.read();
						}
					}).always( function () {
						community.ui.progress(renderTo, false);
						renderTo.modal('hide');
					});						
				},
				rolesDataSource: community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/roles/list.json" />' , {
					schema: {
						total: "totalCount",
						data: "items"
					}
				}),
				permsDataSource: community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/permissions/list.json" />' , {
					schema: {
						total: "totalCount",
						data: "items"
					}
				}),
				contractDataSource : community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/codeset/PROJECT/list.json" />' , {} )
			});
			
						
			observable.bind("change", function(e){						
				if( e.field == "permissionToType" ){
					if( this.get(e.field) == 'anonymous'){
						observable.set('permissionToDisabled', true);
						observable.set('enabledSelectRole', false);
						observable.accessControlEntry.set('grantedAuthority', "USER");
						observable.accessControlEntry.set('grantedAuthorityOwner', "ANONYMOUS");
					}else if (this.get(e.field) == 'role'){
						observable.set('permissionToDisabled', false);
						observable.set('enabledSelectRole', true);						
						observable.accessControlEntry.set('grantedAuthority', "ROLE");
						observable.accessControlEntry.set('grantedAuthorityOwner', "");
					}else{
						observable.set('enabledSelectRole', false);
					 	observable.set('permissionToDisabled', false);	
					 	observable.accessControlEntry.set('grantedAuthority', "USER");
						observable.accessControlEntry.set('grantedAuthorityOwner', "");
					}					
				}
        		});
        		
 			renderTo.on("click", "button[data-subject=permission][data-action=delete], a[data-subject=permission][data-action=delete]", function(e){			
				var $this = $(this);
				var permissionId = $this.data("object-id");
				var data = community.ui.listview( renderTo2 ).dataSource.get(permissionId);	
				observable.removePermission(data);
				return false;		
			});	
			
			renderTo.data("model", observable );	
			community.ui.bind( renderTo, observable );
				
			renderTo.on('show.bs.modal', function (e) {	});
		}
		renderTo.data("model").setSource(data);
		renderTo.modal('show');
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
						<a class="u-link-v5 g-color-gray-dark-v6 g-color-lightblue-v3--hover g-valign-middle" href="#!">커뮤니티</a> <i class="community-admin-angle-right g-font-size-12 g-color-gray-light-v6 g-valign-middle g-ml-10"></i>
					</li>
					<li class="list-inline-item">
						<span class="g-valign-middle">프로젝트</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">프로젝트 관리</h1>
				<!-- Content Body -->
				<div id="features" class="container-fluid">
					<div class="row text-center text-uppercase g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-6 text-left">
						<p class="text-danger g-font-weight-100">이슈관리를 위하여 등록된 프로젝트 정보입니다.</p>
						</div>
						<div class="col-6 text-right">
						<a href="javascript:void();" class="btn btn-xl u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10" data-action="create" data-object-type="project"  data-object-id="0" >새로운 프로젝트 만들기</a>
						</div>
					</div>				
					<div class="row">
	                		<div class="table-responsive">
							<table class="table js-editable-table u-table--v1 u-editable-table--v1 g-color-black g-mb-0">
								<thead class="g-hidden-sm-down g-color-gray-dark-v6">
									<tr class="g-height-50">
										<th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-py-15 g-width-60 sorting" data-kind="project" data-action="sort" data-dir="asc" data-field="projectId" >
											<div class="media">
												<div class="d-flex align-self-center">ID.</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="community-admin-angle-up"></i>
													</a>
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="community-admin-angle-down"></i>
													</a>
													</span>
												</div>
											</div>	
										</th>
										<th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-py-15 g-width-150 sorting" data-kind="project" data-action="sort" data-dir="asc" data-field="contractor" >
											<div class="media">
												<div class="d-flex align-self-center">계약자</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="community-admin-angle-up"></i>
													</a>
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="community-admin-angle-down"></i>
													</a>
													</span>
												</div>
											</div>	
										</th>	   
			                             <th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">프로젝트</th>
			                             <th class="g-bg-gray-light-v8 g-font-weight-400 g-valign-middle g-py-15 g-width-150 sorting" data-kind="project" data-action="sort" data-dir="asc" data-field="maintenanceCost" >
											<div class="media">
												<div class="d-flex align-self-center">비용(월)</div>
												<div class="d-flex align-self-center ml-auto">
													<span class="d-inline-block g-width-10 g-line-height-1 g-font-size-10">
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="community-admin-angle-up"></i>
													</a>
													<a class="g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover" href="#!">
													<i class="community-admin-angle-down"></i>
													</a>
													</span>
												</div>
											</div>	
										</th>
			                             <th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black text-center" width="200">기간</th> 
			                             <th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black text-center" width="100">생성일</th>  
			                             <th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black text-center" width="100">수정일</th>   		
			                             <th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-100">&nbsp;</th>								
									</tr>
								</thead>
								<tbody id="project-listview" class="g-brd-none u-listview"></tbody>
							</table>
						</div>
						<div id="project-listview-pager" class="g-brd-top-0 g-brd-right-0 g-brd-left-0" style="width:100%;"></div>
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
	
	<!-- project editor modal -->
	<div class="modal fade" id="project-editor-modal" tabindex="-1" role="dialog" aria-labelledby="project-editor-modal-labal" aria-hidden="true">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
		      	<div class="modal-header">
		      		<h2 class="modal-title"><span data-bind="text:project.name"></span></h2>
		      		<button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			          	<!--<span aria-hidden="true">&times;</span>-->
			        </button>			        
		      	</div><!-- /.modal-content -->
		      	<div class="modal-body">
		      				        
					<div class="g-brd-around g-brd-gray-light-v7 g-rounded-4 g-pa-15 g-pa-20--md">
	                		<div class="form-group g-mb-10">
	                    		<div class="g-pos-rel">
	                      		<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
		                  			<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
		               			</span>
	                      		<input class="form-control g-brd-gray-light-v7 g-brd-gray-light-v3--focus rounded-0 g-px-14" type="text" placeholder="프로젝트 이름" data-bind="value: project.name" >
	                      		<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">프로젝트 이름을 입력하세요.</small>
	                    		</div>
	                  	</div>
		                 <!-- Textarea Expandable -->
		                 <div class="form-group">
		                    <textarea class="form-control u-textarea-expandable g-brd-gray-light-v7 g-brd-gray-light-v3--focus rounded-0 g-resize-none g-overflow-hidden" rows="3" placeholder="프로젝트 소개  .." data-bind="value: project.summary"></textarea>
		                 </div>
	                  	<!-- End Textarea Expandable -->
	                  	<hr class="g-brd-gray-light-v7 g-mx-minus-20">
		            		<div class="row g-mb-15" >
		            			<div class="col-md-6">
                					<label class="g-mb-10">계약상태</label>		
	                				<div class="form-group u-select--v3 g-pos-rel g-brd-gray-light-v7 g-rounded-4 mb-0">
				                    <input data-role="dropdownlist"
									data-option-label="계약상태를 선택하세요."
									data-auto-bind="true"
									data-text-field="name"
									data-value-field="code"
									data-bind="value: project.contractState, source: contractDataSource"
									style="width: 100%;" />  
			                    </div>
	                			</div>                			
	                			<div class="col-md-6">
	                				<label class="g-mb-10">비용(월)</label>
	                				<div class="form-group u-select--v3 g-pos-rel g-brd-gray-light-v7 g-rounded-4 mb-0">
	                					<input data-role="numerictextbox" data-format="c" data-bind="value: project.maintenanceCost" style="width: 100%;" >
	                				</div>		
	                			</div> 
		            		</div>
		            		<div class="row g-mb-15" >
		            			<div class="col-md-6">
                					<label class="g-mb-10">시작일</label>		
	                				<div class="form-group u-select--v3 g-pos-rel g-brd-gray-light-v7 g-rounded-4 mb-0">
				                		<input data-role="datepicker" data-bind="value: project.startDate" style="width: 100%">    
			                    </div>
	                			</div>                			
	                			<div class="col-md-6">
	                				<label class="g-mb-10">종료일</label>
	                				<div class="form-group u-select--v3 g-pos-rel g-brd-gray-light-v7 g-rounded-4 mb-0">
	                					<input data-role="datepicker" data-bind="value: project.endDate" style="width: 100%">
	                				</div>		
	                			</div> 
		            		</div>				            		
		            	</div>
		      	</div><!-- /.modal-body -->
				<div class="modal-body" data-bind="invisible:isNew"><h4 class="m-t-n">고급설정</h4>		

					<ul class="nav nav-tabs" id="myTab" role="tablist">
					  <li class="nav-item">
					    <a class="nav-link active" id="perms-tab" data-toggle="tab" href="#perms-content" role="tab" aria-controls="perms-content" aria-selected="true">권한설정</a>
					  </li>
					  <li class="nav-item">
					    <a class="nav-link" id="props-tab" data-toggle="tab" href="#props-content" role="tab" aria-controls="props-content" aria-selected="false">속성</a>
					  </li>
					</ul>
					<div class="tab-content" id="myTabContent">
					  <div class="tab-pane fade show active g-pa-10" id="perms-content" role="tabpanel" aria-labelledby="perms-tab">


 					<!-- permission listview -->	
					<div class="table-responsive">
						<table class="table w-100 g-mb-25">
							<thead class="g-hidden-sm-down g-color-gray-dark-v6">
								<tr>
								<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">유형</th>
								<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">대상</th>
								<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">권한</th>
								<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black">&nbsp;</th>
								</tr>
							</thead>
							<tbody id="project-editor-perms-listview" class="g-font-size-default g-color-black g-brd-0"></tbody>
						</table>
					</div>
					<!-- ./permission listview -->	                               
                                
                                	<p>익명사용자, 특정회원 또는 롤에 게시판에 대한 권한을 부여할 수 있습니다. 먼저 권한를 부여할 대상을 선택하세요.</p>
                                 <div class="form-group">
									<div class="col-sm-10">         
										<ul class="list-unstyled">
								          <li>
								              <input type="radio" name="permissionToType" id="permissionToType1" value="anonymous" class="k-radio" data-type="text" data-bind="checked: permissionToType" >
								              <label class="k-radio-label" for="permissionToType1">익명</label>
								          </li>
								          <li>
								              <input type="radio" name="permissionToType" id="permissionToType2" value="user" class="k-radio" data-type="text" data-bind="checked: permissionToType" >
								              <label class="k-radio-label" for="permissionToType2">회원</label>
								          </li>
								          <li>
								              <input type="radio" name="permissionToType" id="permissionToType3" value="role" class="k-radio" data-type="text" data-bind="checked: permissionToType" >
								              <label class="k-radio-label" for="permissionToType3">롤</label>
								          </li>								             
									</div>
                                </div>
								<div class="form-group row">
									<div class="col-sm-6">
										<input data-role="dropdownlist"
										 data-option-label="롤을 선택하세요."
						                 data-auto-bind="false"
						                 data-text-field="name"
						                 data-value-field="name"
						                 data-bind="value: accessControlEntry.grantedAuthorityOwner, source: rolesDataSource, enabled: enabledSelectRole, visible:enabledSelectRole"
						                 style="width: 100%;" />
						               <input type="text" class="form-control" placeholder="권한을 부여할 사용자 아이디(username)을 입력하세요" data-bind="value: accessControlEntry.grantedAuthorityOwner , disabled: permissionToDisabled, invisible:enabledSelectRole">  
									</div>
									<div class="col-sm-6">
									</div>
								</div>
								<div class="form-group row">
									<div class="col-sm-6">
										<input data-role="dropdownlist"
										 data-option-label="권한을 선택하세요."
						                 data-auto-bind="false"
						                 data-text-field="name"
						                 data-value-field="name"
						                 data-bind="value: accessControlEntry.permission, source: permsDataSource"
						                 style="width: 100%;" />
									</div>
								</div>  
								<div class="form-group">            
									<a href="javascript:void();" class="btn u-btn-outline-darkgray g-mr-10 g-mb-15" data-bind="click:addPermission" >권한 추가</a>
								</div>   
													  
					  					  					  
					  </div>
					  <div class="tab-pane fade g-mt-15" id="props-content" role="tabpanel" aria-labelledby="props-tab">
					  <p>속성값을 수정할 수 있습니다.</p>
					  </div>
					</div> 
                    
                        
				</div>	
		      	<div class="modal-footer">
			        <button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
			        <button type="button" class="btn btn-primary" data-bind="{ click: saveOrUpdate }">확인</button>
		      	</div><!-- /.modal-footer -->
	    		</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /.modal -->	
    	<script type="text/x-kendo-template" id="perms-template">    	
	<tr>
		<td class="align-middle text-nowrap">
			#: grantedAuthority #
		</td>
		<td class="align-middle">
			<div class="d-inline-block">
				<span class="d-flex align-items-center justify-content-center u-tags-v1 g-brd-around g-bg-gray-light-v8 g-brd-gray-light-v8 g-font-size-default g-color-gray-dark-v6 g-rounded-50 g-py-4 g-px-15">
					<span class="u-badge-v2--md g-pos-stc g-transform-origin--top-left g-bg-lightblue-v3 g-mr-8"></span>
					#: grantedAuthorityOwner #
				</span>
            </div>		
		</td>
		<td class="align-middle">
			#: permission #
		</td>
		<td class="align-middle text-nowrap text-center">
			<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v3--hover g-text-underline--none--hover g-ml-12" href="\\#!" data-toggle="tooltip" data-placement="top" data-original-title="Delete" data-subject="permission" data-action="delete" data-object-id="#= id #">
			<i class="community-admin-trash"></i>
			</a>
		</td>
	</tr>			                      
    </script> 
    	    	    
    	<script type="text/x-kendo-template" id="template">    	
	<tr class="u-listview-item">
		<td class="g-hidden-sm-down g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-pl-25">#= projectId #</td>
		<td class="g-hidden-sm-down g-valign-middle g-brd-top-none g-brd-bottom g-brd-gray-light-v7 g-pl-25">#= getContractorName( contractor ) #</td>
		<td class="u-text-left">	
		<a class="d-flex align-items-center u-link-v5 u-link-underline g-color-black g-color-lightblue-v3--hover g-color-lightblue-v3--opened" href="\#!" data-action="view" data-object-id="#=projectId#" data-object-type="project">
		<h5 class="g-font-weight-100">
		# if ( new Date() > endDate ) {#  <span class="text-danger"><i class="icon-ban"></i> </span> #} #	
		#= name # 	
		</h5>
		</a>
		<p class="g-font-weight-300 g-color-gray-dark-v6 g-mt-5 g-ml-10 g-mb-0" > 
		# if ( contractState == '002') { # <span class="text-info" >무상</span> # } else if (contractState == '001') { # <span class="text-info"> 유상 </span> # } #
		# if ( new Date() > endDate ) {#  <span class="u-label u-label-danger g-rounded-20 g-mr-10 g-mb-0">계약만료</span> #} #	
		</p>
		</td>
		<td class="text-right align-middle"> #: kendo.toString( maintenanceCost, 'c')  # </td>
		<td class="text-center align-middle"> #: community.data.getFormattedDate( startDate , 'yyyy-MM-dd')  # ~ #: community.data.getFormattedDate( endDate, 'yyyy-MM-dd' )  # </td>
		<td class="text-center align-middle"> #: community.data.getFormattedDate( creationDate )  # </td>
		<td class="text-center align-middle"> #: community.data.getFormattedDate( modifiedDate )  # </td>
		<td class="align-middle">
			<div class="d-flex align-items-center g-line-height-1">
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover g-mr-15" href="\#!" data-action="edit" data-object-type="project" data-object-id="#= projectId #" >
					<i class="community-admin-pencil g-font-size-18"></i>
                </a>
            </div>    
		</td>		
	</tr>				                      
    </script> 	
</body>
</html>
</#compress>