@isTest
public class ActualizarMarcaPreferidaHelperTest {

    @isTest
    static void testActualizarMarca() {
        // Crear cuentas de prueba
        Account acc1 = new Account(Name = 'Cuenta 1');
        Account acc2 = new Account(Name = 'Cuenta 2');
        insert new List<Account>{acc1, acc2};
        
        // Crear registros de Tipo_de_tanque__c
        Tipo_de_tanque__c tipoTanque1 = new Tipo_de_tanque__c(
            Name = 'Marca A',
            Capacidad__c = 100,
            Precio_de_Lista__c = 5000
        );
        
        Tipo_de_tanque__c tipoTanque2 = new Tipo_de_tanque__c(
            Name = 'Marca B',
            Capacidad__c = 200,
            Precio_de_Lista__c = 7000
        );
        
        insert new List<Tipo_de_tanque__c>{tipoTanque1, tipoTanque2};
        
        // Crear tanques industriales
        Tanque_Industrial__c tanque1 = new Tanque_Industrial__c(
            Name = 'SN001',
            Tipo_de_tanque__c = tipoTanque1.Id,
            Estado__c = 'Disponible'
        );
        
        Tanque_Industrial__c tanque2 = new Tanque_Industrial__c(
            Name = 'SN002',
            Tipo_de_tanque__c = tipoTanque2.Id,
            Estado__c = 'Disponible'
        );
        
        Tanque_Industrial__c tanque3 = new Tanque_Industrial__c(
            Name = 'SN003',
            Tipo_de_tanque__c = tipoTanque1.Id,
            Estado__c = 'Disponible'
        );
        
        Tanque_Industrial__c tanque4 = new Tanque_Industrial__c(
            Name = 'SN004',
            Tipo_de_tanque__c = tipoTanque2.Id,
            Estado__c = 'Disponible'
        );

        insert new List<Tanque_Industrial__c>{tanque1, tanque2, tanque3,tanque4};
        
        // Crear oportunidades asociadas a las cuentas
        Opportunity opp1 = new Opportunity(
            Name = 'Opp 1',
            AccountId = acc1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            MarcaComprada__c = 'Marca A',
            Tanque_Industrial__c = tanque1.Id,
            Capacidad__c = 200
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opp 2',
            AccountId = acc1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            MarcaComprada__c = 'Marca B',
            Tanque_Industrial__c = tanque2.Id,
            Capacidad__c = 200
        );
        Opportunity opp3 = new Opportunity(
            Name = 'Opp 3',
            AccountId = acc1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            MarcaComprada__c = 'Marca A',
            Tanque_Industrial__c = tanque3.Id,
            Capacidad__c = 200
        );
        Opportunity opp4 = new Opportunity(
            Name = 'Opp 4',
            AccountId = acc2.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            MarcaComprada__c = 'Marca C',
            Tanque_Industrial__c = tanque4.Id,
            Capacidad__c = 200
        );
        
        insert new List<Opportunity>{opp1, opp2, opp3, opp4};

        // Verificar que las marcas preferidas se hayan actualizado correctamente
        Account updatedAcc1 = [SELECT Marca_Preferida__c FROM Account WHERE Id = :acc1.Id];
        Account updatedAcc2 = [SELECT Marca_Preferida__c FROM Account WHERE Id = :acc2.Id];

        System.assertEquals('Marca A', updatedAcc1.Marca_Preferida__c, 'La marca preferida de la cuenta 1 es la esperada');
        System.assertEquals('Marca C', updatedAcc2.Marca_Preferida__c, 'La marca preferida de la cuenta 2 es la esperada');
    }
}