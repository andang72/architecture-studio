<header id="js-header" class="u-header u-header--sticky-top">
	<div class="u-header__section u-header__section--admin-dark g-min-height-65">
		<nav class="navbar no-gutters g-pa-0">
			<div class="col-auto d-flex flex-nowrap u-header-logo-toggler g-py-12">
				<!-- Logo -->
				<a href="<@spring.url "/secure/display/ftl/admin_v2.0/main"/>" class="navbar-brand d-flex align-self-center g-hidden-xs-down g-line-height-1 py-0 g-mt-5">
					<img style="height: 34px" src="data:image/png;base64,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" />
				</a>
				<!-- End Logo -->
				<!-- Sidebar Toggler -->
				<a class="js-side-nav u-header__nav-toggler d-flex align-self-center ml-auto" href="#!" 
					data-hssm-class="u-side-nav--mini u-sidebar-navigation-v1--mini"
					data-hssm-body-class="u-side-nav-mini"
					data-hssm-is-close-all-except-this="true"
					data-hssm-target="#sideNav"> <i class="community-admin-align-left"></i>
				</a>
				<!-- End Sidebar Toggler -->
			</div>
			<!-- Top Search Bar -->
			<!-- End Top Search Bar -->

			<!-- Messages/Notifications/Top Search Bar/Top User -->
			<div class="col-auto d-flex g-py-12 g-pl-40--lg ml-auto">
				<!-- Top Messages -->
				<!-- End Top Messages -->

				<!-- Top Notifications -->
				<!-- End Top Notifications -->

				<!-- Top Search Bar (Mobi) -->
				
				<!-- End Top Search Bar (Mobi) -->

				<!-- Top User -->
				<div class="col-auto d-flex g-pt-5 g-pt-0--sm g-pl-10 g-pl-20--sm">
					<div class="g-pos-rel g-px-10--lg">
						<a id="profileMenuInvoker" class="d-block" href="#!"
							aria-controls="profileMenu" aria-haspopup="true"
							aria-expanded="false" data-dropdown-event="click"
							data-dropdown-target="#profileMenu"
							data-dropdown-type="css-animation" data-dropdown-duration="300"
							data-dropdown-animation-in="fadeIn"
							data-dropdown-animation-out="fadeOut"> 
							<span class="g-pos-rel"> 
								<span class="u-badge-v2--xs u-badge--top-right g-hidden-sm-up g-bg-lightblue-v5 g-mr-5"></span>
								<img class="g-width-30 g-width-40--md g-height-30 g-height-40--md rounded-circle g-mr-10--sm" data-bind="attr:{ src: userAvatarSrc  }" src="/images/no-avatar.png" alt="Image description">
							</span> 
							<span class="g-pos-rel g-top-2"> 
								<span class="g-hidden-sm-down" data-bind="text:userDisplayName"></span> <i class="community-admin-angle-down g-pos-rel g-top-2 g-ml-10"></i>
							</span>
						</a>

						<!-- Top User Menu -->
						<ul id="profileMenu" class="g-pos-abs g-left-0 g-width-150x--lg g-nowrap g-font-size-14 g-py-20 g-mt-17 rounded u-dropdown--css-animation u-dropdown--hidden" aria-labelledby="profileMenuInvoker" style="animation-duration: 300ms;">
							<li class="g-hidden-sm-up g-mb-10">
								<a class="media g-py-5 g-px-20" href="#!"> 
									<span class="d-flex align-self-center g-pos-rel g-mr-12"> 
										<span class="u-badge-v1 g-top-minus-3 g-right-minus-3 g-width-18 g-height-18 g-bg-lightblue-v5 g-font-size-10 g-color-white rounded-circle p-0">10</span>
											<i class="community-admin-comment-alt"></i>
										</span> 
										<span class="media-body align-self-center">Unread Messages</span>
								</a>
							</li>
							<li class="g-hidden-sm-up g-mb-10">
								<a class="media g-py-5 g-px-20" href="#!"> 
									<span class="d-flex align-self-center g-mr-12">
										<i class="community-admin-bell"></i>
									</span> 
									<span class="media-body align-self-center">Notifications</span>
							</a></li>
							<li class="g-mb-10">
								<a class="media g-color-lightred-v2--hover g-py-5 g-px-20" data-page="none" href="<@spring.url "profile"/>" > 
									<span class="d-flex align-self-center g-mr-12">
										<i class="community-admin-user"></i>
									</span> 
									<span class="media-body align-self-center">My Profile</span>
								</a>
							</li>
							<!--
							<li class="g-mb-10">
								<a class="media g-color-lightred-v2--hover g-py-5 g-px-20" href="#!"> 
									<span class="d-flex align-self-center g-mr-12">
										<i class="community-admin-rocket"></i>
									</span> 
									<span class="media-body align-self-center">Upgrade Plan</span>
								</a>
							</li>
							<li class="g-mb-10">
								<a class="media g-color-lightred-v2--hover g-py-5 g-px-20" href="#!"> 
									<span class="d-flex align-self-center g-mr-12">
										<i class="community-admin-layout-grid-2"></i>
									</span> 
									<span class="media-body align-self-center">Latest Projects</span>
								</a>
							</li>
							<li class="g-mb-10">
								<a class="media g-color-lightred-v2--hover g-py-5 g-px-20" href="#!"> 
									<span class="d-flex align-self-center g-mr-12">
										<i class="community-admin-headphone-alt"></i>
									</span> 
									<span class="media-body align-self-center">Get Support</span>
								</a>
							</li>
							-->
							<li class="mb-0">
								<a class="media g-color-lightred-v2--hover g-py-5 g-px-20" href="<@spring.url "/accounts/logout"/>"> 
									<span class="d-flex align-self-center g-mr-12">
										<i class="community-admin-shift-right"></i>
									</span> 
									<span class="media-body align-self-center">로그아웃</span>
								</a>
							</li>
						</ul>
						<!-- End Top User Menu -->
					</div>
				</div>
				<!-- End Top User -->
			</div>
			<!-- End Messages/Notifications/Top Search Bar/Top User -->
			<!-- Top Activity Toggler -->
			<!-- End Top Activity Toggler -->
		</nav>
		<!-- Top Activity Panel -->
		<!-- End Top Activity Panel -->
	</div>
</header>