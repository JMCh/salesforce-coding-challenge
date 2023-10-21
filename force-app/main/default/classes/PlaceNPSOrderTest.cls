@isTest
public with sharing class PlaceNPSOrderTest {
    @TestSetup    
    static void testdatasetup(){
        Account acc = new Account();
        acc.Name = 'TestAccount';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'Testcontact';
        con.Email = 'Testcontact@invalid.com';
        con.AccountId = acc.Id;
        insert con;



        Product2 pd = new Product2();
        pd.Name = 'TestProd';
        insert pd;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'TestPB';
        pb.IsActive = true;
        insert pb;

        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = pd.Id; 
        pbe.Pricebook2Id = Test.getStandardPricebookId();        
        pbe.UnitPrice = 10;
        pbe.IsActive = true;
        insert pbe;

        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.Status = 'Draft';
        ord.AccountId = acc.Id;
        ord.BillToContactId = con.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        insert ord;

        OrderItem oi = new OrderItem();
        oi.Product2Id = pd.Id;
        oi.Quantity = 1;
        oi.UnitPrice = 1;
        oi.OrderId = ord.Id;
        oi.PricebookEntryId = pbe.id;

        insert oi;

        ord.Status = 'Fulfilled';
        update ord;
    }

    @isTest
    static void sendOrderSucccessTest() {
        Set<Id> orderIds = new Map<Id, Order>(([SELECT Id FROM Order])).keySet();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseNPS());    
        List<PlaceNPSOrder.NPSServiceCallResult> result = PlaceNPSOrder.sendOrdersToNPS(new List<Id>(orderIds));
 	System.debug('Results---'+ result);
        System.assertEquals(200,  result[0].statuscode , 'NPS Call send successfull');        
        Test.stopTest();
    }

    @isTest
    static void BulkOrderExceptionsTest() {
        List<Order> testOrders = new List<Order>();
        List<account> a = [SELECT Id FROM Account ];     

        for(integer i=0; i<33; i++){
            Order o = new Order();
            o.EffectiveDate = Date.today();
            o.Status = 'Draft';
            o.AccountId = a[0].Id;
            
            testOrders.add(o);
        }
        insert testOrders;
        Set<Id> orderIds = new Map<Id, Order>(([SELECT Id FROM Order])).keySet();

        Test.startTest();
        System.assert(orderIds.size() > 30, 'order size is  higher than 30');    
        String expectedError =  'NPS service does not accept more than 30 orders, please check.';      
        List<PlaceNPSOrder.NPSServiceCallResult> result = PlaceNPSOrder.sendOrdersToNPS(new List<Id>(orderIds));

        System.assertEquals(500,  result[0].statuscode , 'NPS Service call failed due to order count is more than 30');        
        System.assertEquals(expectedError,  result[0].message , 'NPS Service call failed due to order count is more than 30');        
        Test.stopTest();
    }
}