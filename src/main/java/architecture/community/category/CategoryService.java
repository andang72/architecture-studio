package architecture.community.category;

import java.util.List;

import architecture.community.board.Board;
import architecture.community.page.Page;
import architecture.community.user.User;

public interface CategoryService {
 
	public Category getCategory(long categoryId) throws CategoryNotFoundException ; 
	
	public Category getCategory(Board board);
	
	public Category getCategory(Page page) ; 
	
	public void saveOrUpdate(Category category);
	
	public List<Board> getBoards(Category category, User user);
	
}
