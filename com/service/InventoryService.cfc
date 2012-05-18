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
component extends="BaseService" accessors="true" output="false" {
	property name="inventoryDAO" type="any";
	
	// entity will be one of StockReceiverItem, StockPhysicalItem, StrockAdjustmentDeliveryItem, VendorOrderDeliveryItem, OrderDeliveryItem
	public void function createInventory(required any entity) {
		
		switch(entity.getEntityName()) {
			case "SlatwallStockReceiverItem": {
				if(arguments.entity.getStock().getSku().setting("skuTrackInventoryFlag")) {
					var inventory = this.newInventory();
					inventory.setQuantityIn(arguments.entity.getQuantity());
					inventory.setStock(arguments.entity.getStock());
					inventory.setStockReceiverItem(arguments.entity);
					getDAO().save(inventory);
				}
				break;
			}
			case "SlatwallStockPhysicalItem": {
				throw("Impliment ME!");
				break;
			}
			case "SlatwallOrderDeliveryItem": {
				if(arguments.entity.getStock().getSku().setting("skuTrackInventoryFlag")) {
					var inventory = this.newInventory();
					inventory.setQuantityOut(arguments.entity.getQuantity());
					inventory.setStock(arguments.entity.getStock());
					inventory.setOrderDeliveryItem(arguments.entity);
					getDAO().save(inventory);
				}
				break;
			}
			case "SlatwallVendorOrderDeliveryItem": {
				if(arguments.entity.getStock().getSku().setting("skuTrackInventoryFlag")) {
					var inventory = this.newInventory();
					inventory.setQuantityOut(arguments.entity.getQuantity());
					inventory.setStock(arguments.entity.getStock());
					inventory.setVendorOrderDeliveryItem(arguments.entity);
					getDAO().save(inventory);
				}
				break;
			}
			case "SlatwallStockAdjustmentDeliveryItem": {
				if(arguments.entity.getStock().getSku().setting("skuTrackInventoryFlag")) {
					var inventory = this.newInventory();
					inventory.setQuantityOut(arguments.entity.getQuantity());
					inventory.setStock(arguments.entity.getStock());
					inventory.setStockAdjustmentDeliveryItem(arguments.entity);
					getDAO().save(inventory);
				}
				break;
			}
			default: {
				throw("You are trying to create an inventory record for an entity that is not one of the 5 entities that manage inventory.  Those entities are: StockReceiverItem, StockPhysicalItem, StrockAdjustmentDeliveryItem, VendorOrderDeliveryItem, OrderDeliveryItem");
			}
		}
		
	}
	
	public numeric function getQOH(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID, string groupBy) {
		return getDAO().getQOH(argumentCollection=arguments);
	}
	
	public numeric function getQOSH(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQOSH(argumentCollection=arguments);
	}
	
	public numeric function getQNDOO(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQNDOO(argumentCollection=arguments);
	}
	
	public numeric function getQNDORVO(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQNDORVO(argumentCollection=arguments);
	}
	
	public numeric function getQNDOSA(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQNDOSA(argumentCollection=arguments);
	}
	
	public numeric function getQNRORO(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQNRORO(argumentCollection=arguments);
	}
	
	public numeric function getQNROVO(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQNROVO(argumentCollection=arguments);
	}
	
	public numeric function getQNROSA(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQNROSA(argumentCollection=arguments);
	}
	
	public numeric function getQR(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQR(argumentCollection=arguments);
	}
	
	public numeric function getQS(string stockID, string skuID, string productID, string stockRemoteID, string skuRemoteID, string productRemoteID) {
		return getDAO().getQS(argumentCollection=arguments);
	}
	
	// These methods are derived quantity methods from respective DAO methods
	public numeric function getQC(required any entity) {
		return arguments.entity.getQuantity('QNDOO') + arguments.entity.getQuantity('QNDORVO') + arguments.entity.getQuantity('QNDOSA');
	}
	
	public numeric function getQE(required any entity) {
		return arguments.entity.getQuantity('QNRORO') + arguments.entity.getQuantity('QNROVO') + arguments.entity.getQuantity('QNROSA');
	}
	
	public numeric function getQNC(required any entity) {
		return arguments.entity.getQuantity('QOH') - arguments.entity.getQuantity('QC');
	}
	
	public numeric function getQATS(required any entity) {
		var ats = arguments.entity.getQuantity('QNC');
		
		if(arguments.entity.setting("skuQATSIncludesQNROROFlag")) {
			ats += arguments.entity.getQuantity('QNRORO');
		}
		if(arguments.entity.setting("skuQATSIncludesQNROVOFlag")) {
			ats += arguments.entity.getQuantity('QNROVO');
		}
		if(arguments.entity.setting("skuQATSIncludesQNROSAFlag")) {
			ats += arguments.entity.getQuantity('QNROSA');
		}
		
		if(isNumeric(arguments.entity.setting("skuHoldBackQuantity"))) {
			ats -= arguments.entity.setting("skuHoldBackQuantity");
		}
		
		return ats;
	}
	
	public numeric function getQIATS(required any entity) {
		return arguments.entity.getQuantity('QNC') - arguments.entity.setting("skuHoldBackQuantity");
	}
	
	
}