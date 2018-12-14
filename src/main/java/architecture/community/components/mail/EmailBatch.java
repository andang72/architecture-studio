package architecture.community.components.mail;

import java.util.Iterator;
import java.util.List;
import javax.mail.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EmailBatch {

	private Logger log = LoggerFactory.getLogger(EmailBatch.class);
	private final List<InboundMessage> newMessages;
	private final Folder folder;
	private final Store store;

	EmailBatch(List<InboundMessage> newMessages, Folder folder, Store store) {
		this.newMessages = newMessages;
		this.folder = folder;
		this.store = store;
	}

	public Iterator<InboundMessage> getMessages() {
		return newMessages.iterator();
	}

	public void close() {
		try {
			if (folder.isOpen())
				folder.close(true);
			if (store.isConnected())
				store.close();
		} catch (MessagingException e) {
			log.warn("Unable to close EmailBatch", e);
		}
	}

}
