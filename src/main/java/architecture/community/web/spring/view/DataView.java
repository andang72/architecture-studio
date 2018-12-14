package architecture.community.web.spring.view;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.ui.Model;

public interface DataView {

	Object handle(Model model, HttpServletRequest request, HttpServletResponse response) throws Exception;
	
}
