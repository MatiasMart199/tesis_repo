<?php
class Conexion{
    private  $host;
    private  $port;
    private  $dbname;
    private  $user;
    private  $pass;
    private  $conexion;

    function __construct(){
        $this->host = "localhost";
        $this->port = "5432";
        $this->dbname = "bdtesis2";
        $this->user = "postgres";
        $this->pass = "1";
    }
	public function getConexion() {
        $this->conexion = pg_connect("host=$this->host port=$this->port dbname=$this->dbname user=$this->user password=$this->pass");
        return $this->conexion;
	}
    function cerrar(){
        pg_close($this->conexion);
    }
}

?>