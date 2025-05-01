import { LightningElement, track } from 'lwc';
import getTipos from '@salesforce/apex/TanqueController.getTipos';
import crearTipoTanque from '@salesforce/apex/TanqueController.crearTipoTanque';
import cargarTanqueIndividual from '@salesforce/apex/TanqueController.cargarTanqueIndividual';
import ejecutarCargaMasivaBatch from '@salesforce/apex/TanqueController.ejecutarCargaMasivaBatch';
import papaparseLib from '@salesforce/resourceUrl/papaparser';
import { loadScript } from 'lightning/platformResourceLoader';


export default class CargaMasivaTanques extends LightningElement {
    @track tipoConfirmado = false;
    @track mostrarNuevoTipo = false;
    @track mostrarTipoExistente = false;
    @track mostrarResumenTipoNuevo = false;
    @track pasoActual = '1';

    @track mostrarModal = false;
    @track mostrarModalError = false;
    @track mensajeError = '';
    


    @track tipoOptions = [];



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

    // Inicializar
    connectedCallback() {
        this.cargarTipos();
    }

    async cargarTipos() {
        const tipos = await getTipos();
        this.tipoOptions = tipos.map(t => ({ label: t.Name, value: t.Id }));
        this.searchTerm = '';
    }
    

    // Botón "Crear Nuevo Tipo"
    activarNuevoTipo() {
        this.resetAll();
        this.mostrarNuevoTipo = true;
    }

    // Botón "Usar Tipo Existente"
    activarTipoExistente() {
        this.resetAll();
        this.mostrarTipoExistente = true;
    }

    // Reset General (cuando cambiás entre modos o al cerrar modal)
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
    }

    // Formulario
    handleInputChange(event) {
        const label = event.target.label;
        if (label === 'Marca') this.nuevaMarca = event.target.value;
        if (label === 'Capacidad (L)') this.nuevaCapacidad = event.target.value;
        if (label === 'Precio de Lista') this.nuevoPrecio = event.target.value;
    }

    // Búsqueda tipo existente
    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get filteredTipoOptions() {
        if (!this.searchTerm) {
            return this.tipoOptions;
        }
        return this.tipoOptions.filter(
            t => t.label.toLowerCase().includes(this.searchTerm)
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

    // Crear nuevo tipo
    async crearTipo() {
        
        if (!this.nuevaMarca || !this.nuevaCapacidad || !this.nuevoPrecio) {
            this.mostrarError('Error faltan datos o estos son inválidos.');
            return;
        }


        this.nuevoTipoPendiente = {
            Name: this.nuevaMarca,
            Capacidad__c: parseInt(this.nuevaCapacidad),
            Precio_de_Lista__c: parseFloat(this.nuevoPrecio)
        };

        this.tipoConfirmado = true;
        this.pasoActual = '2';
        this.mostrarNuevoTipo = false;
        this.mostrarResumenTipoNuevo = true;
    }

    // Carga CSV
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

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (!file || !this.papaparseInitialized) return;
    
        Papa.parse(file, {
            header: true,
            skipEmptyLines: true,
            trimHeaders: true,
            complete: (results) => {
                const datos = results.data.map((row, index) => ({
                    id: index,
                    numeroDeSerie: row['Numero de Serie']?.trim(),
                    estado: row['Estado']?.trim()
                }));
    
                const estadosValidos = ['Disponible', 'Reservado', 'Vendido'];
    
                const camposValidos = datos.every(t => {
                    const numeroSerieValido = t.numeroDeSerie && /^[A-Za-z0-9\-]+$/.test(t.numeroDeSerie);
                    const estadoValido = t.estado && estadosValidos.includes(t.estado);
                    return numeroSerieValido && estadoValido;
                });
    
                if (camposValidos && datos.length > 0) {
                    this.tanquesParseados = datos;
                    this.csvCargado = true;
                    this.pasoActual = '3';
                } else {
                    this.csvCargado = false;
                    this.mostrarError('El archivo CSV tiene datos inválidos. Verifique que:\n- Estado sea "Disponible", "Reservado" o "Vendido".\n- Número de serie contenga solo letras, números o guiones.');
                }
            },
            error: (error) => {
                console.error('Error parseando CSV:', error);
                this.mostrarError('Error parseando CSV.');
            }
        });
    }
    

    // Confirmar carga
    async confirmarCarga() {
        try {
            
            let tipoIdFinal = this.selectedTipoId;

            if (this.nuevoTipoPendiente) {
                const result = await crearTipoTanque({
                    marca: this.nuevoTipoPendiente.Name,
                    capacidad: this.nuevoTipoPendiente.Capacidad__c,
                    precio: this.nuevoTipoPendiente.Precio_de_Lista__c
                });
                tipoIdFinal = result;
                  

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
            this.resetAll(); //  Limpiar todo al finalizar exitosamente
        
        } catch (error) {
            console.error('Error cargando tanques:', JSON.stringify(error, null, 2));
            const msg = error?.body?.message || error.message || 'Error desconocido';
            alert('Error al cargar tanques:\n' + msg);
        }
    }

    abrirModal() {
        this.mostrarModal = true;
    }

    cerrarModal() {
        this.mostrarModal = false;
    }

    
    mostrarError(mensaje) {
        this.mensajeError = mensaje;
        this.mostrarModalError = true;
    }
    
    cerrarModalError() {
        this.mostrarModalError = false;
        this.mensajeError = '';
    }
    
    
}
