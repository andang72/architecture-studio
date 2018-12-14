/**
 * decorator navigation script.
 *
 * @author
 * @version 1.0
 * @requires Jquery
 *
 */
;
(function($) {
	var Accordion = function (el, multiple) {
		this.el       = el || {};
		// more then one submenu open?
		this.multiple = multiple || false;
		var dropdownlink = this
			.el
			.find('.dropdownlink');
		dropdownlink.on('click', {
			el      : this.el,
			multiple: this.multiple
		}, this.dropdown);
	};
	Accordion.prototype.dropdown = function (e) {
		var $el   = e.data.el,
			$this = $(this),
			//this is the ul.submenuItems
			$next = $this.next();
		$next.slideToggle();
		$this
			.parent()
			.toggleClass('open');
		if (!e.data.multiple) {
			//show only one menu at the same time
			$el
				.find('.submenuItems')
				.not($next)
				.slideUp()
				.parent()
				.removeClass('open');
		}
	}
	var accordion = new Accordion($('.accordion-menu'), false);
	
	var item = "";
	var url = window.location.href;
	var page = url.substring(url.lastIndexOf("/")+1);
	page = "/display/pages/"+page;
	console.log('Current Page - ' + page);
	
	var itemParent = $("a[data-page='"+ page +"']").closest('ul.submenuItems').closest('li');
	itemParent.addClass('open');
	
	var itemChildren = $('li.open > ul.submenuItems');
	itemChildren.css('display', 'block');
	
	var text = $("a[data-page='"+ page +"']");
	text.css('color', '#C9DCFF');
	
})(jQuery);
