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
component displayname="Price Group" entityname="SlatwallPriceGroup" table="SlatwallPriceGroup" persistent=true output=false accessors=true extends="BaseEntity" {
	
	// Persistent Properties
	property name="priceGroupID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="activeFlag" ormtype="boolean";
	property name="priceGroupName" ormtype="string";
	property name="priceGroupCode" ormtype="string";
	
	// Related Object Properties (Many-To-One)
	property name="parentPriceGroup" cfc="PriceGroup" fieldtype="many-to-one" fkcolumn="parentPriceGroupID";
	
	// Related Object Properties (One-To-Many)
	property name="childPriceGroups" singularname="ChildPriceGroup" cfc="PriceGroup" fieldtype="one-to-many" fkcolumn="parentPriceGroupID" inverse="true";
	property name="priceGroupRates" singularname="priceGroupRate" cfc="PriceGroupRate" fieldtype="one-to-many" fkcolumn="priceGroupID" cascade="all-delete-orphan" inverse="true";    
	
	// Related Object Properties (many-to-many)
	property name="accounts" singularname="account" cfc="Account" fieldtype="many-to-many" linktable="SlatwallAccountPriceGroup" fkcolumn="priceGroupID" inversejoincolumn="accountID";

	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Pricing Group Rates (one-to-many)
	
	public void function addPriceGroupRate(required any priceGroupRate) {
	   arguments.priceGroupRate.setPriceGroup(this);
	}
	
	public void function removePriceGroupRate(required any priceGroupRate) {
	   arguments.priceGroupRate.removePriceGroup(this);
	}
	
	
	
	// Parent Pricing Group (many-to-one)
	public void function addChildPriceGroup(required any priceGroup) {
		arguments.priceGroup.setParentPriceGroup(this);
	}
	
	public void function removeChildPriceGroup(required any priceGroup) {
		arguments.priceGroup.removeParentPriceGroup();
	}
	
	// Override the default setParentPriceGroup method to wire up childParentGroups
    public void function setParentPriceGroup(required any priceGroup) {
    	variables.parentPriceGroup = arguments.priceGroup;
    	
		// Populate the ChildPriceGroups in the other Price Group. We need to manually manipulate the array because the addChildPriceGroup() has been overwridden
		if(isNew() or !arguments.priceGroup.hasChildPriceGroup(this)) {
			arrayAppend(arguments.priceGroup.getChildPriceGroups(), this);
		}
    	
    }
    
    // Removes the parent (inherited) price group from this price group (nulls out the property) and also removes the references to this price group from the price group that we were inheriting from.
    // If PriceGroupB inherits from PriceGroupA, then this method is going to be called on PriceGroupB. 
    public void function removeParentPriceGroup() {
		if(StructKeyExists(variables, "parentPriceGroup")) {
			// Loop in the parent price group's (priceGroupA) children (inheriting Price Groups), and find this price group (PriceGroupB), and remove it from PriceGroupA's array.
			var index = arrayFind(variables.parentPriceGroup.getChildPriceGroups(), this);
			if(index > 0) {
				arrayDeleteAt(variables.parentPriceGroup.getChildPriceGroups(), index);
			}
			
			structDelete(variables, "parentPriceGroup");
		}
    }
	
    
    // Loop over all Price Group Rates and pull the one that is global
    public any function getGlobalPriceGroupRate() {
    	var rates = getPriceGroupRates();
    	for(var i=1; i <= ArrayLen(rates); i++) {
    		if(rates[i].getGlobalFlag()) {
    			return rates[i];
    		}
    	}	
    }
    
    // Check if this PriceGroup can be deleted. Right now, only check if it has inheriting price groups
    public boolean function isNotDeletable() {
    	return ArrayLen(getChildPriceGroups()) NEQ 0;
    }
    
    
        

	// ============ START: Non-Persistent Property Methods =================
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// =============  END:  Bidirectional Helper Methods ===================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================    
}
