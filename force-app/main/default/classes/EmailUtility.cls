/**
 * Email utility class for sending emails.
 * 
 * @author         NAGARRO | 05-27-2026
 * @description    Email utility class for sending emails.
 * @history        Version 1.0
 * @test class     EmailUtilityTest updated 05-27-2026
 **/
public with sharing class EmailUtility {
    public static Messaging.SingleEmailMessage sendVisualForceTemplateEmailWithPDF(EmailRequestWrapper emailRequest) {
        Messaging.SingleEmailMessage email;
        try {
            if (emailRequest.sourceRecordId == null || emailRequest.pdfVFPageName == null) {
                return null;
            }
            
            email = sendVisualForceTemplateEmail(emailRequest);
            
            String pageStr = '/apex/' + emailRequest.pdfVFpageName;
            PageReference pdfPageRef = new PageReference(pageStr);
            pdfPageRef.getParameters().put('id', emailRequest.sourceRecordId);
            Blob pdfBlob = pdfPageRef.getContentAsPDF();
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            string fileName = emailRequest.attachmentFileName;
            csvAttc.setFileName(fileName);
            csvAttc.setBody(pdfBlob);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ csvAttc });
        } catch (Exception e) {
            LogFactory.error('EmailUtility.sendVisualForceTemplateEmailWithPDF',e);
            return null;
        }
        return email;
    }
    
    public static Messaging.SingleEmailMessage sendVisualForceTemplateEmail(EmailRequestWrapper emailRequest) {
        try {
            System.debug('emailRequest---'+emailRequest);
            Messaging.SingleEmailMessage objMessagingEmail;
            EmailTemplate emailTemplate = new EmailTemplate();
            if (String.isBlank(emailRequest.emailTemplateId) && String.isNotBlank(emailRequest.templateDeveloperName)) {
                emailTemplate = [
					SELECT Id, Name, Subject, DeveloperName, HtmlValue, Body, IsActive
					FROM EmailTemplate
					WHERE DeveloperName = :emailRequest.templateDeveloperName AND IsActive = TRUE 
				];
                emailRequest.emailTemplateId = emailTemplate.Id;
            }
            
            objMessagingEmail = Messaging.renderStoredEmailTemplate(
                emailRequest.emailTemplateId,
            emailRequest.whoId,
            emailRequest.sourceRecordId
                );
            
            if (String.isNotBlank(emailRequest.setOrgWideEmailAddressId)) {
                objMessagingEmail.setOrgWideEmailAddressId(emailRequest.setOrgWideEmailAddressId);
            }
            objMessagingEmail.setUseSignature(false);
            objMessagingEmail.setToAddresses(emailRequest.toEmailIdList);
            objMessagingEmail.saveAsActivity = true;
            
            list<String> ccEmail = new List<String>();
            if (emailRequest.ccEmailIdList != null) {
                ccEmail.addAll(emailRequest.ccEmailIdList);
                objMessagingEmail.setCcAddresses(ccEmail);
            }
            
            if (String.isNotBlank(emailRequest.subject)) {
                objMessagingEmail.setSubject(emailRequest.subject);
            } /*else {
                objMessagingEmail.setSubject(emailTemplate.subject);
            }*/
            System.debug('objMessagingEmail---'+objMessagingEmail);
            return objMessagingEmail;
        } catch (Exception e) {
            LogFactory.error('EmailUtility.sendVisualForceTemplateEmailWithPDF',e);
            return null;
        }
    }
    
    public class EmailRequestWrapper {
        public String sourceRecordId;
        public String templateDeveloperName;
        public List<String> toEmailIdList;
        public List<String> ccEmailIdList;
        public String subject;
        public String whoId;
        public String pdfVFPageName;
        public String attachmentFileName;
        public String emailTemplateId;
        public String setOrgWideEmailAddressId;
    }
}