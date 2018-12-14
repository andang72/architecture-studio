
package architecture.community.board;

import java.util.Date;

import architecture.community.model.ModelObjectAware;

public interface Board extends ModelObjectAware {

	//public static final int MODLE_OBJECT_TYPE = 5;
	
	public abstract long getCategoryId();
	
	public abstract long getBoardId();
	
	public abstract String getName();
	
	public abstract String getDisplayName();
	
	public abstract String getDescription();
	
	public abstract Date getCreationDate();

	public abstract void setCreationDate(Date creationDate);
	
	public abstract Date getModifiedDate();
	
	public abstract void setModifiedDate(Date modifiedDate);
	
}
