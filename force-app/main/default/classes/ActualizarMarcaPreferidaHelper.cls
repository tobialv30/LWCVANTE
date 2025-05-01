public class ActualizarMarcaPreferidaHelper {
    
    public static void actualizarMarca(Set<Id> accountIds) {
        // Traer todas las opps Closed Won con MarcaComprada
        List<Opportunity> opps = [
            SELECT Id, AccountId, MarcaComprada__c
            FROM Opportunity
            WHERE StageName = 'Closed Won'
            AND AccountId IN :accountIds
            AND MarcaComprada__c != null
        ];

        // Agrupar por Account
        Map<Id, Map<String, Integer>> marcaCounterByAccount = new Map<Id, Map<String, Integer>>();

        for (Opportunity opp : opps) {
            if (!marcaCounterByAccount.containsKey(opp.AccountId)) {
                marcaCounterByAccount.put(opp.AccountId, new Map<String, Integer>());
            }

            Map<String, Integer> marcaCounter = marcaCounterByAccount.get(opp.AccountId);
            String marca = opp.MarcaComprada__c;

            Integer currentCount = marcaCounter.containsKey(marca) ? marcaCounter.get(marca) : 0;
            marcaCounter.put(marca, currentCount + 1);
        
        
        }

        // Armar lista de Accounts a actualizar
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : marcaCounterByAccount.keySet()) {
            Map<String, Integer> countMap = marcaCounterByAccount.get(accId);
            String topMarca = null;
            Integer maxCount = 0;

            for (String marca : countMap.keySet()) {
                if (countMap.get(marca) > maxCount) {
                    maxCount = countMap.get(marca);
                    topMarca = marca;
                }
            }

            if (topMarca != null) {
                accountsToUpdate.add(new Account(
                    Id = accId,
                    Marca_Preferida__c = topMarca
                ));
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
