// recordListHomeComponent.js
import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getAvailableObjects from '@salesforce/apex/RecordListHomeController.getAvailableObjects';
import fetchRecords from '@salesforce/apex/RecordListHomeController.fetchRecords';
import getObjectFields from '@salesforce/apex/RecordListHomeController.getObjectFields';

export default class RecordListHomeComponent extends NavigationMixin(LightningElement) {
    @track selectedEntity;
    @track numberOfRecords = 5;
    @track entityOptions = [];
    @track columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Created By', fieldName: 'CreatedById'  },
        { label: 'Edit', type: 'button', typeAttributes: { label: 'Edit', name: 'edit', title: 'Click to edit record', variant: 'base' } }
    ];
    @track records = [];
    @track error;

    @wire(getAvailableObjects)
    wiredObjects({ error, data }) {
        if (data) {
            this.entityOptions = data.map(obj => ({
                label: obj.label,
                value: obj.apiName
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getObjectFields, { objectName: '$selectedEntity' })
    wiredObjectFields({ data, error }) {
        if (data) {
            this.allColumns = data.map(field => {
                return {
                    label: field.label,
                    value: field.fieldName
                };
            });
        } else if (error) {
            console.error('Error loading fields for entity:', error);
        }
    }

    handleEntityChange(event) {
        this.selectedEntity = event.detail.value;
    }

    handleNumberOfRecordsChange(event) {
        this.numberOfRecords = parseInt(event.target.value, 10);
    }
    
    handleColumnChange(event) {
        this.selectedColumns = event.detail.value;
    }


    handleFetchRecords() {
        if (this.selectedEntity) {
            this.fetchRecordsForSelectedEntity();
        }
    }

    fetchRecordsForSelectedEntity() {
        fetchRecords({ objectApiName: this.selectedEntity, limitRecords: this.numberOfRecords })
            .then(result => {
                this.records = result.map(record => ({
                    ...record,
                    Edit: {
                        label: 'Edit',
                        name: 'edit',
                        title: 'Click to edit record',
                        variant: 'base'
                    }
                }));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        if (actionName === 'edit') {
            const recordId = event.detail.row.Id;
            this.navigateToRecordEditPage(recordId);
        }
    }

    navigateToRecordEditPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: this.selectedEntity,
                actionName: 'edit'
            }
        });
    }
}