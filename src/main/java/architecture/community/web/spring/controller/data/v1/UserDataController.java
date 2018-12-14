package architecture.community.web.spring.controller.data.v1;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.NativeWebRequest;

import architecture.community.query.CustomQueryService;
import architecture.community.security.spring.userdetails.CommuintyUserDetails;
import architecture.community.user.User;
import architecture.community.user.UserManager;
import architecture.community.user.UserNotFoundException;
import architecture.community.util.SecurityHelper;
import architecture.community.web.model.ItemList;
import architecture.community.web.model.json.DataSourceRequest;

@Controller("community-data-v1-user-controller")
@RequestMapping("/data/api/v1/users")
public class UserDataController {
		
	@Inject
	@Qualifier("userManager")
	private UserManager userManager;
	
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService;
	
	@PreAuthorize("permitAll")
    @RequestMapping(value = "/find_v2.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public ItemList findUsersBy(
    	@RequestBody DataSourceRequest dataSourceRequest, NativeWebRequest request) {	 
		ItemList list = new ItemList();
		dataSourceRequest.setStatement("COMMUNITY_USER.FIND_USER_IDS_BY_REQUEST");
		List<Long> ids = customQueryService.list(dataSourceRequest, Long.class);
		List<User> items = new ArrayList<User>(ids.size());
		
		for( Long userId : ids ) {
			User user;
			try {
				user = userManager.getUser(userId);
				items.add(user);
			} catch (UserNotFoundException e) {
			}
		}
		
		list.setTotalCount(items.size());
		list.setItems(items);
		
		return list;
	}
	
	
	@PreAuthorize("permitAll")
    @RequestMapping(value = "/find.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public ItemList findUsers(
    		@RequestParam(value = "nameOrEmail", required = false) String nameOrEmail,
    		@RequestParam(value = "skip", defaultValue = "0", required = false) int skip,
		@RequestParam(value = "page", defaultValue = "0", required = false) int page,
		@RequestParam(value = "pageSize", defaultValue = "0", required = false) int pageSize, NativeWebRequest request) {				
		ItemList list = new ItemList();
		if( StringUtils.isNotEmpty(nameOrEmail))
		{
			int totalCount = userManager.getFoundUserCount(nameOrEmail);
			if( totalCount > 0 ) {
				List<User> users;
				if( pageSize > 0 ) {
					users = userManager.findUsers(nameOrEmail, skip, pageSize);					
				}else {
					users = userManager.findUsers(nameOrEmail);
				}
				list.setTotalCount(totalCount);
				list.setItems(users);
			}
		}
		return list;
	}

	
	@PreAuthorize("permitAll")
    @RequestMapping(value = "/me.json", method = { RequestMethod.POST, RequestMethod.GET })
    @ResponseBody
    public UserDetails getUserDetails(Authentication authentication, NativeWebRequest request) {		
		if( authentication != null ) {
			CommuintyUserDetails userDetails = (CommuintyUserDetails) authentication.getPrincipal();
			return new UserDetails(userDetails.getUser(), getRoles(userDetails.getAuthorities()));
		}else {
			return new UserDetails(SecurityHelper.ANONYMOUS, Collections.EMPTY_LIST);
		}
	}
	
	protected List<String> getRoles(Collection<GrantedAuthority> authorities) {
		List<String> list = new ArrayList<String>();
		for (GrantedAuthority auth : authorities) {
		    list.add(auth.getAuthority());
		}
		return list;
	}
		
	public static class UserDetails {
		private User user;		
		private List<String> roles;
		
		public UserDetails() {
		}
		
		public UserDetails(User user, List<String> roles) {
		    this.user = user;
		    this.roles = roles;
		}

		/**
		 * @return user
		 */
		public User getUser() {
		    return user;
		}

		/**
		 * @param user
		 *            설정할 user
		 */
		public void setUser(User user) {
		    this.user = user;
		}

		/**
		 * @return roles
		 */
		public List<String> getRoles() {
		    return roles;
		}

		/**
		 * @param roles
		 *            설정할 roles
		 */
		public void setRoles(List<String> roles) {
		    this.roles = roles;
		}
	}
	
}