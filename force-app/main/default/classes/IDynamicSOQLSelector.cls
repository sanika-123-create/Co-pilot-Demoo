/*******************************************************************************************************************
 * @company     : Nagarro Inc.
 * @date        : 01-06-2023
 * @author      : Nagarro
 * @description : This class is used implementing SOQL selector's methods
 * @history     : Version 1.0
 *******************************************************************************************************************/
public interface IDynamicSOQLSelector {
	/**
	 * Specifies the main object from which you want to retrieve data.
	 * @Example: setFrom('Account')
	 * @param objectName The API name of the main object.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setFrom(String objectName);
	/**
	 * Selects specific fields from the main object. Example: setFields(new Set<String>{'Name', 'Industry'})
	 * @param fields A set of field names to be selected.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setFields(Set<String> fields);
	/**
	 * Selects fields from a field set of the main object.
	 * @Example: setFieldSet('AccountFieldSet')
	 * @param fieldSet - The schema name of the field set.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setFieldSet(Schema.FieldSet fieldSet);
	/**
	 * Selects fields from a field set of the main object and specifies whether to get picklist values as labels.
	 * @Example: setFieldSet('AccountFieldSet', true)
	 * @param fieldSet - The schema name of the field set.
	 * @param getPicklistValuesAsLabel Determines whether to get picklist values as labels.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setFieldSet(Schema.FieldSet fieldSet, Enums.PicklistLabel picklistLabelValue);
	/**
	 * Selects Selects multi-level fields for the object.
	 * @Example: setMultilevelFields('BeachheadReportingAccount__r.Business_Location__r', new Set<String>{'tolabel(Name)'})
	 * @param objectRelationPath The path of the relationship to the object.
	 * @param fields The set of fields.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setMultilevelFields(String objectRelationPath, Set<String> fields);
	/**
	 * Selects fields from a multi-level field set.
	 * @Example: setMultilevelFieldSet('Account', 'Booking__r.Frieght__r.Account__r', 'AccountFieldSet')
	 * @param objectRelationPath The relation path to the object.
	 * @param objectFieldSet The schema name of the multi-level field set.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setMultilevelFieldSet(String objectRelationPath, Schema.FieldSet objectFieldSet);
	/**
	 * Selects fields from a multi-level field set.
	 * @Example: setMultilevelFieldSet('Account', 'Booking__r.Frieght__r.Account__r', 'AccountFieldSet')
	 * @param objectRelationPath The relation path to the object.
	 * @param objectFieldSet The schema name of the multi-level field set.
	 * @param picklistLabelValue Specifies whether to get picklist values as labels.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setMultilevelFieldSet(String objectRelationPath, Schema.FieldSet objectFieldSet, Enums.PicklistLabel picklistLabelValue);
	/**
	 * Sets the query parameters.
	 * @Example: setQueryParams(new Map<String, Object>{'param1' => value1, 'param2' => value2})
	 * @param queryParams A map of parameter names and values.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setQueryParams(Map<String, Object> queryParams);
	/**
	 * Sets the WHERE condition for the query.
	 * @Example: setWhereConditions('Name = \'Test\' OR Name LIKE %Test%')
	 * @param condition The WHERE condition.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setWhereConditions(String condition);
	/**
	 * Sets the HAVING condition for aggregate fields in query.
	 * @Example: setHavingConditions('COUNT(Id) > 1')
	 * @param condition The HAVING condition.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setHavingConditions(String condition);
	/**
	 * Sets the access level for the query.
	 * @Example: setAccessLevel(System.AccessLevel.USER_MODE)
	 * @param accessLevel The access level enum.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setAccessLevel(System.AccessLevel accessLevel);
	/**
	 * Specifies the field to order the query results in ascending order.
	 * @Example: setOrderAscBy('Id')
	 * @param fieldName The name of the field to be ordered.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setOrderAscBy(String fieldName);
	/**
	 * Specifies the field to order the query results in ascending order and handles null values.
	 * @Example: setOrderAscBy('Id', Enums.NullOrder.NULLS_FIRST)
	 * @param fieldName The name of the field to be ordered.
	 * @param nullEnumSet The null handling option.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setOrderAscBy(String fieldName, Enums.NullOrder nullEnumSet);
	/**
	 * Specifies the field to order the query results in descending order.
	 * @Example: setOrderDescBy('Id')
	 * @param fieldName The name of the field to be ordered.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setOrderDescBy(String fieldName);
	/**
	 * Specifies the field to order the query results in descending order and handles null values.
	 * @Example: setOrderDescBy('Id', Enums.NullOrder.NULLS_FIRST)
	 * @param fieldName The name of the field to be ordered.
	 * @param nullEnumSet The null handling option.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setOrderDescBy(String fieldName, Enums.NullOrder nullEnumSet);
	/**
	 * Sets the maximum number of records to retrieve.
	 * @Example: setLimit(4)
	 * @param limitValue The limit value.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setLimit(Integer limitValue);
	/**
	 * Sets the offset for the query results.
	 * @Example: setOffset(4)
	 * @param offset The offset value.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector setOffset(Integer offset);
	/**
	 * Sets the FOR UPDATE clause for the query.
	 * @return The DynamicSOQLSelector instance.
	 */
	DynamicSOQLSelector forUpdate();
	/**
	 * Sets the ALL ROWS clause for the query.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 */
	DynamicSOQLSelector allRows();
	/**
	 * @param fieldName - The name of the field for which to calculate the sum.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the SUM aggregate function.
	 */
	DynamicSOQLSelector setSum(String fieldName, String alias);
	/**
	 * @param fieldName - The name of the field for which to calculate the count.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the COUNT aggregate function.
	 */
	DynamicSOQLSelector setCount(String fieldName, String alias);
	/**
	 * @param fieldName - The name of the field for which to calculate the distinct count.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the COUNT_DISTINCT aggregate function.
	 */
	DynamicSOQLSelector setCountDistinct(String fieldName, String alias);
	/**
	 * @param fieldName - The name of the field for which to calculate the average.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the AVG aggregate function.
	 */
	DynamicSOQLSelector setAvg(String fieldName, String alias);
	/**
	 * @param fieldName - The name of the field for which to find the maximum value.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the MAX aggregate function.
	 */
	DynamicSOQLSelector setMax(String fieldName, String alias);
	/**
	 * @param fieldName - The name of the field for which to find the minimum value.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the MIN aggregate function.
	 */
	DynamicSOQLSelector setMin(String fieldName, String alias);
	/**
	 * @param fieldsSet - The List of fields to group by.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the GROUP BY clause.
	 */
	DynamicSOQLSelector setGroupBy(List<String> fieldsSet);
	/**
	 * @param keyword - The search keyword.
	 * @param fieldSet - The field set for the search.
	 * @param fieldsSet - The set of fields for the search.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Filter the records on the basis of keyword.
	 */
	DynamicSOQLSelector filterAll(String keyword, Schema.FieldSet fieldSet, Set<String> fields);
	/**
	 * @param keyword - The search keyword.
	 * @param fieldSet - The field set for the search.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Filter the records on the basis of keyword.
	 */
	DynamicSOQLSelector filterAll(String keyword, Schema.FieldSet fieldSet);
	/**
     * Generates the subqueries.
     * @Example: setOffset(4).addChildQuery('Cases__r', 'Case', new DynamicSOQLSelector()
                                                                .selectFrom('Accounts__r')
                                                                .selectFields(new Set<String>{ 'Id', 'CaseNumber' })
                                                                .selectFieldSet('BL_Revision_Case_Info')                        
                                            )
     * @param childQuery The complete set of data to build a sub query.
     * @return The DynamicSOQLSelector instance.
     */
	DynamicSOQLSelector addSubQuery(DynamicSOQLSelector childQuery);
	/**
	 * Executes the dynamic SOQL query and returns the results as a list of SObjects.
	 * @return A list of SObjects representing the query results.
	 */
	List<SObject> execute();
	/**
	 * Executes the SOQL query and returns a Database.QueryLocator.
	 * @return Database.QueryLocator - The result of the SOQL query as a Database.QueryLocator
	 */
	Database.QueryLocator getQueryLocator();
	/**
	 * Returns the count of records for the executed query.
	 * @return The count of records.
	 */
	Integer count();
	/**
	 * Returns the count of records for the executed query grouped by a specified field.
	 * @Example: count('Id')
	 * @param fieldName The name of the field to group by.
	 * @return The count of records grouped by the specified field.
	 */
	Integer count(String fieldName);
}