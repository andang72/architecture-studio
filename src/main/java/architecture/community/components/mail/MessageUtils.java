package architecture.community.components.mail;
import java.io.IOException;
import java.util.*;
import javax.activation.MimetypesFileTypeMap;
import javax.mail.*;
import javax.mail.internet.InternetAddress;

public class MessageUtils {


    public static final String END_TOKEN = "--end--";
    public static final String ENABLED_TOKEN = "emailReplyEnabled";
    private static MimetypesFileTypeMap typeMap = new MimetypesFileTypeMap();
    
	   public static String getMessageBodyText(Part message)
		        throws MessagingException, IOException, EmailMonitorException
		    {
		        if(message.isMimeType("text/plain"))
		            return message.getContent().toString();
		        if(message.isMimeType("multipart/alternative"))
		        {
		            Object content = message.getContent();
		            return getTextFromMultipartAlternative(convertToMultipart(content));
		        }
		        if(message.isMimeType("multipart/mixed") || message.isMimeType("multipart/related"))
		        {
		            Object content = message.getContent();
		            return getTextFromMultipartMixed(convertToMultipart(content));
		        } else
		        {
		            EmailMonitorException ex = new EmailMonitorException((new StringBuilder()).append("Unhandled content type '").append(message.getContentType()).append("'").toString());
		            ex.setRejectionReasonProperty("mailmon.read_error.text");
		            throw ex;
		        }
		    }

		    private static Multipart convertToMultipart(Object content)
		        throws IllegalArgumentException
		    {
		        if(content instanceof Multipart)
		            return (Multipart)content;
		        String type = "null";
		        if(content != null)
		            type = content.getClass().getName();
		        throw new IllegalArgumentException((new StringBuilder()).append("Message with content type 'multipart/alternative, but content is an instance of ").append(type).append(", not a Multipart.").toString());
		    }

		    private static String getTextFromMultipartAlternative(Multipart multipart)
		        throws MessagingException, IOException, EmailMonitorException
		    {
		        int count = multipart.getCount();
		        for(int i = 0; i < count; i++)
		        {
		            Part p = multipart.getBodyPart(i);
		            if(p.isMimeType("text/plain"))
		                return p.getContent().toString();
		        }

		        EmailMonitorException ex = new EmailMonitorException("No known content type found in multipart/alternative section");
		        ex.setRejectionReasonProperty("mailmon.read_error.text");
		        throw ex;
		    }

		    private static String getTextFromMultipartMixed(Multipart multipart)
		        throws MessagingException, IOException, EmailMonitorException
		    {
		        for(int i = 0; i < multipart.getCount();)
		            try
		            {
		                return getMessageBodyText(multipart.getBodyPart(i));
		            }
		            catch(EmailMonitorException ignore)
		            {
		                i++;
		            }

		        EmailMonitorException ex = new EmailMonitorException("No known content type found in multipart/alternative section");
		        ex.setRejectionReasonProperty("mailmon.read_error.text");
		        throw ex;
		    }

		    public static List getMessageAttachments(Message message)
		        throws MessagingException, IOException
		    {
		        if(message.isMimeType("multipart/*"))
		        {
		            List attachments = new ArrayList();
		            readAttachments(message, attachments);
		            return attachments;
		        } else
		        {
		            return Collections.EMPTY_LIST;
		        }
		    }

		    private static void readAttachments(Part messagePart, List attachments)
		        throws MessagingException, IOException
		    {
		        if(messagePart.isMimeType("multipart/mixed") || messagePart.isMimeType("multipart/related"))
		        {
		            Object content = messagePart.getContent();
		            if(content instanceof Multipart)
		            {
		                Multipart mp = (Multipart)content;
		                for(int i = 0; i < mp.getCount(); i++)
		                    readAttachments(((Part) (mp.getBodyPart(i))), attachments);

		            } else
		            {
		                String type = "null";
		                if(content != null)
		                    type = content.getClass().getName();
		                throw new IllegalArgumentException((new StringBuilder()).append("Message with content type 'multipart/*, but content is an instance of ").append(type).append(", not a Multipart.").toString());
		            }
		        } else
		        if(!messagePart.isMimeType("multipart/alternative"))
		        {
		            String filename = messagePart.getFileName();
		            if(filename != null)
		            {
		                java.io.InputStream is = messagePart.getInputStream();
		                String contentType = typeMap.getContentType(filename);
		                attachments.add(new AttachmentData(filename, contentType, is));
		            }
		        }
		    }

		    public static String addressToString(Address address)
		    {
		        if(address instanceof InternetAddress)
		            return ((InternetAddress)address).getAddress();
		        else
		            return address.toString();
		    }

		    public static String addressArrayToString(Address addresses[])
		    {
		        if(addresses.length > 0)
		            return addressToString(addresses[0]);
		        else
		            return null;
		    }

		    public static int getIndexAfterEndToken(String messageBody)
		    {
		        int idx = messageBody.lastIndexOf("--end--");
		        if(idx == -1)
		            return idx;
		        idx += "--end--".length();
		        if(idx >= messageBody.trim().length() - 1)
		            return -1;
		        else
		            return idx;
		    }

}
