package architecture.community.web.spring.controller.data.v1;

import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;
import java.util.List;

import javax.inject.Inject;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import architecture.community.exception.NotFoundException;
import architecture.community.exception.UnAuthorizedException;
import architecture.community.query.CustomQueryService;
import architecture.community.user.AvatarImage;
import architecture.community.user.AvatarImageNotFoundException;
import architecture.community.user.User;
import architecture.community.user.UserAvatarService;
import architecture.community.user.UserManager;
import architecture.community.user.UserNotFoundException;
import architecture.community.user.UserTemplate;
import architecture.community.util.SecurityHelper;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.community.web.model.json.Result;
import architecture.ee.service.ConfigService;

@Controller("community-data-v1-me-controller")
@RequestMapping("/data/v1/me")
public class MeDataController {

	private Logger log = LoggerFactory.getLogger(ImagesDataController.class);
	
	@Inject
	@Qualifier("userAvatarService")
	private UserAvatarService userAvatarService;
	
	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("userManager")
	private UserManager userManager;

	@Inject
	@Qualifier("passwordEncoder")
	protected PasswordEncoder passwordEncoder;

	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	@Secured({ "ROLE_USER" })
	@RequestMapping(value = "/list_avatar_image.json", method = RequestMethod.POST)
    @ResponseBody
	public List<AvatarImage> getMyAvatarImages () throws UnAuthorizedException {
		User user = SecurityHelper.getUser();				
		if( user.isAnonymous() )			
		    throw new UnAuthorizedException();	
		
		return userAvatarService.getAvatarImages(user);
	}
	
	
   @Secured({ "ROLE_USER" })
   @RequestMapping(value = "/upload_avatar_image.json", method = RequestMethod.POST)
   @ResponseBody
   public Result uploadMyAvatarImage(
   		MultipartHttpServletRequest request) throws NotFoundException, IOException, UnAuthorizedException {
		
		Result result = Result.newResult();
		result.setAnonymous(false);		
		
		User user = SecurityHelper.getUser();				
		if( user.isAnonymous() )			
		    throw new UnAuthorizedException();			
		
		AvatarImage imageToUse = new AvatarImage(user);		
		Iterator<String> names = request.getFileNames();		
		while (names.hasNext()) {
		    String fileName = names.next();
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("upload  file:{}, size:{}, type:{} ", mpf.getOriginalFilename(), mpf.getSize() , mpf.getContentType() );		    
		    imageToUse.setFilename(mpf.getOriginalFilename());
		    imageToUse.setImageContentType(mpf.getContentType());
		    imageToUse.setImageSize((int) mpf.getSize());		    
		    userAvatarService.addAvatarImage(imageToUse, is, user);
		    result.setCount( result.getCount() + 1);
		}
		return result;
   }

   @Secured({ "ROLE_USER" })
   @RequestMapping(value = "/save_or_update_avatar_image.json", method = RequestMethod.POST)
   @ResponseBody
   public Result svaeOrUpdateMyAvatarImage(
   		MultipartHttpServletRequest request) throws NotFoundException, IOException, UnAuthorizedException {
		
		Result result = Result.newResult();
		result.setAnonymous(false);		
		
		User user = SecurityHelper.getUser();				
		if( user.isAnonymous() )			
		    throw new UnAuthorizedException();			
		
		AvatarImage nowImage ;
		try {
			nowImage = userAvatarService.getAvatarImage(user);
		} catch (AvatarImageNotFoundException e) {
			nowImage = null;
		}
		
		AvatarImage imageToUse = new AvatarImage(user);		
		Iterator<String> names = request.getFileNames();		
		while (names.hasNext()) {
		    String fileName = names.next();
		    MultipartFile mpf = request.getFile(fileName);
		    InputStream is = mpf.getInputStream();
		    log.debug("upload  file:{}, size:{}, type:{} ", mpf.getOriginalFilename(), mpf.getSize() , mpf.getContentType() );		    
		    imageToUse.setFilename(mpf.getOriginalFilename());
		    imageToUse.setImageContentType(mpf.getContentType());
		    imageToUse.setImageSize((int) mpf.getSize());		    
		    userAvatarService.addAvatarImage(imageToUse, is, user);
		    result.setCount( result.getCount() + 1);
		}
		return result;
   }

   	@Secured({ "ROLE_USER" })
	@RequestMapping(value = "/profile/save-or-update.json", method = { RequestMethod.POST})
	@ResponseBody
	public Object signupByJson(@RequestBody DataSourceRequest dataSourceRequest, NativeWebRequest request) throws UnAuthorizedException, UserNotFoundException {	
   		
   		User user = SecurityHelper.getUser();				
		Result result = Result.newResult();	
		boolean verified = userManager.verifyPassword(user, dataSourceRequest.getDataAsString("verifyPassword", null));
		result.getData().put("verify", verified);
		
		log.debug("verified : {}", verified );
		
		if( verified )
		{
			UserTemplate userToUse = (UserTemplate) userManager.getUser(user.getUserId());
			String newName = dataSourceRequest.getDataAsString("name", null);
			String newPassowrd = dataSourceRequest.getDataAsString("newPassword", null);
			try {
			
				if(StringUtils.isNotEmpty(newName) )
				{
					userToUse.setName(newName);
				}
				if( StringUtils.isNotEmpty(newPassowrd) )
				{
					userToUse.setPassword(newPassowrd);
				} 
				userManager.updateUser(userToUse);
			
			} catch (Throwable e) {
				result.setError(e);
			}
		}else {
			result.setError(new BadCredentialsException("Verify Failed."));
		}
		return result;	
	}
}
