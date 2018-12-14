package architecture.community.board;

import architecture.community.exception.NotFoundException;

public class BoardThreadNotFoundException extends NotFoundException {

	public BoardThreadNotFoundException() {
		super(); 
	}

	public BoardThreadNotFoundException(String message, Throwable cause, boolean enableSuppression,
			boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace); 
	}

	public BoardThreadNotFoundException(String message, Throwable cause) {
		super(message, cause); 
	}

	public BoardThreadNotFoundException(String message) {
		super(message); 
	}

	public BoardThreadNotFoundException(Throwable cause) {
		super(cause); 
	}

}
