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


carpeta beans
package BEANS;

import java.io.InputStream;

public class BEANS_Imaginario {
    int id;
    String nom;
    InputStream foto;
    
    public BEANS_Imaginario(){
    }

    public BEANS_Imaginario(int id, String nom, InputStream foto) {
        this.id = id;
        this.nom = nom;
        this.foto = foto;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public InputStream getFoto() {
        return foto;
    }

    public void setFoto(InputStream foto) {
        this.foto = foto;
    }
    
    
}

carpeta daos
package DAOS;

import BEANS.BEANS_Imaginario;
import CONFIG.Conexion;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Usuario
 */
public class DAOS_Imaginario {
    Conexion cn;
    Connection con;

    PreparedStatement pst;
    ResultSet rs;
    
    public int prueba_s_contar_todos() throws SQLException{
        String sql = "call prueba_s_contar_todos()";
        int total = 0;
        try{
            con = cn.getConexion();
            pst = con.prepareStatement(sql);
            rs = pst.executeQuery();
            
            while (rs.next()){
                total = rs.getInt("total");
            }
            pst.close();
            rs.close();
            con.close();
            return total;
            }   catch (SQLException e){
                throw e;
            }
    }

    public List listar() {
        List<BEANS_Imaginario> lista = new ArrayList<>();
        String sql = "select * from persona";
        try {
            con = cn.getConexion();
            pst = con.prepareStatement(sql);
            rs = pst.executeQuery();
            while (rs.next()) {
                BEANS_Imaginario p = new BEANS_Imaginario();
                p.setId(rs.getInt(1));
                p.setNom(rs.getString(2));
                p.setFoto(rs.getBinaryStream(3));
                lista.add(p);
            }
        } catch (Exception e) {
        }
        return lista;
    }

    public void listarImg(int id, HttpServletResponse response) {
        String sql = "select * from persona where Id=" + id;
        InputStream inputStream = null;
        OutputStream outputStream = null;
        BufferedInputStream bufferedInputStream = null;
        BufferedOutputStream bufferedOutputStream = null;
        response.setContentType("image/*");
        try {
            outputStream = response.getOutputStream();
            con = cn.getConexion();
            pst = con.prepareStatement(sql);
            rs = pst.executeQuery();
            if (rs.next()) {
                inputStream = rs.getBinaryStream("Foto");
            }
            bufferedInputStream = new BufferedInputStream(inputStream);
            bufferedOutputStream = new BufferedOutputStream(outputStream);
            int i = 0;
            while ((i = bufferedInputStream.read()) != -1) {
                bufferedOutputStream.write(i);
            }
        } catch (Exception e) {
        }
    }

    public void agregar(BEANS_Imaginario p) {
        String sql = " call prueba_i(?,?,?)";
        try {
            con = cn.getConexion();
            pst = con.prepareStatement(sql);
            pst.setInt(1, p.getId());
            pst.setString(2, p.getNom());
            pst.setBlob(3, p.getFoto());
            pst.executeUpdate();
        } catch (Exception e){
        }
    }
}


clases servlet para las imagenes
package DAOS;

import BEANS.BEANS_Imaginario;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

/**
 *
 * @author Usuario
 */
public class servlet extends HttpServlet {
    DAOS_Imaginario dao = new DAOS_Imaginario();
    BEANS_Imaginario p = new BEANS_Imaginario();
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet servlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet servlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //processRequest(request, response);
        String accion = request.getParameter("accion");
        switch (accion){
            case "Listar":
                List<BEANS_Imaginario>lista= dao.listar();
                request.setAttribute("lista", lista);
                request.getRequestDispatcher("prueba_todos.jsp").forward(request, response);
                break;
            case "Nuevo":
                
                request.getRequestDispatcher("pruebaAgregar.jsp").forward(request, response);
                break;
            case "Guardar":
                int id = Integer.valueOf(request.getParameter("txtId"));
                String nom = request.getParameter("txtNom");
                Part part = request.getPart("fileFoto");
                InputStream inputStream = part.getInputStream();
                p.setId(id);
                p.setNom(nom);
                p.setFoto(inputStream);
                dao.agregar(p);
                request.getRequestDispatcher("servlet?accion=Listar").forward(request, response);
                break;
            default:
                request.getRequestDispatcher("servlet?accion=Listar").forward(request, response);
                break;
        
        }
    }

    
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}



package DAOS;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class servletImg extends HttpServlet {
DAOS_Imaginario dao = new DAOS_Imaginario();
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet servletImg</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet servletImg at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id= Integer.parseInt(request.getParameter("id"));
        dao.listarImg(id, response);
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}

en la carpeta web pages los jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
    <center>
        <div>
            <form action="servlet" method="POST">
                <input type="submit" name="accion" value="Listar">
                <input type="submit" name="accion" value="Nuevo">
            </form>
            <hr>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>NOMBRES</th>
                        <th>FOTO</th>
                        <th>ACCIONES</th>
                    </tr>
                    
                    
                    
                </thead>
                
                    
            </table>
        </div>
    </center>
</body>
</html>







<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.List"%>
<%@page import="BEANS.BEANS_Imaginario"%>
<%

    int cantidad = 0;
    List<BEANS_Imaginario> lista_recibe = new ArrayList<>();
    if (request.getSession().getAttribute("lista") != null) {
        lista_recibe = (List) request.getSession().getAttribute("lista");
        cantidad = lista_recibe.size();
    }else{
        
    }
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
    <center>
        <div>
            <form action="servlet" method="POST">
                <input type="submit" name="accion" value="Listar">
                <input type="submit" name="accion" value="Nuevo">
            </form>
            <hr>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>NOMBRES</th>
                        <th>FOTO</th>
                        <th>ACCIONES</th>
                    </tr>
                    <%
                        int i = 0;
                        while (i < cantidad) {
                    %>
                    <tr>
                        <th><%= lista_recibe.get(i).getId()%></th>
                        <th><%= lista_recibe.get(i).getNom()%></th>
                        <td><img scr="servletImg?id=<%= lista_recibe.get(i).getId() %>" width="250" height="230"></td>
                        <td>
                            <form action="Controler" method="POST">
                                <input type="submit" name="accion" value="Listar">
                                <input type="submit" name="accion" value="Nuevo">
                            </form>
                        </td>
                    </tr>
                    <%
                            i = i + 1;
                        }
                    %>
                </thead>
                
                    
            </table>
        </div>
    </center>
</body>
</html>





<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
    <center>
        <div>
            <h3>Agregar nuevo usuario</h3>
        </div>
        <hr>
        <br>
        <form action="servlet" method="POST" enctype="multipart/form-data">
            <label>Id:</label>
            <input type="text" name="txtId">
            <label>Nombres:</label>
            <input type="text" name="txtNom">
            <label>Foto:</label>
            <input type="file" name="fileFoto">
            <input type="submit" name="accion" value="Guardar">
            <input type="submit" name="accion" value="Regresar">
        </form>
          
    </center>
    </body>
</html>
