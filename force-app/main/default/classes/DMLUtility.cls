/**
 * Utility class DML operations logging and error tracking.
 * 
 * @author         NAGARRO | 05-27-2026
 * @description    Utility class DML operations logging and error tracking.
 * @history        Version 1.0
 * @test class     SharedUtilityTest updated 05-27-2026
 **/
public without sharing class DMLUtility {
	private static Set<String> bypassTriggers;
	/** 
	 * @description Method to insert SObject records
     * @author      NAGARRO | 05-27-2026
	 * @param       records - The SObject records to be inserted
	 * @param       allOrNoneIndicator - Boolean indicator for partial insert
	 * @return      Database.SaveResult[]
	 **/
	public static Database.SaveResult[] insertRecords(List<SObject> records, Boolean allOrNoneIndicator) {
		Database.SaveResult[] results = Database.insert(records, allOrNoneIndicator);
		List<Database.Error> dataBaseErrors = resultsMethodInsertUpdateUtility(results);
		errorLogUtilityMethod(dataBaseErrors, 'DMLUtility-->insertRecords');
		return results;
	}

	/** 
	 * @description Method to insert SObject records
     * @author      NAGARRO | 05-27-2026
	 * @param       records - The SObject records to be inserted
	 * @param       dmlOptions - dmlOptions for insert
	 * @return      Database.SaveResult[]
	 **/
	public static Database.SaveResult[] insertRecords(List<SObject> records, Database.DMLOptions dmlOptions) {
		Database.SaveResult[] results = Database.insert(records, dmlOptions);
		List<Database.Error> dataBaseErrors = resultsMethodInsertUpdateUtility(results);
		errorLogUtilityMethod(dataBaseErrors, 'DMLUtility-->insertRecords');
		return results;
	}
	
	/**
	 * @description Method to update SObject records
	 * @param records - The SObject records to be updated
	 * @param allOrNoneIndicator - Boolean indicator for partial update
	 * @return Database.SaveResult[]
	 **/
	public static Database.SaveResult[] updateRecords(List<SObject> records, Boolean allOrNoneIndicator) {
		Database.SaveResult[] results = Database.update(records, allOrNoneIndicator);
		List<Database.Error> dataBaseErrors = resultsMethodInsertUpdateUtility(results);
		errorLogUtilityMethod(dataBaseErrors, 'DMLUtility-->updateRecords');
		return results;
	}

	/**
	 * @description     : Method to update SObject records
	 * @param records - The SObject records to be updated
	 * @param dmlOptions - dmlOptions indicator for diffrent dml operations
	 * @return      : Database.SaveResult[]
	 **/
	public static Database.SaveResult[] updateRecords(List<SObject> records, Database.DMLOptions dmlOptions) {
		Database.SaveResult[] results = Database.update(records, dmlOptions);
		List<Database.Error> dataBaseErrors = resultsMethodInsertUpdateUtility(results);
		errorLogUtilityMethod(dataBaseErrors,'DMLUtility-->updateRecords');
		return results;
	}

	/**
	 * @description     : Method to upsert SObject records
	 * @param records - The SObject records to be upserted
	 * @param allOrNoneIndicator - Boolean indicator for partial insert
	 * @return Database.UpsertResult[]
	 **/
	public static Database.UpsertResult[] upsertRecords(List<SObject> records, Boolean allOrNoneIndicator) {
		Database.UpsertResult[] results = Database.upsert(records, allOrNoneIndicator);
		List<Database.Error> dataBaseErrors = resultsMethodUpsertUtility(results);
		errorLogUtilityMethod(dataBaseErrors, 'DMLUtility-->upsertRecords');
		return results;
	} 

    /**
	 * @description     : Method to delete SObject records
	 * @param records - The SObject records to be deleted
	 * @param allOrNoneIndicator - Boolean indicator for partial delete
	 * @return      : Database.DeleteResult[]
	 **/
	public static Database.DeleteResult[] deleteRecords(List<SObject> records, Boolean allOrNoneIndicator) {
		Database.DeleteResult[] results = Database.delete(records, allOrNoneIndicator);
		List<Database.Error> dataBaseErrors = resultsMethodDeleteUtility(results);
		errorLogUtilityMethod(dataBaseErrors, 'DMLUtility-->deleteRecords');
		return results;
	}

	/**
	 * @description Method to undelete SObject records
	 * @param records - The SObject records to be undeleted
	 * @param allOrNoneIndicator - Boolean indicator for partial undelete
	 * @return Database.UndeleteResult[]
	 **/
	public static Database.UndeleteResult[] unDeleteRecords(List<SObject> records, Boolean allOrNoneIndicator) {
		Database.UndeleteResult[] results = Database.undelete(records, allOrNoneIndicator);
		List<Database.Error> dataBaseErrors = resultsMethodUndeleteUtility(results);
		errorLogUtilityMethod(dataBaseErrors,'DMLUtility-->unDeleteRecords');
		return results;
	}

	/**
	 * @description     : Method to combine the results in utility method for insert and update dml
	 * @param results - Name of the class and method where this method used
	 * @return      : dataBaseErrors combine the results for insert and update dml
	 **/
	private static List<Database.Error> resultsMethodInsertUpdateUtility(Database.SaveResult[] results) {
		List<Database.Error> dataBaseErrors = new List<Database.Error>();
		if (results == null) {
            return dataBaseErrors;
        }
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                Database.Error[] dmlErrors = new List<Database.Error>();
                for(Database.Error err: result.getErrors()){
                    if(err.getStatusCode() != null && err.getStatusCode() != StatusCode.ENTITY_IS_DELETED){
                        dmlErrors.add(err);
                    }
                }
                dataBaseErrors.addAll(dmlErrors);
            }
        }
		return dataBaseErrors;
	}

	/**
	 * @description     : Method to combine the results in utility method for upsert dml
	 * @param results - Name of the class and method where this method used
	 * @return      : dataBaseErrors combine the results for upsert dml
	 **/
	private static List<Database.Error> resultsMethodUpsertUtility(Database.UpsertResult[] results) {
		List<Database.Error> dataBaseErrors = new List<Database.Error>();
		if (results == null) {
            return dataBaseErrors;
        }
        for (Database.UpsertResult result : results) {
            if (!result.isSuccess()) {
                Database.Error[] dmlErrors = new List<Database.Error>();
                for(Database.Error err: result.getErrors()){
                    if(err.getStatusCode() != null && err.getStatusCode() != StatusCode.ENTITY_IS_DELETED){
                        dmlErrors.add(err);
                    }
                }
                dataBaseErrors.addAll(dmlErrors);
            }
        }
		return dataBaseErrors;
	}

	/**
	 * @description     : Method to combine the results in utility method for delete dml
	 * @param results - Name of the class and method where this method used
	 * @return      : dataBaseErrors combine the results for delete dml
	 **/
	private static List<Database.Error> resultsMethodDeleteUtility(Database.DeleteResult[] results) {
		List<Database.Error> dataBaseErrors = new List<Database.Error>();
		if (results == null) {
            return dataBaseErrors;
        }
        for (Database.DeleteResult result : results) {
            if (!result.isSuccess()) {
                Database.Error[] dmlErrors = new List<Database.Error>();
                for(Database.Error err: result.getErrors()){
                    if(err.getStatusCode() != null && err.getStatusCode() != StatusCode.ENTITY_IS_DELETED){
                        dmlErrors.add(err);
                    }
                }					
                dataBaseErrors.addAll(dmlErrors);
            }
        }
		return dataBaseErrors;
	}

	/**
	 * @description     : Method to combine the results in utility method for delete dml
	 * @param results - Name of the class and method where this method used
	 * @return      : dataBaseErrors combine the results for delete dml
	 **/
	private static List<Database.Error> resultsMethodUndeleteUtility(Database.UndeleteResult[] results) {
		List<Database.Error> dataBaseErrors = new List<Database.Error>();
		if (results == null) {
            return dataBaseErrors;
        }
        for (Database.UndeleteResult result : results) {
            if (!result.isSuccess()) {
                Database.Error[] dmlErrors = new List<Database.Error>();
                for(Database.Error err: result.getErrors()){
                    if(err.getStatusCode() != null && err.getStatusCode() != StatusCode.ENTITY_IS_DELETED){
                        dmlErrors.add(err);
                    }
                }
                dataBaseErrors.addAll(dmlErrors);
            }
        }
		return dataBaseErrors;
	}

	/**
	 * @description     : Method to log the errors for DML Opeartion Failure
	 * @param dataBaseErrors for error logs details
	 * @param sourceClassMethod - Name of the class and method where this method used
	 **/
	private static void errorLogUtilityMethod(List<Database.Error> dataBaseErrors, String sourceClassMethod) {
		if (dataBaseErrors != null && !dataBaseErrors.isEmpty()) {
			LogFactory.logDatabaseErrors(sourceClassMethod, dataBaseErrors);
		}
	}
	/**
	 * @description    Method to delete SObject records
	 * @param recIds - The SObject records ids to be deleted
	 * @param allOrNoneIndicator - Boolean indicator for partial delete
     * @param objectName object Name for which records are tobe deleted
	 * @return      : Database.DeleteResult[]
	 **/
	public static Database.DeleteResult[] deleteRecords(Set<Id> recIds, Boolean allOrNoneIndicator, String objectName) {
		Database.DeleteResult[] results;
		if(recIds?.isEmpty()==false) {
			List<SObject> recsToDelete;// = CommonDAO.getRecordsUsingIds(recIds, objectName);
			results = Database.delete(recsToDelete, allOrNoneIndicator);
			List<Database.Error> dataBaseErrors = resultsMethodDeleteUtility(results);
			errorLogUtilityMethod(dataBaseErrors, 'DMLUtility~deleteRecords');
		}
		return results;
	}

}