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

package architecture.community.link.dao.jdbc;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlParameterValue;

import architecture.community.link.ExternalLink;
import architecture.community.link.dao.ExternalLinkDao;
import architecture.ee.spring.jdbc.ExtendedJdbcDaoSupport;

public class JdbcExternalLinkDao extends ExtendedJdbcDaoSupport implements ExternalLinkDao {

	private final RowMapper<ExternalLink> externalLinkMapper = new RowMapper<ExternalLink>(){
		public ExternalLink mapRow(ResultSet rs, int rowNum) throws SQLException {
			ExternalLink link = new ExternalLink(
				rs.getString("LINK_ID"),	
				rs.getInt("OBJECT_TYPE"),
				rs.getLong("OBJECT_ID"),				
				rs.getInt("PUBLIC_SHARED") == 1 
			);			
			return link;
		}		
	};
	
	public JdbcExternalLinkDao() {
	}
 
	public ExternalLink getExternalLinkByObjectTypeAndObjectId(Integer objectType, Long objectId) {
		ExternalLink link =  getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.SELECT_EXTERNAL_LINK_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 
				externalLinkMapper, 
				new SqlParameterValue (Types.NUMERIC, objectType ),
				new SqlParameterValue (Types.NUMERIC, objectId ));			
		return link;
	}
 
	public ExternalLink getExternalLink(String linkId) {
		ExternalLink link =  getExtendedJdbcTemplate().queryForObject(
				getBoundSql("COMMUNITY_WEB.SELECT_IMAGE_LINK_BY_LINK_ID").getSql(), 
				externalLinkMapper, 
				new SqlParameterValue (Types.VARCHAR, linkId ));			
		return link;		
	}
 
	public void saveExternalLink(ExternalLink link) {
		getExtendedJdbcTemplate().update(getBoundSql("COMMUNITY_WEB.INSERT_EXTERNAL_LINK").getSql(), 	
				new SqlParameterValue (Types.VARCHAR, link.getExternalId() ), 
				new SqlParameterValue (Types.NUMERIC, link.getObjectType() ), 
				new SqlParameterValue (Types.NUMERIC, link.getObjectId() ), 
				new SqlParameterValue (Types.INTEGER, link.isPublicShared() ? 1 : 0  ) );
	}
 
	public void removeExternalLink(String linkId) {
		getExtendedJdbcTemplate().update(
				getBoundSql("COMMUNITY_WEB.DELETE_EXTERNAL_LINK_BY_LINK_ID").getSql(), 	
				new SqlParameterValue (Types.VARCHAR, linkId));	
	}
 
	public void removeExternalLink(int objectType, long objectId) {
		getExtendedJdbcTemplate().update(
				getBoundSql("COMMUNITY_WEB.DELETE_EXTERNAL_LINK_BY_OBJECT_TYPE_AND_OBJECT_ID").getSql(), 	
				new SqlParameterValue (Types.NUMERIC, objectType ),
				new SqlParameterValue (Types.NUMERIC, objectId ));	
	}

}
