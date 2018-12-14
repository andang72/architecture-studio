package architecture.community.wiki.dao.jdbc;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.inject.Inject;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlParameterValue;
import org.springframework.jdbc.core.support.SqlLobValue;

import architecture.community.model.Models;
import architecture.community.user.UserTemplate;
import architecture.community.util.SecurityHelper;
import architecture.community.wiki.BodyContent;
import architecture.community.wiki.Wiki;
import architecture.community.wiki.WikiState;
import architecture.community.wiki.WikiVersion;
import architecture.community.wiki.WikiVersionHelper;
import architecture.community.wiki.dao.WikiDao;
import architecture.ee.jdbc.sequencer.SequencerFactory;
import architecture.ee.service.ConfigService;
import architecture.ee.spring.jdbc.ExtendedJdbcDaoSupport;

public class JdbcWikiDao extends ExtendedJdbcDaoSupport implements WikiDao {
 
	private int DEFAULT_WIKI_VERSION = 1;

	@Inject
	@Qualifier("configService")
	private ConfigService configService;
	
	@Inject
	@Qualifier("sequencerFactory")
	private SequencerFactory sequencerFactory;
		
	private final RowMapper<BodyContent> bodyContentMapper = new RowMapper<BodyContent>() {
		public BodyContent mapRow(ResultSet rs, int rowNum) throws SQLException {
			BodyContent body = new BodyContent();
			body.setBodyId(rs.getLong("BODY_ID"));
			body.setWikiId(rs.getLong("WIKI_ID")); 
			body.setBodyText(rs.getString("BODY_TEXT"));
			return body;
		}
	};

	private final RowMapper<WikiVersion> pageVersionMapper = new RowMapper<WikiVersion>() {
		public WikiVersion mapRow(ResultSet rs, int rowNum) throws SQLException {
			WikiVersion version = new WikiVersion();
			version.setWiki(new Wiki(rs.getLong("WIKI_ID")));
			version.setVersionNumber(rs.getInt("VERSION_ID"));
			version.setWikiState(WikiState.valueOf(rs.getString("STATE").toUpperCase()));
			version.setCreationDate(rs.getDate("CREATION_DATE"));
			version.setModifiedDate(rs.getDate("MODIFIED_DATE"));
			version.setAuthor(new UserTemplate(rs.getLong("USER_ID")));
			return version;
		}
	}; 

	public long getNextWikiId(){
		logger.debug("next id for {}, {}", Models.WIKI.getObjectType(), Models.WIKI.name() );
		return sequencerFactory.getNextValue(Models.WIKI.getObjectType(), Models.WIKI.name());
	} 
	
	public long getNextWikiBodyId(){
		logger.debug("next id for {}, {}", Models.WIKI_BODY.getObjectType(), Models.WIKI_BODY.name() );
		return sequencerFactory.getNextValue(Models.WIKI_BODY.getObjectType(), Models.WIKI_BODY.name());
	} 	
		
