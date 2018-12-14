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

package architecture.community.web.spring.controller.page;

import java.io.IOException;
import java.io.InputStream;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.DatatypeConverter;

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import architecture.community.attachment.Attachment;
import architecture.community.attachment.AttachmentService;
import architecture.community.exception.NotFoundException;
import architecture.community.image.Image;
import architecture.community.image.ImageService;
import architecture.community.image.ThumbnailImage;
import architecture.community.link.ExternalLinkService;
import architecture.community.security.spring.acls.CommunityAclService;
import architecture.community.user.AvatarImage;
import architecture.community.user.UserAvatarService;
import architecture.community.web.spring.controller.data.v1.ImagesDataController;
import architecture.community.web.util.ServletUtils;
import architecture.ee.service.ConfigService;
import architecture.ee.util.StringUtils;

@Controller("download-controller")
@RequestMapping("/download")
public class DownloadController {

	private Logger log = LoggerFactory.getLogger(ImagesDataController.class);

	@Inject
	@Qualifier("imageService")
	private ImageService imageService;
	
	@Inject
	@Qualifier("attachmentService")
	private AttachmentService attachmentService;

	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("externalLinkService")
	private ExternalLinkService externalLinkService;
	
	@Inject
	@Qualifier("userAvatarService")
	private UserAvatarService userAvatarService;
	
	@Inject
	@Qualifier("communityAclService")
	private CommunityAclService communityAclService;
	
	public DownloadController() {
		
	}
	
	@RequestMapping(value = "/proxy", method = RequestMethod.POST)
	public @ResponseBody void save(String fileName, String base64, String contentType, HttpServletResponse response) throws IOException {

	    response.setHeader("Content-Disposition", "attachment;filename=" + fileName); 
	    response.setContentType(contentType); 
	    byte[] data = DatatypeConverter.parseBase64Binary(base64); 
	    response.setContentLength(data.length);
	    response.getOutputStream().write(data);
	    response.flushBuffer();
	}
	
