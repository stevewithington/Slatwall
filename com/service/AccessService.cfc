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
	
	public boolean function hasAccess(required any cmsContentID) {
		// make sure there is restricted content in the system before doing any check
		if(!getService("contentService").restrictedContentExists()) {
			return true;
		}
		// get restricted content by cmsContentID
		var restrictedContent = getService("contentService").getRestrictedContentBycmsContentID(arguments.cmsContentID);
		if(isNull(restrictedContent)) {
			return true;
		}
		// get the purchase required content
		var purchaseRequiredContentSetting = restrictedContent.getSettingDetails('contentRequirePurchaseFlag');
		if(purchaseRequiredContentSetting.settingValueFormatted) {
			if(structKeyExists(purchaseRequiredContentSetting, "settingRelationShips")) {
				var purchaseRequiredCmsContentID = purchaseRequiredContentSetting.settingRelationShips.cmsContentID;
			} else {
				var purchaseRequiredCmsContentID = restrictedContent.getCmsContentID();
			}
		} else {
			var purchaseRequiredCmsContentID = "";
		}
		// get the subscription required content
		var subscriptionRequiredContentSetting = restrictedContent.getSettingDetails('contentRequireSubscriptionFlag');
		if(subscriptionRequiredContentSetting.settingValueFormatted) {
			if(structKeyExists(subscriptionRequiredContentSetting, "settingRelationShips")) {
				var subscriptionRequiredCmsContentID = subscriptionRequiredContentSetting.settingRelationShips.cmsContentID;
			} else {
				var subscriptionRequiredCmsContentID = restrictedContent.getCmsContentID();
			}
		} else {
			var subscriptionRequiredCmsContentID = "";
		}
		var purchasedAccess = false;
		var subcriptionAccess = false;
		
		// check if purchase is allowed for restricted content
		if(!isNull(restrictedContent.getAllowPurchaseFlag()) && restrictedContent.getAllowPurchaseFlag()) {
			// check if the content was purchased
			var accountContentAccessSmartList = this.getAccountContentAccessSmartList();
			accountContentAccessSmartList.addFilter(propertyIdentifier="account_accountID", value=getSlatwallScope().getCurrentAccount().getAccountID());
			accountContentAccessSmartList.addFilter(propertyIdentifier="accessContents_contentID", value=restrictedContent.getContentID());
			if(accountContentAccessSmartList.getRecordsCount() && subscriptionRequiredCmsContentID == "") {
				logAccess(content=restrictedContent,accountContentAccess=accountContentAccessSmartList.getRecords()[1]);
				return true;
			} else if(accountContentAccessSmartList.getRecordsCount()) {
				purchasedAccess = true;
			}
			// check if the content is not allowed for purchase but requires purchase of parent
		} else if((isNull(restrictedContent.getAllowPurchaseFlag()) || !restrictedContent.getAllowPurchaseFlag()) && purchaseRequiredCmsContentID != "") {
			// check if any parent content was purchased
			var accountContentAccessSmartList = this.getAccountContentAccessSmartList();
			accountContentAccessSmartList.addFilter(propertyIdentifier="account_accountID", value=getSlatwallScope().getCurrentAccount().getAccountID());
			accountContentAccessSmartList.addFilter(propertyIdentifier="accessContents_cmsContentID", value=purchaseRequiredCmsContentID);
			// check if the content requires subcription in addition to purchase
			if(accountContentAccessSmartList.getRecordsCount() && subscriptionRequiredCmsContentID == "") {
				logAccess(content=restrictedContent,accountContentAccess=accountContentAccessSmartList.getRecords()[1]);
				return true;
			} else if(accountContentAccessSmartList.getRecordsCount()) {
				purchasedAccess = true;
			}
		}
		// check if restricted content is part of subscription access and doesn't require purchase or it does require purchased and was purchased
		if(purchaseRequiredCmsContentID == "" || purchasedAccess) {
			// check if content is part of subscription access
			for(var subscriptionUsageBenefitAccount in getSlatwallScope().getCurrentAccount().getSubscriptionUsageBenefitAccounts()) {
				if(subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit().getSubscriptionUsage().isActive() && subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit().hasContent(restrictedContent)) {
					logAccess(content=restrictedContent,subscriptionUsageBenefit=subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit());
					return true;
				}
			}
			
			// get all the cms categories assigned to the restricted content
			var cmsCategoryIDs = getService("contentService").getCmsCategoriesByCmsContentID(restrictedContent.getCmsContentID());;
			// check if any of this content's category is part of subscription access
			if(cmsCategoryIDs != "") {
				var categories = getService("contentService").getCategoriesByCmsCategoryIDs(cmsCategoryIDs);
				for(var subscriptionUsageBenefitAccount in getSlatwallScope().getCurrentAccount().getSubscriptionUsageBenefitAccounts()) {
					for(var category in categories) {
						if(subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit().getSubscriptionUsage().isActive() && subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit().hasCategory(category)) {
							logAccess(content=restrictedContent,subscriptionUsageBenefit=subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit());
							return true;
						}
					}
				}
			}
		}
		return false;
	}
	
	public void function logAccess(required any content) {
		var contentAccess = this.newContentAccess();
		contentAccess.setContent(arguments.content);
		contentAccess.setAccount(getSlatwallScope().getCurrentAccount());
		if(structKeyExists(arguments,"subscriptionUsageBenefit")) {
			contentAccess.setSubscriptionUsageBenefit(arguments.subscriptionUsageBenefit);
		} else if(structKeyExists(arguments,"accountContentAccess")) {
			contentAccess.setAccountContentAccess(arguments.accountContentAccess);
		}
		this.saveContentAccess(contentAccess);
	}
	
	public string function createAccessCode() {
		// TODO: access code generation
		
	}
	
}