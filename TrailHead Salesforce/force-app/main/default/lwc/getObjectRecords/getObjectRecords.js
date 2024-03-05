import { LightningElement, wire, track } from 'lwc';
import getRecentRecords from '@salesforce/apex/RecentRecordsController.getRecentRecords';
import getObjectFields from '@salesforce/apex/RecentRecordsController.getObjectFields';
import { NavigationMixin } from 'lightning/navigation';

export default class RecentRecordsComponent extends NavigationMixin(LightningElement) {
    @track selectedEntity = '';
    @track selectedRecordCount = 5;
    maxRecords = 10;
    entityOptions = [{ label: 'Account', value: 'Account' }, { label: 'Contact', value: 'Contact' }, { label: 'Opportunity', value: 'Opportunity' }];
    columns = []; // Columns dynamically populated based on entity
    selectedColumns = []; // Selected columns by the user

    @wire(getRecentRecords, { selectedEntity: '$selectedEntity', selectedRecordCount: '$selectedRecordCount' })
    recentRecords;

    @wire(getObjectFields, { objectName: '$selectedEntity' })
    wiredObjectFields({ data, error }) {
        if (data) {
            this.columns = data.map(field => {
                return {
                    label: field.label,
                    fieldName: field.fieldName,
                    type: field.dataType
                };
            });
        } else if (error) {
            console.error('Error loading fields for entity:', error);
        }
    }

    handleEntityChange(event) {
        this.selectedEntity = event.detail.value;
    }

    handleRecordCountChange(event) {
        this.selectedRecordCount = parseInt(event.target.value, 10);
    }

    handleColumnChange(event) {
        const checked = event.target.checked;
        const fieldName = event.target.value;

        if (checked) {
            this.selectedColumns = [...this.selectedColumns, fieldName];
        } else {
            this.selectedColumns = this.selectedColumns.filter(col => col !== fieldName);
        }
    }

    isSelectedColumn(fieldName) {
        return this.selectedColumns.includes(fieldName);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const recordId = event.detail.row.Id;

        if (action.name === 'edit') {
            this.navigateToRecordEditPage(recordId);
        }
    }

    navigateToRecordEditPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit'
            }
        });
    }
}