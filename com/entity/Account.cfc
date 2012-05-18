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
component displayname="Account" entityname="SlatwallAccount" table="SlatwallAccount" persistent="true" output="false" accessors="true" extends="BaseEntity" {
	
	// Persistent Properties
	property name="accountID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="cmsAccountID" ormtype="string";
	property name="firstName" ormtype="string" hint="This Value is only Set if a MuraID does not exist";
	property name="lastName" ormtype="string" hint="This Value is only Set if a MuraID does not exist";
	property name="company" ormtype="string" hint="This Value is only Set if a MuraID does not exist";
	
	// Related Object Properties (many-to-one)
	property name="primaryEmailAddress" cfc="AccountEmailAddress" fieldtype="many-to-one" fkcolumn="primaryEmailAddressID";
	property name="primaryPhoneNumber" cfc="AccountPhoneNumber" fieldtype="many-to-one" fkcolumn="primaryPhoneNumberID";
	property name="primaryAddress" cfc="AccountAddress" fieldtype="many-to-one" fkcolumn="primaryAddressID";
	property name="primaryAccountPaymentMethod" cfc="AccountPaymentMethod" fieldtype="many-to-one" fkcolumn="primaryAccountPaymentMethodID";
	
	// Related Object Properties (one-to-many)
	property name="accountAddresses" singularname="accountAddress" fieldType="one-to-many" type="array" fkColumn="accountID" cfc="AccountAddress" inverse="true" cascade="all-delete-orphan";
	property name="accountContentAccesses" singularname="accountContentAccess" cfc="AccountContentAccess" type="array" fieldtype="one-to-many" fkcolumn="accountID" inverse="true" cascade="all-delete-orphan";
	property name="accountEmailAddresses" singularname="accountEmailAddress" type="array" fieldtype="one-to-many" fkcolumn="accountID" cfc="AccountEmailAddress" cascade="all-delete-orphan" inverse="true";
	property name="accountPaymentMethods" singularname="accountPaymentMethod" cfc="AccountPaymentMethod" type="array" fieldtype="one-to-many" fkcolumn="accountID" inverse="true" cascade="all-delete-orphan";
	property name="accountPhoneNumbers" singularname="accountPhoneNumber" type="array" fieldtype="one-to-many" fkcolumn="accountID" cfc="AccountPhoneNumber" cascade="all-delete-orphan" inverse="true";
	property name="attributeSetAssignments" singularname="attributeSetAssignment" cfc="AccountAttributeSetAssignment" fieldtype="one-to-many" fkcolumn="accountID" cascade="all-delete-orphan" inverse="true";
	property name="attributeValues" singularname="attributeValue" cfc="AccountAttributeValue" fieldtype="one-to-many" fkcolumn="accountID" cascade="all-delete-orphan" inverse="true";
	property name="orders" singularname="order" fieldType="one-to-many" type="array" fkColumn="accountID" cfc="Order" inverse="true" orderby="orderOpenDateTime desc";
	property name="productReviews" singularname="productReview" fieldType="one-to-many" type="array" fkColumn="accountID" cfc="ProductReview" inverse="true";
	property name="subscriptionUsageBenefitAccounts" singularname="subscriptionUsageBenefitAccount" cfc="SubscriptionUsageBenefitAccount" type="array" fieldtype="one-to-many" fkcolumn="accountID" cascade="all-delete-orphan" inverse="true";
	property name="subscriptionUsages" singularname="subscriptionUsage" cfc="SubscriptionUsage" type="array" fieldtype="one-to-many" fkcolumn="accountID" cascade="all-delete-orphan" inverse="true";
	
	// Related Object Properties (many-to-many)
	property name="priceGroups" singularname="priceGroup" cfc="PriceGroup" fieldtype="many-to-many" linktable="SlatwallAccountPriceGroup" fkcolumn="accountID" inversejoincolumn="priceGroupID";
	property name="permissionGroups" singularname="permissionGroup" cfc="PermissionGroup" fieldtype="many-to-many" linktable="SlatwallAccountPermissionGroup" fkcolumn="accountID" inversejoincolumn="permissionGroupID";

	// Remote properties
	property name="remoteID" ormtype="string" hint="Only used when integrated with a remote system";
	property name="remoteEmployeeID" ormtype="string" hint="Only used when integrated with a remote system";
	property name="remoteCustomerID" ormtype="string" hint="Only used when integrated with a remote system";
	property name="remoteContactID" ormtype="string" hint="Only used when integrated with a remote system";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non Persistent
	property name="fullName" persistent="false";
	property name="emailAddress" persistent="false" formatType="email";
	property name="phoneNumber" persistent="false";
	property name="address" persistent="false";
	property name="password" persistent="false";
	
	public boolean function isGuestAccount() {
		if(isNull(getCmsAccountID())) {
			return true;
		} else {
			return false;
		}
	}
	
	public string function getGravatarURL(numeric size=80) {
		if(cgi.server_port eq 443) {
			return "https://secure.gravatar.com/avatar/#lcase(hash(lcase(getEmailAddress()), "MD5" ))#?s=#arguments.size#";
		} else {
			return "http://www.gravatar.com/avatar/#lcase(hash(lcase(getEmailAddress()), "MD5" ))#?s=#arguments.size#";	
		}
	}
	
	public string function getAllPermissions(){
		var stPermissions = {};
		var permissionGroups = getPermissionGroups();
		
		for(i=1; i <= arrayLen(permissionGroups); i++){
			permissions = permissionGroups[i].getPermissions();
			
			for(j=1; j<= listlen(permissions); j++){
				stPermissions[listGetAt(permissions,j)]='';
			}
		}		
		
		return structKeyList(stPermissions);
	}
		
	// get all the assigned attribute sets
	public array function getAttributeSets(array attributeSetTypeCode){
		var smartList = getService("attributeService").getAttributeSetSmartList();
		
		smartList.addFilter("attributeSetType_systemCode","astAccount");
		
		return smartList.getRecords();
	}
	
	//get attribute value
	public any function getAttributeValue(required string attribute, returnEntity=false){
		var smartList = new Slatwall.com.utility.SmartList(entityName="SlatwallAccountAttributeValue");
		
		smartList.addFilter("account_accountID",getAccountID(),1);
		smartList.addFilter("attribute_attributeID",attribute,1);
		
		smartList.addFilter("account_accountID",getAccountID(),2);
		smartList.addFilter("attribute_attributeCode",attribute,2);
		
		var attributeValue = smartList.getRecords();
		
		if(arrayLen(attributeValue)){
			if(returnEntity) {
				return attributeValue[1];	
			} else {
				return attributeValue[1].getAttributeValue();
			}
		}else{
			if(returnEntity) {
				return getService("ProductService").newAccountAttributeValue();	
			} else {
				return "";
			}
		}
	}
	
	public boolean function isPriceGroupAssigned(required string  priceGroupId) {
		return structKeyExists(this.getPriceGroupsStruct(), arguments.priceGroupID);	
	}
	
	// ============ START: Non-Persistent Property Methods =================
	
	public string function getPhoneNumber() {
		return getPrimaryPhoneNumber().getPhoneNumber();
	}
	
	public string function getEmailAddress() {
		return getPrimaryEmailAddress().getEmailAddress();
	}
	
	public string function getAddress() {
		return getPrimaryAddress().getAddress();
	}
	
	public string function getFullName() {
		return "#getFirstName()# #getLastName()#";
	}
	
	// ============  END:  Non-Persistent Property Methods =================
	
	// ============= START: Bidirectional Helper Methods ===================
	
	// Account Addresses (one-to-many)
	public void function addAccountAddress(required any accountAddress) {
		arguments.accountAddress.setAccount( this );
	}
	public void function removeAccountAddress(required any accountAddress) {
		arguments.accountAddress.removeAccount( this );
	}
	
	// Account Content Accesses (one-to-many)
	public void function addAccountContentAccess(required any accountContentAccess) {
		arguments.accountContentAccess.setAccount( this );
	}
	public void function removeAccountContentAccess(required any accountContentAccess) {
		arguments.accountContentAccess.removeAccount( this );
	}
		
	// Account Email Addresses (one-to-many)
	public void function addAccountEmailAddress(required any accountEmailAddress) {    
		arguments.accountEmailAddress.setAccount( this );    
	}    
	public void function removeAccountEmailAddress(required any accountEmailAddress) {    
		arguments.accountEmailAddress.removeAccount( this );    
	}
	
	// Account Payment Methods (one-to-many)    
	public void function addAccountPaymentMethod(required any accountPaymentMethod) {    
		arguments.accountPaymentMethod.setAccount( this );    
	}    
	public void function removeAccountPaymentMethod(required any accountPaymentMethod) {    
		arguments.accountPaymentMethod.removeAccount( this );    
	}
	
	// Account Phone Numbers (one-to-many)    
	public void function addAccountPhoneNumber(required any accountPhoneNumber) {    
		arguments.accountPhoneNumber.setAccount( this );    
	}    
	public void function removeAccountPhoneNumber(required any accountPhoneNumber) {    
		arguments.accountPhoneNumber.removeAccount( this );    
	}
	
	// Account Promotions (one-to-many)
	public void function addAccountPromotion(required any AccountPromotion) {
		arguments.AccountPromotion.setAccount( this );
	}
	public void function removeAccountPromotion(required any AccountPromotion) {
		arguments.AccountPromotion.removeAccount( this );
	}
	
	// Account Attribute Sets (one-to-many)
	public void function addAccountAttributeSet(required any accountAttributeSet) {
		arguments.accountAttributeSet.setAccount( this );
	}
	public void function removeAccountAttributeSet(required any accountAttributeSet) {
	   arguments.accountAttributeSet.removeAccount( this );
	}
	
	// Attribute Values (one-to-many)    
	public void function addAttributeValue(required any attributeValue) {    
		arguments.attributeValue.setAccount( this );    
	}    
	public void function removeAttributeValue(required any attributeValue) {    
		arguments.attributeValue.removeAccount( this );    
	}
	
	// Orders (one-to-many)
	public void function addOrder(required any Order) {
	   arguments.order.setAccount(this);
	}
	public void function removeOrder(required any Order) {
	   arguments.order.removeAccount(this);
	}
	
	// Product Reviews (one-to-many)
	public void function addProductReview(required any productReview) {
		arguments.productReview.setAccount(this);
	}
	public void function removeProductReview(required any productReview) {
		arguments.productReview.removeAccount(this);
	}
	
	// Subscription Usage Benefits (one-to-many)    
	public void function addSubscriptionUsageBenefitAccount(required any subscriptionUsageBenefitAccount) {    
		arguments.subscriptionUsageBenefitAccount.setAccount( this );    
	}    
	public void function removeSubscriptionUsageBenefitAccount(required any subscriptionUsageBenefitAccount) {    
		arguments.subscriptionUsageBenefitAccount.removeAccount( this );    
	}
	
	// Subscription Usage (one-to-many)    
	public void function addSubscriptionUsage(required any subscriptionUsage) {    
		arguments.subscriptionUsage.setAccount( this );    
	}    
	public void function removeSubscriptionUsage(required any subscriptionUsage) {    
		arguments.subscriptionUsage.removeAccount( this );    
	}
	
	// =============  END:  Bidirectional Helper Methods ===================

	// ================== START: Overridden Methods ========================
	
	public string function getSimpleRepresentationPropertyName() {
		return "fullName";
	}
	
	public any function getPrimaryEmailAddress() {
		if(!isNull(variables.primaryEmailAddress)) {
			return variables.primaryEmailAddress;
		} else if (arrayLen(getAccountEmailAddresses())) {
			return getAccountEmailAddresses()[1];
		} else {
			return getService("accountService").newAccountEmailAddress();
		}
	}
	
	public any function getPrimaryPhoneNumber() {
		if(!isNull(variables.primaryPhoneNumber)) {
			return variables.primaryPhoneNumber;
		} else if (arrayLen(getAccountPhoneNumbers())) {
			return getAccountPhoneNumbers()[1];
		} else {
			return getService("accountService").newAccountPhoneNumber();
		}
	}
	
	public any function getPrimaryAddress() {
		if(!isNull(variables.primaryAddress)) {
			return variables.primaryAddress;
		} else if (arrayLen(getAccountAddresses())) {
			return getAccountAddresses()[1];
		} else {
			return getService("accountService").newAccountAddress();
		}
	}
	
	public any function getPrimaryAccountPaymentMethod() {
		if(!isNull(variables.primaryAccountPaymentMethod)) {
			return variables.primaryAccountPaymentMethod;
		} else if (arrayLen(getAccountPaymentMethods())) {
			return getAccountPaymentMethods()[1];
		} else {
			return getService("accountService").newAccountPaymentMethod();
		}
	}
	
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================

}
