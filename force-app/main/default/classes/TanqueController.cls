public with sharing class TanqueController {

    @AuraEnabled
    public static void ejecutarCargaMasivaBatch(Object tanquesJson, Id tipoId) {
        List<Object> rawList = (List<Object>) tanquesJson;
        List<Tanque_Industrial__c> tanques = new List<Tanque_Industrial__c>();
    
        for (Object obj : rawList) {
            Map<Object, Object> fila = (Map<Object, Object>) obj;
    
            tanques.add(new Tanque_Industrial__c(
                Name = String.valueOf(fila.get('numeroDeSerie')),
                Estado__c = String.valueOf(fila.get('estado')),
                Tipo_de_Tanque__c = tipoId
            ));
        }
    
        // Ejecutar el batch pasando la lista directamente
        Database.executeBatch(new BatchWrapper(tanques), 200);
    }
        
    @AuraEnabled
    public static void cargarTanqueIndividual(Object tanqueJson, Id tipoId) {
        Map<Object, Object> t = (Map<Object, Object>) tanqueJson;
    
        String numeroDeSerie = String.valueOf(t.get('numeroDeSerie'));
        String estado = String.valueOf(t.get('estado'));
    
        Tanque_Industrial__c tanque = new Tanque_Industrial__c(
            Name = numeroDeSerie,
            Estado__c = estado,
            Tipo_de_Tanque__c = tipoId
        );
    
        insert tanque;
    }
    

    @AuraEnabled(cacheable=true)
    public static List<Tipo_de_Tanque__c> getTipos() {
        return [SELECT Id, Name FROM Tipo_de_Tanque__c ORDER BY Name];
    }

    @AuraEnabled
    public static Id crearTipoTanque(String marca, Integer capacidad, Decimal precio) {
        Tipo_de_Tanque__c tipo = new Tipo_de_Tanque__c(
            Name = marca,
            Capacidad__c = capacidad,
            Precio_de_Lista__c = precio
        );
        insert tipo;
        return tipo.Id;
    }
}

