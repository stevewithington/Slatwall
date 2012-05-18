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
component extends="Slatwall.com.service.BaseService" persistent="false" accessors="true" output="false" {

	property name="roundingRuleService" type="any";
	property name="utilityService" type="any";

		
	// ----------------- START: Apply Promotion Logic ------------------------- 
	public void function updateOrderAmountsWithPromotions(required any order) {
		
		// Sale & Exchange Orders
		if( listFindNoCase("otSalesOrder,otExchangeOrder", arguments.order.getOrderType().getSystemCode()) ) {
			// Clear all previously applied promotions for order items
			for(var oi=1; oi<=arrayLen(arguments.order.getOrderItems()); oi++) {
				for(var pa=arrayLen(arguments.order.getOrderItems()[oi].getAppliedPromotions()); pa >= 1; pa--) {
					arguments.order.getOrderItems()[oi].getAppliedPromotions()[pa].removeOrderItem();
				}
			}
			// Clear all previously applied promotions for fulfillment
			for(var of=1; of<=arrayLen(arguments.order.getOrderFulfillments()); of++) {
				for(var pa=arrayLen(arguments.order.getAppliedPromotions()); pa >= 1; pa--) {
					arguments.order.getAppliedPromotions()[pa].removeOrderFulfillment();
				}
			}
			// Clear all previously applied promotions for order
			for(var pa=arrayLen(arguments.order.getAppliedPromotions()); pa >= 1; pa--) {
				arguments.order.getAppliedPromotions()[pa].removeOrder();
			}
			
			// Loop over orderItems and apply Sale Prices
			for(var oi=1; oi<=arrayLen(arguments.order.getOrderItems()); oi++) {
				var orderItem = arguments.order.getOrderItems()[oi];
				var salePriceDetails = orderItem.getSku().getSalePriceDetails();

				if(structKeyExists(salePriceDetails, "salePrice") && salePriceDetails.salePrice < orderItem.getSku().getPrice()) {
					var discountAmount = precisionEvaluate((orderItem.getSku().getPrice() * orderItem.getQuantity()) - (salePriceDetails.salePrice * orderItem.getQuantity()));

					var newAppliedPromotion = this.newOrderItemAppliedPromotion();
					newAppliedPromotion.setPromotion( this.getPromotion(salePriceDetails.promotionID) );
					newAppliedPromotion.setOrderItem( orderItem );
					newAppliedPromotion.setDiscountAmount( discountAmount );
				}
			}
			
			// Loop over all Potential Discounts that require qualifications
			var promotionRewards = getDAO().getActivePromotionRewards(rewardTypeList="merchandise,subscription,contentAccess,order,fulfillment", promotionCodeList=arguments.order.getPromotionCodeList(), qualificationRequired=true);
			for(var pr=1; pr<=arrayLen(promotionRewards); pr++) {
				
				var reward = promotionRewards[pr];
				var qualificationCount = getPromotionRewardQualificationCount(promotionReward=reward, order=arguments.order);
				
				// If this order qualifies for the 
				if(qualificationCount) {
					
					switch(reward.getRewardType()) {
						// =============== Order Item Reward ==============
						case "merchandise": case "subscription": case "contentAccess":
						
							// Loop over all the orderItems
							for(var i=1; i<=arrayLen(arguments.order.getOrderItems()); i++) {
								
								// Get The order Item
								var orderItem = arguments.order.getOrderItems()[i];
								
								// Verify that this is an item being sold
								// TODO: Add check here for the subscriptionTerm
								if(orderItem.getOrderItemType().getSystemCode() == "oitSale") {
									
									// Check the reward settings to see if this orderItem applies
									if( ( !arrayLen( reward.getProductTypes() ) || reward.hasProductType( orderItem.getSku().getProduct().getProductType() ) )
										&&
										( !arrayLen( reward.getProducts() ) || reward.hasProduct( orderItem.getSku().getProduct() ) )
										&&
										( !arrayLen( reward.getSkus() ) || reward.hasSku( orderItem.getSku() ) )
										&&
										( !arrayLen( reward.getBrands() ) || reward.hasBrand( orderItem.getSku().getProduct().getBrand() ) )
										&&
										( !arrayLen( reward.getOptions() ) || reward.hasAnyOption( orderItem.getSku().getOptions() ) )  	) {
										
										// If there is not applied Price Group, or if this reward has the applied pricegroup as an eligible one then use priceExtended... otherwise use skuPriceExtended and then adjust the discount.
										if( isNull(orderItem.getAppliedPriceGroup()) || reward.hasEligiblePriceGroup( orderItem.getAppliedPriceGroup() ) ) {
											// Calculate based on price, which could be a priceGroup price
											var discountAmount = getDiscountAmount(reward, orderItem.getExtendedPrice());
										} else {
											// Calculate based on skuPrice because the price on this item is a priceGroup price and we need to adjust the discount by the difference
											var originalDiscountAmount = getDiscountAmount(reward, orderItem.getExtendedSkuPrice());
											// Take the original discount they were going to get without a priceGroup and subtract the difference of the discount that they are already receiving
											discountAmount = precisionEvaluate(originalDiscountAmount - (orderItem.getExtendedSkuPrice() - orderItem.getExtendedPrice()));
										}
										
										var addNew = false;
										
										// First we make sure that the discountAmount is > 0 before we check if we should add more discount
										if(discountAmount > 0) {
											// If there aren't any promotions applied to this order item yet, then we can add this one
											if(!arrayLen(orderItem.getAppliedPromotions())) {
												addNew = true;
											// If one has already been set then we just need to check if this new discount amount is greater
											} else if ( orderItem.getAppliedPromotions()[1].getDiscountAmount() < discountAmount ) {
												
												// If the promotion is the same, then we just update the amount
												if(orderItem.getAppliedPromotions()[1].getPromotion().getPromotionID() == reward.getPromotionPeriod().getPromotion().getPromotionID()) {
													orderItem.getAppliedPromotions()[1].setDiscountAmount(discountAmount);
													
												// If the promotion is a different then remove the original and set addNew to true
												} else {
													orderItem.getAppliedPromotions()[1].removeOrderItem();
													addNew = true;
												}
												
											}
										}
										
										// Add the new appliedPromotion
										if(addNew) {
											var newAppliedPromotion = this.newPromotionApplied();
											newAppliedPromotion.setAppliedType('orderItem');
											newAppliedPromotion.setPromotion( reward.getPromotionPeriod().getPromotion() );
											newAppliedPromotion.setOrderItem( orderItem );
											newAppliedPromotion.setDiscountAmount( discountAmount );
										}
									}
								}
							}			
							break;
						// =============== Fulfillment Reward ======================
						case "fulfillment":
							// Loop over all the fulfillments
							for(var of=1; of<=arrayLen(arguments.order.getOrderFulfillments()); of++) {
								
								// Get this order Fulfillment
								var orderFulfillment = arguments.order.getOrderFulfillments()[of];
								
								if( ( !arrayLen(reward.getFulfillmentMethods()) || reward.hasFulfillmentMethod(orderFulfillment.getFulfillmentMethod()) ) 
									&&
									( !arrayLen(reward.getShippingMethods()) || (!isNull(orderFulfillment.getShippingMethod()) && reward.hasShippingMethod(orderFulfillment.getShippingMethod()) ) ) ) {
									
									var discountAmount = getDiscountAmount(reward, orderFulfillment.getFulfillmentCharge());
									
									var addNew = false;
										
									// First we make sure that the discountAmount is > 0 before we check if we should add more discount
									if(discountAmount > 0) {
										
										// If there aren't any promotions applied to this order fulfillment yet, then we can add this one
										if(!arrayLen(orderFulfillment.getAppliedPromotions())) {
											addNew = true;
											
										// If one has already been set then we just need to check if this new discount amount is greater
										} else if ( orderFulfillment.getAppliedPromotions()[1].getDiscountAmount() < discountAmount ) {
											
											// If the promotion is the same, then we just update the amount
											if(orderFulfillment.getAppliedPromotions()[1].getPromotion().getPromotionID() == reward.getPromotionPeriod().getPromotion().getPromotionID()) {
												orderFulfillment.getAppliedPromotions()[1].setDiscountAmount(discountAmount);
												
											// If the promotion is a different then remove the original and set addNew to true
											} else {
												orderFulfillment.getAppliedPromotions()[1].removeOrderFulfillment();
												addNew = true;
											}
										}
									}
									
									// Add the new appliedPromotion
									if(addNew) {
										var newAppliedPromotion = this.newPromotionApplied();
										newAppliedPromotion.setAppliedType('orderFulfillment');
										newAppliedPromotion.setPromotion( reward.getPromotionPeriod().getPromotion() );
										newAppliedPromotion.setOrderFulfillment( orderFulfillment );
										newAppliedPromotion.setDiscountAmount( discountAmount );
									}
								}
							}
							
							break;
						// ================== Order Reward =========================
						case "order":
						
							break;
					}
				}
			}
		}
		
		// Return & Exchange Orders
		if( listFindNoCase("otReturnOrder,otExchangeOrder", arguments.order.getOrderType().getSystemCode()) ) {
			
		}
		
	}
	
	private numeric function getDiscountAmount(required any reward, required any originalAmount) {
		var discountAmountPreRounding = 0;
		var discountAmount = 0;
		var roundedFinalAmount = 0;
		
		switch(reward.getAmountType()) {
			case "percentageOff" :
				discountAmountPreRounding = precisionEvaluate(arguments.originalAmount * (reward.getAmount()/100));
				break;
			case "amountOff" :
				discountAmountPreRounding = reward.getAmount();
				break;
			case "amount" :
				discountAmountPreRounding = precisionEvaluate(arguments.originalAmount - reward.getAmount());
				break;
		}
		
		if(!isNull(reward.getRoundingRule())) {
			roundedFinalAmount = getRoundingRuleService().roundValueByRoundingRule(value=precisionEvaluate(arguments.originalAmount - discountAmountPreRounding), roundingRule=reward.getRoundingRule());
			discountAmount = precisionEvaluate(arguments.originalAmount - roundedFinalAmount);
		} else {
			discountAmount = discountAmountPreRounding;
		}
		
		// This makes sure that the discount never exceeds the original amount
		if(discountAmountPreRounding > arguments.originalAmount) {
			discountAmount = arguments.originalAmount;
		}
		
		return numberFormat(discountAmount, "0.00");
	}
	
	public numeric function getPromotionRewardQualificationCount(required any promotionReward, required any order) {
		return 1;
	}
	
	
	public struct function getSalePriceDetailsForProductSkus(required string productID) {
		var priceDetails = getUtilityService().queryToStructOfStructures(getDAO().getSalePricePromotionRewardsQuery(productID = arguments.productID), "skuID");
		for(var key in priceDetails) {
			if(priceDetails[key].roundingRuleID != "") {
				priceDetails[key].salePrice = getRoundingRuleService().roundValueByRoundingRuleID(value=priceDetails[key].salePrice, roundingRuleID=priceDetails[key].roundingRuleID);
			}
		}
		return priceDetails;
	}
	
	public struct function getShippingMethodOptionsDiscountAmountDetails(required any shippingMethodOption) {
		var details = {
			promotionID="",
			discountAmount=0
		};
		
		var promotionRewards = getDAO().getActivePromotionRewards( rewardTypeList="fulfillment", promotionCodeList=arguments.shippingMethodOption.getOrderFulfillment().getOrder().getPromotionCodeList() );
		
		// Loop over the Promotion Rewards to look for the best discount
		for(var i=1; i<=arrayLen(promotionRewards); i++) {
			var qc = 1;
			
			// Check to see if this requires any promotion codes
			if(arrayLen(promotionRewards[i].getPromotionPeriod().getPromotion().getPromotionCodes())) {
				// set the qc to 0 so that we can then 
				qc = 0;
				
				// loop over the promotion codes looking for 
			}
		}
		
		
		return details;
	}
	
	// ----------------- END: Apply Promotion Logic -------------------------
		 
	/*
	  I needed a place to write down some notes about how applied promotions will be reset, and this is it.
	  Promotions applied on orderItem, fulfillment & order are easy because they can be calculated at the time of the order
	  However we also need to keep a table of promotions applied to products and customers so that on the listing page we can
	  query a discount amount to order by price
	  
	  So now we need a method to reset all of the discount amounts.
	  
	  public void function resetPromotionsAppled(string promotionID, string productTypeID, string productID, string skuID, string accountID) {
	  
	  		// Whichever of the arguments get passed in, we need to get the promotionID's that are effected by that item, and then re-call this method with that promotions ID
	  		
	  		// When this method is called with a promotionID, it will delete everything in the promotionsApplied table that is sku or sku + customer and recalculate the amount
	  }
	  
	*/
		
}
