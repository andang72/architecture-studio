package architecture.community.wiki;

public class BodyContent {

	private long bodyId;
	private long wikiId; 
	private String bodyText;

	public BodyContent() {
		this.bodyId = -1L;
		this.wikiId = -1L; 
	}

	public BodyContent(long wikiId, String bodyText) {
		this.bodyId = -1L;
		this.wikiId = wikiId; 
		setBodyText(bodyText);
	}

	/**
	 * @param bodyId
	 * @param pageId
	 * @param bodyType
	 * @param bodyText
	 */
	public BodyContent(long bodyId, long wikiId, String bodyText) {
		this.bodyId = bodyId;
		this.wikiId = wikiId; 
		setBodyText(bodyText);
	}

	/**
	 * @return bodyText
	 */
	public String getBodyText() {
		return bodyText;
	}

	/**
	 * @param bodyText
	 *            설정할 bodyText
	 */
	public void setBodyText(String bodyText) {
		this.bodyText = bodyText;
	}

	/**
	 * @return bodyId
	 */
	public long getBodyId() {
		return bodyId;
	}

	/**
	 * @param bodyId
	 *            설정할 bodyId
	 */
	public void setBodyId(long bodyId) {
		this.bodyId = bodyId;
	}

	public long getWikiId() {
		return wikiId;
	}

	public void setWikiId(long wikiId) {
		this.wikiId = wikiId;
	} 

}
