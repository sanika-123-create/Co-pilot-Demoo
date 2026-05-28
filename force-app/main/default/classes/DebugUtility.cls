/**
 * DebugUtility class to log and track messgae in the system.
 * 
 * @author         NAGARRO | 05-27-2026
 * @description    Get exception details
 * @history        Version 1.0
 * @test class     DebugUtilityTest updated 05-27-2026
 **/
public inherited sharing class DebugUtility {
	/**
	 * @description log and track messgae in the system.
     * @param logMessage message to be logged
	 **/
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void addDebug(String logMessage) {
		System.debug(System.LoggingLevel.INFO, logMessage);
	}
	/**
	 * @description log and track messgae in the system.
	 * @param loggingLevel System.LoggingLevel loggingLevel, String logMessage
     * @param logMessage message to be logged
	 **/
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void addDebug(System.LoggingLevel loggingLevel, String logMessage) {
	    System.debug(loggingLevel, logMessage);
		
	}
}