<div id="sideNav" class="col-auto u-sidebar-navigation-v1 u-sidebar-navigation--dark">
	<ul id="sideNavMenu" class="u-sidebar-navigation-v1-menu u-side-nav--top-level-menu g-min-height-100vh mb-0">
	<#assign menuTree = CommunityContextHelper.getMenuService().getTreeWalker("ADMIN_SIDE_MENU") >
	<#list menuTree.getChildren()  as menuItem >
	<li class="u-sidebar-navigation-v1-menu-item u-side-nav--has-sub-menu u-side-nav--top-level-menu-item">
		<a class="media u-side-nav--top-level-menu-link u-side-nav--hide-on-hidden g-px-15 g-py-12" href="#!" data-hssm-target="#menu_item_${menuItem.menuId}"> 
		<span class="d-flex align-self-center g-pos-rel g-font-size-18 g-mr-18">
			<i class="${ menuItem.getProperty("icon", "community-admin-folder") }"></i>
		</span> 
		<span class="media-body align-self-center">${menuItem.name}</span> 
		<#if (menuTree.getChildCount(menuItem) > 0) >
		<span class="d-flex align-self-center u-side-nav--control-icon">
			<i class="community-admin-angle-right"></i>
		</span> 
		<span class="u-side-nav--has-sub-menu__indicator"></span>		
		</#if>
		</a> 
		<#if (menuTree.getChildCount(menuItem) > 0 ) > 
		<!-- ${menuItem.name} -->
		<ul id="menu_item_${menuItem.menuId}" class="u-sidebar-navigation-v1-menu u-side-nav--second-level-menu mb-0">
		<#list menuTree.getChildren(menuItem)  as menuItemSecond >
		<!-- ${menuItemSecond.name} -->
		<li class="u-sidebar-navigation-v1-menu-item u-side-nav--second-level-menu-item">
			<a class="media u-side-nav--second-level-menu-link g-px-15 g-py-12" href="<#if menuItemSecond.page??>${menuItemSecond.page}<#else>#!</#if>" data-page="<#if menuItemSecond.page??>${menuItemSecond.page}</#if>"> 
				<span class="d-flex align-self-center g-mr-15 g-mt-minus-1"> 
					<i class="${ menuItemSecond.getProperty("icon", "community-admin-layers") }"></i>
				</span> 
				<span class="media-body align-self-center">${menuItemSecond.name}</span>
			</a>
		</li>
		<!-- End ${menuItemSecond.name}-->
		</#list>
		</ul> 
		<!-- End ${menuItem.name}-->
		</#if>
	</li>
	</#list>
	
	</ul>
</div>