package architecture.community.codeset.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlParameterValue;

import architecture.community.codeset.CodeSet;
import architecture.community.model.ModelObjectTreeWalker;
import architecture.community.model.Models;
import architecture.community.util.LongTree;
import architecture.ee.jdbc.property.dao.PropertyDao;
import architecture.ee.jdbc.sequencer.SequencerFactory;
import architecture.ee.service.ConfigService;
import architecture.ee.spring.jdbc.ExtendedJdbcDaoSupport;

public class JdbcCodeSetDao extends ExtendedJdbcDaoSupport implements CodeSetDao {

	@Inject
	@Qualifier("configService")
	private ConfigService configService;

	@Inject
	@Qualifier("sequencerFactory")
	private SequencerFactory sequencerFactory;

	@Inject
	@Qualifier("propertyDao")
	private PropertyDao propertyDao;

	private String codeSetPropertyTableName = "REP_CODESET_PROPERTY";

	private String codeSetPropertyPrimaryColumnName = "CODESET_ID";

	private final RowMapper<CodeSet> codesetMapper = new RowMapper<CodeSet>() {
		public CodeSet mapRow(ResultSet rs, int rowNum) throws SQLException {
			CodeSet g = new CodeSet();
			g.setCodeSetId(rs.getLong("CODESET_ID"));
			g.setObjectType(rs.getInt("OBJECT_TYPE"));
			g.setObjectId(rs.getLong("OBJECT_ID"));
			g.setParentCodeSetId(rs.getLong("PARENT_CODESET_ID"));
			g.setName(rs.getString("NAME"));
			g.setCode(rs.getString("CODE"));
			g.setGroupCode(rs.getString("GROUP_CODE"));
			g.setDescription(rs.getString("DESCRIPTION"));
			g.setCreationDate(rs.getDate("CREATION_DATE"));
			g.setModifiedDate(rs.getDate("MODIFIED_DATE"));
			return g;
		}
	};

	public JdbcCodeSetDao() {
	}

	public Map<String, String> getCodeSetProperties(long codesetId) {
		return propertyDao.getProperties(codeSetPropertyTableName, codeSetPropertyPrimaryColumnName, codesetId);
	}

	public void deleteCodeSetProperties(long codesetId) {
		propertyDao.deleteProperties(codeSetPropertyTableName, codeSetPropertyPrimaryColumnName, codesetId);
	}

	public void setCodeSetProperties(long codesetId, Map<String, String> props) {
		propertyDao.updateProperties(codeSetPropertyTableName, codeSetPropertyPrimaryColumnName, codesetId, props);
	}

	public long getNextCodeSetId() {
		return sequencerFactory.getNextValue(Models.CODESET.getObjectType(), Models.CODESET.name());
	}

	public void batchInsertCodeSet(List<CodeSet> codesets) {
		final List<CodeSet> inserts = codesets;
		if (inserts.size() > 0) {
			getExtendedJdbcTemplate().batchUpdate(getBoundSql("COMMUNITY_WEB.INSERT_CODESET").getSql(),
					new BatchPreparedStatementSetter() {
						public void setValues(PreparedStatement ps, int i) throws SQLException {
							CodeSet c = inserts.get(i);
							ps.setLong(1, c.getCodeSetId());
							ps.setInt(2, c.getObjectType());
							ps.setLong(3, c.getObjectId());
							ps.setLong(4, c.getParentCodeSetId());
							ps.setString(5, c.getName());
							ps.setString(6, c.getCode());
							ps.setString(7, c.getDescription());
							ps.setDate(8, new java.sql.Date(c.getCreationDate().getTime()));
							ps.setDate(9, new java.sql.Date(c.getModifiedDate().getTime()));
						}
						public int getBatchSize() {
							return inserts.size();
						}
					});
		}
	}

