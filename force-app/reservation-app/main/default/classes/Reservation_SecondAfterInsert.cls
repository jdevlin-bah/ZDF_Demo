public with sharing class Reservation_SecondAfterInsert implements TriggerAction.afterInsert {
    public void afterInsert(List<SObject> newList) {
        ZD_Transaction zdt = ZD_Transaction.factory.getInstance('RMS', new List<String>{'Reservation__c', 'Task'});
        zdt.commitTransaction();
    }
}