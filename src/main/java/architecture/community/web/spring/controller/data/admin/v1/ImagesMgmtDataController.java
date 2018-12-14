package architecture.community.web.spring.controller.data.admin.v1;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;

import architecture.community.exception.NotFoundException;
import architecture.community.image.DefaultImage;
import architecture.community.image.Image;
import architecture.community.image.ImageLink;
import architecture.community.image.ImageService;
import architecture.community.model.Property;
import architecture.community.query.CustomQueryService;
import architecture.community.security.spring.acls.CommunityAclService;
import architecture.community.web.model.ItemList;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.community.web.model.json.Result;
import architecture.ee.service.ConfigService;
import architecture.ee.util.StringUtils;

@Controller("data-api-v1-mgmt-images-controller")
@RequestMapping("/data/api/mgmt/v1")
public class ImagesMgmtDataController {

	@Inject
	@Qualifier("communityAclService")
	private CommunityAclService communityAclService;

	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;

	@Inject
	@Qualifier("imageService")
	private ImageService imageService;
	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	public ImagesMgmtDataController() { 
	}

	/**
	 * IMAGES API 
	******************************************/
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public ItemList getImages(
		@RequestBody DataSourceRequest dataSourceRequest, 
		NativeWebRequest request) {
		
		if( !dataSourceRequest.getData().containsKey("objectType")) {
			dataSourceRequest.getData().put("objectType", -1);
		}	
		if( !dataSourceRequest.getData().containsKey("objectId") ) {
			dataSourceRequest.getData().put("objectId", -1);
		}
		
		dataSourceRequest.setStatement("COMMUNITY_CS.COUNT_IMAGE_BY_REQUEST");
		int totalCount = customQueryService.queryForObject(dataSourceRequest, Integer.class);
		dataSourceRequest.setStatement("COMMUNITY_CS.SELECT_IMAGE_IDS_BY_REQUEST");
		List<Long> items = customQueryService.list(dataSourceRequest, Long.class);
		List<Image> images = new ArrayList<Image>(totalCount);
		for( Long id : items ) {
			try {
				images.add(imageService.getImage(id));
			} catch (NotFoundException e) {
			}
		}
		return new ItemList(images, totalCount );
	}	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/save-or-update.json", method = { RequestMethod.POST })
	@ResponseBody
	public Image saveOrUpdate(@RequestBody DefaultImage image, NativeWebRequest request) throws NotFoundException {
		
		DefaultImage imageToUse = 	(DefaultImage)imageService.getImage(image.getImageId());
		if( !StringUtils.isNullOrEmpty(image.getName()) )
		{
			imageToUse.setName(image.getName());
		}
		if( imageToUse.getObjectType() != image.getObjectType())
		{
			imageToUse.setObjectType(image.getObjectType());
		}
		if( imageToUse.getObjectId() != image.getObjectId())
		{
			imageToUse.setObjectId(image.getObjectId());
		}
		imageService.saveOrUpdate(imageToUse); 
		return imageToUse;
	}

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/imagebrowser/{objectType:[\\p{Digit}]+}/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public ItemList getImagesByObjectType(
		@RequestBody DataSourceRequest dataSourceRequest, 	
		@PathVariable Integer objectType,
		NativeWebRequest request) {
		dataSourceRequest.setData("objectType", objectType);
		
		dataSourceRequest.setStatement("COMMUNITY_CS.SELECT_IMAGE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID");
		List<Long> items = customQueryService.list(dataSourceRequest, Long.class);
		List<Image> images = new ArrayList<Image>(items.size());
		for( Long id : items ) {
			try {
				images.add(imageService.getImage(id));
			} catch (NotFoundException e) {
			}
		}
		return new ItemList(images, images.size() );
	}
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/imagebrowser/{objectType:[\\p{Digit}]+}/{objectId:[\\p{Digit}]+}/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public ItemList getImagesByObjectTypeAndObjectId(
		@PathVariable Integer objectType,
		@PathVariable Long objectId,
		@RequestBody DataSourceRequest dataSourceRequest,
		NativeWebRequest request) {
		
		dataSourceRequest.setData("objectType", objectType);
		dataSourceRequest.setData("objectId", objectId);
		
		dataSourceRequest.setStatement("COMMUNITY_CS.SELECT_IMAGE_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID");
		List<Long> items = customQueryService.list(dataSourceRequest, Long.class);
		List<Image> images = new ArrayList<Image>(items.size());
		for( Long id : items ) {
			try {
				images.add(imageService.getImage(id));
			} catch (NotFoundException e) {
			}
		}
		return new ItemList(images, images.size() );
		
	}	
	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/delete.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public Result removeImageAndLink (
		@PathVariable Long imageId,
		@RequestBody DataSourceRequest dataSourceRequest, 
		NativeWebRequest request) throws NotFoundException {
		
		Image image = 	imageService.getImage(imageId);
		imageService.deleteImage(image);
		
		return Result.newResult();
	}	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/get.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public Image getImage (
		@PathVariable Long imageId, 
		NativeWebRequest request) throws NotFoundException {
		Image image = 	imageService.getImage(imageId);
		return image;
	}
	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/link.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public ImageLink getImageLinkAndCreateIfNotExist (
		@PathVariable Long imageId,
		@RequestParam(value = "create", defaultValue = "false", required = false) Boolean createIfNotExist,
		NativeWebRequest request) throws NotFoundException {
		
		Image image = 	imageService.getImage(imageId);
		return imageService.getImageLink(image, createIfNotExist);
	}	
	
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/properties/list.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> getImageProperties (
		@PathVariable Long imageId, 
		NativeWebRequest request) throws NotFoundException {
		Image image = 	imageService.getImage(imageId);
		Map<String, String> properties = image.getProperties(); 
		return toList(properties);
	}

	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/properties/update.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> updateImageProperties (
		@PathVariable Long imageId, 
		@RequestBody List<Property> newProperties,
		NativeWebRequest request) throws NotFoundException {
		Image image = 	imageService.getImage(imageId);
		Map<String, String> properties = image.getProperties();   
		// update or create
		for (Property property : newProperties) {
		    properties.put(property.getName(), property.getValue().toString());
		} 
		imageService.saveOrUpdate(image); 
		return toList(image.getProperties());
	}
	
	@Secured({ "ROLE_ADMINISTRATOR" })
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/properties/delete.json", method = { RequestMethod.POST, RequestMethod.GET })
	@ResponseBody
	public List<Property> deleteImageProperties (
		@PathVariable Long imageId, 
		@RequestBody List<Property> newProperties,
		NativeWebRequest request) throws NotFoundException {
		Image image = 	imageService.getImage(imageId);
		Map<String, String> properties = image.getProperties();  
		for (Property property : newProperties) {
		    properties.remove(property.getName());
		}
		imageService.saveOrUpdate(image);
		return toList(image.getProperties());
	}
	
	protected List<Property> toList(Map<String, String> properties) {
		List<Property> list = new ArrayList<Property>();
		for (String key : properties.keySet()) {
		    String value = properties.get(key);
		    list.add(new Property(key, value));
		}
		return list;
	} 
}
