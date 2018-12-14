package architecture.community.board;

import java.util.Date;

import architecture.community.model.ModelObjectAware;
import architecture.community.user.User;

public interface BoardMessage extends ModelObjectAware {
	
	//public static final int MODLE_ENTITY_TYPE = 7;
	
	public abstract User getUser();
	
	public abstract long getParentMessageId();
	
	public abstract long getMessageId();	
	
	public abstract long getThreadId();
	
	public abstract String getSubject();
	
	public abstract String getBody();
	
	public abstract void setSubject(String subject);
	
	public abstract void setBody(String body);	
	
	public abstract void setKeywords(String keywords);
	
	public abstract String getKeywords(); 
	
	public abstract Date getCreationDate();

	public abstract Date getModifiedDate();	
	
	public abstract void setCreationDate(Date creationDate);

	public abstract void setModifiedDate(Date modifiedDate);	
}
