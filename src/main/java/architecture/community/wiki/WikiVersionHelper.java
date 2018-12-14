package architecture.community.wiki;

import java.util.List;

import architecture.community.util.CommunityContextHelper;

public class WikiVersionHelper {

	public WikiVersionHelper() {
	}
	
	public static List<WikiVersion> getWikiVersions(long pageId) {
		return CommunityContextHelper.getComponent(WikiService.class).getWikiVersions(pageId);
	}

	public static WikiVersion getPublishedWikiVersion(long pageId) {
		List<WikiVersion> list = getWikiVersions(pageId);
		for (WikiVersion pv : list) {
			if (pv.getWikiState() == WikiState.PUBLISHED)
				return pv;
		}
		return null;
	}

	public static WikiVersion getNewestWikiVersion(long pageId) {
		List<WikiVersion> list = getWikiVersions(pageId);
		if (list.size() == 0)
			return null;
		return list.get(0);
	}

	public static WikiVersion getDeletedWikiVersion(long pageId) {
		List<WikiVersion> list = getWikiVersions(pageId);
		for (WikiVersion pv : list) {
			if (pv.getWikiState() == WikiState.DELETED)
				return pv;
		}
		return null;
	}
}
