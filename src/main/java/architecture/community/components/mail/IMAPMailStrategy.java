package architecture.community.components.mail;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Store;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import architecture.ee.service.ConfigService;
import architecture.ee.util.StringUtils;

public class IMAPMailStrategy implements CheckMailStrategy {
	
	private Logger log = LoggerFactory.getLogger(IMAPMailStrategy.class);

	private ConfigService configService;

	public IMAPMailStrategy(ConfigService configService) {
		this.configService = configService;
	}

	public EmailBatch checkForMessages(String host, int port, String user, String password, boolean useSSL)
			throws MessagingException, IOException {
		Store store = null;
		Folder folder = null;
		List<InboundMessage> messages = new ArrayList<InboundMessage>();
		
		/** 메일 박스 이름 */
		String folderName = configService.getApplicationProperty("services.checkmail.folderName", "INBOX");
		/** 불필요 메일을 삭제할 것인지 여부 */
		boolean enableDeleteUnused = configService.getApplicationBooleanProperty("services.checkmail.deleteUnusedMail", false);
		/** 읽은 메일을 삭제할건지 여부 */
		boolean enableDeleteSeen = configService.getApplicationBooleanProperty("services.checkmail.deleteSeenMail", false);
		try {
			Properties props = new Properties();
			props.put("mail.imap.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
			props.put("mail.imap.socketFactory.fallback", "false");
			
			if (useSSL) {
				// TODO 
				// Security.setProperty("ssl.SocketFactory.provider",
				// "com.jivesoftware.util.ssl.DummySSLSocketFactory");
				// props.setProperty("mail.imaps.socketFactory.class",
				// "com.jivesoftware.util.ssl.DummySSLSocketFactory");
				// props.setProperty("mail.imaps.socketFactory.fallback", "true");
			}
			Session session = Session.getInstance(props, null);
			session.setDebug(false);
			if (useSSL)
				store = session.getStore("imaps");
			else
				store = session.getStore("imap");
			
			store.connect(host, port, user, password);
			folder = store.getFolder(folderName);
			folder.open(Folder.READ_WRITE);
			
			log.debug("email monitor open folder {} ({}).", folderName, folder.getMessageCount() );
			
			Message allMessages[] = folder.getMessages();
			for (int i = 0; i < allMessages.length; i++) {
				if (allMessages[i].getFlags().contains(javax.mail.Flags.Flag.SEEN)) {
					if(enableDeleteSeen)
						allMessages[i].setFlag(javax.mail.Flags.Flag.DELETED, true);
					continue;
				}
				if (canProcessMessage(allMessages[i])) {
					IMAPMessage message = new IMAPMessage(allMessages[i]);
					messages.add(message); 
					log.debug("From: {}, date: {}, subject: {}", MessageUtils.addressArrayToString(message.getFrom()), message.getSentDate(),message.getSubject() ); 
					allMessages[i].setFlag(javax.mail.Flags.Flag.SEEN, true);
					continue;
				}
				if (enableDeleteUnused)
					allMessages[i].setFlag(javax.mail.Flags.Flag.DELETED, true);
			} 
			return new EmailBatch(messages, folder, store);
		} catch (MessagingException mex) {
			if (folder != null)
				try {
					folder.close(true);
				} catch (MessagingException e) {
					log.debug("Unable to close folder", e);
				}
			if (store != null)
				try {
					store.close();
				} catch (MessagingException e) {
					log.debug("Unable to close store", e);
				}
			throw mex;
		}
	}

	/**
	 * 메일 내용에 따라 원하는 메일인지를 확인하고 그 결과를 리턴함.
	 * @param message
	 * @return
	 * @throws MessagingException
	 * @throws IOException
	 */
	public boolean canProcessMessage(Message message) throws MessagingException, IOException {
		String subject = message.getSubject();
		if (StringUtils.isEmpty(subject)) {
			return false;
		} else {
			return true;
		}
	}
}
