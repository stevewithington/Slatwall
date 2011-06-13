<!---

    Slatwall - An e-commerce plugin for Mura CMS
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

<cfoutput>
	<table class="stripe">
		<tr>
			<th>#$.slatwall.rbKey("entity.sku.skucode")#</th>
			<th class="varWidth">#$.slatwall.rbKey("entity.product.brand")# - #$.slatwall.rbKey("entity.product.productname")#</th>
			<th>#$.slatwall.rbKey("admin.order.list.actions")#</th>
			<th>#$.slatwall.rbKey("entity.orderitem.price")#</th>
			<th>#$.slatwall.rbKey("entity.orderitem.quantity")#</th>
			<th>#$.slatwall.rbKey("admin.order.detail.quantityshipped")#</th>
			<th>#$.slatwall.rbKey("admin.order.detail.priceextended")#</th>
		</tr>
			
		<cfloop array="#local.orderFulfillment.getOrderFulfillmentItems()#" index="local.orderItem">
			<tr>
				<td>#local.orderItem.getSku().getSkuCode()#</td>
				<td class="varWidth">#local.orderItem.getSku().getProduct().getBrand().getBrandName()# #local.orderItem.getSku().getProduct().getProductName()#</td>
				<td>
<!---					<cfset local.orderActionOptions = local.order.getActionOptions() />
					<cfif arrayLen(local.orderActionOptions) gt 0>
						<select name="orderActions">
							<option value="">#$.slatwall.rbKey("define.select")#</option>
							<cfloop array = #local.orderActionOptions# index="local.thisAction">
								<option value="#local.order.getOrderID()#_#local.thisAction.getOrderActionType().getTypeID()#">#local.thisAction.getOrderActionType().getType()#</option>
							</cfloop>
						</select>
					<cfelse>
						#$.slatwall.rbKey("define.notApplicable")#
					</cfif>--->
				</td>				
				<td>#dollarFormat(local.orderItem.getPrice())#</td>
				<td>#int(local.orderItem.getQuantity())#</td>
				<td>#local.orderItem.getQuantityDelivered()#</td>
				<td>#dollarFormat(local.orderItem.getPrice() * local.orderItem.getQuantity())#</td>
			</tr>
		</cfloop>
	</table>
	<div class="shippingAddress">
		<h5>#$.slatwall.rbKey("entity.orderFulfillment.shippingAddress")#</h5>
		#local.orderFulfillment.getShippingAddress().getFullAddress("<br />")#	
	</div>
	<div class="shippingMethod">
		<h5>#$.slatwall.rbKey("entity.orderFulfillment.shippingMethod")#</h5>
		#local.orderFulfillment.getShippingMethod().getShippingMethodName()#	
	</div>
	<div class="totals">
		<dl class="fulfillmentTotals">
			<dt>
				#$.slatwall.rbKey("entity.orderFulfillment.subtotal")#:
			</dt>
			<dd>
				#dollarFormat( local.orderFulfillment.getSubTotal() )#
			</dd>
			<dt>
				#$.slatwall.rbKey("entity.orderFulfillment.shippingCharge")#:
			</dt>
			<dd>
				#dollarFormat( local.orderFulfillment.getShippingCharge() )#
			</dd>
			<dt>
				#$.slatwall.rbKey("entity.orderFulfillment.tax")#:
			</dt>
			<dd>
				#dollarFormat( local.orderFulfillment.getTax() )#
			</dd>
			<dt>
				#$.slatwall.rbKey("entity.orderFulfillment.total")#:
			</dt>
			<dd>
				#dollarFormat( local.orderFulfillment.getTotalCharge() )#
			</dd>
		</dl>
	</div>
</cfoutput>