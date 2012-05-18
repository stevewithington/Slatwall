﻿<!---

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

--->

<cfparam name="rc.returnAction" type="string" default="admin:product.editproduct&productID=#rc.productID#" />
<cfparam name="rc.processProductSmartList" type="any" />
<cfparam name="rc.multiProcess" type="boolean" />

<cfoutput>
	<cf_SlatwallProcessForm>
		
		<cf_SlatwallActionBar type="process" />
		
		<cf_SlatwallProcessListing processSmartList="#rc.processProductSmartList#">
			<cfswitch expression="#rc.processcontext#" >
				<cfcase value="bulkupdate">
					<cf_SlatwallProcessColumn data="skuPrice" fieldType="text" fieldClass="span2 number" value="" />
				</cfcase> 
				<cfcase value="addOptionGroup">
					<cf_SlatwallProcessColumn data="optionGroup" fieldType="select" valueOptions="#rc.$.slatwall.getService('OptionService').getUnusedProductOptionGroups(rc.productID)#" fieldClass="span2"/>
				</cfcase> 
				<cfcase value="addOption">
					<cf_SlatwallProcessColumn data="option" fieldType="select" valueOptions="#rc.$.slatwall.getService('OptionService').getUnusedProductOptions(rc.productID)#" fieldClass="span2" value="" />
				</cfcase> 
			</cfswitch>	
			
		</cf_SlatwallProcessListing>
		<input type="hidden" name="processcontext" value="#rc.processcontext#" />
	</cf_SlatwallProcessForm>
</cfoutput>