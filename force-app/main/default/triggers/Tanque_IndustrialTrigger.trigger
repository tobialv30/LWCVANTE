trigger Tanque_IndustrialTrigger on Tanque_Industrial__c (after insert) {
    
        if (Trigger.isAfter && Trigger.isInsert && Trigger.new.size() == 1) {
            System.enqueueJob(new GenerarBitlyJob(Trigger.new[0].Id));
        }

}
