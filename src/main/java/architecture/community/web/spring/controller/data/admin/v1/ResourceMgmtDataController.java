package architecture.community.web.spring.controller.data.admin.v1;

import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import javax.inject.Inject;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

import architecture.community.exception.NotFoundException;
import architecture.community.menu.Menu;
import architecture.community.menu.MenuAlreadyExistsException;
import architecture.community.menu.MenuItem;
import architecture.community.menu.MenuItemNotFoundException;
import architecture.community.menu.MenuNotFoundException;
import architecture.community.menu.MenuService;
import architecture.community.query.CustomQueryService;
import architecture.community.query.ParameterValue;
import architecture.community.web.model.ItemList;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.community.web.model.json.Result;

/**
 *	UI컴포넌트 관리자 API
 *
 *	<p>MENU</p> 
 *	<p>MENU</p> 
 * 
 * 
 * @author donghyuck
 * 
 */

@Controller("data-api-v1-mgmt-ui-controller")
@RequestMapping("/data/api/mgmt/v1/ui")
public class ResourceMgmtDataController {

	private Logger logger = LoggerFactory.getLogger(getClass());
	
	@Inject
	@Qualifier("menuService")
	private MenuService menuService;
	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	public ResourceMgmtDataController() {
	}

	
	
	
	
	/**
	 * MENU API 
	******************************************/
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/list.json", method = { RequestMethod.POST, RequestMethod.GET})
	@ResponseBody
	public ItemList getAllMenus (
		@RequestBody DataSourceRequest dataSourceRequest,
		NativeWebRequest request) throws NotFoundException {		
		dataSourceRequest.setStatement("COMMUNITY_UI.SELECT_MENU_IDS_BY_REQUEST");
		List<Long> menuIds = customQueryService.list(dataSourceRequest, Long.class);
		List<Menu> menus = new ArrayList<Menu>(menuIds.size());
		for( Long menuId : menuIds ) {
			menus.add(menuService.getMenuById(menuId));
		}		
		return new ItemList(menus, menus.size());	
	}
	

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/create.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Result createMenu(@RequestBody Menu newMenu, NativeWebRequest request) throws MenuNotFoundException, MenuAlreadyExistsException { 
		menuService.createMenu(newMenu.getName(), newMenu.getDescription());
		return Result.newResult();
    }

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/save-or-update.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Result saveOrUpdateMenu(@RequestBody Menu newMenu, NativeWebRequest request) throws MenuNotFoundException, MenuAlreadyExistsException { 
		Menu menu = newMenu ;
		if( newMenu.getMenuId() > 0 ) {
			menu = menuService.getMenuById(newMenu.getMenuId());		
			if (!org.apache.commons.lang3.StringUtils.equals(newMenu.getName(), menu.getName())) {
				menu.setName(newMenu.getName());
			} 
			if (!org.apache.commons.lang3.StringUtils.equals(newMenu.getDescription(), menu.getDescription())) {
				menu.setDescription(newMenu.getDescription());
			}
		}
		menuService.saveOrUpdateMenu(menu);
		return Result.newResult();
    }
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/delete.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Result deleteMenu(@RequestBody Menu menu, NativeWebRequest request) throws MenuNotFoundException, MenuAlreadyExistsException {  
		menuService.deleteMenu(menu); 
		return Result.newResult();
    }	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/{menuId}/get.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Menu getMenu(@PathVariable Long menuId, NativeWebRequest request) throws MenuNotFoundException { 
		return menuService.getMenuById(menuId);
    }
	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/{menuId}/items/list.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public ItemList getMenuItems(
    		@PathVariable Long menuId, 
    		@RequestParam(value = "widget", defaultValue = "", required = false) String widget,
    		@RequestBody DataSourceRequest dataSourceRequest,
    		NativeWebRequest request) throws NotFoundException {		
    		
		Menu menu = menuService.getMenuById(menuId);   
		dataSourceRequest.getParameters().add(  new ParameterValue(1, "MENU_ID", Types.NUMERIC, menu.getMenuId() ) ) ;
		dataSourceRequest.setStatement("COMMUNITY_UI.SELECT_MENU_ITEM_IDS_BY_MENU_ID_AND_REQUEST");
    		List<Long> itemIds = customQueryService.list(dataSourceRequest, Long.class);
    		List<MenuItem> items = new ArrayList<MenuItem>(itemIds.size());
    		for( Long itemId : itemIds ) {
    			MenuItem item = menuService.getMenuItemById(itemId);
    			if(StringUtils.isNotEmpty(widget) && StringUtils.equals("treelist", widget)) {
    				if( item.getParentMenuItemId() != null && item.getParentMenuItemId() < 1 )
    					item.setParentMenuItemId(null);
    			}
    			items.add(item);
    		}
    		return new ItemList(items, items.size());	
    }
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/{menuId}/items/create.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Result createMenuItem(@PathVariable Long menuId, @RequestBody MenuItem newMenuItem, NativeWebRequest request) throws MenuNotFoundException, MenuAlreadyExistsException { 
		
		Menu menu = menuService.getMenuById(menuId);	
		if( newMenuItem.getMenuId() != menu.getMenuId()) {
			newMenuItem.setMenuId(menu.getMenuId());
		}
		menuService.saveOrUpdateMenuItem(newMenuItem);
		Result r = Result.newResult();
		return Result.newResult();
    }
	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/{menuId}/items/save-or-update.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Result saveOrUpdateMenuItem(@PathVariable Long menuId, @RequestBody MenuItem newMenuItem, NativeWebRequest request) throws MenuNotFoundException, MenuAlreadyExistsException, MenuItemNotFoundException { 
		
		Menu menu = menuService.getMenuById(menuId);
		MenuItem menuItem ;
		if( newMenuItem.getMenuItemId() > 0 )
		{
			menuItem = menuService.getMenuItemById(newMenuItem.getMenuItemId());	 
			if (!org.apache.commons.lang3.StringUtils.equals(newMenuItem.getName(), menuItem.getName())) {
				menuItem.setName(newMenuItem.getName());
			} 
			if (!org.apache.commons.lang3.StringUtils.equals(newMenuItem.getDescription(), menuItem.getDescription())) {
				menuItem.setDescription(newMenuItem.getDescription());
			}
			if (!org.apache.commons.lang3.StringUtils.equals(newMenuItem.getLocation(), menuItem.getLocation())) {
				menuItem.setLocation(newMenuItem.getLocation());
			}
			if (newMenuItem.getParentMenuItemId()!= menuItem.getParentMenuItemId()) {
				menuItem.setParentMenuItemId(newMenuItem.getParentMenuItemId());
			}
			if (newMenuItem.getSortOrder() != menuItem.getSortOrder()) {
				menuItem.setSortOrder(newMenuItem.getSortOrder());
			}
			menuItem.setPage(newMenuItem.getPage());
			menuItem.setRoles(newMenuItem.getRoles());
			
		}else {
			menuItem = newMenuItem ;
			if( newMenuItem.getMenuId() != menu.getMenuId())
				newMenuItem.setMenuId(menu.getMenuId());
		}
		menuService.saveOrUpdateMenuItem(menuItem);
		menuService.refresh(menu);
		return Result.newResult(); 
	}
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/menus/{menuId}/items/delete.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public Result deleteMenuItem(@PathVariable Long menuId, @RequestBody MenuItem newMenuItem, NativeWebRequest request) throws MenuNotFoundException, MenuAlreadyExistsException, MenuItemNotFoundException { 
		Menu menu = menuService.getMenuById(menuId);	 
		if( newMenuItem.getMenuItemId() > 0 )
		{
			MenuItem menuItem = menuService.getMenuItemById(newMenuItem.getMenuItemId());	
			menuService.deleteMenuItem(menuItem);
			menuService.refresh(menu);
		}
		return Result.newResult(); 
	}	
	
	
}
