@isTest
public class AsignarTanquesPorPedidosBatchTest {

    @isTest
    static void testBatchExecution() {
        // Crear tipo de tanque
        Tipo_de_Tanque__c tipo = new Tipo_de_Tanque__c(Name = 'Tipo Test', Capacidad__c = 100, Precio_de_Lista__c = 200);
        insert tipo;

        // Crear tanque disponible
        Tanque_Industrial__c tanque = new Tanque_Industrial__c(
            Name = 'T123-Test',
            Estado__c = 'Reservado',
            Tipo_de_tanque__c = tipo.Id
        );
        insert tanque;

        // Crear cuenta y oportunidad
        Account cuenta = new Account(Name = 'Cuenta Test');
        insert cuenta;

        // Crear pedido pendiente
        Pedido__c pedido = new Pedido__c(
            Estado__c = 'Pendiente',
            Tipo_de_tanque__c = tipo.Id
        );
        insert pedido;

        Opportunity opp = new Opportunity(
            Name = 'Opp Test',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = cuenta.Id,
            Capacidad__c = 100,
            pedido__c = pedido.Id
        );
        insert opp;
        
        pedido.Opportunity__c = opp.Id;
        update pedido;
        
        // Ejecutar el batch
        Test.startTest();
        
        tanque.Estado__c='Disponible';
        update tanque;

        Database.executeBatch(new AsignarTanquesPorPedidosBatch(), 200);
        Test.stopTest();

        // Verificar updates
        Opportunity updatedOpp = [SELECT Tanque_Industrial__c FROM Opportunity WHERE Id = :opp.Id];
        Pedido__c updatedPedido = [SELECT Estado__c FROM Pedido__c WHERE Id = :pedido.Id];
        Tanque_Industrial__c updatedTanque = [SELECT Estado__c FROM Tanque_Industrial__c WHERE Id = :tanque.Id];

        System.assertNotEquals(null, updatedOpp.Tanque_Industrial__c, 'La oportunidad debería tener tanque asignado');
        System.assertEquals('Completado', updatedPedido.Estado__c, 'El pedido debería estar completado');
        System.assertEquals('Reservado', updatedTanque.Estado__c, 'El tanque debería estar reservado');
    }
}
