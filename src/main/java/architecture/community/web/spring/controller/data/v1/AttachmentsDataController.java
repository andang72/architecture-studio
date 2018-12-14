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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import architecture.community.attachment.Attachment;
import architecture.community.attachment.AttachmentService;
import architecture.community.exception.NotFoundException;
import architecture.community.exception.UnAuthorizedException;
import architecture.community.user.User;
import architecture.community.util.SecurityHelper;
import architecture.community.web.model.ItemList;
import architecture.community.web.model.json.Result;

@Controller("attachments-data-controller")
@RequestMapping("/data/api/v1/attachments")
public class AttachmentsDataController {

	
	@Inject
	@Qualifier("attachmentService")
	private AttachmentService attachmentService;
	
	
	private Logger log = LoggerFactory.getLogger(AttachmentsDataController.class);
	
	@Secured({ "ROLE_USER", "ROLE_ADMINISTRATOR" })
    @RequestMapping(value = "/{attachmentId:[\\p{Digit}]+}/remove.json", method = RequestMethod.POST)
    @ResponseBody
    public Result remove (
    		@PathVariable Long attachmentId,	
    		NativeWebRequest request ) throws NotFoundException, IOException, UnAuthorizedException {
		User user = SecurityHelper.getUser();
		
		Attachment attachment = attachmentService.getAttachment(attachmentId);
		if( attachment.getUser().getUserId() == user.getUserId() || SecurityHelper.isUserInRole("ROLE_ADMINISTRATOR"))
			attachmentService.removeAttachment(attachment);
		else 
			throw new UnAuthorizedException("권한이 없습니다.");
		
		return Result.newResult();
	}
	
	
	@Secured({ "ROLE_USER" })
    @RequestMapping(value = "/upload.json", method = RequestMethod.POST)
    @ResponseBody
    public List<Attachment> upload(
    		@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
    		@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId,
    	    MultipartHttpServletRequest request ) throws NotFoundException, IOException, UnAuthorizedException {

		List<Attachment> list = new ArrayList<Attachment>();
		Iterator<String> names = request.getFileNames();		
		while (names.hasNext()) {
		    String fileName = names.next();
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("upload - file:{}, size:{}, type:{} ", mpf.getOriginalFilename(), mpf.getSize() , mpf.getContentType() );
		    Attachment attachment = attachmentService.createAttachment(objectType, objectId, mpf.getOriginalFilename(), mpf.getContentType(), is, (int) mpf.getSize());
		    
		    attachmentService.saveAttachment(attachment);
		    list.add(attachment);
		}			
		return list;
	}
	
	
	@RequestMapping(value = "/list.json", method = RequestMethod.POST)
	@ResponseBody
	public ItemList list (
    		@RequestParam(value = "objectType", defaultValue = "-1", required = false) Integer objectType,
    		@RequestParam(value = "objectId", defaultValue = "-1", required = false) Long objectId,
    	    @RequestParam(value = "startIndex", defaultValue = "0", required = false) Integer startIndex,
    	    @RequestParam(value = "pageSize", defaultValue = "0", required = false) Integer pageSize,
    		NativeWebRequest request) throws NotFoundException {

		ItemList list = new ItemList();
		
		if( objectType > 0 && objectId > 0 ){
			if( pageSize > 0) {
				List<Attachment> attachments = attachmentService.getAttachments(objectType, objectId, startIndex, pageSize);
				list.setItems(attachments);
				list.setTotalCount(attachmentService.getAttachmentCount(objectType, objectId));
			}else {
				List<Attachment> attachments = attachmentService.getAttachments(objectType, objectId);
				list.setItems(attachments);
				list.setTotalCount(attachments.size());				
			}
		}
		return list;

	}	
}
