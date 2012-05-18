/*

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

*/
component displayname="Order" entityname="SlatwallOrder" table="SlatwallOrder" persistent=true output=false accessors=true extends="BaseEntity" {
	
	// Persistent Properties
	property name="orderID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="orderNumber" ormtype="string";
	property name="orderOpenDateTime" ormtype="timestamp";
	property name="orderCloseDateTime" ormtype="timestamp";
	
	// Calculated Properties
	property name="calculatedTotal" ormtype="big_decimal";
	
	// Related Object Properties (Many-To-One)
	property name="account" cfc="Account" fieldtype="many-to-one" fkcolumn="accountID";
	property name="referencedOrder" cfc="Order" fieldtype="many-to-one" fkcolumn="referencedOrderID";	// Points at the "parent" (NOT return) order.
	property name="orderType" cfc="Type" fieldtype="many-to-one" fkcolumn="orderTypeID";
	property name="orderStatusType" cfc="Type" fieldtype="many-to-one" fkcolumn="orderStatusTypeID";
	property name="orderOrigin" cfc="OrderOrigin" fieldtype="many-to-one" fkcolumn="orderOriginID";
	
	// Related Object Properties (One-To-Many)
	property name="orderItems" singularname="orderItem" cfc="OrderItem" fieldtype="one-to-many" fkcolumn="orderID" cascade="all-delete-orphan" inverse="true";
	property name="orderDeliveries" singularname="orderDelivery" cfc="OrderDelivery" fieldtype="one-to-many" fkcolumn="orderID"  cascade="all-delete-orphan" inverse="true";
	property name="orderFulfillments" singularname="orderFulfillment" cfc="OrderFulfillment" fieldtype="one-to-many" fkcolumn="orderID" cascade="all-delete-orphan" inverse="true";
	property name="orderPayments" singularname="orderPayment" cfc="OrderPayment" fieldtype="one-to-many" fkcolumn="orderID" cascade="all-delete-orphan" inverse="true";
	property name="orderReturns" singularname="orderReturn" cfc="OrderReturn" type="array" fieldtype="one-to-many" fkcolumn="orderID" cascade="all-delete-orphan" inverse="true";
	property name="referencingOrders" singularname="referencingOrder" cfc="Order" fieldtype="one-to-many" fkcolumn="referencedOrderID" cascade="all-delete-orphan" inverse="true";
	property name="appliedPromotions" singularname="appliedPromotion" cfc="PromotionApplied" fieldtype="one-to-many" fkcolumn="orderID" cascade="all-delete-orphan" inverse="true";
	
	// Related Object Properties (Many-To-Many)
	property name="promotionCodes" singularname="promotionCode" cfc="PromotionCode" fieldtype="many-to-many" linktable="SlatwallOrderPromotionCode" fkcolumn="orderID" inversejoincolumn="promotionCodeID";
	
	// Remote properties
	property name="remoteID" ormtype="string";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non persistent properties
	property name="discountTotal" persistent="false" formatType="currency";
	property name="itemDiscountAmountTotal" persistent="false" formatType="currency";
	property name="fulfillmentDiscountAmountTotal" persistent="false" formatType="currency";
	property name="fulfillmentTotal" persistent="false" formatType="currency";
	property name="fulfillmentRefundTotal" persistent="false" formatType="currency";
	property name="orderDiscountAmountTotal" persistent="false" formatType="currency";
	property name="paymentAmountTotal" persistent="false" formatType="currency";
	property name="paymentAuthorizedTotal" persistent="false" formatType="currency";
	property name="paymentAmountReceivedTotal" persistent="false" formatType="currency";
	property name="promotionCodeList" persistent="false";
	property name="quantityDelivered" persistent="false";
	property name="quantityUndelivered" persistent="false";
	property name="subTotal" persistent="false" formatType="currency";
	property name="subTotalAfterItemDiscounts" persistent="false" formatType="currency";
	property name="taxTotal" persistent="false" formatType="currency";
	property name="total" persistent="false" formatType="currency";
	property name="totalItems" persistent="false";
	property name="totalQuantity" persistent="false";
	
	
	public string function getStatus() {
		return getOrderStatusType().getType();
	}
	
	public string function getStatusCode() {
		return getOrderStatusType().getSystemCode();
	}
	
	public string function getType(){
		return getOrderType().getType();
	}
	
	public string function getTypeCode(){
		return getOrderType().getSystemCode();
	}
	
	public boolean function hasItemsQuantityWithinMaxOrderQuantity() {
		for(var i=1; i<=arrayLen(getOrderItems()); i++) {
			if(!getOrderItems()[i].hasQuantityWithinMaxOrderQuantity()) {
				return false;
			}
		}
		return true;
	}
	
	public void function removeAllOrderItems() {
		for(var i=arrayLen(getOrderItems()); i >= 1; i--) {
			getOrderItems()[i].removeOrder(this);
		}
	}
	
	public any function getOrderNumber() {
		if(isNull(variables.orderNumber)) {
			variables.orderNumber = "";
			confirmOrderNumberOpenDateCloseDate();
		}
		return variables.orderNumber;
	}
	
    public boolean function isPaid() {
		if(this.getPaymentAmountReceivedTotal() < getTotal()) {
			return false;
		} else {
			return true;
		}
	}
	
	public any function getActionOptions() {
		var smartList = getService("orderService").getOrderStatusActionSmartList();
		//smartList.joinRelatedProperty("SlatwallOrderStatusAction", "orderStatusType", "inner", false);
		smartList.addFilter("orderStatusType_typeID", getOrderStatusType().getTypeID());
		//smartList.addSelect(propertyIdentifier="orderActionType_type", alias="name");
		//smartList.addSelect(propertyIdentifier="orderActionType_typeID", alias="value");
		//return smartList.getHQL();
		return smartList.getRecords(); 
	}
	
 	
	// @hint: This is called from the ORM Event to setup an OrderNumber when an order is placed
	public void function confirmOrderNumberOpenDateCloseDate() {
		if((isNull(variables.orderNumber) || variables.orderNumber == "") && !isNUll(getOrderStatusType()) && !isNull(getOrderStatusType().getSystemCode()) && getOrderStatusType().getSystemCode() != "ostNotPlaced") {
			if(setting('globalOrderNumberGeneration') == "Internal" || setting('globalOrderNumberGeneration') == "") {
				var maxOrderNumber = getService("orderService").getMaxOrderNumber();
				if( arrayIsDefined(maxOrderNumber,1) ){
					setOrderNumber(maxOrderNumber[1] + 1);
				} else {
					setOrderNumber(1);
				}
			} else {
				setOrderNumber( getService("integrationService").getIntegrationByIntegrationPackage( setting('globalOrderNumberGeneration') ).getIntegrationCFC().getNewOrderNumber(order=this) );
			}
			
			setOrderOpenDateTime( now() );
		}
		if(!isNull(getOrderStatusType()) && !isNull(getOrderStatusType().getSystemCode()) && getOrderStatusType().getSystemCode() == "ostClosed" && isNull(getOrderCloseDateTime())) {
			setOrderCloseDateTime( now() );
		}
	}
	
	public numeric function getPreviouslyReturnedFulfillmentTotal() {
		return getService("OrderService").getPreviouslyReturnedFulfillmentTotal(getOrderId());
	}
	
	// A helper to loop over all deliveries, and grab all of the items of each and put them into a single array 
	public array function getDeliveredOrderItems() {
		var arr = [];
		var deliveries = getOrderDeliveries();
		for(var i=1; i <= ArrayLen(deliveries); i++) {
			var deliveryItems = deliveries[i].getOrderDeliveryItems();
			
			for(var j=1; j <= ArrayLen(deliveryItems); j++) {
				ArrayAppend(arr, deliveryItems[j].getOrderItem());
			}
		}
		
		return arr;
	}
    
	// ============ START: Non-Persistent Property Methods =================
	public numeric function getDiscountTotal() {
		return precisionEvaluate(getItemDiscountAmountTotal() + getFulfillmentDiscountAmountTotal() + getOrderDiscountAmountTotal());
		
	}
	
	public numeric function getItemDiscountAmountTotal() {
		var discountTotal = 0;
		for(var i=1; i<=arrayLen(getOrderItems()); i++) {
			if( getOrderItems()[i].getTypeCode() == "oitSale" ) {
				discountTotal = precisionEvaluate(discountTotal + getOrderItems()[i].getDiscountAmount());
			} else if ( getOrderItems()[i].getTypeCode() == "oitReturn" ) {
				discountTotal = precisionEvaluate(discountTotal - getOrderItems()[i].getDiscountAmount());
			} else {
				throw("there was an issue calculating the itemDiscountAmountTotal because of a orderItemType associated with one of the items");
			}
		}
		return discountTotal;
	}
	
	public numeric function getFulfillmentDiscountAmountTotal() {
		var discountTotal = 0;
		for(var i=1; i<=arrayLen(getOrderFulfillments()); i++) {
			discountTotal = precisionEvaluate(discountTotal + getOrderFulfillments()[i].getDiscountAmount());
		}
		return discountTotal;
	}

	public numeric function getFulfillmentTotal() {
		var fulfillmentTotal = 0;
		for(var i=1; i<=arrayLen(getOrderFulfillments()); i++) {
			fulfillmentTotal = precisionEvaluate(fulfillmentTotal + getOrderFulfillments()[i].getFulfillmentCharge());
		}
		return fulfillmentTotal;
	}
	
	public numeric function getFulfillmentRefundTotal() {
		var fulfillmentRefundTotal = 0;
		for(var i=1; i<=arrayLen(getOrderReturns()); i++) {
			fulfillmentRefundTotal = precisionEvaluate(fulfillmentRefundTotal + getOrderReturns()[i].getFulfillmentRefundAmount());
		}
		
		return fulfillmentRefundTotal;
	}
	
	public numeric function getOrderDiscountAmountTotal() {
		return 0;
	}
	
	public numeric function getPaymentAmountTotal() {
		var totalPayments = 0;
		
		for(var i=1; i<=arrayLen(getOrderPayments()); i++) {
			totalPayments = precisionEvaluate(totalPayments + getOrderPayments()[i].getAmount());
		}
		
		return totalPayments;
	}
	
	public numeric function getPaymentAmountAuthorizedTotal() {
		var totalPaymentsAuthorized = 0;
		
		for(var i=1; i<=arrayLen(getOrderPayments()); i++) {
			totalPaymentsAuthorized = precisionEvaluate(totalPaymentsAuthorized + getOrderPayments()[i].getAmountAuthorized());
		}
		
		return totalPaymentsAuthorized;
	}
	
	public numeric function getPaymentAmountReceivedTotal() {
		var totalPaymentsReceived = 0;
		
		for(var i=1; i<=arrayLen(getOrderPayments()); i++) {
			totalPaymentsReceived = precisionEvaluate(totalPaymentsReceived + getOrderPayments()[i].getAmountReceived());
		}
		
		return totalPaymentsReceived;
	}
	
	public string function getpromotionCodeList() {
		if(!structKeyExists(variables, "promotionCodeList")) {
			variables.promotionCodeList = "";
			for(var i=1; i<=arrayLen(getPromotionCodes()); i++) {
				variables.promotionCodeList = listAppend(variables.promotionCodeList, getPromotionCodes()[i].getPromotionCode());
			}
		}
		return variables.promotionCodeList;
	}
	
	public numeric function getDeliveredItemsPaymentAmountUnreceived() {
		var received = getPaymentAmountReceivedTotal();
		var amountDelivered = 0;
		
		for(var f=1; f<=arrayLen(getOrderFulfillments()); f++) {
			// If this fulfillment is fully delivered, then just add the entire amount
			if(getOrderFulfillments()[f].getQuantityUndelivered() == 0) {
				amountDelivered = precisionEvaluate(amountDelivered + getFulfillmentTotal());
				
			// If this fulfillment has at least one item delivered
			} else if(getOrderFulfillments()[f].getQuantityDelivered() > 0) {
				
				// Add the fulfillmentCharge
				amountDelivered = precisionEvaluate(amountDelivered + getOrderFulfillments()[f].getChargeAfterDiscount());
				
				// Loop over the fulfillmentItems and add each of the amounts to the total amount delivered
				for(var i=1; i<=arrayLen(getOrderFulfillments()[f].getOrderFulfillmentItems()); i++) {
					var item = getOrderFulfillments()[f].getOrderFulfillmentItems()[i];
					
					if(item.getQuantityUndelivered() == 0) {
						amountDelivered = precisionEvaluate(amountDelivered + item.getItemTotal());
					} else if (item.getQuantityDelivered() > 0) {
						amountDelivered = precisionEvaluate(amountDelivered + (item.getItemTotal() * (item.getQuantityDelivered() / item.getQuantity())) );
					}
				}
			}
		}
		
		return precisionEvaluate(amountDelivered - getPaymentAmountReceivedTotal());
	}
	
	public numeric function getQuantityDelivered() {
		var orderItems = getOrderItems();
		var variables.quantityDelivered = 0;
		for(var i=1; i<=arrayLen(orderitems); i++) {
			variables.quantityDelivered += orderItems[i].getQuantityDelivered();
		}
		return variables.quantityDelivered;
	}
	
	public numeric function getQuantityUndelivered() {
		return this.getTotalQuantity() - this.getQuantityDelivered();
	}
	
	public numeric function getSubtotal() {
		var subtotal = 0;
		for(var i=1; i<=arrayLen(getOrderItems()); i++) {
			if( getOrderItems()[i].getTypeCode() == "oitSale" ) {
				subtotal = precisionEvaluate(subtotal + getOrderItems()[i].getExtendedPrice());	
			} else if ( getOrderItems()[i].getTypeCode() == "oitReturn" ) {
				subtotal = precisionEvaluate(subtotal - getOrderItems()[i].getExtendedPrice());
			} else {
				throw("there was an issue calculating the subtotal because of a orderItemType associated with one of the items");
			}
		}
		return subtotal;
	}
	
	public numeric function getSubtotalAfterItemDiscounts() {
		return precisionEvaluate(getSubtotal() - getItemDiscountAmountTotal());
	}
	
	public numeric function getTaxTotal() {
		var taxTotal = 0;
		for(var i=1; i<=arrayLen(getOrderItems()); i++) {
			if( getOrderItems()[i].getTypeCode() == "oitSale" ) {
				taxTotal = precisionEvaluate(taxTotal + getOrderItems()[i].getTaxAmount());	
			} else if ( getOrderItems()[i].getTypeCode() == "oitReturn" ) {
				taxTotal = precisionEvaluate(taxTotal - getOrderItems()[i].getTaxAmount());
			} else {
				throw("there was an issue calculating the subtotal because of a orderItemType associated with one of the items");
			}
		}
		return taxTotal;
	}
	
	public numeric function getTotal() {
		return precisionEvaluate(getSubtotal() + getTaxTotal() + getFulfillmentTotal() - getFulfillmentRefundTotal() - getDiscountTotal());
	}
	
	public numeric function getTotalItems() {
		return arrayLen(getOrderItems());
	}
	
	public numeric function getTotalQuantity() {
		if(!structKeyExists(variables,"totalQuantity")) {
			variables.totalQuantity = 0;
			for(var i=1; i<=arrayLen(getOrderItems()); i++) {
				variables.totalQuantity += getOrderItems()[i].getQuantity(); 
			}
		}
		return variables.totalQuantity;
	}
	
	// ============  END:  Non-Persistent Property Methods =================
	
	// ============= START: Bidirectional Helper Methods ===================

	// Account (many-to-one)
	public any function setAccount(required any account) {
		variables.account = arguments.account;
		if(isNew() or !arguments.account.hasOrder( this )) {
			arrayAppend(arguments.account.getOrders(), this);
		}
		return this;
	}
	public void function removeAccount(any account) {
		if(!structKeyExists(arguments, "account")) {
			arguments.account = variables.account;
		}
		var index = arrayFind(arguments.account.getOrders(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.account.getOrders(), index);
		}
		structDelete(variables, "account");
	}
	
	// Refrenced Order (many-to-one)
	public void function setRefrencedOrder(required any refrencedOrder) {
		variables.refrencedOrder = arguments.refrencedOrder;
		if(isNew() or !arguments.refrencedOrder.hasRefrencingOrder( this )) {
			arrayAppend(arguments.refrencedOrder.getRefrencingOrders(), this);
		}
	}
	public void function removeRefrencedOrder(any refrencedOrder) {
		if(!structKeyExists(arguments, "refrencedOrder")) {
			arguments.refrencedOrder = variables.refrencedOrder;
		}
		var index = arrayFind(arguments.refrencedOrder.getRefrencingOrders(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.refrencedOrder.getRefrencingOrders(), index);
		}
		structDelete(variables, "refrencedOrder");
	}

	// Order Items (one-to-many)
	public void function addOrderItem(required any orderItem) {
		arguments.orderItem.setOrder( this );
	}
	public void function removeOrderItem(required any orderItem) {
		arguments.orderItem.removeOrder( this );
	}

	// Order Deliveries (one-to-many)
	public void function addOrderDelivery(required any orderDelivery) {
		arguments.orderDelivery.setOrder( this );
	}
	public void function removeOrderDelivery(required any orderDelivery) {
		arguments.orderDelivery.removeOrder( this );
	}

	// Order Fulfillments (one-to-many)
	public void function addOrderFulfillment(required any orderFulfillment) {
		arguments.orderFulfillment.setOrder( this );
	}
	public void function removeOrderFulfillment(required any orderFulfillment) {
		arguments.orderFulfillment.removeOrder( this );
	}

	// Order Payments (one-to-many)
	public void function addOrderPayment(required any orderPayment) {
		arguments.orderPayment.setOrder( this );
	}
	public void function removeOrderPayment(required any orderPayment) {
		arguments.orderPayment.removeOrder( this );
	}

	// Order Returns (one-to-many)
	public void function addOrderReturn(required any orderReturn) {
		arguments.orderReturn.setOrder( this );
	}
	public void function removeOrderReturn(required any orderReturn) {
		arguments.orderReturn.removeOrder( this );
	}
	
	// Refrencing Order Items (one-to-many)
	public void function addRefrencingOrderItem(required any refrencingOrderItem) {
		arguments.refrencingOrderItem.setRefrencedOrder( this );
	}
	public void function removeRefrencingOrderItem(required any refrencingOrderItem) {
		arguments.refrencingOrderItem.removeRefrencedOrder( this );
	}
	
	// Applied Promotions (one-to-many)
	public void function addAppliedPromotion(required any appliedPromotion) {
		arguments.appliedPromotion.setOrder( this );
	}
	public void function removeAppliedPromotion(required any appliedPromotion) {
		arguments.appliedPromotion.removeOrder( this );
	}
	
	// =============  END:  Bidirectional Helper Methods ===================
	
	// ============== START: Overridden Implicet Getters ===================
	
	public any function getOrderStatusType() {
		if(isNull(variables.orderStatusType)) {
			variables.orderStatusType = getService("typeService").getTypeBySystemCode('ostNotPlaced');
		}
		return variables.orderStatusType;
	}
	
	public any function getOrderType() {
		if(isNull(variables.orderType)) {
			variables.orderType = getService("typeService").getTypeBySystemCode('otSalesOrder');
		}
		return variables.orderType;
	}
	
	// ==============  END: Overridden Implicet Getters ====================
	
	// ================== START: Overridden Methods ========================
	
	public string function getSimpleRepresentationPropertyName() {
		return "orderNumber";
	}
	
	public string function getSimpleRepresentation() {
		if(!isNull(getOrderNumber()) && len(getOrderNumber())) {
			var representation = getOrderNumber();
		} else {
			var representation = rbKey('define.cart');
		}
		
		if(!isNull(getAccount())) {
			representation &= " - #getAccount().getFullname()#";
		}
		
		return representation;
	}
	
	// ==================  END:  Overridden Methods ========================
		
	// =================== START: ORM Event Hooks  =========================
	
	public void function preInsert(){
		super.preInsert();
		
		// Verify Defaults are Set
		getOrderType();
		getOrderStatusType();
		
		confirmOrderNumberOpenDateCloseDate();
	}
	
	public void function preUpdate(Struct oldData){
		super.preUpdate();
		confirmOrderNumberOpenDateCloseDate();
	}
	
	// ===================  END:  ORM Event Hooks  =========================
}
