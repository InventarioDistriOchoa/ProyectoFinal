<?php
class UsuarioDto {
    private $idPersona;
    private $nombre;
    private $correo;
    private $contrasena;
    private $tipoDocumento;
    private $rol;

    public function getIdPersona() { return $this->idPersona; }
    public function setIdPersona($idPersona) { $this->idPersona = $idPersona; }

    public function getNombre() { return $this->nombre; }
    public function setNombre($nombre) { $this->nombre = $nombre; }

    public function getCorreo() { return $this->correo; }
    public function setCorreo($correo) { $this->correo = $correo; }

    public function getContrasena() { return $this->contrasena; }
    public function setContrasena($contrasena) { $this->contrasena = $contrasena; }

    public function getTipoDocumento() { return $this->tipoDocumento; }
    public function setTipoDocumento($tipoDocumento) { $this->tipoDocumento = $tipoDocumento; }

    public function getRol() { return $this->rol; }
    public function setRol($rol) { $this->rol = $rol; }
}
?>

