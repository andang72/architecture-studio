package architecture.community.projects.stats;

import java.util.Map;

import architecture.community.user.User;

public class IssueStatsByUser {

	User user;
	
	Map<String , IssueCount > aggregate ;
	
	Map<String , IssueCount > closedAggregate ;
	
	int totalCount ;
	int closedCount;
	
	public IssueStatsByUser(User user) {
		this.user = user;
		this.aggregate = new java.util.HashMap<String , IssueCount >();
		this.closedAggregate = new java.util.HashMap<String , IssueCount >();
		this.closedCount = 0 ;
		this.totalCount = 0 ;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
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
