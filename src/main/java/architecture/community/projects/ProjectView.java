package architecture.community.projects;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.security.spring.acls.JdbcCommunityAclService.PermissionsBundle;

public class ProjectView {

	@JsonIgnore
	private Project project;
	
	private boolean admin = false ;	
	
	private boolean writable = false ;	
	
	private boolean readable = false ;
	
	private boolean createThreadMessage = false;
	
	private boolean createThread = false;
	
	private boolean createAttachement = false ;
	
	private boolean readComment = false;
	
	private boolean createComment = false;
	
	private boolean createImage = false;
	
	private Stats issueTypeStats;
	
	private Stats resolutionStats;
	
	
	public ProjectView( Project project ) {
		this.project = project;
	}
	
	@JsonIgnore
	public void setPermissionsBundle( PermissionsBundle bundle ) {
		this.admin = bundle.isAdmin();
		this.writable = bundle.isWrite();
		this.readable = bundle.isRead();
		this.createAttachement = bundle.isCreateAttachment();
		this.readComment = bundle.isReadComment();
		this.createComment = bundle.isCreateComment();
		this.createImage = bundle.isCreateImage();
		this.createThread = bundle.isCreateThread();
		this.createThreadMessage = bundle.isCreateThreadMessage();	
	}

	@JsonGetter
	public Stats getIssueTypeStats() {
		return issueTypeStats;
	}


	public void setIssueTypeStats(Stats issueTypeStats) {
		this.issueTypeStats = issueTypeStats;
	}

	@JsonGetter
	public Stats getResolutionStats() {
		return resolutionStats;
	}


	public void setResolutionStats(Stats resolutionStats) {
		this.resolutionStats = resolutionStats;
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
	

	public long getProjectId() {
		return project.getProjectId();
	}

	public void setProjectId(long projectId) {
 
	}

	public String getName() {
		return project.getName();
	}

	public void setName(String name) {
 
	}

	public String getSummary() {
		return project.getSummary();
	}

	public void setSummary(String summary) {
 
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getStartDate() {
		return project.getStartDate();
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setStartDate(Date startDate) {
 
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getEndDate() {
		return project.getEndDate();
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setEndDate(Date endDate) {
 
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return project.getCreationDate();
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setCreationDate(Date creationDate) {
 
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return project.getModifiedDate();
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setModifiedDate(Date modifiedDate) {
 
	}
	
	

	public boolean isAdmin() {
		return admin;
	}

	@JsonIgnore
	public void setAdmin(boolean admin) {
		this.admin = admin;
	}

	public String getContractState() {
		return project.getContractState();
	}

	public void setContractState(String contractState) {
 
	}

	public String getContractor() {
		return project.getContractor();
	}

	public void setContractor(String contractor) {
 
	}
	
	public Double getMaintenanceCost() {
		return project.getMaintenanceCost();
	}

	public void setMaintenanceCost(Double maintenanceCost) {
 
	}
}
