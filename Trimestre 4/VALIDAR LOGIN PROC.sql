


DELIMITER $$

CREATE PROCEDURE validar_login (
  IN p_correo VARCHAR(100),
  IN p_contrasena VARCHAR(255)
)
BEGIN
  SELECT *
  FROM persona
  WHERE correo = p_correo
    AND Contrasena = encriptar_contrasena(p_contrasena);
END$$

DELIMITER ;
