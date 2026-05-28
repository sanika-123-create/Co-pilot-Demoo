/*******************************************************************************************************************
 * @company     : Nagarro Inc.
 * @date        : 01-06-2023
 * @author      : Nagarro
 * @description : This class is used for building SOQL query from data wrapper
 * @history     : Version 1.0
 * @test class  : DynamicSOQLSelectorTest
 *******************************************************************************************************************/
public inherited sharing class DynamicSOQLBuilder {
	private DynamicSOQLSelectorWrapper soqlSelector { get; set; }
	public static List<SOQLInfoWrapper> soqlQueryList = new List<SOQLInfoWrapper>();

	public DynamicSOQLBuilder() {
		// Default constructor initializes a new DynamicSOQLSelectorWrapper
		this.soqlSelector = new DynamicSOQLSelectorWrapper();
	}

	public DynamicSOQLBuilder(DynamicSOQLSelectorWrapper soqlSelectorWrapper) {
		// Constructor that accepts a DynamicSOQLSelectorWrapper object and assigns it to the soqlSelector member variable
		this.soqlSelector = soqlSelectorWrapper;
	}

	/**
	 * Executes the dynamic SOQL query and returns a list of SObject records.
	 * @param isQueryLocator Indicates whether to use Database.QueryLocator or not
	 * @return List of SObject records
	 * @throws CustomException If the object name is not specified
	 */
	public Object selectRecords(Boolean isQueryLocator) {
		String soqlQuery;
		try {
			if (String.isBlank(soqlSelector.objectName)) {
				throw new CustomException('You have not specified any object.');
			}
			soqlQuery = buildSOQLQuery();
			Object records;

			soqlQueryList.add(new SOQLInfoWrapper(soqlQuery, String.valueOf(soqlSelector.queryParams)));
			
			GovernorLimitsUtility.checkSoqlLimits();

			if (isQueryLocator) {
				records = (Object) executeQueryLocator(soqlQuery);
			} else {
				records = (List<SObject>) executeQuery(soqlQuery);
			}

			return records;
		} catch (Exception error) {
			logErrors('DynamicSOQLBuilder', error.getMessage() + 'query-' + soqlQuery, error.getLineNumber());
			DebugUtility.addDebug('Error--' + error.getMessage() + error.getLineNumber());
			throw new CustomException(error.getMessage());
		}
	}

	/**
	 * Counts the number of records for the specified field in the dynamic SOQL query.
	 * If no field name is provided, it defaults to counting the 'Id' field.
	 * @param fieldName The field name to count the records for
	 * @return The count of records
	 * @throws CustomException if the object name is not specified
	 */
	public Integer countRecords(String fieldName) {
		try {
			if (String.isBlank(soqlSelector.objectName)) {
				throw new CustomException('You have not specified object name.');
			}

			String soqlQuery = 'SELECT COUNT(' + (String.isEmpty(fieldName) ? 'Id' : fieldName) + ') FROM ' + soqlSelector.objectName;
			if (!String.isEmpty(soqlSelector.condition)) {
				soqlQuery += ' WHERE ' + soqlSelector.condition;
			}
			if (soqlSelector.limitValue != null && soqlSelector.limitValue > 0) {
				soqlQuery += ' LIMIT ' + soqlSelector.limitValue;
			}

			List<SObject> result = executeQuery(soqlQuery);

			return (!result.isEmpty()) ? Integer.valueOf(((AggregateResult) result[0]).get('expr0')) : 0;
		} catch (Exception error) {
			logErrors('DynamicSOQLBuilder', error.getMessage(), error.getLineNumber());
			DebugUtility.addDebug('Error--' + error.getMessage() + error.getLineNumber());
			throw new CustomException(error.getMessage());
		}
	}

	/**
	 * Builds the dynamic SOQL query based on the provided configuration.
	 * @return The constructed SOQL query as a string
	 */
	public String buildSOQLQuery() {
		String soqlQuery = 'SELECT ' + String.join(soqlSelector.fieldNames, ', ');
		String filterCondition = String.join(soqlSelector.whereConditionSet, ' OR ');
		soqlQuery += ' FROM ' + soqlSelector.objectName;

		if (String.isNotEmpty(filterCondition)) {
			filterCondition = ' ( ' + filterCondition + ') ';
			soqlSelector.condition = String.isNotEmpty(soqlSelector.condition) ? (' (' + soqlSelector.condition + ') AND ' + filterCondition) : filterCondition;
		}
		if (!String.isEmpty(soqlSelector.condition)) {
			soqlQuery += ' WHERE ' + soqlSelector.condition;
		}
		if (soqlSelector.groupByFields != null && soqlSelector.groupByFields.size() > 0) {
			soqlQuery += ' GROUP BY ' + String.join(soqlSelector.groupByFields, ', ');
		}
		if (!String.isEmpty(soqlSelector.havingCondition)) {
			soqlQuery += ' HAVING ' + soqlSelector.havingCondition;
		}
		if (soqlSelector.sortFieldsList != null && soqlSelector.sortFieldsList.size() > 0) {
			soqlQuery += ' ORDER BY ' + String.join(soqlSelector.sortFieldsList, ', ');
		}
		if (soqlSelector.limitValue != null && soqlSelector.limitValue > 0) {
			soqlQuery += ' LIMIT ' + soqlSelector.limitValue;
		}
		if (soqlSelector.offsetValue != null && soqlSelector.offsetValue > 0) {
			soqlQuery += ' OFFSET ' + soqlSelector.offsetValue;
		}
		if (soqlSelector.forUpdate) {
			soqlQuery += ' FOR UPDATE ';
		}
		if (soqlSelector.allRows) {
			soqlQuery += ' ALL ROWS ';
		}

		return soqlQuery;
	}

	/**
	 * Executes the SOQL query and returns a list of SObject records.
	 * @param soqlQuery The SOQL query to execute
	 * @return List of SObject records
	 */
	public List<SObject> executeQuery(String soqlQuery) {
		System.AccessLevel accessLevel = (soqlSelector.accessLevel != null) ? soqlSelector.accessLevel : System.AccessLevel.SYSTEM_MODE;
		DebugUtility.addDebug('generated query---' + soqlQuery);
		return Database.queryWithBinds(soqlQuery, soqlSelector.queryParams, accessLevel);
	}

	/**
	 * Executes the SOQL query and returns a Database.QueryLocator.
	 * @param soqlQuery The SOQL query to execute
	 * @return Database.QueryLocator representing the result of the query
	 */
	private Database.QueryLocator executeQueryLocator(String soqlQuery) {
		System.AccessLevel accessLevel = (soqlSelector.accessLevel != null) ? soqlSelector.accessLevel : System.AccessLevel.SYSTEM_MODE;
		DebugUtility.addDebug('generated query---' + soqlQuery);
		return Database.getQueryLocatorWithBinds(soqlQuery, soqlSelector.queryParams, accessLevel);
	}

	/**
	 * Retrieves the field names from the specified field sets for the given object.
	 * @param objectRelationPath The name of the multi-relationship object
	 * @param fieldSet The schema name of the field set
	 * @param withLabel Whether or not to add toLabel to the picklist fields
	 * @return The set of field names
	 */
	public Set<String> getFieldSetFields(String objectRelationPath, Schema.FieldSet fieldSet, Boolean withLabel) {
		Set<String> fieldNames = new Set<String>();
		if (fieldSet == null) {
			return fieldNames;
		}

		for (Schema.FieldSetMember fieldMember : fieldSet.getFields()) {
			String fieldName = String.isNotEmpty(objectRelationPath) ? (objectRelationPath.trim() + '.' + fieldMember.getFieldPath()) : fieldMember.getFieldPath();
			if (withLabel && fieldMember.getType() == Schema.DisplayType.PICKLIST) {
				fieldNames.add('toLabel(' + fieldName.toLowerCase() + ')');
			} else {
				fieldNames.add(fieldName.toLowerCase());
			}
		}
		return fieldNames;
	}

	/**
	 * Logs the errors in logFactory.
	 * @param sourceClass The name of the CLass
	 * @param sourceMethod The name of the method where the error occurred
	 * @param errMessage The error message
	 * @param errLineNumber The error line number
	 */
	private void logErrors(String sourceClass, String errMessage, Integer errLineNumber) {
		LogFactory.error(sourceClass, 'Building Dynamic SOQL Query. Error: ' + errMessage + ', At line number: ' + errLineNumber);
		LogFactory.saveLog();
	}

	private class CustomException extends Exception {
	}

    public class SOQLInfoWrapper {
    public String query;
    public String params;

    public SOQLInfoWrapper(String query, String params) {
        this.query = query;
        this.params = params;
    }
}
}