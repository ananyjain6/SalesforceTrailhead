public class TaskTriggerHandler {
    public static void handleAfterUpdate(List<Task> updatedTasks, Map<Id, Task> oldMap) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Task updatedTask : updatedTasks) {
            Task oldTask = oldMap.get(updatedTask.Id);
            // Check if the task status changed to 'Completed'
            if (updatedTask.Status == 'Completed' && oldTask.Status != 'Completed') {
                // Check if the current user belongs to the "CQ Account Admin" permission set
                if (checkPermissionSet()) {
                    // Retrieve the related Account
                    Account acc = [SELECT Id, Description, Active__c FROM Account WHERE Id = :updatedTask.WhatId LIMIT 1];
                    if (acc != null) {
                        // Update Account fields
                        acc.Description = updatedTask.Description;
                        acc.Active__c = true;
                        accountsToUpdate.add(acc);
                    }
                }
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    private static Boolean checkPermissionSet() {
        
        return [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CQ_Account_Admin' AND AssigneeId = :UserInfo.getUserId()] != null;
    }
}