	@PreAuthorize("permitAll")
	@RequestMapping(value = "/avatar/{username:.+}", method = RequestMethod.GET)
	@ResponseBody
	public void getUserAvatarImage (
			@PathVariable("username") String username, 
			@RequestParam(value = "width", defaultValue = "0", required = false) Integer width,
		    @RequestParam(value = "height", defaultValue = "0", required = false) Integer height,
		    HttpServletRequest request,
		    HttpServletResponse response) {
		
		try {
			AvatarImage image = userAvatarService.getAvatareImageByUsername(username);
			if (image != null) {
				InputStream input;
				String contentType;
				int contentLength;				
				if (width > 0 && width > 0) {
					input = userAvatarService.getImageThumbnailInputStream(image, width, height);
					contentType = image.getThumbnailContentType();
					contentLength = image.getThumbnailSize();
				} else {
					input = userAvatarService.getImageInputStream(image);
					contentType = image.getImageContentType();
					contentLength = image.getImageSize();
				}				
				response.setContentType(contentType);
				response.setContentLength(contentLength);
				IOUtils.copy(input, response.getOutputStream());
				response.flushBuffer();
			}
		} catch (Exception e) {
			log.warn(e.getMessage(), e);
			response.setStatus(301);
			String url = ServletUtils.getContextPath(request) + configService.getApplicationProperty("components.download.images.no-avatar-url", "/images/no-avatar.png");
			response.addHeader("Location", url);
		}
	}

	
	@Secured({ "ROLE_USER" })
	@RequestMapping(value = "/files/{fileId:[\\p{Digit}]+}/{filename:.+}", method = { RequestMethod.GET, RequestMethod.POST })
	@ResponseBody
	public void getAttachmentFile(
			@PathVariable("fileId") Long fileId, 
			@PathVariable("filename") String filename,
		    @RequestParam(value = "thumbnail", defaultValue = "false", required = false) boolean thumbnail,
		    @RequestParam(value = "width", defaultValue = "150", required = false) Integer width,
		    @RequestParam(value = "height", defaultValue = "150", required = false) Integer height,
		    HttpServletRequest request,
		    HttpServletResponse response) throws IOException {

		try {
		    if (fileId > 0 && !StringUtils.isNullOrEmpty(filename)) {
		    	
		    		log.debug("name {} decoded {}.", filename, ServletUtils.getEncodedFileName(filename));
		    		
		    		Attachment attachment = 	attachmentService.getAttachment(fileId);
		    		
		    		int objectType = attachment.getObjectType() ;
		    		long objectId = attachment.getObjectId();
		    		
		    		log.debug("checking equals plain : {} , decoded : {} ", 
		    				org.apache.commons.lang3.StringUtils.equals(filename, attachment.getName()) , 
		    				org.apache.commons.lang3.StringUtils.equals(ServletUtils.getEncodedFileName(filename), attachment.getName()));
		    		
		    		if (org.apache.commons.lang3.StringUtils.equals(filename, attachment.getName())) {
		    			if ( thumbnail ) {		    	
		    				boolean noThumbnail = false;		    				
		    				if(attachmentService.hasThumbnail(attachment)) {
			    		    		ThumbnailImage thumbnailImage = new ThumbnailImage();			
			    		    		thumbnailImage.setWidth(width);
			    		    		thumbnailImage.setHeight(height);		    		    		
		    				    try {
									InputStream input = attachmentService.getAttachmentThumbnailInputStream( attachment, thumbnailImage );
									response.setContentType(thumbnailImage.getContentType());
									response.setContentLength( (int) thumbnailImage.getSize() );
									IOUtils.copy(input, response.getOutputStream());
									response.flushBuffer();
								} catch (Exception e) {
									log.warn(e.getMessage(), e);
									noThumbnail = true;
								}
			    			}		    				
		    				if(noThumbnail) {
			    				response.setStatus(301);
			    				String url = ServletUtils.getContextPath(request) + configService.getApplicationProperty("components.download.attachments.no-attachment-url", "/images/no-image.jpg");
			    				response.addHeader("Location", url);
			    			}		    				
		    			} else {
							InputStream input = attachmentService.getAttachmentInputStream(attachment);
							response.setContentType(attachment.getContentType());
							response.setContentLength(attachment.getSize());
							IOUtils.copy(input, response.getOutputStream());
							response.setHeader("contentDisposition", "attachment;filename=" + ServletUtils.getEncodedFileName(attachment.getName()));
							response.flushBuffer();
		    			}
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
	
	
	@RequestMapping(value = "/images/{linkId}", method = RequestMethod.GET)
	@ResponseBody
	public void downloadImageByLink(
			@PathVariable("linkId") String linkId, 
			@RequestParam(value = "thumbnail", defaultValue = "false", required = false) boolean thumbnail,
			@RequestParam(value = "width", defaultValue = "150", required = false) Integer width,
			@RequestParam(value = "height", defaultValue = "150", required = false) Integer height,
			HttpServletRequest request,
			HttpServletResponse response) throws IOException {
		try {
			Image image = imageService.getImageByImageLink(linkId);
			if (image != null) {
				InputStream input;
				String contentType;
				int contentLength;
				if (thumbnail) {
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
			String url = ServletUtils.getContextPath(request) + configService.getApplicationProperty("components.download.images.no-image-url", "/images/no-image.jpg");
			response.addHeader("Location", url);
		}
	}
	
	@RequestMapping(value = "/images/{imageId:[\\p{Digit}]+}/{filename:.+}", method = { RequestMethod.GET , RequestMethod.POST })
	@ResponseBody
	public void downloadImage (
			@PathVariable("imageId") Long imageId, 
			@PathVariable("filename") String filename,
		    @RequestParam(value = "thumbnail", defaultValue = "false", required = false) boolean thumbnail,
		    @RequestParam(value = "width", defaultValue = "150", required = false) Integer width,
		    @RequestParam(value = "height", defaultValue = "150", required = false) Integer height,
		    HttpServletRequest request, HttpServletResponse response) throws IOException {
		
		try {
			if (imageId <= 0 && StringUtils.isNullOrEmpty(filename)) {
				throw new IllegalArgumentException();
			}
		    	log.debug("name {} decoded {}.", filename, ServletUtils.getEncodedFileName(filename));
		    	Image image = 	imageService.getImage(imageId);		    	
		    		
		    	log.debug("checking equals plain : {} , decoded : {} ", 
		    	org.apache.commons.lang3.StringUtils.equals(filename, image.getName()) , 
		    	org.apache.commons.lang3.StringUtils.equals(ServletUtils.getEncodedFileName(filename), image.getName()));
		    		
		    	if (image != null) {
						InputStream input;
						String contentType;
						int contentLength;
						if (width > 0 && width > 0 && thumbnail ) {
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
			String url = ServletUtils.getContextPath(request) + configService.getApplicationProperty("components.download.images.no-image-url", "/images/no-image.jpg");
			response.addHeader("Location", url);
		}
	}
	
	/**
	@RequestMapping(value = "/images/{externalId}", method = RequestMethod.GET)
	@ResponseBody
	public void downloadImage(
			@PathVariable("externalId") String externalId, 
			@RequestParam(value = "width", defaultValue = "0", required = false) Integer width,
			@RequestParam(value = "height", defaultValue = "0", required = false) Integer height,
			HttpServletResponse response) throws IOException {
		try {
			
			ExternalLink link = externalLinkService.getExternalLink(externalId);
			Image image = imageService.getImage(link.getObjectId());
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
			String url = configService.getApplicationProperty("components.download.images.no-logo-url", "/images/common/what-to-know-before-getting-logo-design.png");
			response.addHeader("Location", url);
		}
	}
	
	
	@RequestMapping(value = "/logos/{objectType}/{objectId}", method = RequestMethod.GET)
	@ResponseBody
	public void downloadLogo(
			@PathVariable("objectType") int objectType, 
			@PathVariable("objectId") long objectId,
			@RequestParam(value = "width", defaultValue = "0", required = false) Integer width,
			@RequestParam(value = "height", defaultValue = "0", required = false) Integer height,
			HttpServletResponse response) throws IOException {

		try {
			LogoImage image = imageService.getPrimaryLogoImage(objectType, objectId);
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
			String url = configService.getApplicationProperty("components.download.images.no-logo-url", "/images/common/what-to-know-before-getting-logo-design.png");
			response.addHeader("Location", url);
		}
	}
**/
	
}
