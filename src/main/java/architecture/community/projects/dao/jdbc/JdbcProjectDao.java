package architecture.community.projects.dao.jdbc;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlParameterValue;

import architecture.community.i18n.CommunityLogLocalizer;
import architecture.community.model.Models;
import architecture.community.projects.DefaultIssue;
import architecture.community.projects.Issue;
import architecture.community.projects.IssueSummary;
import architecture.community.projects.Project;
import architecture.community.projects.Scm;
import architecture.community.projects.Stats;
import architecture.community.projects.Task;
import architecture.community.projects.dao.ProjectDao;
import architecture.community.user.UserTemplate;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.ee.jdbc.property.dao.PropertyDao;
import architecture.ee.jdbc.sequencer.SequencerFactory;
import architecture.ee.jdbc.sqlquery.mapping.BoundSql;
import architecture.ee.service.ConfigService;
import architecture.ee.spring.jdbc.ExtendedJdbcDaoSupport;
import architecture.ee.util.StringUtils;

public class JdbcProjectDao extends ExtendedJdbcDaoSupport implements ProjectDao {

	private final RowMapper<Task> taskMapper = new RowMapper<Task>() {		
		
		public Task mapRow(ResultSet rs, int rowNum) throws SQLException {			
			Task task = new Task(rs.getInt("OBJECT_TYPE"), rs.getLong("OBJECT_ID"), rs.getLong("TASK_ID"));			
			task.setTaskName(rs.getString("TASK_NAME"));
			task.setDescription(rs.getString("DESCRIPTION"));
			task.setVersion(rs.getString("VERSION"));
			task.setProgress(rs.getString("PROGRESS")); 
			task.setPrice(rs.getDouble("PRICE"));
			task.setStartDate(rs.getDate("START_DATE"));
			task.setEndDate(rs.getDate("END_DATE"));
			task.setUser(new UserTemplate(rs.getLong("USER_ID")));
			task.setCreationDate(rs.getDate("CREATION_DATE"));
			task.setModifiedDate(rs.getDate("MODIFIED_DATE"));		
			
			return task;
		}		
	};
	
	private final RowMapper<Project> projectMapper = new RowMapper<Project>() {				
		public Project mapRow(ResultSet rs, int rowNum) throws SQLException {			
			Project board = new Project(rs.getLong("PROJECT_ID"));			
			board.setName(rs.getString("NAME"));
			board.setSummary(rs.getString("SUMMARY"));
			board.setContractor(rs.getString("CONTRACTOR"));
			board.setContractState(rs.getString("CONTRACT_STATE"));
			board.setMaintenanceCost(rs.getDouble("MAINTENANCE_COST"));
			board.setStartDate(rs.getDate("START_DATE"));
			board.setEndDate(rs.getDate("END_DATE"));
			board.setEnabled(rs.getInt("PROJECT_ENABLED") == 1);
			board.setCreationDate(rs.getDate("CREATION_DATE"));
			board.setModifiedDate(rs.getDate("MODIFIED_DATE"));		
			return board;
		}		
	};
	
	private final RowMapper<Issue> issueMapper = new RowMapper<Issue>() {				
		public Issue mapRow(ResultSet rs, int rowNum) throws SQLException {			
			
			DefaultIssue issue = new DefaultIssue(rs.getLong("ISSUE_ID"));			
			issue.setObjectType(rs.getInt("OBJECT_TYPE"));
			issue.setObjectId(rs.getLong("OBJECT_ID"));
			issue.setIssueType(rs.getString("ISSUE_TYPE"));
			issue.setStatus(rs.getString("ISSUE_STATUS"));
			issue.setResolution(rs.getString("RESOLUTION"));
			issue.setResolutionDate(rs.getDate("RESOLUTION_DATE"));
			issue.setSummary(rs.getString("SUMMARY"));
			issue.setDescription(rs.getString("DESCRIPTION"));
			issue.setPriority(rs.getString("PRIORITY"));
			issue.setComponent(rs.getString("COMPONENT"));
			
			
			issue.setRequestorName(rs.getString("REQUESTOR_NAME"));
			
			issue.setAssignee(new UserTemplate(rs.getLong("ASSIGNEE")));
			issue.setRepoter(new UserTemplate(rs.getLong("REPOTER")));
			
			issue.setDueDate(rs.getDate("DUE_DATE"));
			issue.setStartDate(rs.getDate("START_DATE"));
			issue.setTask( new Task(issue.getObjectType(), issue.getIssueId(), rs.getLong("TASK_ID")) );
			
			issue.setOriginalEstimate(rs.getLong("TIMEORIGINALESTIMATE"));
			issue.setEstimate(rs.getLong("TIMEESTIMATE"));
			issue.setTimeSpent(rs.getLong("TIMESPENT"));
			
			issue.setCreationDate(rs.getDate("CREATION_DATE"));
			issue.setModifiedDate(rs.getDate("MODIFIED_DATE"));		
			return issue;
		}		
	};
	
