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

<cfparam name="rc.returnAction" type="string" default="admin:warehouse.editStockAdjustment&stockAdjustmentID=#rc.stockAdjustmentID#" />
<cfparam name="rc.processStockAdjustmentSmartList" type="any" />
<cfparam name="rc.multiProcess" type="boolean" />

<cfoutput>
	<cf_SlatwallProcessForm>
		
		<cf_SlatwallActionBar type="process" />
		<cfswitch expression="#rc.processcontext#" >
				<cfcase value="addItems">
					<cfset SkuSmartList = rc.$.slatwall.getService('SkuService').getSkuSmartList() />
					<cfset locations = rc.$.slatwall.getService('LocationService').getLocationOptions() /> 

					<cf_SlatwallProcessListing processSmartList="#SkuSmartList#">
						<cf_SlatwallProcessColumn propertyIdentifier="product.brand.brandName" />
						<cf_SlatwallProcessColumn propertyIdentifier="product.productName" />
						<cf_SlatwallProcessColumn propertyIdentifier="skucode" />
						<cf_SlatwallProcessColumn propertyIdentifier="optionsdisplay" />
						<cfif arrayLen(locations) gt 1>
							<cf_SlatwallProcessColumn data="locationID" fieldType="select" valueOptions="#locations#" fieldClass="span2" value="" />
						<cfelse>
							<cf_SlatwallProcessColumn data="locationID" fieldType="hidden" value="#locations[1]['value']#" />
						</cfif>
						<cf_SlatwallProcessColumn data="quantity" fieldType="text" fieldClass="span2 number" value="" />
						<cf_SlatwallProcessColumn data="stockAdjustmentID" fieldType="hidden" value="#rc.stockAdjustmentID#" />
					</cf_SlatwallProcessListing>
					
				</cfcase> 
				
				<cfcase value="processStockAdjustment">
					<p>
						Are you sure that you want to process this stock adjustment? It will no longer be editable.
					</p>	
					<cf_SlatwallProcessListing processSmartList="#rc.processstockadjustmentsmartlist#">
						<cf_SlatwallProcessColumn data="locationID" fieldType="hidden" value="#rc.stockAdjustmentID#" />
					</cf_SlatwallProcessListing>
				</cfcase>	
			</cfswitch>	
		<input type="hidden" name="processcontext" value="#rc.processcontext#" />
		<input type="hidden" name="returnAction" value="admin:warehouse.liststockadjustment" />
	</cf_SlatwallProcessForm>
</cfoutput>