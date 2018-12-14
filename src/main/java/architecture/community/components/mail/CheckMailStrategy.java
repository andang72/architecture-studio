package architecture.community.components.mail;

import java.io.IOException;

import javax.mail.MessagingException;

public interface CheckMailStrategy {
	
    public abstract EmailBatch checkForMessages(String host, int port, String user, String password, boolean useSSL) throws MessagingException, IOException;

}
