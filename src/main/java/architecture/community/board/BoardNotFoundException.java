package architecture.community.board;

public class BoardNotFoundException extends Exception {

	public BoardNotFoundException() {
		super();
	}

	public BoardNotFoundException(String message, Throwable cause, boolean enableSuppression,
			boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public BoardNotFoundException(String message, Throwable cause) {
		super(message, cause);
	}

	public BoardNotFoundException(String message) {
		super(message);
	}

	public BoardNotFoundException(Throwable cause) {
		super(cause);
	}

}
