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
        //System.enqueueJob(new GenerarBitlyJob(tanque.Id));
        //El trigger se ejecuta automáticamente al insertar el tanque
        System.Test.stopTest();

        // Verificar que se haya actualizado el campo
        Tanque_Industrial__c result = [SELECT Short_Link__c FROM Tanque_Industrial__c WHERE Id = :tanque.Id];
        System.assertEquals('https://bit.ly/mockGenerated', result.Short_Link__c, 'El link corto no fue asignado correctamente');
    }

    @isTest
    static void testBatchNoShortLink() {
        // Crear tanques para el batch
        List<Tanque_Industrial__c> tanques = new List<Tanque_Industrial__c>();
        
        for (Integer i = 0; i < 10; i++) {
            tanques.add(new Tanque_Industrial__c(
                Name = 'TanqueBatch',
                Estado__c = 'Disponible'
            ));
        }


        // Ejecutar el batch
        System.Test.startTest();
        Database.executeBatch(new BatchWrapper(tanques), 200);
        System.Test.stopTest();

        // Verificar que el campo Short_Link__c esté vacío
        List<Tanque_Industrial__c> result = [SELECT Short_Link__c FROM Tanque_Industrial__c WHERE Id IN :tanques];
        Integer count = [SELECT COUNT() FROM Tanque_Industrial__c ];
        for (Tanque_Industrial__c tanque : result) {
            System.assertEquals(null, tanque.Short_Link__c, 'El campo Short_Link__c no debería haberse llenado en el batch');
        }
        System.assertEquals(10, count, 'El número de tanques es correcto');
    }
}
