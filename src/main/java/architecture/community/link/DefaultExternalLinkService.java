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

package architecture.community.link;

import javax.inject.Inject;

import org.apache.commons.lang3.RandomStringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.community.exception.NotFoundException;
import architecture.community.link.dao.ExternalLinkDao;
import architecture.community.model.ModelObjectAware;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class DefaultExternalLinkService implements ExternalLinkService {

	private Logger logger = LoggerFactory.getLogger(getClass().getName());

	@Inject
	@Qualifier("externalLinkDao")
	private ExternalLinkDao externalLinkDao;

	@Inject
	@Qualifier("externalLinkCache")
	private Cache externalLinkCache;

	public DefaultExternalLinkService() {

	}

	public ExternalLink getExternalLink(String linkId) throws NotFoundException {
		if (externalLinkCache.get(linkId) == null) {
			try {
				ExternalLink link = externalLinkDao.getExternalLink(linkId);
				externalLinkCache.put(new Element(link.getExternalId(), link));
				return link;
			} catch (Exception e) {
				String msg = (new StringBuilder()).append("Unable to find any object by ").append(linkId).toString();
				throw new NotFoundException(msg, e);
			}
		} else {
			return (ExternalLink) externalLinkCache.get(linkId).getObjectValue();
		}
	}

	public ExternalLink getExternalLink(ModelObjectAware model) throws NotFoundException {
		ExternalLink link = null;
		try {
			link = externalLinkDao.getExternalLinkByObjectTypeAndObjectId(model.getObjectType(), model.getObjectId());
			return link;
		} catch (Exception e) {
			String msg = (new StringBuilder()).append("Unable to find link for : ").append(model.getObjectId())
					.toString();
			throw new NotFoundException(msg, e);
		}
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public ExternalLink getExternalLink(ModelObjectAware model, boolean createIfNotExist) throws NotFoundException {
		try {
			return getExternalLink(model);
		} catch (NotFoundException e) {
			if (createIfNotExist) {
				ExternalLink link = new ExternalLink(RandomStringUtils.random(64, true, true), model.getObjectType(), model.getObjectId(), true);
				externalLinkDao.saveExternalLink(link);
				externalLinkCache.put(new Element(link.getExternalId(), link));
				return link;
			} else {
				throw e;
			}
		}
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void removeExternalLink(ModelObjectAware model) {		
		try {
			ExternalLink link = getExternalLink(model);
			if (externalLinkCache.get(link.getExternalId()) != null) {
				externalLinkCache.remove(link.getExternalId());
			}
			externalLinkDao.getExternalLinkByObjectTypeAndObjectId(model.getObjectType(), model.getObjectId());
		} catch (NotFoundException e) {
		}		
	}

	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void removeExternalLink(String linkId) {
		if (externalLinkCache.get(linkId) != null) {
			externalLinkCache.remove(linkId);
		}
		externalLinkDao.removeExternalLink(linkId);
	}

}
