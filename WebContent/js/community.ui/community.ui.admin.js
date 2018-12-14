var isSideMenuMini = $.cookie('isSideMenuMini') ? true : '';
;
(function($) {
	'use strict';
	var community = window.community = window.community || { ui : { components: {}, helpers : {} }, model : {} , data : {}};
	console.log("SideNav - features on");
	if( community.data.storageAvailable ('localStorage') ){							
		var page = localStorage.getItem('selected_current_page');	
		console.log("SideNav - selected page : " + page );
		
		var item = $("a[data-page='"+ page +"']");							
		if( item.hasClass('u-side-nav--second-level-menu-link') ){
			console.log("SideNav - this is second level");
			
			var itemParent = item.closest('ul.u-side-nav--second-level-menu');
			itemParent.css('display', 'block');
			
			//itemParent.parent().addClass('u-side-nav-opened');
		}
		if (!item.hasClass('active')) {
			item.addClass('active');
		}
	}
	
	console.log("community.ui.admin components initialized.");
	
	/**
	 * Side Nav wrapper.
	 */	
	community.ui.components.HSSideNav = {
		/**
		 *
		 *
		 * @var Object _baseConfig
		 */
		_baseConfig: {},

		/**
		 *
		 *
		 * @var jQuery pageCollection
		 */
		pageCollection: $(),

		/**
		 * Initialization of Side Nav wrapper.
		 *
		 * @param String selector (optional)
		 * @param Object config (optional)
		 *
		 * @return jQuery pageCollection - collection of initialized items.
		 */
		init: function(selector, config) {
			this.collection = selector && $(selector).length ? $(selector) : $();
			if (!$(selector).length) return;

			this.config = config && $.isPlainObject(config) ?
				$.extend({}, this._baseConfig, config) : this._baseConfig;

			this.config.itemSelector = selector;

			this.initSideNav();

			return this.pageCollection;
		},

		initSideNav: function() {
			//Variables
			var $self = this,
				collection = $self.pageCollection;

			//Actions
			this.collection.each(function(i, el) {
				//Variables
				var $this = $(el),
					target = $this.data('hssm-target'),
					targetClass = $this.data('hssm-class'),
					bodyClass = $this.data('hssm-body-class'),
					isUnifyEffect = Boolean($this.data('hssm-fade-effect')),
					isShowAllExceptThis = Boolean($this.data('hssm-is-close-all-except-this')),
					$closedItems = [],
					windW = $(window).width();

				$(target).find('[data-hssm-target]').each(function(i) {
					if ($(this).parent().hasClass('u-side-nav--top-level-menu-item u-side-nav-opened')) {
						$closedItems.push($(this).data('hssm-target'));
					}
				});

				// if (isUnifyEffect) {
				// 	$this.on('click', function(e) {
				// 		e.preventDefault();
        //
				// 		if (!$(target).hasClass('toggled')) {
				// 			$self.unifyOpenEffect(target, targetClass, bodyClass);
				// 			$.cookie('isSideMenuMini', true);
				// 		} else {
				// 			$self.unifyCloseEffect(target, targetClass, bodyClass);
				// 			$.cookie('isSideMenuMini', '');
				// 		}
				// 	});
				// } else {
					$this.on('click', function(e) {
						e.preventDefault();

						if (!$(target).hasClass('toggled')) {
							$self.defaultOpenEffect(target, $closedItems, targetClass, bodyClass);
							$.cookie('isSideMenuMini', true);
						} else {
							$self.defaultCloseEffect(target, $closedItems, targetClass, bodyClass);
							$.cookie('isSideMenuMini', '');
						}
					});
				// }

				$(target).find('[data-hssm-target]').on('click', function(e) {
					e.preventDefault();

					var itemTarget = $(this).data('hssm-target'),
						$itemParent = $(this).parent();

					if (isShowAllExceptThis) {
						if (!$('body').hasClass('u-side-nav-mini')) {
							$itemParent.parent().find('> li:not(".has-active") > ul:not("' + itemTarget + '")').slideUp(400, function() {
								$(this).parent().removeClass('u-side-nav-opened');
								$closedItems.push(itemTarget);
							});
						} else {
							$itemParent.parent().find('> li > ul:not("' + itemTarget + '")').slideUp(400, function() {
								$(this).parent().removeClass('u-side-nav-opened');
								$closedItems.push(itemTarget);
							});
						}
					} else {
						if (!$(this).parent().hasClass('u-side-nav-opened')) {
							$closedItems.push(itemTarget);
						} else {
							$closedItems = $.grep($closedItems, function(value) {
								return value != itemTarget;
							});
						}
					}

					// $(itemTarget).slideToggle(400, function() {
					// 	$(this).parent().toggleClass('u-side-nav-opened');
					// });
					$(itemTarget).slideToggle(400)
					.parent().toggleClass('u-side-nav-opened');
				});

				if (windW <= 992 || isSideMenuMini == true) {
					$(this).trigger('click');
				}

				$(window).on('resize', function() {
					var windW = $(window).width();

					if (windW <= 992) {
						$this.removeClass('once-opened');

						if (!$this.hasClass('is-active')) {
							if (!$this.hasClass('once-closed')) {
								$this.addClass('is-active was-opened once-closed');

								if (isUnifyEffect) {
									$self.unifyOpenEffect(target, targetClass, bodyClass);
								} else {
									$self.defaultOpenEffect(target, $closedItems, targetClass, bodyClass);
								}
							}
						}
					} else {
						$this.removeClass('once-closed');

						if ($this.hasClass('was-opened')) {
							$this.removeClass('is-active was-opened');

							if (!$this.hasClass('once-opened')) {
								$this.addClass('once-opened');

								if (isUnifyEffect) {
									$self.unifyCloseEffect(target, targetClass, bodyClass);
								} else {
									$self.defaultCloseEffect(target, $closedItems, targetClass, bodyClass);
								}
							}
						}
					}
				});

				//Actions
				collection = collection.add($this);
			});
		},

		// unifyOpenEffect: function(target, targetclass, bodyclass) {
		// 	$(target).addClass('toggled u-side-nav--mini-hover-on');
		// 	$(target + '.toggled').addClass(targetclass);
		// 	$('body').addClass(bodyclass);
		// },
    //
		// unifyCloseEffect: function(target, targetclass, bodyclass) {
		// 	$(target).children().hide();
		// 	$(target).removeClass(targetclass + ' toggled');
		// 	$('body').removeClass(bodyclass);
    //
		// 	setTimeout(function() {
		// 		$(target).children().fadeIn(100);
		// 		$(target).removeClass('u-side-nav--mini-hover-on');
		// 	}, 300);
		// },

		defaultOpenEffect: function(target, closeditems, targetclass, bodyclass) {
			$(target).addClass('toggled u-side-nav--mini-hover-on');

			if (closeditems.length > 0) {
				var items = closeditems.toString();

				$(items).slideUp(400, function() {
					$(target + '.toggled').addClass(targetclass);
					$('body').addClass(bodyclass);
					$(items).parent().removeClass('u-side-nav-opened');
				});
			} else {
				$(target + '.toggled').addClass(targetclass);
				$('body').addClass(bodyclass);
			}
		},

		defaultCloseEffect: function(target, closeditems, targetclass, bodyclass) {
			$(target).removeClass('toggled u-side-nav--mini-hover-on');
			$(target).removeClass(targetclass + ' toggled');
			$('body').removeClass(bodyclass);

			if (closeditems.length > 0) {
				setTimeout(function() {
					$(closeditems.toString()).parent().addClass('u-side-nav-opened');
					$(closeditems.toString()).slideDown(400);
				}, 300);
			}
		}
	}
	
	  community.ui.components.HSDropdown = {

		    /**
		     * Base configuration of the component.
		     *
		     * @private
		     */
		    _baseConfig: {
		      dropdownEvent: 'click',
		      dropdownType: 'simple',
		      dropdownDuration: 300,
		      dropdownEasing: 'linear',
		      dropdownAnimationIn: 'fadeIn',
		      dropdownAnimationOut: 'fadeOut',
		      dropdownHideOnScroll: true,
		      dropdownHideOnBlur: false,
		      dropdownDelay: 350,
		      afterOpen: function (invoker) {
		      },
		      afterClose: function (invoker) {
		      }
		    },

		    /**
		     * Collection of all initialized items on the page.
		     *
		     * @private
		     */
		    _pageCollection: $(),

		    /**
		     * Initialization.
		     *
		     * @param {jQuery} collection
		     * @param {Object} config
		     *
		     * @public
		     * @return {jQuery}
		     */
		    init: function (collection, config) {

		      var self;

		      if (!collection || !collection.length) return;

		      self = this;

		      var fieldsQty;

		      collection.each(function (i, el) {

		        var $this = $(el), itemConfig;

		        if ($this.data('HSDropDown')) return;

		        itemConfig = config && $.isPlainObject(config) ?
		          $.extend(true, {}, self._baseConfig, config, $this.data()) :
		          $.extend(true, {}, self._baseConfig, $this.data());

		        switch (itemConfig.dropdownType) {

		          case 'css-animation' :

		            $this.data('HSDropDown', new DropdownCSSAnimation($this, itemConfig));

		            break;

		          case 'jquery-slide' :

		            $this.data('HSDropDown', new DropdownJSlide($this, itemConfig));

		            break;

		          default :

		            $this.data('HSDropDown', new DropdownSimple($this, itemConfig));

		        }

		        self._pageCollection = self._pageCollection.add($this);
		        self._bindEvents($this, itemConfig.dropdownEvent, itemConfig.dropdownDelay);
		        var DropDown = $(el).data('HSDropDown');

		        fieldsQty = $(DropDown.target).find('input, textarea').length;

		      });

		      $(document).on('keyup.HSDropDown', function (e) {

		        if (e.keyCode && e.keyCode == 27) {

		          self._pageCollection.each(function (i, el) {

		            var windW = $(window).width(),
		              optIsMobileOnly = Boolean($(el).data('is-mobile-only'));

		            if (!optIsMobileOnly) {
		              $(el).data('HSDropDown').hide();
		            } else if (optIsMobileOnly && windW < 769) {
		              $(el).data('HSDropDown').hide();
		            }

		          });

		        }

		      });

		      $(window).on('click', function (e) {

		        self._pageCollection.each(function (i, el) {

		          var windW = $(window).width(),
		            optIsMobileOnly = Boolean($(el).data('is-mobile-only'));

		          if (!optIsMobileOnly) {
		            $(el).data('HSDropDown').hide();
		          } else if (optIsMobileOnly && windW < 769) {
		            $(el).data('HSDropDown').hide();
		          }

		        });

		      });

		      self._pageCollection.each(function (i, el) {

		        var target = $(el).data('HSDropDown').config.dropdownTarget;

		        $(target).on('click', function(e) {

		          e.stopPropagation();

		        });

		      });

		      $(window).on('scroll.HSDropDown', function (e) {

		        self._pageCollection.each(function (i, el) {

		          var DropDown = $(el).data('HSDropDown');

		          if (DropDown.getOption('dropdownHideOnScroll') && fieldsQty === 0) {

		            DropDown.hide();

		          } else if (DropDown.getOption('dropdownHideOnScroll') && !(/iPhone|iPad|iPod/i.test(navigator.userAgent))) {

		            DropDown.hide();

		          }

		        });

		      });

		      $(window).on('resize.HSDropDown', function (e) {

		        if (self._resizeTimeOutId) clearTimeout(self._resizeTimeOutId);

		        self._resizeTimeOutId = setTimeout(function () {

		          self._pageCollection.each(function (i, el) {

		            var DropDown = $(el).data('HSDropDown');

		            DropDown.smartPosition(DropDown.target);

		          });

		        }, 50);

		      });

		      return collection;

		    },

		    /**
		     * Binds necessary events.
		     *
		     * @param {jQuery} $invoker
		     * @param {String} eventType
		     * @param {Number} delay
		     * @private
		     */
		    _bindEvents: function ($invoker, eventType, delay) {

		      var $dropdown = $($invoker.data('dropdown-target'));

		      if (eventType == 'hover' && !_isTouch()) {

		        $invoker.on('mouseenter.HSDropDown', function (e) {

		          var $invoker = $(this),
		            HSDropDown = $invoker.data('HSDropDown');

		          if (!HSDropDown) return;

		          if (HSDropDown.dropdownTimeOut) clearTimeout(HSDropDown.dropdownTimeOut);
		          HSDropDown.show();

		        })
		          .on('mouseleave.HSDropDown', function (e) {

		            var $invoker = $(this),
		              HSDropDown = $invoker.data('HSDropDown');

		            if (!HSDropDown) return;

		            HSDropDown.dropdownTimeOut = setTimeout(function () {

		              HSDropDown.hide();

		            }, delay);

		          });

		        if ($dropdown.length) {

		          $dropdown.on('mouseenter.HSDropDown', function (e) {

		            var HSDropDown = $invoker.data('HSDropDown');

		            if (HSDropDown.dropdownTimeOut) clearTimeout(HSDropDown.dropdownTimeOut);
		            HSDropDown.show();

		          })
		            .on('mouseleave.HSDropDown', function (e) {

		              var HSDropDown = $invoker.data('HSDropDown');

		              HSDropDown.dropdownTimeOut = setTimeout(function () {
		                HSDropDown.hide();
		              }, delay);

		            });
		        }

		      }
		      else {

		        $invoker.on('click.HSDropDown', function (e) {

		          var $curInvoker = $(this);

		          if (!$curInvoker.data('HSDropDown')) return;

		          if ($('[data-dropdown-target].active').length) {
		            $('[data-dropdown-target].active').data('HSDropDown').toggle();
		          }

		          $curInvoker.data('HSDropDown').toggle();

		          e.stopPropagation();
		          e.preventDefault();

		        });

		      }

		    }
		  };

		  function _isTouch() {
		    return 'ontouchstart' in window;
		  }

		  /**
		   * Abstract Dropdown class.
		   *
		   * @param {jQuery} element
		   * @param {Object} config
		   * @abstract
		   */
		  function AbstractDropdown(element, config) {

		    if (!element.length) return false;

		    this.element = element;
		    this.config = config;

		    this.target = $(this.element.data('dropdown-target'));

		    this.allInvokers = $('[data-dropdown-target="' + this.element.data('dropdown-target') + '"]');

		    this.toggle = function () {
		      if (!this.target.length) return this;

		      if (this.defaultState) {
		        this.show();
		      }
		      else {
		        this.hide();
		      }

		      return this;
		    };

		    this.smartPosition = function (target) {

		      if (target.data('baseDirection')) {
		        target.css(
		          target.data('baseDirection').direction,
		          target.data('baseDirection').value
		        );
		      }

		      target.removeClass('u-dropdown--reverse-y');

		      var $w = $(window),
		        styles = getComputedStyle(target.get(0)),
		        direction = Math.abs(parseInt(styles.left, 10)) < 40 ? 'left' : 'right',
		        targetOuterGeometry = target.offset();

		      // horizontal axis
		      if (direction == 'right') {

		        if (!target.data('baseDirection')) target.data('baseDirection', {
		          direction: 'right',
		          value: parseInt(styles.right, 10)
		        });

		        if (targetOuterGeometry.left < 0) {

		          target.css(
		            'right',
		            (parseInt(target.css('right'), 10) - (targetOuterGeometry.left - 10 )) * -1
		          );

		        }

		      }
		      else {

		        if (!target.data('baseDirection')) target.data('baseDirection', {
		          direction: 'left',
		          value: parseInt(styles.left, 10)
		        });

		        if (targetOuterGeometry.left + target.outerWidth() > $w.width()) {

		          target.css(
		            'left',
		            (parseInt(target.css('left'), 10) - (targetOuterGeometry.left + target.outerWidth() + 10 - $w.width()))
		          );

		        }

		      }

		      // vertical axis
		      if (targetOuterGeometry.top + target.outerHeight() - $w.scrollTop() > $w.height()) {
		        target.addClass('u-dropdown--reverse-y');
		      }

		    };

		    this.getOption = function (option) {
		      return this.config[option] ? this.config[option] : null;
		    };

		    return true;
		  }


		  /**
		   * DropdownSimple constructor.
		   *
		   * @param {jQuery} element
		   * @param {Object} config
		   * @constructor
		   */
		  function DropdownSimple(element, config) {
		    if (!AbstractDropdown.call(this, element, config)) return;

		    Object.defineProperty(this, 'defaultState', {
		      get: function () {
		        return this.target.hasClass('u-dropdown--hidden');
		      }
		    });

		    this.target.addClass('u-dropdown--simple');

		    this.hide();
		  }

		  /**
		   * Shows dropdown.
		   *
		   * @public
		   * @return {DropdownSimple}
		   */
		  DropdownSimple.prototype.show = function () {

		    var activeEls = $(this)[0].config.dropdownTarget;

		    $('[data-dropdown-target="' + activeEls + '"]').addClass('active');

		    this.smartPosition(this.target);

		    this.target.removeClass('u-dropdown--hidden');
		    if (this.allInvokers.length) this.allInvokers.attr('aria-expanded', 'true');
		    this.config.afterOpen.call(this.target, this.element);

		    return this;
		  }

		  /**
		   * Hides dropdown.
		   *
		   * @public
		   * @return {DropdownSimple}
		   */
		  DropdownSimple.prototype.hide = function () {

		    var activeEls = $(this)[0].config.dropdownTarget;

		    $('[data-dropdown-target="' + activeEls + '"]').removeClass('active');

		    this.target.addClass('u-dropdown--hidden');
		    if (this.allInvokers.length) this.allInvokers.attr('aria-expanded', 'false');
		    this.config.afterClose.call(this.target, this.element);

		    return this;
		  }

		  /**
		   * DropdownCSSAnimation constructor.
		   *
		   * @param {jQuery} element
		   * @param {Object} config
		   * @constructor
		   */
		  function DropdownCSSAnimation(element, config) {
		    if (!AbstractDropdown.call(this, element, config)) return;

		    var self = this;

		    this.target
		      .addClass('u-dropdown--css-animation u-dropdown--hidden')
		      .css('animation-duration', self.config.dropdownDuration + 'ms');

		    Object.defineProperty(this, 'defaultState', {
		      get: function () {
		        return this.target.hasClass('u-dropdown--hidden');
		      }
		    });

		    if (this.target.length) {

		      this.target.on('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function (e) {

		        if (self.target.hasClass(self.config.dropdownAnimationOut)) {
		          self.target.removeClass(self.config.dropdownAnimationOut)
		            .addClass('u-dropdown--hidden');


		          if (self.allInvokers.length) self.allInvokers.attr('aria-expanded', 'false');

		          self.config.afterClose.call(self.target, self.element);
		        }

		        if (self.target.hasClass(self.config.dropdownAnimationIn)) {

		          if (self.allInvokers.length) self.allInvokers.attr('aria-expanded', 'true');

		          self.config.afterOpen.call(self.target, self.element);
		        }

		        e.preventDefault();
		        e.stopPropagation();
		      });

		    }
		  }

		  /**
		   * Shows dropdown.
		   *
		   * @public
		   * @return {DropdownCSSAnimation}
		   */
		  DropdownCSSAnimation.prototype.show = function () {

		    var activeEls = $(this)[0].config.dropdownTarget;

		    $('[data-dropdown-target="' + activeEls + '"]').addClass('active');

		    this.smartPosition(this.target);

		    this.target.removeClass('u-dropdown--hidden')
		      .removeClass(this.config.dropdownAnimationOut)
		      .addClass(this.config.dropdownAnimationIn);

		  }

		  /**
		   * Hides dropdown.
		   *
		   * @public
		   * @return {DropdownCSSAnimation}
		   */
		  DropdownCSSAnimation.prototype.hide = function () {

		    var activeEls = $(this)[0].config.dropdownTarget;

		    $('[data-dropdown-target="' + activeEls + '"]').removeClass('active');

		    this.target.removeClass(this.config.dropdownAnimationIn)
		      .addClass(this.config.dropdownAnimationOut);

		  }

		  /**
		   * DropdownSlide constructor.
		   *
		   * @param {jQuery} element
		   * @param {Object} config
		   * @constructor
		   */
		  function DropdownJSlide(element, config) {
		    if (!AbstractDropdown.call(this, element, config)) return;

		    this.target.addClass('u-dropdown--jquery-slide u-dropdown--hidden').hide();

		    Object.defineProperty(this, 'defaultState', {
		      get: function () {
		        return this.target.hasClass('u-dropdown--hidden');
		      }
		    });
		  }

		  /**
		   * Shows dropdown.
		   *
		   * @public
		   * @return {DropdownJSlide}
		   */
		  DropdownJSlide.prototype.show = function () {

		    var self = this;

		    var activeEls = $(this)[0].config.dropdownTarget;

		    $('[data-dropdown-target="' + activeEls + '"]').addClass('active');

		    this.smartPosition(this.target);

		    this.target.removeClass('u-dropdown--hidden').stop().slideDown({
		      duration: self.config.dropdownDuration,
		      easing: self.config.dropdownEasing,
		      complete: function () {
		        self.config.afterOpen.call(self.target, self.element);
		      }
		    });

		  }

		  /**
		   * Hides dropdown.
		   *
		   * @public
		   * @return {DropdownJSlide}
		   */
		  DropdownJSlide.prototype.hide = function () {

		    var self = this;

		    var activeEls = $(this)[0].config.dropdownTarget;

		    $('[data-dropdown-target="' + activeEls + '"]').removeClass('active');

		    this.target.stop().slideUp({
		      duration: self.config.dropdownDuration,
		      easing: self.config.dropdownEasing,
		      complete: function () {
		        self.config.afterClose.call(self.target, self.element);
		        self.target.addClass('u-dropdown--hidden');
		      }
		    });

		  }	



	
	/**
	* HSScrollBar component.
	* 
	* @requires malihu jquery custom scrollbar plugin (v3.1.5.)
	*/
	community.ui.components.HSScrollBar = {

		/**
		 * Base configuration.
		 * 
		 * @private
		 */
		_baseConfig : {
			scrollInertia : 150,
			theme : 'minimal-dark'
		},

		/**
		 * Collection of all initalized items on the page.
		 * 
		 * @private
		 */
		_pageCollection : $(),

		/**
		 * Initialization of HSScrollBar component.
		 * 
		 * @param {jQuery}
		 *            collection
		 * @param {Object}
		 *            config
		 * 
		 * @return {jQuery}
		 */
		init : function(collection, config) {

			if (!collection || !collection.length)
				return;

			var self = this;

			config = config && $.isPlainObject(config) ? $.extend(true, {}, config, this._baseConfig) : this._baseConfig;

			return collection.each(function(i, el) {
						var $this = $(el), scrollBar, scrollBarThumb, itemConfig = $.extend(true, {}, config, $this.data());
						$this.mCustomScrollbar(itemConfig);

						scrollBar = $this.find('.mCSB_scrollTools');
						scrollBarThumb = $this.find('.mCSB_dragger_bar');

						if (scrollBar.length && $this.data('scroll-classes')) {
							scrollBar.addClass($this.data('scroll-classes'));
						}

						if (scrollBarThumb.length && $this.data('scroll-thumb-classes')) {
							scrollBarThumb.addClass($this.data('scroll-thumb-classes'));
						}
						self._pageCollection = self._pageCollection.add($this);
					});
		},

		/**
		 * Destroys the component.
		 * 
		 * @param {jQuery}
		 *            collection
		 * 
		 * @return {jQuery}
		 */
		destroy : function(collection) {
			if (!collection && !collection.length)
				return $();

			var _self = this;
			return collection.each(function(i, el) {
				var $this = $(el);
				$this.mCustomScrollbar('destroy');
				_self._pageCollection = _self._pageCollection.not($this);

			});
		}
	}
	  
})(jQuery);

