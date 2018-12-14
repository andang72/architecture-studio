package architecture.community.board;

import java.util.List;

import architecture.community.user.User;

public interface BoardService {
		
	
	public abstract Board createBoard(String name, String displayName, String description);
	
	public abstract void updateBoard(Board board);

	public abstract void deleteBoard(Board board);
	
	public abstract Board getBoardById(long boardId) throws BoardNotFoundException ;
	
	public abstract List<Board> getAllBoards();	
	
	public abstract boolean exist (long boardId);
	
 	public abstract BoardMessage createMessage(int containerType, long containerId);
	
	public abstract BoardMessage createMessage(int containerType, long containerId, User user);
	
	
	/**
	 * containerType, containerId 에 해당하는 새로운 토픽을 생성한다.
	 * 
	 * @param containerType
	 * @param containerId
	 * @param rootMessage
	 * @return
	 */
	public abstract BoardThread createThread(int containerType, long containerId, BoardMessage rootMessage);
	
	/**
	 * containerType, containerId 에 새로운 토픽을 추가한다.
	 * 
	 * @param containerType
	 * @param containerId
	 * @param thread
	 */
	public abstract void addThread(int containerType, long containerId, BoardThread thread);
	
	/**
	 * containerType, containerId 에 등록된 모든 토픽 수를 리턴한다.
	 * 
	 * @param containerType
	 * @param containerId
	 * @return
	 */
	public abstract int getBoardThreadCount(int objectType, long objectId);		
	
	public abstract int getBoardMessageCount(Board board) ;
	
	
	public abstract List<BoardThread> getBoardThreads(int containerType, long containerId);
	
	public abstract List<BoardThread> getBoardThreads(int objectType, long objectId, int startIndex, int numResults);
	
	public abstract List<BoardMessage> getBoardMessages(int containerType, long containerId);
			
	public abstract BoardThread getBoardThread(long threadId) throws BoardThreadNotFoundException ;
	
	public abstract BoardMessage getBoardMessage(long messageId) throws BoardMessageNotFoundException ;
	
	public abstract void updateThread(BoardThread thread);
		
	public abstract void updateMessage(BoardMessage message);
	
	public abstract void addMessage(BoardThread forumthread, BoardMessage parentMessage, BoardMessage newMessage);
	
	public abstract int getMessageCount(BoardThread thread);
	
	public abstract List<BoardMessage> getMessages(BoardThread thread);
	
	public abstract MessageTreeWalker getTreeWalker(BoardThread thread);	
	
	public abstract void deleteThread(BoardThread thread) ;
			
	public abstract void deleteMessage(BoardThread thread, BoardMessage message, boolean recursive);
}
