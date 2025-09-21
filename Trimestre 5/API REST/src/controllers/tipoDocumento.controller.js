import TipoDocumento from "../models/tipoDocumento.model.js";

// Crear TipoDocumento
export const createTipoDocumento = async (req, res) => {
  try {
    const tipo = await TipoDocumento.create(req.body);
    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Tipo de documento creado",
      body: tipo,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear tipo de documento",
      error: error.message,
    });
  }
};

// Mostrar todos los tipos
export const showTipoDocumento = async (req, res) => {
  try {
    const tipos = await TipoDocumento.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de tipos de documento",
      body: tipos,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener tipos",
      error: error.message,
    });
  }
};

// Mostrar Tipo por ID
export const showIdTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;
    const tipo = await TipoDocumento.findOne({ where: { idTipo_Documento: id } });

    if (!tipo)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de documento no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento encontrado",
      body: tipo,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener tipo",
      error: error.message,
    });
  }
};

// Actualizar Tipo
export const updateTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;

    const [updated] = await TipoDocumento.update(req.body, {
      where: { idTipo_Documento: id },
    });

    if (updated === 0) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de documento no encontrado",
      });
    }

    const tipoDocActualizado = await TipoDocumento.findByPk(id);

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento actualizado",
      body: tipoDocActualizado,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar tipo",
      error: error.message,
    });
  }
};


// Eliminar Tipo
export const deleteTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;
    await TipoDocumento.destroy({ where: { idTipo_Documento: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento eliminado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar tipo",
      error: error.message,
    });
  }
};
