package architecture.community.category;

import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.community.board.Board;
import architecture.community.board.BoardNotFoundException;
import architecture.community.board.BoardService;
import architecture.community.category.dao.CategoryDao;
import architecture.community.page.Page;
import architecture.community.query.CustomQueryService;
import architecture.community.query.ParameterValue;
import architecture.community.security.spring.acls.CommunityAclService;
import architecture.community.security.spring.acls.JdbcCommunityAclService.PermissionsBundle;
import architecture.community.user.User;
import architecture.community.util.SecurityHelper;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class CommunityCategoryService implements CategoryService {

	@Inject
	@Qualifier("categoryDao")
	private CategoryDao categoryDao;
    
	@Inject
	@Qualifier("categoryCache")
	private Cache categoryCache;

	@Inject
	@Qualifier("boardService")
	private BoardService boardService;
	
	@Inject
	@Qualifier("communityAclService")
	private CommunityAclService communityAclService;
	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	public Category getCategory(long categoryId) throws CategoryNotFoundException {
		Category category = null;
		if (categoryCache.get(categoryId) != null) {
			category = (Category) categoryCache.get(categoryId).getObjectValue();
		}
		if (category == null) {
			category = categoryDao.load(categoryId);
			updateCache(category);
		}
		return category;
	}
	

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdate(Category category) {	 
		categoryDao.saveOrUpdate(category); 
		if (categoryCache.get(category.getCategoryId()) != null) {
			categoryCache.remove(category.getCategoryId());
		}
	}
	
	private void updateCache(Category category) {
		categoryCache.put(new Element(category.getCategoryId(), category));
	}

	public List<Board> getBoards(Category category, User user) {
		ArrayList<ParameterValue> values = new ArrayList<ParameterValue>();	
		values.add(new ParameterValue(1, "CATEGORY_ID", Types.NUMERIC, category.getCategoryId()));
		List<Long> ids = customQueryService.list("COMMUNITY_CS.SELECT_BOARD_IDS_BY_CATEGORY", values, Long.class);
		List<Board> list = new ArrayList<Board>();
		for( Long boardId : ids ) {
			PermissionsBundle bundle = communityAclService.getPermissionBundle(SecurityHelper.getAuthentication(), Board.class, boardId );	
			if( bundle.isAdmin() || bundle.isRead() || bundle.isWrite() )
			{
				try {
					list.add( boardService.getBoardById(boardId));
				} catch (BoardNotFoundException e) {
				}
			}
		}
		return list;
	}

	public Category getCategory(Board board) {
		
		long categoryId = board.getCategoryId();
		if( categoryId > 0) {
			try {
				return getCategory(categoryId);
			} catch (CategoryNotFoundException e) {
			}
		}
		return null;
	}
	
	public Category getCategory(Page page) {
		Object val = page.getProperties().get("categoryId");
		long categoryId = 0 ;
		if( val != null ) {
			categoryId = Long.parseLong(val.toString());
		}
		if( categoryId > 0) {
			try {
				return getCategory(categoryId);
			} catch (CategoryNotFoundException e) {
			}
		}
		return null;
	}
}
