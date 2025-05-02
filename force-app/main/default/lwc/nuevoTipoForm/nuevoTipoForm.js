import { LightningElement, api } from 'lwc';

export default class NuevoTipoForm extends LightningElement {
    @api marca = '';
    @api capacidad = '';
    @api precio = '';

    handleMarcaChange(event) {
        this.marca = event.target.value;
    }

    handleCapacidadChange(event) {
        this.capacidad = event.target.value;
    }

    handlePrecioChange(event) {
        this.precio = event.target.value;
    }

    handleConfirmar() {
        // Validar que los campos tengan valor
        if (!this.marca || !this.capacidad || !this.precio) {
            // Disparar evento de error
            this.dispatchEvent(new CustomEvent('error', {
                detail: 'Error faltan datos o estos son inválidos.'
            }));
            return;
        }

        // Crear objeto con datos del nuevo tipo
        const nuevoTipo = {
            Name: this.marca,
            Capacidad__c: parseInt(this.capacidad),
            Precio_de_Lista__c: parseFloat(this.precio)
        };

        // Disparar evento de confirmación con los datos
        this.dispatchEvent(new CustomEvent('confirmartipo', {
            detail: nuevoTipo
        }));
    }

    @api
    resetForm() {
        this.marca = '';
        this.capacidad = '';
        this.precio = '';
    }
}