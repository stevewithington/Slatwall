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
component extends="BaseController" output="false" accessors="true" {
	
	// Slatwall Service Injection		
	property name="addressService" type="any";
	property name="attributeService" type="any";
	property name="settingService" type="any";
	property name="scheduleService" type="any";
	property name="productCacheService" type="any";
	property name="updateService" type="any";
	property name="utilityFileService" type="any";
	property name="measurementUnitService" type="any";
	
	this.publicMethods='';
	this.secureMethods = 'listsetting,detailsetting,editsetting,listfulfillmentmethod,editfulfillmentmethod,detailfulfillmentmethod,deletefulfillmentmethod,createfulfillmentmethod,listmeasurementunit,editmeasurementunit,detailmeasurementunit,createmeasurementunit,deletemeasurementunit,listorderorigin,createorderorigin,deleteorderorigin,editorderorigin,detailorderorigin,listpaymentmethod,editpaymentmethod,detailpaymentmethod,createpaymentmethod,deletepaymentmethod,listroundingrule,editroundingrule,detailroundingrule,createroundingrule,deleteroundingrule,listtaxcategory,edittaxcategory,detailtaxcategory,createtaxcategory,deletetaxcategory,listterm,detailterm,editterm,createterm,deleteterm,listType,editType,detailType,createType,deleteType,listLocation,editlocation,detaillocation,createlocation,deletelocation,listaddresszone,editaddresszone,detailaddresszone,createaddresszone,deleteaddresszone,listcountry,editcountry,detailcountry,createcountry,deletecountry,listattributeset,editattributeset,detailattributeset,createattributeset,deleteattributeset,createcategory,detailcategory,editcategory,deletecategory,listcategory,editcontent,detailcontent,createcontent,deletecontent,listschedule,editschedule,detailschedule,createschedule,deleteschedule,listtask,edittask,detailtask,createtask,deletetask,listtaskhistory,saveaddresszone,saveattributeset,savecategory,savecountry,savefulfillmentmethod,saveLocation,saveorderorigin,savepaymentmethod,saveroundingrule,saveschedule,savesetting,savetask,savetaskhistory,savetaxcategory,saveterm,saveType,savemeasurementunit';
	
	public void function default() {
		getFW().redirect(action="admin:setting.listsetting");
	}
	
	public void function createAddressZoneLocation(required struct rc) {
		editAddressZoneLocation(rc);
	}
	
	public void function editAddressZoneLocation(required struct rc) {
		param name="rc.addressZoneID" default="";
		param name="rc.addressID" default="";
		
		rc.addressZoneLocation = getAddressService().getAddress( rc.addressID, true );
		rc.addressZone = getAddressService().getAddressZone( rc.addressZoneID );
		rc.edit=true;
		
		getFW().setView("admin:setting.detailaddresszoneLocation");
	}
	
	public void function deleteAddressZoneLocation(required struct rc) {
		param name="rc.addressZoneID" default="";
		param name="rc.addressID" default="";
		
		rc.addressZoneLocation = getAddressService().getAddress( rc.addressID, true );
		rc.addressZone = getAddressService().getAddressZone( rc.addressZoneID );
		
		rc.addressZone.removeAddressZoneLocation( rc.addressZoneLocation );
		
		getFW().redirect(action="admin:setting.detailaddresszone", queryString="addressZoneID=#rc.addressZoneID#&messageKeys=admin.setting.deleteaddresszonelocation_success");
	}
	
	public void function createAccountAttributeSet( required struct rc ) {    
		param name="rc.attributeSetID" default="";
		
		rc.attributeSet = getAttributeService().getAttributeSet( rc.attributeSetID, true );
		var asType = getService("typeService").getTypeBySystemCode( "astAccount" );
		rc.attributeSet.setAttributeSetType( asType );
		rc.edit = true;
		rc.listAction = "admin:setting.listattributeset"; 
		rc.saveAction = "admin:setting.saveattributeset";
		rc.cancelAction = "admin:setting.listattributeset";
		getFW().setView( "admin:setting.detailattributeset" );
	}
	
	public void function createProductAttributeSet( required struct rc ) {    
		param name="rc.attributeSetID" default="";
		
		rc.attributeSet = getAttributeService().getAttributeSet( rc.attributeSetID, true );
		var asType = getService("typeService").getTypeBySystemCode( "astProduct" );
		rc.attributeSet.setAttributeSetType( asType );
		rc.edit = true;
		rc.listAction = "admin:setting.listattributeset"; 
		rc.saveAction = "admin:setting.saveattributeset";
		rc.cancelAction = "admin:setting.listattributeset";
		getFW().setView( "admin:setting.detailattributeset" );
	}

	public void function createProductCustomizationAttributeSet( required struct rc ) {    
		param name="rc.attributeSetID" default="";
		
		rc.attributeSet = getAttributeService().getAttributeSet( rc.attributeSetID, true );
		var asType = getService("typeService").getTypeBySystemCode( "astProductCustomization" );
		rc.attributeSet.setAttributeSetType( asType );
		rc.edit = true;
		rc.listAction = "admin:setting.listattributeset"; 
		rc.saveAction = "admin:setting.saveattributeset";
		rc.cancelAction = "admin:setting.listattributeset";
		getFW().setView( "admin:setting.detailattributeset" );
	}

	// Frontend Views
	public void function updateFrontendViews(required struct rc) {
		
		var baseSlatwallPath = getDirectoryFromPath(expandPath("/muraWRM/plugins/Slatwall/frontend/views/")); 
		var baseSitePath = getDirectoryFromPath(expandPath("/muraWRM/#rc.siteid#/includes/display_objects/custom/slatwall/"));

		getUtilityFileService().duplicateDirectory(baseSlatwallPath,baseSitePath,true,true,".svn");
		getFW().redirect(action="admin:main");
	}
	
	// slatwall update
	public void function detailSlatwallUpdate(required struct rc) {

		var versions = getUpdateService().getAvailableVersions();
		rc.availableDevelopVersion = versions.develop;
		rc.availableMasterVersion = versions.master;

		rc.currentVersion = getFW().getValue('SlatwallVersion');
		if(find("-", rc.currentVersion)) {
			rc.currentBranch = "develop";
		} else {
			rc.currentBranch = "master";
		}

	}

	public void function updateSlatwall(required struct rc) {
		getUpdateService().update(branch=rc.updateBranch);
		getFW().redirect(action="admin:setting.detailslatwallupdate", queryString="reload=1&messageKeys=admin.setting.updateslatwall_success");	
	}

	public void function detailViewUpdate() {
		// Do Nothing
	}
	
	public void function saveTask(required struct rc){
		
		rc.runningFlag=false;
		
		super.genericSaveMethod('Task',rc);
	}
	
	public void function saveTaskSchedule(required struct rc){
		
		rc.nextRunDateTime = getScheduleService().getSchedule(rc.schedule.scheduleid).getNextRunDateTime(rc.startDateTime,rc.endDateTime); 	
		
		super.genericSaveMethod('TaskSchedule',rc);
	}
	
	public void function editSetting(required struct rc) {
		rc.setting = getSettingService().getSetting(rc.settingID, true);
		rc.edit = true;
		getFW().setView("admin:setting.detailsetting");
	}
	
	public void function editMeasurementUnit(required struct rc) {
		rc.measurementUnit = getMeasurementUnitService().getMeasurementUnit(rc.unitCode);
		rc.edit = true;
		getFW().setView("admin:setting.detailmeasurementunit");
	}
	
	public void function editCountry(required struct rc) {
		rc.country = getAddressService().getCountry(rc.countryCode);
		rc.edit = true;
		getFW().setView("admin:setting.detailcountry");
	}
	
}
