package architecture.community.wiki;

import java.util.Calendar;
import java.util.Date;
 
import architecture.community.user.User;

public class WikiVersion {

	private int versionNumber;
	private WikiState wikiState;
	private Date creationDate;
	private Date modifiedDate;
	private Wiki wiki;
	private User user;

	public WikiVersion() {
		this.versionNumber = -1;
		this.wikiState = WikiState.INCOMPLETE;
		this.creationDate = Calendar.getInstance().getTime();
		this.modifiedDate = this.creationDate;
	}
 
	/**
	 * @return versionNumber
	 */
	public int getVersionNumber() {
		return versionNumber;
	}

	/**
	 * @param versionNumber
	 *            설정할 versionNumber
	 */
	public void setVersionNumber(int versionNumber) {
		this.versionNumber = versionNumber;
	}
 
	/**
	 * @return creationDate
	 */
	public Date getCreationDate() {
		return creationDate;
	}

	/**
	 * @param creationDate
	 *            설정할 creationDate
	 */
	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	/**
	 * @return modifiedDate
	 */
	public Date getModifiedDate() {
		return modifiedDate;
	}

	/**
	 * @param modifiedDate
	 *            설정할 modifiedDate
	 */
	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	}

	public User getAuthor() {
		// TODO 자동 생성된 메소드 스텁
		return user;
	}

	public void setAuthor(User author) {
		this.user = author;
	}

 
	public WikiState getWikiState() {
		return wikiState;
	}

	public void setWikiState(WikiState wikiState) {
		this.wikiState = wikiState;
	}

	public Wiki getWiki() {
		return wiki;
	}

	public void setWiki(Wiki wiki) {
		this.wiki = wiki;
	}


}
