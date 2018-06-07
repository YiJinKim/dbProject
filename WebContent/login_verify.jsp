<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*"%>

<html>
<head>
<title></title>
<%
	String dbdriver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(dbdriver);
	Connection myConn = null;
	String dburl = "jdbc:oracle:thin:@localhost:1521:orcl";
	String user = "c##db";
	String passwd = "db";

	Statement stmt = null;
	Statement p_stmt = null;
	String mySQL = null;
	String p_mySQL = null;
	ResultSet rs = null;
	ResultSet p_rs = null;
	String userID = request.getParameter("userID");
	String userPassword = request.getParameter("userPassword");
	String userName = request.getParameter("userName");
%>
</head>
<body>

	<%
		try {
			myConn = DriverManager.getConnection(dburl, user, passwd);

			stmt = myConn.createStatement();
			mySQL = "select s_id, s_pwd, s_name from student where s_id='" + userID + "' and s_pwd='" + userPassword
					+ "'";
			rs = stmt.executeQuery(mySQL);

			p_stmt = myConn.createStatement();
			p_mySQL = "select p_id, p_pwd, p_name from professor where p_id='" + userID + "' and p_pwd='"
					+ userPassword + "'";
			p_rs = p_stmt.executeQuery(p_mySQL);
		} catch (SQLException e) {
			out.println(e);
			e.printStackTrace();
		} finally {
			if (rs.next()) {
				session.setAttribute("user", userID);
				session.setAttribute("user_name", rs.getString("s_name"));
				response.sendRedirect("main.jsp");
	%>
	<script>
		alert("Student Login Successfully!!");
	</script>
	<%
		} else if (p_rs.next()) {
				session.setAttribute("professor", userID);
				session.setAttribute("prof_name", rs.getString("p_name"));
				response.sendRedirect("main.jsp");
	%>
	<script>
		alert("Professor Login Successfully!!");
	</script>
	<%
		} else { //사용자 정보가 없을 때
			}
	%>
	<script>
		alert("Wrong ID/Password. Please Check!!"); //메시지 알림 후
		location.href = "login.jsp";
	</script>
	<%
		}
		stmt.close();
		p_stmt.close();
		myConn.close();
	%>
</body>
</html>