/**
 * COMMUNITY UI PROFESSIONAL
 * 
 * dependency : kendoui professional (commercial edition)
 */
 
(function (window, $, undefined) {			
	var community = window.community = window.community || { ui : {} , data :{ model: {} }},
		extend = $.extend,
		handleAjaxError = community.ui.handleAjaxError ;
	
	
	function treelist_datasource( options ){
		options = options || {} ;
		var settings = extend(true, {}, { error: handleAjaxError } , options ); 
		return new kendo.data.TreeListDataSource(settings);
	}
	
	function treelist( renderTo, options){		
		if(!renderTo.data("kendoTreeList")){			
			 renderTo.kendoTreeList(options);
		}		
		return renderTo.data("kendoTreeList");
	}	
	
	/**
	 * Editor  
	 */
	function editor ( renderTo, options ){
		if(!renderTo.data("kendoEditor")){			
			renderTo.kendoEditor(options);
		}	
		return renderTo.data("kendoEditor");
	}
	
	function chart ( renderTo, options ){
		if(!renderTo.data("kendoChart")){			
			renderTo.kendoChart(options);
		}	
		return renderTo.data("kendoChart");
	}
	
	
	extend( community.ui , {	
		editor : editor,
		chart : chart,
		treelist : treelist,
		treelist_datasource : treelist_datasource	
	});	
	
	
}(window, jQuery));