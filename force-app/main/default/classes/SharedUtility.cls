/**
 * Factory class common utility class for logging and error tracking.
 * 
 * @author         NAGARRO | 05-27-2026
 * @description    common utility class for logging and error tracking.
 * @history        Version 1.0
 * @test class     SharedUtilityTest updated 05-27-2026
 **/
public with sharing class SharedUtility {
    /**
	 * @description try catch to check if we get the stack trace to find the flow of the apex execution
     * @return String error stack trace
	 **/
    public static String getStackTrace() {
		String stackTrace = '';
		try {
			throw new CustomException();
		} catch (Exception ex) {
			stackTrace = ex.getStackTraceString();
		}
		return stackTrace;
	}

	/**
	 * @description Formats a date into a string in MM/dd/yyyy format
	 * @param inputDate The date to format
	 * @return String The formatted date string
	 **/
	public static String formatDate(Date inputDate) {
        if (inputDate != null) {
            return String.valueOf(inputDate.month()) +
                '/' +
                String.valueOf(inputDate.day()) +
                '/' +
                String.valueOf(inputDate.year());
        }
        return '';
    }

	/**
	 * @description method to perform contains check
	 * @param allValues The list of strings to search in
	 * @param valueToCheck The string to search for
	 * @return boolean True if the value is found, false otherwise
	 **/
    public static boolean contains(List<String> allValues, String valueToCheck){
        boolean hasVal = false;
        for(Integer i=0; i< allValues.size(); i ++ ){
            if(allValues[i].equalsIgnoreCase(valueToCheck)){
                hasVal = true;
                break;
            }
        }
        return hasVal;
    }
}