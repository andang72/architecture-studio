package architecture.community.components.mail;

import org.springframework.context.ApplicationEvent;

import architecture.community.user.User;

public class MailEvent extends ApplicationEvent {
 
	public enum State {

		INBOUND,

		MOVED
	};
	
	private String eventType = "EMAIL";
	
	private User user;

	private State state;
	
	public MailEvent(InboundMessage source, User user, State state) {
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
