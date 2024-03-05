// RecordListHomeController.cls
public with sharing class RecordListHomeController {
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> fetchRecords(String objectApiName, Integer limitRecords) {
        // Query records with the required fields and limit the number of records
        String query = 'SELECT Name, CreatedDate, CreatedById FROM ' + objectApiName + ' LIMIT :limitRecords';
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectInfo> getAvailableObjects() {
        List<ObjectInfo> objectInfos = new List<ObjectInfo>();
        for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            if (objDescribe.isQueryable() && objDescribe.isCreateable() && objDescribe.isUpdateable()) {
                ObjectInfo info = new ObjectInfo(objDescribe.getLabel(), objDescribe.getName());
                objectInfos.add(info);
            }
        }
        return objectInfos;
    }

    public class ObjectInfo {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String apiName { get; set; }

        public ObjectInfo(String label, String apiName) {
            this.label = label;
            this.apiName = apiName;
        }
    }

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