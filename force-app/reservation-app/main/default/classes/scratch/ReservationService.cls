public with sharing class ReservationService extends ZD_VirtualCallable{
    
    @TestVisible private static ZD_Configuration config{
        get{
            if(ReservationService.config == null){
                ReservationService.config = new ZD_Configuration('RMS');
            }
            return ReservationService.config;
        }
        private set;
    }

    private Map<String,List<ZD_Record>> reservationsMap;

    public ReservationService(){
        List<String> initMethods = ReservationService.config.get('init_methods')?.split(';');
        if(initMethods != null){
            for(String method : initMethods){
                this.call(method);
            }
        }
    }
    
    public override Object doCall(String action, Map<String,Object> args){
        switch on action {
            when 'setvip' {
                List<ZD_Record> records = args.get('records') instanceof List<SObject> ? ZD_Record.toRecords((List<SObject>)args.get('records')) : (List<ZD_Record>) args.get('records');
                this.setVIP(records);
            }
            when 'classify' {
                ZD_Record record = (ZD_Record)args.get('record');
                this.classify(record);
            }
            when 'createremindertasks'{
                List<ZD_Record> records = args.get('records') instanceof List<SObject> ? ZD_Record.toRecords((List<SObject>)args.get('records')) : (List<ZD_Record>) args.get('records');
                this.createReminderTasks(records);
            }
            when 'createviptasks'{
                List<ZD_Record> records = args.get('records') instanceof List<SObject> ? ZD_Record.toRecords((List<SObject>)args.get('records')) : (List<ZD_Record>) args.get('records');
                this.createVIPTasks(records);
            }
            when 'buildreservationsmap'{
                this.buildReservationsMap();
            }
        }
        return null;
    }

    @TestVisible
    private void setVIP(List<ZD_Record> records){
        for(ZD_Record record : records){
            try{
                this.call('classify', new Map<String,Object>{'record' => record});
                if(record.get('VIP__c') == true){
                    record.put('Name', 'VIP: ' + record.get('Name'));
                }
            }catch(Exception e){
                record.put('Name', 'Error Computing Result');
            }
            
        }
    }

    private void buildReservationsMap(){
        //SELECT Customer__c FROM Reservation__c WHERE Date_and_Time__c = Last_N_Days:30
        Callable querySvc = ZD_CallableFactory.getFactory().getCallableInstance('QueryService');
        querySvc.call('setObject', new Map<String,Object>{'objectType' => 'Reservation__c'});
        querySvc.call('selectField', new Map<String,Object>{'field' => 'Customer__c'});
        querySvc.call('withDateLiteralWhereClause', new Map<String,Object>{'field' => 'Date_and_Time__c', 'operator' => 'Last_N_Days', 'value' => 30});
        String query = String.valueOf(querySvc.call('build', null));
        List<ZD_Record> reservations = ZD_DatabaseService.queryAsZDRecords(query);
        if(this.reservationsMap == null){
            this.reservationsMap = new Map<String,List<ZD_Record>>();
            for(ZD_Record res : reservations){
                String customerId = String.valueOf(res.get('Customer__c'));
                if(!this.reservationsMap.containsKey(customerId)){
                    this.reservationsMap.put(customerId, new List<ZD_Record>());
                }
                this.reservationsMap.get(customerId).add(res);
            }
        }
        
    }

    @TestVisible
    private void classify(ZD_Record record){
        Double threshold = Double.valueOf(ReservationService.config.get('vip_threshold'));
        if(Double.valueOf(record.get('Deposit_Amount__c')) >= threshold 
            || this.reservationsMap?.get(String.valueOf(record.get('Customer__c')))?.size() >= 3){
            record.put('VIP__c', true);
        }
    }

    @TestVisible
    private void createReminderTasks(List<ZD_Record> records){
        ZD_Transaction zdt = ZD_Transaction.factory.getInstance('RMS', new List<String>{'Reservation__c', 'Task'});
        for(ZD_Record record : records){
            ZD_Record task = new ZD_Record((SObject) Type.forName('Task').newInstance());
            task.put('WhatId', record.Id);
            task.put('Subject', 'Send Reminder for ' + record.get('Name'));
            DateTime reservationDateTime = (DateTime) record.get('Date_and_Time__c');
            Date reservationDate = Date.newinstance(reservationDateTime.year(), reservationDateTime.month(), reservationDateTime.day());
            task.put('ActivityDate', reservationDate.addDays(-1));
            task.put('Description', 'Remind customer about reservation.');
            zdt.registerUpsert(task);
        }
    }

    @TestVisible
    private void createVIPTasks(List<ZD_Record> records){
        for(ZD_Record record : records){
            if(record.get('VIP__c') == true){
                System.enqueueJob(new VIPTaskQueueable(record));
            }
        }
    }

    public class VIPTaskQueueable implements System.Queueable,Database.AllowsCallouts{

        private ZD_Record reservation;

        public VIPTaskQueueable(ZD_Record reservation){
            this.reservation = reservation;
        }

        public void execute(QueueableContext context) {
            String prompt = 'Be very concise, 500 words or less. Give me, the restaurant owner, '
                            + 'one, single task (nothing more) to make this VIP person '
                            + 'have a good experience based off the fact that they said their preferences are: '
                            + reservation.get('Preferences__c');
            Callable chatGPTSvc = ZD_CallableFactory.getFactory().getCallableInstance('ChatGPTService');
            String response = String.valueOf(chatGPTSvc.call('doCallout', new Map<String,Object>{'prompt' => prompt}));

            ZD_Record task = new ZD_Record((SObject) Type.forName('Task').newInstance());
            task.put('WhatId', reservation.Id);
            task.put('Subject', 'Special Task For ' + reservation.get('Name'));
            DateTime reservationDateTime = (DateTime) reservation.get('Date_and_Time__c');
            Date reservationDate = Date.newInstance(reservationDateTime.year(), reservationDateTime.month(), reservationDateTime.day());
            task.put('ActivityDate', reservationDate);
            task.put('Description', response);
            ZD_DatabaseService.doInsert(new List<ZD_Record>{task});
        }
    }
}