/**
 * CustomException class to log exceptions and track errors in the system.
 * 
 * @author         NAGARRO | 05-27-2026
 * @description    Get exception details
 * @history        Version 1.0
 * @test class     CustomExceptionTest updated 05-27-2026
 **/
public with sharing class CustomException extends Exception {
	//Added to create/cover test class for this class
	public override String getMessage() {
		return super.getMessage();
	}
}