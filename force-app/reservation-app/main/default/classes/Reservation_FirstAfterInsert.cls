public with sharing class Reservation_FirstAfterInsert implements TriggerAction.afterInsert {
    public void afterInsert(List<SObject> newList) {
        ZD_CallableFactory.getFactory().getCallableInstance('ReservationService')
                    .call('createReminderTasks', new Map<String,Object>{'records' => newList});
        ZD_CallableFactory.getFactory().getCallableInstance('ReservationService')
                    .call('createVIPTasks', new Map<String,Object>{'records' => newList});
    }
}