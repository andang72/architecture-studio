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

package architecture.community.model;

import architecture.community.announce.Announce;
import architecture.community.attachment.Attachment;
import architecture.community.board.Board;
import architecture.community.board.BoardMessage;
import architecture.community.board.BoardThread;
import architecture.community.category.Category;
import architecture.community.codeset.CodeSet;
import architecture.community.comment.Comment;
import architecture.community.image.Image;
import architecture.community.image.LogoImage;
import architecture.community.menu.Menu;
import architecture.community.menu.MenuItem;
import architecture.community.page.Page;
import architecture.community.page.api.Api;
import architecture.community.projects.Issue;
import architecture.community.projects.Project;
import architecture.community.projects.Scm;
import architecture.community.projects.Task;
import architecture.community.tag.ContentTag;
import architecture.community.user.AvatarImage;
import architecture.community.user.Role;
import architecture.community.user.User;
import architecture.community.wiki.Wiki;

public enum Models {
	
	UNKNOWN(-1, null), 
	USER(1, User.class), 
	ROLE(3, Role.class),
	CATEGORY(4, Category.class),
	BOARD(5, Board.class),
	BOARD_THREAD(6, BoardThread.class),
	BOARD_MESSAGE(7, BoardMessage.class),
	COMMENT(8, Comment.class),
	ANNOUNCE(9, Announce.class),
	ATTACHMENT(10, Attachment.class),
	IMAGE(11, Image.class),
	LOGO_IMAGE(12, LogoImage.class),
	AVATAR_IMAGE(13, AvatarImage.class),
	PAGE(14, Page.class),
	TAG(15, ContentTag.class),
	CODESET(17, CodeSet.class),
	ISSUE(18, Issue.class),
	PROJECT(19, Project.class),
	TASK(20, Task.class),
	SCM(21, Scm.class),
	MENU(25, Menu.class),
	MENU_ITEM(26, MenuItem.class),
	API(30, Api.class),
	WIKI(35, Wiki.class),
	WIKI_BODY(36, architecture.community.wiki.BodyContent.class)
	;
	
	private int objectType;
	
	private Class objectClass;
	
	private Models(int objectType, Class clazz) {
		this.objectType = objectType;
		this.objectClass = clazz;
	}
	
	public Class getObjectClass() {
		return objectClass;
	}

	public int getObjectType()
	{
		return objectType;
	} 
	
	public static Models valueOf(int objectType){
		Models selected = Models.UNKNOWN ;
		for( Models m : Models.values() )
		{
			if( m.getObjectType() == objectType ){
				selected = m;
				break;
			}
		}
		return selected;
	}
}


