package architecture.community.projects.event;

import java.util.Hashtable;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.google.common.eventbus.Subscribe;

import architecture.ee.service.ConfigService;

public class IssueStateChangeEventListener  {

	protected Logger logger = LoggerFactory.getLogger(getClass());
	
	private static Map<Long, SseEmitter> sseEmitters = new Hashtable<Long, SseEmitter>();
	
	public IssueStateChangeEventListener() { 
	} 
	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;

	@PostConstruct
	public void initialize() throws Exception {
		if( configService != null)
		{
			configService.registerEventListener(this);
		}
	}
	
	@PreDestroy
	public void destory(){
		if( configService != null)
		{
			configService.unregisterEventListener(this);
		}
	}
	
	@Subscribe 
	public void handelIssueStateChangeEvent(IssueStateChangeEvent e) {
		logger.debug("ISSUE User : {}, STATE :{}" , e.getUser().getUsername(), e.getState().name() );
	}
		
}