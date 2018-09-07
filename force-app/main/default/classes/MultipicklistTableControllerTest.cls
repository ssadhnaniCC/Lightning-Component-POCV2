@isTest
public class MultipicklistTableControllerTest {
    
    @isTest static void userIsOnAccount() { //This case is for when user is on Account Record Page
        Account acc = new Account(Name='Test Account 1', Hobbies__c='Coding;Science', Interested_Country__c='US;UK;India');
        insert acc;
        
        MultipicklistTableController.getMultipicklistData(acc.Id, null, 'multiSelectFieldSet');
    }
    
    @isTest static void userIsOnOpportunity() { //This case is for when user is on Another Object's Record Page Which have Account Field
        Account acc = new Account(Name='Test Account 2', Hobbies__c='Coding;Science', Interested_Country__c='US;UK;India');
		insert acc;
        
        Opportunity opp = new Opportunity(Name='Test', AccountId = acc.Id, StageName='Closed Won', CloseDate = System.today());
		insert opp;
        
        MultipicklistTableController.getMultipicklistData(opp.Id, 'AccountId', 'multiSelectFieldSet');
    }

}