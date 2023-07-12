@isTest
public class IntegrationTest {
    @isTest
    public static void runHappyPath(){
        Test.setMock(HttpCalloutMock.class, new ChatGPTMockCallout());
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        insert c;
        
        Reservation__c r = new Reservation__c();
        r.Date_and_Time__c = System.now().addDays(5);
        r.Preferences__c = 'Test Preferences';
        r.Deposit_Amount__c = 500;
        r.Customer__c = c.Id;
        
        Test.startTest();
        insert r;
        Test.stopTest();
        
        r = [SELECT Id, VIP__c FROM Reservation__c LIMIT 1];
        Assert.isTrue(r.VIP__c, 'reservation should be VIP');
        List<Task> tasks = [SELECT Id, WhatId, Subject, Description FROM Task];
        Assert.areEqual(2, tasks.size(), 'Should be 2 tasks created');
        Assert.areEqual('Remind customer about reservation.', tasks[0].Description, 'Reminder task description wrong');
        Assert.areEqual('Test Content', tasks[1].Description, 'Special VIP task description wrong');
    }
    
    public class ChatGPTMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {            
            String response = '{"choices": ['+
                '{' +
                  '"finish_reason": "stop",' +
                  '"index": 0,' +
                  '"message": {' +
                    '"content": "Test Content",' +
                    '"role": "assistant"' +
                  '}' +
                '}' +
              '],' +
              '"created": 1677823794,' +
              '"id": "chatcmpl-6psu2Yl4ZFP5wb1S2CK9bCu7r2fEz",' +
              '"model": "gpt-3.5-turbo-0301",' +
              '"object": "chat.completion",' +
              '"usage": {' +
                '"completion_tokens": 29,' +
                '"prompt_tokens": 54,' +
                '"total_tokens": 83' +
              '}' +
            '}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
}