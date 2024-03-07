@isTest
public class TaskTriggerHandlerTest {
    @isTest
    static void testTaskCompletion() {
        Account acc = new Account(Name = 'Test Account', Active__c = false);
        insert acc;
        
        Task tsk = new Task(Subject = 'Test Task', WhatId = acc.Id, Status = 'Not Started');
        insert tsk;
        
        tsk.Status = 'Completed';
        tsk.Description = 'Test comments';
        update tsk;
        
        acc = [SELECT Id, Active__c, Description FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, acc.Active__c);
        System.assertEquals('Test comments', acc.Description);
    }
    
    
}