package dashboard.script
 
 /** common package import here! */
import java.util.Map;
import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import architecture.community.web.util.ParamUtils;
import architecture.community.web.util.ServletUtils;
import architecture.community.util.SecurityHelper;

/** custom package import here! */
import architecture.community.query.CustomQueryService;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.ee.util.NumberUtils;
import architecture.community.page.Page; 

import org.apache.commons.lang3.StringUtils;
	
/**
* Script Index Page View
*/
public class IndexView extends architecture.community.web.spring.view.AbstractScriptView  {

	
 	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	public IndexView() { 
		
	} 

	protected void renderMergedOutputModel(
		Map<String, Object> model, 
		HttpServletRequest request, 
		HttpServletResponse response) throws Exception { 
		

		if (log.isDebugEnabled()) {
			log.debug("Rendering view {} with model '{}'", getClass().getName(), model );
		}
		
		Page page = model.get("__page");
		Map<String, String> variables = model.get("__variables");
		boolean preview = ParamUtils.getBooleanParameter(request, "preview", false);
		
		String view = page.getTemplate();
		if (StringUtils.endsWith(view, ".jsp")) {
			view = StringUtils.removeEnd(view, ".jsp");	
		} 
		
		//dispatch(request, response, "/display/pages/access_analytics.html");
		
		if(SecurityHelper.isUserInRole("ROLE_OPERATOR")) {
			redirect(request, response, ServletUtils.getContextPath(request) + "/display/pages/operation_status.html");
		} else if(SecurityHelper.isUserInRole("ROLE_PROFESSOR")) {
			redirect(request, response, ServletUtils.getContextPath(request) + "/display/pages/operation_status.html");
		} else {
			redirect(request, response, ServletUtils.getContextPath(request) + "/display/pages/operation_status.html");
		} 
		
	} 

}