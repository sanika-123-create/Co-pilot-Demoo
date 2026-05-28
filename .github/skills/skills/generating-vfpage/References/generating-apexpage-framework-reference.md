
## 4) VISUALFORCE FRAMEWORK

### 4.1 VF Page Structure

```xml
<apex:page controller="ClaimController" renderAs="PDF" applyBodyTag="false" showHeader="false">
    <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; }
                table { width: 100%; border-collapse: collapse; }
                .header { text-align: center; font-weight: bold; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Claim Summary</h1>
            </div>
            
            <table>
                <tr>
                    <td>Claim Number:</td>
                    <td><apex:outputText value="{!claim.Name}"/></td>
                </tr>
                <tr>
                    <td>Amount:</td>
                    <td>
                        <apex:outputText value="{0, number, $}">
                            <apex:param value="{!claim.Claim_Amount__c}"/>
                        </apex:outputText>
                    </td>
                </tr>
                <tr>
                    <td>Date:</td>
                    <td>
                        <apex:outputText value="{0, date, yyyy-MM-dd}">
                            <apex:param value="{!claim.CreatedDate}"/>
                        </apex:outputText>
                    </td>
                </tr>
            </table>
        </body>
    </html>
</apex:page>
```

### 4.2 Controller Pattern

```apex
public class ClaimController {
    
    public Case claim { get; private set; }
    public List<Equipment__c> equipmentList { get; private set; }
    
    public ClaimController() {
        Id claimId = ApexPages.currentPage().getParameters().get('id');
        loadClaimData(claimId);
    }
    
    private void loadClaimData(String claimId) {
        if (String.isBlank(claimId)) {
            return;
        }
        
        List<Case> claims = ClaimDao.getClaimById(claimId);
        if (!claims.isEmpty()) {
            this.claim = claims[0];
            loadEquipment(claimId);
        }
    }
    
    private void loadEquipment(String claimId) {
        this.equipmentList = EquipmentDao.getEquipmentByClaimId(claimId);
    }
}
```

### 4.3 VF Components and Reusable Patterns

**Email Template VF:**
```xml
<messaging:emailTemplate>
    <messaging:plainTextEmailBody>
        Hello {!recipient.FirstName},
        
        Your claim {!claim.Name} has been received.
        Amount: ${!claim.Claim_Amount__c}
        
        Thank you.
    </messaging:plainTextEmailBody>
    
    <messaging:htmlEmailBody>
        <html>
            <body>
                <p>Hello <strong>{!recipient.FirstName}</strong>,</p>
                <p>Your claim <strong>{!claim.Name}</strong> has been received.</p>
                <p>Amount: <strong>${!claim.Claim_Amount__c}</strong></p>
                <p>Thank you.</p>
            </body>
        </html>
    </messaging:htmlEmailBody>
</messaging:emailTemplate>
```

### 4.4 Best Practices

- ✅ Keep logic in controller, not in VF bindings
- ✅ Use `<apex:outputText>` with formatting for dates/numbers
- ✅ Cache getter results to avoid repeated SOQL
- ✅ Use `<apex:repeat>` for lists instead of `<apex:page forEach>`
- ❌ Avoid heavy computation in getters
- ❌ Avoid direct SOQL in VF page properties

### 4.5 PDF Rendering

```xml
<apex:page controller="ClaimPDFController" renderAs="PDF" applyBodyTag="false">
    <head>
        <style type="text/css">
            @page { size: A4; }
            body { margin: 0.5in; }
        </style>
    </head>
    <body>
        <!-- Content here -->
    </body>
</apex:page>
```

---