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

package architecture.community.viewcount;

import architecture.community.board.BoardThread;
import architecture.community.page.Page;

public interface ViewCountService {

	public abstract void addViewCount(BoardThread thread);

	public abstract int getViewCount(BoardThread thread);
	
	public abstract void clearCount(BoardThread thread);
	
	
	
	public abstract void addViewCount(Page page);

	public abstract int getViewCount(Page page);
	
	public abstract void clearCount(Page page);
	
	
	public abstract void addViewCount(int objectType, long objectId );

	public abstract int getViewCount(int objectType, long objectId );
	
	public abstract void clearCount(int objectType, long objectId );
	
	
	public abstract void updateViewCounts();
	
	public abstract boolean isViewCountsEnabled() ;
}
