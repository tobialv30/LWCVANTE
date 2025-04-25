public class BatchWrapper implements Database.Batchable<Tanque_Industrial__c> {

    List<Tanque_Industrial__c> tanques;

    public BatchWrapper(List<Tanque_Industrial__c> tanquesInput) {
        this.tanques = tanquesInput;
    }

    public Iterable<Tanque_Industrial__c> start(Database.BatchableContext context) {
        return tanques;
    }

    public void execute(Database.BatchableContext context, List<Tanque_Industrial__c> scope) {
        insert scope;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('✅ Tanques insertados vía batch wrapper.');
    }
}
