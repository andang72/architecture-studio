package architecture.community.projects;

import java.util.Calendar;
import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.PropertyAwareSupport;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;

public class Project extends PropertyAwareSupport {

	private long projectId;
	
	private String name;
	
	private String summary;
	
	private Date startDate ;
	
	private Date endDate;
	
	private Date creationDate;
	
	private Date modifiedDate;
	
	private String contractState   ;
	
	private String contractor ;
	
	private Double maintenanceCost;
	
	private boolean enabled;
	
	public Project() {
		this.projectId = -1L;
		this.name = null;
		this.summary = null;
		this.startDate = null;
		this.endDate = null;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;
		this.contractState = "" ;
		this.maintenanceCost = 0D ;
		this.contractor = null;
		this.enabled = true;
	}

	public Project(long projectId) {
		this.projectId = projectId;
		this.name = null;
		this.summary = null;
		this.startDate = null;
		this.endDate = null;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;
		this.contractState = "" ;
		this.maintenanceCost = 0D ;
		this.contractor = null;
		this.enabled = true;
	}

	public String getContractor() {
		return contractor;
	}

	public void setContractor(String contractor) {
		this.contractor = contractor;
	}

	public long getProjectId() {
		return projectId;
	}

	public void setProjectId(long projectId) {
		this.projectId = projectId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getSummary() {
		return summary;
	}

	public void setSummary(String summary) {
		this.summary = summary;
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

	public String getContractState() {
		return contractState;
	}

	public void setContractState(String contractState) {
		this.contractState = contractState;
	}

	public Double getMaintenanceCost() {
		return maintenanceCost;
	}

	public void setMaintenanceCost(Double maintenanceCost) {
		this.maintenanceCost = maintenanceCost;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

}
