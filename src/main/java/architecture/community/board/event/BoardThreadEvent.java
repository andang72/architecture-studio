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

package architecture.community.board.event;

import org.springframework.context.ApplicationEvent;

import architecture.community.board.BoardThread;

public class BoardThreadEvent extends ApplicationEvent {

	public enum Type {

		CREATED,

		UPDATED,

		DELETED,

		MOVED,

		VIEWED
	};
	
	private Type type ;

	public BoardThreadEvent(BoardThread source, Type type) {
		
		super(source);
		
		this.type = type;
	}

	public Type getType() {
		return type;
	}

}
