package architecture.community.projects.stats;

import java.util.Map;

import architecture.community.projects.Project;

public class IssueStateByProject {

	Project project;
	
	Map<String , IssueCount > aggregate ;
	
	Map<String , IssueCount > closedAggregate ;
	
	int totalCount ;
	int closedCount;
	
	public IssueStateByProject(Project project) {
		this.project = project;
		this.aggregate = new java.util.HashMap<String , IssueCount >();
		this.closedAggregate = new java.util.HashMap<String , IssueCount >();
		this.closedCount = 0 ;
		this.totalCount = 0 ;
	}

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
	}

	public Map<String, IssueCount> getAggregate() {
		return aggregate;
	}

	public void setAggregate(Map<String, IssueCount> aggregate) {
		this.aggregate = aggregate;
	}

	public Map<String, IssueCount> getClosedAggregate() {
		return closedAggregate;
	}

	public void setClosedAggregate(Map<String, IssueCount> closedAggregate) {
		this.closedAggregate = closedAggregate;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getClosedCount() {
		return closedCount;
	}

	public void setClosedCount(int closedCount) {
		this.closedCount = closedCount;
	} 

}
