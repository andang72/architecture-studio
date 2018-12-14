(function (window, $, undefined) {
	
	var community = window.community = window.community || { model : {} , data :{ model: {} }},
	extend = $.extend,
	Model = kendo.data.Model;
	community.data = community.data || { model : {}} ;
	community.model.Property = Model.define({ 		
		id: "name",
		fields: { 			
			name: { type: "string", defaultValue: "" },			
			value: { type: "string", defaultValue: "" }
		}
	});

	community.model.Category = Model.define({ 		
		id: "categoryId",
		fields: { 		
			categoryId: { type: "number", defaultValue: 0 },			
			objectType: { type: "number", defaultValue: 0 },			
			objectId: { type: "number", defaultValue: 0},			
			name: { type: "string", defaultValue: "" },	
			displayName: { type: "string", defaultValue: "" },
			description: { type: "string", defaultValue: "" },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"}
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    	return kendo.toString(this.get("modifiedDate"), "g");
	    },
		copy : function ( target ){
		    target.categoryId = this.get("categoryId");
		    target.set("name", this.get("name"));
		    target.set("displayName", this.get("displayName"));
		    target.set("objectType", this.get("objectType"));
		    target.set("objectId", this.get("objectId"));
		    target.set("description", this.get("description"));
		    if( typeof this.get("properties") === 'object' )
		    	target.set("properties", this.get("properties"));	  
		    if(this.get("creationDate") != null )
		    	target.set("creationDate", this.get("creationDate"));
		    if(this.get("modifiedDate") != null )
		    	target.set("modifiedDate", this.get("modifiedDate"));
		}
	});
	
	community.model.Menu = Model.define({ 		
		id: "menuId",
		fields: { 		
			menuId: { type: "number", defaultValue: 0 },			
			name: { type: "string", defaultValue: null },		
			description: { type: "string", defaultValue: null },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"}
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    },
		copy : function ( target ){
		    	target.menuId = this.get("menuId");
		    	target.set("name", this.get("name"));
		    	target.set("description", this.get("description"));
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties"));	  
		    	if(this.get("creationDate") != null )
		    		target.set("creationDate", this.get("creationDate"));
		    if(this.get("modifiedDate") != null )
		    		target.set("modifiedDate", this.get("modifiedDate"));
		}
	});
	
	community.model.MenuItem = Model.define({ 		
		id: "menuItemId",
		parentId: "parentMenuItemId",
		fields: { 		
			menuItemId: { type: "number", defaultValue: 0 },		
			menuId: { type: "number", defaultValue: 0 },	
			parentMenuItemId: { type: "number", defaultValue: null },	
			name: { type: "string", defaultValue: null },	
			page: { type: "string", defaultValue: null },	
			roles: { type: "string", defaultValue: null },	
			sortOrder: { type: "number", defaultValue: 1 },	
			location: { type: "string", defaultValue: null },	
			description: { type: "string", defaultValue: null },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"}
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    },
		copy : function ( target ){
		    	target.menuItemId = this.get("menuItemId");
		    	target.set("name", this.get("name"));
		    	target.set("menuId", this.get("menuId"));
		    	target.set("parentMenuItemId", this.get("parentMenuItemId"));
		    	target.set("roles", this.get("roles"));
		    	target.set("sortOrder", this.get("sortOrder"));
		    target.set("page", this.get("page"));
		    	target.set("location", this.get("location"));
		    	target.set("description", this.get("description"));
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties"));	  
		    	if(this.get("creationDate") != null )
		    		target.set("creationDate", this.get("creationDate"));
		    if(this.get("modifiedDate") != null )
		    		target.set("modifiedDate", this.get("modifiedDate"));
		}
	});
	
	
	community.model.Role = Model.define({ 		
		id: "roleId",
		fields: { 		
			roleId: { type: "number", defaultValue: 0 },			
			name: { type: "string", defaultValue: null },		
			description: { type: "string", defaultValue: null },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"}
		}
	});
	
	community.model.ObjectAccessControlEntry = Model.define({ 		
		id: "id",
		fields: { 	
			id: { type: "number", defaultValue: 0 },			
			granting: { type: "boolean", defaultValue: false },			
			domainObjectClass: { type: "string", defaultValue: "" },			
			domainObjectId: { type: "number", defaultValue: 0 },			
			grantedAuthority: { type: "string", defaultValue: "" },			
			grantedAuthorityOwner:{ type: "string", defaultValue: "" },
			permission:{ type: "string", defaultValue: "" }
		}
	});
	
	community.model.User = Model.define({ 
		id : "userId",
		fields: { 			
			userId: { type: "number", defaultValue: 0 },			
			username: { type: "string", defaultValue: "" },			
			name: { type: "string", defaultValue: "" },			
			nameVisible: { type: "boolean", defaultValue: false },	
			firstName: { type: "string", defaultValue: "" },
			lastName: { type: "string", defaultValue: "" },
			email: { type: "string", defaultValue: "" },			
			emailVisible: { type: "boolean", defaultValue: false },					
			anonymous: { type: "boolean", defaultValue: true },			
			enabled: { type: "boolean", defaultValue: false },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"},
			status : {type:"string", defaultValue: "NONE"},
			properties: { type: "object", defaultValue : {} },
			roles: { type: "object", defaultValue: [] }
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    },
		getUserProfileImage : function (){
			return getUserProfileImage(this);			
		},
		hasRole : function ( role ) {
			if( typeof( this.roles ) != "undefined" && $.inArray( role, this.roles ) >= 0 )
				return true
			else 
				return false;    	
	    },
	    copy : function ( target ){
		    	target.userId = this.get("userId");
		    	target.set("username", this.get("username"));
		    	target.set("name", this.get("name"));
		    	target.set("email", this.get("email"));
		    	target.set("status", this.get("status"));		    	
		    	if(this.get("creationDate") != null )
		    		target.set("creationDate", this.get("creationDate"));
		    	if(this.get("modifiedDate") != null )
		    		target.set("modifiedDate", this.get("modifiedDate"));
		    	target.set("enabled", this.get("enabled"));
		    	target.set("nameVisible", this.get("nameVisible"));
		    	target.set("emailVisible", this.get("emailVisible"));
		    	target.set("anonymous", this.get("anonymous"));
		    	if( typeof this.get("roles") === 'object' )
		    		target.set("roles", this.get("roles") );	
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties"));	    	
		}
	});
	
	community.model.Board = Model.define({ 
		id : "boardId",
		fields: { 			
			boardId: { type: "number", defaultValue: 0 },			
			objectType: { type: "number", defaultValue: 0 },			
			objectId: { type: "number", defaultValue: 0},			
			name: { type: "string", defaultValue: "" },	
			displayName: { type: "string", defaultValue: "" },
			description: { type: "string", defaultValue: "" },
			properties: { type: "object", defaultValue : {} },
			totalMessage: { type: "number", defaultValue: 0},
			totalViewCount: { type: "number", defaultValue: 0},
			totalThreadCount: { type: "number", defaultValue: 0},
			createThread: { type: "boolean", defaultValue: false },
			createThreadMessage: { type: "boolean", defaultValue: false },
			createAttachement: { type: "boolean", defaultValue: false },
			createComment: { type: "boolean", defaultValue: false },
			createImage: { type: "boolean", defaultValue: false },
			readComment: { type: "boolean", defaultValue: false },
			readable: { type: "boolean", defaultValue: false },
			writable: { type: "boolean", defaultValue: false },
			creationDate:{ type: "date" },
			modifiedDate:{ type: "date"}
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    },
		copy : function ( target ){
		    	target.boardId = this.get("boardId");
		    	target.set("objectType", this.get("objectType"));
		    	target.set("objectId", this.get("objectId"));
		    	target.set("name", this.get("name"));
		    	target.set("displayName", this.get("displayName"));
		    	target.set("description", this.get("description"));
		    	target.set("totalMessage", this.get("totalMessage"));
		    	target.set("totalViewCount", this.get("totalViewCount"));
		    	target.set("totalThreadCount", this.get("totalThreadCount"));
		    	target.set("writable", this.get("writable"));
		    	target.set("readable", this.get("readable"));
		    	target.set("createImage", this.get("createImage"));
		    	target.set("createComment", this.get("createComment"));
		    	target.set("createAttachement", this.get("createAttachement"));
		    	target.set("createThread", this.get("createThread"));
		    	target.set("createThreadMessage", this.get("createThreadMessage"));
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties"));	  
		    	if(this.get("creationDate") != null )
		    		target.set("creationDate", this.get("creationDate"));
		    if(this.get("modifiedDate") != null )
		    		target.set("modifiedDate", this.get("modifiedDate"));
		}
		
	});

	
	community.model.Message = Model.define({ 		
		id: "messageId",
		fields: { 	
			user: { type: "object" , defaultValue : new community.model.User()},
			objectType: { type: "number", defaultValue: 0 },			
			objectId: { type: "number", defaultValue: 0 },			
			threadId: { type: "number", defaultValue: 0 },			
			messageId: { type: "number", defaultValue: 0 },			
			parentMessageId: { type: "number", defaultValue: 0 },			
			keywords:{ type: "string", defaultValue: "" },		
			subject:{ type: "string", defaultValue: "" },			
			body:{type: "string", defaultValue: "" },			
			replyCount:{ type: "number", defaultValue: 0 },	
			attachmentsCount:{ type: "number", defaultValue: 0 },	
			properties: { type: "object", defaultValue : {} },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date" }
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    }
	});
	
	community.model.Thread = Model.define({ 
		id : "threadId",
		fields: { 	
			threadId: { type: "number", defaultValue: 0 },		
			objectType: { type: "number", defaultValue: 0 },		
			objectId: { type: "number", defaultValue: 0 },		
			latestMessage :{ type: "object", defaultValue: new community.model.Message() },	
			rootMessage	: { type: "object", defaultValue: new community.model.Message() },	
			messageCount: { type: "number", defaultValue: 0 },	
			viewCount: { type: "number", defaultValue: 0 },	
			properties: { type: "object", defaultValue : {} },
			creationDate: { type: "date" },			
			modifiedDate: { type: "date" }
		},
		formattedCreationDate : function(){		
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    },
		copy: function ( target ){
			target.threadId = this.get("threadId");
		    	target.set("objectType",this.get("objectType") );
		    	target.set("objectId", this.get("objectId"));
		    	target.set("messageCount",this.get("messageCount") );
		    	target.set("viewCount", this.get("viewCount"));
		    	target.set("modifiedDate",this.get("modifiedDate") );
		    	target.set("creationDate", this.get("creationDate") )
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties") );
		    	if( typeof this.get("latestMessage") === 'object' )
		    		target.set("latestMessage", this.get("latestMessage") );
		    	if( typeof this.get("rootMessage") === 'object' )
		    		target.set("rootMessage", this.get("rootMessage") );
		    	
		}
	});
	
	community.model.Attachment = Model.define({ 
		id : "attachmentId",
		fields: { 	
			attachmentId:{ type: "number", defaultValue: 0 },		
			objectType:{ type: "number", defaultValue: 0 },		
			objectId:{ type: "number", defaultValue: 0 },		
			name:{ type: "string", defaultValue: "" },
			contentType:{ type: "string", defaultValue: "" },
			downloadCount:{ type: "number", defaultValue: 0 },	
			size: { type: "number", defaultValue: 0 },	
			user: { type: "object" , defaultValue : new community.model.User()},
			properties: { type: "object", defaultValue : {} },
			creationDate: { type: "date" },			
			modifiedDate: { type: "date" }
		},
		formattedSize : function(){
			return kendo.toString(this.get("size"), "##,###");
		},	
		formattedCreationDate : function(){
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    }
	});
	
	community.model.Image = Model.define({ 
		id : "imageId",
		fields: { 	
			imageId:{ type: "number", defaultValue: 0 },		
			objectType:{ type: "number", defaultValue: 0 },		
			objectId:{ type: "number", defaultValue: 0 },		
			name:{ type: "string", defaultValue: "" },
			contentType:{ type: "string", defaultValue: "" },
			size: { type: "number", defaultValue: 0 },	
			thumbnailContentType:{ type: "string", defaultValue: "" },	
			thumbnailSize : { type: "number", defaultValue: 0 },				
			user: { type: "object" , defaultValue : new community.model.User()},
			properties: { type: "object", defaultValue : {} },
			creationDate: { type: "date" },			
			modifiedDate: { type: "date" }
		},
		copy: function ( target ){
			target.imageId = this.get("imageId");
		    	target.set("objectType",this.get("objectType") );
		    	target.set("objectId", this.get("objectId"));
		    	target.set("name",this.get("name") );
		    	target.set("contentType", this.get("contentType"));
		    	target.set("size", this.get("size"));
		    	target.set("thumbnailContentType", this.get("thumbnailContentType"));
		    	target.set("thumbnailSize", this.get("thumbnailSize"));
		    	target.set("modifiedDate",this.get("modifiedDate") );
		    	target.set("creationDate", this.get("creationDate") ); 
		    	if( typeof this.get("user") === 'object' )
		    		target.set("user", this.get("user") );
		    	
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties") ); 
		},
		formattedSize : function(){
			return kendo.toString(this.get("size"), "##,###");
		},	
		formattedCreationDate : function(){
			return kendo.toString(this.get("creationDate"), "g");
	    },
	    formattedModifiedDate : function(){
	    		return kendo.toString(this.get("modifiedDate"), "g");
	    }
	});
	
	community.model.BodyContent = Model.define({ 		
		id: "bodyId",
		fields: { 	
			bodyId: { type: "number", defaultValue: -1 },			
			bodyText: { type: "string", defaultValue: "" },			
			bodyType:{ type: "string", defaultValue: "FREEMARKER" },
			pageId: { type: "number", defaultValue: 0 }	
		}
	});	 
	
	community.model.Page = Model.define({ 		
		id: "pageId",
		fields: { 	
			objectType: { type: "number", defaultValue: -1 },			
			objectId: { type: "number", defaultValue: -1},				
			pageId: { type: "number", defaultValue: 0 },			
			name: { type: "string", defaultValue: "" },	
			versionId: { type: "number", defaultValue: 0 },	
			pageState: { type: "string", defaultValue: "INCOMPLETE" },	
			commentCount: { type: "number", defaultValue: 0 },		
			viewCount: { type: "number", defaultValue: 0 },		
			summary: { type: "string", defaultValue: "" },	
			tagsString: { type: "string", defaultValue: "" },	
			title: { type: "string", defaultValue: "" },
			template: { type: "string", defaultValue: "" },
			pattern: { type: "string", defaultValue: "" },
			script: { type: "string", defaultValue: "" },
			secured: { type: "boolean", defaultValue: false },
			properties: { type: "object", defaultValue : {} },
			bodyText: { type: "string", defaultValue: "" },	
			bodyContent : { type: "object", defaultValue : new community.model.BodyContent() },
			user: { type: "object" , defaultValue : new community.model.User() },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"}	
		},
		copy: function ( target ){
			target.pageId = this.get("pageId");
		    	target.set("objectType",this.get("objectType") );
		    	target.set("objectId", this.get("objectId"));
		    	target.set("name",this.get("name") );
		    	target.set("versionId", this.get("versionId"));
		    	target.set("pageState", this.get("pageState"));
		    	target.set("commentCount", this.get("commentCount"));
		    	target.set("viewCount", this.get("viewCount"));
		    	target.set("summary", this.get("summary"));
		    	target.set("tagsString", this.get("tagsString"));
		    	target.set("title", this.get("title"));
		    	target.set("template", this.get("template"));
		    	target.set("pattern", this.get("pattern"));
		    	target.set("script", this.get("script"));
		    	target.set("secured", this.get("secured"));
		    	target.set("bodyText", this.get("bodyText"));
		    	target.set("modifiedDate",this.get("modifiedDate") );
		    	target.set("creationDate", this.get("creationDate") )
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties") );
		    	if( typeof this.get("user") === 'object' )
		    		target.set("user", this.get("user") );
		    	if( typeof this.get("bodyContent") === 'object' )
		    		target.set("bodyContent", this.get("bodyContent") ); 
		}
	});
	
	community.model.Project = Model.define({ 		
		id: "projectId",
		fields: { 	
			projectId: { type: "number", defaultValue: -1 },			
			name: { type: "string", defaultValue: "" },			
			summary:{ type: "string", defaultValue: "" },
			enabled: { type: "boolean", defaultValue: true },
			contractState: { type: "string", defaultValue: "" },
			contractor: { type: "string", defaultValue: "" },
			maintenanceCost : { type: "number", defaultValue: 0 },
			startDate:{ type: "date" },			
			endDate:{ type: "date"},
			properties: { type: "object", defaultValue : {} },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date" }	
		},
		copy: function ( target ){
			target.projectId = this.get("projectId");
				target.set("name",this.get("name") );
		    	target.set("summary", this.get("summary") );
		    	target.set("contractor", this.get("contractor") );
		    	target.set("contractState", this.get("contractState") );
		    	target.set("maintenanceCost", this.get("maintenanceCost") );
		    	target.set("startDate",this.get("startDate") );
		    	target.set("endDate", this.get("endDate") );		
		    	target.set("modifiedDate",this.get("modifiedDate") );
		    	target.set("creationDate", this.get("creationDate") );
		    	target.set("enabled", this.get("enabled") );
		    	if( typeof this.get("properties") === 'object' )
		    		target.set("properties", this.get("properties") );
		}
	});	

	community.model.Task = Model.define({ 		
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
			modifiedDate:{ type: "date"},
			properties: { type: "object", defaultValue : {} },
		},
		copy: function ( target ){
			target.taskId = this.get("taskId");
			target.set("objectType",this.get("objectType") );
	    	target.set("objectId", this.get("objectId"));
		   	target.set("taskName",this.get("taskName") );
		   	target.set("description", this.get("description") );
		   	target.set("version", this.get("version") ); 
		   	target.set("price", this.get("price") );
		   	target.set("startDate",this.get("startDate") );
		   	target.set("endDate", this.get("endDate") );		
		   	target.set("modifiedDate",this.get("modifiedDate") );
		   	target.set("creationDate", this.get("creationDate") );
		   	target.set("progress", this.get("progress") );
		   	if( typeof this.get("properties") === 'object' )
		   		target.set("properties", this.get("properties") );
		}
	});	
	
	community.model.Issue = Model.define({  
		id: "issueId",
		fields: { 	
			issueId: { type: "number", defaultValue: -1 },	
			objectType: { type: "number", defaultValue: -1 },			
			objectId: { type: "number", defaultValue: -1},	
			issueType: { type: "string", defaultValue: null },			
			issueTypeName: { type: "string", defaultValue: null },
			summary:{ type: "string", defaultValue: "" },
			description: { type: "string", defaultValue: "" },
			priority : { type: "string", defaultValue: "002" },
			priorityName: { type: "string", defaultValue: null },
			resolution : { type: "string", defaultValue: null},
			resolutionName: { type: "string", defaultValue: null },	
			resolutionDate : { type: "date", defaultValue: null},
			status : { type: "string", defaultValue: "001"},
			statusName: { type: "string", defaultValue: null },
			startDate:{ type: "date", defaultValue: null },	
			dueDate:{ type: "date", defaultValue: null },	
			estimate: { type: "number", defaultValue: 0},	
			timeSpent: { type: "number", defaultValue: 0},	
			originalEstimate: { type: "number", defaultValue: 0},	
			repoter:{ type: "object", defaultValue: new community.model.User() },
			assignee:{ type: "object", defaultValue: new community.model.User() },
			task:{ type: "object", defaultValue: new community.model.Task() },
			requestorName : {type: "string"},
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date" }	
		},
		copy: function ( target ){
			target.issueId = this.get("issueId");
	    		target.set("objectType",this.get("objectType") );
	    		target.set("objectId", this.get("objectId"));
		    	target.set("issueType",this.get("issueType") );
		    	target.set("issueTypeName",this.get("issueTypeName") );	
		    	target.set("resolution",this.get("resolution") );
		    	target.set("resolutionName",this.get("resolutionName") );			    	
		    	target.set("status",this.get("status") );
		    	target.set("statusName",this.get("statusName") );			    	
		    	target.set("summary", this.get("summary") );
		    	target.set("priority",this.get("priority") );	
		    	target.set("priorityName",this.get("priorityName") );	
		    	target.set("description", this.get("description") );
		    	target.set("maintenanceCost", this.get("maintenanceCost") );
		    	target.set("startDate",this.get("startDate") );	
		    	target.set("dueDate",this.get("dueDate") );	
		    	target.set("modifiedDate",this.get("modifiedDate") );
		    	target.set("creationDate", this.get("creationDate") );
		    	target.set("resolutionDate", this.get("resolutionDate") );
		    	target.set("timeSpent", this.get("timeSpent") );
		    	target.set("estimate", this.get("estimate") );
		    	target.set("originalEstimate", this.get("originalEstimate") );
		    	target.set("requestorName", this.get("requestorName"));
		    	if( typeof this.get("task") === 'object' )
		    		target.set("task", this.get("task") );
		    	if( typeof this.get("repoter") === 'object' )
		    		target.set("repoter", this.get("repoter") );
		    	if( typeof this.get("assignee") === 'object' )
		    		target.set("assignee", this.get("assignee") );
		}			
	});
	
	
	community.model.Announce = kendo.data.Model.define({
		id : "announceId", // the identifier of the model
		fields : {
			announceId : { type : "number", editable : false, defaultValue : 0 },
			objectType : { type : "number", editable : true, defaultValue : 0 },
			objectId : { type : "number", editable : true, defaultValue : 0 },
			subject : { type : "string", editable : true },
			body : { type : "string", editable : true },
			startDate : { type : "date", editable : true },
			endDate : { type : "date", editable : true },
			user : { type : "common.ui.data.User" },
			modifiedDate : { type : "date" },
			creationDate : { type : "date" }
		},
		authorPhotoUrl : function() {
			if (typeof this.get("user") === 'object')
				return getUserProfileImage(this.get("user"));
			else
				return "/images/common/no-avatar.png";
		},
		formattedCreationDate : function() {
			return kendo.toString(this.get("creationDate"), "g");
		},
		formattedModifiedDate : function() {
			return kendo.toString(this.get("modifiedDate"), "g");
		},
		formattedStartDate : function() {				
			return kendo.toString(this.get("startDate"), 'yyyy.MM.dd');
		},
		formattedEndDate : function() {
			return kendo.toString(this.get("endDate"), "g");
		},
		copy : function(target) {
			if (typeof this.get("user") === 'object')
				target.set("user", this.get("user"));
			if (typeof this.get("properties") === 'object')
				target.set("properties", this.get("properties"));
			target.announceId = this.get("announceId");
			target.set("objectType", this.get("objectType"));
			target.set("objectId", this.get("objectId"));
			target.set("subject", this.get("subject"));
			target.set("body", this.get("body"));
			target.set("startDate", this.get("startDate"));
			target.set("endDate", this.get("endDate"));
			target.set("modifiedDate", this.get("modifiedDate"));
			target.set("creationDate", this.get("creationDate")); 
		}
	});

	community.data.model.FileInfo = kendo.data.Model.define({  
		id: "name",
		fields: { 	
			name: { type: "string", defaultValue: null },			
			path: { type: "string", defaultValue: null }, 
			fileContent:{ type: "string", defaultValue: null },
			directory: { type: "boolean", defaultValue: false },
			size: { type: "number", defaultValue: 0 },
			lastModifiedDate:{ type: "date" } 			
		},
		copy: function ( target ){
			target.name = this.get("name");
			target.set("path", this.get("path"));
			target.set("fileContent", this.get("fileContent"));
			target.set("directory", this.get("directory"));
			target.set("size", this.get("size"));
			target.set("lastModifiedDate", this.get("lastModifiedDate"));
		}			
	}); 
	
	community.data.model.Api = kendo.data.Model.define({  
		id: "apiId",
		fields: { 	
			apiId: { type: "number", defaultValue: -1 },	
			objectType: { type: "number", defaultValue: -1 },			
			objectId: { type: "number", defaultValue: -1},	
			title: { type: "string", defaultValue: null },	
			apiName: { type: "string", defaultValue: null },			
			apiVersion: { type: "string", defaultValue: null }, 
			description: { type: "string", defaultValue: null },
			contentType : { type: "string", defaultValue: null },
			scriptSource: { type: "string", defaultValue: null },
			pattern: { type: "string", defaultValue: null },
			creator:{ type: "object", defaultValue: new community.model.User() },
			properties: { type: "object", defaultValue : {} },
			secured: { type: "boolean", defaultValue: false },
			enabled: { type: "boolean", defaultValue: false },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date" }				
		},
		copy: function ( target ){
			target.apiId = this.get("apiId");
			target.set("objectType", this.get("objectType"));
			target.set("objectId", this.get("objectId"));
			target.set("title", this.get("title"));
			target.set("apiName", this.get("apiName"));
			target.set("apiVersion", this.get("apiVersion"));
			target.set("description", this.get("description"));
			target.set("contentType", this.get("contentType"));
			target.set("scriptSource", this.get("scriptSource"));
			target.set("pattern", this.get("pattern"));
			target.set("secured", this.get("secured"));
			target.set("enabled", this.get("enabled"));
			target.set("modifiedDate", this.get("modifiedDate"));
			target.set("creationDate", this.get("creationDate"));
			if( typeof this.get("creator") === 'object' )
				target.set("creator", this.get("creator") );
			if( typeof this.get("properties") === 'object' )
				target.set("properties", this.get("properties") ); 
		}			
	}); 

	
	community.model.WikiBodyContent = Model.define({ 		
		id: "bodyId",
		fields: { 	
			bodyId: { type: "number", defaultValue: -1 },			
			bodyText: { type: "string", defaultValue: "" },			 
			wikiId: { type: "number", defaultValue: 0 }	
		}
	});	 
	
	community.model.Wiki = Model.define({ 		
		id: "wikiId",
		fields: { 	
			wikiId: { type: "number", defaultValue: -1 },	
			objectType: { type: "number", defaultValue: -1 },			
			objectId: { type: "number", defaultValue: -1},	 
			name: { type: "string", defaultValue: "" },	
			version : { type: "number", defaultValue: 0 },	
			wikiState: { type: "string", defaultValue: "INCOMPLETE" },	   
			title: { type: "string", defaultValue: "" },  
			secured: { type: "boolean", defaultValue: false },
			properties: { type: "object", defaultValue : {} },
			bodyContent : { type: "object", defaultValue : new community.model.WikiBodyContent() },
			creater: { type: "object" , defaultValue : new community.model.User() },
			creationDate:{ type: "date" },			
			modifiedDate:{ type: "date"}	
		},
		copy: function ( target ){
			target.wikiId = this.get("wikiId");
		    target.set("objectType",this.get("objectType") );
		    target.set("objectId", this.get("objectId"));
		    target.set("name",this.get("name") );
		    target.set("version", this.get("version"));
		    target.set("wikiState", this.get("wikiState")); 
		    target.set("title", this.get("title"));  
		    target.set("secured", this.get("secured")); 
		    target.set("modifiedDate",this.get("modifiedDate") );
		    target.set("creationDate", this.get("creationDate") )
		    if( typeof this.get("properties") === 'object' )
		    	target.set("properties", this.get("properties") );
		    if( typeof this.get("user") === 'object' )
		    	target.set("creater", this.get("creater") );
		    if( typeof this.get("bodyContent") === 'object' )
		    	target.set("bodyContent", this.get("bodyContent") );
		    
		    if( target.get("wikiState") == null )
		    	target.set("wikiState" , "INCOMPLETE" );
		    if( target.get("bodyContent") == null )
		    	target.set("bodyContent" , new community.model.WikiBodyContent() );
		    	
		}
	});
	
	community.model.Chart = Model.define({
		//id: "bodyId",
		fields: { 	
			date: { type: "string", defaultValue: "" },
			value1: { type: "number", defaultValue: 0 },
			value2: { type: "number", defaultValue: 0 }
		}
	});	
	
	function getUserProfileImage ( user ) {
		if( user != null && !user.anonymous && user.username != null &&  user.username.length > 0 )
			return encodeURI (community.ui.path() + '/download/avatar/' + user.username + '?height=96&width=96&time=' + kendo.guid() );
		else
			return community.ui.path() + "/images/no-avatar.png";
	}
	
	function getAttachmentUrl ( attachment ){	
		return getAttachmentThumbnailUrl(attachment, false);
	}
	
	function getAttachmentThumbnailUrl ( attachment , thumbnail ){	
		if( attachment.attachmentId > 0 ){
			var _photoUrl = '/download/files/' + attachment.attachmentId + '/' + attachment.name  ; 
			if( thumbnail ){
				_photoUrl = _photoUrl + '?thumbnail=true&height=120&width=120&time=' + kendo.guid() ;
			}else{
				_photoUrl = _photoUrl + '?time=' + kendo.guid() ;
			} 
			return encodeURI( _photoUrl );
		}
		return "/images/no-image.jpg";
	} 
	
	var DEFAULT_DOWNLOAD_OPTIONS = {
		thumbnail : false,		
		width : 150,
		height : 150
	};
	
	function getImageUrl ( image , options ){	
		options = options || {};		
		var settings = extend(true, {}, DEFAULT_DOWNLOAD_OPTIONS , options ); 
		if( image.imageId > 0 ){
			var _imageUrl = '/download/images/' + image.imageId + '/' + image.name  ; 
			if( settings.thumbnail ){
				_imageUrl = _imageUrl + '?thumbnail=true&height='+ settings.height +'&width='+ settings.width + '&time=' + kendo.guid() ;
			}else{
				_imageUrl = _imageUrl + '?time=' + kendo.guid() ;
			} 
			return encodeURI( _imageUrl );
		}
		return "/images/no-image.jpg";
	} 
	
	function getUserDisplayName (user){
		var displayName = "익명";
		if( user != null && !user.anonymous ){
			if( user.nameVisible )
			{
				displayName = user.name;
			}else{
				displayName = user.username;
			}
		}
		return displayName ;
	}
	
	function getFormattedNumber(num, format){
		format = format || '###,##';		
		if( typeof(num) == 'string')			
			return kendo.toString(new Number( num ) , format);
		return kendo.toString(num, format);
	}
	
	function getFormattedDate(date, format ){		
		format = format || "g";		
		if( typeof(date) == 'string')			
			return kendo.toString(new Date( date ) , format);
		return kendo.toString(date, format);
	}
	
	
	function bytesToSize(bytes) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
		    if (bytes == 0) return 'n/a';
		    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
		    if (i == 0) return bytes + ' ' + sizes[i]; 
		    return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
	}
	
	function uploadImageAndInsertLink( file, editor , url ) {
		url = url || '/data/api/v1/images/upload_image_and_link.json'
	    data = new FormData();
	    	data.append("file", file);
	    $.ajax({
	        data: data,
	        type: "POST",
	        url: url,
	        cache: false,
	        contentType: false,
	        processData: false,
	        success: function (response) {	        		
	        		$.each( response, function( index , item  ) {
	        			var externalId = item.linkId;
	        			var url = '/download/images/' + externalId;
	        			editor.summernote('insertImage', url, function ($image) {
	        				
	        			  console.log("insert image ... " + externalId );
	        			 
		            	  $image.addClass('img-responsive');
		            	  $image.attr('data-external-id', externalId );
					  //$image.attr('data-shared', response.publicShared ); 
					  // console.log( $image ); 
		            });				  
				});
	        }
	    });
	}	
	
	function replaceLineBreaksToBr(str){
		if( str != null)
			str = str.replace(/(?:\r\n|\r|\n)/g, '<br />');
		
		return str;
	}
	
	function storageAvailable(type) {
	    try {
	        var storage = window[type],
	            x = '__storage_test__';
	        storage.setItem(x, x);
	        storage.removeItem(x);
	        return true;
	    }
	    catch(e) {
	        return e instanceof DOMException && (
	            // Firefox를 제외한 모든 브라우저
	            e.code === 22 ||
	            // Firefox
	            e.code === 1014 ||
	            // 코드가 존재하지 않을 수도 있기 때문에 테스트 이름 필드도 있습니다.
	            // Firefox를 제외한 모든 브라우저
	            e.name === 'QuotaExceededError' ||
	            // Firefox
	            e.name === 'NS_ERROR_DOM_QUOTA_REACHED') &&
	            // 이미 저장된 것이있는 경우에만 QuotaExceededError를 확인하십시오.
	            storage.length !== 0;
	    }
	} 
	
	extend(community.data, {
		uploadImageAndInsertLink: uploadImageAndInsertLink,
		getImageUrl : getImageUrl,
		getFormattedDate : getFormattedDate,
		getFormattedNumber : getFormattedNumber,
		getAttachmentUrl : getAttachmentThumbnailUrl,
		getAttachmentThumbnailUrl :getAttachmentThumbnailUrl,
		getUserDisplayName : getUserDisplayName ,
		getUserProfileImage : getUserProfileImage,
		bytesToSize : bytesToSize,
		storageAvailable : storageAvailable,
		replaceLineBreaksToBr : replaceLineBreaksToBr
	});
	
	console.log("community.data initialized.");
	
}(window, jQuery));

