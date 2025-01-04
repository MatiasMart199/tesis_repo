<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-success">
            <div class="card-header text-center">
                AGREGAR TIPO DE IMPUESTO
            </div>
            <div class="card-body">
                <div class="form-group">
                    <label>Descripción</label>
                    <input type="text" class="form-control" id="agregar_tip_imp_descrip">
                </div>
                <div class="form-group">
                    <label>Tasa 1</label>
                    <input type="text" class="form-control" id="agregar_tip_imp_tasa">
                </div>
                <div class="form-group">
                    <label>Tasa 2</label>
                    <input type="text" class="form-control" id="agregar_tip_imp_tasa2">
                </div>
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-agregar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>
