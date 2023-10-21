@isTest
public with sharing class MockResponseNPS implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"sfId": "801Ea00000Abjy9IAB","orderNumber": "2233","customerEmail": "javed@test.com"}');
        res.setStatusCode(200);
        return res;
    }    
}