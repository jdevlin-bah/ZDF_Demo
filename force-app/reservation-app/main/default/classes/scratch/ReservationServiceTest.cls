@isTest
public class ReservationServiceTest {
    
    private static Map<Id,ZD_Record> insertedRecords = new Map<Id,ZD_Record>();

    /**
     * Here we will mock a single void method. 
     * Steps:
     * 1. Create reservations with deposits 0, 250, 500, and 750 dollars
     * 2. classify them normally
     * 3. start mocking and set the classify method to run the StubInvocable TestClassifyMethod with true. This
     *    always sets VIP__c to true
     * 4. reset the values
     * 5. run the classify method again.
     * 6. assert that all the reservations are marked as VIP__c = true
     */
    @isTest
    public static void mockSingleVoidMethod(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService svc = new ReservationService();
        //run the code normally
        List<ZD_Record> reservationsList = new List<ZD_Record>();
        for(Integer i = 0; i < 1000; i += 250){
            ZD_Record res = new ZD_Record('Reservation__c');
            res.put('Deposit_Amount__c', i);
            res.put('VIP__c', false);
            reservationsList.add(res);
            svc.call('classify', new Map<String,Object>{'record' => res});
        }
        Assert.isFalse(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should not be VIP');
        Assert.isFalse(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should not be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should be VIP');

        //now mock the classify method, its a default so it will now default to this code
        ZD_Application.startMocking();
        svc.when('classify').thenExecute(new TestClassifyMethod(true));
        ZD_Application.stopMocking();

        //clear the list to start again
        reservationsList.clear();
        for(Integer i = 0; i < 1000; i += 250){
            ZD_Record res = new ZD_Record('Reservation__c');
            res.put('Deposit_Amount__c', i);
            res.put('VIP__c', false);
            reservationsList.add(res);
            svc.call('classify', new Map<String,Object>{'record' => res});
        }
        
        //the results are different;
        Assert.isTrue(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should be VIP');
    }

    /**
     * Here we will mock a single void method with different args
     * Steps:
     * 1. Create reservations with deposits 0, 250, 500, and 750 dollars
     * 2. classify them normally
     * 3. start mocking and set the classify method to run the StubInvocable TestClassifyMethod with false 
     *    for reservation at index 1, and true for all other reservations.
     * 4. reset the values
     * 5. run the classify method again.
     * 6. assert that all the reservations are marked as VIP__c = true except index 1
     */
    @isTest
    public static void mockSingleVoidMethod_withDifferentArgs(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService svc = new ReservationService();
        //run the code normally
        List<ZD_Record> reservationsList = new List<ZD_Record>();
        for(Integer i = 0; i < 1000; i += 250){
            ZD_Record res = new ZD_Record('Reservation__c');
            res.put('Deposit_Amount__c', i);
            res.put('VIP__c', false);
            reservationsList.add(res);
            svc.call('classify', new Map<String,Object>{'record' => res});
        }

        Assert.isFalse(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should not be VIP');
        Assert.isFalse(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should not be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should be VIP');

        //now mock the classify method
        ZD_Application.startMocking();
        svc.when('classify').with(new Map<String,Object>{'record' => reservationsList[0]}).thenExecute(new TestClassifyMethod(true));
        svc.when('classify').with(new Map<String,Object>{'record' => reservationsList[1]}).thenExecute(new TestClassifyMethod(false));
        svc.when('classify').with(new Map<String,Object>{'record' => reservationsList[2]}).thenExecute(new TestClassifyMethod(true));
        svc.when('classify').with(new Map<String,Object>{'record' => reservationsList[3]}).thenExecute(new TestClassifyMethod(true));
        ZD_Application.stopMocking();

        //the results are different
        for(Integer i = 0; i < 4; i ++){
            svc.call('classify', new Map<String,Object>{'record' => reservationsList[i]});
        }
        Assert.isTrue(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should be VIP');
        Assert.isFalse(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should not be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should be VIP');
    }

    /**
     * Here we will test error handling by forcing an exception to be thrown
     * for a particular record
     * Steps:
     * 1. Create reservations with deposits 0, 250, 500, and 750 dollars
     * 2. classify them normally
     * 3. start mocking and set the classify method to throw a TestException 
     *    for reservation at index 3
     * 4. reset the values
     * 5. run the classify method again.
     * 6. assert that all the reservations are normal except index 3, it had an error occur (expected)
     */
    @isTest
    public static void mockMethodByThrowingException(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService svc = new ReservationService();
        //run the code normally
        List<ZD_Record> reservationsList = new List<ZD_Record>();
        for(Integer i = 0; i < 1000; i += 250){
            ZD_Record res = new ZD_Record('Reservation__c');
            res.put('Deposit_Amount__c', i);
            res.put('Name', 'Test');
            res.put('VIP__c', false);
            reservationsList.add(res);
        }
        svc.call('setVIP', new Map<String,Object>{'records' => reservationsList});

        Assert.isFalse(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should not be VIP');
        Assert.isFalse(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should not be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(String.valueOf(reservationsList[2].get('Name')).startsWith('VIP'), 'Name should start with VIP now');
        Assert.isTrue(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(String.valueOf(reservationsList[3].get('Name')).startsWith('VIP'), 'Name should start with VIP now');

        //reset the VIP and name fields
        for(ZD_Record res : reservationsList){
            res.put('VIP__c', false);
            res.put('Name', 'Test');
        }

        //mock the classify method to throw an exception for reservation at index 3
        ZD_Application.startMocking();
        svc.when('classify').with(new Map<String,Object>{'record' => reservationsList[3]}).thenThrowException(new TestException('ERROR!'));
        ZD_Application.stopMocking();

        svc.call('setVIP', new Map<String,Object>{'records' => reservationsList});
        
        Assert.isFalse(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should not be VIP');
        Assert.isFalse(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should not be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(String.valueOf(reservationsList[2].get('Name')).startsWith('VIP'), 'Name should start with VIP now');
        Assert.isFalse(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should not be VIP');
        Assert.areEqual('Error Computing Result', String.valueOf(reservationsList[3].get('Name')), 'Name should be Error Computing Result');
    }


    /**
     * Here we will insert into a list instead of the database
     * Steps:
     * 1. Create reservation
     * 2. mock the ZD_DatabaseService insert method to execute the MockInserter class instead
     * 3. run the createReminderTasks method and commit the transaction it is stored in
     * 4. Assert that instead of inserted into the database, the record is part of the list.
     */
    @isTest
    public static void testMethodWithDMLInMemory(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService svc = new ReservationService();
        ZD_Record res = new ZD_Record('Reservation__c');
        res.put('Date_and_Time__c', System.now().addDays(4));
        res.Id = ZD_Application.util.getFakeId('0Re');
        ZD_VirtualCallable dbSvc = (ZD_VirtualCallable) ZD_CallableFactory.getFactory().getCallableInstance('ZD_DatabaseService');

        //instead of inserting into the database, we will execute the mock inserter
        ZD_Application.startMocking();
        dbSvc.when('insert').thenExecute(new MockInserter());
        ZD_Application.stopMocking();

        //call the service normally, its not mocked, only the db service is
        svc.call('createReminderTasks', new Map<String,Object>{'records' => new List<ZD_Record>{res}});
        ZD_Transaction zdt = ZD_Transaction.factory.getInstance('RMS', new List<String>{'Reservation__c', 'Task'});
        zdt.commitTransaction();
        Assert.areEqual(1, insertedRecords.keySet().size(), '1 task should be created');
    }

    /**
     * Here we will override an entire instance with a mock instance for easier
     * testing. It is faster than the httpCalloutMock
     * Steps:
     * 1. Create reservation
     * 2. mock the ZD_DatabaseService insert method to execute the MockInserter class instead
     * 3. instantiate a ZD_VirtualCallable to replace the chatGPTService and have it return a value for the doCallout method
     * 4. put the instance in the factory
     * 5. run the createReminderTasks method and commit the transaction it is stored in
     * 6. Assert that instead of inserted into the database, the record is part of the list and
     *    that the value from the mocked callout matches.
     */
    @isTest
    public static void testMockEntireInstance(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService svc = new ReservationService();
        ZD_Record res = new ZD_Record('Reservation__c');
        res.put('Date_and_Time__c', System.now().addDays(4));
        res.put('VIP__c', true);
        res.Id = ZD_Application.util.getFakeId('0Re');
        ZD_VirtualCallable dbSvc = (ZD_VirtualCallable) ZD_CallableFactory.getFactory().getCallableInstance('ZD_DatabaseService');

        
        ZD_Application.startMocking();
        //VirtualCallable is virtual, so it can be instantiated
        ZD_VirtualCallable mockChatGPTService = new ZD_VirtualCallable();
        mockChatGPTService.when('doCallout').thenReturn('this is a mocked callout');
        //putting the mocked instance in my factory so when its retrieved later it grabs the mock instance instead of the real one
        ZD_CallableFactory.getFactory().callableInstanceMap.put('ChatGPTService', mockChatGPTService);
        //instead of inserting into the database, we will execute the mock inserter
        dbSvc.when('insert').thenExecute(new MockInserter());
        ZD_Application.stopMocking();

        //call the service normally, its not mocked, only only its depdendencies are
        Test.startTest();
        svc.call('createVIPTasks', new Map<String,Object>{'records' => new List<ZD_Record>{res}});
        Test.stopTest();
        Assert.areEqual(1, insertedRecords.keySet().size(), '1 task should be created');
    }

    /**
     * here we will be able to chain multiple queueable jobs. this is an advantage over
     * current tests that can only do 1.
     * Steps:
     * 1. Create 2 reservations
     * 2. mock the ZD_DatabaseService insert method to execute the MockInserter class instead
     * 3. instantiate a ZD_VirtualCallable to replace the chatGPTService and have it return a value for the doCallout method
     * 4. put the instance in the factory
     * 5. mock the createVIPTasks runner method to run the CreateVIPTasksTestRunner class
     * 6. Assert two tasks got created (impossible without mocking in a unit test)
     */
    @isTest
    public static void testMultipleQueueableJobs(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService svc = new ReservationService();
        ZD_Record res1 = new ZD_Record('Reservation__c');
        res1.put('Date_and_Time__c', System.now().addDays(4));
        res1.put('VIP__c', true);
        res1.Id = ZD_Application.util.getFakeId('0Re');
        ZD_Record res2 = new ZD_Record('Reservation__c');
        res2.put('Date_and_Time__c', System.now().addDays(5));
        res2.put('VIP__c', true);
        res2.Id = ZD_Application.util.getFakeId('0Re');
        ZD_VirtualCallable dbSvc = (ZD_VirtualCallable) ZD_CallableFactory.getFactory().getCallableInstance('ZD_DatabaseService');

        
        ZD_Application.startMocking();
        //VirtualCallable is virtual, so it can be instantiated
        ZD_VirtualCallable mockChatGPTService = new ZD_VirtualCallable();

        //rather than writing a class definition, we can say what the method
        mockChatGPTService.when('doCallout').thenReturn('this is a mocked callout');

        //putting the mocked instance in my factory so when its retrieved later it grabs the mock instance instead of the real one
        ZD_CallableFactory.getFactory().callableInstanceMap.put('ChatGPTService', mockChatGPTService);
        
        //instead of calling createVIP directly, we will mock it and have some other apex run
        svc.when('createVIPTasks').thenExecute(new CreateVIPTasksTestRunner());

        //instead of inserting into the database, we will execute the mock inserter
        dbSvc.when('insert').thenExecute(new MockInserter());

        ZD_Application.stopMocking();

        //call the service normally, its not mocked, only only its depdendencies are
        Test.startTest();
        svc.call('createVIPTasks', new Map<String,Object>{'records' => new List<ZD_Record>{res1, res2}});
        Test.stopTest();
        Assert.areEqual(2, insertedRecords.keySet().size(), '2 tasks should be created');
    }
    
    /**
     * here we will show what happens when we reference code that we depend on in a test that doesnt
     * have the code deployed. we get an error if the code doesnt exist
     * Steps:
     * 1. put a value in the init_methods config so we can call our dependency via reflection
     * 2. instantiate the service
     * 3. assert on the error (or lack of if the code exists)
     */
    @isTest
    public static void testWithoutDependency_Fail(){
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'init_methods', 'buildReservationsMap'));

        Type t = Type.forName('QueryService');
        Exception ex;
        try{
            ReservationService svc = new ReservationService();
            if(t == null){
                Assert.fail('if the type is null, QueryService doesnt exist and this should fail');
            }
        }catch(ZD_Application.ApplicationException e){
            ex = e;
        }
        if(t == null){
            Assert.isTrue(ex.getMessage().contains('The class QueryService does not exist in the org'), 'Wrong application exception');
        }else{
            Assert.isNull(ex, 'exception should not have been thrown here');
        }
    }

    /**
     * here we will show how to work around that dependency
     * Steps:
     * 1. put a value in the init_methods config so we can call our dependency via reflection
     * 2. create reservations
     * 3. create a mock instance of the query service
     * 4. set the mockQueryService in the factory
     * 5. mock the query method from the db service 
     * 6. mock the required custom metadata records
     * 7. instantiate the serivce
     * 8. call the setVip method
     * 9. assert on the results as normal
     */
    @isTest
    public static void testWithoutDependency_Success(){
        List<ZD_Record> reservationsList = new List<ZD_Record>();
        Id customerId = ZD_Application.util.getFakeId('003');
        for(Integer i = 0; i < 1000; i += 250){
            ZD_Record res = new ZD_Record('Reservation__c');
            res.put('Deposit_Amount__c', i);
            res.put('Name', 'Test');
            //same customer
            res.put('Customer__c', customerId);
            res.put('VIP__c', false);
            reservationsList.add(res);
        }
        //mock the query service for this test and just return the built query
        ZD_Application.startMocking();
        
        ZD_VirtualCallable mockQueryService = new ZD_VirtualCallable();
        mockQueryService.when('build').thenReturn('SELECT Customer__c FROM Reservation__c WHERE Date_and_Time__c = Last_N_Days:30');
        ZD_CallableFactory.getFactory().callableInstanceMap.put('QueryService', mockQueryService);
        
        ZD_VirtualCallable dbService = (ZD_VirtualCallable) ZD_CallableFactory.getFactory().getCallableInstance('ZD_DatabaseService');
        dbService.when('queryAsZDRecords') 
                 .with(new Map<String,Object>{'query' => 'SELECT Customer__c FROM Reservation__c WHERE Date_and_Time__c = Last_N_Days:30'})
                 .thenReturn(reservationsList);
        ZD_Application.stopMocking();

        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'vip_threshold', '500'));
        ReservationService.config.cache.addToCache(new ZD_Configuration.Setting('RMS', 'init_methods', 'buildReservationsMap'));
        ReservationService svc = new ReservationService();

        Test.startTest();
        svc.call('setVIP', new Map<String,Object>{'records' => reservationsList});
        Test.stopTest();
        
        //all vip
        Assert.isTrue(Boolean.valueOf(reservationsList[0].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[1].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[2].get('VIP__c')), 'Should be VIP');
        Assert.isTrue(Boolean.valueOf(reservationsList[3].get('VIP__c')), 'Should be VIP');
    }

    class TestClassifyMethod extends ZD_Application.StubInvocable{

        private Boolean isVIP;

        public TestClassifyMethod(Boolean isVIP){
            this.isVIP = isVIP;
        }

        public override void handleMethodCall(String action, Map<String,Object> args){
            ZD_Record record = (ZD_Record)args.get('record');
            record.put('VIP__c', this.isVIP);
        }
    }

    class MockInserter extends ZD_Application.StubInvocable{

        public override void handleMethodCall(String action, Map<String,Object> args){
            List<ZD_Record> records = args.get('records') instanceof List<SObject> 
                                ? ZD_Record.toRecords((List<SObject>)args.get('records')) 
                                : (List<ZD_Record>) args.get('records');
            for(ZD_Record record : records){
                record.Id = ZD_Application.util.getFakeId('0Re');
                insertedRecords.put(record.Id, record);
            }
        }
    }

    class CreateVIPTasksTestRunner extends ZD_Application.StubInvocable{

        public override void handleMethodCall(String action, Map<String,Object> args){
            List<ZD_Record> records = args.get('records') instanceof List<SObject> 
                                ? ZD_Record.toRecords((List<SObject>)args.get('records')) 
                                : (List<ZD_Record>) args.get('records');
            for(ZD_Record record : records){
                new ReservationService.VIPTaskQueueable(record).execute(null);
            }
        }
    }

    class TestException extends Exception{}
}