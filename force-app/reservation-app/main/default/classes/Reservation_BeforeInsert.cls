public with sharing class Reservation_BeforeInsert implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<SObject> newList) {
        ZD_CallableFactory.getFactory().getCallableInstance('ReservationService')
                    .call('setVIP', new Map<String,Object>{'records' => newList});
    }
}