	public void batchUpdateCodeSet(List<CodeSet> codesets) {
		final List<CodeSet> updates = codesets;
		if (updates.size() > 0) {
			getExtendedJdbcTemplate().batchUpdate(getBoundSql("COMMUNITY_WEB.UPDATE_CODESET").getSql(),
					new BatchPreparedStatementSetter() {
						public void setValues(PreparedStatement ps, int i) throws SQLException {
							CodeSet c = updates.get(i);
							ps.setLong(1, c.getParentCodeSetId());
							ps.setString(2, c.getName());
							ps.setString(3, c.getGroupCode());
							ps.setString(4, c.getCode());
							ps.setString(5, c.getDescription());
							ps.setDate(6, new java.sql.Date(c.getModifiedDate().getTime()));
							ps.setLong(7, c.getCodeSetId());
						}

						public int getBatchSize() {
							return updates.size();
						}
					});
		}
	}

	public void saveOrUpdateCodeSet(List<CodeSet> codesets) {
		List<CodeSet> updates = new ArrayList<CodeSet>();
		List<CodeSet> inserts = new ArrayList<CodeSet>();
		for (CodeSet codeSet : codesets) {
			if (codeSet.getCodeSetId() < 1) {
				long codeSetId = getNextCodeSetId();
				codeSet.setCodeSetId(codeSetId);
				inserts.add(codeSet);
			} else {
				updates.add(codeSet);
			}
		}
		batchUpdateCodeSet(updates);
		batchInsertCodeSet(inserts);
	}

