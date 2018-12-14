package architecture.community.projects.event;

import org.springframework.context.ApplicationEvent;

import architecture.community.projects.Issue;
import architecture.community.user.User;

public class IssueStateChangeEvent extends ApplicationEvent {
	
	public enum State {

		CREATED,

		UPDATED,

		DELETED,

		MOVED
	};
	
	private String eventType = "ISSUE";
	
	private User user;

	private State state;
	
	public IssueStateChangeEvent(Issue source, User user, State state) {
		super(source);
		this.user = user;
		this.state = state;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public State getState() {
		return state;
	}

	public void setState(State state) {
		this.state = state;
	}

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

}
