package architecture.community.projects;

import java.util.Calendar;
import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.ModelObjectAwareSupport;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.model.json.JsonUserDeserializer;
import architecture.community.user.User;

public class Task extends ModelObjectAwareSupport {
	
	private Long taskId;
	
	private String taskName;
	
	private String description;
	
	private String version;
	
	private String progress ;
	
	private User user;
	
	private Date startDate;
	
	private Date endDate;
	
	private Double price;
	
	private Date creationDate;
	
	private Date modifiedDate;
	
	public Task(int objectType, long objectId, Long taskId, String taskName) {
		super(objectType, objectId);
		this.taskId = taskId;
		this.taskName = taskName;
	}

	public Task( ) {
		this(-1, -1L);
		this.taskId = -1L;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;		
		this.startDate = null;
		this.endDate = null;
		this.price = 0D;
	}
	
	public Task(int objectType, long objectId) {
		super(objectType, objectId); 
		this.taskId = -1L;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;		
		this.startDate = null;
		this.endDate = null;
		this.price = 0D;
	} 
	
	public Task(int objectType, long objectId, long taskId) {
		super(objectType, objectId);
		this.taskId = taskId;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;		
		this.startDate = null;
		this.endDate = null;
		this.price = 0D;
	}


	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getStartDate() {
		return startDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getEndDate() {
		return endDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Double getPrice() {
		return price;
	}

	public void setPrice(Double price) {
		this.price = price;
	}

	public Long getTaskId() {
		return taskId;
	}

	public void setTaskId(Long taskId) {
		this.taskId = taskId;
	}

	public String getTaskName() {
		return taskName;
	}

	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	public String getProgress() {
		return progress;
	}

	public void setProgress(String progress) {
		this.progress = progress;
	}

	public User getUser() {
		return user;
	}

	@JsonDeserialize(using = JsonUserDeserializer.class)
	public void setUser(User user) {
		this.user = user;
	}
	
	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return creationDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return modifiedDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("Task [objectType=").append(getObjectType()).append(", objectId=").append(getObjectId()).append(", ");
		if (taskId != null)
			builder.append("taskId=").append(taskId).append(", ");
		if (taskName != null)
			builder.append("taskName=").append(taskName).append(", ");
		if (description != null)
			builder.append("description=").append(description).append(", ");
		if (version != null)
			builder.append("version=").append(version).append(", ");
		if (progress != null)
			builder.append("progress=").append(progress).append(", ");
		if (user != null)
			builder.append("user=").append(user).append(", ");
		if (creationDate != null)
			builder.append("creationDate=").append(creationDate).append(", ");
		if (modifiedDate != null)
			builder.append("modifiedDate=").append(modifiedDate);
		builder.append("]");
		return builder.toString();
	}
	
	
}
