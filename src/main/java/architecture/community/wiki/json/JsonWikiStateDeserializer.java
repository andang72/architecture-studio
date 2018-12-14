package architecture.community.wiki.json;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import architecture.community.wiki.WikiState;

public class JsonWikiStateDeserializer extends JsonDeserializer<WikiState>  {

	public WikiState deserialize(JsonParser jsonParser, DeserializationContext deserializationContext)
		    throws IOException, JsonProcessingException {
	    		return WikiState.valueOf(jsonParser.getText().toUpperCase());
	    }

}
