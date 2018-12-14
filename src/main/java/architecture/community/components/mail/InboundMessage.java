package architecture.community.components.mail;

import java.io.IOException;
import java.util.Iterator;

import javax.mail.Address;
import javax.mail.MessagingException;

public interface InboundMessage
{

    public abstract String getSubject() throws MessagingException;

    public abstract String getBody() throws MessagingException, IOException, EmailMonitorException;

    public abstract Address[] getFrom()
        throws MessagingException;

    public abstract Iterator getAttachments() throws MessagingException, IOException;

    public abstract Iterator getHeaders() throws MessagingException;

    public abstract String[] getHeader(String s) throws MessagingException;
}
