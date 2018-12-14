package architecture.community.components.mail;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.mail.Flags;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Provider;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.search.FlagTerm;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import architecture.community.services.CommunitySpringEventPublisher;
import architecture.community.util.SecurityHelper;
import architecture.ee.service.ConfigService;
import architecture.ee.util.StringUtils;

public class EmailMonitor {
 
	
	private Logger log = LoggerFactory.getLogger(EmailMonitor.class);


	@Autowired(required = false)
	@Qualifier("communitySpringEventPublisher")
	private CommunitySpringEventPublisher eventPublisher;
	
	@Autowired
	@Qualifier("configService")
	private ConfigService configService;
	
	public EmailMonitor() {
		
	}
	
	public void initialize() {
 
	}	
    
	public boolean isEnabled()
    {
        return configService.getApplicationBooleanProperty("services.checkmail.enabled", false);
    }
         
	public void processMessages() {
		
		log.debug("email monitoring service is {}", isEnabled() );
	 
		if(isEnabled()){ 
			Map senders = new HashMap();
			EmailBatch newMessages = null;
			try
	        {
	            newMessages = checkMailAccount();
	            if(newMessages == null)
	                return;
	            
	            Iterator<InboundMessage> iter = newMessages.getMessages();
	            while(iter.hasNext()) {
	            	InboundMessage message = iter.next();
	            	// don action ... for inbound message.
	            	log.debug(" message {}", message.getSubject() );
	            	if( eventPublisher != null)
	        			eventPublisher.fireEvent(new MailEvent( message, SecurityHelper.getUser(), MailEvent.State.INBOUND ));
	            }
	            
	        }
	        catch(MessagingException mex)
	        {
	            log.warn("Error reading configured email account - no messages read.", mex);
	        }
	        catch(IOException ioe)
	        {
	            log.warn("Error reading configured email account - no messages read.", ioe);
	        }catch(Throwable e) {
	        	log.warn("Error reading configured email account - no messages read.", e);
	        }
	        finally
	        {
	            senders.clear();
	            if(newMessages != null)
	                newMessages.close();
	        }			
		}else {
			
		}
	}
	
	private EmailBatch checkMailAccount() throws MessagingException, IOException {   
		
		String host = configService.getApplicationProperty("services.checkmail.host", null);
		int port = configService.getApplicationIntProperty("services.checkmail.port", 993);
		boolean ssl = configService.getApplicationBooleanProperty("services.checkmail.ssl", false);
		String username = configService.getApplicationProperty("services.checkmail.username", "");
		String password = configService.getApplicationProperty("services.checkmail.password", "");
		String accountType = configService.getApplicationProperty("services.checkmail.protocol", "imap");
		
		log.debug("email monitoring service with {}, {}, {}, {}", host, port, accountType, username );  
		log.debug("email monitoring service : {}", !StringUtils.isNullOrEmpty(host) );
		if( !StringUtils.isNullOrEmpty(host)) {
			CheckMailStrategy strategy ;
			if( accountType.equals("imap")) {
				strategy = new IMAPMailStrategy(configService);
			}else {
				throw new IllegalArgumentException("Only IMAP type supported.");
			}
			
			log.debug("email monitoring service checkForMessages : {}", strategy.getClass().getName());
			
			return strategy.checkForMessages(host, port, username, password, ssl);
		}else {
			log.info("No host configured for incoming email - skipping email processing.");
	        return null;
		}
		
	}
	

	public boolean testConnection() {
		
		boolean success = false;
		String host = ""; // JiveGlobals.getJiveProperty("checkmail.host");
		int port = 993; // JiveGlobals.getJiveIntProperty("checkmail.port", 110);
		boolean ssl = false; // JiveGlobals.getJiveBooleanProperty("checkmail.useSSL", false);
		String username = ""; // JiveGlobals.getJiveProperty("checkmail.v", "");
		String password = ""; // JiveGlobals.getJiveProperty("checkmail.password", "");
		String accountType = "imap"; // JiveGlobals.getJiveProperty("checkmail.protocol", "POP3");
		Store store = null;
		Folder folder = null;
		try {
			Properties props = new Properties();
			// props.setProperty("mail.imap.host", "imap.worksmobile.com");
			// props.put("mail.imap.port", "993");
			props.put("mail.imap.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
			props.put("mail.imap.socketFactory.fallback", "false");
			// props.put("mail.imap.socketFactory.port", "993");

			Session session = Session.getDefaultInstance(props, null);
			session.setDebug(true);

			for (Provider p : session.getProviders()) {
				log.debug("provider {}", p.getClassName());
			}

			if (ssl)
				store = session.getStore((new StringBuilder()).append(accountType).append("s").toString());
			else
				store = session.getStore(accountType);
			store.connect(host, port, username, password);
			String folderName = "INBOX"; // JiveGlobals.getJiveProperty("checkmail.folderName", "INBOX");
			folder = store.getFolder(folderName);
			folder.open(Folder.READ_ONLY);

			// Message[] messages = folder.getMessages(1, 30); //folder.getMessages(30);

			Message[] messages = folder.search(new FlagTerm(new Flags(Flags.Flag.SEEN), false));
			for (int i = 0, n = messages.length; i < n; i++) {
				Message message = messages[i];

				int count = 0;
				if (message.getHeader("To") != null) {
					for (String s : message.getHeader("To")) {
						count = count + StringUtils.countOccurrencesOf(s, "helpdesk@podosw.com");
					}
				}
				if (count == 0)
					continue;

				java.util.Enumeration e = message.getAllHeaders();

				while (e.hasMoreElements()) {
					javax.mail.Header h = ((javax.mail.Header) e.nextElement());

					log.debug("header : {} = {}", h.getName(), h.getValue());
				}

				System.out.println("---------------------------------");
				System.out.println("Email Number " + (i + 1));
				System.out.println("Subject: " + message.getSubject());
				System.out.println("From: " + message.getFrom()[0]);
				System.out.println("Date: " + message.getSentDate());

				// System.out.println("Text: " + message.getContent().toString());

			}

			success = true;
		} catch (Exception ex) {
			success = false;
			log.info("Email connection test failed.", ex);
		} finally {
			if (folder != null)
				try {
					folder.close(false);
				} catch (Exception ex) {
				}
			if (store != null)
				try {
					store.close();
				} catch (Exception ex) {
				}
		}
		return success;
	}
}
