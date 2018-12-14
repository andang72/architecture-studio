package architecture.community.wiki;

import java.util.ArrayList;
import java.util.List;

import javax.inject.Inject;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.community.user.User;
import architecture.community.user.UserManager;
import architecture.community.user.UserNotFoundException;
import architecture.community.wiki.dao.WikiDao;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class CommunityWikiService implements WikiService {


	private Logger log = LoggerFactory.getLogger(getClass());

	@Inject
	@Qualifier("userManager")
	private UserManager userManager;

	@Inject
	@Qualifier("wikiDao")
	private WikiDao wikiDao; 
	
	@Inject
	@Qualifier("wikiCache")
	private Cache wikiCache;

	@Inject
	@Qualifier("wikiIdCache")
	private Cache wikiIdCache;

	@Inject
	@Qualifier("wikiVersionCache")
	private Cache wikiVersionCache;

	@Inject
	@Qualifier("wikiVersionsCache")
	private Cache wikiVersionsCache; 
	
	public CommunityWikiService() {

	} 
	
	public Wiki createWiki(User user,String name, String title, String body) {
		
		if (name == null)
			throw new IllegalArgumentException("A wiki name is required to create a wiki.");
		Wiki wiki = new Wiki(); 
		if( StringUtils.isNotEmpty( name ))
			wiki.setName(name);
		else 
			wiki.setName(RandomStringUtils.random(64, true, true));
		wiki.setBodyContent(new BodyContent(-1L, -1L, body));
		wiki.setTitle(title);
		wiki.setCreater(user);
		return wiki;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateWiki(Wiki page) {
		saveOrUpdateWiki(page, false);
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateWiki(Wiki wiki, boolean forceNewVersion) {
		boolean isNewWiki = wiki.getWikiId() < 1L;
		boolean isNewVersionRequired = isNewVersionRequired(forceNewVersion, isNewWiki);
 
		
		if (isNewWiki) {
			wikiDao.create(wiki);
			//fireEvent(new PageEvent(page, PageEvent.Type.CREATED));
		} else {
			wikiDao.update(wiki, isNewVersionRequired);
			/*if (page.getWikiState() == PageState.DELETED) {
				fireEvent(new PageEvent(page, PageEvent.Type.DELETED));
			} else {
				fireEvent(new PageEvent(page, PageEvent.Type.UPDATED));
			}
			*/
		} 
		
		if (wikiCache.get(wiki.getWikiId()) != null) {
			wikiCache.remove(wiki.getWikiId()); 
		}
		
		String key = getVersionListCacheKey(wiki.getWikiId());
		if (wikiVersionsCache.get(key) != null) {
			wikiVersionsCache.remove(key);
		}
	}

	private boolean isNewVersionRequired(boolean forceNewVersion, boolean isNewPage) {
		boolean isNewVersionRequired = false;
		if (isNewPage)
			isNewVersionRequired = false;
		else if (forceNewVersion)
			isNewVersionRequired = true;
		return isNewVersionRequired;
	}

	public Wiki getWiki(long wikiId) throws WikiNotFoundException {
		if (wikiId < 1)
			throw new WikiNotFoundException();

		Wiki wiki = null;
		if (wikiCache.get(wikiId) != null) {
			wiki = (Wiki) wikiCache.get(wikiId).getObjectValue();
		}
		if (wiki == null) {
			try {
				wiki = wikiDao.getWikiById(wikiId);
				if (wiki == null)
					throw new WikiNotFoundException();				
				setUserInWiki(wiki);
				if (WikiState.PUBLISHED == wiki.getWikiState())
					wikiCache.put(new Element(wikiId, wiki));				
				wikiIdCache.put(new Element(wiki.getName(), wikiId));				
			} catch (Exception e) {
				throw new WikiNotFoundException(e);
			}
		}
		return wiki;
	}

	public Wiki getWiki(long wikiId, int versionId) throws WikiNotFoundException {
		if (wikiId < 1)
			throw new WikiNotFoundException();
		Wiki wiki = findInLocalCache(wikiId, versionId);
		if (wiki == null) {
			try {
				wiki = wikiDao.getWikiById(wikiId, versionId);
				if (wiki == null)
					throw new WikiNotFoundException(); 
				setUserInWiki(wiki);
				WikiVersion wikiVersion = WikiVersionHelper.getPublishedWikiVersion(wikiId);
				if (wikiVersion != null && wikiVersion.getVersionNumber() == versionId) {
					if (WikiState.PUBLISHED == wiki.getWikiState())
						wikiCache.put(new Element(wikiId, wiki)); 
					wikiIdCache.put(new Element(wiki.getName(), wikiId));
				}
			} catch (Exception e) {
				throw new WikiNotFoundException(e);
			}
		}
		return wiki;
	}

	protected void setUserInWiki(Wiki wiki) {
		long userId = wiki.getCreater().getUserId();
		try {
			wiki.setCreater(userManager.getUser(userId));
		} catch (UserNotFoundException e) {
		}
	}

	public Wiki findInLocalCache(long wikiId, int versionNumber) {
		if (wikiCache.get(wikiId) != null) {
			Wiki wiki = (Wiki) wikiCache.get(wikiId).getObjectValue();
			if (wiki.getVersion() == versionNumber)
				return wiki;
		}
		return null;
	}

	public Wiki getWiki(String name) throws WikiNotFoundException {
		Wiki wikiToUse = null;
		if (wikiIdCache.get(name) != null) {
			Long pageId = (Long) wikiIdCache.get(name).getObjectValue();
			log.debug("using cached pageId : " + pageId);
			wikiToUse = getWiki(pageId);
		}
		if (wikiToUse == null) {
			try {
				wikiToUse = wikiDao.getWikiByName(name);
				if (wikiToUse == null)
					throw new WikiNotFoundException();
				setUserInWiki(wikiToUse);
				if( WikiState.PUBLISHED == wikiToUse.getWikiState())
					wikiCache.put(new Element(wikiToUse.getWikiId(), wikiToUse));
				wikiIdCache.put(new Element(wikiToUse.getName(), wikiToUse.getWikiId()));
			} catch (Exception e) {
				throw new WikiNotFoundException(e);
			}
		}
		return wikiToUse;
	}

	public Wiki getWiki(String name, int versionId) throws WikiNotFoundException {
		Wiki wikiToUse = null;
		if (wikiIdCache.get(name) != null) {
			Long wikiId = (Long) wikiIdCache.get(name).getObjectValue();
			log.debug("using cached pageId : " + wikiId);
			wikiToUse = getWiki(wikiId, versionId);
		}
		
		if (wikiToUse == null) {			
			try {
				wikiToUse = wikiDao.getWikiByName(name);
				if (wikiToUse == null)
					throw new WikiNotFoundException();
				
				wikiToUse = getWiki(wikiToUse.getWikiId(), versionId);
			} catch (Exception e) {
				throw new WikiNotFoundException(e);
			}
		}
		return wikiToUse;
	}

	public List<Wiki> getWikis(int objectType) { 
		return null;
	}

	public List<Wiki> getWikis(int objectType, long objectId) {
		List<Long> ids = wikiDao.getWikiIds(objectType, objectId);
		ArrayList<Wiki> list = new ArrayList<Wiki>(ids.size());
		for (Long wikiId : ids) {
			try {
				list.add(getWiki(wikiId));
			} catch (WikiNotFoundException e) {
			}
		}
		return list;
	} 


	public List<Wiki> getWikis(int objectType, long objectId, int startIndex, int maxResults) {
		List<Long> ids = wikiDao.getWikiIds(objectType, objectId, startIndex, maxResults);
		ArrayList<Wiki> list = new ArrayList<Wiki>(ids.size());
		for (Long pageId : ids) {
			try {
				list.add(getWiki(pageId));
			} catch (WikiNotFoundException e) {
			}
		}
		return list;
	}

	public int getWikiCount(int objectType) {
		return 0;
	}

	public int getWikiCount(int objectType, long objectId) {
		return wikiDao.getWikiCount(objectType, objectId);
	}
 

	public List<WikiVersion> getWikiVersions(long wikiId) {
		String key = getVersionListCacheKey(wikiId);
		List<Integer> versions;
		if (wikiVersionsCache.get(key) != null) {
			versions = (List<Integer>) wikiVersionsCache.get(key).getObjectValue();
		} else {
			versions = this.wikiDao.getWikiVersionIds(wikiId);
			wikiVersionsCache.put(new Element(key, versions));
		}
		List<WikiVersion> list = new ArrayList<WikiVersion>(versions.size());
		for (Integer version : versions) {
			list.add(getWikiVersion(wikiId, version));
		}
		return list;
	}

	private String getVersionCacheKey(long wikiId, int versionId) {
		return (new StringBuilder()).append("version-").append(wikiId).append("-").append(versionId).toString();
	}

	private String getVersionListCacheKey(long wikiId) {
		return (new StringBuilder()).append("versions-").append(wikiId).toString();
	}

	protected WikiVersion getWikiVersion(long pageId, int versionNumber) {
		String key = getVersionCacheKey(pageId, versionNumber);
		WikiVersion pv;
		if (wikiVersionCache.get(key) != null) {
			pv = (WikiVersion) wikiVersionCache.get(key).getObjectValue();
		} else {
			pv = wikiDao.getWikiVersion(pageId, versionNumber);
			wikiVersionCache.put(new Element(key, pv));
		}
		return pv;
	}
 
	public List<Wiki> getWikis(int objectType, WikiState state) {
		List<Long> ids = wikiDao.getWikiIds(objectType, state);
		ArrayList<Wiki> list = new ArrayList<Wiki>(ids.size());
		for (Long wikiId : ids) {
			try {
				list.add(getWiki(wikiId));
			} catch (WikiNotFoundException e) {
			}
		}
		return list;
	}
 
	public List<Wiki> getWikis(int objectType, WikiState state, int startIndex, int maxResults) {
		List<Long> ids = wikiDao.getWikiIds(objectType, state, startIndex, maxResults);
		ArrayList<Wiki> list = new ArrayList<Wiki>(ids.size());
		for (Long wikiId : ids) {
			try {
				list.add(getWiki(wikiId));
			} catch (WikiNotFoundException e) {
			}
		}
		return list;
	}
 
	public int getWikiCount(int objectType, WikiState state) {
		return wikiDao.getWikiCount(objectType, state);
	}
 
	public int getWikiCount(int objectType, long objectId, WikiState state) {
		return wikiDao.getWikiCount(objectType, objectId, state);
	}
 
	public List<Wiki> getWikis(int objectType, long objectId, WikiState state) {
		List<Long> ids = wikiDao.getWikiIds(objectType, objectId, state);
		ArrayList<Wiki> list = new ArrayList<Wiki>(ids.size());
		for (Long wikiId : ids) {
			try {
				list.add(getWiki(wikiId));
			} catch (WikiNotFoundException e) {
			}
		}
		return list;
	}

 	public List<Wiki> getWikis(int objectType, long objectId, WikiState state, int startIndex, int maxResults) {
		List<Long> ids = wikiDao.getWikiIds(objectType, objectId, state, startIndex, maxResults);
		ArrayList<Wiki> list = new ArrayList<Wiki>(ids.size());
		for (Long wikiId : ids) {
			try {
				list.add(getWiki(wikiId));
			} catch (WikiNotFoundException e) {
			}
		}
		return list;
	}

}
