<#ftl encoding="UTF-8"/>
<#compress>
<!DOCTYPE html>
<html>
<head>	
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
	<title>${ CommunityContextHelper.getConfigService().getApplicationProperty("website.title", "REPLICANT") } | ADMIN v2.0</title>

	
	<!-- Bootstrap CSS -->
    <link href="<@spring.url "/css/bootstrap/4.0.0/bootstrap.min.css"/>" rel="stylesheet" type="text/css" />
    		
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
	var __apiId = <#if RequestParameters.apiId?? >${RequestParameters.apiId}<#else>0</#if>;
	
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
	        "community.ui.admin" 		: { "deps" :['jquery', 'jquery.cookie', 'community.ui.core', 'community.data'] },
	        "jquery.slimscroll.min"     : { "deps" :['jquery'] } 
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
			"dropzone"					 : "<@spring.url "/js/dropzone/dropzone"/>",
			"ace" 						: "<@spring.url "/js/ace/ace"/>",
			"jquery.slimscroll.min" 	: "<@spring.url "/js/jquery.slimscroll/1.3.8/jquery.slimscroll.min"/>"				
		}
	});
	require([ 
	"jquery", "bootstrap", "community.data", "kendo.messages.min", "community.ui.admin", "dropzone", "ace", "jquery.slimscroll.min" ], function($, kendo ) {
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
			visible : false,
			editable : false,
			isNew : true,
			source: new community.data.model.Api(), 
			formatedCreationDate : "",
			formatedModifiedDate: "",
			setUser : function( data ){
				var $this = this;				
				data.copy($this.currentUser);
				$this.set('userAvatarSrc', community.data.getUserProfileImage( $this.currentUser ) );
				$this.set('userDisplayName', community.data.getUserDisplayName( $this.currentUser ) );
				$this.load(__apiId);
			},
			back : function(){
				var $this = this;
				community.ui.send("<@spring.url "/secure/display/ftl/admin_v2.0/manage-apis_v2" />");
				return false;
			},
			cancle : function(){
				var $this = this;
				if( $this.source.get('apiId') > 0 ){
					$this.set('editable', false );	
					$('#task-grid').attr('disabled', true);
					$('#scm-grid').attr('disabled', true);
				}else{
					$this.back();
				}
			},
			edit : function(e){
			 	var $this = this;
			 	$this.set('editable', true );
			 	if($this.source.apiId > 0 ) {
			 		$('#task-grid').attr('disabled', false);
			 		$('#scm-grid').attr('disabled', false);
			 	}
		 	},
		 	saveOrUpdate : function(e){				
				var $this = this;
				community.ui.progress(renderTo, true);	
				community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/pages/api/save-or-update.json" />', {
					data: community.ui.stringify($this.source),
					contentType : "application/json",
					success : function(response){ 
						$this.setSource( new community.data.model.Api( response.data.item ) );
					}
				}).always( function () {
					community.ui.progress(renderTo, false); 
				});					
			},
			setSource : function( data ){
				var $this = this;		 
				if( data.get('apiId') > 0 ){
					data.copy( $this.source );
					$this.set('editable', false ); 
					$this.set('isNew', false );
					
					createContentTabs($this);
				}else{	
					$this.set('isNew', true ); 
					data.copy( $this.source );
				}
				
				$this.set('formatedCreationDate' , community.data.getFormattedDate( $this.source.creationDate) );
				$this.set('formatedModifiedDate' , community.data.getFormattedDate( $this.source.modifiedDate) ); 
				
				if( $this.get('isNew' )){
					$this.edit();
				} 				
				if( !$this.get('visible') ) 
					$this.set('visible' , true ); 
				return false;			
			},
			openSecurityModal : function(){
				var $this = this;
				openSecurityModal($this);
				return false;
			},
			openPropertyModal : function(){
				var $this = this;
				openPropsModal($this);
				return false;
			},
			openEditorWindow : function(){
				createEditorWindow(this);
			},
			load : function(objectId){
				var $this = this;		
				if( objectId > 0 ){
					community.ui.progress($('#features'), true);	
					community.ui.ajax('<@spring.url "/data/api/mgmt/v1/pages/api/"/>' + objectId + '/get.json', {
						success: function(data){	
							$this.setSource( new community.data.model.Api(data) );
						}	
					}).always( function () {
						community.ui.progress($('#features'), false);
					});	
				}else{
					$this.setSource( new community.data.model.Api() );
				}	 
			},
			contractDataSource : community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/codeset/PROJECT/list.json" />' , {} ),
			contractorDataSource : community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/codeset/CONTRACTOR/list.json" />' , {} ),
			objectTypeDataSource: community.ui.datasource( '<@spring.url "/data/api/v1/objects/type/list.json" />' , {
				schema : {
					model: {
						id: "OBJECT_TYPE"
					}   
				}
			} )
		});
		
		community.ui.bind( $('#js-header') , observable );    
		// initialization of sidebar navigation component
	    community.ui.components.HSSideNav.init('.js-side-nav');
	   	// initialization of HSDropdown component
	    community.ui.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false});	  
 
 		var renderTo = $('#features');
		community.ui.bind( renderTo , observable ); 
		
	}); 

	function createEditorWindow(observable){
		var renderTo = $('#window');
		if( !community.ui.exists( renderTo ) ){   
			 
			var model = kendo.observable({
				source : new community.data.model.Api(),  
				editable : false,
				selectScript : function (){
					var $this = this; 
					observable.set('source.scriptSource' , $this.source.scriptSource );
					$this.set('editable', true);
				},
				setSource : function(data){
					var $this = this;
					data.copy($this.source);
					if( $this.source.scriptSource != null ){
						setResourceContent({ path: '/' + $this.source.scriptSource }, function(response){ 
							renderTo.data("kendoWindow").center().open();
							editor.setValue( response.fileContent);
						});
					}else{
						renderTo.data("kendoWindow").center().open();
					}
				}
			});
			
			renderTo.kendoWindow({
				width: "900px",
				title: "스크립트 에디터",
				visible: false,
				modal: false,
				actions: ["Pin", "Minimize", "Maximize", "Close"],
				open: function(){
					
				},
				close: function(){
					editor.setValue("");
					treeview.select($());
				}
			}); 
			
			community.ui.bind(renderTo, model);
			renderTo.data( "model", model );
			 
			var editor = ace.edit("htmleditor");		
			editor.getSession().setMode("ace/mode/java");
			editor.getSession().setUseWrapMode(true);  
			editor.setReadOnly(true);
			var treeview = $('#treeview').kendoTreeView({
				dataSource: new kendo.data.HierarchicalDataSource({						
					transport: {
						read: {
							url : '<@spring.url "/secure/data/mgmt/resources/SCRIPT/list.json"/>',
							dataType: "json"
						}
					},
					schema: {		
						model: {
							id: "path",
							hasChildren: "directory"
						}
					}	
					}),
					template: kendo.template($("#treeview-template").html()),
					dataTextField: "name",
					change: function(e) {
						var $this = this;
						var selectedCells = $this.select();			
						var filePlaceHolder = $this.dataItem( $this.select() ); 
						if(community.ui.defined( filePlaceHolder )  && !filePlaceHolder.directory){
							setResourceContent(filePlaceHolder, function(response){
								editor.setValue( response.fileContent );
								model.source.scriptSource = filePlaceHolder.path;
							}); 
						}
					}
			}).data("kendoTreeView");
			
			$('#treeview').slimScroll({ height: 200, railOpacity: 0.9 }); 
		}
		renderTo.data("model").setSource(observable.source); 
	}
	
	function setResourceContent( data , handler ){
		community.ui.ajax( "<@spring.url "/secure/data/mgmt/resources/SCRIPT/get.json" />" , {
			data : { path:  data.path},
				success : function(response){
					//editor.setValue( response.fileContent );
					handler( response );
				}
			}
		); 	
	}

	function createContentTabs(observable){ 
		$('#nav-tab a[data-toggle="tab"]').on('show.bs.tab', function (e) {
			var url = $(this).attr("href"); // the remote url for content
			var target = $(url);
			
			console.log(url);
			console.log(target);
			
			var tab = $(this); // this tab 
			if(url === '#nav-props'){
				createPropertiesGrid($(url + ' .grid'), observable);
			}else if (url === '#nav-info'){ 
				//createProjectListView(observable); 
			} 
		});  
		$('#nav-tab a[data-toggle="tab"]:nth-child(1)').tab('show'); 
	}
	
	function createPropertiesGrid(renderTo, observable){ 
		if( !community.ui.exists(renderTo) ){  
			var __prefix = '<@spring.url "/data/api/mgmt/v1/pages/api/"/>' + observable.source.apiId + '/properties/' ;
			community.ui.grid(renderTo, {
				dataSource: {
					transport: { 
						read : 		{ url: __prefix + '/list.json', type:'post', contentType: "application/json; charset=utf-8"},
						create : 	{ url: __prefix + '/update.json', type:'post', contentType: "application/json; charset=utf-8" },
						update : 	{ url: __prefix + 'update.json', type:'post', contentType: "application/json; charset=utf-8" },
						destroy : 	{ url: __prefix + '/delete.json', type:'post', contentType: "application/json; charset=utf-8" },       
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
							return community.ui.stringify(options);
						}
					}, 
					batch: true, 
					schema: {
						model: community.model.Property
					}
				},
				height : 550,
				sortable: true,
				filterable: false,
				pageable: false, 
				editable: "inline",
				columns: [
					{ field: "name", title: "이름", width: 250 , validation: { required: true} },  
					{ field: "value", title: "값" , validation: { required: true} },
					{ command: ["destroy"], title: "&nbsp;", width: "250px"}
				],
				toolbar: kendo.template('<div class="p-sm"><div class="g-color-white"><a href="\\#"class="btn u-btn-darkgray g-mr-5 k-grid-add"><span class="k-icon k-i-plus"></span> 속성 추가</a><a href="\\#"class="btn u-btn-darkgray g-mr-5 k-grid-save-changes"><span class="k-icon k-i-check"></span> 저장</a><a href="\\#"class="btn u-btn-darkgray g-mr-5 k-grid-cancel-changes"><span class="k-icon k-i-cancel"></span> 취소</a><a class="pull-right community-admin-reload u-link-v5 g-font-size-20 g-color-gray-light-v3 g-color-secondary--hover g-mt-7 g-mr-5" data-kind="properties" data-action="refresh"></a></div></div>'),    
				save : function(){
					
				}
			});						
		}		
	}
		
	
	function createFileUpload( observable ){ 
		var renderTo = $('#file-upload');
		if( !community.ui.exists( renderTo ) ){	
			community.ui.upload( renderTo, {
				enabled: true,
		        async: {
		            saveUrl: '<@spring.url "/data/api/v1/attachments/upload.json"/>',
		            autoUpload: true
		        },
		        dropZone: ".dropZoneElement.file",
		        upload: function (e) {								         
		    		e.data = { objectType : 19, objectId : observable.get('project.projectId') };														    								    	 		    	 
		    	},
		        success: function(e){ 
		        	community.ui.listview($('#attachments-listview')).dataSource.read();		
		        }
		    }); 
		    $('.dropZoneElement.file').click(function(e){
		    	renderTo.click();
		    });
		} 	
	}
	
	function nonEditor(container, options) {
		container.text(options.model[options.field]);
	}
	
	function createScmGrid( observable ) {
		var renderTo = $('#scm-grid');	
		if( !community.ui.exists( renderTo ) ){	 
			community.ui.grid(renderTo, {
				dataSource: {
					transport: { 
						read : { url:'<@spring.url "/data/api/mgmt/v1/scm/list.json"/>', type:'post', contentType: "application/json; charset=utf-8"},
						create : { url:'<@spring.url "/data/api/mgmt/v1/scm/save-or-update.json"/>',  type:'post', contentType: "application/json; charset=utf-8"},
						update : { url:'<@spring.url "/data/api/mgmt/v1/scm/save-or-update.json"/>',  type:'post', contentType: "application/json; charset=utf-8"},
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
							options.objectType = 19 ; 
							options.objectId = observable.project.projectId;
							return community.ui.stringify(options);
						}
					},  
					serverPaging: true,
					pageSize: 15,
					schema: {
						total: "totalCount",
						data:  "items",
						model: {
								id: "scmId", 
								fields: { 		 	
									scmId: { type: "number", defaultValue: 0 },	
									objectType: { type: "number", defaultValue: 19 },	
									objectId: { type: "number", defaultValue: 0 },	
									name: { type: "string", defaultValue: null },	
									description: { type: "string", defaultValue: null },	
									url: { type: "string", defaultValue: null },	
									username : { type: "string", defaultValue: null },
									password: { type: "string", defaultValue: null },	
									creationDate:{ type: "date" },			
									modifiedDate:{ type: "date"}
								}
						}
					}
				}, 
				resizable: true,
				sortable: true,
				filterable: false,
				pageable: false, 
				editable: "popup",
				toolbar: ["create"],
				edit: function(e) {
				    $.each( e.container.find("input[data-role=numerictextbox]"), function( index, item ){
				    	if( item.getAttribute("name") === 'scmId' ){
				    		$(item).data("kendoNumericTextBox").enable(false);
				    	}
				    });			
				    if (e.model.isNew()) {
						e.model.set('objectId', observable.project.projectId );
				    }
				 },
				columns: [
					{ field: "scmId", title: "ID", width:75 },
					{ field: "objectType", title: "객체 유형" , width:80, validation: { required: true} },
					{ field: "objectId", title: "객체 ID" , width:80, validation: { required: true} },
					{ field: "name", title: "이름" , width:200, validation: { required: true} },
					{ field: "description", title: "설명" },  
					{ field: "url", title: "URL", width: 100  },
					{ field: "username", title: "User", width: 100  },
					{ field: "password", title: "Password", width: 100  },
					{ command: ["edit", "destroy"], title: "&nbsp;", width: "220"}
				],
				save : function(){ 
				}
			});					
		
		}
	}
		
	function createTaskGrid( observable ) {
		var renderTo = $('#task-grid');	
		if( !community.ui.exists( renderTo ) ){	 
			community.ui.grid(renderTo, {
				dataSource: {
					transport: { 
						read : { url:'<@spring.url "/data/api/mgmt/v1/tasks/list.json"/>', type:'post', contentType: "application/json; charset=utf-8"},
						create : { url:'<@spring.url "/data/api/mgmt/v1/tasks/save-or-update.json"/>',  type:'post', contentType: "application/json; charset=utf-8"},
						update : { url:'<@spring.url "/data/api/mgmt/v1/tasks/save-or-update.json"/>',  type:'post', contentType: "application/json; charset=utf-8"},
						parameterMap: function (options, operation){	 
							if (operation !== "read" && options.models) { 
								return community.ui.stringify(options.models);
							}
							options.objectType = 19 ; 
							options.objectId = observable.project.projectId;
							return community.ui.stringify(options);
						}
					},  
					serverPaging: true,
					pageSize: 15,
					schema: {
						total: "totalCount",
						data:  "items",
						model: {
								id: "taskId", 
								fields: { 		 	
									taskId: { type: "number", defaultValue: 0 },	
									objectType: { type: "number", defaultValue: 19 },	
									objectId: { type: "number", defaultValue: 0 },	
									taskName: { type: "string", defaultValue: null },	
									description: { type: "string", defaultValue: null },	
									version: { type: "string", defaultValue: null },	
									price : { type: "number", defaultValue: 0 },
									startDate:{ type: "date" },			
									endDate:{ type: "date"},
									progress: { type: "string", defaultValue: null },
									creationDate:{ type: "date" },			
									modifiedDate:{ type: "date"}
								}
						}
					}
				}, 
				resizable: true,
				sortable: true,
				filterable: false,
				pageable: false, 
				editable: "popup",
				toolbar: ["create"],
				edit: function(e) {
				    $.each( e.container.find("input[data-role=numerictextbox]"), function( index, item ){
				    	if( item.getAttribute("name") !== 'price' ){
				    		$(item).data("kendoNumericTextBox").enable(false);
				    	}
				    });			
				    if (e.model.isNew()) {
				       	e.model.set('objectId', observable.project.projectId );
				    }
				 },
				columns: [
					{ field: "taskId", title: "ID", width:75 },
					{ field: "objectType", title: "객체 유형" , width:80, validation: { required: true} },
					{ field: "objectId", title: "객체 ID" , width:80, validation: { required: true} },
					{ field: "taskName", title: "이름" , width:200, validation: { required: true} },
					{ field: "version", title: "버전", width: 80  },
					{ field: "price", title: "가격" , format: "{0:c}" , width: 100 },
					{ field: "startDate", title: "시작일" , format: "{0:yyyy.MM.dd}", width: 100},
					{ field: "endDate", title: "종료일", format: "{0:yyyy.MM.dd}" },
					{ field: "progress", title: "진행율", width: 80  },
					{ field: "description", title: "설명"  },
					{ command: ["edit", "destroy"], title: "&nbsp;", width: "220"}
				],
				save : function(){ 
				}
			});					
		
		}
	}
	
	function createAttachmentListView ( observable ){
		var renderTo = $('#attachments-listview');	
		if( !community.ui.exists( renderTo ) ){					
			console.log('create attachment listview');
			var listview = community.ui.listview( renderTo , {
				dataSource: community.ui.datasource('/data/api/v1/attachments/list.json', {
					transport : {
						parameterMap :  function (options, operation){
							return { startIndex: options.skip, pageSize: options.pageSize, objectType : 19 , objectId : observable.project.projectId }
						}
					},
					pageSize: 10,
					schema: {
						total: "totalCount",
						data: "items",
						model : community.model.Attachment
					}
				}),
				template: community.ui.template($("#attachments-template").html()),
			    dataBound : function(e){
					community.ui.tooltip(renderTo);
					if( this.items().length == 0){
						renderTo.html('<tr class="g-height-150"><td colspan="3" class="align-middle g-font-weight-300 g-color-black text-center">첨부파일이 없습니다.</td></tr>');
					}
				}	
			});
			renderTo.removeClass('k-listview');
			renderTo.removeClass('k-widget'); 
			createFileUpload(observable); 
			renderTo.on("click", "a[data-kind=attachment]", function(e){		
				var $this = $(this); 
				if( community.ui.defined(  $this.data("kind") ) &&  $this.data("kind") === 'attachment' ){
					if( confirm("파일을 삭제하시겠습까?") ){
						community.ui.progress(renderTo, true); 
						community.ui.ajax( '<@spring.url "/data/api/v1/attachments/" />' + $this.data("object-id") + '/remove.json', {
							contentType : "application/json",
							data : community.ui.stringify({}) ,
							success : function(response){		
								listview.dataSource.read();				
							}
						}).always( function () {
							community.ui.progress(renderTo, false);
						});			            		
					}		
					return false;
				} 		
			}); 
		}
	}
 
	function openSecurityModal(observable){
		var renderTo = $('#projects-security-modal');
		if( !renderTo.data("model") ){
			console.log('creating permission acl listview.');
			var listview = community.ui.listview( $('#projects-perms-listview'), {
				dataSource : community.ui.datasource( '<@spring.url "/data/api/mgmt/v1/security/permissions/30/"/>'+ observable.source.get('apiId') +'/list.json' , {
					schema: {
						total: "totalCount",
						data: "items",
						model: community.model.ObjectAccessControlEntry
					}
				}),	
				template: community.ui.template($("#perms-template").html()),
				dataBound: function() {
					if( this.items().length == 0)
						$('#projects-perms-listview').html('<tr class="g-height-50"><td colspan="4" class="align-middle g-font-weight-300 g-color-black text-center">조건에 해당하는 데이터가 없습니다.</td></tr>');
				}
			}); 
			
			$('#projects-perms-listview').removeClass('k-widget');
			
			var models = new community.ui.observable({ 	
				permissionToType : "",  
				enabledSelectRole : false,
				permissionToDisabled	: true,	
				enabledSelectRole : false,			
				accessControlEntry: new community.model.ObjectAccessControlEntry(),
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
				addPermission : function (e){
					var $this = this;
					if( $this.accessControlEntry.get('grantedAuthorityOwner').length > 0  && $this.accessControlEntry.get('permission').length > 0 ){
						community.ui.progress(renderTo, true);	
						community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/permissions/30/" />' + observable.source.get('apiId') +'/add.json' , {
							data: community.ui.stringify($this.accessControlEntry),
							contentType : "application/json",
							success : function(response){
								listview.dataSource.read();
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
					community.ui.ajax( '<@spring.url "/data/api/mgmt/v1/security/permissions/30/" />' + observable.source.get('apiId') +'/remove.json', {
						data:community.ui.stringify(data),
						contentType : "application/json",
						success : function(response){
							listview.dataSource.read();
						}
					}).always( function () {
						community.ui.progress(renderTo, false);
					});	
					return false;	
				},
				setSource : function(){
 			
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
					$this.accessControlEntry.set('domainObjectId' , observable.source.apiId);					
				},
			}); 
			models.bind("change", function(e){						
				if( e.field == "permissionToType" ){
					if( this.get(e.field) == 'anonymous'){
						models.set('permissionToDisabled', true);
						models.set('enabledSelectRole', false);
						models.accessControlEntry.set('grantedAuthority', "USER");
						models.accessControlEntry.set('grantedAuthorityOwner', "ANONYMOUS");
					}else if (this.get(e.field) == 'role'){
						models.set('permissionToDisabled', false);
						models.set('enabledSelectRole', true);						
						models.accessControlEntry.set('grantedAuthority', "ROLE");
						models.accessControlEntry.set('grantedAuthorityOwner', "");
					}else{
						models.set('enabledSelectRole', false);
					 	models.set('permissionToDisabled', false);	
					 	models.accessControlEntry.set('grantedAuthority', "USER");
						models.accessControlEntry.set('grantedAuthorityOwner', "");
					}					
				}
        		}); 			
			renderTo.data("model", models );
			community.ui.bind(renderTo, models );
		}
		renderTo.data("model").setSource(observable);
		renderTo.modal('show');
	}			
	</script> 	
	<style>
		.message-panel-frame .modal-content {
			border-radius: 1rem;
		}
		
		.message-panel-frame .modal-header {
			background-color: #3899ec;
			border-top-left-radius: 1rem;
			border-top-right-radius: 1rem;
		}
		
		.message-panel-frame .modal-title {
		    font-weight: 400;
		    font-size: 1.6em;
		    color: #fff;		
		}
		
		
		.fullsize-panel-frame.modal {
		  position: fixed;
		  top: 0;
		  right: 0;
		  bottom: 0;
		  left: 0;
		  overflow: hidden;
		}
		
		.fullsize-panel-frame .modal-dialog {
		  position: fixed;
		  margin: 0;
		  width: 100%;
		  min-width : 100%;
		  height: 100%;
		  padding: 0;
		}
		
		.fullsize-panel-frame .modal-content {
		  position: absolute;
		  top: 0;
		  right: 0;
		  bottom: 0;
		  left: 0;
		  border: 2px solid #eee;
		  border-radius: 0;
		  box-shadow: none;
		}
		
		.fullsize-panel-frame .modal-header {
		  position: absolute;
		  top: 0;
		  right: 0;
		  left: 0;
		  /*
		  height: 50px;
		  padding: 10px;
		  */
		  /*background: #6598d9;*/
		  background-color: #3899ec;
		  border: 0;
		  border-radius : 0 ;
		}
		
		.fullsize-panel-frame .modal-title {
		  font-weight: 300;
		  font-size: 2em;
		  color: #fff;
		  line-height: 30px;
		}
		
		.fullsize-panel-frame .modal-body {
		  position: absolute;
		  top: 50px;
		  bottom: 60px;
		  width: 100%;
		  font-weight: 300;
		  overflow: auto;
		}
		
		.fullsize-panel-frame .modal-footer {
		  position: absolute;
		  right: 0;
		  bottom: 0;
		  left: 0;
		  height: 60px;
		  padding: 10px;
		  background: #f1f3f5;
		}
	#htmleditor {
		min-height:500px; 
		
	}
	
	#window {
		opacity : 1;
	} 
	
	.k-window { 
		border-radius:0px;
	}
		
	</style>
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
						<span class="g-valign-middle">API 서비스</span>
					</li>
				</ul>
			</div>
			<!-- End Breadcrumb-v1 -->
			<div class="g-pa-20">
				<h1 class="g-font-weight-300 g-font-size-28 g-color-black g-mb-30">RESTful API 서비스 관리</h1>
			</div>	
				<!-- Content Body -->
				<div id="features" class="container-fluid" data-bind="visible:visible" style="display:none;" >
					<div class="row g-bord-radias g-brd-gray-dark-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-3">
						<div class="col-12 g-pa-20">
							<div class="media-md align-items-center">
								<div class="d-flex g-mb-15 g-mb-0--md">
									<header class="g-mb-10">
										<div class="u-heading-v6-2 text-uppercase" >
											<h2 class="h4 u-heading-v6__title g-font-weight-300" data-bind="text: source.name"></h2>
										</div>
										<div class="g-pl-90">
											<p data-bind="text: source.title"></p>
										</div>
									</header>
						 		</div>	
								<div class="media d-md-flex align-items-center ml-auto">
									<a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-bind="click:back">
										<i class="hs-admin-angle-left g-font-size-18"></i>
										<span class="g-hidden-sm-down g-ml-10">뒤로가기</span>
									</a>
									<a class="d-flex align-items-center u-link-v5 g-color-lightblue-v3 g-color-primary--hover g-ml-15 g-ml-45--md" href="#!" data-action="refresh" data-object-type="menu" data-object-id="0" data-bind="invisible:isNew" style="display:none;" >
										<i class="hs-admin-reload g-font-size-18"></i>
										<span class="g-hidden-sm-down g-ml-10">새로고침</span>
									</a>
									<button class="btn u-btn-outline-blue g-ml-15 g-ml-45--md" type="button" role="button" data-bind="click:edit, invisible:editable">수정</button>
									<button class="btn u-btn-outline-darkgray g-ml-15 g-ml-45--md" type="button" role="button" data-bind="click:cancle, visible:editable" style="display:none;">최소</button>
									<button class="btn u-btn-outline-blue g-ml-5 g-ml-5--md" type="button" role="button" data-bind="click:saveOrUpdate, visible:editable" style="display:none;">확인</button>
								</div>
							</div>
	                  	</div>					
					</div> 
					<div class="row">
						<div class="media w-100 g-px-25 g-brd-gray-light-v7 g-brd-top-0 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-1" style="background:#f5f5f5;">
							<div class="d-flex align-self-center">
								<div class="media">
									<div class="d-flex align-self-center">
										<img class="g-width-24 g-height-24 rounded-circle g-mr-5" data-bind="attr:{ src: userAvatarSrc }" src="/images/no-avatar.png" alt="Image description">
									</div>
									<div class="media-body align-self-center text-left g-font-weight-300"><span class="g-font-weight-400" data-bind="text:userDisplayName"></span> 계정으로 작업</div>
								</div>
							</div>
							<div class="media-body d-flex align-self-center justify-content-end">
								<a class="d-flex align-items-center u-link-v5 g-parent g-py-15 g-color-gray-dark-v6 g-color-primary--hover g-ml-10 g-ml-30--sm" href="#!" data-bind="click:openSecurityModal, invisible:isNew" >
									<span class="g-font-size-18 g-color-gray-light-v6 g-color-lightred-v3--parent-hover g-color-lightred-v3--parent-active g-mr-10">
										<i class="hs-admin-lock"></i>
									</span>
									<span class="g-hidden-md-down g-ml-5">접근 권한 설정</span>
								</a>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-lg-10 g-mt-20 g-mb-10">
							<div class="form-group g-mb-30">
								<label class="g-mb-10 g-font-weight-600" for="input-api-title">타이틀</label>
								<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                	</span>
		                      		<input id="input-api-title" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="타이틀을 입력하세요" 
		                      			data-bind="value: source.title, enabled:editable" autofocus>
								</div>
	                  		</div> 
							<div class="form-group g-mb-30">
								<label class="g-mb-10 g-font-weight-600" for="input-page-name">이름 <span class="text-danger">*</span></label>
								<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                	</span>
		                      		<input id="input-api-name" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="API 이름을 입력하세요" 
		                      			data-bind="value: source.apiName, enabled:editable" autofocus>
									<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">
									이 페이지를 호출할때 사용되는 이름입니다. ex) /data/apis/<span data-bind="text: source.apiName"></span>
									</small>	
								</div>
	                  		</div> 
							<div class="form-group g-mb-30">
								<label class="g-mb-10 g-font-weight-600" for="input-api-pattern">패턴</label>
								<div class="g-pos-rel">
								<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
								<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
								</span>
								<input id="input-api-pattern" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="패턴을 입력하세요" data-bind="value:source.pattern, enabled:editable">
								<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5">
								패턴을 기반으로 페이지를 호출합니다. 
								ex) /data/apis<span data-bind="text: source.pattern"></span>
								</small>
								</div>
							</div>
							<div class="form-group">
			                   	<label class="g-mb-10 g-font-weight-600" for="input-page-description">설명</label>			
			                    <textarea id="input-api-description" class="form-control form-control-md g-resize-none g-rounded-4" rows="3" 
			                    	placeholder="간략하게 API 에 대한 설명을 입력하세요." data-bind="value:source.description, enabled:editable"></textarea>
							</div>	 

							<div class="row g-mb-15" >
			            		<div class="col-md-6">
	                					<label class="g-mb-10 g-font-weight-600">객체유형</label>		
		                				<div class="form-group g-pos-rel g-rounded-4 mb-0">
					                    <input data-role="dropdownlist"
										data-option-label="서비스를 소유하는 객체 유형을 선택하세요."
										data-auto-bind="true"
										data-text-field="NAME"
										data-value-field="OBJECT_TYPE"
										data-bind="value: source.objectType, enabled:editable, source: objectTypeDataSource"
										style="width: 100%;" /> 
									</div>
								</div>
								<div class="col-md-6">
	                					<label class="g-mb-10 g-font-weight-600">객체 ID</label>		
		                				<div class="form-group g-pos-rel g-rounded-4 mb-0">
					                    <input data-role="numerictextbox" placeholder="객체 ID" data-min="-1" data-format="###" data-bind="value:source.objectId" style="width: 100%"/>
				                    </div>
		                		</div>						
							</div>

							<div class="row g-mb-15" >
			            		<div class="col-md-6">
									<div class="form-group">
										<label class="g-mb-10 g-font-weight-600">버전<span class="text-danger">*</span></label>
										<div class="g-pos-rel">
											<input class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" 
											placeholder="버전 정보를 입력하세요" data-bind="value: source.apiVersion, enabled:editable">
										</div>
									</div>
								</div>
								<div class="col-md-6">
									<div class="form-group">
										<label class="g-mb-10 g-font-weight-600">콘텐츠 유형</label>
										<div class="g-pos-rel">
											<input class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" 
											placeholder="콘텐츠 유형를 입력하세요" data-bind="value: source.contentType, enabled:editable">
										</div>
									</div>	
		                		</div>						
							</div>
							
	 						<div class="form-group">
	                    			<label class="g-mb-10 g-font-weight-600" for="input-page-template">서버 스크립트<span class="text-danger">*</span></label>
		                    		<div class="g-pos-rel">
			                      	<span class="g-pos-abs g-top-0 g-right-0 d-block g-width-40 h-100 opacity-0 g-opacity-1--success">
				                  		<i class="hs-admin-check g-absolute-centered g-font-size-default g-color-lightblue-v3"></i>
				                		</span>
		                      		<input id="input-page-script" class="form-control form-control-md g-rounded-4 g-px-14 g-py-10" type="text" placeholder="서버 스크립트 파일 경로를 입력하세요" data-bind="value: source.scriptSource, enabled:editable">
		                    		</div>
								<div class="media-body d-flex align-self-center justify-content-end g-my-15">
									<a class="d-flex align-items-center u-link-v5 g-color-gray-light-v6 g-color-secondary--hover g-ml-10 g-ml-15--sm g-ml-30--xl" href="#!" data-bind="enabled:editable, click:openEditorWindow" >
										<i class="hs-admin-pencil-alt g-font-size-18"></i>
										<span class="g-hidden-sm-down g-ml-10">스크립트 불러오기</span>
									</a>
								</div>
	                  		</div> 																																																																				
							<div class="row g-pt-15" >
			            		<div class="col-md-6 g-mb-30">
									<label class="d-flex align-items-center justify-content-between g-mb-0">
										<span class="g-pr-20 g-font-weight-500">인증필요</span>
										<div class="u-check">
											<input class="g-hidden-xs-up g-pos-abs g-top-0 g-right-0" name="api-secured" value="true" data-bind="checked: source.secured,  enabled:editable" type="checkbox">
											<div class="u-check-icon-radio-v8">
												<i class="fa" data-check-icon=""></i>
											</div>
										</div>
									</label> 
									<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5 g-hidden-md-down">
									ON 상태인 경우 접근권한이 허용된 사용자만 이용할 수 있습니다.
									</small>
								</div>
								<div class="col-md-6 g-mb-30">
	                				<label class="d-flex align-items-center justify-content-between g-mb-0">
										<span class="g-pr-20 g-font-weight-500">API 사용여부</span>
										<div class="u-check">
											<input class="g-hidden-xs-up g-pos-abs g-top-0 g-right-0" name="api-enabled" value="true" data-bind="checked: source.enabled,  enabled:editable" type="checkbox">
											<div class="u-check-icon-radio-v8">
												<i class="fa" data-check-icon=""></i>
											</div>
										</div>
									</label> 
									<small class="g-font-weight-300 g-font-size-12 g-color-gray-dark-v6 g-pt-5 g-hidden-md-down">
									ON 상태인 경우 API 서비스가 동작합니다.
									</small>
		                		</div>						
							</div>		 
	                  																														
	                  		<!-- EDITOR START-->	
	                  		<!--                  		
							<div class="card g-brd-gray-light-v7 g-rounded-3 g-mb-30">
								<header class="card-header g-bg-transparent g-brd-gray-light-v7 g-px-15 g-px-30--sm g-pt-15 g-pt-20--sm g-pb-10 g-pb-15--sm"></header>
								<div class="card-block g-pa-15" ></div>
			                </div>	 
			                -->
	                  		<!-- EDITOR END --> 
	                  		<section data-bind="invisible:isNew" style="display:none;" > 
							<nav>
							  <div class="nav nav-tabs" id="nav-tab" role="tablist"> 
							    <a class="nav-item nav-link" id="nav-props-tab" data-toggle="tab" href="#nav-props" role="tab" aria-controls="nav-props" aria-selected="false">속성</a>
							  </div>
							</nav>
							<div class="tab-content" id="nav-tabContent">
 								<div class="tab-pane fade" id="nav-props" role="tabpanel" aria-labelledby="nav-props-tab"> 
									<div class="grid g-mt-5"></div> 
								</div>	   							   
							</div>
	                  		</section>
	                  		
						</div>
						<div class="g-brd-left--lg g-brd-gray-light-v4 col-md-2 g-mb-10 g-mb-0--md">
							<section class="g-mb-10 g-mt-20"> 
								<p>
								생성일 : <span class="g-color-gray-dark-v4 " data-bind="text: formatedCreationDate"> </span>
								</p>
								<p data-bind="invisible:isNew" >
								수정일 : <span class="g-color-gray-dark-v4" data-bind="text: formatedModifiedDate"> </span>
								</p>							
								</section>
							<!-- options setting -->					
						</div>		
					</div>												
					<div class="row"> 
						<div id="items-treelist"></div>
						<!-- menu listview -->
						<div class="table-responsive g-mb-0" style="display:none;">						
						<table class="table u-table--v3 g-color-black">
							<thead>
								<tr class="g-bg-gray-light-v8">
									<th class="g-valign-middle g-width-100 g-px-30 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="MENU_ITEM_ID" >
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
									<th class="g-valign-middle g-width-100" > 부모 ID </th>
									<th class="g-valign-middle g-px-30 g-width-300 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="NAME">
										<div class="media">
											<div class="d-flex align-self-center">이름</div>
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
									<th class="g-valign-middle g-px-30" > 설명 </th>
									<th class="g-valign-middle g-px-30 g-width-150 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="CREATION_DATE">
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
									<th class="g-valign-middle g-px-30 g-width-150 sorting" data-kind="menu" data-action="sort" data-dir="asc" data-field="MODIFIED_DATE">
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
									<th class="g-valign-middle g-px-30 g-width-100"></th>	
								</tr>	
							</thead>
							<tbody id="items-listview" class="u-listview g-brd-none">
							</tbody>
						</table>
						</div>					
						<div id="items-listview-pager" class="g-brd-top-none" style="width:100%;"></div>
            			<!-- menu listview end -->
					</div>
				</div>
				<!-- End Content Body -->
			 
			<!-- Footer -->
			<#include "includes/admin-footer.ftl">
			<!-- End Footer -->
		</div>
	</div>
	</section>
	
	<div id="window" style="display:none;"> 
		<div class="row" >
			<div class="col-lg-8"> 
				<div class="k-block g-ml-15"><div class="k-header">스크립트</div>
				<div id="treeview"></div>
				</div>
				
			</div>
			<div class="col-lg-4"><a href="#!" data-bind="click:selectScript, enabled:editable" class="btn btn-md u-btn-3d u-btn-primary g-width-180--md g-mb-10 g-font-size-default g-ml-10">스크립트 선택</a></div>
		</div> 
		<div class="row" >
			<div class="col-lg-12">
				<div class="g-pa-15">
				<div id="htmleditor" class="g-brd-gray-light-v6 g-brd-top-1 g-brd-left-0 g-brd-right-0 g-brd-style-solid g-brd-1 "></div>
				</div>		 
			</div>
		</div>
	</div>
	
	<div class="modal message-panel-frame fade" id="projects-security-modal" tabindex="-1" role="dialog" aria-labelledby="projects-security-modal-labal" aria-hidden="true">
	
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">	
		      	<div class="modal-header">
		      		<h2 class="modal-title">접근권한설정</h2>
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			          	<i aria-hidden="true" class="icon-svg icon-svg-sm icon-svg-ios-close m-t-xs"></i>
			        </button>
		      	</div><!-- /.modal-header -->		      	
		    	<div class="modal-body">		
						

					 					<!-- permission listview -->						
										<div class="g-mt-0"> 							
											<table class="table w-100 g-mb-25">
												<thead class="g-hidden-sm-down g-color-gray-dark-v6">
													<tr>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-150 ">유형</th>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-150">대상</th>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-min-width-150">권한</th>
														<th class="g-valign-middle g-font-weight-300 g-bg-gray-light-v8 g-color-black g-width-150">&nbsp;</th>
													</tr>
												</thead>
												<tbody id="projects-perms-listview" class="g-font-size-default g-color-black g-brd-0"></tbody>
											</table>
										</div>
										
										<!-- ./permission listview -->	         
										
										                            
		                                <p>익명사용자, 특정회원 또는 롤에 게시판에 대한 권한을 부여할 수 있습니다. 먼저 권한를 부여할 대상을 선택하세요. 마지막으로 권한추가를 클릭하면 권한이 부여됩니다.</p>
		                                <div class="g-mb-15">
					                    
					                    <label class="form-check-inline u-check g-pl-25 ml-0 g-mr-25">
					                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" name="permissionToType" checked="" value="anonymous" type="radio" data-bind="checked: permissionToType">
					                      <div class="u-check-icon-radio-v4 g-absolute-centered--y g-left-0 g-width-18 g-height-18">
					                        <i class="g-absolute-centered d-block g-width-10 g-height-10 g-bg-primary--checked"></i>
					                      </div>
					                      익명
					                    </label>
					
					                    <label class="form-check-inline u-check g-pl-25 ml-0 g-mr-25">
					                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" name="permissionToType" type="radio" value="user" data-bind="checked: permissionToType">
					                      <div class="u-check-icon-radio-v4 g-absolute-centered--y g-left-0 g-width-18 g-height-18">
					                        <i class="g-absolute-centered d-block g-width-10 g-height-10 g-bg-primary--checked"></i>
					                      </div>
					                      회원
					                    </label>
					
					                    <label class="form-check-inline u-check g-pl-25 ml-0 g-mr-25">
					                      <input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" name="permissionToType" type="radio" value="role" data-bind="checked: permissionToType">
					                      <div class="u-check-icon-radio-v4 g-absolute-centered--y g-left-0 g-width-18 g-height-18">
					                        <i class="g-absolute-centered d-block g-width-10 g-height-10 g-bg-primary--checked"></i>
					                      </div>
					                      롤
										</label>
		
										</div>
										
					<div class="row">
						<div class="col">
							<input data-role="dropdownlist"
												 data-option-label="롤을 선택하세요."
								                 data-auto-bind="false"
								                 data-text-field="name"
								                 data-value-field="name"
								                 data-bind="value: accessControlEntry.grantedAuthorityOwner, source: rolesDataSource, enabled: enabledSelectRole, visible:enabledSelectRole"
								                 style="width: 100%;" />
								               	
							<input type="text" class="form-control" placeholder="권한을 부여할 사용자 아이디(username)을 입력하세요" data-bind="value: accessControlEntry.grantedAuthorityOwner , disabled: permissionToDisabled, invisible:enabledSelectRole">  
						</div>
						<div class="col">
							<input data-role="dropdownlist"
												 data-option-label="권한을 선택하세요."
								                 data-auto-bind="false"
								                 data-text-field="name"
								                 data-value-field="name"
								                 data-bind="value: accessControlEntry.permission, source: permsDataSource"
								                 style="width: 100%;" />
						</div>
					</div>
					
					<div class="d-flex g-mt-20">
						<a href="#!" class="btn btn-md u-btn-outline-blue g-mr-10 g-mb-15" data-bind="click:addPermission"><i class="hs-admin-plus"></i> 권한 추가</a>
                    </div>      	
		      	</div>	
		      	<!-- .modal-footer -->	
		      	<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">확인</button>
					<!--<button type="button" class="btn btn-primary" data-bind="{ click: saveOrUpdate }">확인</button>-->
				</div> <!-- /.modal-footer -->	      	
		    </div>
		    <!-- /.modal-content -->
		</div>
	</div>		

	<script id="treeview-template" type="text/kendo-ui-template">
	#if(item.directory){#<i class="fa fa-folder-open-o"></i> # }else{# <i class="fa fa-file-code-o"></i> #}#
	<span class="g-ml-5">#: item.name # </span>
	# if (!item.items) { #
		<a class='delete-link' href='\#'></a> 
	# } #
    </script>	
        	
	<script type="text/x-kendo-template" id="attachments-template">   
	<tr class="g-height-55">
		<td class="align-middle text-center g-width-50 g-pa-0">				
			#if ( contentType.match("^image") ) {#	
			<img class="g-width-50 g-height-50" src="#= community.data.getAttachmentThumbnailUrl( data, true) #" />
			# }else if( contentType === "application/pdf" || contentType === "application/vnd.openxmlformats-officedocument.presentationml.presentation" ){ #		
			<img class="g-brd-around g-brd-gray-light-v4 g-width-50 g-height-50" src="#= community.data.getAttachmentThumbnailUrl( data, true) #" />
			# } else { #			
			<i class="icon-svg icon-svg-sm icon-svg-dusk-attach m-t-xs"></i>
			# } #
		</td> 
		<td class="align-middle text-center g-width-30 g-pa-0">
			<a class="u-icon-v1 g-font-size-16 g-text-underline--none--hover" href="#: community.data.getAttachmentUrl(data) #" title="" data-toggle="tooltip" data-placement="top" data-original-title="PC 저장">
				<i class="icon-communication-038 u-line-icon-pro"></i>
			</a>			
		</td>
		<td class="align-middle g-font-weight-400"> #: name #  </td>
		<td class="align-middle text-right"><span class='text-muted'>#: formattedSize() #</span></td> 
		<td class="align-middle g-width-50 g-pa-0">		
			<a class="u-icon-v1 g-font-size-16 g-text-underline--none--hover" href="\\#!" title="" data-toggle="tooltip" data-placement="top" data-original-title="삭제" data-kind="attachment" data-action="remove" data-object-id="#= attachmentId #" data-owner-object-id="#= objectId #" >
				<i class="icon-hotel-restaurant-214 u-line-icon-pro"></i>
			</a>
        </td> 
	</tr>            	        	        	
	</script> 
			
	<script type="text/x-kendo-template" id="perms-template">    	 	
	<tr>
		<td class="align-middle text-nowrap g-width-150" >
			#: grantedAuthority #
		</td>
		<td class="align-middle ">
			<div class="d-inline-block">
				<span class="d-flex align-items-center justify-content-center u-tags-v1 g-brd-around g-bg-gray-light-v8 g-brd-gray-light-v8 g-font-size-default g-color-gray-dark-v6 g-rounded-50 g-py-4 g-px-15">
					<span class="u-badge-v2--md g-pos-stc g-transform-origin--top-left g-bg-lightblue-v3 g-mr-8"></span>
					#: grantedAuthorityOwner #
				</span>
            </div>		
		</td>
		<td class="align-middle g-width-150">			
			<span class="u-tags-v1 text-center g-width-110 g-brd-around g-brd-teal-v2 g-bg-teal-v2 g-font-weight-400 g-color-white g-rounded-50 g-py-4 g-px-15">#: permission #</span>
		</td>
		<td class="align-middle text-nowrap text-center g-width-150">
			<a class="g-color-gray-dark-v5 g-text-underline--none--hover g-pa-5" href="\\#!" data-toggle="tooltip" data-placement="top" data-original-title="Delete" data-subject="permission" data-action="delete" data-object-id="#= id #">
				<i class="hs-admin-trash g-font-size-18"></i>
			</a>
		</td>
	</tr>			                      
    </script>    
    		
	<script type="text/x-kendo-template" id="template">    	
	<tr>
		<td class="g-px-30">#: menuItemId # </td>
		<td class="g-px-30">#if( parentMenuItemId < 0 ) {# - #}else{# #:parentMenuItemId # #}#</td>
		<td class="g-px-30">
		<a class="d-flex align-items-center u-link-v5 g-color-black g-color-lightblue-v3--hover g-color-lightblue-v3--opened" href="\#!" data-object-id="#=menuId#" data-object-type="menu">#: name #</a>
		</td>
		<td class="g-px-30">#: description #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( creationDate)  #</td>
		<td class="g-px-30">#: community.data.getFormattedDate( modifiedDate)  #</td>
		<td class="g-px-30">
			<div class="d-flex align-items-center g-line-height-1">
				<a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover g-mr-15" href="\#!" data-action="edit" data-object-type="menu" data-object-id="#= menuId #" >
					<i class="hs-admin-pencil g-font-size-18"></i>
                </a>
                <!--
                <a class="u-link-v5 g-color-gray-light-v6 g-color-lightblue-v4--hover" href="\#!" data-action="delete" data-object-type="menu" data-object-id="#= menuId #" >
                		<i class="hs-admin-trash g-font-size-18"></i>
                </a>-->
			</div>
		</td>
	</tr>
	</script>

	<!-- porperties template -->
	<script type="text/x-kendo-template" id="property-template">   
	<tr>
		<td class="align-middle">#: name # </td>
		<td class="align-middle">#: value #</td>
		<td class="align-middle text-center">
			<div class="btn-group">
                <a class="btn btn-sm u-btn-outline-bluegray k-edit-button" href="\\#">수정</a>
                <a class="btn btn-sm u-btn-outline-bluegray k-delete-button" href="\\#">삭제</a>
            </div>
		</td>
	</td>
	</script>
	<script type="text/x-kendo-template" id="property-edit-template">   
	<tr>
		<td class="align-middle">
			<input type="text" class="k-textbox form-control" data-bind="value:name" name="name" required="required" validationMessage="필수 입력 항목입니다." />
			<span data-for="name" class="k-invalid-msg"></span>
		</td>
		<td class="align-middle">
			<input type="text" class="k-textbox form-control" data-bind="value:value" name="value" required="required" validationMessage="필수 입력 항목입니다." />
			<span data-for="value" class="k-invalid-msg"></span>		
		</td>
		<td class="align-middle text-center">
			<a class="btn btn-sm u-btn-outline-bluegray k-update-button" href="\\#">확인</a>
            <a class="btn btn-sm u-btn-outline-bluegray k-cancel-button" href="\\#">취소</a>
		</td>
	</td>
	</script>			 	
</body>
</html>
</#compress> 	