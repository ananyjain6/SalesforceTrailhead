public with sharing class RecentRecordsController {
    
    // Method to retrieve the most recent records for the selected entity
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecentRecords(String selectedEntity, Integer selectedRecordCount) {
        try {
            String query = 'SELECT ';
            List<Schema.SObjectField> fields = getFields(selectedEntity);
            if (fields.isEmpty()) {
                query += 'Id, Name, CreatedDate, CreatedById ';
            } else {
                for (Schema.SObjectField field : fields) {
                    query += field + ', ';
                }
                query = query.substring(0, query.length() - 2) + ' ';
            }
            query += 'FROM ' + selectedEntity + ' ORDER BY CreatedDate DESC LIMIT :selectedRecordCount';
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching recent records: ' + e.getMessage());
        }
    }
    
    // Method to retrieve the fields of the selected object dynamically
    @AuraEnabled(cacheable=true)
    public static List<FieldDescribeWrapper> getObjectFields(String objectName) {
        try {
            List<FieldDescribeWrapper> fieldList = new List<FieldDescribeWrapper>();
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            for (String fieldName : fieldsMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
                FieldDescribeWrapper fieldWrapper = new FieldDescribeWrapper();
                fieldWrapper.label = fieldDescribe.getLabel();
                fieldWrapper.fieldName = fieldName;
                fieldWrapper.dataType = String.valueOf(fieldDescribe.getType());
                fieldList.add(fieldWrapper);
            }
            return fieldList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching object fields: ' + e.getMessage());
        }
    }
    
    // Wrapper class to hold field information
    public class FieldDescribeWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String dataType;
    }
    
    // Helper method to get fields for the selected entity
    private static List<Schema.SObjectField> getFields(String objectName) {
        try {
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
            return describeResult.fields.getMap().values();
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching fields for entity: ' + e.getMessage());
        }
    }
}