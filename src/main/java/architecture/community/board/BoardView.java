package architecture.community.board;

import java.io.Serializable;
import java.util.Date;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.json.JsonDateSerializer;

public class BoardView implements Board , Serializable {
	
	@JsonIgnore
	private Board board;
	
	private int totalThreadCount = 0;
	
	private int totalViewCount = 0;
	
	private int totalMessage = 0;
	
	
	private boolean writable = false ;	
	private boolean readable = false ;
	private boolean createThreadMessage = false;
	private boolean createThread = false;
	private boolean createAttachement = false ;
	private boolean readComment = false;
	private boolean createComment = false;
	private boolean createImage = false;
	
	public BoardView(Board board) {
		this.board = board;
	}
	
	
	@JsonGetter
	public boolean isWritable() {
		return writable;
	}


	@JsonIgnore
	public void setWritable(boolean writable) {
		this.writable = writable;
	}


	@JsonGetter
	public boolean isReadable() {
		return readable;
	}


	@JsonIgnore
	public void setReadable(boolean readable) {
		this.readable = readable;
	}


	@JsonGetter
	public boolean isCreateAttachement() {
		return createAttachement;
	}


	@JsonIgnore
	public void setCreateAttachement(boolean createAttachement) {
		this.createAttachement = createAttachement;
	}


	@JsonGetter
	public boolean isReadComment() {
		return readComment;
	}


	@JsonIgnore
	public void setReadComment(boolean readComment) {
		this.readComment = readComment;
	}


	@JsonGetter
	public boolean isCreateComment() {
		return createComment;
	}


	@JsonIgnore
	public void setCreateComment(boolean createComment) {
		this.createComment = createComment;
	}


	@JsonGetter
	public boolean isCreateThreadMessage() {
		return createThreadMessage;
	}


	@JsonIgnore
	public void setCreateThreadMessage(boolean createThreadMessage) {
		this.createThreadMessage = createThreadMessage;
	}


	@JsonGetter
	public boolean isCreateThread() {
		return createThread;
	}


	@JsonIgnore
	public void setCreateThread(boolean createThread) {
		this.createThread = createThread;
	}


	@JsonGetter
	public boolean isCreateImage() {
		return createImage;
	}


	@JsonIgnore
	public void setCreateImage(boolean createImage) {
		this.createImage = createImage;
	}



	public int getObjectType() {
		return board.getObjectType();
	}
 
	public long getObjectId() {
		return board.getObjectId();
	}

 
	public long getBoardId() {
		return board.getBoardId();
	}
 
	public String getName() {
		return board.getName();
	}

 
	public String getDisplayName() {
		return board.getDisplayName();
	}

 
	public String getDescription() {		
		return board.getDescription();
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return board.getCreationDate();
	}

 
	public void setCreationDate(Date creationDate) {		
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return board.getModifiedDate();
	}

	public void setModifiedDate(Date modifiedDate) {
		
	}

	public int getTotalThreadCount() {
		return totalThreadCount;
	}

	public void setTotalThreadCount(int totalThreadCount) {
		this.totalThreadCount = totalThreadCount;
	}

	public int getTotalViewCount() {
		return totalViewCount;
	}

	public void setTotalViewCount(int totalViewCount) {
		this.totalViewCount = totalViewCount;
	}

	public int getTotalMessage() {
		return totalMessage;
	}

	public void setTotalMessage(int totalMessage) {
		this.totalMessage = totalMessage;
	}
 
	 
	public void setProperties(Map<String, String> properties) {
		board.setProperties(properties);
	}
 
	public Map<String, String> getProperties() {
		return board.getProperties();
	}


	@Override
	public long getCategoryId() {
		return board.getCategoryId();
	}



}
