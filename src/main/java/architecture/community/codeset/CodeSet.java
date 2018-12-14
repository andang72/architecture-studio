package architecture.community.codeset;

import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.ModelObjectAware;
import architecture.community.model.PropertyAwareSupport;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.model.json.JsonPropertyDeserializer;
import architecture.community.model.json.JsonPropertySerializer;

public class CodeSet extends PropertyAwareSupport implements ModelObjectAware {

	private int objectType;
	private long objectId;
	private long codeSetId;
	private long parentCodeSetId;
	private String code;
	private String name;
	private String description;
	private boolean enabled;
	private Date creationDate;
	private Date modifiedDate;
	private List<Code> codes;
	private boolean hasChildren;
	private String groupCode;

	public CodeSet() {
		this.codeSetId = UNKNOWN_OBJECT_ID;
		this.parentCodeSetId = UNKNOWN_OBJECT_ID;
		this.objectType = UNKNOWN_OBJECT_TYPE;
		this.objectId = UNKNOWN_OBJECT_ID;
		this.creationDate = new Date();
		this.modifiedDate = this.creationDate;
		this.hasChildren = false;
		this.code = null;
		this.codes = Collections.EMPTY_LIST;
		this.groupCode = null;
	}

	public CodeSet(long codeGroupId) {
		this.codeSetId = codeGroupId;
	}

	public Long getParentCodeSetId() {
		return parentCodeSetId;
	}

	public void setParentCodeSetId(Long parentCodeSetId) {
		this.parentCodeSetId = parentCodeSetId;
	}

	public int getObjectType() {
		return objectType;
	}

	public void setObjectType(int objectType) {
		this.objectType = objectType;
	}

	public long getObjectId() {
		return objectId;
	}

	public void setObjectId(long objectId) {
		this.objectId = objectId;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
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

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public long getCodeSetId() {
		return codeSetId;
	}

	public void setCodeSetId(long codeSetId) {
		this.codeSetId = codeSetId;
	}

	@JsonDeserialize(using = JsonPropertyDeserializer.class)
	public void setProperties(Map<String, String> properties) {
		super.setProperties(properties);
	}

	@JsonSerialize(using = JsonPropertySerializer.class)
	public Map<String, String> getProperties() {
		return super.getProperties();
	}

	public List<Code> getCodes() {
		return codes;
	}

	public void setCodes(List<Code> codes) {
		this.codes = codes;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public boolean isHasChildren() {
		return hasChildren;
	}

	public void setHasChildren(boolean hasChildren) {
		this.hasChildren = hasChildren;
	}

	public String getGroupCode() {
		return groupCode;
	}

	public void setGroupCode(String groupCode) {
		this.groupCode = groupCode;
	}

	@Override
	public String toString() {
		return "CodeSet [codeSetId=" + codeSetId + ", name=" + name + ", enabled=" + enabled + "]";
	}

}
