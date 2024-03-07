@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    static void testHandleAfterInsert() {
        Account acc = new Account(Name = 'Test Account', Active__c = false, OwnerId = UserInfo.getUserId());
        insert acc;
        
        Test.startTest();
        List<Account> newAccounts = new List<Account>{acc};
        AccountTriggerHandler.handleAfterInsert(newAccounts);
        Test.stopTest();
        
        List<Task> insertedTasks = [SELECT Id, Subject, WhatId, ActivityDate, OwnerId, Status FROM Task WHERE WhatId = :acc.Id];
        
        
        Task insertedTask = insertedTasks[0];
        System.assertEquals('Review Account- ' + acc.AccountNumber, insertedTask.Subject);
        System.assertEquals(acc.Id, insertedTask.WhatId);
        System.assertEquals(Date.today().addDays(7), insertedTask.ActivityDate);
        System.assertEquals(acc.OwnerId, insertedTask.OwnerId);
        System.assertEquals('Not Started', insertedTask.Status);
    }
}