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

package architecture.community.image;

import java.io.IOException;
import java.io.InputStream;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.PropertyAwareSupport;
import architecture.community.model.json.JsonDateDeserializer;
import architecture.community.model.json.JsonDateSerializer;
import architecture.community.model.json.JsonUserDeserializer;
import architecture.community.user.User;
import architecture.community.util.SecurityHelper;

public class DefaultImage extends PropertyAwareSupport implements Image {
	
	private Long imageId;
	
	private String name;
	 
	private Integer size;
	
	private String contentType;
	
	private Integer objectType;
	
	private Long objectId;
	
	private InputStream inputStream;
	
	private Integer thumbnailSize ;
	
	private String thumbnailContentType ;
	
	private User user;
	
	private Date creationDate;
	
	private Date modifiedDate;
	
	public DefaultImage() {
		this.user = SecurityHelper.ANONYMOUS;
		this.imageId = UNKNOWN_OBJECT_ID;
		this.objectType = UNKNOWN_OBJECT_TYPE;
		this.objectId = UNKNOWN_OBJECT_ID;
		this.thumbnailContentType = DEFAULT_THUMBNAIL_CONTENT_TYPE;
		this.size = 0;
		this.thumbnailSize = 0 ;
	}

	public DefaultImage(Integer objectType, Long objectId) {
		this.imageId = UNKNOWN_OBJECT_ID;
		this.objectType = objectType;
		this.objectId = objectId;
		this.thumbnailContentType = DEFAULT_THUMBNAIL_CONTENT_TYPE;
		this.size = 0;
		this.thumbnailSize = 0 ;
		this.user = SecurityHelper.ANONYMOUS;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public long getImageId() {
		return imageId;
	}

	public void setImageId(Long imageId) {
		this.imageId = imageId;
	}

	public void setSize(int size) {
		this.size = size;
	}

	public void setContentType(String contentType) {
		this.contentType = contentType;
	}

	public String getContentType() {
		return contentType;
	}

	public int getSize() {
		return size ;
	}

	@JsonIgnore
	public InputStream getInputStream() throws IOException {
		return inputStream;
	}

	public int getObjectType() {
		return objectType;
	}

	public void setObjectType(Integer objectType) {
		this.objectType = objectType;
	}

	public long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	public Integer getThumbnailSize() {
		return thumbnailSize;
	}

	public void setThumbnailSize(Integer thumbnailSize) {
		this.thumbnailSize = thumbnailSize;
	}

	public String getThumbnailContentType() {
		return thumbnailContentType;
	}

	public void setThumbnailContentType(String thumbnailContentType) {
		this.thumbnailContentType = thumbnailContentType;
	}

	public User getUser() {
		return user;
	}

	 @JsonDeserialize(using = JsonUserDeserializer.class)
	public void setUser(User user) {
		this.user = user;
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
	
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("Image{");
	    sb.append("imageId=").append(imageId);
	    sb.append(",name=").append(getName());
	    sb.append(",contentType=").append(contentType);
	    sb.append("size=").append(size);
		sb.append("}");
		return sb.toString();
	}
	
}
