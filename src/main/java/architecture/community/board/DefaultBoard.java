package architecture.community.board;

import java.io.Serializable;
import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.PropertyAwareSupport;
import architecture.community.model.json.JsonDateSerializer;

public class DefaultBoard extends PropertyAwareSupport implements Board , Serializable {

	private long categoryId;
	
	private long boardId;
	
	private int objectType;
	
	private long objectId;
	
	private String name;
	
	private String displayName;
			
	private String description;
	
	private Date creationDate;

	private Date modifiedDate;
	
	public DefaultBoard() {
		this.categoryId = 0;
		this.boardId = -1L;
		this.objectType = UNKNOWN_OBJECT_TYPE;
		this.objectId = -1L;
		this.creationDate = new Date();
		this.modifiedDate = creationDate;
	}
	
	public DefaultBoard(long boardId) {
		this.categoryId = 0;
		this.boardId = boardId;
		this.objectType = UNKNOWN_OBJECT_TYPE;
		this.objectId = -1L;
		this.creationDate = new Date();
		this.modifiedDate = creationDate;
	}

	public long getBoardId() {
		return boardId;
	}

	public void setBoardId(long boardId) {
		this.boardId = boardId;
	}

	public int getObjectType() {
		return objectType;
	}

	public void setObjectType(int objectType) {
		this.objectType = objectType;
	}

	public long getObjectId() {
		return objectId;
	}

	public void setObjectId(long objectId) {
		this.objectId = objectId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
        if(name == null)
        {
            throw new IllegalArgumentException("Name cannot be null");
        } else
        {
            this.name = name;
            return;
        }
	}

	public String getDisplayName() {
		return displayName;
	}

	public void setDisplayName(String displayName) {
		if(displayName == null || "".equals(displayName.trim()))
            throw new IllegalArgumentException("Display Name cannot be null");
        if(this.displayName != null && this.displayName.equals(displayName))
        {
            return;
        } else
        {
            this.displayName = displayName;
            return;
        }
	}

	public long getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(long categoryId) {
		this.categoryId = categoryId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(Date creationDate) {
        if(creationDate == null)
            throw new IllegalArgumentException("Creation date cannot be null");
        this.creationDate = creationDate;
        if(modifiedDate.compareTo(this.creationDate) == -1)
        	modifiedDate = this.creationDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return modifiedDate;
	}

	public void setModifiedDate(Date modifiedDate) {
        if(modifiedDate == null)
            throw new IllegalArgumentException("Modification date cannot be null");
        this.modifiedDate = modifiedDate;
        if(this.modifiedDate.compareTo(creationDate) == -1)
            this.modifiedDate = creationDate;
	}

	public boolean equals(Object o)
    {
        if(this == o)
            return true;
        if(!(o instanceof Board))
            return false;
        if(o == null || getClass() != o.getClass())
        {
            return false;
        } else
        {
            Board that = (Board)o;
            return this.boardId == that.getBoardId();
        }
    }

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("DefaultBoard [boardId=").append(boardId).append(", objectType=").append(objectType).append(", objectId=").append(objectId).append(", ");
		if (name != null)
			builder.append("name=").append(name).append(", ");
		if (displayName != null)
			builder.append("displayName=").append(displayName).append(", ");
		if (description != null)
			builder.append("description=").append(description).append(", ");
		if (creationDate != null)
			builder.append("creationDate=").append(creationDate).append(", ");
		if (modifiedDate != null)
			builder.append("modifiedDate=").append(modifiedDate);
		builder.append("]");
		return builder.toString();
	}

}