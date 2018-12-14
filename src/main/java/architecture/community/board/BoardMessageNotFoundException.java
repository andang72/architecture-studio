package architecture.community.board;

import architecture.community.exception.NotFoundException;

public class BoardMessageNotFoundException extends NotFoundException {

	public BoardMessageNotFoundException() { 
	}

	public BoardMessageNotFoundException(String message) {
		super(message); 
	}

	public BoardMessageNotFoundException(Throwable cause) {
		super(cause); 
	}

	public BoardMessageNotFoundException(String message, Throwable cause) {
		super(message, cause); 
	}

	public BoardMessageNotFoundException(String message, Throwable cause, boolean enableSuppression,
			boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace); 
	}

}
