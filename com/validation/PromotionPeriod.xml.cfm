<?xml version="1.0" encoding="UTF-8"?>
<validateThis xsi:noNamespaceSchemaLocation="validateThis.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<objectProperties>
		<property name="startDateTime">
			<rule type="required" contexts="save" />
			<rule type="date" contexts="save" />
		</property>
		<property name="endDateTime">
			<rule type="required" contexts="save" />
			<rule type="date" contexts="save" />
		</property>
	</objectProperties>
</validateThis>
