public with sharing class NPSServiceCall {
    public class NPSServiceCallException extends Exception{}
    private final String npsServiceNamedCredential = 'NPS_Service';

    //NPS InsertOrder Callout Method
    public HttpResponse sendOrders(List<Order> orders){   

        if(orders.size() > 30){
            throw new NPSServiceCallException('NPS service does not accept more than 30 orders, please check.');
        }

        List<NPSOrderIds> npsidsList = new List<NPSOrderIds>();
        for (Order ord : orders) {
            npsidsList.add(new NPSOrderIds(ord));
        }

               
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://salesforce-coding-challenge.herokuapp.com/orders');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('tmondo:Noy84LRpYvMZuETB')));
        req.setHeader('Content-Type','application/json');    
        req.setBody(JSON.serialize(npsidsList));

        HttpResponse response = ht.send(req);                
        return response;
    }

    
}