	public void saveOrUpdateCodeSet(CodeSet codeset) {
		if (codeset.getCodeSetId() == -1L) {
			long codeSetId = getNextCodeSetId();
			codeset.setCodeSetId(codeSetId);
			getJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.INSERT_CODESET").getSql(),
					new SqlParameterValue(Types.NUMERIC, codeset.getCodeSetId()),
					new SqlParameterValue(Types.NUMERIC, codeset.getObjectType()),
					new SqlParameterValue(Types.NUMERIC, codeset.getObjectId()),
					new SqlParameterValue(Types.NUMERIC, codeset.getParentCodeSetId()),
					new SqlParameterValue(Types.VARCHAR, codeset.getName()),
					new SqlParameterValue(Types.VARCHAR, codeset.getGroupCode()),
					new SqlParameterValue(Types.VARCHAR, codeset.getCode()),
					new SqlParameterValue(Types.VARCHAR, codeset.getDescription()),
					new SqlParameterValue(Types.TIMESTAMP, codeset.getCreationDate()),
					new SqlParameterValue(Types.TIMESTAMP, codeset.getModifiedDate()));
			if (codeset.getProperties().size() > 0) {
				setCodeSetProperties(codeset.getCodeSetId(), codeset.getProperties());
			}
		} else {
			getJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.UPDATE_CODESET").getSql(),
					new SqlParameterValue(Types.NUMERIC, codeset.getParentCodeSetId()),
					new SqlParameterValue(Types.VARCHAR, codeset.getName()),
					new SqlParameterValue(Types.VARCHAR, codeset.getGroupCode()),
					new SqlParameterValue(Types.VARCHAR, codeset.getCode()),
					new SqlParameterValue(Types.VARCHAR, codeset.getDescription()),
					new SqlParameterValue(Types.TIMESTAMP, codeset.getModifiedDate()),
					new SqlParameterValue(Types.NUMERIC, codeset.getCodeSetId()));
			deleteCodeSetProperties(codeset.getCodeSetId());
			setCodeSetProperties(codeset.getCodeSetId(), codeset.getProperties());
		}

	}

	/*
	 * CODESET_ID OBJECT_TYPE OBJECT_ID PARENT_CODESET_ID NAME DESCRIPTION
	 * CREATION_DATE MODIFIED_DATE
	 */
	public ModelObjectTreeWalker getTreeWalker(int objectType, long objectId) {
		int numCodeSets = getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.COUNT_CODESET_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId));
		numCodeSets++;

		final LongTree tree = new LongTree(-1L, numCodeSets);
		getExtendedJdbcTemplate().query(getBoundSql("COMMUNITY_WEB.SELECT_ROOT_CODESET").getSql(),
				new RowCallbackHandler() {
					public void processRow(ResultSet rs) throws SQLException {
						long commentId = rs.getLong(1);
						tree.addChild(-1L, commentId);
						logger.debug("tree add : " + commentId);
					}
				}, new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId));

		getExtendedJdbcTemplate().query(getBoundSql("COMMUNITY_WEB.SELECT_CHILD_CODESET").getSql(),
				new RowCallbackHandler() {
					public void processRow(ResultSet rs) throws SQLException {
						long commentId = rs.getLong(1);
						long parentCommentId = rs.getLong(2);
						tree.addChild(parentCommentId, commentId);
						logger.debug("tree add : " + parentCommentId + "," + commentId);
					}
				}, new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId));

		logger.debug("total:" + tree.getChildCount(-1L));
		StringBuilder sb = new StringBuilder();
		for (long id : tree.getRecursiveChildren(-1L)) {
			sb.append(id).append(", ");
		}
		logger.debug(sb.toString());
		
		return new ModelObjectTreeWalker(objectType, objectId, tree);
	}

	public List<Long> getCodeSetIds(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_WEB.SELECT_CODESET_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(),
				Long.class, new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId));
	}

	public CodeSet getCodeSetById(long codesetId) {
		CodeSet codeset = null;
		try {
			codeset = getExtendedJdbcTemplate().queryForObject(getBoundSql("COMMUNITY_WEB.SELECT_CODESET_BY_ID").getSql(), codesetMapper, new SqlParameterValue(Types.NUMERIC, codesetId));
			codeset.setProperties(getCodeSetProperties(codesetId));
		} catch (IncorrectResultSizeDataAccessException e) {
			if (e.getActualSize() > 1) {
				logger.warn((new StringBuilder()).append("Multiple occurrances of the same codeset ID found: ").append(codesetId).toString());
				throw e;
			}
		} catch (DataAccessException e) {
			String message = (new StringBuilder()).append("Failure attempting to load codeset by ID : ").append(codesetId).append(".").toString();
			logger.error(message, e);
		}
		return codeset;
	}

	
	public int getCodeSetCount(int objectType, long objectId) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.COUNT_CODESET_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), Integer.class,
				new SqlParameterValue(Types.NUMERIC, objectType), new SqlParameterValue(Types.NUMERIC, objectId));
	}

	public int getCodeSetCount(int objectType, long objectId, Long codeSetId) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.COUNT_CODESET_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_CODESET_ID").getSql(),
				Integer.class, new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), new SqlParameterValue(Types.NUMERIC, codeSetId));
	}

	public List<Long> getCodeSetIds(int objectType, long objectId, Long codeSetId) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_WEB.SELECT_CODESET_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_CODESET_ID").getSql(),
				Long.class, new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), new SqlParameterValue(Types.NUMERIC, codeSetId));
	}
 
	public List<Long> getCodeSetIds(int objectType, long objectId, String groupCode) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_WEB.SELECT_CODESET_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_GROUP").getSql(),
				Long.class, new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), new SqlParameterValue(Types.VARCHAR, groupCode));
	}
 
	public int getCodeSetCount(int objectType, long objectId, String groupCode) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.COUNT_CODESET_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_GROUP").getSql(),
				Integer.class, new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), new SqlParameterValue(Types.VARCHAR, groupCode));
	}
 
	public int getCodeSetCount(int objectType, long objectId, String group, String code) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.COUNT_CODESET_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_GROUP_AND_CODE").getSql(),
				Integer.class, 
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), 
				new SqlParameterValue(Types.VARCHAR, group),
				new SqlParameterValue(Types.VARCHAR, code));
	}
 
	public List<Long> getCodeSetIds(int objectType, long objectId, String group, String code) {
		return getExtendedJdbcTemplate().queryForList(
				getBoundSql("COMMUNITY_WEB.SELECT_CODESET_IDS_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_GROUP_AND_CODE").getSql(),
				Long.class, 
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), 
				new SqlParameterValue(Types.VARCHAR, group),
				new SqlParameterValue(Types.VARCHAR, code));
	}

 
	public Long findCodeSetByCode(int objectType, long objectId, String group, String code) {
		return getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.FIND_CODESET_BY_OBJECT_TYPE_AND_OBJECT_ID_AND_GROUP_AND_CODE").getSql(),
				Long.class, 
				new SqlParameterValue(Types.NUMERIC, objectType),
				new SqlParameterValue(Types.NUMERIC, objectId), 
				new SqlParameterValue(Types.VARCHAR, group),
				new SqlParameterValue(Types.VARCHAR, code));
	}

}
