import { LightningElement, track } from 'lwc';
import getTipos from '@salesforce/apex/TanqueController.getTipos';
import crearTipoTanque from '@salesforce/apex/TanqueController.crearTipoTanque';
import cargarTanqueIndividual from '@salesforce/apex/TanqueController.cargarTanqueIndividual';
import ejecutarCargaMasivaBatch from '@salesforce/apex/TanqueController.ejecutarCargaMasivaBatch';
import papaparseLib from '@salesforce/resourceUrl/papaparser';
import { loadScript } from 'lightning/platformResourceLoader';

export default class CargaMasivaTanques extends LightningElement {
    // 🧠 Control del wizard
    @track modoSeleccionado = ''; // 'nuevo' | 'existente'
    @track tipoConfirmado = false;
    @track mostrarNuevoTipo = false;
    @track mostrarTipoExistente = false;
    @track pasoActual = '1'; // '1', '2', '3'
    
    
    @track mostrarModal = false; // ➡️ Modal oculto por defecto


    // 📋 Datos
    @track tipoOptions = [];
    selectedTipoId = '';
    nuevaMarca = '';
    nuevaCapacidad = '';
    nuevoPrecio = '';
    
    
    nuevoTipoPendiente = null;

    // 📄 CSV y tabla
    csvCargado = false;
    tanquesParseados = [];
    papaparseInitialized = false;

    columnas = [
        { label: 'Número de Serie', fieldName: 'numeroDeSerie' },
        { label: 'Estado', fieldName: 'estado' }
    ];


    // Mostrar modal
    abrirModal() {
        this.mostrarModal = true;
    }
    
    // Cerrar modal
    cerrarModal() {
        this.mostrarModal = false;
        this.tipoConfirmado = false;
        this.modoSeleccionado = '';
        this.selectedTipoId = '';
        this.csvCargado = false;
        this.tanquesParseados = [];
        this.pasoActual = '1'; // Volver al paso inicial
    }
    
    
    
    
    // 🚀 Al cargar
    connectedCallback() {
        this.cargarTipos();
    }

    async cargarTipos() {
        const tipos = await getTipos();
        this.tipoOptions = tipos.map(t => ({ label: t.Name, value: t.Id }));
    }

    // 📍 Opciones del radio group
    get opcionesTipo() {
        return [
            { label: 'Crear nuevo tipo de tanque', value: 'nuevo' },
            { label: 'Usar tipo existente', value: 'existente' }
        ];
    }

    // 🔄 Manejar opción nuevo/existente
    handleModoChange(event) {
        this.modoSeleccionado = event.detail.value;
        this.tipoConfirmado = false;
        this.pasoActual = '1'; // Volver a paso 1

        if (this.modoSeleccionado === 'nuevo') {
            this.mostrarNuevoTipo = true;
            this.mostrarTipoExistente = false;
        } else {
            this.mostrarNuevoTipo = false;
            this.mostrarTipoExistente = true;
        }
    }

    // 🛠 Inputs de creación de tipo
    handleInputChange(event) {
        const label = event.target.label;
        if (label === 'Marca') this.nuevaMarca = event.target.value;
        if (label === 'Capacidad (L)') this.nuevaCapacidad = event.target.value;
        if (label === 'Precio de Lista') this.nuevoPrecio = event.target.value;
    }

    // 💾 Crear nuevo tipo
    async crearTipo() {
        try {
            
            this.nuevoTipoPendiente = {
                Name: this.nuevaMarca,
                Capacidad__c: parseInt(this.nuevaCapacidad),
                Precio_de_Lista__c: parseFloat(this.nuevoPrecio)
            };
            this.tipoConfirmado = true;
            this.pasoActual = '2';
            this.mostrarNuevoTipo = false;

            /*
            const id = await crearTipoTanque({
                marca: this.nuevaMarca,
                capacidad: parseInt(this.nuevaCapacidad),
                precio: parseFloat(this.nuevoPrecio)
            });
            this.selectedTipoId = id;
            this.tipoConfirmado = true;
            this.pasoActual = '2'; // Pasar a paso 2
            this.mostrarNuevoTipo = false;
            await this.cargarTipos();

            */
        
        } catch (err) {
            console.error('Error creando tipo:', err);
        }
    }

    // 🔽 Elegir tipo existente
    handleTipoChange(event) {
        this.selectedTipoId = event.detail.value;
        this.pasoActual = '2'; // Pasar a paso 2
        this.tipoConfirmado = true;
    }

    // ⚡ Cargar librería PapaParse
    renderedCallback() {
        if (this.papaparseInitialized) return;

        loadScript(this, papaparseLib)
            .then(() => {
                this.papaparseInitialized = true;
                console.log('PapaParse cargado');
            })
            .catch(error => {
                console.error('Error cargando PapaParse', error);
            });
    }

    // 📑 Cargar archivo CSV
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

                const camposValidos = datos.every(t => t.numeroDeSerie && t.estado);
                if (camposValidos && datos.length > 0) {
                    this.tanquesParseados = datos;
                    this.csvCargado = true;
                    this.pasoActual = '3'; // Ahora está en Confirmar
                } else {
                    this.csvCargado = false;
                    alert('El archivo CSV no contiene columnas válidas o está vacío.');
                }
            },
            error: (error) => {
                console.error('Error parseando CSV:', error);
            }
        });
    }

    // 🚀 Confirmar carga de tanques

    async confirmarCarga() {
        try {
            if ((!this.selectedTipoId && !this.nuevoTipoPendiente) || this.tanquesParseados.length === 0) {
                alert('Faltan datos para la carga.');
                return;
            }
    
            let tipoIdFinal = this.selectedTipoId;
    
            // Si es un tipo nuevo → insertarlo primero
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
    
        } catch (error) {
            console.error('Error cargando tanques:', JSON.stringify(error, null, 2));
            const msg = error?.body?.message || error.message || 'Error desconocido';
            alert('Error al cargar tanques:\n' + msg);
        }
    }
    



    /*

    async confirmarCarga() {
        try {
            if (!this.selectedTipoId || this.tanquesParseados.length === 0) {
                alert('Faltan datos para la carga.');
                return;
            }

            if (this.tanquesParseados.length === 1) {
                await cargarTanqueIndividual({
                    tanqueJson: this.tanquesParseados[0],
                    tipoId: this.selectedTipoId
                });
            } else {
                await ejecutarCargaMasivaBatch({
                    tanquesJson: this.tanquesParseados,
                    tipoId: this.selectedTipoId
                });
            }

            this.abrirModal();


        } catch (error) {
            console.error('Error cargando tanques:', JSON.stringify(error, null, 2));
            const msg = error?.body?.message || error.message || 'Error desconocido';
            alert('Error al cargar tanques:\n' + msg);
        }
    }
    */


    }

