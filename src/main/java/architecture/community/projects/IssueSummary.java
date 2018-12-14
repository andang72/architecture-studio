package architecture.community.projects;

import java.io.Serializable;
import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.json.JsonDateSerializer;
import architecture.community.user.User;

public class IssueSummary implements Serializable {

	private Project project;

	private Long issueId;

	private String summary;
	
	private User repoter;

	private User assignee;

	// 오류 , 기술지원, ..정기정검...
	private String issueType;

	private String issueTypeName;

	// 0(하), 1(중), 2 (상)
	private String priority;

	private String priorityName;

	// 처리결과 코드
	private String resolution;

	// 처리결과
	private String resolutionName;

	private String status;
	
	private String statusName;
	
	// 예정일
	private Date dueDate;

	private Date creationDate;

	private Date modifiedDate;

	private Date resolutionDate;
	
	private Task task;

	public IssueSummary(Long issueId) {
		this.issueId = issueId;
	}

	public Task getTask() {
		return task;
	}

	public void setTask(Task task) {
		this.task = task;
	}

	public String getSummary() {
		return summary;
	}

	public void setSummary(String summary) {
		this.summary = summary;
	}

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
	}

	public User getRepoter() {
		return repoter;
	}

	public void setRepoter(User repoter) {
		this.repoter = repoter;
	}

	public User getAssignee() {
		return assignee;
	}

	public void setAssignee(User assignee) {
		this.assignee = assignee;
	}

	public String getIssueType() {
		return issueType;
	}

	public void setIssueType(String issueType) {
		this.issueType = issueType;
	}

	public String getIssueTypeName() {
		return issueTypeName;
	}

	public void setIssueTypeName(String issueTypeName) {
		this.issueTypeName = issueTypeName;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}

	public String getPriorityName() {
		return priorityName;
	}

	public void setPriorityName(String priorityName) {
		this.priorityName = priorityName;
	}

	public String getResolution() {
		return resolution;
	}

	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	public String getResolutionName() {
		return resolutionName;
	}

	public void setResolutionName(String resolutionName) {
		this.resolutionName = resolutionName;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getDueDate() {
		return dueDate;
	}

	public void setDueDate(Date dueDate) {
		this.dueDate = dueDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return creationDate;
	}
 

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return modifiedDate;
	}
 

	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	}

	public void setResolutionDate(Date resolutionDate) {
		this.resolutionDate = resolutionDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getResolutionDate() {
		return resolutionDate;
	}
 

	public Long getIssueId() {
		return issueId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getStatusName() {
		return statusName;
	}

	public void setStatusName(String statusName) {
		this.statusName = statusName;
	}

	
}
