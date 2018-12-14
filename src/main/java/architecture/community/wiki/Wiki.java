package architecture.community.wiki;

import java.util.Calendar;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.ModelObjectAwareSupport;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.model.json.JsonUserDeserializer;
import architecture.community.user.User;
import architecture.community.user.UserTemplate;
import architecture.community.wiki.json.JsonBodyContentDeserializer;
import architecture.community.wiki.json.JsonWikiStateDeserializer;

public class Wiki extends ModelObjectAwareSupport {
	
	private Long wikiId;
	
	private String title;
	
	private Date creationDate;
	
	private Date modifiedDate;
	
	private String name ;
	
	private WikiState wikiState;
	 
	 
	private BodyContent bodyContent;
	
	private Integer version ;
	
	private User creater;
	
	private User modifier;
	
	private boolean secured;
	
	public Wiki( ) {
		this(-1, -1L);
		this.wikiId = -1L;
		this.version = 0;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;		
		this.name = null;
		this.wikiId = -1L;
		this.version = -1;
		this.wikiState = WikiState.INCOMPLETE;
		this.creater = new UserTemplate(-1L);
		this.title = "";
		this.secured = false;
	}

	public Wiki(Long wikiId) {
		super(-1, -1L);
		this.wikiId = wikiId;
		this.name = null;
		this.version = -1;
		this.wikiState =WikiState.INCOMPLETE;
		this.creater = new UserTemplate(-1L);
		this.title = ""; 
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = creationDate;
		this.secured = false;
	}
	
	public Wiki(int objectType, long objectId) {
		super(objectType, objectId); 
		this.wikiId = -1L;
		this.version = 0;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;		 
		this.secured = false;
	} 
	
	public Wiki(int objectType, long objectId, long wikiId) {
		super(objectType, objectId);
		this.wikiId = wikiId;
		this.version = 0;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;		
		this.secured = false;
	}

	
	
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreationDate() {
		return creationDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getModifiedDate() {
		return modifiedDate;
	}

	@JsonDeserialize(using = JsonDateDeserializer.class)
	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	}

	public Long getWikiId() {
		return wikiId;
	}

	public void setWikiId(Long wikiId) {
		this.wikiId = wikiId;
	}

	public Integer getVersion() {
		return version;
	}

	public void setVersion(Integer version) {
		this.version = version;
	}

	public User getCreater() {
		return creater;
	}

	@JsonDeserialize(using = JsonUserDeserializer.class)
	public void setCreater(User creater) {
		this.creater = creater;
	}

	public User getModifier() {
		return modifier;
	}

	@JsonDeserialize(using = JsonUserDeserializer.class)
	public void setModifier(User modifier) {
		this.modifier = modifier;
	}

 
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	
	@JsonIgnore
	public String getBodyText() {
		if (bodyContent == null)
			return null;
		else
			return bodyContent.getBodyText();
	}

	@JsonIgnore
	public void setBodyText(String body) {
		bodyContent.setBodyText(body);
	}
	
	/**
	 * @return bodyContent
	 */
	public BodyContent getBodyContent() {
		return bodyContent;
	}

	/**
	 * @param bodyContent
	 *            설정할 bodyContent
	 */
	@JsonDeserialize(using = JsonBodyContentDeserializer.class)
	public void setBodyContent(BodyContent bodyContent) {
		this.bodyContent = bodyContent;
	}	
	
	/**
	 * @return pageState
	 */
	public WikiState getWikiState() {
		return wikiState;
	}

	
	
	public boolean isSecured() {
		return secured;
	}

	public void setSecured(boolean secured) {
		this.secured = secured;
	}

	/**
	 * @param pageState
	 *            설정할 pageState
	 */

	@JsonDeserialize(using = JsonWikiStateDeserializer.class)
	public void setWikiState(WikiState wikiState) {
		this.wikiState = wikiState;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("Wiki [");
		if (wikiId != null)
			builder.append("wikiId=").append(wikiId).append(", ");
		if (title != null)
			builder.append("title=").append(title).append(", ");
		if (creationDate != null)
			builder.append("creationDate=").append(creationDate).append(", ");
		if (modifiedDate != null)
			builder.append("modifiedDate=").append(modifiedDate).append(", ");
		if (name != null)
			builder.append("name=").append(name).append(", ");
		if (wikiState != null)
			builder.append("wikiState=").append(wikiState).append(", ");
		if (version != null)
			builder.append("version=").append(version).append(", ");
		builder.append("secured=").append(secured).append("]");
		return builder.toString();
	}	
	
	
}
