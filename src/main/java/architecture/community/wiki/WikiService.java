package architecture.community.wiki;

import java.util.List;

import architecture.community.user.User;

public interface WikiService {

	public abstract Wiki createWiki(User user, String name, String title, String body);

	public abstract void saveOrUpdateWiki(Wiki wiki);

	public abstract void saveOrUpdateWiki(Wiki wiki, boolean forceNewVersion);

	public abstract Wiki getWiki(long wikiId) throws WikiNotFoundException;

	public abstract Wiki getWiki(long wikiId, int versionId) throws WikiNotFoundException;

	public abstract Wiki getWiki(String name) throws WikiNotFoundException;

	public abstract Wiki getWiki(String name, int versionId) throws WikiNotFoundException;

	public abstract List<Wiki> getWikis(int objectType);

	public abstract List<Wiki> getWikis(int objectType, long objectId);

	public abstract List<Wiki> getWikis(int objectType, long objectId, int startIndex, int maxResults);

	public abstract int getWikiCount(int objectType);

	public abstract int getWikiCount(int objectType, long objectId);

	public abstract List<WikiVersion> getWikiVersions(long wikiId);

	public abstract List<Wiki> getWikis(int objectType, WikiState state);

	public abstract List<Wiki> getWikis(int objectType, WikiState state, int startIndex, int maxResults);

	public abstract int getWikiCount(int objectType, WikiState state);

	public abstract int getWikiCount(int objectType, long objectId, WikiState state);

	public abstract List<Wiki> getWikis(int objectType, long objectId, WikiState state);

	public abstract List<Wiki> getWikis(int objectType, long objectId, WikiState state, int startIndex, int maxResults);
	
}
