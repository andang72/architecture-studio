package architecture.community.web.spring.controller.data.v1;

import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;

import architecture.community.attachment.AttachmentService;
import architecture.community.image.ImageService;
import architecture.community.query.CustomQueryService;
import architecture.community.security.spring.acls.CommunityAclService;
import architecture.community.viewcount.ViewCountService;

@Controller("data-api-v1-web-controller")
@RequestMapping("/data/api/v1")
public class WebDataController {

	private Logger log = LoggerFactory.getLogger(getClass());	
	
	@Inject
	@Qualifier("imageService")
	private ImageService imageService;
	
	@Inject
	@Qualifier("attachmentService")
	private AttachmentService attachmentService;
		
	@Inject
	@Qualifier("viewCountService")
	private ViewCountService viewCountService
	;	
	
	@Inject
	@Qualifier("communityAclService")
	private CommunityAclService communityAclService;
	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	public WebDataController() { 
	}
	
	
	@RequestMapping(value = "/objects/type/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Map<String, Object>> getObjectTypes(NativeWebRequest request){ 
		List<Map<String, Object>> list = customQueryService.list("COMMUNITY_CS.SELECT_OBJECT_TYPE_ID_AND_NAME");
		return list ;
	}
	
}
