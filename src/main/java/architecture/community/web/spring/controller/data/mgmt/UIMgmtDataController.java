package architecture.community.web.spring.controller.data.mgmt;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;

import architecture.community.exception.NotFoundException;
import architecture.community.menu.MenuItem;
import architecture.community.menu.MenuService;
import architecture.community.model.Property;
import architecture.community.query.CustomQueryService;
import architecture.community.security.spring.acls.CommunityAclService;
import architecture.ee.service.ConfigService;

/**
 * Menu Data Controller for Web Management (Administrator)
 *
 *
 * @author donghyuck
 *
 */
@Controller("secure-ui-data-mgmt-controller")
@RequestMapping("/secure/data/mgmt")
public class UIMgmtDataController {

	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("communityAclService")
	private CommunityAclService communityAclService;
	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService; 
	
	@Inject
	@Qualifier("menuService")
	private MenuService menuService;
	
	
	public UIMgmtDataController() {
		
	} 
	
	
	/** ----------------------------------
	 * MENU ITEM PROPERTY API
	 * ----------------------------------- **/
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menu/items/{itemId:[\\p{Digit}]+}/properties/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> getImageProperties (
		@PathVariable Long itemId, 
		NativeWebRequest request) throws NotFoundException {
		MenuItem menuToUse = 	menuService.getMenuItemById(itemId);
		Map<String, String> properties = menuToUse.getProperties(); 
		return toList(properties);
	}

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menu/items/{itemId:[\\p{Digit}]+}/properties/update.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> updateImageProperties (
		@PathVariable Long itemId, 
		@RequestBody List<Property> newProperties,
		NativeWebRequest request) throws NotFoundException {
		MenuItem menuToUse = 	menuService.getMenuItemById(itemId);
		Map<String, String> properties = menuToUse.getProperties();   
		// update or create
		for (Property property : newProperties) {
		    properties.put(property.getName(), property.getValue().toString());
		} 
		menuService.saveOrUpdateMenuItem(menuToUse); 
		return toList(menuToUse.getProperties());
	}
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menu/items/{itemId:[\\p{Digit}]+}/properties/delete.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> deleteImageProperties (
		@PathVariable Long itemId, 
		@RequestBody List<Property> newProperties,
		NativeWebRequest request) throws NotFoundException {
		MenuItem menuToUse = 	menuService.getMenuItemById(itemId);
		Map<String, String> properties = menuToUse.getProperties();  
		for (Property property : newProperties) {
		    properties.remove(property.getName());
		}
		menuService.saveOrUpdateMenuItem(menuToUse);
		return toList(menuToUse.getProperties());
	}
	
	protected List<Property> toList(Map<String, String> properties) {
		List<Property> list = new ArrayList<Property>();
		for (String key : properties.keySet()) {
		    String value = properties.get(key);
		    list.add(new Property(key, value));
		}
		return list;
	} 
}