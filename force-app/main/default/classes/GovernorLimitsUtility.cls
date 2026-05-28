/**
 * @description       : 
 * @author            : NAGARRO
 * @group             : 
 * @last modified on  : 11-04-2025
 * @last modified by  : NAGARRO
**/
public without sharing class GovernorLimitsUtility {
	private static final Decimal THRESHOLD_SOQL =  0.8; // 80%
	private static final Decimal THRESHOLD_DML =  0.8; // 80%
	private static final Decimal THRESHOLD_ASYNC = 0.6; // 60%
	private static final String USERNAME ='sanika-rajiv.aloni.@nagarro.com.github';
	public static Boolean limitExceeded = false;

	private static Boolean isMailSent = false; // to avoid multiple mails to be sent in the same transaction

	public static void checkSoqlLimits() {
		if (String.isBlank(USERNAME) || isMailSent) {
			return;
		}

		Decimal currentQueries = Limits.getQueries();
		Decimal queryLimit = Limits.getLimitQueries();
		Decimal currentlyQueryThreshold = currentQueries / queryLimit;
		System.debug('currentlyQueryThreshold ::::@@@@ '+ currentlyQueryThreshold);
		System.debug('THRESHOLD_SOQL ::::@@@@ '+ THRESHOLD_SOQL);

		if (currentlyQueryThreshold < THRESHOLD_SOQL) {
			return;
		}
		limitExceeded = true;

		String message =
			'Warning: SQOL Limits threshold exceeded: ' +
			Limits.getQueries() +
			' out of ' +
			Limits.getLimitQueries() +
			' (' +
			(currentlyQueryThreshold * 100) +
			'%)' +
			' (Org Id: ' +
			UserInfo.getOrganizationId() +
			')';

		String stackTrace = SharedUtility.getStackTrace();
		String exceptionMessasge = '\n\n' + message + '\n\n' + stackTrace;
		String mailBody = message + '<br/><br/>Stack trace:' + '<br/><br/>' + stackTrace;
		DebugUtility.addDebug(LoggingLevel.ERROR, exceptionMessasge);
		sendNotificationEmail('Warning: SQOL Limits threshold exceeded', mailBody);
		try {
			if (System.isFuture()) { //FB-13547
				LogFactory.saveLogNonFuture('INFO', 'checkSoqlLimits - SQOL Limits threshold exceeded', new List<String>{ exceptionMessasge });
			} else {
				LogFactory.saveLogFuture('INFO', 'checkSoqlLimits - SQOL Limits threshold exceeded', new List<String>{ exceptionMessasge });
			}
		} catch (Exception ex) {
			DebugUtility.addDebug(LoggingLevel.ERROR, ex.getMessage());
		}
	}

	private static List<User> userList;
	public static void sendNotificationEmail(String subject, String mailBody) {
		if (String.isBlank(USERNAME)) {
			return;
		}

		// send to user id, to avoid daily email limit to the email addresses, no limit to user id
		// cannot use the DAO class here as it goes to the 1001 max depth error.
		userList = userList == null ? [SELECT Id FROM User WHERE UserName = :USERNAME WITH SYSTEM_MODE LIMIT 1] : userList;
		Id userId = userList.isEmpty() ? (Test.isRunningTest() ? UserInfo.getUserID() : null) : userList[0].Id;
		if (userId == null) {
			return;
		}

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setTargetObjectId(userId);
		email.setSaveAsActivity(false);
		email.setSubject(UserInfo.getOrganizationName() + ': ' + subject);
		String htmlBody = 'Hi,' + '<br/><br/>' + mailBody + '<br/><br/>' + 'Thanks.';
		email.setHtmlBody(htmlBody);

		try {
			isMailSent = true;
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
		} catch (Exception ex) {
			DebugUtility.addDebug(LoggingLevel.ERROR, ex.getMessage());
			LogFactory.saveLogFuture('INFO', 'Email error', new List<String>{ ex.getMessage() });
		}
	}
}