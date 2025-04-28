global class ActualizarMarcaPreferidaScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        
        // 1. Traer todas las oportunidades Closed Won de una
        List<Opportunity> opps = [
            SELECT Id, AccountId, Tanque_Industrial__r.Marca__c
            FROM Opportunity
            WHERE StageName = 'Closed Won'
            AND AccountId != NULL
            AND Tanque_Industrial__c != NULL
            AND Tanque_Industrial__r.Tipo_de_Tanque__c != NULL
        ];
        
        // 2. Organizar en un Map<AccountId, List<Opportunity>>
        Map<Id, List<Opportunity>> oppsByAccount = new Map<Id, List<Opportunity>>();
        
        for (Opportunity opp : opps) {
            if (!oppsByAccount.containsKey(opp.AccountId)) {
                oppsByAccount.put(opp.AccountId, new List<Opportunity>());
            }
            oppsByAccount.get(opp.AccountId).add(opp);
        }
        
        // 3. Para cada Account, calcular la marca más comprada
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Id accId : oppsByAccount.keySet()) {
            
            Map<String, Integer> marcaCount = new Map<String, Integer>();
            
            for (Opportunity opp : oppsByAccount.get(accId)) {
                
                String marca = opp.Tanque_Industrial__r.Marca__c;
                
                if (marca != null) {
                    if (!marcaCount.containsKey(marca)) {
                        marcaCount.put(marca, 0);
                    }
                    marcaCount.put(marca, marcaCount.get(marca) + 1);
                }
            }
            
            String marcaPreferida = null;
            Integer maxCantidad = 0;
            for (String marca : marcaCount.keySet()) {
                if (marcaCount.get(marca) > maxCantidad) {
                    maxCantidad = marcaCount.get(marca);
                    marcaPreferida = marca;
                }
            }
            
            if (marcaPreferida != null) {
                accountsToUpdate.add(new Account(
                    Id = accId,
                    Marca_Preferida__c = marcaPreferida
                ));
            }
        }
        
        // 4. Update masivo
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}

