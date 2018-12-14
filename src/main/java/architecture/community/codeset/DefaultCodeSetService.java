package architecture.community.codeset;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import javax.inject.Inject;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.community.codeset.dao.CodeSetDao;
import architecture.community.model.ModelObjectTreeWalker;
import architecture.community.tag.LockUtils;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class DefaultCodeSetService implements CodeSetService {

	private Logger logger = LoggerFactory.getLogger(getClass().getName());

	@Inject
	@Qualifier("codeSetDao")
	private CodeSetDao codeSetDao;

	@Inject
	@Qualifier("codeSetCache")
	private Cache codeSetCache;

	@Inject
	@Qualifier("codeSetTreeWalkerCache")
	private Cache treeWalkerCache;

	@Inject
	@Qualifier("codeSetIdCache")
	private Cache codeSetIdCache;
	

	public DefaultCodeSetService() {
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdate(CodeSet codeset) {
		if (codeset.getCodeSetId() > 0) {
			Date now = new Date();
			codeset.setModifiedDate(now);
			clearCodeSetCache(codeset);
		} else {
			codeset.setCodeSetId(-1L);
		}
		codeSetDao.saveOrUpdateCodeSet(codeset);
	}
	
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdate(List<CodeSet> codesets) {
		for (CodeSet code : codesets) {
		    if (code.getCodeSetId() > 0) {
			clearCodeSetCache(code.getCodeSetId());
		    }
		}
		this.codeSetDao.saveOrUpdateCodeSet(codesets);
	}

	
	/**
	 * 인자로 전달된 객체의 자식에 해당하는 코드세트 목록을 리턴한다.
	 * 
	 */
	public List<CodeSet> getCodeSets(CodeSet codeset) {
		List<Long> codesetIds = codeSetDao.getCodeSetIds(codeset.getObjectType(), codeset.getObjectId(), codeset.getCodeSetId());
		List<CodeSet> codesets = new ArrayList<CodeSet>(codesetIds.size());
		for (long codesetId : codesetIds) {
			CodeSet item;
			try {
				item = getCodeSet(codesetId);
				codesets.add(item);
			} catch (CodeSetNotFoundException e) {
			}
		}
		return codesets;
	}
 
	public List<CodeSet> getRecrusiveCodesets(CodeSet codeset) {
		// TODO Auto-generated method stub
		return null;
	}

	public int getCodeSetCount(int objectType, long objectId, String group) {
		return codeSetDao.getCodeSetCount(objectType, objectId, group);
	}

	public List<CodeSet> getCodeSets(int objectType, long objectId, String group) {
		List<Long> groups = codeSetDao.getCodeSetIds(objectType, objectId, group);
		List<CodeSet> list = new ArrayList<CodeSet>(groups.size());
		for (long id : groups) {
			CodeSet codeset;
			try {
				codeset = getCodeSet(id);
				list.add(codeset);
			} catch (CodeSetNotFoundException e) {
			}
		}
		return list;
	}


	@Override
	public int getCodeSetCount(int objectType, long objectId, String group, String code) {
		return codeSetDao.getCodeSetCount(objectType, objectId, group, code);
	}

	@Override
	public List<CodeSet> getCodeSets(int objectType, long objectId, String group, String code) {
		List<Long> groups = codeSetDao.getCodeSetIds(objectType, objectId, group, code);
		List<CodeSet> list = new ArrayList<CodeSet>(groups.size());
		for (long id : groups) {
			CodeSet codeset;
			try {
				codeset = getCodeSet(id);
				list.add(codeset);
			} catch (CodeSetNotFoundException e) {
			}
		}
		return list;
	}	

 
	public List<CodeSet> getCodeSets(String group, String code) {
		if( StringUtils.isNotEmpty(group) ) {
			if( StringUtils.isNotEmpty( code )) {
				getCodeSets(-1, -1L, group , code  );
			}else {
				return getCodeSets(-1, -1L, group );
			}
		}
		return Collections.EMPTY_LIST;
	}
	
	
	
	@Override
	public int getCodeSetCount(CodeSet codeset) {
		return codeSetDao.getCodeSetCount(codeset.getObjectType(), codeset.getObjectId(), codeset.getCodeSetId());
	}

	public int getRecrusiveCodeSetCount(CodeSet codeset) {
		return 0;
	}

	public CodeSet getCodeSet(long codeSetId) throws CodeSetNotFoundException {
		CodeSet codeset = getCodeSetInCache(codeSetId);
		if (codeset == null) {
			codeset = codeSetDao.getCodeSetById(codeSetId);
			if (codeset == null)
				throw new CodeSetNotFoundException();
			codeSetCache.put(new Element(codeSetId, codeset));
			codeSetIdCache.put(new Element(getCodeSetKey(codeset.getObjectType(), codeset.getObjectId(), codeset.getGroupCode(), codeset.getCode()), codeSetId));
		}
		return codeset;
	}

	protected CodeSet getCodeSetInCache(long codeSetId) {
		if (codeSetCache.get(codeSetId) != null)
			return (CodeSet) codeSetCache.get(codeSetId).getObjectValue();
		else
			return null;
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public CodeSet createCodeSet(CodeSet orgCodeset, String name, String description) {
		CodeSet codeset = new CodeSet();

		codeset.setObjectType(orgCodeset.getObjectType());
		codeset.setObjectId(orgCodeset.getObjectId());
		codeset.setParentCodeSetId(orgCodeset.getCodeSetId());

		codeset.setName(name);
		codeset.setDescription(description);
		return codeset;
	}

	public ModelObjectTreeWalker getCodeSetTreeWalker(int objectType, long objectId) {
		String key = getTreeWalkerCacheKey(objectType, objectId);
		ModelObjectTreeWalker treeWalker;
		if (treeWalkerCache.get(key) != null) {
			treeWalker = (ModelObjectTreeWalker) treeWalkerCache.get(key).getObjectValue();
		} else {
			synchronized (key) {
				treeWalker = codeSetDao.getTreeWalker(objectType, objectId);
				treeWalkerCache.put(new Element(key, treeWalker));
			}
		}
		return treeWalker;
	}
	
 
	public CodeSet getCodeSetByCode(String group, String code) throws CodeSetNotFoundException {
		return getCodeSetByCode(-1, -1L, group, code);
	}
	
	public CodeSet getCodeSetByCode(int objectType, long objectId, String group, String code) throws CodeSetNotFoundException {		
		String key = getCodeSetKey(objectType, objectId, group, code);
		long codeSetId = -1L;
		if(codeSetIdCache.get(key) != null) {
			codeSetId = (Long)codeSetIdCache.get(key).getObjectValue();
		}else {
			codeSetId = codeSetDao.findCodeSetByCode(objectType, objectId, group, code);
		}
		if( codeSetId > 0 )
			return getCodeSet(codeSetId);
		
		throw new CodeSetNotFoundException();
	}
		

	private void clearCodeSetCache(long codeSetId) {
		if (codeSetCache.get(codeSetId) != null) {
			CodeSet codeset = (CodeSet)codeSetCache.get(codeSetId).getObjectValue();		
			String key = getCodeSetKey(codeset.getObjectType(), codeset.getObjectId(), codeset.getGroupCode(), codeset.getCode());
			codeSetCache.remove(codeSetId);
			if (codeSetIdCache.get(key) != null)
				codeSetIdCache.remove(key);
		}
	}

	private void clearCodeSetCache(CodeSet codeSet) {
		String key = getTreeWalkerCacheKey(codeSet.getObjectType(), codeSet.getObjectId());
		clearCodeSetCache(codeSet.getCodeSetId());
		synchronized (key) {
			treeWalkerCache.remove(key);
		}
	}

	private static String getTreeWalkerCacheKey(int objectType, long objectId) {
		return LockUtils.intern((new StringBuilder("codeSetTreeWalker-")).append(objectType).append("-").append(objectId).toString());
	}
	
	private String getCodeSetKey(int objectType, long objectId, String group, String code) {
		return (new StringBuilder()).append(objectType).append("-").append(objectId).append("-").append(group).append("-").append(code).toString();
	}

}
