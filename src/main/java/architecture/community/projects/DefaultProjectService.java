package architecture.community.projects;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import javax.inject.Inject;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;

import architecture.community.codeset.CodeSet;
import architecture.community.codeset.CodeSetService;
import architecture.community.menu.Menu;
import architecture.community.projects.dao.ProjectDao;
import architecture.community.projects.event.IssueStateChangeEvent;
import architecture.community.services.CommunitySpringEventPublisher;
import architecture.community.user.User;
import architecture.community.user.UserManager;
import architecture.community.util.SecurityHelper;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.ee.spring.event.EventSupport;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class DefaultProjectService extends EventSupport implements ProjectService {

	private Logger logger = LoggerFactory.getLogger(getClass().getName());
	
	@Inject
	@Qualifier("projectDao")
	private ProjectDao projectDao;

	@Inject
	@Qualifier("projectCache")
	private Cache projectCache;	
	
	@Inject
	@Qualifier("projectIssueCache")
	private Cache projectIssueCache;	 
	
	@Inject
	@Qualifier("taskService")
	private TaskService taskService;
	
	@Inject
	@Qualifier("userManager")
	private UserManager userManager;	
	
	@Inject
	@Qualifier("codeSetService")
	private CodeSetService codeSetService;

	@Autowired(required = false)
	@Qualifier("communitySpringEventPublisher")
	private CommunitySpringEventPublisher eventPublisher; 
	
	private com.google.common.cache.LoadingCache<Long, Stats> projectIssueTypeStatsCache = null;
	
	private com.google.common.cache.LoadingCache<Long, Stats> projectResolutionStatsCache = null; 
	
	public DefaultProjectService() {  
		
	}	 
	
	public void initialize(){		
		logger.debug("creating cache ...");		
		projectIssueTypeStatsCache = CacheBuilder.newBuilder().maximumSize(500).expireAfterAccess( 60 * 100, TimeUnit.MINUTES).build(		
				new CacheLoader<Long, Stats>(){			
					public Stats load(Long projectId) throws Exception {
						//logger.debug("get role form database by {}", roleId );
						List<CodeSet> list = codeSetService.getCodeSets(-1, -1L, "ISSUE_TYPE");
						Stats stats = projectDao.getIssueTypeStats(projectId);
						int total = 0;
						for ( CodeSet code : list ) {
							stats.add(code.getName(), code.getCode(), 0);
						}
						/*
						for( Stats.Item item : stats.getItems())
						{
							if(!StringUtils.equals("ETC", item.getName()))
								total = total + item.getValue();
						}
						*/
						//stats.add("TOTAL", total);
						return stats;
					}
				}
			);
		
		projectResolutionStatsCache = CacheBuilder.newBuilder().maximumSize(50).expireAfterAccess( 60 * 100, TimeUnit.MINUTES).build(		
				new CacheLoader<Long, Stats>(){
					@Override
					public Stats load(Long projectId) throws Exception {
						List<CodeSet> list = codeSetService.getCodeSets(-1, -1L, "RESOLUTION");
						Stats stats = projectDao.getResolutionStats(projectId);
						int total = 0;
						for ( CodeSet code : list ) {
							stats.add(code.getName(), code.getCode(), 0);
						}
						/*
						for( Stats.Item item : stats.getItems())
						{
							if(!StringUtils.equals("ETC", item.getName()))
								total = total + item.getValue();
						}
						*/
						//stats.add("TOTAL", total);	
						return stats;
					}			
		});	 
	}
	
	public Stats getIssueTypeStats(Project project)  {
		try {
			return projectIssueTypeStatsCache.get(project.getProjectId());
		} catch (ExecutionException e) {
			return null;
		}
	}
	
	public Stats getIssueResolutionStats(Project project)  {
		try {
			return projectResolutionStatsCache.get(project.getProjectId());
		} catch (ExecutionException e) {
			return null;
		}
	}

	private void clearProjectStats(Long projectId) {
		if( projectId > 0) {
			projectIssueTypeStatsCache.invalidate(projectId);
			projectResolutionStatsCache.invalidate(projectId);
		}
	}
 
	public List<Project> getProjects() { 
		List<Long> ids = projectDao.getAllProjectIds();
		List<Project> list = new ArrayList<Project>(ids.size());
		for(Long projectId : ids ) {
			try {
				list.add(getProject(projectId));
			} catch (ProjectNotFoundException e) {
			}
		}
		return list;
	}
	
	public List<Project> getProjects(DataSourceRequest dataSourceRequest){
		List<Long> ids = projectDao.getProjectIds(dataSourceRequest);
		List<Project> list = new ArrayList<Project>(ids.size());
		for(Long projectId : ids ) {
			try {
				list.add(getProject(projectId));
			} catch (ProjectNotFoundException e) {
			}
		}
		return list;
	}
 
	public int getProjectCount(DataSourceRequest dataSourceRequest){
		return projectDao.getProjectCount(dataSourceRequest);
	}
	
	public Project getProject(long projectId) throws ProjectNotFoundException { 
		Project project = getProjectInCache(projectId);		
		if( project == null ) {
			project = projectDao.getProjectById(projectId);
			if( project != null && project.getProjectId() > 0 )
				projectCache.put(new Element(projectId, project ));
		}
		if( project == null )
			throw new ProjectNotFoundException(); 
		return project;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateProject(Project project) {
		
		if( project.getProjectId() > 0 && projectCache.get(project.getProjectId()) != null  ) {
			projectCache.remove(project.getProjectId());
		} 
		projectDao.saveOrUpdateProject(project);
	}
	
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateProject(Project project, Map<String, String> properties) {
		if( project.getProjectId() > 0 && projectCache.get(project.getProjectId()) != null  ) {
			projectCache.remove(project.getProjectId());
			projectDao.setProjectProperties(project.getProjectId(), properties); 
		} 
	}
	
	protected Project getProjectInCache(long projectId){
		if( projectCache.get(projectId) != null && projectId > 0L )
			return  (Project) projectCache.get( projectId ).getObjectValue();
		else 
			return null;
	}
 
	public Issue createIssue(int objectType, long objectId, User repoter) {
		Issue issue = new DefaultIssue(objectType, objectId, repoter);		
		return issue;
	}

 
	public int getIssueCount(int objectType, long objectId) {		
		return projectDao.getIssueCount(objectType, objectId);
	}
 
	public List<Issue> getIssues(int objectType, long objectId) {
		List<Long> threadIds = projectDao.getIssueIds(objectType, objectId);
		List<Issue> list = new ArrayList<Issue>(threadIds.size());
		for( Long threadId : threadIds )
		{
			try {
				list.add(getIssue(threadId));
			} catch (IssueNotFoundException e) {
				// ignore;
				logger.warn(e.getMessage(), e);
			}
		}
		return list;
	}
 
	public List<Issue> getIssues(int objectType, long objectId, int startIndex, int numResults) {
		List<Long> threadIds = projectDao.getIssueIds(objectType, objectId, startIndex, numResults);
		List<Issue> list = new ArrayList<Issue>(threadIds.size());
		for( Long threadId : threadIds )
		{
			try {
				list.add(getIssue(threadId));
			} catch (IssueNotFoundException e) {
				// ignore;
				logger.warn(e.getMessage(), e);
			}
		}
		return list;
	}
	

	public int getIssueCount(DataSourceRequest dataSourceRequest) {
		return projectDao.getIssueCount(dataSourceRequest);
	}

	public List<Issue> getIssues(DataSourceRequest dataSourceRequest) {
		List<Long> threadIds = projectDao.getIssueIds(dataSourceRequest);
		List<Issue> list = new ArrayList<Issue>(threadIds.size());
		for( Long threadId : threadIds )
		{
			try {
				list.add(getIssue(threadId));
			} catch (IssueNotFoundException e) {
				// ignore;
				logger.warn(e.getMessage(), e);
			}
		}
		return list;
	}
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateIssues(List<Issue> issues) {
		for(Issue issue : issues) {
			projectIssueCache.remove(issue.getIssueId());
			clearProjectStats(issue.getObjectId());
		}
		
		projectDao.saveOrUpdateIssues(issues); 
		
	} 
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void deleteIssue(Issue issue) {
		if( issue.getIssueId() > 0L) {
			if( issue.getIssueId() > 0 && projectIssueCache.get(issue.getIssueId()) != null  ) {
				projectIssueCache.remove(issue.getIssueId());
			} 
			clearProjectStats(issue.getObjectId());
			projectDao.deleteIssue(issue);
		}
	} 
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateIssue(Issue issue) {
		boolean isNew = true;
		IssueStateChangeEvent.State state ;
		if( issue.getIssueId() > 0 ) {
			isNew = false;
			state = IssueStateChangeEvent.State.UPDATED;
		}else {
			state = IssueStateChangeEvent.State.CREATED;
		}
		
		if( issue.getIssueId() > 0 && projectIssueCache.get(issue.getIssueId()) != null  ) {
			projectIssueCache.remove(issue.getIssueId());
		} 
		
		clearProjectStats(issue.getObjectId());
		
		logger.debug("save or update user {}" , issue );
		
		projectDao.saveOrUpdateIssue(issue);
		
		if( eventPublisher != null)
			eventPublisher.fireEvent(new IssueStateChangeEvent( issue, SecurityHelper.getUser(), state ));
		
	}
	
	protected Issue geIssueInCache(long issueId){
		if( projectIssueCache.get(issueId) != null && issueId > 0L )
			return  (Issue) projectIssueCache.get( issueId ).getObjectValue();
		else 
			return null;
	}
 
	public Issue getIssue(long issueId) throws IssueNotFoundException {
		Issue issue = geIssueInCache(issueId);		
		if( issue == null ) {
			issue = projectDao.getIssueById(issueId);
			if( issue != null && issue.getIssueId() > 0 ) { 
				if( issue.getAssignee().getUserId() > 0) {
					issue.setAssignee( userManager.getUser(issue.getAssignee()));
				} 
				if( issue.getRepoter().getUserId() > 0) {
					issue.setRepoter( userManager.getUser(issue.getRepoter()));				
				} 
				if( issue.getTask().getTaskId() > 0 ) {
					try {
						issue.setTask(taskService.getTask(issue.getTask().getTaskId()));
					} catch (TaskNotFoundException e) { }
				} 
				((DefaultIssue)issue).setIssueTypeName(getCodeText( "ISSUE_TYPE", issue.getIssueType()));
				((DefaultIssue)issue).setPriorityName(getCodeText( "PRIORITY", issue.getPriority()));	
				((DefaultIssue)issue).setStatusName(getCodeText( "ISSUE_STATUS", issue.getStatus()));
				((DefaultIssue)issue).setResolutionName(getCodeText( "RESOLUTION", issue.getResolution())); 
				projectIssueCache.put(new Element(issueId, issue ));
			}
		}
		if( issue == null )
			throw new IssueNotFoundException(); 
		return issue;
	}
	
	/**
	 * 코드값에 해당하는 테스트를 리턴한다.
	 * 
	 * @param group
	 * @param code
	 * @return
	 */
	private String getCodeText( String group, String code ) {		
		if( StringUtils.isEmpty(group) || StringUtils.isEmpty(code))
			return null;
		
		try {
			return codeSetService.getCodeSetByCode(group, code).getName();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			return null;
		}
	} 
	
	public int getIssueSummaryCount(DataSourceRequest dataSourceRequest) {
		return projectDao.getIssueSummaryCount(dataSourceRequest);
	}

	public List<IssueSummary> getIssueSummary(DataSourceRequest dataSourceRequest) {
		
		List<IssueSummary> list = projectDao.getIssueSummary(dataSourceRequest);
		for( IssueSummary summary : list )
		{
			if( summary.getAssignee().getUserId() > 0)
				summary.setAssignee( userManager.getUser(summary.getAssignee()));
				
			if( summary.getRepoter().getUserId() > 0)
				summary.setRepoter( userManager.getUser(summary.getRepoter()));				
			
			if( StringUtils.isNotEmpty( summary.getIssueType() ))
				summary.setIssueTypeName(getCodeText( "ISSUE_TYPE", summary.getIssueType()));
			
			if( StringUtils.isNotEmpty( summary.getPriority() ))
				summary.setPriorityName(getCodeText( "PRIORITY", summary.getPriority()));		
			
			if( StringUtils.isNotEmpty( summary.getStatus() ))
				summary.setStatusName(getCodeText( "ISSUE_STATUS", summary.getStatus()));
			
			if( StringUtils.isNotEmpty( summary.getResolution() ))
				summary.setResolutionName(getCodeText( "RESOLUTION", summary.getResolution()));
			
		}
		return list;
	}  

}