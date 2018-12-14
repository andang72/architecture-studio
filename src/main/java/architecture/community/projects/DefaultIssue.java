package architecture.community.projects;

import java.util.Calendar;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.ModelObjectAwareSupport;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.model.json.JsonUserDeserializer;
import architecture.community.user.User;

public class DefaultIssue extends ModelObjectAwareSupport implements Issue {
	
	
	private User repoter;
	
	private User assignee;
	
	private String requestorName;
	
	// 오류 , 기술지원, ..정기정검...
	private String issueType;
	
	private String issueTypeName;
	
	// 접수일자
	// 작업일자 계획  시작 - 종료
	// 작업완료 실적
	// 작업시간 계획 
	// 작업시간 실적  
	
	private long issueId;
	
	private String summary;
	
	private String description;
	
	// 0(하), 1(중), 2 (상)
	private String priority;
	
	private String priorityName;
	
	private String component;
	
	//처리결과 코드
	private String resolution;
		
	//처리결과 
	private String resolutionName;
	
	private String status;
	
	private String statusName;
	
	// 작업시작일 
	
	// 완료일 
	private Date resolutionDate;
	
	
	private Date startDate;
	
	// 예정일 
	private Date dueDate;
	
	
	private Date creationDate;
	
	private Date modifiedDate;
		
	private Long estimate;
	private Long timeSpent;
	private Long originalEstimate ;
	
	private Task task;
	
	public DefaultIssue() {
		super(-1, -1L);
		this.issueId = -1L;
		this.issueType = null;
		this.summary = null;
		this.description = null;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = creationDate;
		this.resolutionDate = null;
		this.dueDate = null;
		this.startDate = null;
		this.assignee = null;
		this.repoter = null;
		this.resolution = null;
		this.resolutionName = null;
		this.status = null;
		this.statusName = null;
		this.estimate = 0L;
		this.timeSpent = 0L;
		this.originalEstimate = 0L;
		this.requestorName = null;
		this.task = null;
	}
	
	public DefaultIssue(long issueId) {
		super(-1, -1L);
		this.issueId = issueId;
		this.issueType = null;
		this.summary = null;
		this.description = null;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = creationDate;
		this.dueDate = null;
		this.startDate = null;
		this.assignee = null;
		this.repoter = null;
		this.resolution = null;
		this.status = null;
		this.statusName = null;
		this.resolutionDate = null;
		this.requestorName = null;
		this.task = null;
	}
	
	public DefaultIssue(int objectType, long objectId) {
		super(objectType, objectId);
		this.issueId = -1L;
		this.issueType = null;
		this.summary = null;
		this.description = null;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = creationDate;
		this.dueDate = null;
		this.startDate = null;
		this.assignee = null;
		this.repoter = null;
		this.resolution = null;
		this.status = null;
		this.statusName = null;
		this.resolutionDate = null;
		this.requestorName = null;
		this.task = null;
	}
	
	public DefaultIssue(int objectType, long objectId, User repoter) {
		super(objectType, objectId);
		this.issueId = -1L;
		this.issueType = null;
		this.summary = null;
		this.description = null;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = creationDate;
		this.dueDate = null;
		this.startDate = null;
		this.assignee = null;
		this.repoter = repoter;
		this.resolution = null;
		this.resolutionName = null;
		this.status = null;
		this.statusName = null;
		this.resolutionDate = null;
		this.estimate = 0L;
		this.timeSpent = 0L;
		this.originalEstimate = 0L;		
		this.requestorName = null;
		this.task = null;
	}
	
	
	public String getRequestorName() {
		return requestorName;
	}

	public void setRequestorName(String requestorName) {
		this.requestorName = requestorName;
	}

	public User getRepoter() {
		return repoter;
	} 

	@JsonDeserialize(using = JsonUserDeserializer.class)
	public void setRepoter(User repoter) {
		this.repoter = repoter;
	} 

	public long getIssueId() {
		return issueId;
	}

	public void setIssueId(long issueId) {
		this.issueId = issueId;
	}

	public String getSummary() {
		return summary;
	}

	public void setSummary(String summary) {
		this.summary = summary;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	

	/**
	 * @return creationDate
	 */
	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return creationDate;
	}

