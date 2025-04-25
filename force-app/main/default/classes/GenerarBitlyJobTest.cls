@isTest
public class GenerarBitlyJobTest {

    @isTest
    static void testGenerarBitlyQueueable() {
        // Mock para el callout
        System.Test.setMock(HttpCalloutMock.class, new MockBitlyResponse());

        // Crear un tanque que dispare el queueable
        Tanque_Industrial__c tanque = new Tanque_Industrial__c(
            Name = 'TestTanque',
            Estado__c = 'Disponible'
        );
        insert tanque;

        // Ejecutar cola
        System.Test.startTest();
        System.enqueueJob(new GenerarBitlyJob(tanque.Id));
        System.Test.stopTest();

        // Verificar que se haya actualizado el campo
        Tanque_Industrial__c result = [SELECT Short_Link__c FROM Tanque_Industrial__c WHERE Id = :tanque.Id];
        System.assertEquals('https://bit.ly/mockGenerated', result.Short_Link__c, 'El link corto no fue asignado correctamente');
    }
}
