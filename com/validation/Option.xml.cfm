<?xml version="1.0" encoding="UTF-8"?>
<validateThis xsi:noNamespaceSchemaLocation="validateThis.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<objectProperties>
		<property name="optionCode">
			<rule type="required" contexts="*" />
			<rule type="custom" contexts="*" failureMessage="Option Code is Not Unique">
				<param name="methodName" value="hasUniqueOptionCode" />
			</rule>
		</property>
		<property name="optionName">
			<rule type="required" contexts="*" />
		</property>
		<property name="skus">
			<rule type="collectionSize" context="delete">
				<param name="max" value="0" />
			</rule>
		</property>
	</objectProperties>
</validateThis>