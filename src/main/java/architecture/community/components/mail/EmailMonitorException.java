package architecture.community.components.mail;

import org.springframework.core.NestedRuntimeException;

public class EmailMonitorException extends NestedRuntimeException {

	private String rejectionMailAddress;
	private String reasonProperty;

	public EmailMonitorException(Throwable cause) {
		super(cause.getMessage(), cause);
	}

	public EmailMonitorException(String msg) {
		super(msg);
	}

	public EmailMonitorException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public String getRejectionMailAddress() {
		return rejectionMailAddress;
	}

	public void setRejectionMailAddress(String rejectionMailAddress) {
		this.rejectionMailAddress = rejectionMailAddress;
	}

	public String getRejectionReasonProperty() {
		return reasonProperty;
	}

	public void setRejectionReasonProperty(String reasonProperty) {
		this.reasonProperty = reasonProperty;
	}
}
