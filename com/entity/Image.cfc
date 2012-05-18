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
component displayname="Image" entityname="SlatwallImage" table="SlatwallImage" persistent="true" extends="BaseEntity" discriminatorColumn="directory" {
			
	// Persistent Properties
	property name="imageID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="imageName" ormtype="string";
	property name="imageDescription" ormtype="string" length="4000";
	property name="imageExtension" ormtype="string";
	property name="imageFile" ormtype="string";
	
	// Related entity properties
	property name="imageType" cfc="Type" fieldtype="many-to-one" fkcolumn="imageTypeID";
	
	// Special helper property
	property name="directory" insert="false" update="false";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	public string function getImagePath() {
		return "#request.muraScope.siteConfig().getAssetPath()#/assets/Image/Slatwall/#getDirectory()#/#getImageID()#.#getImageExtension()#";
	}
	
	public string function getImageDirectory(){
		return "#request.muraScope.siteConfig().getAssetPath()#/assets/Image/Slatwall/#getDirectory()#/";	
	}
	
	public string function getResizedImagePath(numeric width=0, numeric height=0, string resizeMethod="scale", string cropLocation="",numeric cropXStart=0, numeric cropYStart=0,numeric scaleWidth=0,numeric scaleHeight=0) {
		arguments.imagePath = getImagePath();
		return getService("imageService").getResizedImagePath(argumentCollection=arguments);
	}
	
	public string function getImage(string size, numeric width=0, numeric height=0, string alt="", string class="", string resizeMethod="scale", string cropLocation="",numeric cropXStart=0, numeric cropYStart=0,numeric scaleWidth=0,numeric scaleHeight=0) {
		// Get the expected Image Path
		var path=getImagePath();
		
		// If no image Exists use the defult missing image 
		if(!fileExists(expandPath(path))) {
			path = setting('globalMissingImagePath');
		}
		
		// If there were sizes specified, get the resized image path
		if(arguments.width != 0 || arguments.height != 0) {
			arguments.imagePath=path;
			path = getResizedImagePath(argumentcollection=arguments);	
		}
		
		// Read the Image
		var img = imageRead(expandPath(path));
		
		// Setup Alt & Class for the image
		if(arguments.alt == "" && len(getImageName())) {
			arguments.alt = "#getImageName()#";
		}
		if(arguments.class == "") {
			arguments.class = "productImage";	
		}
		return '<img src="#path#" width="#imageGetWidth(img)#" height="#imageGetHeight(img)#" alt="#arguments.alt#" class="#arguments.class#" />';
	}
	
	public array function getImageTypeOptions() {
		if(!structKeyExists(variables, "imageTypeOptions")) {
			var smartList = new Slatwall.com.utility.SmartList(entityName="SlatwallType");
			smartList.addSelect(propertyIdentifier="type", alias="name");
			smartList.addSelect(propertyIdentifier="typeID", alias="value");
			smartList.addFilter(propertyIdentifier="parentType_systemCode", value="itProduct");
			smartList.addOrder("type|ASC");
			
			variables.imageTypeOptions = smartList.getRecords();
		}
		return variables.imageTypeOptions;
	}
	
	// ============ START: Non-Persistent Property Methods =================
	
	// ============  END:  Non-Persistent Property Methods =================
	
	// ============= START: Bidirectional Helper Methods ===================
	
	// =============  END:  Bidirectional Helper Methods ===================
	
	// ================== START: Overridden Methods ========================
	
	// ==================  END:  Overridden Methods ========================
		
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
}