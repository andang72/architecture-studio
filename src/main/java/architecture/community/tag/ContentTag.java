package architecture.community.tag;

import java.util.Date;

public interface ContentTag {

	public static final int SORT_TAGNAME = 6000;
	
	public static final int SORT_TAGCOUNT = 6001;

	public abstract long getTagId();

	public abstract String getUnfilteredName();

	public abstract String getName();

	public abstract Date getCreationDate();

}