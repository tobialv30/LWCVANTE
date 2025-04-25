public class BitlyService {
    private static final String BITLY_TOKEN = '69f61b88e362449896656e4cfec41aa695fb5f1d';

    public String acortarUrl(String longUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api-ssl.bitly.com/v4/shorten');
        req.setMethod('POST');
        req.setHeader('Authorization', BITLY_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        Map<String, Object> body = new Map<String, Object>();
        body.put('group_guid', 'Bp4phjZhccx');
        body.put('long_url', longUrl);
        body.put('domain', 'bit.ly');
        
        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);


            Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            string link = (String) json.get('link');
            return link;
        
    }
}
