public class GenerarBitlyJob implements Queueable, Database.AllowsCallouts {

    private Id tanqueId;

    public GenerarBitlyJob(Id tanqueId) {
        this.tanqueId = tanqueId;
    }

    public void execute(QueueableContext context) {
        try {
            Tanque_Industrial__c tanque = [
                SELECT Id, Name FROM Tanque_Industrial__c WHERE Id = :tanqueId LIMIT 1
            ];

            String url = System.URL.getOrgDomainUrl().toExternalForm() +
                '/lightning/r/Tanque_Industrial__c/' + tanque.Id + '/view';

            
                BitlyService bitly = new BitlyService();
                String shortLink = bitly.acortarUrl(url);

            if (shortLink != null) {
                tanque.Short_Link__c = shortLink;
                update tanque;
            }
        } catch (Exception e) {
            System.debug('💥 Error en Queueable Bitly: ' + e.getMessage());
        }
    }
}
