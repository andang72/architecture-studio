package architecture.community.projects;

import java.util.List;
import java.util.Map;

import architecture.community.user.User;
import architecture.community.web.model.json.DataSourceRequest;

public interface ProjectService {
	
	public abstract Stats getIssueTypeStats(Project project)  ;
	
	public abstract Stats getIssueResolutionStats(Project project)  ;
	
	public abstract List<Project> getProjects();
	
	public abstract List<Project> getProjects(DataSourceRequest dataSourceRequest);
	
	public abstract int getProjectCount(DataSourceRequest dataSourceRequest);
	
	public abstract Project getProject(long projectId) throws ProjectNotFoundException ;
	
	public abstract void saveOrUpdateProject(Project project);
	
	public abstract void saveOrUpdateProject(Project project, Map<String, String> properties );
	
	public abstract void saveOrUpdateIssues(List<Issue> issue) ;
	
	public abstract Issue createIssue(int objectType, long objectId, User repoter);
	
	public abstract void saveOrUpdateIssue(Issue issue);
	
	public abstract int getIssueCount(int objectType, long objectId);
	
	public abstract int getIssueCount(DataSourceRequest dataSourceRequest);
	
	public abstract Issue getIssue( long issueId ) throws  IssueNotFoundException ;
	
	public abstract void deleteIssue(Issue issue);
	
	public abstract List<Issue> getIssues(int objectType, long objectId);
	
	public abstract List<Issue> getIssues(DataSourceRequest dataSourceRequest);
	
	public abstract List<Issue> getIssues(int objectType, long objectId, int startIndex, int numResults);

	
	/*
	 * IssueSummary API
	 * */
	public abstract int getIssueSummaryCount(DataSourceRequest dataSourceRequest);
	
	public abstract List<IssueSummary> getIssueSummary(DataSourceRequest dataSourceRequest); 
	

}
