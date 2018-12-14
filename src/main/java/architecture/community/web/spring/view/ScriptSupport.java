package architecture.community.web.spring.view;

import java.io.IOException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpInputMessage;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import architecture.community.user.User;
import architecture.community.util.SecurityHelper;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.ee.util.StringUtils;

public abstract class ScriptSupport {

	protected Logger log = LoggerFactory.getLogger(getClass());
	
	protected boolean isMultipartHttpServletRequest(HttpServletRequest request) {
		if (request instanceof MultipartHttpServletRequest ) {
			return true;
		}
		return false;
	}
	
	protected MultipartHttpServletRequest getMultipartHttpServletRequest(HttpServletRequest request) {
		return (MultipartHttpServletRequest) request;
	}
	
	protected User getUser() {
		return SecurityHelper.getUser();
	}
	
	protected boolean isUserInRole(String roles) {
		return SecurityHelper.isUserInRole(roles);
	}
	
	protected DataSourceRequest getDataSourceRequest(HttpServletRequest request) {
		return getRequestBodyObject (DataSourceRequest.class, request );
	}
	
	protected <T> T getRequestBodyObject(Class<T> requiredType, HttpServletRequest request) {
		HttpInputMessage inputMessage = new ServletServerHttpRequest(request);
        MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
        try {
			return  (T) converter.read(requiredType, inputMessage );
		
        } catch (IOException e) {
			log.warn("error : {}", e);
			return null;
		}
	} 
	
	public String getProperty( Map<String, String> properties, String name, String defaultValue) {
		return StringUtils.defaultString( properties.get( name ), defaultValue );
	}
	
	public Boolean getBooleanProperty( Map<String, String> properties , String key, Boolean defaultValue ) {
		String value = properties.get(key);
		try {
			return Boolean.parseBoolean(value);
		} catch (Exception e) { } 
		return defaultValue;
	}
	
	public Long getLongProperty( Map<String, String> properties , String key, Long defaultValue ) {
		String value = properties.get(key);
		try {
			return Long.parseLong(value);
		} catch (Exception e) { } 
		return defaultValue;
	}	
	
}