	private final RowMapper<Scm> scmMapper = new RowMapper<Scm>() {				
		public Scm mapRow(ResultSet rs, int rowNum) throws SQLException {			
			Scm scm = new Scm(rs.getInt("OBJECT_TYPE"), rs.getLong("OBJECT_ID"), rs.getLong("SCM_ID"));			
			scm.setName(rs.getString("NAME"));
			scm.setDescription(rs.getString("DESCRIPTION"));
			scm.setUrl(rs.getString("URL"));
			scm.setUsername(rs.getString("USERNAME"));
			scm.setPassword(rs.getString("PASSWORD"));
			scm.setTags(rs.getString("TAGS"));
			scm.setCreationDate(rs.getDate("CREATION_DATE"));
			scm.setModifiedDate(rs.getDate("MODIFIED_DATE"));		
			return scm;
		}		
	};
	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("sequencerFactory")
	private SequencerFactory sequencerFactory;

	@Inject
	@Qualifier("propertyDao")
	private PropertyDao propertyDao;	
	
	private String projectPropertyTableName = "AC_SD_PROJECT_PROPERTY";
	private String projectPropertyPrimaryColumnName = "PROJECT_ID";
	
	private String scmPropertyTableName = "AC_SD_SCM_PROPERTY";
	private String scmPropertyPrimaryColumnName = "SCM_ID";	
	
	public JdbcProjectDao() { 
	}

	public long getNextProjectId(){
		logger.debug("next id for {}, {}", Models.PROJECT.getObjectType(), Models.PROJECT.name() );
		return sequencerFactory.getNextValue(Models.PROJECT.getObjectType(), Models.PROJECT.name());
	}
	
	public long getNextIssueId(){
		logger.debug("next id for {}, {}", Models.ISSUE.getObjectType(), Models.ISSUE.name() );
		return sequencerFactory.getNextValue(Models.ISSUE.getObjectType(), Models.ISSUE.name());
	}
	
	public long getNextTaskId(){
		logger.debug("next id for {}, {}", Models.TASK.getObjectType(), Models.TASK.name() );
		return sequencerFactory.getNextValue(Models.TASK.getObjectType(), Models.TASK.name());
	}
	
	public long getNextScmId(){
		logger.debug("next id for {}, {}", Models.SCM.getObjectType(), Models.SCM.name() );
		return sequencerFactory.getNextValue(Models.SCM.getObjectType(), Models.SCM.name());
	}	
	
	public Map<String, String> getProjectProperties(long projectId) {
		return propertyDao.getProperties(projectPropertyTableName, projectPropertyPrimaryColumnName, projectId);
	}

	public void deleteProjectProperties(long projectId) {
		propertyDao.deleteProperties(projectPropertyTableName, projectPropertyPrimaryColumnName, projectId);
	}
	
	public void setProjectProperties(long projectId, Map<String, String> props) {
		propertyDao.updateProperties(projectPropertyTableName, projectPropertyPrimaryColumnName, projectId, props);
	}	
	
	public Map<String, String> getScmProperties(long scmId) {
		return propertyDao.getProperties(scmPropertyTableName, scmPropertyPrimaryColumnName, scmId);
	}

	public void deleteScmProperties(long scmId) {
		propertyDao.deleteProperties(scmPropertyTableName, scmPropertyPrimaryColumnName, scmId);
	}
	
