public class HomePageController {
    @AuraEnabled
    public static List<String> getEntityOptions() {
        List<String> entities = new List<String>();
        for (Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
            if (objTyp.getDescribe().isAccessible()) {
                entities.add(objTyp.getDescribe().getName());
            }
        }
        return entities;
    }
    
    @AuraEnabled
    public static List<sObject> getRecords(String entityName, Integer recordLimit) {
        String query = 'SELECT Id, Name, CreatedDate, CreatedBy.Name FROM ' + entityName + ' ORDER BY CreatedDate DESC LIMIT :recordLimit';
        return Database.query(query);
    }
}