package CONFIG;

import java.beans.Statement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author Usuario
 */
public class Conexion {
    private String USERNAME = "root"; //del MySQL
    private String PASSWORD = "4815162342";
    private String HOST = "localhost";
    private String PORT = "3306";
    private String DATABASE = "prueba";
    private String CLASSNAME = "com.mysql.cj.jdbc.Driver";
    private String URL = "jdbc:mysql://" + HOST + ":" + PORT + "/" + DATABASE + "?serverTimezone=UTC";

    private Connection con;
    
    public Conexion() throws ClassNotFoundException, SQLException {

        try {
            Class.forName(CLASSNAME);
            con = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.err.println("Error 1: " + e);
        } catch (SQLException e) {
            System.err.println("Error 2: " + e);
        }
    }
    
    public Connection getConexion() {
        return con;  //retornar el objeto que contiene la conexión
    }

    public void close() {
        con = null;
    }
    
    public static Connection conn;
    private static Statement stm;
    private static ResultSet rs;
    
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
        CONFIG.Conexion c1 = new CONFIG.Conexion();
        CONFIG.Conexion.conn = c1.getConexion();

        if (conn != null) {
            System.out.println("Conexión exitosa.... ");
        }
    }
}
