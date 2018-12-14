package architecture.community.components.mail;

import java.io.IOException;
import java.util.Date;
import java.util.Enumeration;
import java.util.Iterator;

import javax.mail.Address;
import javax.mail.Message;
import javax.mail.MessagingException;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import architecture.community.model.json.JsonDateSerializer;

public class IMAPMessage implements InboundMessage {

	private final Message original;
	
	public IMAPMessage(Message original) {
		this.original = original;
	}

	public String getBody() throws MessagingException, IOException, EmailMonitorException {
		return MessageUtils.getMessageBodyText(original);
	}

	@JsonIgnore
	public Iterator getAttachments() throws MessagingException, IOException {
		return MessageUtils.getMessageAttachments(original).iterator();
	}

	@JsonIgnore
	public Iterator getHeaders() throws MessagingException {
		final Enumeration enumeration = original.getAllHeaders();
		return new Iterator() {
			public void remove() {
				throw new UnsupportedOperationException();
			}
			public boolean hasNext() {
				return enumeration.hasMoreElements();
			}
			public Object next() {
				return enumeration.nextElement();
			}
		};
	}

	public Address[] getFrom() throws MessagingException {
		return original.getFrom();
	}

	public String getSubject() throws MessagingException {
		return original.getSubject();
	}
	@JsonIgnore
	public String[] getHeader(String name) throws MessagingException {
		return original.getHeader(name);
	}
	
	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getSentDate() {
		try {
			return original.getSentDate();
		} catch (MessagingException e) {
			return null;
		}
	}

}
