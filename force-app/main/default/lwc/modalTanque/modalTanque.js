import { LightningElement, api } from 'lwc';

export default class ModalTanque extends LightningElement {
    @api mostrar = false;
    @api titulo = '';
    @api mensaje = '';
    @api variante = 'brand'; // brand para éxito, neutral para error
    @api esError = false;

    get headerClass() {
        return this.esError ? 'slds-modal__header slds-theme_error' : 'slds-modal__header';
    }

    handleCerrar() {
        this.dispatchEvent(new CustomEvent('cerrarmodal'));
    }
}