use distriochoa;
DELIMITER $$

CREATE FUNCTION encriptar_contrasena(clave VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  RETURN SHA2(clave, 256);
END$$

DELIMITER ;

###encriptar una por una
UPDATE persona
SET Contrasena = encriptar_contrasena('444')
WHERE correo = 'santiago4@gmail.com';




###procedimiento para que al insertar usuario se encripte la contraseña que se digite.
DELIMITER $$
CREATE PROCEDURE insertar_usuario_encriptado (
  IN p_id INT,
  IN p_nombre VARCHAR(100),
  IN p_correo VARCHAR(100),
  IN p_contrasena VARCHAR(255),
  IN p_tipo_doc INT,
  IN p_rol INT
)
BEGIN
  INSERT INTO persona (
    idPersona, nombre, correo, Contrasena,
    Tipo_Documento_idTipo_Documento, Rol_idRol
  )
  VALUES (
    p_id, p_nombre, p_correo,
    encriptar_contrasena(p_contrasena),
    p_tipo_doc, p_rol
  );
END$$

DELIMITER ;






