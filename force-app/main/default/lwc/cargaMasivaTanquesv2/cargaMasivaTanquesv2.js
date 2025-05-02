import { LightningElement, track, wire } from 'lwc';
import getTipos from '@salesforce/apex/TanqueController.getTipos';
import crearTipoTanque from '@salesforce/apex/TanqueController.crearTipoTanque';
import cargarTanqueIndividual from '@salesforce/apex/TanqueController.cargarTanqueIndividual';
import ejecutarCargaMasivaBatch from '@salesforce/apex/TanqueController.ejecutarCargaMasivaBatch';
import papaparseLib from '@salesforce/resourceUrl/papaparser';
import { loadScript } from 'lightning/platformResourceLoader';
import { refreshApex } from '@salesforce/apex';

export default class CargaMasivaTanquesv2 extends LightningElement {
    @track tipoOptions = [];
    tipoWireResult;

    // Wire a getTipos
    @wire(getTipos)
    wiredTipos(result) {
        this.tipoWireResult = result;
        if (result.data) {
            this.tipoOptions = result.data.map(t => ({ label: t.Name, value: t.Id }));
        }
    }

    @track tipoConfirmado = false;
    @track mostrarNuevoTipo = false;
    @track mostrarTipoExistente = false;
    @track mostrarResumenTipoNuevo = false;
    @track pasoActual = '1';

    // Modal properties
    @track mostrarModal = false;
    @track tituloModal = 'Carga Exitosa';
    @track mensajeModal = '✔️ ¡Tanques cargados correctamente!';
    @track varianteModal = 'brand';
    @track esErrorModal = false;

    selectedTipoId = '';
    tipoSeleccionado = null;
    searchTerm = '';

    nuevaMarca = '';
    nuevaCapacidad = '';
    nuevoPrecio = '';

    nuevoTipoPendiente = null;

    csvCargado = false;
    tanquesParseados = [];
    papaparseInitialized = false;

    columnas = [
        { label: 'Número de Serie', fieldName: 'numeroDeSerie' },
        { label: 'Estado', fieldName: 'estado' }
    ];

    activarNuevoTipo() {
        this.resetAll();
        this.mostrarNuevoTipo = true;
    }

    activarTipoExistente() {
        this.resetAll();
        this.mostrarTipoExistente = true;
    }

    resetAll() {
        this.tipoConfirmado = false;
        this.mostrarNuevoTipo = false;
        this.mostrarTipoExistente = false;
        this.mostrarResumenTipoNuevo = false;
        this.pasoActual = '1';
        this.selectedTipoId = '';
        this.tipoSeleccionado = null;
        this.searchTerm = '';
        this.nuevaMarca = '';
        this.nuevaCapacidad = '';
        this.nuevoPrecio = '';
        this.nuevoTipoPendiente = null;
        this.csvCargado = false;
        this.tanquesParseados = [];
        
        // Resetear el formulario hijo si existe
        const formulario = this.template.querySelector('c-nuevo-tipo-form');
        if (formulario) {
            formulario.resetForm();
        }
    }

    handleFormError(event) {
        this.mostrarError(event.detail);
    }

    handleConfirmarNuevoTipo(event) {
        this.nuevoTipoPendiente = event.detail;
        this.tipoConfirmado = true;
        this.pasoActual = '2';
        this.mostrarNuevoTipo = false;
        this.mostrarResumenTipoNuevo = true;
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get filteredTipoOptions() {
        if (!this.searchTerm) return this.tipoOptions;
        return this.tipoOptions.filter(t =>
            t.label.toLowerCase().includes(this.searchTerm)
        );
    }

    handleSelectTipo(event) {
        const tipoId = event.currentTarget.dataset.id;
        const tipo = this.tipoOptions.find(t => t.value === tipoId);

        this.selectedTipoId = tipoId;
        this.tipoSeleccionado = tipo;
        this.pasoActual = '2';
        this.tipoConfirmado = true;
        this.mostrarTipoExistente = false;
    }

    renderedCallback() {
        if (this.papaparseInitialized) return;

        loadScript(this, papaparseLib)
            .then(() => {
                this.papaparseInitialized = true;
            })
            .catch(error => {
                console.error('Error cargando PapaParse', error);
            });
    }

    handleCsvCargado(event) {
        this.tanquesParseados = event.detail;
        this.csvCargado = true;
        this.pasoActual = '3';
    }

    handleErrorCsv(event) {
        this.mostrarError(event.detail);
    }

    async confirmarCarga() {
        try {
            let tipoIdFinal = this.selectedTipoId;

            if (this.nuevoTipoPendiente) {
                tipoIdFinal = await crearTipoTanque({
                    marca: this.nuevoTipoPendiente.Name,
                    capacidad: this.nuevoTipoPendiente.Capacidad__c,
                    precio: this.nuevoTipoPendiente.Precio_de_Lista__c
                });

                await refreshApex(this.tipoWireResult);
            }

            if (this.tanquesParseados.length === 1) {
                await cargarTanqueIndividual({
                    tanqueJson: this.tanquesParseados[0],
                    tipoId: tipoIdFinal
                });
            } else {
                await ejecutarCargaMasivaBatch({
                    tanquesJson: this.tanquesParseados,
                    tipoId: tipoIdFinal
                });
            }

            this.abrirModal();
            this.resetAll();

        } catch (error) {
            console.error('Error cargando tanques:', JSON.stringify(error, null, 2));
            const msg = error?.body?.message || error.message || 'Error desconocido';
            this.mostrarError('Error al cargar tanques:\n' + msg);
        }
    }

    abrirModal() {
        this.tituloModal = 'Carga Exitosa';
        this.mensajeModal = '✔️ ¡Tanques cargados correctamente!';
        this.varianteModal = 'brand';
        this.esErrorModal = false;
        this.mostrarModal = true;
    }

    mostrarError(mensaje) {
        this.tituloModal = 'Error';
        this.mensajeModal = mensaje;
        this.varianteModal = 'neutral';
        this.esErrorModal = true;
        this.mostrarModal = true;
    }

    handleCerrarModal() {
        this.mostrarModal = false;
    }
}