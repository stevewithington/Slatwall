﻿/*

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
component displayname="Subscription Usage Benefit" entityname="SlatwallSubscriptionUsageBenefit" table="SlatwallSubscriptionUsageBenefit" persistent="true" accessors="true" extends="BaseEntity" {
	
	// Persistent Properties
	property name="subscriptionUsageBenefitID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="maxUseCount" ormtype="integer";
	
	// Related Object Properties (many-to-one)
	property name="subscriptionBenefit" cfc="SubscriptionBenefit" fieldtype="many-to-one" fkcolumn="subscriptionBenefitID";
	property name="subscriptionUsage" cfc="SubscriptionUsage" fieldtype="many-to-one" fkcolumn="subscriptionUsageID" inverse="true";
	property name="renewalSubscriptionUsage" cfc="SubscriptionUsage" fieldtype="many-to-one" fkcolumn="renewalSubscriptionUsageID" inverse="true";
	
	// Related Object Properties (one-to-many)
	
	// Related Object Properties (many-to-many)
	property name="priceGroups" singularname="priceGroup" cfc="PriceGroup" type="array" fieldtype="many-to-many" linktable="SlatwallSubscriptionUsageBenefitPriceGroup" fkcolumn="subscriptionUsageBenefitID" inversejoincolumn="priceGroupID" cascade="all";
	property name="promotions" singularname="promotion" cfc="Promotion" type="array" fieldtype="many-to-many" linktable="SlatwallSubscriptionUsageBenefitPromotion" fkcolumn="subscriptionUsageBenefitID" inversejoincolumn="promotionID" cascade="all";
	property name="categories" singularname="category" cfc="Category" type="array" fieldtype="many-to-many" linktable="SlatwallSubscriptionUsageBenefitCategory" fkcolumn="subscriptionUsageBenefitID" inversejoincolumn="categoryID" cascade="all";
	property name="contents" singularname="content" cfc="Content" type="array" fieldtype="many-to-many" linktable="SlatwallSubscriptionUsageBenefitContent" fkcolumn="subscriptionUsageBenefitID" inversejoincolumn="contentID" cascade="all";
	
	// Remote Properties
	property name="remoteID" ormtype="string";
	
	// Audit Properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non-Persistent Properties

	
	public numeric function getCurrentUseCount() {
		var subscriptionUsageBenefitAccountSmartList = getService("SubscriptionService").getSubscriptionUsageBenefitAccountSmartList();
		subscriptionUsageBenefitAccountSmartList.addFilter(propertyIdentifier="subscriptionUsageBenefit_subscriptionUsageBenefitID", value=variables.subscriptionUsageBenefitID);
		return subscriptionUsageBenefitAccountSmartList.getRecordsCount();
	}
	
	public numeric function getAvailableUseCount() {
		return getMaxUseCount() - getCurrentUseCount();
	}
	
	public void function copyFromSubscriptionBenefit(required any subscriptionBenefit) {
		setSubscriptionBenefit(arguments.subscriptionBenefit);
		setMaxUseCount(arguments.subscriptionBenefit.getMaxUseCount());
		for(var priceGroup in arguments.subscriptionBenefit.getPriceGroups()) {
			addPriceGroup(priceGroup);
		}
		for(var promotion in arguments.subscriptionBenefit.getPromotions()) {
			addPromotion(promotion);
		}
		for(var category in arguments.subscriptionBenefit.getCategories()) {
			addCategory(category);
		}
		for(var content in arguments.subscriptionBenefit.getContents()) {
			addContent(content);
		}
	}
	
	public void function copyFromSubscriptionUsageBenefit(required any subscriptionUsageBenefit) {
		setSubscriptionBenefit(arguments.subscriptionUsageBenefit.getSubscriptionBenefit());
		setMaxUseCount(arguments.subscriptionUsageBenefit.getMaxUseCount());
		for(var priceGroup in arguments.subscriptionUsageBenefit.getPriceGroups()) {
			addPriceGroup(priceGroup);
		}
		for(var promotion in arguments.subscriptionUsageBenefit.getPromotions()) {
			addPromotion(promotion);
		}
		for(var category in arguments.subscriptionUsageBenefit.getCategories()) {
			addCategory(category);
		}
		for(var content in arguments.subscriptionUsageBenefit.getContents()) {
			addContent(content);
		}
	}
	
	// ============ START: Non-Persistent Property Methods =================
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// subscriptionUsage (many-to-one)    
	public void function setSubscriptionUsage(required any subscriptionUsage) {    
		variables.subscriptionUsage = arguments.subscriptionUsage;    
		if(isNew() or !arguments.subscriptionUsage.hasSubscriptionUsageBenefit( this )) {    
			arrayAppend(arguments.subscriptionUsage.getSubscriptionUsageBenefits(), this);    
		}    
	}    
	public void function removeSubscriptionUsage(any subscriptionUsage) {    
		if(!structKeyExists(arguments, "subscriptionUsage")) {    
			arguments.subscriptionUsage = variables.subscriptionUsage;    
		}    
		var index = arrayFind(arguments.subscriptionUsage.getSubscriptionUsageBenefits(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.subscriptionUsage.getSubscriptionUsageBenefits(), index);    
		}    
		structDelete(variables, "subscriptionUsage");    
	}
	
	// renewalSubscriptionUsage (many-to-one)    
	public void function setRenewalSubscriptionUsage(required any renewalSubscriptionUsage) {    
		variables.renewalSubscriptionUsage = arguments.renewalSubscriptionUsage;    
		if(isNew() or !arguments.renewalSubscriptionUsage.hasRenewalSubscriptionUsageBenefit( this )) {    
			arrayAppend(arguments.renewalSubscriptionUsage.getRenewalSubscriptionUsageBenefits(), this);    
		}    
	}    
	public void function removeRenewalSubscriptionUsage(any renewalSubscriptionUsage) {    
		if(!structKeyExists(arguments, "renewalSubscriptionUsage")) {    
			arguments.renewalSubscriptionUsage = variables.renewalSubscriptionUsage;    
		}    
		var index = arrayFind(arguments.renewalSubscriptionUsage.getRenewalSubscriptionUsageBenefits(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.renewalSubscriptionUsage.getRenewalSubscriptionUsageBenefits(), index);    
		}    
		structDelete(variables, "renewalSubscriptionUsage");    
	}
	
	// =============  END:  Bidirectional Helper Methods ===================

	// ================== START: Overridden Methods ========================
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
}