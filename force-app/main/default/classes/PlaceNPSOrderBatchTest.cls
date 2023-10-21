@isTest
public with sharing class PlaceNPSOrderBatchTest {
    @TestSetup    
    static void testData(){
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
    static void placeOrderBatchTest(){
        Set<Id> orderIds = new Map<Id, Order>(([SELECT Id FROM Order])).keySet();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseNPS()); 

        PlaceNPSOrderBatch npsbatch = new PlaceNPSOrderBatch(new List<Id>(orderIds));
        Id batchId = Database.executeBatch(npsbatch, 30); 
        Test.stopTest();        

        

    }

    static void Morethan30BatchSizeTest(){
        List<Order> testOrders = new List<Order>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Testcontact' LIMIT 1];     

        for(integer i=0; i<300; i++){
            Order ord = new Order();
            ord.EffectiveDate = Date.today();
            ord.Status = 'Draft';
            ord.AccountId = con.AccountId;
            ord.BillToContactId = con.Id;
            testOrders.add(ord);
        }
        insert testOrders;

        Set<Id> orderIds = new Map<Id, Order>(([SELECT Id FROM Order])).keySet();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseNPS()); 
        PlaceNPSOrderBatch npsbatch = new PlaceNPSOrderBatch(new List<Id>(orderIds));
        Id batchId = Database.executeBatch(npsbatch, 30); 
        Test.stopTest();        

       
    }
}