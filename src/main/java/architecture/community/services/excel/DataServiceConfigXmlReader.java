package architecture.community.services.excel;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.Node;
import org.dom4j.io.SAXReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import architecture.community.services.excel.DataServiceConfig.Column;
import architecture.ee.jdbc.sqlquery.builder.xml.XmlStatementBuilder;
import architecture.ee.jdbc.sqlquery.mapping.ParameterMapping;
import architecture.ee.jdbc.sqlquery.type.TypeAliasRegistry;
import architecture.ee.util.StringUtils;

public class DataServiceConfigXmlReader {
	
	private static final Logger log = LoggerFactory.getLogger(DataServiceConfigXmlReader.class);
	
	private static final TypeAliasRegistry typeAliasRegistry = new TypeAliasRegistry();
	
	private File file;
	
	private Document document; 
	
	private  Map<String, DataServiceConfig> holder ; 
	
	public DataServiceConfigXmlReader(File file, Map<String, DataServiceConfig> holder ) throws IOException {
		this.file = file;
		if (!file.exists()) {
			// Attempt to recover from this error case by seeing if the
			// tmp file exists. It's possible that the rename of the
			// tmp file failed the last time Jive was running,
			// but that it exists now.
			File tempFile;
			tempFile = new File(file.getParentFile(), file.getName() + ".tmp");
			if (tempFile.exists()) {
				// log.error(L10NUtils.format("002157", file.getName()));
				tempFile.renameTo(file);
			}
			// There isn't a possible way to recover from the file not
			// being there, so throw an error.
			else {
				throw new FileNotFoundException(); // L10NUtils.format("002151",
													// file.getName()));
			}
		}
		// Check read and write privs.
		if (!file.canRead()) {
			throw new IOException(); // L10NUtils.format("002152",
										// file.getName()));
		}
		if (!file.canWrite()) {
			throw new IOException(); // L10NUtils.format("002153",
										// file.getName()));
		}

		Reader reader = null;
		try {
			reader = new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8);
			this.holder = holder;
			buildDoc(reader);
		} catch (Exception e) { 
			throw new IOException(e.getMessage());
		} finally {
			try {
				reader.close();
			} catch (Exception e) {
				log.debug(e.getMessage(), e);
			}
		} 
	}
	public DataServiceConfigXmlReader(InputStream in , Map<String, DataServiceConfig> holder ) throws IOException {
		Reader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
		this.holder = holder;
		buildDoc(reader);
	}

	private void buildDoc(Reader in) throws IOException {
		try {
			SAXReader xmlReader = new SAXReader();
			xmlReader.setEncoding("UTF-8");
			document = xmlReader.read(in);
		
		} catch (Exception e) {
			log.error("Error reading XML", e);
			throw new IOException(e.getMessage());
		} finally {
			if (in != null) {
				in.close();
			}
		}
	}
	
	public void parse() throws Exception {
		List<Node> list = document.selectNodes("//data-service");
		excelExportElement(list);
	}
	
	private void excelExportElement(List<Node> list) throws Exception {
		for (Node node : list) {
			Element ele = (Element) node;
			log.debug(" {} - {} , element {} ", ele.attributeValue("name", null), ele.attributeValue("description", null), node.asXML());
			
			Element soruceEl = ele.element("source");
			DataServiceConfig config = new DataServiceConfig(ele.attributeValue("name", null),  ele.attributeValue("description", null) );
			
			config.setDataSourceName(soruceEl.elementText("dataSourceName"));
			config.setStatement(soruceEl.elementTextTrim("statement"));
			config.setQueryString(soruceEl.elementText("queryString"));
			
			config.setHeader( Boolean.parseBoolean( ele.elementText("header") ) ) ;
			
			Element parameterMappingsEl = soruceEl.element("parameter-mappings");
			if( parameterMappingsEl != null )
			{
				config.setParameterMappings(getParameterMappings(parameterMappingsEl.elements()));
			}
				
			Element resultMappingsEl = soruceEl.element("result-mappings");
			if( resultMappingsEl != null )
			{
				config.setResultMappings(getParameterMappings(resultMappingsEl.elements()));
			}
			
			Element targetEl = ele.element("target");
			if(targetEl!=null) {
				String typeString = StringUtils.defaultString( targetEl.elementText("type"), "NONE");
				config.setType( DataServiceConfig.Type.valueOf(typeString.toUpperCase()) );
				if( config.getType() != DataServiceConfig.Type.NONE ) {
					config.setFileName(targetEl.elementTextTrim("fileName"));
					config.setSheetName(targetEl.elementTextTrim("sheetName"));
				}
			} 
			
			Element columnsEl = ele.element("columns");
			if( columnsEl != null )
			{
				for (Element child : columnsEl.elements()) {
					Column.Builder builder = new Column.Builder(child.attributeValue("field"));
					builder.index(Integer.parseInt(child.attributeValue("index", "0")));
					builder.width(Integer.parseInt(child.attributeValue("width", "0")));
					builder.title(child.attributeValue("title"));
					config.addColumns(builder.build());
				}
			}
			
			holder.put( config.getName(), config );			
		}
	}
	
	private List<ParameterMapping> getParameterMappings( List<Element> elements ) {
		List<ParameterMapping> parameterMappings = new ArrayList<ParameterMapping>();
		for (Element child : elements ) {
			ParameterMapping.Builder builder = new ParameterMapping.Builder(child.attributeValue(XmlStatementBuilder.XML_ATTR_NAME_TAG));
			builder.column( child.attributeValue("name", null));
			builder.index(Integer.parseInt(child.attributeValue("index", "0")));
			builder.mode(child.attributeValue("mode", "NONE"));
			builder.primary(Boolean.parseBoolean(child.attributeValue("primary", "false")));
			builder.encoding(child.attributeValue("encoding", null));
			builder.pattern(child.attributeValue("pattern", null));
			builder.cipher(child.attributeValue("cipher", null));
			builder.cipherKey(child.attributeValue("cipherKey", null));
			builder.cipherKeyAlg(child.attributeValue("cipherKeyAlg", null));
			builder.digest(child.attributeValue("digest", null));
			builder.size(child.attributeValue("size", "0"));
			String javaTypeName = child.attributeValue("javaType", null);
			String jdbcTypeName = child.attributeValue("jdbcType", null);			
			if (!StringUtils.isEmpty(jdbcTypeName))
				builder.jdbcTypeName(jdbcTypeName);					
			if (!StringUtils.isEmpty(javaTypeName ))
				builder.javaType(typeAliasRegistry.resolveAlias(javaTypeName));
			parameterMappings.add(builder.build());
		}
		return parameterMappings;
	}
	
}
