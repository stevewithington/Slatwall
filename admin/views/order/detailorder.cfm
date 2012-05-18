<!---

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
<cfparam name="rc.edit" default="false" />
<cfparam name="rc.order" type="any" />

<cfoutput>
	<cf_SlatwallDetailForm object="#rc.order#" edit="#rc.edit#">
		<cf_SlatwallActionBar type="detail" object="#rc.order#" edit="#rc.edit#">
			<cf_SlatwallActionCaller action="admin:order.createorderitem" queryString="orderID=#rc.order.getOrderID()#" type="list" modal=true />
			<cfif rc.order.getQuantityDelivered()>
				<cf_SlatwallActionCaller action="admin:order.createreturnorder" queryString="originalOrderID=#rc.order.getOrderID()#" type="list" modal=true />
			</cfif>
		</cf_SlatwallActionBar>
		
		<cf_SlatwallDetailHeader>
			<cf_SlatwallPropertyList divclass="span4">
				<cf_SlatwallPropertyDisplay object="#rc.order#" property="orderStatusType" edit="#rc.edit#">
				<cf_SlatwallPropertyDisplay object="#rc.order#" property="orderOpenDateTime">
				<cfif !isNull(rc.order.getOrderClosedDateTime)>
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="orderCloseDateTime">
				</cfif>
				<cf_SlatwallPropertyDisplay object="#rc.order#" property="orderOrigin" edit="#rc.edit#">
			</cf_SlatwallPropertyList>
			<cf_SlatwallPropertyList divclass="span4">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="paymentAmountTotal">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="paymentAuthorizedTotal">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="paymentAmountReceivedTotal">
			</cf_SlatwallPropertyList>
			<cf_SlatwallPropertyList divclass="span4">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="subtotal">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="taxtotal">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="fulfillmenttotal">
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="discounttotal">
					<hr />
					<cf_SlatwallPropertyDisplay object="#rc.order#" property="total">
			</cf_SlatwallPropertyList>
		</cf_SlatwallDetailHeader>
		
		<cf_SlatwallTabGroup object="#rc.order#" allowComments=true>
			<cf_SlatwallTab view="admin:order/ordertabs/orderitems" />
			<cf_SlatwallTab view="admin:order/ordertabs/orderfulfillments" />
			<cf_SlatwallTab view="admin:order/ordertabs/orderpayments" />
			<cf_SlatwallTab view="admin:order/ordertabs/orderdeliveries" />
		</cf_SlatwallTabGroup>
		
	</cf_SlatwallDetailForm>

</cfoutput>