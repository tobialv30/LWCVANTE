// Paso 1: Borrar Tanques Industriales
List<Tanque_Industrial__c> tanques = [SELECT Id FROM Tanque_Industrial__c LIMIT 10000];
if (!tanques.isEmpty()) {
    delete tanques;
    System.debug('✅ Tanques Industriales borrados: ' + tanques.size());
}

// Paso 5: Borrar Tipos de Tanques
List<Tipo_de_Tanque__c> tipos = [SELECT Id FROM Tipo_de_Tanque__c LIMIT 10000];
if (!tipos.isEmpty()) {
    delete tipos;
    System.debug('✅ Tipos de Tanque borrados: ' + tipos.size());
}


// Paso 2: Borrar Oportunidades
List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 10000];
if (!opps.isEmpty()) {
    delete opps;
    System.debug('✅ Oportunidades borradas: ' + opps.size());
}

// Paso 3: Borrar Leads
List<Lead> leads = [SELECT Id FROM Lead LIMIT 10000];
if (!leads.isEmpty()) {
    delete leads;
    System.debug('✅ Leads borrados: ' + leads.size());
}

// Paso 4: Borrar Accounts
List<Account> accounts = [SELECT Id FROM Account LIMIT 10000];
if (!accounts.isEmpty()) {
    delete accounts;
    System.debug('✅ Accounts borradas: ' + accounts.size());
}

