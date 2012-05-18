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
<cfif thisTag.executionMode eq "end">
	<!--- Required --->
	<cfparam name="attributes.smartList" type="any" />
	<cfparam name="attributes.edit" type="boolean" default="false" />
	
	<!--- Admin Actions --->
	<cfparam name="attributes.recordEditAction" type="string" default="" />
	<cfparam name="attributes.recordEditQueryString" type="string" default="" />
	<cfparam name="attributes.recordEditModal" type="boolean" default="false" />
	<cfparam name="attributes.recordDetailAction" type="string" default="" />
	<cfparam name="attributes.recordDetailQueryString" type="string" default="" />
	<cfparam name="attributes.recordDetailModal" type="boolean" default="false" />
	<cfparam name="attributes.recordDeleteAction" type="string" default="" />
	<cfparam name="attributes.recordDeleteQueryString" type="string" default="" />
	<cfparam name="attributes.recordProcessAction" type="string" default="" />
	<cfparam name="attributes.recordProcessQueryString" type="string" default="" />
	<cfparam name="attributes.recordProcessModal" type="boolean" default="false" />

	<!--- Hierarchy Expandable --->
	<cfparam name="attributes.parentPropertyName" type="string" default="" />  <!--- Setting this value will turn on Expanable --->
	<cfparam name="attributes.expandAction" type="string" default="#request.context.slatAction#" />  
	
	<!--- Sorting --->
	<cfparam name="attributes.sortProperty" type="string" default="" />  <!--- Setting this value will turn on Sorting --->
	
	<!--- Single Select --->
	<cfparam name="attributes.selectFieldName" type="string" default="" />			<!--- Setting this value will turn on single Select --->
	<cfparam name="attributes.selectValue" type="string" default="" />
	
	<!--- Multiselect --->
	<cfparam name="attributes.multiselectFieldName" type="string" default="" />		<!--- Setting this value will turn on Multiselect --->
	<cfparam name="attributes.multiselectValues" type="string" default="" />
	
	<!--- Helper / Additional / Custom --->
	<cfparam name="attributes.tableattributes" type="string" default="" />  <!--- Pass in additional html attributes for the table --->
	<cfparam name="attributes.tableclass" type="string" default="" />  <!--- Pass in additional classes for the table --->	
	<cfparam name="attributes.adminattributes" type="string" default="" />
	
	<!--- ThisTag Variables used just inside --->
	<cfparam name="thistag.columns" type="array" default="#arrayNew(1)#" />
	<cfparam name="thistag.allpropertyidentifiers" type="string" default="" />
	<cfparam name="thistag.selectable" type="string" default="false" />
	<cfparam name="thistag.multiselectable" type="string" default="false" />
	<cfparam name="thistag.expandable" type="string" default="false" />
	<cfparam name="thistag.sortable" type="string" default="false" />
	<cfparam name="thistag.exampleEntity" type="string" default="" />

	<cfsilent>
		<cfif isSimpleValue(attributes.smartList)>
			<cfset attributes.smartList = request.slatwallScope.getService("utilityORMService").getServiceByEntityName( attributes.smartList ).invokeMethod("get#attributes.smartList#SmartList") />
		</cfif>
		
		<!--- Setup the example entity --->
		<cfset thistag.exampleEntity = createObject("component", "Slatwall.com.entity.#replace(attributes.smartList.getBaseEntityName(), 'Slatwall', '')#") />
		
		<!--- Setup the default table class --->
		<cfset attributes.tableclass = listPrepend(attributes.tableclass, 'table table-striped table-bordered table-condensed', ' ') />
		
		<!--- Setup Select --->
		<cfif len(attributes.selectFieldName)>
			<cfset thistag.selectable = true />
			
			<cfset attributes.tableclass = listAppend(attributes.tableclass, 'table-select', ' ') />
			<cfset attributes.tableattributes = listAppend(attributes.tableattributes, 'data-selectfield="#attributes.selectFieldName#"', " ") />
		</cfif>
		
		<!--- Setup Multiselect --->
		<cfif len(attributes.multiselectFieldName)>
			<cfset thistag.multiselectable = true />
			
			<cfset attributes.tableclass = listAppend(attributes.tableclass, 'table-multiselect', ' ') />
			
			<cfset attributes.tableattributes = listAppend(attributes.tableattributes, 'data-multiselectfield="#attributes.multiselectFieldName#"', " ") />
		</cfif>
		
		<!--- Setup Hierarchy Expandable --->
		<cfif len(attributes.parentPropertyName)>
			<cfset thistag.expandable = true />
			
			<cfset attributes.tableclass = listAppend(attributes.tableclass, 'table-expandable', ' ') />
			
			<cfset attributes.tableattributes = listAppend(attributes.tableattributes, 'data-expandaction="#attributes.expandAction#"', " ") />
			<cfset attributes.tableattributes = listAppend(attributes.tableattributes, 'data-parentidproperty="#attributes.parentPropertyName#.#thistag.exampleEntity.getPrimaryIDPropertyName()#"', " ") />
			
		</cfif>
		
		<!--- Setup Sortability --->
		<cfif len(attributes.sortProperty)>
			<cfif not arrayLen(attributes.smartList.getOrders())>
				<cfset thistag.sortable = true />
				
				<cfset attributes.tableclass = listAppend(attributes.tableclass, 'table-sortable', ' ') />
				
				<cfset attributes.smartList.addOrder("#attributes.sortProperty#|ASC") />
			</cfif>
		</cfif>
		
		<!--- Setup the admin meta info --->
		<cfset attributes.administativeCount = 0 />
		
		<!--- Detail --->
		<cfif len(attributes.recordDetailAction)>
			<cfset attributes.administativeCount++ />
			
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-detailaction="#attributes.recordDetailAction#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-detailquerystring="#attributes.recordDetailQueryString#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-detailmodal="#attributes.recordDetailModal#"', " ") />
		</cfif>
		
		<!--- Edit --->
		<cfif len(attributes.recordEditAction)>
			<cfset attributes.administativeCount++ />
			
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-editaction="#attributes.recordEditAction#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-editquerystring="#attributes.recordEditQueryString#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-editmodal="#attributes.recordEditModal#"', " ") />
		</cfif>
		
		<!--- Delete --->
		<cfif len(attributes.recordDeleteAction)>
			<cfset attributes.administativeCount++ />
			
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-deleteaction="#attributes.recordDeleteAction#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-deletequerystring="#attributes.recordDeleteQueryString#"', " ") />
		</cfif>
		
		<!--- Process --->
		<cfif len(attributes.recordProcessAction)>
			<cfset attributes.administativeCount++ />
			
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-processaction="#attributes.recordProcessAction#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-processquerystring="#attributes.recordProcessQueryString#"', " ") />
			<cfset attributes.adminattributes = listAppend(attributes.adminattributes, 'data-processmodal="#attributes.recordProcessModal#"', " ") />
		</cfif>
		
		<!--- Setup the primary representation column if no columns were passed in --->
		<cfif not arrayLen(thistag.columns)>
			<cfset arrayAppend(thistag.columns, {
				propertyIdentifier = thistag.exampleentity.getSimpleRepresentationPropertyName(),
				title = "",
				tdClass="primary",
				search = true,
				sort = true,
				filter = false,
				range = false
			}) />
		</cfif>
		
		<!--- Setup the list of all property identifiers to be used later --->
		<cfloop array="#thistag.columns#" index="column">
			<cfset thistag.allpropertyidentifiers = listAppend(thistag.allpropertyidentifiers, column.propertyIdentifier) />
		</cfloop>
	</cfsilent>
	<cfoutput>
		<cfif arrayLen(attributes.smartList.getPageRecords())>
			<cfif thistag.selectable>
				<input type="hidden" name="#attributes.selectFieldName#" value="#attributes.selectValue#" />
			</cfif>
			<cfif thistag.multiselectable>
				<input type="hidden" name="#attributes.multiselectFieldName#" value="#attributes.multiselectValues#" />
			</cfif>
			<table id="LD#replace(attributes.smartList.getSavedStateID(),'-','','all')#" class="#attributes.tableclass#" data-savedstateid="#attributes.smartList.getSavedStateID()#" data-entityname="#attributes.smartList.getBaseEntityName()#" data-idproperty="#thistag.exampleEntity.getPrimaryIDPropertyName()#" data-propertyidentifiers="#thistag.exampleEntity.getPrimaryIDPropertyName()#,#thistag.allpropertyidentifiers#" #attributes.tableattributes#>
				<thead>
					<tr>
						<!--- Selectable --->
						<cfif thistag.selectable>
							<th class="select">&nbsp;</th>
						</cfif>
						<!--- Multiselectable --->
						<cfif thistag.multiselectable>
							<th class="multiselect">&nbsp;</th>
						</cfif>
						<!--- Sortable --->
						<cfif thistag.sortable>
							<th class="sort">&nbsp;</th>
						</cfif>
						<cfloop array="#thistag.columns#" index="column">
							<cfsilent>
								<cfif not len(column.title)>
									<cfset column.title = attributes.smartList.getPageRecords()[1].getTitleByPropertyIdentifier(column.propertyIdentifier) />
								</cfif>
							</cfsilent>
							<th class="data #column.tdClass#" data-propertyIdentifier="#column.propertyIdentifier#">
								<cfif not column.search and not column.sort and not column.filter and not column.range>
									#column.title#
								<cfelse>
									<div class="dropdown">
										<a href="##" class="dropdown-toggle" data-toggle="dropdown">#column.title# <span class="caret"></span> </a>
										<ul class="dropdown-menu nav">
											<cfif column.search>
												<li class="nav-header">#request.slatwallScope.rbKey('define.search')#</li>
												<li class="search-filter"><input type="text" class="listing-search span2" name="FK:#column.propertyIdentifier#" value="" /> <i class="icon-search"></i></li>
												<li class="divider"></li>
											</cfif>
											<cfif column.sort>
												<li class="nav-header">#request.slatwallScope.rbKey('define.sort')#</li>
												<li><a href="##" class="listing-sort" data-sortdirection="ASC"><i class="icon-arrow-down"></i> Sort Ascending</a></li>
												<li><a href="##" class="listing-sort" data-sortdirection="DESC"><i class="icon-arrow-up"></i> Sort Decending</a></li>
											</cfif>
											<!---
											<cfif column.range>
												<li class="nav-header">#request.slatwallScope.rbKey('define.range')#</li>
												
												<cfset filterOptions = attributes.smartList.getFilterOptions(valuePropertyIdentifier=column.propertyIdentifier, namePropertyIdentifier=column.propertyIdentifier) />
												<div class="filter-scroll">
													<cfloop array="#filterOptions#" index="filter">
														<li><a href="#attributes.smartList.buildURL( 'F:#column.propertyIdentifier#=#filter["value"]#' )#">#filter['value']#</a></li>
													</cfloop>
												</div>
												
											</cfif>
											--->
											<cfif column.filter>
												<li class="divider"></li>
												<li class="nav-header">#request.slatwallScope.rbKey('define.filter')#</li>
												<cfset filterOptions = attributes.smartList.getFilterOptions(valuePropertyIdentifier=column.propertyIdentifier, namePropertyIdentifier=column.propertyIdentifier) />
												<div class="filter-scroll">
													<input type="hidden" name="F:#column.propertyIdentifier#" value="" />
													<cfloop array="#filterOptions#" index="filter">
														<li><a href="##" class="listing-filter" data-filtervalue="#filter['value']#"><i class="slatwall-ui-checkbox"></i> #filter['name']#</a></li>
													</cfloop>
												</div>
											</cfif>
										</ul>
									</div>
								</cfif>
							</th>
						</cfloop>
						<cfif attributes.administativeCount>
							<th class="admin admin#attributes.administativeCount#" #attributes.adminattributes#>&nbsp;</th>
						</cfif>
					</tr>
				</thead>
				<tbody <cfif thistag.sortable>class="sortable"</cfif>>
					<cfloop array="#attributes.smartList.getPageRecords()#" index="record">
						<tr id="#record.getPrimaryIDValue()#">
							<!--- Selectable --->
							<cfif thistag.selectable>
								<td><a href="##" class="table-action-select" data-idvalue="#record.getPrimaryIDValue()#"><i class="slatwall-ui-raido"></i></a></td>
							</cfif>
							<!--- Multiselectable --->
							<cfif thistag.multiselectable>
								<td><a href="##" class="table-action-multiselect#IIF(attributes.edit, DE(""), DE(" disabled"))#" data-idvalue="#record.getPrimaryIDValue()#"><i class="slatwall-ui-checkbox"></i></a></td>
							</cfif>
							<!--- Sortable --->
							<cfif thistag.sortable>
								<td><a href="##" class="table-action-sort" data-idvalue="#record.getPrimaryIDValue()#" data-sortPropertyValue="#record.getValueByPropertyIdentifier( attributes.sortProperty )#"><i class="icon-move"></i></a></td>
							</cfif>
							<cfloop array="#thistag.columns#" index="column">
								<!--- Expandable Check --->
								<cfif column.tdclass eq "primary" and thistag.expandable>
									<td class="#column.tdclass#"><a href="##" class="table-action-expand depth0" data-depth="0"  data-parentid="#record.getPrimaryIDValue()#"><i class="icon-plus"></i></a> #record.getValueByPropertyIdentifier( propertyIdentifier=column.propertyIdentifier, formatValue=true )#</td>
								<cfelse>
									<td class="#column.tdclass#">#record.getValueByPropertyIdentifier( propertyIdentifier=column.propertyIdentifier, formatValue=true )#</td>
								</cfif>
							</cfloop>
							<cfif attributes.administativeCount>
								<td class="admin admin#attributes.administativeCount#">
									<cfif attributes.recordDetailAction neq "">
										<cf_SlatwallActionCaller action="#attributes.recordDetailAction#" queryString="#record.getPrimaryIDPropertyName()#=#record.getPrimaryIDValue()#&#attributes.recordDetailQueryString#" class="btn btn-mini" icon="eye-open" iconOnly="true" modal="#attributes.recordDetailModal#" />
									</cfif>
									<cfif attributes.recordEditAction neq "">
										<cf_SlatwallActionCaller action="#attributes.recordEditAction#" queryString="#record.getPrimaryIDPropertyName()#=#record.getPrimaryIDValue()#&#attributes.recordEditQueryString#" class="btn btn-mini" icon="pencil" iconOnly="true" modal="#attributes.recordEditModal#" />
									</cfif>
									<cfif attributes.recordProcessAction neq "">
										<cf_SlatwallActionCaller action="#attributes.recordProcessAction#" queryString="#record.getPrimaryIDPropertyName()#=#record.getPrimaryIDValue()#&#attributes.recordProcessQueryString#" class="btn btn-mini" icon="cog" text="#request.slatwallScope.rbKey('define.process')#" disabled="#record.isNotProcessable()#" modal="#attributes.recordProcessModal#" />
									</cfif>
									<cfif attributes.recordDeleteAction neq "">
										<cf_SlatwallActionCaller action="#attributes.recordDeleteAction#" queryString="#record.getPrimaryIDPropertyName()#=#record.getPrimaryIDValue()#&#attributes.recordDeleteQueryString#" class="btn btn-mini" icon="trash" iconOnly="true" disabled="#record.isNotDeletable()#" confirm="true" />
									</cfif>
								</td>
							</cfif>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<cf_SlatwallSmartListPager smartList="#attributes.smartList#" />
		<cfelse>
			<p><em>#replace(request.slatwallScope.rbKey("entity.define.norecords"), "${entityNamePlural}", request.slatwallScope.rbKey("entity.#replace(attributes.smartList.getBaseEntityName(), 'Slatwall', '', 'all')#_plural"))#</em></p>
		</cfif>
	</cfoutput>
</cfif>
