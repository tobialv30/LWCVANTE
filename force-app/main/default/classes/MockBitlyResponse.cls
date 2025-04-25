@isTest
global class MockBitlyResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(201); 
        res.setBody('{"link":"https://bit.ly/mockGenerated"}');
        return res;
    }
}

