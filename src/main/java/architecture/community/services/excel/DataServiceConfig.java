package architecture.community.services.excel;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import architecture.ee.jdbc.sqlquery.mapping.ParameterMapping;

public class DataServiceConfig implements Serializable {

	private String name;
	
	private String description;
	
	private String dataSourceName;
	
	private String statement;
	
	private String queryString;

	private String totalCountStatement;
	
	private String totalCountQueryString;	

	private Type type;
	
	private String fileName;
	
	private String sheetName;
	
	private List<ParameterMapping> parameterMappings;
	
	private List<ParameterMapping> resultMappings;
	
	private boolean header ;
	
	private List<Column> columns;	
	
 
	public DataServiceConfig(String name, String description) {
		this.totalCountStatement = null;
		this.totalCountQueryString = null;
		this.fileName = null;
		this.columns = new ArrayList<Column>();
		this.name = name;
		this.description = description;
		this.parameterMappings = null;
		this.resultMappings = null;
		this.header = true;
		this.sheetName = null;
		this.type = Type.NONE;
	}

	public DataServiceConfig() {
		this.totalCountStatement = null;
		this.totalCountQueryString = null;		
		this.name = null;
		this.description = null;
		this.fileName = null;
		this.columns = new ArrayList<Column>();
		this.parameterMappings = null;
		this.resultMappings = null;
		this.header = true;
		this.sheetName = null;
		this.type = Type.NONE;
	}
	
	
	public Type getType() {
		return type;
	}

	public void setType(Type type) {
		this.type = type;
	}

	public boolean isSetDataSourceName() {
		return StringUtils.isNotBlank(this.dataSourceName);
	} 
	
	public boolean isSetQueryString() {
		return StringUtils.isNotBlank(this.queryString);
	}
	
	public boolean isSetParameterMappings() {
		return parameterMappings == null ? false : true;
	}

	public boolean isSetResultMappings() {
		return resultMappings == null ? false : true;
	}
	
	public String getSheetName() {
		return sheetName;
	}

	public void setSheetName(String sheetName) {
		this.sheetName = sheetName;
	}

	public boolean isHeader() {
		return header;
	}

	public void setHeader(boolean header) {
		this.header = header;
	}

	public List<ParameterMapping> getParameterMappings() {
		return parameterMappings;
	}

	public void setParameterMappings(List<ParameterMapping> parameterMappings) {
		this.parameterMappings = parameterMappings;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getDataSourceName() {
		return dataSourceName;
	}

	public void setDataSourceName(String dataSourceName) {
		this.dataSourceName = dataSourceName;
	}

	public String getStatement() {
		return statement;
	}

	public void setStatement(String statement) {
		this.statement = statement;
	}

	public String getQueryString() {
		return queryString;
	}

	public void setQueryString(String queryString) {
		this.queryString = queryString;
	}

	public String getTotalCountStatement() {
		return totalCountStatement;
	}

	public void setTotalCountStatement(String totalCountStatement) {
		this.totalCountStatement = totalCountStatement;
	}

	public String getTotalCountQueryString() {
		return totalCountQueryString;
	}

	public void setTotalCountQueryString(String totalCountQueryString) {
		this.totalCountQueryString = totalCountQueryString;
	}

	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	public String getFileName() {
		return fileName;
	}


	public void setFileName(String fileName) {
		this.fileName = fileName;
	}


	public List<Column> getColumns() {
		return columns;
	}




	public List<ParameterMapping> getResultMappings() {
		return resultMappings;
	}

	public void setResultMappings(List<ParameterMapping> resultMappings) {
		this.resultMappings = resultMappings;
	}

	public void setColumns(List<Column> columns) {
		this.columns = columns;
	}


	public void addColumns(int index, String field, String title) {
		this.columns.add(new Column(index, field, title));
	}

	public void addColumns(Column column) {
		this.columns.add(column);
	}
	
	public static class Column implements Serializable  {
		
		private int index;
		
		private String field;
		
		private String title; 
		
		private String format;
		
		private int width;
		
		public Column() {
			this.index = 0 ;
			this.field = null;
			this.title = null;
			this.width = 0;
			this.format = null;
		}

		public Column(int index, String field, String title) { 
			this.index = index;
			this.field = field;
			this.title = title;
			this.width = 0;
			this.format = null;
		}

		public int getIndex() {
			return index;
		}

		public void setIndex(int index) {
			this.index = index;
		}

		public String getField() {
			return field;
		}

		public void setField(String field) {
			this.field = field;
		}

		public String getTitle() {
			return title;
		}

		public void setTitle(String title) {
			this.title = title;
		}
		
		
		public int getWidth() {
			return width;
		}

		public void setWidth(int width) {
			this.width = width;
		}


		public String getFormat() {
			return format;
		}

		public void setFormat(String format) {
			this.format = format;
		}


		public static class Builder {
			 
			private Column columnMapping = new Column();

			public Builder(String field) {
				columnMapping.field = field;
			}

			public Builder(int index, String field) {
				columnMapping.index = index;
				columnMapping.field = field;
			}

			public Column build() {
				return columnMapping;
			}

			public Builder field(String field) {
				columnMapping.field = field;
				return this;
			}

			public Builder width(int width) {
				columnMapping.width = width;
				return this;
			}

			public Builder format(String format) {
				columnMapping.format = format;
				return this;
			}
			
			public Builder index(int index) {
				columnMapping.index = index;
				return this;
			}
			
			public Builder title(String title) {
				columnMapping.title = title;
				return this;
			}
		};
	}
	
	
	public enum Type {
 		XLSX, 
	    OBJECT,
	    NONE,
	}
}
