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
	
	property name="sessionService" type="any";
	property name="priceGroupService" type="any";
	property name="validationService" type="any";
	
	// Mura Injection on Init
	property name="userManager" type="any";
	property name="userUtility" type="any";
	
	public any function init() {
		setUserManager( getCMSBean("userManager") );
		setUserUtility( getCMSBean("userUtility") );
		variables.permissions = '';
		
		return super.init();
	}
	
	public boolean function loginCmsUser(required string username, required string password, required string siteID) {
		var loginResult = getUserUtility().login(username=arguments.username, password=arguments.password, siteID=arguments.siteID);
		
		if(loginResult) {
			getSlatwallScope().setCurrentSession(javaCast("null", ""));
		}
		
		return loginResult;
	}
	
	public any function saveAccountByCmsUser(required any cmsUser) {
		
		// Load Account based upon the logged in cmsAccountID
		var account = this.getAccountByCMSAccountID(arguments.cmsUser.getUserID());
		
		if( isnull(account) ) {
			// TODO: Check to see if the e-mail exists and is assigned to an account.   If it does we should update that account with this cms user id.
			
			// Create new Account
			account = this.newAccount();
			
			// Link account to thus mura user
			account.setCmsAccountID(arguments.cmsUser.getUserID());
			
			// update and save with values from cms user
			account = updateAccountFromCmsUser(account, arguments.cmsUser);
			getDAO().save(target=account);
		
		} else {
			// Update the existing account 
			account = updateAccountFromCmsUser(account, arguments.cmsUser);	
		}
		
		return account;
	}
	
	public any function saveAccount(required any account, required struct data, required string siteID=request.muraScope.event('siteID')) {
		
		var wasNew = arguments.account.isNew();
		
		// Call the super.save() to do population and validation
		arguments.account = super.save(entity=arguments.account, data=arguments.data);
		
		// Account Email
		if( structKeyExists(arguments.data, "emailAddress") ) {
			
			// Setup Email Address
			var accountEmailAddress = arguments.account.getPrimaryEmailAddress();
			accountEmailAddress.populate(arguments.data);
			accountEmailAddress.setAccount(arguments.account);
			arguments.account.setPrimaryEmailAddress(accountEmailAddress);
			
			// Validate This Object
			accountEmailAddress.validate();
			if(accountEmailAddress.hasErrors()) {
				getSlatwallScope().setORMHasErrors( true );
				arguments.account.addError("emailAddress", "The Email address has errors");
			}

		}

		// Account Phone Number, not required - how to set only if required by account? 
		if( structKeyExists(arguments.data, "phoneNumber") && arguments.data.phoneNumber != "") {
			
			// Setup Phone Number
			var accountPhoneNumber = arguments.account.getPrimaryPhoneNumber();
			accountPhoneNumber.populate(arguments.data);
			accountPhoneNumber.setAccount(arguments.account);
			arguments.account.setPrimaryPhoneNumber(accountPhoneNumber);
			
			// Validate This Object
			accountPhoneNumber.validate();
			if(accountPhoneNumber.hasErrors()) {
				getSlatwallScope().setORMHasErrors( true );
				arguments.account.addError("phoneNumber", "The Phone Number has errors");
			}
		}
		
		// Account address
		if(structKeyExists(arguments.data, "primaryAddress")) {
			// Setup Account Address
			var accountAddress = arguments.account.getPrimaryAddress();
			accountAddress.populate(arguments.data.primaryAddress);
			accountAddress.setAccount(arguments.account);
			arguments.account.setPrimaryAddress(accountAddress);

			// Validate Address
			accountAddress.getAddress().validate();
			if(accountAddress.getAddress().hasErrors()) {
				getSlatwallScope().setORMHasErrors( true );
			}
		}
		
		// if there is no error and access code or link is passed then validate it
		if(!arguments.account.hasErrors() && structKeyExists(arguments.data,"access")) {
			var subscriptionUsageBenefitAccountCreated = false;
			if(structKeyExists(arguments.data.access,"accessID")) {
				var access = getService("accessService").getAccess(arguments.data.access.accessID);
			} else if(structKeyExists(arguments.data.access,"accessCode")) {
				var access = getService("accessService").getAccessByAccessCode(arguments.data.access.accessCode);
			} 
			if(isNull(access)) {
				//return access code error
				getSlatwallScope().setORMHasErrors( true );
				arguments.account.addError("access", "The access code you provided is invalid.");
			}
		}
		
		
		// If the account doesn't have errors, is new, has and email address and password, has a password passed in, and not supposed to be a guest account. then attempt to setup the username and password in Mura
		if( !arguments.account.hasErrors() && wasNew && !isNull(arguments.account.getPrimaryEmailAddress()) && structKeyExists(arguments.data, "password") && (!structKeyExists(arguments.data, "guestAccount") || arguments.data.guestAccount == false) ) {
			
			// Try to get the user out of the mura database using the primaryEmail as the username
			var cmsUser = getUserManager().getBean().loadBy(siteID=arguments.siteID, username=arguments.account.getPrimaryEmailAddress().getEmailAddress());
			
			if(!cmsUser.getIsNew()) {
				getSlatwallScope().setORMHasErrors( true );
				arguments.account.addError("emailAddress", "This E-Mail Address is already in use with another Account.");
				// make sure password is entered 
			} else if(!len(trim(arguments.data.password))) {
				getSlatwallScope().setORMHasErrors( true );
				arguments.account.addError("password", "The field Password is required.");
			} else {
				// Setup a new mura user
				cmsUser.setUsername(arguments.account.getPrimaryEmailAddress().getEmailAddress());
				cmsUser.setPassword(arguments.data.password);
				cmsUser.setSiteID(arguments.siteID);
				
				// Update mura user with values from account
				cmsUser = updateCmsUserFromAccount(cmsUser, arguments.account);
				cmsUser = cmsUser.save();
				
				// check if there was any validation error during cms user save
				if(structIsEmpty(cmsUser.getErrors())) {
					// Set the mura userID in the account
					arguments.account.setCmsAccountID(cmsUser.getUserID());
										
					// If there currently isn't a user logged in, then log in this new account
					var currentUser = request.muraScope.currentUser();
					if(!currentUser.isLoggedIn()) {
						// Login the mura User
						getUserUtility().loginByUserID(cmsUser.getUserID(), arguments.siteID);
						// Set the account in the session scope
						getSlatwallScope().getCurrentSession().setAccount(arguments.account);
					}
				} else {
					getSlatwallScope().setORMHasErrors( true );
					// add all the cms errors
					for(var error in cmsUser.getErrors()) {
						arguments.account.addError(error, cmsUser.getErrors()[error]);
						arguments.account.addError("CMSError", cmsUser.getErrors()[error]);
					}
				}
			}
		}
		
		// If the account isn't new, and it has a cmsAccountID then update the mura user from the account
		if(!wasNew && !isNull(arguments.account.getCmsAccountID())) {
			
			// Load existing mura user
			var cmsUser = getUserManager().read(userID=arguments.account.getCmsAccountID());
			
			// If that user exists, update from account and save
			if(!cmsUser.getIsNew()) {
				cmsUser = updateCmsUserFromAccount(cmsUser, arguments.account);
				
				// If a pasword was passed in, then update the mura accout with the new password
				if(structKeyExists(arguments.data, "password")) {
					cmsUser.setPassword(arguments.data.password);
				// If a password wasn't submitted then just set the value to blank so that mura doesn't re-hash the password	
				} else {
					cmsUser.setPassword("");	
				}
				
				cmsUser = cmsUser.save();
				
				// check if there was any validation error during cms user save
				if(!structIsEmpty(cmsUser.getErrors())) {
					getSlatwallScope().setORMHasErrors( true );
					// add all the cms errors
					for(var error in cmsUser.getErrors()) {
						arguments.account.addError(error, cmsUser.getErrors()[error]);
						arguments.account.addError("CMSError", cmsUser.getErrors()[error]);
					}
				}
			}
			
			// If the current user is the one whos account was just updated then Re-Login the current user so that the new values are saved.
			var currentUser = request.muraScope.currentUser();
			if(currentUser.getUserID() == cmsUser.getUserID()) {
				getUserUtility().loginByUserID(cmsUser.getUserID(), arguments.siteID);	
			}
		}
		
		// if all validation passed and setup accounts subscription benefits based on access 
		if(!arguments.account.hasErrors() && !isNull(access)) {
			subscriptionUsageBenefitAccountCreated = getService("subscriptionService").createSubscriptionUsageBenefitAccountByAccess(access, arguments.account);
		}

		return arguments.account;
	}
	
	public any function updateCmsUserFromAccount(required any cmsUser, required any Account) {
		
		// Sync Name & Company
		arguments.cmsUser.setFName(arguments.account.getFirstName());
		arguments.cmsUser.setLName(arguments.account.getLastName());
		if(!isNull(arguments.account.getCompany())) {
			arguments.cmsUser.setCompany(arguments.account.getCompany());	
		}
		
		// Sync Primary Email
		if(!isNull(arguments.account.getPrimaryEmailAddress())) {
			arguments.cmsUser.setEmail(arguments.account.getPrimaryEmailAddress().getEmailAddress());	
		}
		
		// Reset the password as whatever was already in the database
		
		// TODO: Sync the mobile phone number
		// TODO: Loop over addresses and sync them as well.
				
		return arguments.cmsUser;
	}
	
	public any function updateAccountFromCmsUser(required any account, required any cmsUser) {
		
		// Sync Name & Company
		if(arguments.account.getFirstName() != cmsUser.getFName()){
			arguments.account.setFirstName(cmsUser.getFName());
		}
		if(arguments.account.getLastName() != cmsUser.getLName()) {
			arguments.account.setLastName(cmsUser.getLName());
		}
		if(arguments.account.getCompany() != cmsUser.getCompany()) {
			arguments.account.setCompany(cmsUser.getCompany());
		}
		
		// Sync the primary email if out of sync
		if( isNull(arguments.account.getPrimaryEmailAddress()) || arguments.account.getPrimaryEmailAddress().getEmailAddress() != arguments.cmsUser.getEmail()) {
			// Setup the new primary email object
			
			// Attempt to find that e-mail address in all of our emails
			for(var i=1; i<=arrayLen(arguments.account.getAccountEmailAddresses()); i++) {
				if(arguments.account.getAccountEmailAddresses()[i].getEmailAddress() == arguments.cmsUser.getEmail()) {
					var primaryEmail = arguments.account.getAccountEmailAddresses()[i];
				}
			}
			if( isNull(primaryEmail) ) {
				var primaryEmail = this.newAccountEmailAddress();
				primaryEmail.setEmailAddress(arguments.cmsUser.getEmail());
				primaryEmail.setAccount(arguments.account);
			}
			arguments.account.setPrimaryEmailAddress(primaryEmail);
		}
		
		// TODO: Sync the mobile phone number
		// TODO: Loop over addresses and set those up as well.
		
		return arguments.account;
	}
	
	public any function getAccountSmartList(struct data={}, currentURL="") {
		arguments.entityName = "SlatwallAccount";
		
		var smartList = getDAO().getSmartList(argumentCollection=arguments);
		
		smartList.addKeywordProperty(propertyIdentifier="firstName", weight=3);
		smartList.addKeywordProperty(propertyIdentifier="lastName", weight=3);
		
		return smartList;
	}
	
	public boolean function deleteAccount(required any account) {
	
		// Set the primary fields temporarily in the local scope so we can reset if delete fails
		var primaryEmailAddress = arguments.account.getPrimaryEmailAddress();
		var primaryPhoneNumber = arguments.account.getPrimaryPhoneNumber();
		var primaryAddress = arguments.account.getPrimaryAddress();
		
		// Remove the primary fields so that we can delete this entity
		arguments.account.setPrimaryEmailAddress(javaCast("null", ""));
		arguments.account.setPrimaryPhoneNumber(javaCast("null", ""));
		arguments.account.setPrimaryAddress(javaCast("null", ""));
	
		// Use the base delete method to check validation
		var deleteOK = super.delete(arguments.account);
		
		// If the delete failed, then we just reset the primary fields in account and return false
		if(!deleteOK) {
			arguments.account.setPrimaryEmailAddress(primaryEmailAddress);
			arguments.account.setPrimaryPhoneNumber(primaryPhoneNumber);
			arguments.account.setPrimaryAddress(primaryAddress);
		
			return false;
		}
	
		return true;
	}
	
}
