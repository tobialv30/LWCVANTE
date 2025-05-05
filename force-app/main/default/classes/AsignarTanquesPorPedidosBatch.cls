
global class AsignarTanquesPorPedidosBatch implements Database.Batchable<SObject>, Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AsignarTanquesPorPedidosBatch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Tipo_de_tanque__c, Opportunity__c
            FROM Pedido__c
            WHERE Estado__c = 'Pendiente'
            AND Tipo_de_tanque__c != NULL
            AND Opportunity__c != NULL
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Pedido__c> pedidos) {
        // 1. Recolectar tipos de tanque
        Set<Id> tipoIds = new Set<Id>();
        
        for (Pedido__c p : pedidos) {
            tipoIds.add(p.Tipo_de_tanque__c);
        }

        // 2. Traer tanques disponibles agrupados por tipo
        Map<Id, List<Tanque_Industrial__c>> tanquesPorTipo = new Map<Id, List<Tanque_Industrial__c>>();
        
        for (Tanque_Industrial__c tanque : [
            SELECT Id, Name, Tipo_de_tanque__c
            FROM Tanque_Industrial__c
            WHERE Estado__c = 'Disponible'
            AND Tipo_de_tanque__c IN :tipoIds
            ORDER BY Precio_de_Lista__c ASC
        ]) {
            if (!tanquesPorTipo.containsKey(tanque.Tipo_de_tanque__c)) {
                tanquesPorTipo.put(tanque.Tipo_de_tanque__c, new List<Tanque_Industrial__c>());
            }
            tanquesPorTipo.get(tanque.Tipo_de_tanque__c).add(tanque);
        }

        // 3. Procesar pedidos
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Tanque_Industrial__c> tanquesToUpdate = new List<Tanque_Industrial__c>();
        List<Pedido__c> pedidosToUpdate = new List<Pedido__c>();

        for (Pedido__c pedido : pedidos) {
            List<Tanque_Industrial__c> disponibles = tanquesPorTipo.get(pedido.Tipo_de_tanque__c);

            if (disponibles != null && !disponibles.isEmpty()) {
                Tanque_Industrial__c asignado = disponibles.remove(0); // tomar el primero

                oppsToUpdate.add(new Opportunity(
                    Id = pedido.Opportunity__c,
                    Tanque_Industrial__c = asignado.Id,
                    Pedido__c = null
                ));

                tanquesToUpdate.add(new Tanque_Industrial__c(
                    Id = asignado.Id,
                    Estado__c = 'Reservado'
                ));

                pedidosToUpdate.add(new Pedido__c(
                    Id = pedido.Id,
                    Estado__c = 'Completado',
                    Opportunity__c = null
                ));
            }
        }

        if (!oppsToUpdate.isEmpty()) update oppsToUpdate;
        if (!tanquesToUpdate.isEmpty()) update tanquesToUpdate;
        if (!pedidosToUpdate.isEmpty()) update pedidosToUpdate;
    }

    global void finish(Database.BatchableContext bc) {
        // Podés enviar un email si querés o dejarlo vacío
    }
}
