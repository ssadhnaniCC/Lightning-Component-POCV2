public class MultipicklistTableController {
    
    @AuraEnabled
    public static List<FieldSetWrapper> getMultipicklistData(Id recId, String accountField,String fsName) {
        
        Id accountId;
        String objectName = recId.getSObjectType().getDescribe().getName();
        if(objectName.toLowerCase() != 'account' && String.isNotBlank(accountField)){
        	SObject sObj = Database.query('SELECT ' + accountField + ' FROM ' + objectName + ' WHERE id=:recId LIMIT 1');
            if(sObj != NULL && sObj.get(accountField) != NULL){
                accountId = (Id) sObj.get(accountField);
            }
        }else {
            accountId = recId;
        }
        
		if(accountId != NULL){
			Map<String, FieldSetWrapper> wrapperMap = new Map<String, FieldSetWrapper>(); // field API as a key
			Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Account');
			Schema.DescribeSObjectResult describe = targetType.getDescribe();
			
			String picklistFields = '';
			for (Schema.FieldSetMember f: describe.fieldSets.getMap().get(fsName).getFields()) {
				FieldSetWrapper wrapperObj = new FieldSetWrapper();
				wrapperObj.fieldName = f.getLabel();
				
				wrapperMap.put(f.fieldPath, wrapperObj);
				picklistFields += f.fieldPath + ',';
			}
			if(String.isNotBlank(picklistFields)){
				picklistFields = picklistFields.removeEnd(',');
				
				Account accObj = Database.query('SELECT ' + picklistFields + ' FROM Account WHERE Id= :accountId LIMIT 1');
				Integer maxSize = 0;
                for(String field : picklistFields.split(',')){// getting largest value set
                    if(accObj.get(field) != null && ((String)accObj.get(field)).split(';').size() > maxSize){
                        maxSize = ((String)accObj.get(field)).split(';').size();
                    }
                }
                system.debug('@@@maxSize = ' + maxSize);
                
                for(String field : picklistFields.split(',')){
					FieldSetWrapper wrapObj = wrapperMap.get(field);
                    if(accObj.get(field) != null){
						wrapObj.fieldValues.addAll(((String)accObj.get(field)).split(';'));
                        if(wrapObj.fieldValues.size() < maxSize){//this logic is to add blank TDs in the table
                            system.debug('@@@(maxSize - wrapObj.fieldValues.size()) = ' + (maxSize - wrapObj.fieldValues.size()));
                            Integer cnt = maxSize - wrapObj.fieldValues.size();
                            for(Integer i = 0; i < cnt; i++){
                                wrapObj.fieldValues.add('');
                                system.debug('@@i=' + i);
                            }
                            system.debug('@@wrapObj.fieldValues.size()=' + wrapObj.fieldValues.size());
                        }
                    }else{
                        for(Integer i = 0; i < maxSize; i++){
                            wrapObj.fieldValues.add('');
                        } 
                    }
				}
				return wrapperMap.values();
			}
		}
        return null;
    }
    
    // Wrapper For FieldSet's Field and Its Values
    public class FieldSetWrapper{
        @AuraEnabled String fieldName {get; set;}
        @AuraEnabled List<String> fieldValues {get; set;}
        public FieldSetWrapper(){
            fieldValues = new List<String>(); 
        }
    }
    
    
}