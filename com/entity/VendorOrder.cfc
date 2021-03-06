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
component displayname="Vendor VendorOrder" entityname="SlatwallVendorOrder" table="SlatwallVendorOrder" persistent="true" accessors="true" output="false" extends="BaseEntity" {
	
	// Persistent Properties
	property name="vendorOrderID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="vendorOrderNumber" ormtype="string";
	property name="estimatedReceivalDateTime" ormtype="timestamp";
	property name="currencyCode" ormtype="string" length="3";
	
	// Related Object Properties (Many-To-One)
	property name="vendor" cfc="Vendor" fieldtype="many-to-one" fkcolumn="vendorID";
	property name="vendorOrderType" cfc="Type" fieldtype="many-to-one" fkcolumn="vendorOrderTypeID";
	property name="vendorOrderStatusType" cfc="Type" fieldtype="many-to-one" fkcolumn="vendorOrderStatusTypeID";
	
	// Related Object Properties (One-To-Many)
	property name="attributeValues" singularname="attributeValue" cfc="AttributeValue" type="array" fieldtype="one-to-many" fkcolumn="vendorOrderID" cascade="all-delete-orphan" inverse="true";
	property name="vendorOrderItems" singularname="vendorOrderItem" cfc="VendorOrderItem" fieldtype="one-to-many" fkcolumn="vendorOrderID" inverse="true" cascade="all";
	property name="stockReceivers" singularname="stockReceiver" cfc="StockReceiver" type="array" fieldtype="one-to-many" fkcolumn="vendorOrderID" cascade="all-delete-orphan" inverse="true";
	
	// Remote Properties
	property name="remoteID" ormtype="string";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non persistent properties
	property name="total" persistent="false" formatType="currency"; 
	property name="subTotal" persistent="false" formatType="currency"; 
	//property name="taxTotal" persistent="false" formatType="currency";
	//property name="itemAmountTotal" persistent="false" formatType="currency" ;
	//property name="fulfillmentAmountTotal" persistent="false" formatType="currency"; 
	property name="orderAmountTotal" persistent="false" formatType="currency"; 
	property name="fulfillmentTotal" persistent="false" formatType="currency";
	property name="vendorSkus" persistent="false";
	property name="vendorSkusSmartList" persistent="false";
	
	public array function getVendorSkus() {
		return getVendorSkusSmartList().getRecords();
	}
	
	public any function getVendorSkusSmartList() {
		return getVendor().getVendorSkusSmartList();
	}
	
	public numeric function getSubtotal() {
		var subtotal = 0;
		for(var i=1; i<=arrayLen(getVendorOrderItems()); i++) {
			subtotal = precisionEvaluate(subtotal + getVendorOrderItems()[i].getExtendedCost());
		}
		return subtotal;
	}
	
	public numeric function getTotal() {
		return getSubtotal() /*+ getTaxTotal() + getFulfillmentTotal()*/;
	}
	
	public void function removeAllVendorOrderItems() {
		for(var i=arrayLen(getVendorOrderItems()); i >= 1; i--) {
			getVendorOrderItems()[i].removeVendorOrder(this);
		}
	}
	
	public boolean function isProductInVendorOrder(required any productID) {
		return getService("VendorOrderService").isProductInVendorOrder(arguments.productID, this.getVendorOrderId());
	}
	
	// This method first finds the Stock with the provided sku and location, then searches in the VendorOrder's Items list for an item with that stock. If either are not found, it returns a blank VendorOrderItem
	public any function getVendorOrderItemForSkuAndLocation(required any skuID, required any locationID) {
		var sku = getService("SkuService").getSku(arguments.skuID);
		var location = getService("LocationService").getLocation(arguments.locationID);
		var stock = getService("StockService").getStockBySkuAndLocation(sku, location);
		
		for(var i=1; i<=arrayLen(getVendorOrderItems()); i++) {
			if(getVendorOrderItems()[i].hasStock(stock)) {
				return vendorOrderItems[i];
			}
		}
		
		// Otherwise, if stock was null (could not find one with that sku and location) or no VendorOrderItem was found with the located stock, return a new VendorOrderItem
		return getService("VendorOrderService").newVendorOrderItem();
	}
	
	public any function getVendorOrderItemCostForSku(required any skuID) {
		// Search over all VendorOrderItems to find one that has a stock for the given skuID
		var vendorOrderItems = getVendorOrderItems(); 
		for(var i=1; i <= ArrayLen(vendorOrderItems); i++){
			if(vendorOrderItems[i].getStock().getSku().getSkuID() == arguments.skuID) {
				return vendorOrderItems[i].getCost();
			}
		}
		
		// Otherwise, if nothing could be found, the cost is 0.
		return 0;	
	}
	
	public any function getQuantityOfStockAlreadyOnOrder(required any skuID, required any locationID) {
		return getService("VendorOrderService").getQuantityOfStockAlreadyOnOrder(getVendorOrderID(), arguments.skuID, arguments.locationID);
	}
	
	public any function getQuantityOfStockAlreadyReceived(required any skuID, required any locationID) {
		return getService("VendorOrderService").getQuantityOfStockAlreadyReceived(getVendorOrderID(), arguments.skuID, arguments.locationID);
	}
	
	public any function getSkusOrdered() {
		return getService("VendorOrderService").getSkusOrdered(getVendorOrderId());
	}
	
	// ============ START: Non-Persistent Property Methods =================
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// Vendor (many-to-one)
	public void function setVendor(required any vendor) {
		variables.vendor = arguments.vendor;
		if(isNew() or !arguments.vendor.hasVendorOrder( this )) {
			arrayAppend(arguments.vendor.getVendorOrders(), this);
		}
	}
	public void function removeVendor(any vendor) {
		if(!structKeyExists(arguments, "vendor")) {
			arguments.vendor = variables.vendor;
		}
		var index = arrayFind(arguments.vendor.getVendorOrders(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.vendor.getVendorOrders(), index);
		}
		structDelete(variables, "vendor");
	}
	
	// Attribute Values (one-to-many)    
	public void function addAttributeValue(required any attributeValue) {    
		arguments.attributeValue.setAttributeValues( this );    
	}    
	public void function removeAttributeValue(required any attributeValue) {    
		arguments.attributeValue.removeAttributeValues( this );    
	}
	
	// Stock Receivers (one-to-many)
	public void function addStockReceiver(required any stockReceiver) {
		arguments.stockReceiver.setVendorOrder( this );
	}
	public void function removeStockReceiver(required any stockReceiver) {
		arguments.stockReceiver.removeVendorOrder( this );
	}
	
	// =============  END:  Bidirectional Helper Methods ===================

	// ============== START: Overridden Implicet Getters ===================

	public any function getVendorOrderType() {
		if( !structKeyExists(variables, "vendorOrderType") ) {
			variables.vendorOrderType = getService("typeService").getTypeBySystemCode("votPurchaseOrder");
		}
		return variables.vendorOrderType;
	}
	
	public any function getVendorOrderStatusType() {
		if( !structKeyExists(variables, "vendorOrderStatusType") ) {
			variables.vendorOrderStatusType = getService("typeService").getTypeBySystemCode("vostNew");
		}
		return variables.vendorOrderStatusType;
	}
	
	// ==============  END: Overridden Implicet Getters ====================
	
	// ================== START: Overridden Methods ========================
	
	public string function getSimpleRepresentation() {
		return "#getVendor().getVendorName()# - #getVendorOrderNumber()#";
	}
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	public void function preInsert(){
		super.preInsert();
		
		// Verify Defaults are Set
		getVendorOrderType();
		getVendorOrderStatusType();
	}
	
	// ===================  END:  ORM Event Hooks  =========================
}
