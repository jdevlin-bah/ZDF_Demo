import { api, LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { RefreshEvent } from 'lightning/refresh';

export default class TaskCDCListener extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Reservation__c.Name']}) reservation;

    channelName = '/data/TaskChangeEvent';
    subscription = {}; // holds subscription, used for unsubscribe

    connectedCallback() {
        this.registerErrorListener();
        this.registerSubscribe();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, () => console.log('Unsubscribed to change events.'));
    }

    // Called by connectedCallback()
    registerErrorListener() {
        onError(error => {
            console.error('Salesforce error', JSON.stringify(error));
        });
    }

    // Called by connectedCallback()
    registerSubscribe() {
        const changeEventCallback = changeEvent => {
            this.processChangeEvent(changeEvent);
        };

        // Sets up subscription and callback for change events
        subscribe(this.channelName, -1, changeEventCallback).then(subscription => {
            this.subscription = subscription;
        });
    }

    // Called by registerSubscribe()
    processChangeEvent(changeEvent) {
        try {
            const recordIds = changeEvent.data.payload.ChangeEventHeader.recordIds; // avoid deconstruction
            if(changeEvent.data.payload.WhatId === this.recordId && changeEvent.data.payload.Subject.includes('Special Task For VIP')){
                console.log('relevant task found!');
                this.dispatchEvent(new RefreshEvent());
            }
        } catch (err) {
            console.error(err);
        }
    }

}