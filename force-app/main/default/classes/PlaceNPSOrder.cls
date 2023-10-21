public with sharing class PlaceNPSOrder {
    @InvocableMethod(label='Place Orders to NPS Service'  callout = 'true')
    public static List<NPSServiceCallResult> sendOrdersToNPS(List<Id> orderIds){

        List<NPSServiceCallResult> outputlist = new List<NPSServiceCallResult>();
        NPSServiceCallResult result = new NPSServiceCallResult();

        //Method1 : Call NPS Service directly from Invocable Method        
        try {
            List<Order> ordersList = [SELECT Id, Status, OrderNumber, BillToContact.Email FROM Order WHERE Id IN :orderIds WITH USER_MODE];                
            NPSServiceCall npsCall = new NPSServiceCall();
            HttpResponse response = npsCall.sendOrders(ordersList);      
           
            result.statuscode = response.getStatusCode();         
            result.message = response.getBody();
        } catch (Exception ex) {            
            result.statuscode = 500;

            result.message = ex.getMessage();            
        }

        outputlist.add(result);
        return outputlist;




        //Method 2: Call batch class , batchsize: 30 
        //
        //PlaceNPSOrderBatch ordrbatch = new PlaceNPSOrderBatch(orderIds);
        //Database.executeBatch(ordrbatch, 30);

    }
    

    public class NPSServiceCallResult{    
        @InvocableVariable    
        public Integer statuscode;      
        @InvocableVariable  
        public String message;
    }
    
}