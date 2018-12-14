package architecture.community.web.spring.freemarker;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.web.servlet.view.freemarker.FreeMarkerView;

import freemarker.ext.beans.BeansWrapper;
import freemarker.template.Template;
import freemarker.template.TemplateHashModel;
import freemarker.template.TemplateModelException;

public class CommunityFreeMarkerView extends FreeMarkerView {
	
	
	protected void exposeHelpers(Map<String, Object> model, HttpServletRequest request) throws Exception {
		BeansWrapper wrapper = (BeansWrapper)getObjectWrapper();
		populateStatics(wrapper, model);
	}
	

	/**
	 * 모든 freemarker 템플릿에서 사용하게될 유틸리티들을 정의한다.
	 * 
	 * @param wrapper
	 * @param model
	 */
	public void populateStatics(BeansWrapper wrapper, Map<String, Object> model){
		/**
		try {
			TemplateHashModel enumModels = wrapper.getEnumModels();
			try {

			} catch (Exception e) {
				
			}
			model.put("enums", wrapper.getEnumModels());
		} catch (UnsupportedOperationException e) {
		}
		**/
		
		//model.put("page", new Page());
		
		/**
		 * 정적 Util / Helper 클래스들을 추가하여 ftl 파일에서 쉽게 필요한 유틸리티들을 사용할 수 있도록 한다. 
		 */
		TemplateHashModel staticModels = wrapper.getStaticModels();
		try {	
			model.put("ServletUtils",	staticModels.get("architecture.community.web.util.ServletUtils"));
			model.put("SecurityHelper",	staticModels.get("architecture.community.util.SecurityHelper"));
			model.put("CommunityContextHelper",	staticModels.get("architecture.community.util.CommunityContextHelper"));
			model.put("WebApplicationContextUtils",	staticModels.get("org.springframework.web.context.support.WebApplicationContextUtils"));	
			
		} catch (TemplateModelException e) {
			
		}			
		model.put("statics", wrapper.getStaticModels());			
	}


	@Override
	protected Template getTemplate(String name, Locale locale) throws IOException {
		return super.getTemplate(name, locale);
	}
}
