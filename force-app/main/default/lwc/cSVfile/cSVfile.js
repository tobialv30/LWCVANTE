import { LightningElement, api, track } from 'lwc';


export default class CSVfile extends LightningElement {
    @api columnas = [];
    @track tanquesParseados = [];
    @track csvCargado = false;


    handleFileUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

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
                    this.dispatchEvent(new CustomEvent('csvcargado', { detail: this.tanquesParseados }));
                } else {
                    this.csvCargado = false;
                    this.dispatchEvent(new CustomEvent('errorcsv', {
                        detail: 'El archivo CSV tiene datos inválidos. Verifique que:\n- Estado sea "Disponible", "Reservado" o "Vendido".\n- Número de serie contenga solo letras, números o guiones.'
                    }));
                }
            },
            error: (error) => {
                console.error('Error parseando CSV:', error);
                this.dispatchEvent(new CustomEvent('errorcsv', { detail: 'Error parseando CSV.' }));
            }
        });
    }

    handleConfirmarCarga() {
        this.dispatchEvent(new CustomEvent('confirmarcarga'));
    }
}