	/**
	 * @param creationDate
	 *            설정할 creationDate
	 */
	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	/**
	 * @return modifiedDate
	 */
	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return modifiedDate;
	}

	/**
	 * @param modifiedDate
	 *            설정할 modifiedDate
	 */
	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	} 
	
	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getStartDate() {
		return startDate;
	}
	
	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public String getIssueType() {
		return issueType;
	}

	public void setIssueType(String issueType) {
		this.issueType = issueType;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getDueDate() {
		return dueDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setDueDate(Date dueDate) {
		this.dueDate = dueDate;
	}



	public User getAssignee() {
		return assignee;
	}


	@JsonDeserialize(using = JsonUserDeserializer.class)
	public void setAssignee(User assignee) {
		this.assignee = assignee;
	}



	public String getPriority() {
		return priority;
	}



	public void setPriority(String priority) {
		this.priority = priority;
	}



	public String getComponent() {
		return component;
	}



	public void setComponent(String component) {
		this.component = component;
	}

	@JsonGetter
	public String getPriorityName() {
		return priorityName;
	}

	@JsonIgnore
	public void setPriorityName(String priorityName) {
		this.priorityName = priorityName;
	}

	@JsonGetter
	public String getIssueTypeName() {
		return issueTypeName;
	}

	@JsonIgnore
	public void setIssueTypeName(String issueTypeName) {
		this.issueTypeName = issueTypeName;
	}


	public String getResolution() {
		return resolution;
	}


	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	@JsonGetter
	public String getResolutionName() {
		return resolutionName;
	}

	
	@JsonIgnore
	public void setResolutionName(String resolutionName) {
		this.resolutionName = resolutionName;
	}

	
	public String getStatus() {
		return status;
	}


	public void setStatus(String status) {
		this.status = status;
	}

	@JsonGetter
	public String getStatusName() {
		return statusName;
	}

	@JsonIgnore
	public void setStatusName(String statusName) {
		this.statusName = statusName;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getResolutionDate() {
		return resolutionDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setResolutionDate(Date resolutionDate) {
		this.resolutionDate = resolutionDate;
	}
	
	
	
	public Long getEstimate() {
		return estimate;
	}

	public void setEstimate(Long estimate) {
		this.estimate = estimate;
	}

	public Long getTimeSpent() {
		return timeSpent;
	}

	public void setTimeSpent(Long timeSpent) {
		this.timeSpent = timeSpent;
	}

	public Long getOriginalEstimate() {
		return originalEstimate;
	}

	public void setOriginalEstimate(Long originalEstimate) {
		this.originalEstimate = originalEstimate;
	}

	
	
	public Task getTask() {
		return task;
	}

	public void setTask(Task task) {
		this.task = task;
	}

	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("DefaultIssue [");
		if (repoter != null)
			builder.append("repoter=").append(repoter).append(", ");
		if (assignee != null)
			builder.append("assignee=").append(assignee).append(", ");
		if (issueType != null)
			builder.append("issueType=").append(issueType).append(", ");
		if (issueTypeName != null)
			builder.append("issueTypeName=").append(issueTypeName).append(", ");
		builder.append("issueId=").append(issueId).append(", ");
		if (summary != null)
			builder.append("summary=").append(summary).append(", ");
		if (description != null)
			builder.append("description=").append(description).append(", ");
		if (priority != null)
			builder.append("priority=").append(priority).append(", ");
		if (priorityName != null)
			builder.append("priorityName=").append(priorityName).append(", ");
		if (component != null)
			builder.append("component=").append(component).append(", ");
		if (resolution != null)
			builder.append("resolution=").append(resolution).append(", ");
		if (resolutionName != null)
			builder.append("resolutionName=").append(resolutionName).append(", ");
		if (status != null)
			builder.append("status=").append(status).append(", ");
		if (statusName != null)
			builder.append("statusName=").append(statusName).append(", ");
		if (resolutionDate != null)
			builder.append("resolutionDate=").append(resolutionDate).append(", ");
		if (dueDate != null)
			builder.append("dueDate=").append(dueDate).append(", ");
		if (creationDate != null)
			builder.append("creationDate=").append(creationDate).append(", ");
		if (modifiedDate != null)
			builder.append("modifiedDate=").append(modifiedDate);
		builder.append("]");
		return builder.toString();
	} 
}
