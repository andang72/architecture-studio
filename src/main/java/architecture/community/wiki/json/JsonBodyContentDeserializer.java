package architecture.community.wiki.json;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.ObjectCodec;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonNode;

import architecture.community.wiki.BodyContent;

public class JsonBodyContentDeserializer extends JsonDeserializer<BodyContent>  {

	public BodyContent deserialize(JsonParser jsonParser, DeserializationContext deserializationContext)
			throws IOException, JsonProcessingException {
		ObjectCodec oc = jsonParser.getCodec();

		JsonNode node = oc.readTree(jsonParser);
		if (node == null) {
			return new BodyContent();
		} else {
			long bodyId = node.get("bodyId").asLong();
			long wikiId = node.get("wikiId").asLong();

			String bodyText = "";
			if (node.has("bodyText")) {
				bodyText = node.get("bodyText").textValue();
			} 
			return new BodyContent(bodyId, wikiId, bodyText);
		}
	}

}