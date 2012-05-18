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

	property name="integrationService" type="any";
	property name="sessionService" type="any";
	property name="settingService" type="any";
	
	public boolean function processPayment(required any orderPayment, required string transactionType, required numeric transactionAmount, string providerTransactionID="") {
		// Lock down this determination so that the values getting called and set don't overlap
		lock scope="Session" timeout="45" {
			// Get the relavent info and objects for this order payment
			var processOK = false;
			var paymentMethod = arguments.orderPayment.getPaymentMethod();
			var providerService = getIntegrationService().getPaymentIntegrationCFC(paymentMethod.getIntegration());
			
			if(arguments.orderPayment.getPaymentMethodType() eq "creditCard") {
				// Chech if it's a duplicate transaction. Determination is made based on matching
				// transactionType and transactionAmount for this payment in last 60 sec.
				var isDuplicateTransaction = getDAO().isDuplicateCreditCardTransaction(orderPaymentID=arguments.orderPayment.getOrderPaymentID(),transactionType=arguments.transactionType,transactionAmount=arguments.transactionAmount);
				if(isDuplicateTransaction){
					processOK = true;
					arguments.orderPayment.addError('processing', "This transaction is duplicate of an already processed transaction.", true);
				} else {
					// Create a new Credit Card Transaction
					var transaction = this.newCreditCardTransaction();
					transaction.setTransactionType(arguments.transactionType);
					transaction.setOrderPayment(arguments.orderPayment);
					
					// Make sure that this transaction gets saved to the DB
					this.saveCreditCardTransaction(transaction);
					getDAO().flushORMSession();

					// Generate Process Request Bean
					var requestBean = new Slatwall.com.utility.payment.CreditCardTransactionRequestBean();
					
					// Move all of the info into the new request bean
					requestBean.populatePaymentInfoWithOrderPayment(arguments.orderPayment);
					
					requestBean.setTransactionID(transaction.getCreditCardTransactionID());
					requestBean.setTransactionType( arguments.transactionType );
					requestBean.setTransactionAmount( arguments.transactionAmount );
					requestBean.setProviderTransactionID( arguments.providerTransactionID );
					
					requestBean.setTransactionCurrency("USD"); // TODO: This is a hack that should be fixed at some point.  The currency needs to be more dynamic
					
					// Wrap in a try / catch so that the transaction will still get saved to the DB even in error
					try {
						
						// Get Response Bean from provider service
						logSlatwall("Payment Processing Request - Started", true);
						var response = providerService.processCreditCard(requestBean);
						logSlatwall("Payment Processing Request - Finished", true);
						
						// Populate the Credit Card Transaction with the details of this process
						transaction.setProviderTransactionID(response.getTransactionID());
						transaction.setAuthorizationCode(response.getAuthorizationCode());
						transaction.setAmountAuthorized(response.getAmountAuthorized());
						transaction.setAmountCharged(response.getAmountCharged());
						transaction.setAmountCredited(response.getAmountCredited());
						transaction.setAVSCode(response.getAVSCode());
						transaction.setStatusCode(response.getStatusCode());
						transaction.setMessage(serializeJSON(response.getMessages()));
											
						// Make sure that this transaction with all of it's info gets added to the DB
						ormFlush();
						
						if(!response.hasErrors()) {
							processOK = true;
						} else {
							// Populate the orderPayment with the processing error
							arguments.orderPayment.addError('processing', response.getAllErrorsHTML(), true);
						}
					} catch (any e) {
						// Populate the orderPayment with the processing error
						arguments.orderPayment.addError('processing', "An Unexpected Error Ocurred", true);
						
						// Log the exception
						logSlatwallException(e);
						
						rethrow;
					}
				}
			}
		}

		return processOK;
	}

	public string function getCreditCardTypeFromNumber(required string creditCardNumber) {
		if(isNumeric(arguments.creditCardNumber)) {
			var n = arguments.creditCardNumber;
			var l = len(trim(arguments.creditCardNumber));
			if( (l == 13 || l == 16) && left(n,1) == 4 ) {
				return 'Visa';
			} else if ( l == 16 && left(n,2) >= 51 && left(n,2) <= 55 ) {
				return 'MasterCard';
			} else if ( l == 16 && left(n,2) == 35 ) {
				return 'JCB';
			} else if ( l == 15 && (left(n,4) == 2014 || left(n,4) == 2149) ) {
				return 'EnRoute';
			} else if ( l == 16 && left(n,4) == 6011) {
				return 'Discover';
			} else if ( l == 14 && left(n,3) >= 300 && left(n,3) <= 305) {
				return 'CarteBlanche';
			} else if ( l == 14 && (left(n,2) == 30 || left(n,2) == 36 || left(n,2) == 38) ) {
				return 'Diners Club';
			} else if ( l == 15 && (left(n,2) == 34 || left(n,2) == 37) ) {
				return 'American Express';
			}
		}
		
		return 'Invalid';
	}
}