/*******************************************************************************************************************
 * @company     : Nagarro Inc.
 * @date        : 01-06-2023
 * @author      : Nagarro
 * @description : This class is used for select data for building a SOQL query
 * @history     : Version 1.0
 * @test class  : DynamicSOQLSelectorTest
 *******************************************************************************************************************/
public inherited sharing class DynamicSOQLSelector  {
	private DynamicSOQLSelectorWrapper soqlSelectorWrapper;

	/*
	 * @purpose      : Create a new instance for the soqlSelector wrapper
	 * @param        : NULL
	 * @return       : NULL
	 */
	public DynamicSOQLSelector() {
		soqlSelectorWrapper = new DynamicSOQLSelectorWrapper();
	}

	/*
	 * @purpose     : Set NULLS FIRST or NULLS LAST based on parameter
	 * @parameter   : withNullFirst
	 * @return      : String
	 */
	private String setNullWithOrderBy(Boolean withNullFirst) {
		String sortDirection = ' NULLS LAST ';
		if (withNullFirst) {
			sortDirection = ' NULLS FIRST ';
		}
		return sortDirection;
	}

	/*
	 * @purpose     : Add aggregate operations in query
	 * @parameter   : aggFunc
	 * @parameter   : fieldName
	 * @parameter   : alias
	 * @return      : DynamicSOQLSelector
	 */
	private DynamicSOQLSelector setAggregates(String aggFunc, String fieldName, String alias) {
		if (String.isNotBlank(fieldName) && String.isNotBlank(aggFunc)) {
			fieldName = fieldName.toLowerCase().trim();
			alias = String.isEmpty(alias) ? '' : alias;
			soqlSelectorWrapper.fieldNames.add(aggFunc.trim() + '(' + fieldName + ') ' + alias);
		}
		return this;
	}

	/*
	 * @purpose     : Checks for violations in the WHERE condition of the query
	 * @parameter   : condition - The WHERE condition to check
	 * @return      : void
	 */
	private void checkWhereConditionViolations(String condition) {
		if (condition.contains('\'')) {
			throw new CustomException('Static values are not allowed in the WHERE conditions. Please use binding variables instead.');
		}
	}

	/*
	 * @purpose     : Checks for tolabel in the field and return the relational field
	 * @parameter   : field - The name of the field
	 * @parameter   : objectRelationPath - The path of the relationship to the object
	 * @return      : string
	 */
	private String getRelationFieldPath(String objectRelationPath, String field) {
		if (String.isNotBlank(field)) {
			field = field.trim().toLowerCase();
			if (field.contains('tolabel(')) {
				field = 'tolabel(' + objectRelationPath + '.' + field.substringAfter('(').substringBefore(')') + ')';
			} else {
				field = objectRelationPath + '.' + field;
			}
		}
		return field;
	}

	/*
	 * @purpose     : Specifies the object from which to retrieve data
	 * @parameter   : objectName - The name of the object to select from
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setFrom(String objectName) {
		if (String.isNotBlank(objectName)) {
			soqlSelectorWrapper.objectName = objectName.trim();
		}
		return this;
	}

	/*
	 * @purpose     : Selects specific fields to retrieve from the object
	 * @parameter   : fields - A set of field names to select
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setFields(Set<String> fields) {
		for (String field : fields) {
			if (String.isNotEmpty(field) && !soqlSelectorWrapper.fieldNames.contains(field.toLowerCase().trim())) {
				soqlSelectorWrapper.fieldNames.add(field.toLowerCase().trim());
			}
		}
		return this;
	}

	/*
	 * @purpose     : Selects fields from a field set for the object
	 * @parameter   : fieldSet - The schema name of the field set
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setFieldset(Schema.FieldSet fieldSet) {
		if (fieldSet != null) {
			soqlSelectorWrapper.fieldNames.addAll(new DynamicSOQLBuilder().getFieldSetFields(null, fieldSet, false));
		}
		return this;
	}

	/*
	 * @purpose     : Selects fields from a field set for the object
	 * @parameter   : fieldSet - The schema name of the field set
	 * 				  picklistLabelValue - Specifies whether to get picklist values as labels
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setFieldset(Schema.FieldSet fieldSet, Enums.PicklistLabel picklistLabelValue) {
		Boolean getPicklistValuesAsLabel = (picklistLabelValue == Enums.PicklistLabel.WITH_LABEL);
		if (fieldSet != null) {
			soqlSelectorWrapper.fieldNames.addAll(new DynamicSOQLBuilder().getFieldSetFields(null, fieldSet, getPicklistValuesAsLabel));
		}
		return this;
	}

	/*
	 * @purpose     : Selects multi-level fields for the object
	 * @parameter   : objectRelationPath - The path of the relationship to the object
	 *                fields - A set of field names to select
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setMultilevelFields(String objectRelationPath, Set<String> fields) {
		if (String.isNotBlank(objectRelationPath) && !fields.isEmpty()) {
			for (String field : fields) {
				String fieldName = getRelationFieldPath(objectRelationPath, field);
				if (!String.isEmpty(fieldName) && !soqlSelectorWrapper.fieldNames.contains(fieldName)) {
					soqlSelectorWrapper.fieldNames.add(fieldName);
				}
			}
		}
		return this;
	}

	/*
	 * @purpose     : Selects fields from a multi-level field set for the object
	 * @parameter   : objectRelationPath - The path of the relationship to the object
	 *                objectFieldSet - The schema name of the multi-level field set
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setMultilevelFieldSet(String objectRelationPath, Schema.FieldSet objectFieldSet) {
		if (String.isNotBlank(objectRelationPath) && objectFieldSet != null) {
			soqlSelectorWrapper.fieldNames.addAll(new DynamicSOQLBuilder().getFieldSetFields(objectRelationPath, objectFieldSet, false));
		}
		return this;
	}

	/*
	 * @purpose     : Selects fields from a multi-level field set for the object
	 * @parameter   : objectRelationPath - The path of the relationship to the object
	 *                objectFieldSet - The schema name of the multi-level field set
	 * 				  picklistLabelValue - The value of the enum PicklistLabel
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setMultilevelFieldSet(String objectRelationPath, Schema.FieldSet objectFieldSet, Enums.PicklistLabel picklistLabelValue) {
		Boolean getPicklistValuesAsLabel = (picklistLabelValue == Enums.PicklistLabel.WITH_LABEL);
		if (String.isNotBlank(objectRelationPath) && objectFieldSet != null) {
			soqlSelectorWrapper.fieldNames.addAll(new DynamicSOQLBuilder().getFieldSetFields(objectRelationPath, objectFieldSet, getPicklistValuesAsLabel));
		}
		return this;
	}

	/*
	 * @purpose     : Sets the query parameters for the SOQL query
	 * @parameter   : queryParams - A map of query parameters
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setQueryParams(Map<String, Object> queryParams) {
		if (soqlSelectorWrapper.queryParams.size() > 0) {
			soqlSelectorWrapper.queryParams.putAll(queryParams);
		} else {
			soqlSelectorWrapper.queryParams = queryParams;
		}
		return this;
	}

	/*
	 * @purpose     : Sets the WHERE condition for the query
	 * @parameter   : condition - The WHERE condition for the query
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setWhereConditions(String condition) {
		//checkWhereConditionViolations(condition);
		soqlSelectorWrapper.condition = condition;
		return this;
	}

	/*
	 * @purpose     : Sets the HAVING condition for aggregate fields in query
	 * @parameter   : condition - The HAVING condition for the query
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setHavingConditions(String condition) {
		checkWhereConditionViolations(condition);
		soqlSelectorWrapper.havingCondition = condition;
		return this;
	}

	/*
	 * @purpose     : Sets the access level for the query
	 * @parameter   : accessLevel - The access level for the query
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setAccessLevel(System.AccessLevel accessLevel) {
		soqlSelectorWrapper.accessLevel = accessLevel;
		return this;
	}

	/*
	 * @purpose     : Builds the subquery
	 * @parameter   : childQuery - The complete set of data to build a sub query
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector addSubQuery(DynamicSOQLSelector childQuery) {
		soqlSelectorWrapper.fieldNames.add(' ( ' + new DynamicSOQLBuilder(childQuery.soqlSelectorWrapper).buildSOQLQuery() + ' ) ');
		return this;
	}

	/*
	 * @purpose     : Specifies the field to order the query results in ascending order
	 * @parameter   : fieldName - The name of the field to order by
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setOrderAscBy(String fieldName) {
		if (String.isNotEmpty(fieldName)) {
			soqlSelectorWrapper.sortFieldsList.add(fieldName + ' ASC ');
		}
		return this;
	}

	/*
	 * @purpose     : Specifies the field to order the query results in ascending order and sets NULLS FIRST or NULLS LAST based on the null order enum
	 * @parameter   : fieldName - The name of the field to order by
	 *                nullsOrder - The null order enum to specify NULLS FIRST or NULLS LAST
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setOrderAscBy(String fieldName, Enums.NullOrder nullEnumSet) {
		Boolean withNullFirst = (nullEnumSet == Enums.NullOrder.NULLS_FIRST) ? true : false;
		if (String.isNotEmpty(fieldName)) {
			soqlSelectorWrapper.sortFieldsList.add(fieldName + ' ASC ' + setNullWithOrderBy(withNullFirst));
		}
		return this;
	}

	/*
	 * @purpose     : Specifies the field to order the query results in descending order
	 * @parameter   : fieldName - The name of the field to order by
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setOrderDescBy(String fieldName) {
		if (String.isNotEmpty(fieldName)) {
			soqlSelectorWrapper.sortFieldsList.add(fieldName + ' DESC ');
		}
		return this;
	}

	/*
	 * @purpose     : Specifies the field to order the query results in descending order and sets NULLS FIRST or NULLS LAST based on the null order enum
	 * @parameter   : fieldName - The name of the field to order by
	 *                nullsOrder - The null order enum to specify NULLS FIRST or NULLS LAST
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setOrderDescBy(String fieldName, Enums.NullOrder nullEnumSet) {
		Boolean withNullFirst = (nullEnumSet == Enums.NullOrder.NULLS_FIRST) ? true : false;
		if (String.isNotEmpty(fieldName)) {
			soqlSelectorWrapper.sortFieldsList.add(fieldName + ' DESC ' + setNullWithOrderBy(withNullFirst));
		}
		return this;
	}

	/*
	 * @purpose     : Sets the LIMIT clause for the query
	 * @parameter   : limit - The limit value for the query
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setLimit(Integer limitValue) {
		soqlSelectorWrapper.limitValue = limitValue;
		return this;
	}

	/*
	 * @purpose     : Sets the OFFSET clause for the query
	 * @parameter   : offset - The offset value for the query
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector setOffset(Integer offset) {
		soqlSelectorWrapper.offsetValue = offset;
		return this;
	}

	/*
	 * @purpose     : Sets the FOR UPDATE clause for the query
	 * @param       : NULL
	 * @return      : DynamicSOQLSelector - The updated instance of DynamicSOQLSelector
	 */
	public DynamicSOQLSelector forUpdate() {
		soqlSelectorWrapper.forUpdate = true;
		return this;
	}

	/**
	 * Sets the ALL ROWS clause for the query.
	 * @param        : NULL
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 */
	public DynamicSOQLSelector allRows() {
		soqlSelectorWrapper.allRows = true;
		return this;
	}

	/**
	 * @param fieldName - The name of the field for which to calculate the sum.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the SUM aggregate function.
	 */
	public DynamicSOQLSelector setSum(String fieldName, String alias) {
		return this.setAggregates('SUM', fieldName, alias);
	}

	/**
	 * @param fieldName - The name of the field for which to calculate the count.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the COUNT aggregate function.
	 */
	public DynamicSOQLSelector setCount(String fieldName, String alias) {
		return this.setAggregates('COUNT', fieldName, alias);
	}

	/**
	 * @param fieldName - The name of the field for which to calculate the distinct count.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the COUNT_DISTINCT aggregate function.
	 */
	public DynamicSOQLSelector setCountDistinct(String fieldName, String alias) {
		return this.setAggregates('COUNT_DISTINCT', fieldName, alias);
	}

	/**
	 * @param fieldName - The name of the field for which to calculate the average.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the AVG aggregate function.
	 */
	public DynamicSOQLSelector setAvg(String fieldName, String alias) {
		return this.setAggregates('AVG', fieldName, alias);
	}

	/**
	 * @param fieldName - The name of the field for which to find the maximum value.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the MAX aggregate function.
	 */
	public DynamicSOQLSelector setMax(String fieldName, String alias) {
		return this.setAggregates('MAX', fieldName, alias);
	}

	/**
	 * @param fieldName - The name of the field for which to find the minimum value.
	 * @param alias - The alias name of aggregate field.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the MIN aggregate function.
	 */
	public DynamicSOQLSelector setMin(String fieldName, String alias) {
		return this.setAggregates('MIN', fieldName, alias);
	}

	/**
	 * @param fieldsSet - The List of fields to group by.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Sets the GROUP BY clause.
	 */
	public DynamicSOQLSelector setGroupBy(List<String> fieldsSet) {
		for (String field : fieldsSet) {
			if (String.isNotEmpty(field)) {
				field = field.toLowerCase().trim();
				soqlSelectorWrapper.groupByFields.add(field);
			}
		}
		return this;
	}

	/**
	 * @param keyword - The search keyword.
	 * @param fieldSet - The field set for the search.
	 * @param fieldsSet - The set of fields for the search.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Filter the records on the basis of keyword.
	 */
	public DynamicSOQLSelector filterAll(String keyword, Schema.FieldSet fieldSet, Set<String> fields) {
		if (String.isNotEmpty(keyword)) {
			soqlSelectorWrapper.queryParams.put('keyword', '%' + keyword + '%');
			if (fields == null) {
				fields = new Set<String>();
			}
			fields.addAll(new DynamicSOQLBuilder().getFieldSetFields(null, fieldSet, true));

			for (String field : fields) {
				if (!String.isEmpty(field)) {
					soqlSelectorWrapper.whereConditionSet.add(field.toLowerCase().trim() + ' LIKE :keyword');
				}
			}
		}
		return this;
	}

	/**
	 * @param keyword - The search keyword.
	 * @param fieldSet - The field set for the search.
	 * @return DynamicSOQLSelector - The updated instance of DynamicSOQLSelector.
	 * @purpose Filter the records on the basis of keyword.
	 */
	public DynamicSOQLSelector filterAll(String keyword, Schema.FieldSet fieldSet) {
		if (String.isNotEmpty(keyword)) {
			soqlSelectorWrapper.queryParams.put('keyword1', '%' + keyword + '%');

			for (String field : (new DynamicSOQLBuilder().getFieldSetFields(null, fieldSet, true))) {
				if (!String.isEmpty(field)) {
					soqlSelectorWrapper.whereConditionSet.add(field.toLowerCase().trim() + ' LIKE :keyword1');
				}
			}
		}
		return this;
	}

	/*
	 * @purpose     : Executes the SOQL query and returns the list of SObject records
	 * @param       : NULL
	 * @return      : List<SObject> - The result of the SOQL query as a list of SObject records
	 */
	public List<SObject> execute() {
		return (List<SObject>) new DynamicSOQLBuilder(soqlSelectorWrapper).selectRecords(false);
	}

	/*
	 * @purpose      :Executes the SOQL query and returns a Database.QueryLocator.
	 * @param        : NULL
	 * @return       :Database.QueryLocator - The result of the SOQL query as a Database.QueryLocator
	 */
	public Database.QueryLocator getQueryLocator() {
		return (Database.QueryLocator) new DynamicSOQLBuilder(soqlSelectorWrapper).selectRecords(true);
	}

	/*
	 * @purpose     : Returns the count of records in the SOQL query result
	 * @return      : Integer - The count of records in the SOQL query result
	 */
	public Integer count() {
		return new DynamicSOQLBuilder(soqlSelectorWrapper).countRecords(null);
	}

	/*
	 * @purpose     : Returns the count of records in the SOQL query result for a specific field
	 * @parameter   : fieldName - The name of the field to count records for (default is 'Id' if null)
	 * @return      : Integer - The count of records in the SOQL query result for the specified field
	 */
	public Integer count(String fieldName) {
		return new DynamicSOQLBuilder(soqlSelectorWrapper).countRecords(fieldName);
	}

	private class CustomException extends Exception {
	}
}