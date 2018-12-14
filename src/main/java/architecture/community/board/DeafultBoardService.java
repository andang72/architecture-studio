package architecture.community.board;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.community.attachment.Attachment;
import architecture.community.attachment.AttachmentService;
import architecture.community.board.dao.BoardDao;
import architecture.community.board.event.BoardThreadEvent;
import architecture.community.comment.CommentService;
import architecture.community.i18n.CommunityLogLocalizer;
import architecture.community.model.Models;
import architecture.community.user.User;
import architecture.community.user.UserManager;
import architecture.community.util.SecurityHelper;
import architecture.ee.spring.event.EventSupport;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class DeafultBoardService extends EventSupport implements BoardService {
	
	private Logger logger = LoggerFactory.getLogger(getClass().getName());
	
	@Inject
	@Qualifier("boardDao")
	private BoardDao boardDao;
	
	@Inject
	@Qualifier("boardCache")
	private Cache boardCache;
	
	@Inject
	@Qualifier("userManager")
	private UserManager userManager;
	
	@Inject
	@Qualifier("threadCache")
	private Cache threadCache;
	
	@Inject
	@Qualifier("messageCache")
	private Cache messageCache;
	
	@Inject
	@Qualifier("messageTreeWalkerCache")
	private Cache messageTreeWalkerCache;
	
	@Inject
	@Qualifier("attachmentService")
	private AttachmentService attachmentService;
	
	@Inject
	@Qualifier("commentService")
	private CommentService commentService;
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void deleteThread(BoardThread thread) {
		
		List<Long> messages = boardDao.getAllMessageIdsInThread(thread);
		for(Long messageId : messages) {
			// delete attachment. 
			if (messageCache != null && messageCache.get( messageId) != null)
			{
				messageCache.remove( messageId );
			}
			for( Attachment attachment : attachmentService.getAttachments(Models.BOARD_MESSAGE.getObjectType(), messageId)) {
				attachmentService.removeAttachment(attachment);
			}
		}
		boardDao.deleteThread(thread);
		evictCaches(thread);
	}
		
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void deleteMessage(BoardThread thread, BoardMessage message, boolean recursive)
	{
		if( thread.getThreadId() != message.getThreadId()) {
			throw new IllegalArgumentException("Could not be deleted. It belogs to thread " + message.getThreadId() + ", and not thread " + thread.getThreadId() );
		}
		if( thread.getRootMessage().getMessageId() == message.getMessageId() ) {
			throw new IllegalArgumentException("Could not be deleted root message.");
		} 
		try { 
			BoardMessage messageToUse = getBoardMessage(message.getMessageId());
			MessageTreeWalker walker = getTreeWalker(thread);
			long newParentId = walker.getParent(messageToUse).getMessageId();
			
			// update parent message message.getMessageId(), parentId 
			boardDao.updateParentMessage(message.getMessageId(), newParentId);
			
			// delete message messageToUse , parentId 
			deleteMessage(message, recursive);
			// fix update date for thread .
			boardDao.updateModifiedDate(thread, new Date());
			
			// clear cache .. 
			if( messageTreeWalkerCache != null && messageTreeWalkerCache.get( thread.getThreadId() )  != null)
			{
				messageTreeWalkerCache.remove(thread.getThreadId());
			}
			evictCaches(thread);
			
		} catch (BoardMessageNotFoundException e) {
		}		
	}
	
	public void deleteMessage(BoardMessage message,  boolean recursive ) {
		if( message != null ) {
			
			try {
				BoardThread threadToUse = getBoardThread(message.getThreadId());	
				if(recursive) {
					if( messageTreeWalkerCache != null && messageTreeWalkerCache.get( message.getThreadId() )  != null) {
						MessageTreeWalker walker = (MessageTreeWalker) messageTreeWalkerCache.get( message.getThreadId() ).getObjectValue();
						for ( long messageId : walker.getRecursiveChildren(message)) {
							BoardMessage messageToUse = getBoardMessage(messageId);
							deleteMessage(  threadToUse , messageToUse, false);
						}
					} 
				}
				boardDao.deleteMessage(message);
				evictCaches(message);
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
			} 
		}
	}
	
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public Board createBoard(String name, String displayName, String description) {				
		
		DefaultBoard newBoard = new DefaultBoard();		
		
		if(name == null || "".equals(name.trim()))
            throw new IllegalArgumentException("Board name must be specified.");
		
		newBoard.setName(name);		
        
		if(displayName == null || "".equals(displayName.trim()))
            throw new IllegalArgumentException("Board display name must be specified.");
        
        newBoard.setDisplayName(displayName);        
        newBoard.setDescription(description);
        newBoard.setCreationDate(new Date());		
		boardDao.createBoard(newBoard);		
		return newBoard;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void updateBoard(Board board) {	
		evictCaches(board);
		boardDao.saveOrUpdate(board);
	}
	
	public boolean exist(long boardId) {
		if( boardId > 0L ) {
			try {
				getBoardById( boardId );
				return true;
			} catch (BoardNotFoundException e) {
			}
		}
		return false;
	}

	public Board getBoardById(long boardId) throws BoardNotFoundException {				
		
		Board board = getBoardInCache(boardId);		
		if( board == null && boardId > 0L ){
			try {			
				board = boardDao.getBoardById(boardId);
				updateCaches(board);
			} catch (Throwable e) {				
				throw new BoardNotFoundException(CommunityLogLocalizer.format("013003", boardId), e);
			}
		}
		return board;
	}

 
	public List<Board> getAllBoards() {
		List<Long> ids = boardDao.getAllBoardIds();
		List<Board> boards = new ArrayList<Board>(ids.size());
		for( Long id : ids )
		{
			try {
				boards.add(getBoardById(id));
			} catch (BoardNotFoundException e) {
				logger.warn(e.getMessage(), e);
			}
		}
		return boards;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void deleteBoard(Board board) {
				
	}
	
	protected Board getBoardInCache(Long boardId) {
		if (boardCache.get(boardId) != null)
			return (Board)boardCache.get(boardId).getObjectValue();
		else
			return null;
	}
	
	protected void updateCaches(Board board) {
		if (board != null) {
			if (board.getBoardId() > 0 ) {
				if (boardCache.get(board.getBoardId()) != null)
					boardCache.remove(board.getBoardId());
				boardCache.put(new Element(board.getBoardId(), board ));
			}
		}
	}
	
	protected void evictCaches(Board board){		
		boardCache.remove(Long.valueOf(board.getBoardId()));
	}


	public BoardThread createThread(int objectType, long objectId, BoardMessage rootMessage) {		
		DefaultBoardThread newThread = new DefaultBoardThread(objectType, objectId, rootMessage);
		return newThread;
	}
	
	
 
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void addThread(int objectType, long objectId, BoardThread thread) {		
		DefaultBoardThread threadToUse = (DefaultBoardThread)thread; 
		DefaultBoardMessage rootMessage = (DefaultBoardMessage)threadToUse.getRootMessage();		
		boolean isNew = rootMessage.getThreadId() < 1L ;
		if( !isNew ){
			// get exist old value..			
		}				
		// insert thread ..
		boardDao.createBoardThread(threadToUse);
		// insert message ..
		boardDao.createBoardMessage(threadToUse, rootMessage, -1L );				
		fireEvent(new BoardThreadEvent(threadToUse, BoardThreadEvent.Type.CREATED));		
	}

	public BoardMessage createMessage(int objectType, long objectId) {
		DefaultBoardMessage newMessage = new DefaultBoardMessage(objectType, objectId, SecurityHelper.ANONYMOUS);
		return newMessage;
	}

	public BoardMessage createMessage(int objectType, long objectId, User user) {
		DefaultBoardMessage newMessage = new DefaultBoardMessage(objectType, objectId, user);
		return newMessage;
	}

	public List<BoardThread> getBoardThreads(int objectType, long objectId, int startIndex, int numResults){
		List<Long> threadIds = boardDao.getBoardThreadIds(objectType, objectId, startIndex, numResults);
		List<BoardThread> list = new ArrayList<BoardThread>(threadIds.size());
		for( Long threadId : threadIds )
		{
			try {
				list.add(getBoardThread(threadId));
			} catch (BoardThreadNotFoundException e) {
				// ignore;
				logger.warn(e.getMessage(), e);
			}
		}
		return list;
	}
	
	public List<BoardThread> getBoardThreads(int objectType, long objectId) {		
		List<Long> threadIds = boardDao.getBoardThreadIds(objectType, objectId);
		List<BoardThread> list = new ArrayList<BoardThread>(threadIds.size());
		for( Long threadId : threadIds )
		{
			try {
				list.add(getBoardThread(threadId));
			} catch (BoardThreadNotFoundException e) {
				// ignore;
				logger.warn(e.getMessage(), e);
			}
		}
		return list;
	}

	
	public List<BoardMessage> getBoardMessages(int objectType, long objectId) {
		return null;
	}

	public BoardThread getBoardThread(long threadId) throws BoardThreadNotFoundException {		
		if(threadId < 0L)
            throw new BoardThreadNotFoundException(CommunityLogLocalizer.format("013004", threadId ));
		
		BoardThread threadToUse = getForumThreadInCache(threadId);
		if( threadToUse == null){
			
			try {
				threadToUse = boardDao.getBoardThreadById(threadId);
				threadToUse.setLatestMessage(new DefaultBoardMessage(boardDao.getLatestMessageId(threadToUse)));	
				((DefaultBoardThread)threadToUse).setMessageCount(boardDao.getAllMessageIdsInThread(threadToUse).size());
			} catch (Exception e) {
				throw new BoardThreadNotFoundException(CommunityLogLocalizer.format("013005", threadId ));
			}			
			try {
				BoardMessage rootMessage = threadToUse.getRootMessage();		
				BoardMessage latestMessage = threadToUse.getLatestMessage();					
				threadToUse.setRootMessage(getBoardMessage(rootMessage.getMessageId()));					
				if(latestMessage != null && latestMessage.getMessageId() > 0){
					threadToUse.setLatestMessage(getBoardMessage(latestMessage.getMessageId()));	
					threadToUse.setModifiedDate(threadToUse.getLatestMessage().getModifiedDate());
				}						
			} catch (Exception e) {
				throw new BoardThreadNotFoundException(CommunityLogLocalizer.format("013005", threadId ), e);
			}
			updateCaches(threadToUse);	
		}
		return threadToUse;
	}


	public BoardMessage getBoardMessage(long messageId) throws BoardMessageNotFoundException {
		if(messageId < 0L)
            throw new BoardMessageNotFoundException(CommunityLogLocalizer.format("013006", messageId ));
		
		BoardMessage messageToUse = getForumMessageInCache(messageId);
		if( messageToUse == null){
			try {
				messageToUse = boardDao.getBoardMessageById(messageId);			
				if( messageToUse.getUser().getUserId() > 0){
					((DefaultBoardMessage)messageToUse).setUser(userManager.getUser(messageToUse.getUser()));
				}	
				
				//int attachmentCount = attachmentService.getAttachmentCount(Models.BOARD_MESSAGE.getObjectType(), messageId);
				//messageToUse.setAttachmentCount( attachmentCount );
				
				updateCaches(messageToUse);
			} catch (Exception e) {
				throw new BoardMessageNotFoundException(CommunityLogLocalizer.format("013007", messageId ));
			}
		}
		return messageToUse;
	}

	

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void updateThread(BoardThread thread) {		
		boardDao.updateBoardThread(thread);
		evictCaches(thread);
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void updateMessage(BoardMessage message) {
		
		boardDao.updateBoardMessage(message);		
		try {
			BoardThread thread = getBoardThread(message.getThreadId());
			boardDao.updateModifiedDate(thread, message.getModifiedDate() );
			
			evictCaches(message);
			evictCaches(thread);
			
		} catch (BoardThreadNotFoundException e) {
			logger.error(e.getMessage(), e );
		}		
	}	


	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void addMessage(BoardThread thread, BoardMessage parentMessage, BoardMessage newMessage) {
		
		DefaultBoardMessage newMessageToUse = (DefaultBoardMessage)newMessage;
		if(newMessageToUse.getCreationDate().getTime() < parentMessage.getCreationDate().getTime() ){
			logger.warn(CommunityLogLocalizer.getMessage("013008"));			
			Date newDate = new Date(parentMessage.getCreationDate().getTime() + 1L);
			newMessageToUse.setCreationDate(newDate);
			newMessageToUse.setModifiedDate(newDate);
		}		
		if(thread.getThreadId() != -1L){
			newMessageToUse.setThreadId(thread.getThreadId());
		}		
		boardDao.createBoardMessage(thread, newMessageToUse, parentMessage.getMessageId());
		updateThreadModifiedDate(thread, newMessageToUse);		
		evictCaches(thread);
		
	}
	
	protected void evictCaches(BoardThread thread){				
		if (threadCache != null && threadCache.get( thread.getThreadId() ) != null)
		{
			threadCache.remove(thread.getThreadId());
		}		
		if (messageTreeWalkerCache != null && messageTreeWalkerCache.get( thread.getThreadId() ) != null)
		{
			messageTreeWalkerCache.remove(thread.getThreadId());
		}
	}
	
	protected void evictCaches(BoardMessage message){				
		if (messageCache != null && messageCache.get( message.getMessageId() ) != null)
		{
			messageCache.remove(message.getMessageId());
		}			
	}
	
	protected void updateThreadModifiedDate(BoardThread thread, BoardMessage message){
		if( message.getModifiedDate() != null){			
			thread.setModifiedDate(message.getModifiedDate());
			if (threadCache != null && threadCache.get(thread.getThreadId()) != null){
				threadCache.put(new Element(thread.getThreadId(), thread ));
			}
		}
	}
	
	protected void updateCaches(BoardThread boardThread) {
		if (boardThread != null) {
			if (boardThread.getThreadId() > 0 ) {
				if (threadCache != null && threadCache.get(boardThread.getThreadId()) != null)
					threadCache.remove(boardThread.getThreadId());
				threadCache.put(new Element(boardThread.getThreadId(), boardThread ));
			}
		}
	}
	
	protected void updateCaches(BoardMessage boardMessage) {
		if (boardMessage != null) {
			if (boardMessage.getMessageId() > 0 ) {
				if (messageCache != null && messageCache.get(boardMessage.getMessageId()) != null)
					messageCache.remove(boardMessage.getMessageId());
				messageCache.put(new Element(boardMessage.getMessageId(), boardMessage ));
			}
		}
	}
	
	protected BoardThread getForumThreadInCache(Long threadId) {
		if( threadCache != null && threadCache.get(threadId) != null)
			return (BoardThread)threadCache.get(threadId).getObjectValue();
		else
			return null;
	}
	
	protected BoardMessage getForumMessageInCache(Long messageId) {
		if( messageCache != null && messageCache.get(messageId) != null)
			return (BoardMessage)messageCache.get(messageId).getObjectValue();
		else
			return null;
	}


	public int getMessageCount(BoardThread thread) {
		return boardDao.getMessageCount(thread);
	}
	
	public int getBoardThreadCount(int objectType, long objectId) {
		return boardDao.getBoardThreadCount(objectType, objectId);
	}

	public int getBoardMessageCount(Board board) {		
		return boardDao.getBoardMessageCount(Models.BOARD.getObjectType(), board.getBoardId() );
	}
	

	public List<BoardMessage> getMessages(BoardThread thread) {		
		List<Long> messageIds = boardDao.getMessageIds(thread);
		List<BoardMessage> list = new ArrayList<BoardMessage>(messageIds.size());
		for(Long messageId : messageIds){
			try {
				list.add(getBoardMessage(messageId));
			} catch (BoardMessageNotFoundException e) {
			}
		}
		return list;
	}

	public MessageTreeWalker getTreeWalker(BoardThread thread) {
		if( messageTreeWalkerCache != null && messageTreeWalkerCache.get(thread.getThreadId()) != null)
			return (MessageTreeWalker)messageTreeWalkerCache.get(thread.getThreadId()).getObjectValue();
		
		MessageTreeWalker treeWalker = boardDao.getTreeWalker(thread);
		messageTreeWalkerCache.put(new Element(thread.getThreadId(), treeWalker ));
		return treeWalker;
	}

}
