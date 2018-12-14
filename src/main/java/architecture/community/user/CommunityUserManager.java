package architecture.community.user;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.community.i18n.CommunityLogLocalizer;
import architecture.community.user.dao.UserDao;
import architecture.community.user.event.UserRemovedEvent;
import architecture.ee.spring.event.EventSupport;
import architecture.ee.util.StringUtils;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class CommunityUserManager extends EventSupport implements UserManager {

	private static final Logger log = LoggerFactory.getLogger(CommunityUserManager.class);

	@Inject
	@Qualifier("userDao")
	private UserDao userDao;

	@Inject
	@Qualifier("passwordEncoder")
	protected PasswordEncoder passwordEncoder;

	@Inject
	@Qualifier("userCache")
	private Cache userCache;

	@Inject
	@Qualifier("userIdCache")
	private Cache userIdCache;

	private boolean emailAddressCaseSensitive;

	public CommunityUserManager() {
		emailAddressCaseSensitive = true;
	}

	public User getUser(User template) {
		return getUser(template, true);
	}

	public User getUser(User template, boolean caseSensitive) {

		User user = null;
		if (template.getUserId() > 0L) {
			log.debug("get user by {}", template.getUserId());
			user = getUserInCache(template.getUserId());
			if (user == null) {
				log.debug("user {} cache does not exist", template.getUserId() );
				try {
					user = userDao.getUserById(template.getUserId());
					updateCaches(user);
				} catch (Throwable e) {
					log.error(CommunityLogLocalizer.getMessage("010005"), e);
				}

			}
		} 
		
		if (user == null && !StringUtils.isNullOrEmpty(template.getUsername())) {
			
			String nameToUse = template.getUsername();
			long userIdToUse = getUserIdInCache(nameToUse); 
			log.debug("find cache by username {} > {}", nameToUse, userIdToUse );
			if (userIdToUse > 0L) {
				user = getUserInCache(userIdToUse);
			}
			if (user == null) {
				if (!caseSensitive) {
					nameToUse = nameToUse.toUpperCase();
				}
				try {
					user = userDao.getUserByUsername(nameToUse);
					updateCaches(user);
				} catch (Throwable e) {
					log.error(CommunityLogLocalizer.getMessage("010004"), e);
				}
			}
		}

		if (null == user && !StringUtils.isNullOrEmpty(template.getEmail())) {
			try {
				user = userDao.getUserByEmail(template.getEmail());
				updateCaches(user);
			} catch (Exception ex) {
				log.debug(CommunityLogLocalizer.getMessage("010006"), ex);
			}
		}
		return user;
	}

	public User getUser(String username) throws UserNotFoundException {
		User user = getUser(((User) (new UserTemplate(username))));
		if (null == user) {
			UserNotFoundException e = new UserNotFoundException(CommunityLogLocalizer.format("010002", username));
			throw e;
		}
		return user;
	}

	public User getUser(long userId) throws UserNotFoundException {
		User user = getUser(((User) (new UserTemplate(userId))));
		if (null == user) {
			UserNotFoundException e = new UserNotFoundException(CommunityLogLocalizer.format("010002", userId));
			throw e;
		}
		return user;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public User createUser(User newUser) throws UserAlreadyExistsException, EmailAlreadyExistsException {
		User user = getUser(newUser);

		if (null != user) {
			if (!user.getUsername().equals(newUser.getUsername())) {
				if (caseEmailAddress(user).equals(caseEmailAddress(newUser))) {
					EmailAlreadyExistsException e = new EmailAlreadyExistsException( CommunityLogLocalizer.format("010014", user.getUsername(), caseEmailAddress(user)));
					throw e;
				}
			} else {
				UserAlreadyExistsException e = new UserAlreadyExistsException( CommunityLogLocalizer.format("010014", user.getUsername(), caseEmailAddress(user)));
				log.info(e.getMessage());
				throw e;
			}
		}

		UserTemplate userTemplate = new UserTemplate(newUser);
		userTemplate.setPassword(newUser.getPassword());
		userTemplate.setPasswordHash(getPasswordHash(newUser));
		userTemplate.setEmail(caseEmailAddress(newUser));
		setTemplateDates(userTemplate);

		user = userDao.createUser(userTemplate);

		userTemplate = new UserTemplate(user);
		userTemplate.setPassword(null);
		updateCaches(userTemplate);
		return userTemplate;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void deleteUser(User user) throws UserNotFoundException {
		User existUser = getUser(user);
		try {
			userDao.deleteUser(existUser);
			evictCaches(user);
			fireEvent(new UserRemovedEvent(this, user));
		} catch (DataAccessException ex) {
			String message = CommunityLogLocalizer.format("010016", user);
			log.error(message, ex);
			throw ex;
		}

	}

	protected void evictCaches(User user) {
		userCache.remove(Long.valueOf(user.getUserId()));
		userIdCache.remove(user.getUsername());
	}

	protected long getUserIdInCache(String username) {
		if (userIdCache.get(username) != null) {
			return (Long) userIdCache.get(username).getObjectValue();
		}
		return -2L;
	}

	protected void updateCaches(User user) {
		if (user != null) {
			log.debug("update cahce {}, {}", user.getUserId(), user.getUsername());
			if (user.getUserId() > 0 && !StringUtils.isNullOrEmpty(user.getUsername())) {
				
				if(userIdCache.get(user.getUsername()) != null)
					userIdCache.remove(user.getUsername());
				
				userIdCache.put(new Element(user.getUsername(), user.getUserId()));
				
				if(userCache.get(user.getUserId()) != null)
					userCache.remove(user.getUserId());				
				
				userCache.put(new Element(user.getUserId(), user));

			}
		}
	}

	protected User getUserInCache(Long userId) {
		if (userCache.get(userId) != null)
			return (User) userCache.get(userId).getObjectValue();
		return null;
	}

	/**
	 * 사용자 객체의 생성일 과 수정일이 널인 경우 현재 일자로 업데이트 한다.
	 * 
	 * @param ut
	 */
	private void setTemplateDates(UserTemplate ut) {
		if (null == ut)
			return;
		if (null == ut.getCreationDate())
			ut.setCreationDate(new Date());
		if (null == ut.getModifiedDate())
			ut.setModifiedDate(new Date());
	}


	private String caseEmailAddress(User user) {
		return emailAddressCaseSensitive || user.getEmail() == null ? user.getEmail() : user.getEmail().toLowerCase();
	}

	@Override
	public List<User> findUsers(String nameOrEmail) {
		List<Long> ids = userDao.findUserIds(nameOrEmail);
		List<User> users = new ArrayList<User>(ids.size());
		for (long id : ids)
			try {
				users.add(getUser(id));
			} catch (UserNotFoundException e) {
				log.warn(e.getMessage(), e);
			}
		return users;
	}

	@Override
	public List<User> findUsers(String nameOrEmail, int startIndex, int numResults) {
		List<Long> ids = userDao.findUserIds(nameOrEmail, startIndex, numResults);
		List<User> users = new ArrayList<User>(ids.size());
		for (long id : ids)
			try {
				users.add(getUser(id));
			} catch (UserNotFoundException e) {
				log.warn(e.getMessage(), e);
			}
		return users;
	}

	@Override
	public int getFoundUserCount(String nameOrEmail) {
		return userDao.getFoundUserCount(nameOrEmail);
	}

	public int getUserCount() {
		return userDao.getUserCount();
	}

	public List<User> getUsers() {
		List<Long> ids = userDao.getUserIds();
		List<User> users = new ArrayList<User>(ids.size());
		for (long id : ids)
			try {
				users.add(getUser(id));
			} catch (UserNotFoundException e) {
				log.warn(e.getMessage(), e);
			}
		return users;
	}

	@Override
	public List<User> getUsers(int startIndex, int numResults) {
		List<Long> ids = userDao.getUserIds(startIndex, numResults);
		List<User> users = new ArrayList<User>(ids.size());
		for (long id : ids)
			try {
				users.add(getUser(id));
			} catch (UserNotFoundException e) {
				log.warn(e.getMessage(), e);
			}
		return users;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void updateUser(User user) throws UserNotFoundException, UserAlreadyExistsException {

		UserTemplate userToUse = new UserTemplate(getUser(user));
		
		if (null == userToUse) {
			throw new UserNotFoundException();
		}

		String previousUsername = null;
		if (!userToUse.getUsername().equals(user.getUsername())) {
			log.debug("previous username is {}. new username is {}." , userToUse.getUsername() , user.getUsername());
			previousUsername = userToUse.getUsername();
			UserTemplate toCheck = new UserTemplate();
			toCheck.setUsername(user.getUsername());
			User match = getUser(toCheck);
			if (null != match && match.getUserId() != user.getUserId()) {
				throw new UserAlreadyExistsException();
			}
		}
		
		if(!StringUtils.isNullOrEmpty(user.getUsername()))
			userToUse.setUsername(user.getUsername());		
		if(!StringUtils.isNullOrEmpty(user.getEmail()))
			userToUse.setEmail( caseEmailAddress(user) );
		userToUse.setEmailVisible(user.isEmailVisible());
		if( !StringUtils.isNullOrEmpty(user.getName()) && !org.apache.commons.lang3.StringUtils.equals(user.getName(), userToUse.getName()))
			userToUse.setName( user.getName() );
		userToUse.setNameVisible( user.isNameVisible() );
		userToUse.setProperties( user.getProperties() );
		userToUse.setEnabled( user.isEnabled() );
		userToUse.setStatus( user.getStatus() );
		userToUse.setModifiedDate(new Date());		
		
		if( !StringUtils.isNullOrEmpty( user.getPassword() ) ){
			userToUse.setPasswordHash(getPasswordHash(user));	
		}else {
			userToUse.setPasswordHash(userToUse.getPassword());
		}		
		wireTemplateDates(userToUse);
		try {
			
			userDao.updateUser(userToUse); 
			// cache 수정 ..
			
			userCache.remove(userToUse.getUserId());
			if (previousUsername != null)
				userIdCache.remove(previousUsername);
			
			/**
			userCache.put(new Element(userToUse.getUserId(), userToUse));
			if (previousUsername != null)
				userIdCache.remove(previousUsername);
			userIdCache.put(new Element(userToUse.getUsername(), userToUse.getUserId())); 
			**/
		} catch (DataAccessException ex) { 
			throw ex;
		}

	}
	
	
	public boolean verifyPassword(User user, String password) {
		if( user.getPassword() == null || StringUtils.isNullOrEmpty(password))
			return false;
		return passwordEncoder.matches(password, user.getPassword());
	}	

	private String getPasswordHash(User user) {
		String passwd;
		passwd = user.getPassword();
		if (StringUtils.isNullOrEmpty(passwd))
			return null;
		try {
			return passwordEncoder.encode(passwd);
		} catch (Exception ex) {
			log.warn(CommunityLogLocalizer.getMessage("010001"), ex);
		}
		return null;
	}
	private void wireTemplateDates(UserTemplate ut) {
		if (null == ut)
			return;
		if (null == ut.getCreationDate())
			ut.setCreationDate(new Date());
		if (null == ut.getModifiedDate())
			ut.setModifiedDate(new Date());
	}
}
