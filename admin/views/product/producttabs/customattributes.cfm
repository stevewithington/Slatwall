﻿<!---

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

All the field names are set in the format attribute.[attributeID].[attributeValueID]
AttributeValueID in the name is used to lookup the saved value and update. For new record
it is set to 0

--->

<cfset rc.attributeSets = rc.Product.getAttributeSets(["astProduct"]) />

<cfoutput>
	<cfset attributeValueIndex = 0 />
	<cfloop array="#rc.attributeSets#" index="local.attributeSet">
		<div id="tabCustomAttributes_#local.attributeSet.getAttributeSetID()#">
		<dl class="twoColumn">
		<cfloop array="#local.attributeSet.getAttributes()#" index="local.attribute">
			<cfset attributeValueIndex ++ />
			<cfif local.attribute.getActiveFlag()>
				<cfset local.attributeValue = rc.Product.getAttributeValue(local.attribute.getAttributeID(), true) />
				<dt>
					<label for="attribute.#local.attribute.getAttributeID()#">#local.attribute.getAttributeName()#<cfif local.attribute.getRequiredFlag() EQ 1> *</cfif></label>
				</dt>
				<dd>
					<cfif rc.edit>
						<input type="hidden" name="attributeValues[#attributeValueIndex#].attributeValueID" value="#local.attributeValue.getAttributeValueID()#" />
						<input type="hidden" name="attributeValues[#attributeValueIndex#].attribute.attributeID" value="#local.attribute.getAttributeID()#" />
						<cf_SlatwallFormField fieldName="attributeValues[#attributeValueIndex#].attributeValue" fieldType="#replace(local.attribute.getAttributeType().getSystemCode(), 'at', '', 'all')#" value="#local.attributeValue.getAttributeValue()#" valueOptions="#local.attribute.getAttributeOptionsOptions()#" />
					<cfelse>
						#local.attributeValue.getAttributeValue()#
					</cfif>
				</dd>
			</cfif>
		</cfloop>
		</dl>
		</div>
	</cfloop> 
</cfoutput>
