package architecture.community.board.dao;

import java.util.Date;
import java.util.List;

import architecture.community.board.Board;
import architecture.community.board.BoardMessage;
import architecture.community.board.BoardThread;
import architecture.community.board.MessageTreeWalker;

public interface BoardDao {
	
	public abstract void createBoard(Board board);
	
	public abstract Board getBoardById(long boardId);
	
	public abstract List<Long> getAllBoardIds();
	
	public void deleteBoard(Board board);
	
	public void saveOrUpdate( Board board );

	public abstract void createBoardThread( BoardThread thread );
	
	public abstract void createBoardMessage (BoardThread thread, BoardMessage message, long parentMessageId);
	
	public abstract int getBoardThreadCount(int objectType, long objectId);	
	
	public abstract List<Long> getBoardThreadIds(int objectType, long objectId);
	
	public abstract List<Long> getBoardThreadIds(int objectType, long objectId, int startIndex, int numResults);
	
	public abstract long getLatestMessageId(BoardThread thread);
	
	public abstract List<Long> getAllMessageIdsInThread(BoardThread thread);
	
	public abstract BoardThread getBoardThreadById(long threadId);
		
	public abstract int getBoardMessageCount(int objectType, long objectId);	
	
	public abstract BoardMessage getBoardMessageById(long messageId) ;
	
	public abstract void updateBoardMessage(BoardMessage message);
	
	public abstract void updateBoardThread(BoardThread thread);
	
	public abstract void updateModifiedDate(BoardThread thread, Date date);
	
	public abstract List<Long> getMessageIds(BoardThread thread);
	
	public abstract int getMessageCount(BoardThread thread);	
	
	public abstract MessageTreeWalker getTreeWalker(BoardThread thread) ;
	
	public abstract void updateParentMessage( long messageId, long newParentId );
	
	public abstract void deleteMessage(BoardMessage message);
	
	public void deleteThread(BoardThread thread);
	
}
