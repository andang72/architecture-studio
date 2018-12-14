package architecture.community.menu.dao;

import java.util.List;

import architecture.community.menu.Menu;
import architecture.community.menu.MenuItem;
import architecture.community.menu.MenuItemTreeWalker;
import architecture.community.menu.MenuNotFoundException;

public interface MenuDao {
	
	public void saveOrUpdate(Menu menu);
	
	public void delete(Menu menu); 
	
	public Menu getMenuById(long menuId);
	
	public List<Long> getAllMenuIds();	
	
	public void saveOrUpdate(MenuItem item); 
	
	public long getMenuIdByName(String name) throws MenuNotFoundException ;
	
	public MenuItem getMenuItemById(long menuItemId);
	
	public List<MenuItem> getMenuItemsByMenuId(long menuId);
	
	public List<Long> getMenuItemIds( long menuId );
	
	public MenuItemTreeWalker getTreeWalkerById(long menuId) ;
	
	public void delete(MenuItem item);
	
}
