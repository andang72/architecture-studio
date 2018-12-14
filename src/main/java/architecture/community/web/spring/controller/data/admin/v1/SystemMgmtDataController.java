package architecture.community.web.spring.controller.data.admin.v1;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;

import architecture.community.codeset.CodeSet;
import architecture.community.codeset.CodeSetNotFoundException;
import architecture.community.codeset.CodeSetService;
import architecture.community.exception.NotFoundException;
import architecture.community.model.Property;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.ee.service.ConfigService;
import architecture.ee.util.StringUtils;

/**
 * 시스템 관리자 API
 * @author donghyuck
 *
 */

@Controller("data-api-v1-mgmt-system-controller")
@RequestMapping("/data/api/mgmt/v1")
public class SystemMgmtDataController {

	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("codeSetService")
	private CodeSetService codeSetService;
	
	public SystemMgmtDataController() {
	}
	

	/**
	 * CODESET API 
	******************************************/
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/codeset/{group}/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<CodeSet> getCodeSetsByGroup(
			@PathVariable String group,
			@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
			@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId ){

		if (!StringUtils.isNullOrEmpty(group)) {
			return codeSetService.getCodeSets(objectType, objectId, group);
		}
		return Collections.EMPTY_LIST;
	}

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/codeset/{group}/code/{code}/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<CodeSet> getCodeSetsByGroupAndCode(
			@PathVariable String group,
			@PathVariable String code,
			@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
			@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId ){
		
		List<CodeSet> codes = Collections.EMPTY_LIST ;
		if (!StringUtils.isNullOrEmpty(group) && !StringUtils.isNullOrEmpty(code)) {
			codes = codeSetService.getCodeSets(objectType, objectId, group, code);
		}
		return codes ;
	}
	
	@RequestMapping(value = "/codeset/list.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public List<CodeSet> getCodeSets(
	    @RequestParam(value = "objectType", defaultValue = "0", required = false) Integer objectType,
	    @RequestParam(value = "objectId", defaultValue = "0", required = false) Long objectId,
	    @RequestParam(value = "codeSetId", defaultValue = "0", required = false) Integer codeSetId) { 
		if (codeSetId > 0) {
		    try {
		    		CodeSet codeset = codeSetService.getCodeSet(codeSetId);
				return codeSetService.getCodeSets(codeset);
		    } catch (CodeSetNotFoundException e) {
		    }
		}
		if (objectType == 1 && objectId > 0L) {
		    return codeSetService.getCodeSets(null);
		}
		return Collections.EMPTY_LIST;
    }
	
	@RequestMapping(value = "/codeset/save-or-update.json", method = RequestMethod.POST)
    @ResponseBody
    public CodeSet updateCodeSet(@RequestBody CodeSet codeset) {		
		if (codeset.getParentCodeSetId() == null)
		    codeset.setParentCodeSetId(-1L);			
		codeSetService.saveOrUpdate(codeset);		
		return codeset;
    }	
	

	/**
	 * CONFIG API 
	******************************************/
	
	private List<Property> getApplicationProperties(){
		List<String> propertyKeys = configService.getApplicationPropertyNames();
		List<Property> list = new ArrayList<Property>(); 
		for( String key : propertyKeys ) {
			String value = configService.getApplicationProperty(key);
			list.add(new Property( key, value ));
		}
		return list ;
	}
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/properties/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> getConfig(@RequestBody DataSourceRequest dataSourceRequest, NativeWebRequest request){ 
		return getApplicationProperties() ;
	}
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/properties/update.json", method = RequestMethod.POST)
	@ResponseBody
	public List<Property> updatePageProperties( 
			@RequestBody List<Property> newProperties, 
			NativeWebRequest request) throws NotFoundException {
 
		// update or create
		for (Property property : newProperties) {
			configService.setApplicationProperty(property.getName(), property.getValue());
		}		
		return newProperties;
	}

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/properties/delete.json", method = { RequestMethod.POST, RequestMethod.DELETE })
	@ResponseBody
	public List<Property> deletePageProperties(  
			@RequestBody List<Property> newProperties, NativeWebRequest request) throws NotFoundException {
		
		for (Property property : newProperties) {
			configService.deleteApplicationProperty(property.getName());
		}
		return getApplicationProperties();
	}
}
