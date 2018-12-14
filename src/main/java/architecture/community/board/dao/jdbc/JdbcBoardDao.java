package architecture.community.board.dao.jdbc;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlParameterValue;

import architecture.community.board.Board;
import architecture.community.board.BoardMessage;
import architecture.community.board.BoardThread;
import architecture.community.board.DefaultBoard;
import architecture.community.board.DefaultBoardMessage;
import architecture.community.board.DefaultBoardThread;
import architecture.community.board.MessageTreeWalker;
import architecture.community.board.dao.BoardDao;
import architecture.community.i18n.CommunityLogLocalizer;
import architecture.community.model.Models;
import architecture.community.user.UserTemplate;
import architecture.community.util.LongTree;
import architecture.ee.jdbc.property.dao.PropertyDao;
import architecture.ee.jdbc.sequencer.SequencerFactory;
import architecture.ee.service.ConfigService;
import architecture.ee.spring.jdbc.ExtendedJdbcDaoSupport;
import architecture.ee.util.StringUtils;

//@Repository("boardDao")
//@MaxValue(id=ModelObjectAware.BOARD, name="BOARD")
public class JdbcBoardDao extends ExtendedJdbcDaoSupport implements BoardDao {

	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("sequencerFactory")
	private SequencerFactory sequencerFactory;

	@Inject
	@Qualifier("propertyDao")
	private PropertyDao propertyDao;
	
	private String boardPropertyTableName = "REP_BOARD_PROPERTY";
	private String boardPropertyPrimaryColumnName = "BOARD_ID";
	
	
	private final RowMapper<Board> boardMapper = new RowMapper<Board>() {		
		public Board mapRow(ResultSet rs, int rowNum) throws SQLException {			
			DefaultBoard board = new DefaultBoard(rs.getLong("BOARD_ID"));	
			board.setName(rs.getString("NAME"));
			board.setCategoryId(rs.getLong("CATEGORY_ID"));
			board.setDisplayName(rs.getString("DISPLAY_NAME"));
			board.setDescription(rs.getString("DESCRIPTION"));
			board.setCreationDate(rs.getDate("CREATION_DATE"));
			board.setModifiedDate(rs.getDate("MODIFIED_DATE"));		
			return board;
		}		
	};
	
