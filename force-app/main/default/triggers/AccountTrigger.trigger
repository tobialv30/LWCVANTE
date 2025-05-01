trigger AccountTrigger on Account (after update) {
    
    Set<Id> updatedAccounts = new Set<Id>();

    for (Account acc : Trigger.new) {
        Account old = Trigger.oldMap.get(acc.Id);
        if (acc.Cantidad_de_Tanques_Comprados__c != old.Cantidad_de_Tanques_Comprados__c) {
            updatedAccounts.add(acc.Id);
        }
    }

    if (!updatedAccounts.isEmpty()) {
        ActualizarMarcaPreferidaHelper.actualizarMarca(updatedAccounts);
    }
}
