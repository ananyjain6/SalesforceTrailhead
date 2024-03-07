public class AccountTriggerHandler {
    public static void handleAfterInsert(List<Account> newAccounts) {
        List<Task> tasksToInsert = new List<Task>();
        for (Account acc : newAccounts) {
            if (!acc.Active__c) {
                Task newTask = createTaskForAccount(acc);
                tasksToInsert.add(newTask);
            }
        }
        insert tasksToInsert;
    }
    
    public static Task createTaskForAccount(Account acc) {
        String taskSubject = 'Review Account- ' + acc.AccountNumber;
        Date dueDate = System.today().addDays(7);
        Task newTask = new Task(
            Subject = taskSubject,
            WhatId = acc.Id,
            ActivityDate = dueDate,
            OwnerId = acc.OwnerId,
            Status = 'Not Started'
        );
        return newTask;
    }

    

}