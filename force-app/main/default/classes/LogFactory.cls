/**
 * Factory class to log information and track errors in the system.
 * 
 * @author         NAGARRO | 05-27-2026
 * @description    To log the information and to track any error if occurred
 * @history        Version 1.0
 * @test class     LogFactoryTest updated 05-27-2026
 **/
public without sharing class LogFactory {
	// Final String constants for the Error and Info Type
	public static final String TYPE_ERROR = 'ERROR';
	public static final String TYPE_INFO = 'INFO';
	public static Boolean toString = true;
	
	// Getter and Setter for the list of the Log records created in a transaction
	private static List<Log__c> allLogs {
		get {
			if (allLogs == null) {
				allLogs = new List<Log__c>();
			}
			return allLogs;
		}
		set;
	}
    /** 
	 * @description Method to create a Log record with type ERROR
	 * @param sourceClass - Name of the class where the error originated
	 * @param message - Output message containing information related to the error (Stacktrace, Message etc.)
	 **/
	public static void error(String sourceClass, String message) {
		newLog(TYPE_ERROR, sourceClass, message);
	}

	/** 
	 * @description Method to create a Log record with type ERROR
	 * @param sourceClass - Name of the class where the error originated
	 * @param message - Output message containing information related to the error (Stacktrace, Message etc.)
	 **/
	public static void error(String sourceClass, String error,String errorline, String message) {
		newLog(TYPE_ERROR, sourceClass+error, errorline + ' ' + message);
	}

	/**
	 * @description Method to create a Log record with type ERROR
	 * @param sourceClass - Name of the class where the error originated
	 * @param ex - Exception containing information related to the error (Stacktrace, Message, Line Number etc.)
	 **/
	public static void error(String sourceClass, Exception ex) {
		String message = 'Line Number : ' + ex.getLineNumber() + ' Message : ' + ex.getMessage() + ' Stack Trace : ' + ex.getStackTraceString();
		newLog(TYPE_ERROR, sourceClass, message);
	}
	/**
	 * @description Method to create a Log record with type INFO
	 * @param sourceClass - Name of the class where the logging of info is performed
	 * @param message - Output message containing information which is to be logged
	 **/
	public static void info(String sourceClass, String message) {
		newLog(TYPE_INFO, sourceClass, message);
	}

	/**
	 * @description Method to create a Log record with type INFO
	 * @param sourceClass - Name of the class where the logging of info is performed
	 * @param handler - AsyncOperationHandler
     * @return Log__c
	 **/
	public static Log__c logAsyncJob(String sourceClass, AsyncOperationHandler handler) {
		Log__c log;
		try {
			log = newLog(handler?.error == null ? TYPE_INFO : TYPE_ERROR, sourceClass, toString ? handler?.toString() : '');
		} catch(Exception ex) {
			log = newLog(handler?.error == null ? TYPE_INFO : TYPE_ERROR, sourceClass, '');
		}
		return log;
	}

	/**
	 * @description Method to upsert all the Log records created in the transaction and re initializing the allLogs variable for new logs.
	 **/
	public static void saveLog() {
		if (allLogs != null && !allLogs.isEmpty()) {
			//DMLUtility.upsertParamsDMLUtility params = new DMLUtility.upsertParamsDMLUtility(allLogs, null, true, accesslevel.SYSTEM_MODE, 'LogFactory~saveLog');
			//DMLUtility.upsertRecords(params);
			allLogs.clear();
			allLogs = new List<Log__c>();
		}
	}

	/**
	 * @description Method to create a Log record with level type as INFO or Error and to add the record to the allLogs variable
	 * @param level - Level of the information log wheather it is an ERROR or INFO
	 * @param sourceClass - Name of the class where the logging is performed
	 * @param message - Output message containing information which is to be logged
     * @return Log__c
	 **/
	private static Log__c newLog(String level, String sourceClass, String message) {
		String stackTrace = SharedUtility.getStackTrace();
		Log__c logItem = new Log__c(Level__c = level, Source_class__c = sourceClass, Description__c = message + '\nStackTrace : ');
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.allowFieldTruncation = true;
		logItem.setOptions(dml);
		allLogs.add(logItem);
		return logItem;
	}

	/**
	 * @description Method to upsert all the Logs in future.
	 * @param level - Level of the information log wheather it is an ERROR or INFO
	 * @param sourceClass - Name of the class where the logging is performed
	 * @param messages - List of string of messages to be logged
	 **/
	@Future
	public static void saveLogFuture(String level, String sourceClass, List<String> messages) {
		for (String message : messages) {
			newLog(level, sourceClass, message);
		}
		saveLog();
	}

	/**
	 * @description Method to upsert all the Logs in future.
	 * @param level - Level of the information log wheather it is an ERROR or INFO
	 * @param sourceClass - Name of the class where the logging is performed
	 * @param messages - List of string of messages to be logged
	 **/
	public static void saveLogNonFuture(String level, String sourceClass, List<String> messages) {
		for (String message : messages) {
			newLog(level, sourceClass, message);
		}
		saveLog();
	}

	/**
	 * @description Method to create log records for the List of Database Errors.
	 * @param sourceClass - Name of the class where the logging is performed
	 * @param errors - list of Database error instances
	 **/
	public static void logDatabaseErrors(String sourceClass, List<Database.Error> errors) {
		List<String> messages = new List<String>();		
		for (Database.Error err : errors) {
			messages.add(err.getStatusCode() + ' : ' + err.getMessage() + ' : ' + err.getFields());
		}
		if (System.isBatch() || System.isQueueable() || System.isFuture()) {
			saveLogNonFuture(TYPE_ERROR, sourceClass, messages);
		} else {
			saveLogFuture(TYPE_ERROR, sourceClass, messages);
		}
	}
	/***
	 * @description : To Insert from Batch
	 * @param sourceClass
	 * @param errors
	 ***/
	public static void logDatabaseErrorsNonFuture(String sourceClass, List<Database.Error> errors) {
		for (Database.Error err : errors) {
			String messageError = '';
			messageError = err.getStatusCode() + ' : ' + err.getMessage() + ' : ' + err.getFields();
			newLog(TYPE_ERROR, sourceClass, messageError);
		}
	}
	/***
	 * @description : To get the Log Id
	 * @param type - log type Error or Info 
	 * @param sourceClass - Name of the class where the logging is performed
	 * @param message - List of string of messages to be logged
     * @return Id logId;
	 ***/
	public static Id saveLogRecord(String type, String sourceClass, String message) {
		Log__c log = newLog(type, sourceClass, message);
		//DMLUtility.insertRecords(new List<sObject>{ log }, true, accessLevel.SYSTEM_MODE, 'LogFactory~saveLogRecord'); 
		allLogs.clear();
		return log.Id;
	}

	/***
	 * @description : To create log from LWC
	 * @param compName - LWC component name 
	 * @param message - List of string of messages to be logged
	 ***/
	@AuraEnabled
	public static void createLogRecord(String compName, String message) {
		try {
			LogFactory.error(compName, message);
			if (Test.isRunningTest()) {
				throw new DMLException('DML error');
			}
		} catch (Exception e) {
			LogFactory.error('CC_BaseController Error while creating record: ', e);
			throw new AuraHandledException(e.getMessage());
		} finally {
			LogFactory.saveLog();
		}
	}
}