package dashboard.script;
 
 import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;

import architecture.community.exception.UnAuthorizedException;
import architecture.community.query.CustomQueryService;
import architecture.community.query.ParameterValue;
import architecture.community.security.spring.userdetails.CommuintyUserDetails;
import architecture.community.user.User;
import architecture.community.user.UserTemplate;
import architecture.community.util.CommunityConstants;
import architecture.community.web.model.json.DataSourceRequest;
import architecture.community.web.util.ParamUtils;
import architecture.ee.service.ConfigService;
import architecture.ee.util.StringUtils;

public class DashboardLoginData extends architecture.community.web.spring.view.AbstractScriptDataView {

 
	@Inject
	@Qualifier("customQueryService")
	private CustomQueryService customQueryService; 
 
	@Inject
	@Qualifier("configService")
	private ConfigService configService;	
	
	public Object handle(Model model, HttpServletRequest request, HttpServletResponse response) throws Exception{
	
		String username = ParamUtils.getParameter(request, "username", null); 
		if (log.isDebugEnabled()) {
			log.debug("login {} with model '{}'", username , model );
		} 
		if( !StringUtils.isNullOrEmpty(username))
		try{  
			DataSourceRequest dataSourceRequest = new DataSourceRequest () ; //getDataSourceRequest(request);
			dataSourceRequest.setStatement("DASHBOARD.SELECT_CS_MEMBER_BY_ID");
			List<ParameterValue> values = new ArrayList<ParameterValue>();
			values.add(new ParameterValue(1, "", Types.VARCHAR, username));
			dataSourceRequest.setParameters(values); 
			UserTemplate user = customQueryService.queryForObject(
				dataSourceRequest, new RowMapper<UserTemplate>() { 
				public UserTemplate mapRow(ResultSet rs, int rowNum) throws SQLException {
					UserTemplate ut = new UserTemplate();
					ut.setUserId(rs.getLong("cs_member_seq"));
					ut.setUsername(rs.getString("cs_member_id"));
					ut.setPassword(rs.getString("cs_password"));
					ut.setName(rs.getString("cs_member_name"));
					ut.setNameVisible(true);
					ut.setEmail(rs.getString("cs_email"));
					ut.setEmailVisible(true);
					ut.setEnabled(true);

					Map<String, String> properties = new HashMap<String, String>();
					ut.setProperties(properties); 
					
					return ut;
				} 
			}); 
			CommuintyUserDetails details = new CommuintyUserDetails(user, getFinalUserAuthority(user)); 
			UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken( details, null , details.getAuthorities());
			SecurityContextHolder.getContext().setAuthentication(token); 
			response.sendRedirect("/index.html");
		
		}catch(Exception e){
		    log.error(e.getMessage(), e);
		}
		response.sendError(403);
		throw new UnAuthorizedException();
	} 
	
	protected List<GrantedAuthority> getFinalUserAuthority(User user) {		
		if( user.getUserId() <= 0)
			return Collections.EMPTY_LIST;
		String authority = configService.getLocalProperty(CommunityConstants.SECURITY_AUTHENTICATION_AUTHORITY_PROP_NAME);
		List<String> roles = new ArrayList<String>();		
		if(! StringUtils.isNullOrEmpty( authority ))
		{
			authority = authority.trim();
		    if (!roles.contains(authority)) {
		    	roles.add(authority);
		    }
		}
		return AuthorityUtils.createAuthorityList(StringUtils.toStringArray(roles));
	}

}	