	public void update(WikiVersion pageVersion) {
		if (pageVersion.getWikiState() == WikiState.PUBLISHED) { 
			
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_STATE_TO_ARCHIVED").getSql(),
				new SqlParameterValue(Types.NUMERIC, pageVersion.getWiki().getWikiId()),
				new SqlParameterValue(Types.NUMERIC, pageVersion.getVersionNumber())); 
			
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_STATE").getSql(),
				new SqlParameterValue(Types.NUMERIC, pageVersion.getAuthor()),
				new SqlParameterValue(Types.DATE, pageVersion.getCreationDate()),
				new SqlParameterValue(Types.DATE, pageVersion.getModifiedDate()),
				new SqlParameterValue(Types.VARCHAR, pageVersion.getWikiState().name().toLowerCase()),
				new SqlParameterValue(Types.NUMERIC, pageVersion.getWiki().getWikiId()),
				new SqlParameterValue(Types.NUMERIC, pageVersion.getVersionNumber()));
		}
	}

 

	public WikiVersion getWikiVersion(long wikiId, int versionNumber) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_BY_ID_AND_VERSION").getSql(), pageVersionMapper,
				new SqlParameterValue(Types.NUMERIC, wikiId), new SqlParameterValue(Types.NUMERIC, versionNumber));
	}

	public List<WikiVersion> getWikiVersions(long wikiId) {
		return getExtendedJdbcTemplate().query(getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_VERSIONS").getSql(),
				pageVersionMapper, new SqlParameterValue(Types.NUMERIC, wikiId));
	}

	public List<Integer> getWikiVersionIds(long wikiId) {
		return getExtendedJdbcTemplate().queryForList(getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_VERSION_IDS").getSql(),
				Integer.class, new SqlParameterValue(Types.NUMERIC, wikiId));
	}



	/**
	 * 새로운 페이지 생성
	 */
	public void create(Wiki page) { 
		long nextId = getNextWikiId();
		page.setWikiId(nextId);
		page.setVersion(DEFAULT_WIKI_VERSION);  
		// INSERT V2_PAGE
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.CREATE_WIKI").getSql(),
			new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
			new SqlParameterValue(Types.NUMERIC, page.getObjectType()),
			new SqlParameterValue(Types.NUMERIC, page.getObjectId()),
			new SqlParameterValue(Types.VARCHAR, page.getName()),
			new SqlParameterValue(Types.NUMERIC, page.getVersion()),
			new SqlParameterValue(Types.NUMERIC, page.getCreater().getUserId()),
			new SqlParameterValue(Types.TIMESTAMP, page.getCreationDate()),
			new SqlParameterValue(Types.TIMESTAMP, page.getModifiedDate()));
		insertPageVersion(page);
		insertPageBody(page);
		insertProperties(page);
	}
	 
	private void insertProperties(Wiki page) {
		if (page.getProperties() != null && !page.getProperties().isEmpty()) {
			Map<String, String> properties = page.getProperties();
			final List<Map.Entry<String, String>> entryList = new ArrayList<Map.Entry<String, String>>( properties.entrySet());
			final long pageId = page.getWikiId();
			final long pageVersionId = page.getVersion();
			getExtendedJdbcTemplate().batchUpdate(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_PROPERTY").getSql(),
					new BatchPreparedStatementSetter() {
						public int getBatchSize() {
							return entryList.size();
						}

						public void setValues(PreparedStatement ps, int index) throws SQLException {
							Map.Entry<String, String> e = entryList.get(index);
							ps.setLong(1, pageId);
							ps.setLong(2, pageVersionId);
							ps.setString(3, e.getKey());
							ps.setString(4, e.getValue());
						}
					});
		}
	}

	private Map<String, String> loadProperties(Wiki page) {
		return getExtendedJdbcTemplate().query(getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_PROPERTIES").getSql(),
				new Object[] { page.getWikiId(), page.getVersion() }, new ResultSetExtractor<Map<String, String>>() {
					public Map<String, String> extractData(ResultSet rs) throws SQLException, DataAccessException {
						Map<String, String> rows = new HashMap<String, String>();
						while (rs.next()) {
							String key = rs.getString(1);
							String value = rs.getString(2);
							rows.put(key, value);
						}
						return rows;
					}
				});
	}
	
	
	private void insertPageVersion(Wiki page) {
		
		Date now = Calendar.getInstance().getTime();
		if (page.getVersion() > 1) {
			page.setModifiedDate(now);
		}
		if (page.getWikiState() == WikiState.PUBLISHED) {
			// clean up on publish
			cleanupVersionsOnPublish(page);
		}
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_VERSION").getSql(),
			new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
			new SqlParameterValue(Types.NUMERIC, page.getVersion()),
			new SqlParameterValue(Types.VARCHAR, page.getWikiState().name().toLowerCase()),
			new SqlParameterValue(Types.VARCHAR, page.getTitle()), 
			new SqlParameterValue(Types.NUMERIC, page.isSecured() ? 1 : 0 ),				
			new SqlParameterValue(Types.NUMERIC, page.getVersion() <= 1 ? page.getCreater().getUserId() : SecurityHelper.getUser().getUserId()),
			new SqlParameterValue(Types.DATE, page.getCreationDate()),
			new SqlParameterValue(Types.DATE, page.getModifiedDate()));
	}

	private void cleanupVersionsOnPublish(Wiki page) {
		if (page.getVersion() > 0) {
			try {
				int pubishedVersion = getExtendedJdbcTemplate().queryForObject(
					getBoundSql("COMMUNITY_UI_WIKI.SELECT_PUBLISHED_WIKI_VERSION_NUMBER").getSql(), Integer.class,
					new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
				page.setVersion(pubishedVersion + 1);
			} catch (EmptyResultDataAccessException e) {
				int maxArchiveId = getExtendedJdbcTemplate().queryForObject(
					getBoundSql("COMMUNITY_UI_WIKI.SELECT_MAX_ARCHIVED_WIKI_VERSION_NUMBER").getSql(), Integer.class,
					new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
				if (maxArchiveId > 0)
					page.setVersion(maxArchiveId + 1);
				else
					page.setVersion(1);
			}
			List<Long> toDelete = getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_DRAFT_WIKI_VERSIONS").getSql(), Long.class,
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
			for (Long version : toDelete)
				deleteVersion(page, version.intValue());
		}
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_STATE_TO_ARCHIVED").getSql(),
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
				new SqlParameterValue(Types.NUMERIC, page.getVersion()));

		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_VISION_NUMBER").getSql(),
				new SqlParameterValue(Types.NUMERIC, page.getVersion()),
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()));

	}
	
	

	private void deleteVersion(Wiki page, int version) {
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_BODY_VERSION").getSql(),
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()), new SqlParameterValue(Types.NUMERIC, version));
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_VERSION").getSql(),
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()), new SqlParameterValue(Types.NUMERIC, version));
	}

	private void insertPageBody(final Wiki page) {
		long bodyId = -1L;
		if (page.getBodyText() != null) {
			boolean newBodyRequired = false;
			if (page.getVersion() == 1) {
				newBodyRequired = true;
			} else {
				// load body from database ...
				List<BodyContent> results = getExtendedJdbcTemplate().query(
						getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_BODY").getSql(), bodyContentMapper,
						new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
						new SqlParameterValue(Types.NUMERIC, Integer.valueOf(page.getVersion() - 1)));
				String preTextBody = null;
				for (BodyContent bodyContent : results) {
					bodyId = bodyContent.getBodyId();
					preTextBody = bodyContent.getBodyText();
				}
				String textBody = page.getBodyText();
				if (preTextBody == null || !preTextBody.equals(textBody))
					newBodyRequired = true;
			}

			if (newBodyRequired) {
				bodyId = getNextWikiId();
				getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_BODY").getSql(),
						new SqlParameterValue(Types.NUMERIC, bodyId),
						new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
						new SqlParameterValue(Types.CLOB, new SqlLobValue(page.getBodyText(), getLobHandler())));
				
				getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_BODY_VERSION").getSql(),
						new SqlParameterValue(Types.NUMERIC, bodyId),
						new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
						new SqlParameterValue(Types.NUMERIC, page.getVersion()));
			}
		}
	} 
	
	
	public void update(Wiki page, boolean isNewVersion) {
		
		int prevVersionId = page.getVersion();
		Date now = Calendar.getInstance().getTime();
		if (isNewVersion) {
			int maxVersionId = getExtendedJdbcTemplate().queryForObject(
					getBoundSql("COMMUNITY_UI_WIKI.SELECT_MAX_WIKI_VERSION_NUMBER").getSql(), Integer.class,
					new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
			page.setVersion(maxVersionId + 1);
		}

		page.setModifiedDate(now);
		// update page ...
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI").getSql(),
			new SqlParameterValue(Types.NUMERIC, page.getObjectType()),
			new SqlParameterValue(Types.NUMERIC, page.getObjectId()),
			new SqlParameterValue(Types.VARCHAR, page.getName()),
			new SqlParameterValue(Types.NUMERIC, page.getVersion()),
			new SqlParameterValue(Types.NUMERIC, page.getModifier().getUserId()),
			new SqlParameterValue(Types.TIMESTAMP, page.getModifiedDate()),
			new SqlParameterValue(Types.NUMERIC, page.getWikiId()));

		updateProperties(page);

		if (isNewVersion) {
			insertPageVersion(page);
			insertPageBody(page);
		} else {
			updateWikiVersion(page, prevVersionId);
			updateWikiBody(page, prevVersionId);
		}
	}
	
	private void updateProperties(final Wiki page) {
		Map<String, String> oldProps = loadProperties(page);
		logger.debug("old:" + oldProps);
		logger.debug("new:" + page.getProperties());

		final List<String> deleteKeys = getDeletedPropertyKeys(oldProps, page.getProperties());
		final List<String> modifiedKeys = getModifiedPropertyKeys(oldProps, page.getProperties());
		final List<String> addedKeys = getAddedPropertyKeys(oldProps, page.getProperties());
		logger.debug("deleteKeys:" + deleteKeys.size());
		if (!deleteKeys.isEmpty()) {
			getExtendedJdbcTemplate().batchUpdate(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_PROPERTY_BY_NAME").getSql(),
					new BatchPreparedStatementSetter() {
						public void setValues(PreparedStatement ps, int i) throws SQLException {
							ps.setLong(1, page.getWikiId());
							ps.setLong(2, page.getVersion());
							ps.setString(3, deleteKeys.get(i));
						}

						public int getBatchSize() {
							return deleteKeys.size();
						}
					});
		}
		logger.debug("modifiedKeys:" + modifiedKeys.size());
		if (!modifiedKeys.isEmpty()) {
			getExtendedJdbcTemplate().batchUpdate(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_PROPERTY_BY_NAME").getSql(),
					new BatchPreparedStatementSetter() {
						public void setValues(PreparedStatement ps, int i) throws SQLException {
							String key = modifiedKeys.get(i);
							String value = page.getProperties().get(key);
							logger.debug("batch[" + key + "=" + value + "]");
							ps.setString(1, value);
							ps.setLong(2, page.getWikiId());
							ps.setLong(3, page.getVersion());
							ps.setString(4, key);
						}
						public int getBatchSize() {
							return modifiedKeys.size();
						}
					});
		}
		logger.debug("addedKeys:" + addedKeys.size());
		if (!addedKeys.isEmpty()) {
			getExtendedJdbcTemplate().batchUpdate(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_PROPERTY").getSql(),
					new BatchPreparedStatementSetter() {
						public void setValues(PreparedStatement ps, int i) throws SQLException {
							ps.setLong(1, page.getWikiId());
							ps.setLong(2, page.getVersion());
							String key = addedKeys.get(i);
							String value = page.getProperties().get(key);
							logger.debug("batch[" + key + "=" + value + "]");
							ps.setString(3, key);
							ps.setString(4, value);
						}
						public int getBatchSize() {
							return addedKeys.size();
						}
					});
		}
	}	
	

	private List<String> getDeletedPropertyKeys(Map<String, String> oldProps, Map<String, String> newProps) {
		HashMap<String, String> temp = new HashMap<String, String>(oldProps);
		Set<String> oldKeys = temp.keySet();
		Set<String> newKeys = newProps.keySet();
		for (String key : newKeys)
			oldKeys.remove(key);
		return Arrays.asList(oldKeys.toArray(new String[oldKeys.size()]));

	}

	private List<String> getModifiedPropertyKeys(Map<String, String> oldProps, Map<String, String> newProps) {
		HashMap<String, String> temp = new HashMap<String, String>(oldProps);
		Set<String> oldKeys = temp.keySet();
		Set<String> newKeys = newProps.keySet();
		oldKeys.retainAll(newKeys);
		List<String> modified = new ArrayList<String>();
		for (String key : oldKeys) {
			logger.debug(key + " equals:[" + newProps.get(key) + "]=[" + oldProps.get(key) + "]" + StringUtils.equals(newProps.get(key), oldProps.get(key)));
			if (!StringUtils.equals(newProps.get(key), oldProps.get(key)))
				modified.add(key);
		}
		return modified;
	}

	/**
	 * return key values
	 * 
	 * @param oldProps
	 * @param newProps
	 * @return
	 */
	private List<String> getAddedPropertyKeys(Map<String, String> oldProps, Map<String, String> newProps) {
		HashMap<String, String> temp = new HashMap<String, String>(oldProps);
		Set<String> oldKeys = temp.keySet();
		Set<String> newKeys = newProps.keySet();
		List<String> added = new ArrayList<String>();
		for (String key : newKeys) {
			if (!oldKeys.contains(key)) {
				added.add(key);
			}
		}
		return added;
	}
	
	

	private void updateWikiVersion(Wiki page, int prevVersionId) {
		Date now = Calendar.getInstance().getTime();

		if (page.getWikiState() == WikiState.PUBLISHED) {
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_STATE_TO_ARCHIVED").getSql(),
					new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
					new SqlParameterValue(Types.NUMERIC, page.getVersion()));
		}
		if (page.getVersion() > 0) {
			page.setModifiedDate(now);
			long modifierId = page.getModifier().getUserId() <= 0L ? page.getCreater().getUserId() : page.getModifier().getUserId();
			// update page version
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_VERSION").getSql(),
				new SqlParameterValue(Types.VARCHAR, page.getWikiState().name().toLowerCase()),
				new SqlParameterValue(Types.VARCHAR, page.getTitle()),
				new SqlParameterValue(Types.NUMERIC, page.isSecured() ? 1 : 0 ),			
				new SqlParameterValue(Types.NUMERIC, modifierId),
				new SqlParameterValue(Types.DATE, page.getModifiedDate()),
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
				new SqlParameterValue(Types.NUMERIC, page.getVersion()));

		}
	}

	private void updateWikiBody(Wiki page, int prevVersionId) {
		long bodyId = -1L; 
		try {
			bodyId = getExtendedJdbcTemplate().queryForObject(
					getBoundSql("COMMUNITY_UI_WIKI.SELETE_WIKI_BODY_ID").getSql(), Long.class,
					new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
					new SqlParameterValue(Types.NUMERIC, prevVersionId));
		} catch (EmptyResultDataAccessException e) {
		}
		if (page.getBodyText() != null) {
			if (bodyId != -1L) {
				final long bodyIdToUse = bodyId;
				getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.UPDATE_WIKI_BODY").getSql(),
						new SqlParameterValue(Types.VARCHAR, page.getBodyContent().getBodyText()),
						new SqlParameterValue(Types.NUMERIC, bodyIdToUse));
			} else {
				final long bodyIdToUse = getNextWikiBodyId();
				getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_BODY").getSql(),
						new SqlParameterValue(Types.NUMERIC, bodyIdToUse),
						new SqlParameterValue(Types.NUMERIC, page.getWikiId()), 
						new SqlParameterValue(Types.VARCHAR, page.getBodyContent().getBodyText()));
				
				getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.INSERT_WIKI_BODY_VERSION").getSql(),
						new SqlParameterValue(Types.NUMERIC, bodyIdToUse),
						new SqlParameterValue(Types.NUMERIC, page.getWikiId()),
						new SqlParameterValue(Types.NUMERIC, prevVersionId));
			}
		}
	}


	public void delete(Wiki page) {

		if (page.getVersion() == -1) {
			List<Long> bodyIds = getExtendedJdbcTemplate().queryForList( getBoundSql("COMMUNITY_UI_WIKI.SELETE_WIKI_BODY_IDS").getSql(), Long.class,
				new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_BODY_VERSIONS").getSql(), new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
			for (long bodyId : bodyIds) {
				getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_BODY").getSql(), new SqlParameterValue(Types.NUMERIC, bodyId));
			}
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_VERSIONS").getSql(), new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_PROPERTIES").getSql(), new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
			getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_UI_WIKI.DELETE_PAGE").getSql(), new SqlParameterValue(Types.NUMERIC, page.getWikiId()));
		}
	}


	private Wiki load(long wikiId, int versionNumber) {
		if (wikiId <= 0)
			return null; 
		final Wiki wkikToUse = new Wiki();
		wkikToUse.setWikiId(wikiId);
		wkikToUse.setVersion(versionNumber);
		getExtendedJdbcTemplate().query(getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_BY_ID_AND_VERSION").getSql(),
			new RowMapper<Wiki>() {			
				public Wiki mapRow(ResultSet rs, int rowNum) throws SQLException {
					wkikToUse.setName(rs.getString("NAME"));
					wkikToUse.setObjectType(rs.getInt("OBJECT_TYPE"));
					wkikToUse.setObjectId(rs.getLong("OBJECT_ID"));
					wkikToUse.setWikiState( WikiState.valueOf(rs.getString("STATE").toUpperCase() )); 
					wkikToUse.setCreater (new UserTemplate(rs.getLong("USER_ID")));
					
					if (rs.wasNull())
						wkikToUse.setCreater(new UserTemplate(-1L));
						
					wkikToUse.setTitle(rs.getString("TITLE")); 
					wkikToUse.setSecured(rs.getInt("SECURED") == 1 ? true : false);
					wkikToUse.setCreationDate(rs.getTimestamp("CREATION_DATE"));
					wkikToUse.setModifiedDate(rs.getTimestamp("MODIFIED_DATE"));
					return wkikToUse;
				}
			}, 
			new SqlParameterValue(Types.NUMERIC, wkikToUse.getWikiId()),
			new SqlParameterValue(Types.NUMERIC, wkikToUse.getVersion()));

		//if (wkikToUse.getName() == null)
		//	return null;

		try {
			BodyContent bodyContent = getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_BODY").getSql(), 
				bodyContentMapper,
				new SqlParameterValue(Types.NUMERIC, wkikToUse.getWikiId()),
				new SqlParameterValue(Types.NUMERIC, wkikToUse.getVersion()));
			wkikToUse.setBodyContent(bodyContent);
		} catch (EmptyResultDataAccessException e) {
			wkikToUse.setBodyContent(new BodyContent(-1L, wkikToUse.getWikiId(), null ));
		}

		if (StringUtils.isEmpty( wkikToUse.getBodyText() ) ) {
			getExtendedJdbcTemplate().update(
				getBoundSql("COMMUNITY_UI_WIKI.DELETE_WIKI_BODY_VERSION").getSql(), 
				new SqlParameterValue(Types.NUMERIC, wkikToUse.getWikiId()),
				new SqlParameterValue(Types.NUMERIC, wkikToUse.getVersion()));
		}

		Map<String, String> properties = loadProperties(wkikToUse);
		wkikToUse.getProperties().putAll(properties);
		
		return wkikToUse;
	}

	public int getWikiVersion(long pageId) { 
		WikiVersion v = WikiVersionHelper.getDeletedWikiVersion(pageId);
		if (v == null)
			v = WikiVersionHelper.getPublishedWikiVersion(pageId);
		if (v == null)
			v = WikiVersionHelper.getNewestWikiVersion(pageId);
		if (v != null)
			return v.getVersionNumber();
		else
			return -1;
	}

	public Wiki getWikiByName(String name) {
		long pageId = -1L;
		try {
			pageId = getExtendedJdbcTemplate().queryForObject(
					getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_ID_BY_NAME").getSql(), Long.class,
					new SqlParameterValue(Types.VARCHAR, name));
		} catch (DataAccessException e) {
			return null;
		}

		return getWikiById(pageId, -1);
	}

	public Wiki getWikiByName(String name, int versionNumber) {
		long pageId = -1L;
		try {
			pageId = getExtendedJdbcTemplate().queryForObject( getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_ID_BY_NAME").getSql(), Long.class, new SqlParameterValue(Types.VARCHAR, name));
		} catch (DataAccessException e) {
			return null;
		}
		return load(pageId, versionNumber);
	}

	public Wiki getWikiByTitle(int objectType, long objectId, String title) {
		Long resutls[] = getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_TITLE").getSql(),
				new RowMapper<Long[]>() {
					public Long[] mapRow(ResultSet rs, int rowNum) throws SQLException {
						return new Long[] { rs.getLong("PAGE_ID"), rs.getLong("VERSION_ID") };
					}
				}, new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId),
				new SqlParameterValue(Types.VARCHAR, title));
		if (resutls == null || resutls.length == 0) {
			return null;
		}
		return load(resutls[0].longValue(), resutls[1].intValue());
	}

	public int getWikiCount(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_UI_WIKI.COUNT_WIKI_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId));
	}
	
	public List<Long> getWikiIds(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId));
	}

	public List<Long> getWikiIds(int objectType, long objectId, int startIndex, int maxResults) {
		return getExtendedJdbcTemplate().query(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				startIndex,
				maxResults, 
				Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.NUMERIC, objectId )
				);
	}
 
	public List<Long> getWikiIds(int objectType, WikiState state) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_IDS_BY_OBJECT_TYPE_AND_STATE").getSql(), Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.VARCHAR, state.name().toLowerCase()));
	}
 
	public List<Long> getWikiIds(int objectType, WikiState state, int startIndex, int maxResults) {
		return getExtendedJdbcTemplate().query(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_IDS_BY_OBJECT_TYPE_AND_STATE").getSql(), 
				startIndex, 
				maxResults,
				Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType ),
				new SqlParameterValue(Types.VARCHAR, state.name().toLowerCase() )
				);
	}
 
	public int getWikiCount(int objectType, WikiState state) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_UI_WIKI.COUNT_WIKI_BY_OBJECT_TYPE_AND_STATE").getSql(), Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.VARCHAR, state.name().toLowerCase()));
	}
 
	public List<Long> getWikiIds(int objectType, long objectId, WikiState state) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_STATE").getSql(),
				Long.class, new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId),
				new SqlParameterValue(Types.VARCHAR, state.name().toLowerCase()));
	}
 
	public List<Long> getWikiIds(int objectType, long objectId, WikiState state, int startIndex, int maxResults) {
		return getExtendedJdbcTemplate().query(
				getBoundSql("COMMUNITY_UI_WIKI.SELECT_WIKI_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_STATE").getSql(),
				startIndex, 
				maxResults, 
				Long.class,
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId),
				new SqlParameterValue(Types.VARCHAR, state.name().toLowerCase())
				);
	}
 
	public int getWikiCount(int objectType, long objectId, WikiState state) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_UI_WIKI.COUNT_WIKI_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_STATE").getSql(), Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId),
				new SqlParameterValue(Types.VARCHAR, state.name().toLowerCase()));
	}


	public Wiki getWikiById(long pageId) {
		return getWikiById(pageId, -1);
	}

	public Wiki getWikiById(long pageId, int versionNumber) {
		return load( pageId, versionNumber <= 0 ? getWikiVersion(pageId) : versionNumber);
	} 
	public void delete(WikiVersion wikiVersion) {
		
	}
 
}
