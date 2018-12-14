package architecture.community.codeset;

public class Code {

	private long codeId;

	private long codeSetId;

	private String name;

	private int index;

	private String description;

	public Code() {		
		this.codeId = -1L;
		this.codeSetId = -1L;
		this.index = 0;
    }

	public long getCodeId() {
		return codeId;
	}

	public void setCodeId(long codeId) {
		this.codeId = codeId;
	}

	public long getCodeSetId() {
		return codeSetId;
	}

	public void setCodeSetId(long codeSetId) {
		this.codeSetId = codeSetId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getIndex() {
		return index;
	}

	public void setIndex(int index) {
		this.index = index;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

}
