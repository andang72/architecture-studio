package architecture.community.projects;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;

import architecture.community.projects.dao.ProjectDao;
import architecture.community.user.UserManager;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class CommunityTaskService implements TaskService {
	
	private Logger logger = LoggerFactory.getLogger(getClass().getName());
	
	@Inject
	@Qualifier("projectDao")
	private ProjectDao projectDao;
	
	@Inject
	@Qualifier("taskCache")
	private Cache taskCache;	
	
	@Inject
	@Qualifier("userManager")
	private UserManager userManager;

	public Task getTask(long taskId) throws TaskNotFoundException {
		Task task = getTaskInCache(taskId);		
		if( task == null ) {
			task = projectDao.getTaskById(taskId);
			if( task != null && task.getTaskId() > 0 ) {
				if( task.getUser().getUserId() > 0)
					task.setUser( userManager.getUser(task.getUser())); 
				if( taskCache!=null )
					taskCache.put(new Element(taskId, task ));
			}
		}
		if( task == null )
			throw new TaskNotFoundException(); 
		return task;
	}
 
	public void deleteTask(Task task) {
		if( task.getTaskId() > 0L) {
			if( taskCache!=null && task.getTaskId() > 0 && taskCache.get(task.getTaskId()) != null  ) {
				taskCache.remove(task.getTaskId());
			}  
			projectDao.deleteTask(task);
		}
	}
 
	public void saveOrUpdateTask(Task task) {
		logger.debug("save or update {}. ", task );
		boolean isNew = true;
		if( task.getTaskId() > 0 ) {
			isNew = false; 
		}else { 
		}
		
		if( taskCache!=null && task.getTaskId() > 0 && taskCache.get(task.getTaskId()) != null  ) {
			taskCache.remove(task.getTaskId());
		} 
		logger.debug("save or update {}" , task );
		projectDao.saveOrUpdateTask(task);
		
	}
	   
	protected Task getTaskInCache(long taskId){
		if( taskCache!=null && taskCache.get(taskId) != null && taskId > 0L )
			return  (Task) taskCache.get( taskId ).getObjectValue();
		else 
			return null;
	}
}
