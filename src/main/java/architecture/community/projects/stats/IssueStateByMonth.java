package architecture.community.projects.stats;

import java.util.Map;

public class IssueStateByMonth {
		
		String month;
		
		Map<String , IssueCount > aggregate ;
		
		Map<String , IssueCount > closedAggregate ;
		
		int totalCount ;
		
		int closedCount ;
		
		public IssueStateByMonth(String month) {
			this.month = month;
			this.aggregate = new java.util.HashMap<String , IssueCount >();
			this.closedAggregate = new java.util.HashMap<String , IssueCount >();
			this.totalCount = 0 ;
			this.closedCount = 0;
		}

		public String getMonth() {
			return month;
		}

		public void setMonth(String month) {
			this.month = month;
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
