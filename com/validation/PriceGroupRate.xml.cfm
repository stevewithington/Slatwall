<?xml version="1.0" encoding="UTF-8"?>
<validateThis xsi:noNamespaceSchemaLocation="validateThis.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<conditions>
		<condition name="isNotGlobal" 
			serverTest="getGlobalFlag() EQ 0"
			clientTest="" />
			
		<!--<condition name="HasNoIncludesButIsNotGlobal" 
			serverTest="getGlobalFlag() EQ 0 AND ((ArrayLen(getProducts()) + ArrayLen(getProductTypes()) + ArrayLen(getSkus())) EQ 0)"
			clientTest="" />-->	
			
	</conditions>
	
	<objectProperties>
		<property name="priceGroup">
			<rule type="required" contexts="save" />
		</property>
		<property name="amountType">
			<rule type="required" contexts="save" />
		</property>
		<property name="amount">
			<rule type="required" contexts="save" />
			<rule type="numeric" contexts="save" />
		</property>
		
		<!--<property name="productTypes">
			<rule type="required" condition="HasNoIncludesButIsNotGlobal" failureMessage="You require at least one product or product type in this non-global rate."/>
			<rule type="collectionSize" contexts="*" condition="HasNoIncludesButIsNotGlobal" failureMessage="You require at least one product or product type in this non-global rate.">
				<param name="min" value="1" />
			</rule>
		</property>-->
	</objectProperties>
</validateThis>