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
component extends="BaseService" accessors="true" {
	property name="productService" type="any";
	
	public any function saveOption(required any entity, required struct data) {
		
		super.save(argumentcollection=arguments);
		
		if(!arguments.entity.hasErrors()) {
			// remove image if option is checked (unless a new image is set, in which case the old image is removed by processUpload
			if(structKeyExists(arguments.data,"removeImage") and arguments.entity.hasImage() and !structKeyExists(arguments.data,"imageUploadResult")) {
				removeImage(arguments.entity);
			}
			// process image if one was uploaded
			if(structKeyExists(arguments.data,"imageUploadResult")) {
				processImageUpload(arguments.entity,arguments.data.imageUploadResult);
			} 
		} else {
			// delete image if one was uploaded
			if(structKeyExists(arguments.data,"imageUploadResult")) {
				var result = arguments.data.imageUploadResult;
				var uploadPath = result.serverDirectory & "/" & result.serverFile;
				fileDelete(uploadPath);
			} 
		}
		
		return arguments.entity;
	}
	
	public any function saveOptionGroup(required any entity, required struct data) {
		
		// This also saves options that were passed in the correct format by using base object populate that will automatically call saveOption() in this service
		super.save(argumentcollection=arguments);
		
		// If this is a new option group then we need to set the sort order as the next in line
		if(isNull(arguments.entity.getSortOrder())) {
			arguments.entity.setSortOrder( getOptionGroupCount() + 1);
		}
		
		if(!arguments.entity.hasErrors()) {
			// remove image if option is checked (unless a new image is set, in which case the old image is removed by processUpload
			if(structKeyExists(arguments.data,"removeImage") and arguments.entity.hasImage() and !structKeyExists(arguments.data,"imageUploadResult")) {
				removeImage(arguments.entity);
			}
			// process image if one was uploaded
			if(structKeyExists(arguments.data,"imageUploadResult")) {
				processImageUpload(arguments.entity,arguments.data.imageUploadResult);
			} 
		} else {
			// delete image if one was uploaded
			if(structKeyExists(arguments.data,"imageUploadResult")) {
				var result = arguments.data.imageUploadResult;
				var uploadPath = result.serverDirectory & "/" & result.serverFile;
				fileDelete(uploadPath);
			} 
		}
		
		return arguments.entity;
	}
	
	public void function saveOptionSort(required string optionIDs) {
		for(var i=1; i<=listlen(arguments.optionIDs);i++) {
			var optionID = listGetAt(arguments.optionIDs,i);
			var thisOption = this.getOption(optionID);
			thisOption.setSortOrder(i);
		}
		
	}
	
	public void function saveOptionGroupSort(required string optionGroupIDs) {
		for(var i=1; i<=listlen(arguments.optionGroupIDs);i++) {
			var optionGroupID = listGetAt(arguments.optionGroupIDs,i);
			var thisOptionGroup = this.getOptionGroup(optionGroupID);
			thisOptionGroup.setSortOrder(i);
		}
	}
	
	public numeric function getOptionGroupCount() {
		return arrayLen(this.listOptionGroup());
	}
		
	private void function processImageUpload(required any entity, required struct imageUploadResult) {
		
		var imageName = createUUID() & "." & arguments.imageUploadResult.serverFileExt;
		var filePath = arguments.entity.getImageDirectory() & imageName;
		var imageSaved = getService("imageService").saveImage(uploadResult=arguments.imageUploadResult,filePath=filePath);
		if(imageSaved) {
			// if this was a new image where a pre-existing one existed for this object, delete the old image
			if(arguments.entity.hasImage()) {
				removeImage(arguments.entity);
			}
			if(arguments.entity.getClassName() == "SlatwallOption") {
				arguments.entity.setOptionImage(imageName);
			} else if(arguments.entity.getClassName() == "SlatwallOptionGroup") {
				arguments.entity.setOptionGroupImage(imageName);
			}
		}
	}
	
	public array function getMaximumOptionSortOrders() {
		return getDAO().getMaximumOptionSortOrders();
	}
	
	public array function getOptionsForSelect(required any options){
		var sortedOptions = [];
		
		for(i=1; i <= arrayLen(arguments.options); i++){
			arrayAppend(sortedOptions,{name=arguments.options[i].getOptionName(),value=arguments.options[i].getOptionID()});
		}
		
		return sortedOptions;
	}
	
	public array function getUnusedProductOptionGroups(required string productID){
		return getDAO().getUnusedProductOptionGroups(arguments.productID);
	}
	
	public array function getUnusedProductOptions(required string productID){
		return getDAO().getUnusedProductOptions(arguments.productID);
	}
}