/**
 * Hamburgers plugin helper.
 * 
 * @author Htmlstream
 * @version 1.0
 * @requires hamburgers.min.css
 * 
 */
;(function($){
	'use strict';

	
	$.HSCore = {			
		components: {},
		helpers : {}
	};
	
	
	$.HSCore.helpers.HSHamburgers = {
		/**
		 * Initialize 'hamburgers' plugin.
		 * 
		 * @param String selector
		 *
		 * @return undefined;
		 */
		init: function(selector) {

			if( !selector || !$(selector).length ) return;

		  var hamburgers = $(selector),
		  		timeoutid;

		  hamburgers.each(function(i, el){

		  	var $this = $(this);

		  	if($this.closest('button').length) {
		  		$this.closest('button').get(0).addEventListener('click', function(e){

		  			var $self = $(this),
		  					$hamburger = $self.find(selector);

		  			if(timeoutid) clearTimeout(timeoutid);
		  			timeoutid = setTimeout(function(){

		  				$hamburger.toggleClass('is-active');

		  			}, 10);
		  			e.preventDefault();
		  		}, false);
		  	}
		  	else {
		  		$this.get(0).addEventListener('click', function(e){
		  			var $self = $(this);
		  			if(timeoutid) clearTimeout(timeoutid);
		  			timeoutid = setTimeout(function(){
		  				$self.toggleClass('is-active');
		  			}, 10);
		  			e.preventDefault();
		  		}, false);
		  	}
		  });
		}
	};

})(jQuery);
