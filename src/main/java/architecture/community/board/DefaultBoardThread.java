package architecture.community.board;

import java.util.Date;
import java.util.concurrent.atomic.AtomicInteger;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.PropertyAwareSupport;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.model.json.JsonForumMessageDeserializer;
import architecture.community.util.CommunityContextHelper;

public class DefaultBoardThread extends PropertyAwareSupport implements BoardThread {

	private long threadId;
	
	private int objectType;
	
	private long objectId;
	
	private Date creationDate;

	private Date modifiedDate;
	
	private BoardMessage latestMessage;
	
	private BoardMessage rootMessage;	

    private AtomicInteger messageCount = new AtomicInteger(-1);

	public DefaultBoardThread() {
		this.threadId = UNKNOWN_OBJECT_ID;
		this.objectType = UNKNOWN_OBJECT_TYPE;
		this.objectId = UNKNOWN_OBJECT_ID;
		this.rootMessage = null;
		this.latestMessage = null;
		this.messageCount = new AtomicInteger(-1);
	}
	
	public DefaultBoardThread(long threadId) {
		this.threadId = threadId;
		this.objectType = UNKNOWN_OBJECT_TYPE;
		this.objectId = -1L;
		this.rootMessage = null;
		this.latestMessage = null;
		this.messageCount = new AtomicInteger(-1);
	}

	public DefaultBoardThread(int objectType, long objectId, BoardMessage rootMessage) {
		this.threadId = -1L;
		this.objectType = objectType;
		this.objectId = objectId;
		this.rootMessage = rootMessage;
		this.latestMessage = null;
		boolean isNew = rootMessage.getThreadId() < 1L;
		if( isNew ){			
			this.creationDate = rootMessage.getCreationDate();
			this.modifiedDate = this.creationDate;
		}
		this.messageCount = new AtomicInteger(-1);
	}
	
	public void setMessageCount(int messageCount){
		this.messageCount.set(messageCount);
	}
	
	public int getViewCount(){
		if( threadId < 1)
			return -1;
		
		return CommunityContextHelper.getViewCountServive().getViewCount(this);		
	}
	
    public int getMessageCount()
    {
        int count = messageCount.get();
        if(count <= 0)
            return 1;
        else
            return count;
    }

    public void incrementMessageCount()
    {
        if(messageCount.get() < 0)
            messageCount.set(1);
        else
            messageCount.incrementAndGet();
    }

    public void decrementMessageCount()
    {
        if(messageCount.get() > 0)
            messageCount.decrementAndGet();
    }
    
	public long getThreadId() {
		return threadId;
	}

	public void setThreadId(long threadId) {
		this.threadId = threadId;
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

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return modifiedDate;
	}

	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	}

	public BoardMessage getLatestMessage() {
		return latestMessage;
	}

	@JsonDeserialize(using = JsonForumMessageDeserializer.class)
	public void setLatestMessage(BoardMessage latestMessage) {
		this.latestMessage = latestMessage;
	}

	public BoardMessage getRootMessage() {
		return rootMessage;
	}

	@JsonDeserialize(using = JsonForumMessageDeserializer.class)
	public void setRootMessage(BoardMessage rootMessage) {
		this.rootMessage = rootMessage;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("BoardThread [threadId=").append(threadId).append(", objectType=").append(objectType)
				.append(", objectId=").append(objectId).append(", ");
		if (creationDate != null)
			builder.append("creationDate=").append(creationDate).append(", ");
		if (modifiedDate != null)
			builder.append("modifiedDate=").append(modifiedDate).append(", ");
		if (latestMessage != null)
			builder.append("latestMessage=").append(latestMessage).append(", ");
		if (rootMessage != null)
			builder.append("rootMessage=").append(rootMessage).append(", ");
		if (messageCount != null)
			builder.append("messageCount=").append(messageCount);
		builder.append("]");
		return builder.toString();
	}

}
