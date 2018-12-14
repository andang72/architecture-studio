/**
 *    Copyright 2015-2017 donghyuck
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package architecture.community.web.spring.controller.data.v1;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import architecture.community.exception.NotFoundException;
import architecture.community.exception.UnAuthorizedException;
import architecture.community.image.DefaultImage;
import architecture.community.image.Image;
import architecture.community.image.ImageLink;
import architecture.community.image.ImageService;
import architecture.community.link.ExternalLink;
import architecture.community.link.ExternalLinkService;
import architecture.community.model.ModelObjectAwareSupport;
import architecture.community.model.Models;
import architecture.community.user.User;
import architecture.community.util.SecurityHelper;
import architecture.ee.service.ConfigService;

@Controller("images-data-controller")
@RequestMapping("/data/api/v1/images")

public class ImagesDataController {

	private Logger log = LoggerFactory.getLogger(ImagesDataController.class);

	@Inject
	@Qualifier("imageService")
	private ImageService imageService;

	@Inject
	@Qualifier("configService")
	private ConfigService configService;

	@Inject
	@Qualifier("externalLinkService")
	private ExternalLinkService externalLinkService;
	
	
	public ImagesDataController() {
	}

	@Secured({ "ROLE_USER" })
    @RequestMapping(value = "/upload.json", method = RequestMethod.POST)
    @ResponseBody
    public List<Image> uploadImage(
    		@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
    		@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId,
    		MultipartHttpServletRequest request) throws NotFoundException, IOException, UnAuthorizedException {

		User user = SecurityHelper.getUser();
		List<Image> list = new ArrayList<Image>();
		Iterator<String> names = request.getFileNames();		
		while (names.hasNext()) {
		    String fileName = names.next();
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("upload file:{}, size:{}, type:{} ", mpf.getOriginalFilename(), mpf.getSize() , mpf.getContentType() );
		    Image image = imageService.createImage(objectType, objectId, mpf.getOriginalFilename(), mpf.getContentType(), is, (int) mpf.getSize());
    			image.setUser(user);		    
		    imageService.saveImage(image);
		    list.add(image);
		}			
		return list;
    }


	/**
	 * 이미지를 생성 / 업데이트 하고 동시에 타 모듈에서 이미지를 보여주기 위한 링크키를 생성하여 리턴한다. 
	 * (링크키는 없는 경우에만 생성된다.)
	 * 
	 * @param objectType
	 * @param objectId
	 * @param imageId
	 * @param request
	 * @return
	 * @throws NotFoundException
	 * @throws IOException
	 * @throws UnAuthorizedException
	 */
	@Secured({ "ROLE_USER" })
    @RequestMapping(value = "/upload_image_and_link.json", method = RequestMethod.POST)
    @ResponseBody
    public List<ImageLink> uploadImageAndRetureLink(
    		@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
    		@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId,
    		@RequestParam(value = "imageId", defaultValue = "0", required = false) Long imageId,
    		MultipartHttpServletRequest request) throws NotFoundException, IOException, UnAuthorizedException {

		User user = SecurityHelper.getUser();
		if( user.isAnonymous() )
		    throw new UnAuthorizedException();
		
		List<ImageLink> list = new ArrayList<ImageLink>();
			
		Iterator<String> names = request.getFileNames();		
		while (names.hasNext()) {
		    String fileName = names.next();
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("upload objectType: {}, objectId:{}, image : {}, file:{}, size:{}, type:{} ", objectType, objectId, imageId,  mpf.getOriginalFilename(), mpf.getSize() , mpf.getContentType() );
		    
		    Image image;
		    if (imageId > 0) {
			    	image = imageService.getImage(imageId);	
			    	image.setUser(user);
			    	((DefaultImage) image).setName(mpf.getOriginalFilename());
			    	((DefaultImage) image).setInputStream(is);
			    	((DefaultImage) image).setSize((int) mpf.getSize());
		    } else {
			    	image = imageService.createImage(objectType, objectId, mpf.getOriginalFilename(), mpf.getContentType(), is, (int) mpf.getSize());
			    	image.setUser(user);
		    }		    
		    imageService.saveImage(image);
		    ImageLink link = imageService.getImageLink(image, true);
		    link.setFilename(image.getName());
		    list.add( link ) ;
		    
		}			
		return list ;
		//externalLinkService.getExternalLink(new ModelObjectAwareSupport(Models.IMAGE.getObjectType(), imageToUse.getImageId()), true);
    }

	@Secured({ "ROLE_USER" })
    @RequestMapping(value = "/upload_image_and_external_link.json", method = RequestMethod.POST)
    @ResponseBody
    public List<ExternalLink> uploadImageAndRetureExternalLink(
    		@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
    		@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId,
    		@RequestParam(value = "imageId", defaultValue = "0", required = false) Long imageId,
    		MultipartHttpServletRequest request) throws NotFoundException, IOException, UnAuthorizedException {

		User user = SecurityHelper.getUser();
		if( user.isAnonymous() )
		    throw new UnAuthorizedException();
	
		Image imageToUse = null ;		
		Iterator<String> names = request.getFileNames();		
		List<ExternalLink> list = new ArrayList<ExternalLink>();
		while (names.hasNext()) {
		    String fileName = names.next();
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("upload image {}, file:{}, size:{}, type:{} ", imageId,  mpf.getOriginalFilename(), mpf.getSize() , mpf.getContentType() );
		    Image image;
		    if (imageId > 0) {
			    	image = imageService.getImage(imageId);			
			    	((DefaultImage) image).setName(mpf.getOriginalFilename());
			    	((DefaultImage) image).setInputStream(is);
			    	((DefaultImage) image).setSize((int) mpf.getSize());
		    } else {
			    	image = imageService.createImage(objectType, objectId, mpf.getOriginalFilename(), mpf.getContentType(), is, (int) mpf.getSize());
			    	image.setUser(user);
		    }		    
		    imageService.saveImage(image);
		    imageToUse = image;
		    list.add(externalLinkService.getExternalLink(new ModelObjectAwareSupport(Models.IMAGE.getObjectType(), imageToUse.getImageId()), true) );
		}			
		return list ;
    }
	
	/*
	@Secured({ "ROLE_USER" })
    @RequestMapping(value = "/upload_image.json", method = RequestMethod.POST)
    @ResponseBody
    public Image upload(
    		@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
    		@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId,
    		@RequestParam(value = "imageId", defaultValue = "0", required = false) Long imageId,
    		MultipartHttpServletRequest request) throws NotFoundException, IOException, UnAuthorizedException {

		User user = SecurityHelper.getUser();
		if( user.isAnonymous() )
		    throw new UnAuthorizedException();
	
		Iterator<String> names = request.getFileNames();		
		while (names.hasNext()) {
		    String fileName = names.next();
		    log.debug(fileName);
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("imageId: " + imageId);
		    log.debug("file name: " + mpf.getOriginalFilename());
		    log.debug("file size: " + mpf.getSize());
		    log.debug("file type: " + mpf.getContentType());
		    log.debug("file class: " + is.getClass().getName());
		    Image image;
		    if (imageId > 0) {
		    	image = imageService.getImage(imageId);			
		    	((DefaultImage) image).setName(mpf.getOriginalFilename());
		    	((DefaultImage) image).setInputStream(is);
		    	((DefaultImage) image).setSize((int) mpf.getSize());
		    } else {
		    	image = imageService.createImage(objectType, objectId, mpf.getOriginalFilename(), mpf.getContentType(), is, (int) mpf.getSize());
		    	image.setUser(user);
		    }		    
		    imageService.saveImage(image);
		    return image;
		}
		return null;
    }
	
	@RequestMapping(value = "/{imageId}/{filename:.+}", method = RequestMethod.GET)
	@ResponseBody
	public void handleImage(@PathVariable("imageId") Long imageId, @PathVariable("filename") String filename,
			@RequestParam(value = "width", defaultValue = "0", required = false) Integer width,
			@RequestParam(value = "height", defaultValue = "0", required = false) Integer height,
			HttpServletResponse response) throws IOException {

		log.debug(" ------------------------------------------");
		log.debug("imageId:" + imageId);
		log.debug("width:" + width);
		log.debug("height:" + height);
		log.debug("------------------------------------------");
		try {
			if (imageId > 0 && !StringUtils.isNullOrEmpty(filename)) {
				Image image = imageService.getImage(imageId);
				User user = SecurityHelper.getUser();
				image.setUser(user);
				if (filename.equals(image.getName())) {
					InputStream input;
					String contentType;
					int contentLength;
					if (width > 0 && width > 0) {
						input = imageService.getImageThumbnailInputStream(image, width, height);
						contentType = image.getThumbnailContentType();
						contentLength = image.getThumbnailSize();
					} else {
						input = imageService.getImageInputStream(image);
						contentType = image.getContentType();
						contentLength = image.getSize();
					}
					response.setContentType(contentType);
					response.setContentLength(contentLength);
					IOUtils.copy(input, response.getOutputStream());
					response.flushBuffer();
				} else {
					throw new NotFoundException();
				}
			} else {
				throw new NotFoundException();
			}
		} catch (NotFoundException e) {
			response.sendError(404);
		}
	}

	@RequestMapping(value = "/logo/{type}/{name}", method = RequestMethod.GET)
	@ResponseBody
	public void handleLogoImage(@PathVariable("type") int objectType, @PathVariable("name") String name,
			@RequestParam(value = "width", defaultValue = "0", required = false) Integer width,
			@RequestParam(value = "height", defaultValue = "0", required = false) Integer height,
			HttpServletResponse response) throws IOException {

		try {
			LogoImage image = null;
			Long objectId = -1L;

			image = imageService.getPrimaryLogoImage(objectType, objectId);

			if (image != null) {
				InputStream input;
				String contentType;
				int contentLength;
				if (width > 0 && width > 0) {
					input = imageService.getImageThumbnailInputStream(image, width, height);
					contentType = image.getThumbnailContentType();
					contentLength = image.getThumbnailSize();
				} else {
					input = imageService.getImageInputStream(image);
					contentType = image.getContentType();
					contentLength = image.getSize();
				}

				response.setContentType(contentType);
				response.setContentLength(contentLength);
				IOUtils.copy(input, response.getOutputStream());
				response.flushBuffer();
			}

		} catch (Exception e) {
			log.warn(e.getMessage(), e);
			response.setStatus(301);
			String url = configService.getApplicationProperty("components.download.images.no-logo-url", "/images/no-image.jpg");
			response.addHeader("Location", url);
		}
	}
**/
}
