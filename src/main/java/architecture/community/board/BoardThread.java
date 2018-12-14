package architecture.community.board;

import java.util.Date;

import architecture.community.model.ModelObjectAware;

public interface BoardThread extends ModelObjectAware {
	
	//public static final int MODLE_ENTITY_TYPE = 6;
	
	public long getThreadId() ;

	public Date getCreationDate();

	public void setCreationDate(Date creationDate);

	public Date getModifiedDate() ;

	public void setModifiedDate(Date modifiedDate);

	public BoardMessage getLatestMessage();

	public void setLatestMessage(BoardMessage latestMessage);

	public BoardMessage getRootMessage() ;

	public void setRootMessage(BoardMessage rootMessage) ;
	
}
