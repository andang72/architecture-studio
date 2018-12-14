package architecture.community.projects.stats;

import architecture.community.codeset.CodeSet;

public class IssueCount {

	String code ;
	String name ;
	Integer value ;
	
	public IssueCount (CodeSet code){
		this.name = code.getName();
		this.code = code.getCode();
		this.value = 0;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getValue() {
		return value;
	}

	public void setValue(Integer value) {
		this.value = value;
	} 
}
