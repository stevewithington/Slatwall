<!---

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

--->
<cfif thisTag.executionMode is "end">
	<cfparam name="thistag.settings" type="array" default="#arrayNew(1)#" />
	<cfparam name="thistag.hasInheritedValues" type="boolean" default="false" />
	
	<cfsilent>
		<cfloop array="#thistag.settings#" index="thisSetting">
			<cfif thisSetting.settingDetails.settingInherited>
				<cfset thistag.hasInheritedValues = true />
				<cfbreak />
			</cfif>
		</cfloop>
	</cfsilent>
	<cfoutput>
		<table class="table table-striped table-bordered table-condensed">
			<tr>
				<th class="primary">#request.slatwallScope.rbKey('entity.setting.settingName')#</th>
				<th>#request.slatwallScope.rbKey('entity.setting.settingValue')#</th>
				<cfif thistag.hasInheritedValues>
					<th>#request.slatwallScope.rbKey('define.inheritance')#</th>
				</cfif>
				<th>&nbsp;</th>
			</tr>
			<cfloop array="#thistag.settings#" index="thisSetting">
				<tr>
					<td class="primary">
						#thisSetting.settingDisplayName# <cfif len(thisSetting.settingHint)><a href="##" rel="tooltip" class="hint" title="#thisSetting.settingHint#"><i class="icon-question-sign"></i></a></cfif>
					</td>
					<td>
						#thisSetting.settingDetails.settingValueFormatted#
					</td>
					<cfif thistag.hasInheritedValues>
						<td>
							<cfif thisSetting.settingDetails.settingInherited>
								<cfif !structCount(thisSetting.settingDetails.settingRelationships)>
									<cf_SlatwallActionCaller action="admin:setting.settings" text="#request.slatwallScope.rbKey('define.global')#"/>
								<cfelse>
									<cfif structCount(thisSetting.settingDetails.settingRelationships) eq 1>
										<cfif structKeyList(thisSetting.settingDetails.settingRelationships) eq "productTypeID">
											<cfset local.productType = request.slatwallScope.getService("productService").getProductType(thisSetting.settingDetails.settingRelationships.productTypeID) />
											<cf_SlatwallActionCaller action="admin:product.detailProductType" text="#local.productType.getSimpleRepresentation()#" queryString="productTypeID=#thisSetting.settingDetails.settingRelationships.productTypeID#">
										</cfif>
									</cfif>
								</cfif>
							<cfelse>
								#request.slatwallScope.rbKey('define.here')#
							</cfif>
						</td>
					</cfif>
					<td class="admin admin1">
						<cfif thisSetting.settingDetails.settingInherited>
							<cfif isObject(thisSetting.settingObject)>
								<cf_SlatwallActionCaller action="admin:setting.editsetting" queryString="settingID=&returnAction=#request.context.slatAction#&settingName=#thisSetting.settingName#&#thisSetting.settingObject.getPrimaryIDPropertyName()#=#thisSetting.settingObject.getPrimaryIDValue()#" class="btn btn-mini" icon="pencil" iconOnly="true" modal="true" />
							<cfelse>
								<cf_SlatwallActionCaller action="admin:setting.editsetting" queryString="settingID=&returnAction=#request.context.slatAction#&settingName=#thisSetting.settingName#" class="btn btn-mini" icon="pencil" iconOnly="true" modal="true" />
							</cfif>
						<cfelse>
							<cfif isObject(thisSetting.settingObject)>
								<cf_SlatwallActionCaller action="admin:setting.editsetting" queryString="settingID=#thisSetting.settingDetails.settingID#&returnAction=#request.context.slatAction#&settingName=#thisSetting.settingName#&#thisSetting.settingObject.getPrimaryIDPropertyName()#=#thisSetting.settingObject.getPrimaryIDValue()#" class="btn btn-mini" icon="pencil" iconOnly="true" modal="true" />
							<cfelse>
								<cf_SlatwallActionCaller action="admin:setting.editsetting" queryString="settingID=#thisSetting.settingDetails.settingID#&returnAction=#request.context.slatAction#&settingName=#thisSetting.settingName#" class="btn btn-mini" icon="pencil" iconOnly="true" modal="true" />
							</cfif>
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>