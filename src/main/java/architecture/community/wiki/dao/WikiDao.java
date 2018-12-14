package architecture.community.wiki.dao;

import java.util.List;
 
import architecture.community.wiki.Wiki;
import architecture.community.wiki.WikiState;
import architecture.community.wiki.WikiVersion;

public interface WikiDao {
	 
	public abstract void create(Wiki wiki);

	public abstract void update(Wiki wiki, boolean flag);

	public abstract void delete(Wiki wiki);

	public abstract Wiki getWikiById(long pageId);

	public abstract Wiki getWikiById(long pageId, int versionNumber);

	public abstract Wiki getWikiByName(String name);

	public abstract Wiki getWikiByName(String name, int versionNumber);

	public abstract Wiki getWikiByTitle(int objectType, long objectId, String title);

	public abstract int getWikiCount(int objectType, long objectId);

	public abstract List<Long> getWikiIds(int objectType, long objectId);

	public abstract List<Long> getWikiIds(int objectType, long objectId, int startIndex, int maxResults);

	public abstract List<Long> getWikiIds(int objectType, WikiState state);

	public abstract List<Long> getWikiIds(int objectType, WikiState state, int startIndex, int maxResults);

	public abstract int getWikiCount(int objectType, WikiState state);

	public abstract List<Long> getWikiIds(int objectType, long objectId, WikiState state);

	public abstract List<Long> getWikiIds(int objectType, long objectId, WikiState state, int startIndex, int maxResults);

	public abstract int getWikiCount(int objectType, long objectId, WikiState state); 
	
    public abstract void update(WikiVersion wikiVersion);

    public abstract void delete(WikiVersion wikiVersion);

    public abstract WikiVersion getWikiVersion(long wikiId, int version);

    public abstract List<WikiVersion> getWikiVersions(long wikiId);

    public abstract List<Integer> getWikiVersionIds(long wikiId);
    
}
