public with sharing class PlaceNPSOrderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private string query;
    private List<Id> idList;
    public HttpResponse response;

    public PlaceNPSOrderBatch(List<Id> ids){
        this.idList = ids;
        this.query = 'SELECT Id, OrderNumber, BillToContact.Email FROM Order WHERE Id IN :idList';
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orderList){
        NPSServiceCall npssrvce= new NPSServiceCall();
        response = npssrvce.sendOrders(orderList);  
    }

    public void finish(Database.BatchableContext bc){

        // we can send email to admin 
    }
}