package architecture.community.projects.dao;

import java.util.List;
import java.util.Map;

import architecture.community.projects.Issue;
import architecture.community.projects.IssueSummary;
import architecture.community.projects.Project;
import architecture.community.projects.Scm;
import architecture.community.projects.Stats;
import architecture.community.projects.Task;
import architecture.community.web.model.json.DataSourceRequest;

public interface ProjectDao {
	
	public Stats getIssueTypeStats(long projectId);	

	public Stats getResolutionStats(long projectId);
	
	public void saveOrUpdateProject(Project project);
	
	public Project getProjectById(long projectId);
	
	public List<Long> getAllProjectIds(); 
	
	public abstract List<Long> getProjectIds(DataSourceRequest dataSourceRequest);
	
	public abstract int getProjectCount(DataSourceRequest dataSourceRequest);

	
	public abstract Map<String, String> getProjectProperties(long projectId);

	public abstract void deleteProjectProperties(long projectId) ;
	
	public abstract void setProjectProperties(long projectId, Map<String, String> props);
	
	
	public abstract void saveOrUpdateIssue(Issue issue);
	
	public abstract void saveOrUpdateIssues(List<Issue> issue) ;
	
	public abstract void deleteIssue(Issue issue);
	
	public abstract Issue getIssueById(long issueId);
	
	public abstract int getIssueCount( int objectType, long objectId ); 
	
	public abstract int getIssueCount(DataSourceRequest dataSourceRequest);
	
	public abstract List<Long> getIssueIds( int objectType, long objectId ); 
	
	public abstract List<Long> getIssueIds(DataSourceRequest dataSourceRequest);
	
	public abstract List<Long> getIssueIds(int objectType, long objectId, int startIndex, int numResults);

	
	/*
	 * Task API
	 * */
	public abstract void saveOrUpdateTask(Task task);	
	
	public abstract void deleteTask(Task task);
	
	public abstract Task getTaskById(long taskId);
	
	/*
	 * IssueSummary API
	 * */
	public abstract int getIssueSummaryCount(DataSourceRequest dataSourceRequest);
	
	public abstract List<IssueSummary> getIssueSummary(DataSourceRequest dataSourceRequest);

	
	/*
	 * Scm API
	 * */
	
	public abstract Scm getScmById(long scmId);
	public abstract void saveOrUpdateScm(Scm scm);
	public abstract void deleteScm(Scm scm);
}
