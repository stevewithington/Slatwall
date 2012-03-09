/*

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

*/
component displayname="Brand" entityname="SlatwallBrand" table="SlatwallBrand" persistent=true output=false accessors=true extends="BaseEntity" {
	
	// Persistent Properties
	property name="brandID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="activeFlag" ormtype="boolean" hint="As Brands Get Old, They would be marked as Not Active";
	property name="urlTitle" ormtype="string" hint="This is the name that is used in the URL string";
	property name="brandName" ormtype="string" hint="This is the common name that the brand goes by.";
	property name="brandWebsite" ormtype="string" hint="This is the Website of the brand";
	
	// Persistent Properties - Inheritence Settings
	property name="brandDisplayTemplate" ormtype="string";
	
	// Remote properties
	property name="remoteID" ormtype="string";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Related Object Properties
	property name="products" singularname="product" cfc="Product" fieldtype="one-to-many" fkcolumn="brandID" inverse="true";
	//property name="vendors" singularname="vendor" cfc="Vendor" fieldtype="one-to-many" fkcolumn="brandID" inverse="true" cascade="all";    
	//property name="brandVendors" singularname="brandVendor" cfc="VendorBrand" fieldtype="one-to-many" fkcolumn="brandID" lazy="extra" inverse="true" cascade="all";
	property name="promotionRewards" singularname="promotionReward" cfc="PromotionRewardProduct" fieldtype="many-to-many" linktable="SlatwallPromotionRewardProductBrand" fkcolumn="brandID" inversejoincolumn="promotionRewardID" inverse="true";
	property name="promotionQualifiers" singularname="promotionQualifier" cfc="PromotionQualifierProduct" fieldtype="many-to-many" linktable="SlatwallPromotionQualifierProductBrand" fkcolumn="brandID" inversejoincolumn="promotionQualifierID" inverse="true";
	property name="promotionRewardExclusions" singularname="promotionRewardExclusion" cfc="PromotionRewardExclusion" fieldtype="many-to-many" linktable="SlatwallPromotionRewardExclusionBrand" fkcolumn="brandID" inversejoincolumn="promotionRewardExclusionID" inverse="true";
	property name="promotionQualifierExclusions" singularname="promotionQualifierExclusion" cfc="PromotionQualifierExclusion" fieldtype="many-to-many" linktable="SlatwallPromotionQualifierExclusionBrand" fkcolumn="brandID" inversejoincolumn="promotionQualifierExclusionID" inverse="true";
	
	// Related Object Properties (many-to-many)
	property name="vendors" singularname="vendor" cfc="Vendor" fieldtype="many-to-many" linktable="SlatwallVendorBrand" fkcolumn="brandID" inversejoincolumn="vendorID";
	
	public Brand function init(){
	   // set default collections for association management methods
	   if(isNull(variables.products)) {
	   	   variables.products = [];
	   }
 	   if(isNull(variables.promotionRewards)) {
	       variables.promotionRewards = [];
	   }
 	   if(isNull(variables.promotionRewardExclusions)) {
	       variables.promotionRewardExclusions = [];
	   }
 	   if(isNull(variables.promotionQualifiers)) {
	       variables.promotionQualifiers = [];
	   }
 	   if(isNull(variables.promotionQualifierExclusions)) {
	       variables.promotionQualifierExclusions = [];
	   }   
	   return super.init();
	}
 
 /******* Association management methods for bidirectional relationships **************/
	
	// Products (one-to-many)
	
	public void function addProduct(required Product Product) {
	   arguments.Product.setBrand(this);
	}
	
	public void function removeProduct(required Product Product) {
	   arguments.Product.removeBrand(this);
	}
	
	
	// promotionRewards (many-to-many)
	public void function addPromotionReward(required any promotionReward) {
	   arguments.promotionReward.addBrand(this);
	}
	
	public void function removePromotionReward(required any promotionReward) {
	   arguments.promotionReward.removeBrand(this);
	}
	
	// promotionQualifiers (many-to-many)
	public void function addPromotionQualifier(required any promotionQualifier) {
		arguments.promotionQualifier.addBrand( this );
	}
	
	public void function removePromotionQualifier(required any promotionQualifier) {
		arguments.promotionQualifier.removeBrand( this );
	}

	// promotionRewardExclusions (many-to-many)
	public void function addPromotionRewardExclusion(required any promotionRewardExclusion) {
	   arguments.promotionRewardExclusion.addBrand(this);
	}
	
	public void function removePromotionRewardExclusion(required any promotionRewardExclusion) {
	   arguments.promotionRewardExclusion.removeBrand(this);
	}
	
	// promotionQualifierExclusions (many-to-many)
	public void function addPromotionQualifierExclusion(required any promotionQualifierExclusion) {
	   arguments.promotionQualifierExclusion.addBrand(this);
	}
	
	public void function removePromotionQualifierExclusion(required any promotionQualifierExclusion) {
	   arguments.promotionQualifierExclusion.removeBrand(this);
	}
	
    /************   END Association Management Methods   *******************/
	
	// ============ START: Non-Persistent Property Methods =================
	
	// ============  END:  Non-Persistent Property Methods =================
	
	// ============= START: Bidirectional Helper Methods ===================
	
	// =============  END:  Bidirectional Helper Methods ===================
	
	// ================== START: Overridden Methods ========================
	
	// ==================  END:  Overridden Methods ========================
		
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
}
