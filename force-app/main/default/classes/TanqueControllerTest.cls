@isTest
public class TanqueControllerTest {

    @isTest
    static void testEjecutarCargaMasivaBatch() {
        // Crear un tipo de tanque para asociar
        Tipo_de_Tanque__c tipo = new Tipo_de_Tanque__c(Name = 'TipoTest', Capacidad__c = 1000, Precio_de_Lista__c = 500);
        insert tipo;

        // Crear datos simulados en formato JSON
        List<Object> tanquesJson = new List<Object>{
            (Object) new Map<Object, Object>{'numeroDeSerie' => 'TANQUE001', 'estado' => 'Disponible'},
            (Object) new Map<Object, Object>{'numeroDeSerie' => 'TANQUE002', 'estado' => 'Reservado'}
        };

        // Ejecutar el método
        System.Test.startTest();
        TanqueController.ejecutarCargaMasivaBatch(tanquesJson, tipo.Id);
        System.Test.stopTest();

        // Verificar que los tanques se hayan insertado
        List<Tanque_Industrial__c> tanques = [SELECT Name, Estado__c, Tipo_de_Tanque__c FROM Tanque_Industrial__c WHERE Tipo_de_Tanque__c = :tipo.Id];
        System.assertEquals(2, tanques.size(), 'Se esperaban 2 tanques insertados');
        System.assertEquals('TANQUE001', tanques[0].Name, 'El primer tanque tiene el nombre esperado');
        System.assertEquals('Disponible', tanques[0].Estado__c, 'El primer tanque tiene el estado esperado');
    }

    @isTest
    static void testCargarTanqueIndividual() {
        // Crear un tipo de tanque para asociar
        Tipo_de_Tanque__c tipo = new Tipo_de_Tanque__c(Name = 'TipoTest', Capacidad__c = 1000, Precio_de_Lista__c = 500.00);
        insert tipo;

        // Crear datos simulados en formato JSON
        Map<Object, Object> tanqueJson = new Map<Object, Object>{'numeroDeSerie' => 'TANQUE003', 'estado' => 'Disponible'};

        // Ejecutar el método
        System.Test.startTest();
        TanqueController.cargarTanqueIndividual(tanqueJson, tipo.Id);
        System.Test.stopTest();

        // Verificar que el tanque se haya insertado
        Tanque_Industrial__c tanque = [SELECT Name, Estado__c, Tipo_de_Tanque__c FROM Tanque_Industrial__c WHERE Tipo_de_Tanque__c = :tipo.Id LIMIT 1];
        System.assertEquals('TANQUE003', tanque.Name, 'El tanque tiene el nombre esperado');
        System.assertEquals('Disponible', tanque.Estado__c, 'El tanque tiene el estado esperado');
    }

    @isTest
    static void testGetTipos() {
        // Insertar tipos de tanque
        Tipo_de_Tanque__c tipo1 = new Tipo_de_Tanque__c(Name = 'TipoA', Capacidad__c = 500, Precio_de_Lista__c = 300.00);
        Tipo_de_Tanque__c tipo2 = new Tipo_de_Tanque__c(Name = 'TipoB', Capacidad__c = 1000, Precio_de_Lista__c = 600.00);
        insert new List<Tipo_de_Tanque__c>{tipo1, tipo2};

        // Ejecutar el método
        System.Test.startTest();
        List<Tipo_de_Tanque__c> tipos = TanqueController.getTipos();
        System.Test.stopTest();

        // Verificar que se devuelvan los tipos de tanque
        System.assertEquals(2, tipos.size(), 'Se esperaban 2 tipos de tanque');
        System.assertEquals('TipoA', tipos[0].Name, 'El primer tipo tiene el nombre esperado');
        System.assertEquals('TipoB', tipos[1].Name, 'El segundo tipo tiene el nombre esperado');
    }

    @isTest
    static void testCrearTipoTanque() {
        // Ejecutar el método
        System.Test.startTest();
        Id tipoId = TanqueController.crearTipoTanque('TipoC', 1500, 800.00);
        System.Test.stopTest();

        // Verificar que el tipo de tanque se haya creado
        Tipo_de_Tanque__c tipo = [SELECT Name, Capacidad__c, Precio_de_Lista__c FROM Tipo_de_Tanque__c WHERE Id = :tipoId];
        System.assertEquals('TipoC', tipo.Name, 'El tipo no tiene el nombre esperado');
        System.assertEquals(1500, tipo.Capacidad__c, 'El tipo no tiene la capacidad esperada');
        System.assertEquals(800.00, tipo.Precio_de_Lista__c, 'El tipo no tiene el precio esperado');
    }
}