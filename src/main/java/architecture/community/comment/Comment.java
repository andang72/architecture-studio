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

package architecture.community.comment;

import java.util.Date;

import architecture.community.model.ContentModelObject;
import architecture.community.user.User;

public interface Comment extends ContentModelObject {
	
	//public static final int MODLE_OBJECT_TYPE = 8;

	public abstract Status getStatus();

    public abstract void setStatus(Comment.Status status);

    public abstract long getCommentId();

    public abstract long getParentObjectId();

    public abstract int getParentObjectType();
    
    public abstract long getParentCommentId();   

    public abstract User getUser();

    public abstract void setUser(User user);

    public abstract String getName();

    public abstract void setName(String name);

    public abstract String getEmail();

    public abstract void setEmail(String email);

    public abstract String getURL();

    public abstract void setURL(String url);

    public abstract String getIPAddress();

    public abstract void setIPAddress(String address);

    public abstract boolean isAnonymous();

    public abstract String getBody();

    public abstract void setBody(String body);

    public abstract int getReplyCount ();
    
    public abstract Date getCreationDate();

    public abstract void setCreationDate(Date creationDate);

    public abstract Date getModifiedDate();

    public abstract void setModifiedDate(Date modifiedDate);
    
}
