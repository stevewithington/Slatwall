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
component persistent="false" accessors="true" output="false" extends="BaseController" {

	property name="accountService" type="any";
	property name="orderService" type="any";
	property name="userUtility" type="any";
	property name="paymentService" type="any";
	
	public any function init(required any fw) {
		setUserUtility( getCMSBean("userUtility") );
		
		return super.init(arguments.fw);
	}
	
	public void function create(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		if(!rc.account.isNew()){
			redirectToView();
		} else {
			prepareEditData(rc);
			getFW().setView("frontend:account.create");
		}
	}
	
	public void function edit(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		prepareEditData(rc);
		getFW().setView("frontend:account.edit");
	}
	
	public void function editLogin(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		prepareEditData(rc);
		getFW().setView("frontend:account.editlogin");
	}
	
	public void function prepareEditData(required struct rc) {
		rc.attributeSets = rc.account.getAttributeSets(["astAccount"]);
	}
	
	public void function save(required struct rc) {
		var wasNew = rc.$.slatwall.getCurrentAccount().isNew();
		var currentAction = "frontend:account.edit";
		if(wasNew){
			currentAction = "frontend:account.create";
		}
		rc.account = getAccountService().saveAccount(account=rc.$.slatwall.getCurrentAccount(), data=rc, siteID=rc.$.event('siteID'));
		if(rc.account.hasErrors()) {
			prepareEditData(rc);
			getFW().setView(currentAction);
		} else {
			redirectToView();
		}
	}
	
	public void function login(required struct rc) {
		param name="rc.username" default="";
		param name="rc.password" default="";
		param name="rc.returnURL" default="";
		param name="rc.forgotPasswordEmail" default="";
		
		if(rc.forgotPasswordEmail != "") {
			rc.forgotPasswordResult = getUserUtility().sendLoginByEmail(email=rc.forgotPasswordEmail, siteid=rc.$.event('siteID'));
		} else {
			var loginSuccess = getAccountService().loginCmsUser(username=rc.username, password=rc.password, siteID=rc.$.event('siteID'));
		
			if(!loginSuccess) {
				request.status = "failed";
			} else if ( len(rc.returnURL) > 3) {
				getFW().redirectExact(returnURL);
			}
			
		}
		
		getFW().setView("frontend:account.detail");
	}
	
	public void function listAddress(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		getFW().setView("frontend:account.listaddress");
	}
	
	public void function editAddress(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		rc.accountAddress = getAccountService().getAccountAddress(rc.accountAddressID);
		// make sure address belongs to this account
		if(rc.account.hasAccountAddress(rc.accountAddress)){
			getFW().setView("frontend:account.editaddress");
		} else {
			redirectToView();
		}
	}
	
	public void function saveAddress(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		rc.accountAddress = getAccountService().getAccountAddress(rc.accountAddressID);
		// make sure address belongs to this account
		if(rc.account.hasAccountAddress(rc.accountAddress) || rc.accountAddress.isNew()){
			rc.accountAddress.setAccount(rc.account);
			rc.accountAddress = getAccountService().saveAccountAddress(accountAddress=rc.accountAddress, data=rc);
			if(rc.accountAddress.hasErrors()) {
				getFW().setView("frontend:account.editaddress");
			} else {
				getFW().setView("frontend:account.listaddress");
			}
		} else {
			redirectToView();
		}
	}
	
	public void function listPaymentMethod(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		rc.paymentMethods = getPaymentService().listPaymentMethod();
		getFW().setView("frontend:account.listpaymentmethod");
	}
	
	public void function editPaymentMethod(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		rc.accountPaymentMethod = getAccountService().getAccountPaymentMethod(rc.accountPaymentMethodID);
		// make sure PaymentMethod belongs to this account
		if(rc.account.hasAccountPaymentMethod(rc.accountPaymentMethod)){
			getFW().setView("frontend:account.editpaymentmethod");
		} else {
			redirectToView();
		}
	}
	
	public void function createPaymentMethod(required struct rc) {
		// if no payment method ID passed redirect to overview
		if(rc.$.event("paymentMethodID") == ""){
			redirectToView();
		}
		rc.accountPaymentMethodID = "";
		rc.account = rc.$.slatwall.getCurrentAccount();
		rc.paymentMethod = getPaymentService().getPaymentMethod(rc.$.event("paymentMethodID"));
		rc.accountPaymentMethod = getAccountService().newAccountPaymentMethod();
		rc.accountPaymentMethod.setPaymentMethod(rc.paymentMethod);
		getFW().setView("frontend:account.editpaymentmethod");
	}
	
	public void function savePaymentMethod(required struct rc) {
		rc.account = rc.$.slatwall.getCurrentAccount();
		var paymentMethod = getPaymentService().getPaymentMethod(rc.$.event("paymentMethod.paymentMethodID"));
		rc.accountPaymentMethod = getAccountService().getAccountPaymentMethod(rc.accountPaymentMethodID, true);
		// make sure PaymentMethod belongs to this account
		if(rc.account.hasAccountPaymentMethod(rc.accountPaymentMethod) || rc.accountPaymentMethod.isNew()){
			rc.accountPaymentMethod.setAccount(rc.account);
			rc.accountPaymentMethod = getAccountService().saveAccountPaymentMethod(rc.accountPaymentMethod, rc);
			if(rc.accountPaymentMethod.hasErrors()) {
				getFW().setView("frontend:account.editpaymentmethod");
			} else {
				redirectToView("listpaymentmethod");
			}
		} else {
			redirectToView();
		}
	}
	
	private void function redirectToView(string view="") {
		if(view == ""){
			getFW().redirectExact("/my-account");
		} else {
			getFW().redirectExact("/my-account/?showitem=#arguments.view#");
		}
	}
	
	// Special account specific logic to require a user to be logged in
	public void function after(required struct rc) {
		if(!rc.$.currentUser().isLoggedIn() && rc.slatAction != "frontend:account.create" && rc.slatAction != "frontend:account.save" && rc.slatAction != "frontend:account.noaccess") {
			getFW().setView("frontend:account.login");
		}
	}
	
	public void function verifyEmail(required struct rc) {
		param name="rc.emailVerificationID" default="";
		param name="rc.returnURL" default="";
		
		var emailVerification = getAccountService().getEmailVerification(rc.emailVerificationID);
		
		if(!isNull(emailVerification) && !isNull(emailVerification.getAccountEmailAddress())) {
			emailVerification.getAccountEmailAddress().setVerifiedFlag( true );
		}
		
		if(rc.returnURL neq "") {
			getFW().redirectExact(rc.returnURL);
		}
	}
	
}