	public void setScmProperties(long scmId, Map<String, String> props) {
		propertyDao.updateProperties(scmPropertyTableName, scmPropertyPrimaryColumnName, scmId, props);
	}	
	
	public String getScmPropertyTableName() {
		return scmPropertyTableName;
	}

	public void setScmPropertyTableName(String scmPropertyTableName) {
		this.scmPropertyTableName = scmPropertyTableName;
	}

	public String getScmPropertyPrimaryColumnName() {
		return scmPropertyPrimaryColumnName;
	}

	public void setScmPropertyPrimaryColumnName(String scmPropertyPrimaryColumnName) {
		this.scmPropertyPrimaryColumnName = scmPropertyPrimaryColumnName;
	}

	public String getProjectPropertyTableName() {
		return projectPropertyTableName;
	}

	public void setProjectPropertyTableName(String projectPropertyTableName) {
		this.projectPropertyTableName = projectPropertyTableName;
	}

	public String getProjectPropertyPrimaryColumnName() {
		return projectPropertyPrimaryColumnName;
	}

	public void setProjectPropertyPrimaryColumnName(String projectPropertyPrimaryColumnName) {
		this.projectPropertyPrimaryColumnName = projectPropertyPrimaryColumnName;
	}

	@Override
	public void saveOrUpdateProject(Project project) {
		Project toUse = project;
		if (toUse.getProjectId() < 1L) {
			toUse.setProjectId(getNextProjectId());		
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.INSERT_PROJECT").getSql(),
					new SqlParameterValue(Types.NUMERIC, toUse.getProjectId()),
					new SqlParameterValue(Types.VARCHAR, toUse.getName()),
					new SqlParameterValue(Types.VARCHAR, toUse.getSummary()),
					new SqlParameterValue(Types.VARCHAR, toUse.getContractor()),
					new SqlParameterValue(Types.VARCHAR, toUse.getContractState()),
					new SqlParameterValue(Types.NUMERIC, toUse.getMaintenanceCost()),					
					new SqlParameterValue(Types.TIMESTAMP, toUse.getStartDate()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getEndDate()),
					new SqlParameterValue(Types.NUMERIC, toUse.isEnabled() ? 1 : 0 ),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getCreationDate()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getModifiedDate()));
			
		} else {
			Date now = Calendar.getInstance().getTime();
			toUse.setModifiedDate(now);		
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.UPDATE_PROJECT").getSql(),
					new SqlParameterValue(Types.VARCHAR, toUse.getName()),
					new SqlParameterValue(Types.VARCHAR, toUse.getSummary()),
					new SqlParameterValue(Types.VARCHAR, toUse.getContractor()),
					new SqlParameterValue(Types.VARCHAR, toUse.getContractState()),
					new SqlParameterValue(Types.NUMERIC, toUse.getMaintenanceCost()),	
					new SqlParameterValue(Types.TIMESTAMP, toUse.getStartDate()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getEndDate()),
					new SqlParameterValue(Types.NUMERIC, toUse.isEnabled() ? 1 : 0 ),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getModifiedDate()),
					new SqlParameterValue(Types.NUMERIC, toUse.getProjectId())
			);
		}	
	}
 
	public Project getProjectById(long projectId) {
		try {
			Project project = getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.SELECT_PROJECT_BY_ID").getSql(),
				projectMapper,
				new SqlParameterValue(Types.NUMERIC, projectId));
			
			Map<String, String> properties = getProjectProperties(project.getProjectId());
			project.getProperties().putAll(properties);
			return project;
		} catch (DataAccessException e) {
			logger.warn(e.getMessage());
			return null;
		}
	}
 
	public List<Long> getAllProjectIds() {
		return getExtendedJdbcTemplate().queryForList(getBoundSql("COMMUNITY_WEB.SELECT_PROJECT_IDS").getSql(), Long.class);
	}

	public Stats getIssueTypeStats(long projectId) {
		return getStats(projectId, "COMMUNITY_WEB.SELECT_ISSUE_TYPE_STATS_BY_PROJECT");
	}

	public Stats getResolutionStats(long projectId) {
		return getStats(projectId, "COMMUNITY_WEB.SELECT_RESOLUTION_STATS_BY_PROJECT");
	} 
	
	private Stats getStats(long projectId , String statement) {
		return getExtendedJdbcTemplate().query(getBoundSql(statement).getSql(), new ResultSetExtractor<Stats>() { 
			public Stats extractData(ResultSet rs) throws SQLException, DataAccessException {
				Stats stats = new Stats();
				while(rs.next()) {
					stats.add(StringUtils.defaultString(rs.getString(1), "ETC"), rs.getInt(2));
				}
				return stats;
			}			
		}, new SqlParameterValue(Types.NUMERIC, projectId ));
	} 
	 
	public void deleteIssue(Issue issue) { 
		Issue toUse = issue;
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.DELETE_ISSUE_BY_ID").getSql(), 
				new SqlParameterValue(Types.NUMERIC, toUse.getIssueId())
		);
	}

	@Override
	public void saveOrUpdateIssue(Issue issue) {
 
		Issue toUse = issue; 
		if (toUse.getIssueId() < 1L) {
			toUse.setIssueId(getNextIssueId());			
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.INSERT_ISSUE").getSql(),
					new SqlParameterValue(Types.NUMERIC, toUse.getIssueId()),
					new SqlParameterValue(Types.NUMERIC, toUse.getObjectType()),
					new SqlParameterValue(Types.NUMERIC, toUse.getObjectId()),
					new SqlParameterValue(Types.VARCHAR, toUse.getIssueType()),
					new SqlParameterValue(Types.VARCHAR, toUse.getStatus()),					
					new SqlParameterValue(Types.VARCHAR, toUse.getComponent()),
					new SqlParameterValue(Types.VARCHAR, toUse.getSummary()),
					new SqlParameterValue(Types.VARCHAR, toUse.getDescription()),
					new SqlParameterValue(Types.VARCHAR, toUse.getPriority()),	
					new SqlParameterValue(Types.VARCHAR, toUse.getResolution()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getResolutionDate()),
					new SqlParameterValue(Types.NUMERIC, toUse.getAssignee() == null ? -1L: toUse.getAssignee().getUserId()),	
					new SqlParameterValue(Types.NUMERIC, toUse.getRepoter() == null ? -1L: toUse.getRepoter().getUserId()),	 
					
					new SqlParameterValue(Types.TIMESTAMP, toUse.getStartDate()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getDueDate()), 
					
					new SqlParameterValue(Types.NUMERIC, toUse.getOriginalEstimate() == null ? 0L: toUse.getOriginalEstimate()),
					new SqlParameterValue(Types.NUMERIC, toUse.getEstimate() == null ? 0L: toUse.getEstimate()),	
					new SqlParameterValue(Types.NUMERIC, toUse.getTimeSpent() == null ? 0L: toUse.getTimeSpent()),	
					new SqlParameterValue(Types.VARCHAR, toUse.getRequestorName()),
					
					new SqlParameterValue(Types.NUMERIC, toUse.getTask() == null ? -1L: toUse.getTask().getTaskId()),	
					
					new SqlParameterValue(Types.TIMESTAMP, toUse.getCreationDate()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getModifiedDate()));					
		} else {
			Date now = Calendar.getInstance().getTime();
			toUse.setModifiedDate(now);		
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.UPDATE_ISSUE").getSql(), 
					new SqlParameterValue(Types.VARCHAR, toUse.getIssueType()),
					new SqlParameterValue(Types.VARCHAR, toUse.getStatus()),
					new SqlParameterValue(Types.VARCHAR, toUse.getResolution()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getResolutionDate()),
					new SqlParameterValue(Types.VARCHAR, toUse.getPriority()),	
					new SqlParameterValue(Types.VARCHAR, toUse.getComponent()),
					new SqlParameterValue(Types.VARCHAR, toUse.getSummary()),
					new SqlParameterValue(Types.VARCHAR, toUse.getDescription()),					
					new SqlParameterValue(Types.NUMERIC, toUse.getAssignee() == null ? -1L: toUse.getAssignee().getUserId()),	
					new SqlParameterValue(Types.NUMERIC, toUse.getRepoter() == null ? -1L: toUse.getRepoter().getUserId()),	
					
					new SqlParameterValue(Types.TIMESTAMP, toUse.getStartDate()),
					new SqlParameterValue(Types.TIMESTAMP, toUse.getDueDate()),

					new SqlParameterValue(Types.NUMERIC, toUse.getEstimate() == null ? 0L: toUse.getEstimate()),	
					new SqlParameterValue(Types.NUMERIC, toUse.getTimeSpent() == null ? 0L: toUse.getTimeSpent()),	
					new SqlParameterValue(Types.VARCHAR, toUse.getRequestorName()),
					
					new SqlParameterValue(Types.NUMERIC, toUse.getTask() == null ? -1L: toUse.getTask().getTaskId()),	
					
					new SqlParameterValue(Types.TIMESTAMP, toUse.getModifiedDate()),
					new SqlParameterValue(Types.NUMERIC, toUse.getIssueId())
			);		
			
		}	
		
	}

	public void saveOrUpdateIssues(List<Issue> issue) {
		final List<Issue> updates = issue;
		getExtendedJdbcTemplate().batchUpdate(
			    getBoundSql("COMMUNITY_WEB.UPDATE_ISSUE").getSql(),
			    new BatchPreparedStatementSetter() {
				public void setValues(PreparedStatement ps, int i) throws SQLException {
					Issue toUse = updates.get(i);
					ps.setString(1, toUse.getIssueType());
					ps.setString(2, toUse.getStatus());
					ps.setString(3, toUse.getResolution());					
					if( toUse.getResolutionDate() != null)
						ps.setTimestamp(4, new Timestamp(toUse.getResolutionDate().getTime()));
					else
						ps.setNull(4, Types.TIMESTAMP);
					ps.setString(5, toUse.getPriority());
					ps.setString(6, toUse.getComponent());
					ps.setString(7, toUse.getSummary());
					ps.setString(8, toUse.getDescription());
					ps.setLong(9, toUse.getAssignee() == null ? -1L: toUse.getAssignee().getUserId());
					ps.setLong(10, toUse.getRepoter() == null ? -1L: toUse.getRepoter().getUserId());
					
					if( toUse.getResolutionDate() != null)
						ps.setTimestamp(11, new Timestamp(toUse.getDueDate().getTime()));
					else
						ps.setNull(11, Types.TIMESTAMP);
					
					if( toUse.getModifiedDate() != null)
						ps.setTimestamp(12, new Timestamp(toUse.getModifiedDate().getTime()));
					else
						ps.setNull(12, Types.TIMESTAMP);
					ps.setLong(13, toUse.getIssueId());
				}

				public int getBatchSize() {
				    return updates.size();
				}
	    });
	}
 
	public Issue getIssueById(long issueId) {
		Issue thread = null;
		if (issueId <= 0L) {
			return thread;
		}		
		try {
			thread = getExtendedJdbcTemplate().queryForObject(getBoundSql("COMMUNITY_WEB.SELECT_ISSUE_BY_ID").getSql(), 
					issueMapper, 
					new SqlParameterValue(Types.NUMERIC, issueId ));
		} catch (DataAccessException e) {
			logger.error(CommunityLogLocalizer.format("013005", issueId), e);
		}
		return thread;
	}
 
	public int getIssueCount(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.COUNT_ISSUE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
			);
	}
 
	public List<Long> getIssueIds(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_WEB.SELECT_ISSUE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
			);
	}
 
	public List<Long> getIssueIds(int objectType, long objectId, int startIndex, int numResults) {
		return getExtendedJdbcTemplate().query(
				getBoundSql("COMMUNITY_WEB.SELECT_ISSUE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				startIndex, 
				numResults, 
				Long.class, 
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
		);
	}

	@Override
	public int getIssueCount(DataSourceRequest dataSourceRequest) {
		
		int objectType = dataSourceRequest.getDataAsInteger("objectType", -1);
		long objectId = dataSourceRequest.getDataAsLong("objectId", -1L);	
		BoundSql sqlSource = getBoundSqlWithAdditionalParameter("COMMUNITY_WEB.COUNT_ISSUE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID", getAdditionalParameter(dataSourceRequest));
		return getExtendedJdbcTemplate().queryForObject(
				sqlSource.getSql(), 
				Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
			);
	}
 
	public List<Long> getIssueIds(DataSourceRequest dataSourceRequest) {
		int objectType = dataSourceRequest.getDataAsInteger("objectType", -1);
		long objectId = dataSourceRequest.getDataAsLong("objectId", -1L);		
		BoundSql sqlSource = getBoundSqlWithAdditionalParameter("COMMUNITY_WEB.SELECT_ISSUE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID", getAdditionalParameter(dataSourceRequest));
		if( dataSourceRequest.getPageSize() > 0 )
		{	
			return getExtendedJdbcTemplate().query(
					sqlSource.getSql(), 
					dataSourceRequest.getSkip(), 
					dataSourceRequest.getPageSize(), 
					Long.class, 
					new SqlParameterValue(Types.NUMERIC, objectType ),
					new SqlParameterValue(Types.NUMERIC, objectId )
			);			
		}else {
			return getExtendedJdbcTemplate().queryForList(
					sqlSource.getSql(), 
					Long.class,
					new SqlParameterValue(Types.NUMERIC, objectType ),
					new SqlParameterValue(Types.NUMERIC, objectId )
			);
		}
	}

	
	public List<Long> getProjectIds(DataSourceRequest dataSourceRequest) {
		BoundSql sqlSource = getBoundSqlWithAdditionalParameter("COMMUNITY_WEB.SELECT_PROJECT_IDS", getAdditionalParameter(dataSourceRequest));
		if( dataSourceRequest.getPageSize() > 0 )
		{	
			return getExtendedJdbcTemplate().query(
					sqlSource.getSql(), 
					dataSourceRequest.getSkip(), 
					dataSourceRequest.getPageSize(), 
					Long.class
			);			
		}else {
			return getExtendedJdbcTemplate().queryForList(
					sqlSource.getSql(), 
					Long.class
			);
		}
	}

 
	public int getProjectCount(DataSourceRequest dataSourceRequest) {
		BoundSql sqlSource = getBoundSqlWithAdditionalParameter("COMMUNITY_WEB.COUNT_PROJECT_IDS", getAdditionalParameter(dataSourceRequest));
		return getExtendedJdbcTemplate().queryForObject(
				sqlSource.getSql(), 
				Integer.class
			);
	}
 
	public void saveOrUpdateTask(Task task) {
		Task taskToUse = task;
		if (taskToUse.getTaskId() < 1L) {
			taskToUse.setTaskId(getNextTaskId());			
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.INSERT_TASK").getSql(),
					new SqlParameterValue(Types.NUMERIC, taskToUse.getTaskId()),
					new SqlParameterValue(Types.NUMERIC, taskToUse.getObjectType()),
					new SqlParameterValue(Types.NUMERIC, taskToUse.getObjectId()),
					new SqlParameterValue(Types.VARCHAR, taskToUse.getTaskName()),
					new SqlParameterValue(Types.VARCHAR, taskToUse.getVersion()),					
					
					
					new SqlParameterValue(Types.NUMERIC, taskToUse.getPrice()),					
					new SqlParameterValue(Types.DATE, taskToUse.getStartDate()),
					new SqlParameterValue(Types.DATE, taskToUse.getEndDate()),
					new SqlParameterValue(Types.VARCHAR, taskToUse.getProgress()),
					
					new SqlParameterValue(Types.VARCHAR, taskToUse.getDescription()),
					new SqlParameterValue(Types.NUMERIC, taskToUse.getUser() == null ? -1L: taskToUse.getUser().getUserId()),	
					new SqlParameterValue(Types.TIMESTAMP, taskToUse.getCreationDate()),
					new SqlParameterValue(Types.TIMESTAMP, taskToUse.getModifiedDate()));					
		} else {
			Date now = Calendar.getInstance().getTime();
			taskToUse.setModifiedDate(now);		
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.UPDATE_TASK").getSql(), 
					new SqlParameterValue(Types.VARCHAR, taskToUse.getTaskName()),
					new SqlParameterValue(Types.VARCHAR, taskToUse.getVersion()),					
					
					new SqlParameterValue(Types.NUMERIC, taskToUse.getPrice()),					
					new SqlParameterValue(Types.DATE, taskToUse.getStartDate()),
					new SqlParameterValue(Types.DATE, taskToUse.getEndDate()),					
					
					new SqlParameterValue(Types.VARCHAR, taskToUse.getProgress()),
					new SqlParameterValue(Types.VARCHAR, taskToUse.getDescription()),				
					new SqlParameterValue(Types.NUMERIC, taskToUse.getUser() == null ? -1L: taskToUse.getUser().getUserId()),	
					new SqlParameterValue(Types.TIMESTAMP, taskToUse.getModifiedDate()),
					new SqlParameterValue(Types.NUMERIC, taskToUse.getTaskId())
			);		
			
		}	
	}
 
	public void deleteTask(Task task) {
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.DELETE_TASK_BY_ID").getSql());
		
	}
 
	public Task getTaskById(long taskId) {
		Task task = null;
		if (taskId <= 0L) {
			return task;
		}		
		try {
			task = getExtendedJdbcTemplate().queryForObject(getBoundSql("COMMUNITY_WEB.SELECT_TASK_BY_ID").getSql(), 
					taskMapper, 
					new SqlParameterValue(Types.NUMERIC, taskId ));
		} catch (DataAccessException e) {
			logger.error(CommunityLogLocalizer.format("013005", taskId), e);
		}
		return task;
	}
 
	private final RowMapper<IssueSummary> summaryMapper = new RowMapper<IssueSummary>() {				
		public IssueSummary mapRow(ResultSet rs, int rowNum) throws SQLException {			
			IssueSummary issue = new IssueSummary(rs.getLong("ISSUE_ID"));			
			issue.setProject( new Project( rs.getLong("PROJECT_ID") ) );
			issue.getProject().setName(rs.getString("PROJECT_NAME"));
			issue.getProject().setContractState(rs.getString("PROJECT_CONTRACT_STATE"));		
			issue.getProject().setContractor(rs.getString("PROJECT_CONTRACTOR"));	 
			issue.setIssueType(rs.getString("ISSUE_TYPE"));
			issue.setStatus(rs.getString("ISSUE_STATUS"));
			issue.setResolution(rs.getString("ISSUE_RESOLUTION"));
			issue.setResolutionDate(rs.getDate("RESOLUTION_DATE"));
			issue.setSummary(rs.getString("ISSUE_SUMMARY"));
			issue.setPriority(rs.getString("ISSUE_PRIORITY"));			
			issue.setAssignee(new UserTemplate(rs.getLong("ASSIGNEE")));
			issue.setRepoter(new UserTemplate(rs.getLong("REPOTER")));			
			issue.setDueDate(rs.getDate("DUE_DATE"));			
			issue.setCreationDate(rs.getDate("CREATION_DATE"));
			issue.setModifiedDate(rs.getDate("MODIFIED_DATE"));		
			issue.setTask(new Task(Models.PROJECT.getObjectType(), rs.getLong("PROJECT_ID"), rs.getLong("TASK_ID"), rs.getString("TASK_NAME")));
			return issue;
		}		
	};
	 
	public int getIssueSummaryCount(DataSourceRequest dataSourceRequest) { 
		BoundSql sqlSource = getBoundSqlWithAdditionalParameter("COMMUNITY_WEB.COUNT_ISSUE_SUMMARY_BY_REQUEST", getAdditionalParameter(dataSourceRequest));
		return getExtendedJdbcTemplate().queryForObject(
				sqlSource.getSql(), 
				Integer.class
			);
	}
		
	public List<IssueSummary> getIssueSummary(DataSourceRequest dataSourceRequest) { 
		BoundSql sqlSource = getBoundSqlWithAdditionalParameter("COMMUNITY_WEB.SELECT_ISSUE_SUMMARY_BY_REQUEST", getAdditionalParameter(dataSourceRequest));
		if( dataSourceRequest.getPageSize() > 0 )
		{	
			return getExtendedJdbcTemplate().query(
					sqlSource.getSql(), 
					dataSourceRequest.getSkip(), 
					dataSourceRequest.getPageSize(), 
					summaryMapper
			);			
		}else {
			return getExtendedJdbcTemplate().query(
					sqlSource.getSql(), 
					summaryMapper
			);
		}
	}

	private Map<String, Object> getAdditionalParameter( DataSourceRequest dataSourceRequest ){
		Map<String, Object> additionalParameter = new HashMap<String, Object>();
		additionalParameter.put("filter", dataSourceRequest.getFilter());
		additionalParameter.put("sort", dataSourceRequest.getSort());		
		additionalParameter.put("data", dataSourceRequest.getData());		
		additionalParameter.put("user", dataSourceRequest.getUser());
		logger.debug("data {}", dataSourceRequest.getData());
		
		return additionalParameter;
	}
 
	
	public void saveOrUpdateScm(Scm scm) {
		Scm scmToUse = scm;
		if (scmToUse.getScmId() < 1L) {
			scmToUse.setScmId(getNextScmId());			
			getExtendedJdbcTemplate().update(getBoundSql("SERVICE_DESK.INSERT_SCM").getSql(),
					new SqlParameterValue(Types.NUMERIC, scmToUse.getScmId()),
					new SqlParameterValue(Types.NUMERIC, scmToUse.getObjectType()),
					new SqlParameterValue(Types.NUMERIC, scmToUse.getObjectId()),
					new SqlParameterValue(Types.VARCHAR, scmToUse.getName()),
					new SqlParameterValue(Types.VARCHAR, scmToUse.getDescription()),	 		
					new SqlParameterValue(Types.VARCHAR, scmToUse.getUrl()),
					new SqlParameterValue(Types.VARCHAR, scmToUse.getUsername()), 
					new SqlParameterValue(Types.VARCHAR, scmToUse.getPassword()),
					
					new SqlParameterValue(Types.VARCHAR, scmToUse.getTags()), 	
					new SqlParameterValue(Types.TIMESTAMP, scmToUse.getCreationDate()),
					new SqlParameterValue(Types.TIMESTAMP, scmToUse.getModifiedDate()));					
		} else {
			Date now = Calendar.getInstance().getTime();
			scmToUse.setModifiedDate(now);		
			getExtendedJdbcTemplate().update(getBoundSql("SERVICE_DESK.UPDATE_SCM").getSql(), 
					new SqlParameterValue(Types.VARCHAR, scmToUse.getName()), 
					new SqlParameterValue(Types.VARCHAR, scmToUse.getDescription()),	
					new SqlParameterValue(Types.VARCHAR, scmToUse.getUrl()),
					new SqlParameterValue(Types.VARCHAR, scmToUse.getUsername()), 
					new SqlParameterValue(Types.VARCHAR, scmToUse.getPassword()),
					new SqlParameterValue(Types.VARCHAR, scmToUse.getTags()), 						
					new SqlParameterValue(Types.TIMESTAMP, scmToUse.getModifiedDate()),
					new SqlParameterValue(Types.NUMERIC, scmToUse.getScmId())
			);		
			if(!scmToUse.getProperties().isEmpty())
				setScmProperties(scmToUse.getScmId(), scmToUse.getProperties()); 
		} 
	}
 
	public void deleteScm(Scm scm) {
		getExtendedJdbcTemplate().update(getBoundSql("SERVICE_DESK.DELETE_SCM_BY_ID").getSql(), new SqlParameterValue(Types.NUMERIC, scm.getScmId()) );
		deleteScmProperties(scm.getScmId());
	}
 
	public Scm getScmById(long scmId) {
		Scm scm = null;
		if (scmId <= 0L) {
			return scm;
		}		
		try {
			scm = getExtendedJdbcTemplate().queryForObject(getBoundSql("SERVICE_DESK.SELECT_SCM_BY_ID").getSql(), 
					scmMapper, 
					new SqlParameterValue(Types.NUMERIC, scmId ));
			
			Map<String, String> properties = getScmProperties(scm.getScmId());
			scm.getProperties().putAll(properties);
			
		} catch (DataAccessException e) {
			logger.error(CommunityLogLocalizer.format("013005", scmId), e);
		}
		return scm;
	}	
}
