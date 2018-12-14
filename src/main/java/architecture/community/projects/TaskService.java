package architecture.community.projects;

public interface TaskService { 
	
	public abstract Task getTask( long taskId ) throws  TaskNotFoundException ;
	
	public abstract void deleteTask(Task task);
	
	public abstract void saveOrUpdateTask(Task task);

}
