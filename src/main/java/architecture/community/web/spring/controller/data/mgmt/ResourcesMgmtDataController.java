package architecture.community.web.spring.controller.data.mgmt;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.inject.Inject;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.exception.NotFoundException;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.util.CommunityConstants;
import architecture.ee.service.ConfigService;

@Controller("secure-resources-data-mgmt-controller")
@RequestMapping("/secure/data/mgmt")
public class ResourcesMgmtDataController {
	
	protected Logger log = LoggerFactory.getLogger(getClass());	
	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Autowired
    private ResourceLoader resourceLoader;
	
	public ResourcesMgmtDataController() { 
	}

	@RequestMapping(value = "/resources/{type}/get.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public FileInfo getTemplateContent( 
    		@PathVariable String type,
	    @RequestParam(value = "path", defaultValue = "", required = false) String path,
	    NativeWebRequest request) throws NotFoundException, IOException { 
		
		File file = resourceLoader.getResource(getResourcePath(type.toLowerCase()) + path).getFile();
		FileInfo fileInfo = new FileInfo(file); 
		fileInfo.setFileContent(file.isDirectory() ? "" : FileUtils.readFileToString(file, "UTF-8"));
		
		return fileInfo;
    }
	
    @RequestMapping(value = "/resources/{type}/list.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public List<FileInfo> getResources(
    	@PathVariable String type,	
	    @RequestParam(value = "path", defaultValue = "", required = false) String path,
	    NativeWebRequest request) throws NotFoundException {
	
    	if( StringUtils.equals(type, "template") || StringUtils.equals(type, "script") || StringUtils.equals(type, "sql")  )
    	{
    		throw new IllegalArgumentException();
    	} 
    	
    	Resource root = resourceLoader.getResource(getResourcePath(type.toLowerCase())); 
    	List<FileInfo> list = new ArrayList<FileInfo>();
		
    	try {
		    File file = root.getFile();
		    if (StringUtils.isEmpty(path)) {
			for (File f : file.listFiles()) {
			    list.add(new FileInfo(file, f));
			}
		    } else {
		    	File targetFile = resourceLoader.getResource(getResourcePath(type.toLowerCase()) + path).getFile();
				for (File f : targetFile.listFiles()) {
				    list.add(new FileInfo(file, f));
				}
		    }
		} catch (IOException e) {
		    log.error(e.getMessage());
		}
    	
    	return list;
    }
    
    
   // VIEW_RENDER_JSP_LOCATION_PROP_NAME
    
    protected String getResourcePath(String type) {
    	if (StringUtils.equals( type , "template"))
    	    return configService.getApplicationProperty(CommunityConstants.VIEW_RENDER_FREEMARKER_TEMPLATE_LOCATION_PROP_NAME, "/WEB-INF/template/ftl/");
    	else if (StringUtils.equals( type , "sql"))
    	    return configService.getApplicationProperty("services.sqlquery.resource.location", "/WEB-INF/sql");
    	else if (StringUtils.equals( type , "script"))
    		return configService.getApplicationProperty("services.script.resource.location", "/WEB-INF/services-script");
    	
    	return null;
    }

    public static class FileInfo {
 
	private boolean directory;
	private String path;
	private String relativePath;
	private String absolutePath;
	private String name;
	private long size;
	private Date lastModifiedDate;
	private String fileContent;

	
	/**
	 * 
	 */
	
	public FileInfo(File file) { 
	    this.lastModifiedDate = new Date(file.lastModified());
	    this.name = file.getName();
	    this.path = file.getPath();
	    this.absolutePath = file.getAbsolutePath();
	    this.directory = file.isDirectory();
	    if (this.directory) {
		this.size = FileUtils.sizeOfDirectory(file);
	    } else {
		this.size = FileUtils.sizeOf(file);
	    }
	}

	public FileInfo(File root, File file) {
	    this.lastModifiedDate = new Date(file.lastModified());
	    this.name = file.getName();
	    this.path = StringUtils.removeStart(file.getAbsolutePath(), root.getAbsolutePath());
	    this.absolutePath = file.getAbsolutePath();
	    this.directory = file.isDirectory();
	    if (this.directory) {
		this.size = FileUtils.sizeOfDirectory(file);
	    } else {
		this.size = FileUtils.sizeOf(file);
	    }

	}

 

	/**
	 * @return fileContent
	 */
	public String getFileContent() {
	    return fileContent;
	}

	/**
	 * @param fileContent
	 *            설정할 fileContent
	 */
	public void setFileContent(String fileContent) {
	    this.fileContent = fileContent;
	}
 
	/**
	 * @return directory
	 */
	public boolean isDirectory() {
	    return directory;
	}

	/**
	 * @param directory
	 *            설정할 directory
	 */
	public void setDirectory(boolean directory) {
	    this.directory = directory;
	}

	/**
	 * @return path
	 */
	public String getPath() {
	    return path;
	}

	/**
	 * @param path
	 *            설정할 path
	 */
	public void setPath(String path) {
	    this.path = path;
	}

	/**
	 * @return absolutePath
	 */
	@JsonIgnore
	public String getAbsolutePath() {
	    return absolutePath;
	}

	/**
	 * @param absolutePath
	 *            설정할 absolutePath
	 */
	public void setAbsolutePath(String absolutePath) {
	    this.absolutePath = absolutePath;
	}

	/**
	 * @return name
	 */
	public String getName() {
	    return name;
	}

	/**
	 * @param name
	 *            설정할 name
	 */
	public void setName(String name) {
	    this.name = name;
	}

	/**
	 * @return size
	 */
	public long getSize() {
	    return size;
	}

	/**
	 * @param size
	 *            설정할 size
	 */
	public void setSize(long size) {
	    this.size = size;
	}

	/**
	 * @return lastModifiedDate
	 */
	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getLastModifiedDate() {
	    return lastModifiedDate;
	}

	/**
	 * @param lastModifiedDate
	 *            설정할 lastModifiedDate
	 */
	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setLastModifiedDate(Date lastModifiedDate) {
	    this.lastModifiedDate = lastModifiedDate;
	}

    }
	
}