	public void createBoard(Board board) {		
		if( board == null)
			throw new IllegalArgumentException();
		
		if( board.getBoardId() <= 0 ){
			((DefaultBoard)board).setBoardId(getNextBoardId());
		}		
		Date now = new Date();		
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.CREATE_BOARD").getSql(),
				new SqlParameterValue(Types.NUMERIC, board.getBoardId()),
				new SqlParameterValue(Types.VARCHAR, board.getName()),
				new SqlParameterValue(Types.VARCHAR, StringUtils.isNullOrEmpty(board.getDisplayName()) ? board.getName() : board.getDisplayName()),
				new SqlParameterValue(Types.VARCHAR, board.getDescription()),
				new SqlParameterValue(Types.TIMESTAMP, board.getCreationDate() != null ? board.getCreationDate() : now ),
				new SqlParameterValue(Types.TIMESTAMP, board.getModifiedDate() != null ? board.getModifiedDate() : now )
		);
		setBoardProperties(board.getBoardId(), board.getProperties());	
	}
	
	public Map<String, String> getBoardProperties(long boardId) {
		return propertyDao.getProperties(boardPropertyTableName, boardPropertyPrimaryColumnName, boardId);
	}

	public void deleteBoardProperties(long boardId) {
		propertyDao.deleteProperties(boardPropertyTableName, boardPropertyPrimaryColumnName, boardId);
	}
	
	public void setBoardProperties(long boardId, Map<String, String> props) {
		propertyDao.updateProperties(boardPropertyTableName, boardPropertyPrimaryColumnName, boardId, props);
	}

		
	public long getNextBoardId(){		
		return sequencerFactory.getNextValue(Models.BOARD.getObjectType(), Models.BOARD.name());
	}
	
	@Override
	public void saveOrUpdate(Board board) {
		if( board.getBoardId() > 0 ) {
			// update 	
			Date now = new Date();
			board.setModifiedDate(now);		
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.UPDATE_BOARD").getSql(), 
					new SqlParameterValue(Types.VARCHAR, 	board.getName() ),
					new SqlParameterValue(Types.VARCHAR, 	StringUtils.isNullOrEmpty(board.getDisplayName()) ? board.getName() : board.getDisplayName()),
					new SqlParameterValue(Types.VARCHAR, 	board.getDescription()),
					new SqlParameterValue(Types.TIMESTAMP, 	board.getModifiedDate() ),	
					new SqlParameterValue(Types.NUMERIC, 	board.getBoardId() )
			);
			if(!board.getProperties().isEmpty())
				setBoardProperties(board.getBoardId(), board.getProperties());
			
		}else {
			// insert	
			createBoard(board);
		}
	}
	
	

	
	public Board getBoardById(long boardId) {
		if (boardId <= 0L) {
			return null;
		}		
		Board board = null;
		try {
			board = getExtendedJdbcTemplate().queryForObject( getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_BY_ID").getSql(),  boardMapper,  new SqlParameterValue(Types.NUMERIC, boardId));
		} catch (IncorrectResultSizeDataAccessException e) {
			if (e.getActualSize() > 1) {
				logger.warn(CommunityLogLocalizer.format("013002", boardId));
				throw e;
			}
		} catch (DataAccessException e) {
			logger.error(CommunityLogLocalizer.format("013001", boardId), e);
		}
		return board;
	}
	
	public List<Long> getAllBoardIds(){
		return getExtendedJdbcTemplate().queryForList(getBoundSql("COMMUNITY_BOARD.SELECT_ALL_BOARD_IDS").getSql(), Long.class);
	}


	public void deleteBoard(Board board) {
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.DELETE_BOARD").getSql(), new SqlParameterValue(Types.NUMERIC, board.getBoardId() ) );
	}
	

	private final RowMapper<BoardThread> threadMapper = new RowMapper<BoardThread>() {	
		
		public BoardThread mapRow(ResultSet rs, int rowNum) throws SQLException {			
			DefaultBoardThread thread = new DefaultBoardThread(rs.getLong("THREAD_ID"));			
			thread.setObjectType(rs.getInt("OBJECT_TYPE"));
			thread.setObjectId(rs.getLong("OBJECT_ID"));
			thread.setRootMessage(  new DefaultBoardMessage( rs.getLong("ROOT_MESSAGE_ID") ) );
			thread.setCreationDate(rs.getTimestamp("CREATION_DATE"));
			thread.setModifiedDate(rs.getTimestamp("MODIFIED_DATE"));		
			return thread;
		}
		
	};

	private final RowMapper<BoardMessage> messageMapper = new RowMapper<BoardMessage>() {	

		public BoardMessage mapRow(ResultSet rs, int rowNum) throws SQLException {			
			DefaultBoardMessage message = new DefaultBoardMessage(rs.getLong("MESSAGE_ID"));		
			message.setParentMessageId(rs.getLong("PARENT_MESSAGE_ID"));
			message.setThreadId(rs.getLong("THREAD_ID"));
			message.setObjectType(rs.getInt("OBJECT_TYPE"));
			message.setObjectId(rs.getLong("OBJECT_ID"));
			message.setUser(new UserTemplate(rs.getLong("USER_ID")));
			message.setSubject(rs.getString("SUBJECT"));
			message.setBody(rs.getString("BODY"));
			message.setKeywords(rs.getString("KEYWORDS"));
			message.setCreationDate(rs.getTimestamp("CREATION_DATE"));
			message.setModifiedDate(rs.getTimestamp("MODIFIED_DATE"));		
			return message;
		}
		
	};
	
	public long getNextThreadId(){
		logger.debug("next id for {}, {}", Models.BOARD_THREAD.getObjectType(), Models.BOARD_THREAD.name() );
		return sequencerFactory.getNextValue(Models.BOARD_THREAD.getObjectType(), Models.BOARD_THREAD.name());
	}	
	
	public long getNextMessageId(){
		logger.debug("next id for {}, {}", Models.BOARD_MESSAGE.getObjectType(), Models.BOARD_MESSAGE.name() );
		return sequencerFactory.getNextValue(Models.BOARD_MESSAGE.getObjectType(), Models.BOARD_MESSAGE.name());
	}	
	
	
	public List<Long> getBoardThreadIds(int objectType, long objectId, int startIndex, int numResults){
		return getExtendedJdbcTemplate().query(
				getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				startIndex, 
				numResults, 
				Long.class, 
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
		);
	}
	
	public List<Long> getBoardThreadIds(int objectType, long objectId){
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
				);
	}
	
	public long getLatestMessageId(BoardThread thread){
		try
        {
            return getExtendedJdbcTemplate().queryForObject(
            		getBoundSql("COMMUNITY_BOARD.SELECT_LATEST_BOARD_MESSAGE_ID_BY_THREAD_ID").getSql(), 
            		Long.class,
            		new SqlParameterValue(Types.NUMERIC, thread.getThreadId() ) );
        }
        catch(IncorrectResultSizeDataAccessException e)
        {
            logger.error(CommunityLogLocalizer.format("013009", thread.getThreadId() ), e );
        }
        return -1L;		
	}
	
	public List<Long> getAllMessageIdsInThread(BoardThread thread){
		return getExtendedJdbcTemplate().queryForList(
			getBoundSql("COMMUNITY_BOARD.SELECT_ALL_BOARD_MESSAGE_IDS_BY_THREAD_ID").getSql(), 
			Long.class,
			new SqlParameterValue(Types.NUMERIC, thread.getThreadId() )
		);		
	}
	
	public void createBoardThread(BoardThread thread) {		
		DefaultBoardThread threadToUse = (DefaultBoardThread)thread;		
		threadToUse.setThreadId(getNextThreadId());		
		
		if( threadToUse.getRootMessage().getMessageId() <= 0 ){
			DefaultBoardMessage messageToUse = (DefaultBoardMessage)thread.getRootMessage();		
			messageToUse.setMessageId(getNextMessageId());		
		}
		
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.CREATE_BOARD_THREAD").getSql(),
				new SqlParameterValue(Types.NUMERIC, threadToUse.getThreadId() ),
				new SqlParameterValue(Types.NUMERIC, threadToUse.getObjectType()),
				new SqlParameterValue(Types.NUMERIC, threadToUse.getObjectId()),				
				new SqlParameterValue(Types.NUMERIC, threadToUse.getRootMessage().getMessageId()),				
				new SqlParameterValue(Types.TIMESTAMP, threadToUse.getCreationDate() ),
				new SqlParameterValue(Types.TIMESTAMP, threadToUse.getModifiedDate() )
		);
	}
	
	public void createBoardMessage (BoardThread thread, BoardMessage message, long parentMessageId) {
			
		DefaultBoardMessage messageToUse = (DefaultBoardMessage) message;
		if(messageToUse.getCreationDate() == null )
		{
			Date now = new Date();	
			messageToUse.setCreationDate(now);
			messageToUse.setModifiedDate(now);
		}	
		
		if(messageToUse.getMessageId() == -1L || messageToUse.getMessageId() == 0L){
			messageToUse.setMessageId(getNextMessageId());
		}
		
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.CREATE_BOARD_MESSAGE").getSql(),
				new SqlParameterValue(Types.NUMERIC, messageToUse.getMessageId() ),
				new SqlParameterValue(Types.NUMERIC, parentMessageId),
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId()),
				new SqlParameterValue(Types.NUMERIC, thread.getObjectType()),
				new SqlParameterValue(Types.NUMERIC, thread.getObjectId()),
				new SqlParameterValue(Types.NUMERIC, messageToUse.getUser().getUserId()),
				new SqlParameterValue(Types.VARCHAR, messageToUse.getKeywords()),
				new SqlParameterValue(Types.VARCHAR, messageToUse.getSubject()),
				new SqlParameterValue(Types.VARCHAR, messageToUse.getBody()),
				new SqlParameterValue(Types.TIMESTAMP, messageToUse.getCreationDate() ),
				new SqlParameterValue(Types.TIMESTAMP, messageToUse.getModifiedDate() )
		);	
	}

	
	public void deleteThread(BoardThread thread) {
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.DELETE_BOARD_MESSAGE_BY_THREAD_ID").getSql(),
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId() ));
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.DELETE_BOARD_THREAD").getSql(),
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId() ));		
	}
	
	public void deleteMessage(BoardMessage message) {
		
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.DELETE_BOARD_MESSAGE").getSql(),
				new SqlParameterValue(Types.NUMERIC, message.getMessageId() ));
		
	}
	
	public BoardThread getBoardThreadById(long threadId) {
		BoardThread thread = null;
		if (threadId <= 0L) {
			return thread;
		}		
		try {
			thread = getExtendedJdbcTemplate().queryForObject(getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_BY_ID").getSql(), 
					threadMapper, 
					new SqlParameterValue(Types.NUMERIC, threadId ));
		} catch (DataAccessException e) {
			logger.error(CommunityLogLocalizer.format("013005", threadId), e);
		}
		return thread;
	}
	
	public BoardMessage getBoardMessageById(long messageId) {
		BoardMessage message = null;
		if (messageId <= 0L) {
			return message;
		}		
		try {
			message = getExtendedJdbcTemplate().queryForObject(getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_MESSAGE_BY_ID").getSql(), 
					messageMapper, 
					new SqlParameterValue(Types.NUMERIC, messageId ));
		} catch (DataAccessException e) {
			logger.error(CommunityLogLocalizer.format("013007", messageId), e);
		}
		return message;
	}

	public void updateBoardThread(BoardThread thread) {
		Date now = new Date();
		thread.setModifiedDate(now);		
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.UPDATE_BOARD_THREAD").getSql(), 
				new SqlParameterValue(Types.VARCHAR, thread.getRootMessage().getMessageId()),
				new SqlParameterValue(Types.TIMESTAMP, thread.getModifiedDate() ),	
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId())
		);
	}
	
	public void updateBoardMessage(BoardMessage message) {
		Date now = new Date();
		message.setModifiedDate(now);		
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.UPDATE_BOARD_MESSAGE").getSql(), 
				new SqlParameterValue(Types.VARCHAR, message.getKeywords() ),
				new SqlParameterValue(Types.VARCHAR, message.getSubject() ),
				new SqlParameterValue(Types.VARCHAR, message.getBody()),
				new SqlParameterValue(Types.TIMESTAMP, message.getModifiedDate() ),	
				new SqlParameterValue(Types.NUMERIC, message.getMessageId() )
		);
	}
 
	public void updateModifiedDate(BoardThread thread, Date date) {
		thread.setModifiedDate(date);	
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.UPDATE_BOARD_THREAD_MODIFIED_DATE").getSql(), 
				new SqlParameterValue(Types.TIMESTAMP, date ),	
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId() )
		);
	}

	@Override
	public int getBoardThreadCount(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForObject(
			getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_COUNT_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
			Integer.class,
			new SqlParameterValue(Types.NUMERIC, objectType ),
			new SqlParameterValue(Types.NUMERIC, objectId )
			);
	}

	@Override
	public List<Long> getMessageIds(BoardThread thread) {
		
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_MESSAGE_IDS_BY_THREAD_ID").getSql(), Long.class,
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId() )
				);
	}

	@Override
	public int getMessageCount(BoardThread thread) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_MESSAGE_COUNT_BY_THREAD_ID").getSql(), 
				Integer.class,
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId() )
		);
	}	
	
	public int getBoardMessageCount(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_MESSAGE_COUNT_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId)
		);
	}
	
	public MessageTreeWalker getTreeWalker(BoardThread thread) {	
		
		final LongTree tree = new LongTree(thread.getRootMessage().getMessageId(), getMessageCount(thread));
		getExtendedJdbcTemplate().query(getBoundSql("COMMUNITY_BOARD.SELECT_BOARD_THREAD_MESSAGES_BY_THREAD_ID").getSql(), 
				new RowCallbackHandler() {
					public void processRow(ResultSet rs) throws SQLException {
						long messageId = rs.getLong(1);
						long parentMessageId = rs.getLong(2);
						tree.addChild(parentMessageId, messageId);						
					}}, 
				new SqlParameterValue(Types.NUMERIC, thread.getThreadId() ));
		
		return new MessageTreeWalker( thread.getThreadId(), tree);
	}

	@Override
	public void updateParentMessage(long newParentId, long oldParentId) {
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_BOARD.UPDATE_PARENT_MESSAGE_ID").getSql(), 
				new SqlParameterValue(Types.NUMERIC, newParentId ),
				new SqlParameterValue(Types.NUMERIC, oldParentId)
		);
		
	}

	
}
