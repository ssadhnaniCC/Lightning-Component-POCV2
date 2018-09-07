({
    loadFieldSet: function(component, event) {
        var fieldSetName = component.get("v.fieldSetName");
        var accFieldName = component.get("v.accountFieldName");
        var recId = component.get("v.recordId");
        
        if(fieldSetName && recId) {
            var getFormAction = component.get("c.getMultipicklistData");
            getFormAction.setParams({
                recId: recId,
                accountField: accFieldName,
                fsName: fieldSetName
            });
            
            getFormAction.setCallback(this, function(response) {
                var state = response.getState();
                
                if (component.isValid() && state === "SUCCESS") {
                    if(response.getReturnValue() != null){
                    	component.set("v.wrapperList", response.getReturnValue());
                    }
                } else if (state === "ERROR") {
                    console.log('Has Error!!!');
                }
            });
            
            $A.enqueueAction(getFormAction);
        }
        
        
    }
})