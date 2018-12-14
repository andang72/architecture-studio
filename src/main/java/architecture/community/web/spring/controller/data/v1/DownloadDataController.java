package architecture.community.web.spring.controller.data.v1;

import java.io.IOException;

import javax.inject.Inject;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;

import architecture.community.services.CommunityDataService;
import architecture.community.web.model.json.DataSourceRequest;

@Controller("download-data-controller")
@RequestMapping("/data/api/v1/export")
public class DownloadDataController {

	private Logger log = LoggerFactory.getLogger(DownloadDataController.class);

	
	@Inject
	@Qualifier("customDataService")
	private CommunityDataService dataService;
	
	public DownloadDataController() {
	}
	
	@Secured({ "ROLE_DEVELOPER" })
	@RequestMapping(value = "/excel/{name:.+}", method = { RequestMethod.POST, RequestMethod.GET})
	@ResponseBody
	public void exportAsExcel (
			@PathVariable("name") String name, 
			@RequestParam(value = "data", required = false) String jsonData,
		    HttpServletResponse response) throws IOException {		
		
		ObjectMapper mapper = new ObjectMapper();
		DataSourceRequest dataSourceRequest = mapper.readValue(jsonData, DataSourceRequest.class);		
		
		log.debug("request data {}", dataSourceRequest.getData() );		
		dataService.export(name, dataSourceRequest, response);
		log.debug("export done.");
	}
}
