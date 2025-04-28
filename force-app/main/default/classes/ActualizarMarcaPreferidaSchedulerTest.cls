@isTest
private class ActualizarMarcaPreferidaSchedulerTest {
    
    @isTest
    static void testActualizarMarcaPreferida() {
        // 1. Crear datos de prueba
        
        // Crear cuentas
        Account cuenta1 = new Account(Name = 'Cuenta Test 1');
        insert cuenta1;
        
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
        
        insert new List<Tanque_Industrial__c>{tanque1, tanque2, tanque3};
        
        // Crear oportunidades ganadas
        Opportunity opp1 = new Opportunity(
            Name = 'Opp 1',
            AccountId = cuenta1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Tanque_Industrial__c = tanque1.Id,
            Capacidad__c = 100
        );
        
        Opportunity opp2 = new Opportunity(
            Name = 'Opp 2',
            AccountId = cuenta1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Tanque_Industrial__c = tanque2.Id,
            Capacidad__c = 200
        );
        
        Opportunity opp3 = new Opportunity(
            Name = 'Opp 3',
            AccountId = cuenta1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Tanque_Industrial__c = tanque3.Id,
            Capacidad__c = 100
        );
        
        // Las insertas
        insert new List<Opportunity>{opp1, opp2, opp3};
        
        // 2. Iniciar test y programar la ejecución
        Test.startTest();
        
        // Programar la ejecución del job
        String jobId = System.schedule(
            'Test Actualizar Marca Preferida',
            '0 0 0 * * ?', // Expresión Cron (medianoche)
            new ActualizarMarcaPreferidaScheduler()
        );
        
        // Esto fuerza la ejecución del job programado inmediatamente
        Test.stopTest();
        
        // 3. Verificar resultados
        Account cuentaActualizada = [
            SELECT Id, Marca_Preferida__c 
            FROM Account 
            WHERE Id = :cuenta1.Id
        ];
        
        // La Marca A debería ser la preferida (aparece 2 veces vs 1 vez la Marca B)
        System.assertEquals('Marca A', cuentaActualizada.Marca_Preferida__c, 
                           'La marca preferida debería ser Marca A');
    }
    
    @isTest
    static void testSinOportunidadesGanadas() {
        // Probar cuando no hay oportunidades ganadas
        Account cuenta = new Account(Name = 'Cuenta Sin Opps');
        insert cuenta;
        
        Test.startTest();
        String jobId = System.schedule(
            'Test Sin Opps',
            '0 0 0 * * ?',
            new ActualizarMarcaPreferidaScheduler()
        );
        Test.stopTest();
        
        // Verificar que no haya cambios
        Account cuentaActualizada = [SELECT Id, Marca_Preferida__c FROM Account WHERE Id = :cuenta.Id];
        System.assertEquals(null, cuentaActualizada.Marca_Preferida__c, 
                           'No debería haberse actualizado la marca preferida');
    }
    
    @isTest
    static void testDiferentesEtapasOportunidad() {
        // Este test verifica que solo se consideren las oportunidades Closed Won
        
        // Crear datos de prueba
        Account cuenta = new Account(Name = 'Cuenta Test Etapas');
        insert cuenta;
        
        // Crear registros de Tipo_de_tanque__c
        Tipo_de_tanque__c tipoTanque1 = new Tipo_de_tanque__c(
            Name = 'Marca C',
            Capacidad__c = 300,
            Precio_de_Lista__c = 9000
        );
        
        Tipo_de_tanque__c tipoTanque2 = new Tipo_de_tanque__c(
            Name = 'Marca D',
            Capacidad__c = 400,
            Precio_de_Lista__c = 11000
        );
        
        insert new List<Tipo_de_tanque__c>{tipoTanque1, tipoTanque2};
        
        // Crear tanques industriales
        Tanque_Industrial__c tanque1 = new Tanque_Industrial__c(
            Name = 'SN101',
            Tipo_de_tanque__c = tipoTanque1.Id,
            Estado__c = 'Disponible'
        );
        
        Tanque_Industrial__c tanque2 = new Tanque_Industrial__c(
            Name = 'SN102',
            Tipo_de_tanque__c = tipoTanque2.Id,
            Estado__c = 'Disponible'
        );
        
        insert new List<Tanque_Industrial__c>{tanque1, tanque2};
        
        // Crear oportunidades con diferentes estados
        Opportunity oppGanada = new Opportunity(
            Name = 'Opp Ganada',
            AccountId = cuenta.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Tanque_Industrial__c = tanque1.Id,
            Capacidad__c = 300
        );
        
        Opportunity oppPendiente = new Opportunity(
            Name = 'Opp Pendiente',
            AccountId = cuenta.Id,
            StageName = 'Negotiation',  // Una etapa que no es Closed Won
            CloseDate = Date.today().addDays(30),
            Tanque_Industrial__c = tanque2.Id,
            Capacidad__c = 400
        );
        
        insert new List<Opportunity>{oppGanada, oppPendiente};
        
        Test.startTest();
        
        // Ejecutar el scheduler
        ActualizarMarcaPreferidaScheduler scheduler = new ActualizarMarcaPreferidaScheduler();
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verificar resultados
        Account cuentaActualizada = [SELECT Id, Marca_Preferida__c FROM Account WHERE Id = :cuenta.Id];
        System.assertEquals('Marca C', cuentaActualizada.Marca_Preferida__c, 
                           'Solo debería considerarse la oportunidad Closed Won con Marca C');
    }
}