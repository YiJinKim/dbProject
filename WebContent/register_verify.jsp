<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ page import="java.sql.*"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.io.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<%
request.setCharacterEncoding("utf-8");
	String dbdriver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(dbdriver);
	Connection myConn = null;
	String dburl = "jdbc:oracle:thin:@localhost:1521:orcl";
	String user = "c##db";
	String passwd = "db";

	PreparedStatement pstmt = null;
	PreparedStatement prof_pstmt = null;
	
	String formID = request.getParameter("user");
	String formPass = request.getParameter("pass");
	String confirmPass = request.getParameter("confirmPass");
	String formName = request.getParameter("name");
	String mode = request.getParameter("chk_info");
	
%>
</head>
<body>
<%
if(!formPass.equals(confirmPass)) {
		%><script> 
		alert("비밀번호를 다시 확인해주세요."); 
		location.href="register.jsp";  
		</script><%
	}
else{
	try{          
		myConn = DriverManager.getConnection(dburl, user, passwd);
		
		if(mode.equals("professor")){
			String isExistSQL = "select * from professor where p_id=?";
			PreparedStatement prpStatementCheck = myConn.prepareStatement(isExistSQL);
			prpStatementCheck.setString(1, formID);
			ResultSet rsCheck=prpStatementCheck.executeQuery();
			if(rsCheck.next()){
				
				%><script> 
				alert("이미 존재하는 아이디 입니다."); 
				location.href="main.jsp";  
			</script><%
			}
			else{
				String prof_sql = "insert into professor (p_pwd, p_name,p_id) values(?,?,?)";
				prof_pstmt = myConn.prepareStatement(prof_sql);

				prof_pstmt.setString(1, formPass);
				prof_pstmt.setString(2, formName);
				prof_pstmt.setString(3, formID);

				prof_pstmt.executeUpdate();
				%><script> 
				alert("성공적으로 가입 되었습니다."); 
				location.href="main.jsp";  
			</script><%
			}

		}
		else{
			String isExistSQL = "select * from student where s_id=?";
			PreparedStatement prpStatementCheck = myConn.prepareStatement(isExistSQL);
			prpStatementCheck.setString(1, formID);
			ResultSet rsCheck=prpStatementCheck.executeQuery();
			if(rsCheck.next()){
				
				%><script> 
				alert("이미 존재하는 아이디 입니다."); 
				location.href="register.jsp";  
			</script><%
			}
			else{
				String sql = "insert into student (s_pwd, s_name,s_id) values(?,?,?)";      
				pstmt = myConn.prepareStatement(sql);
			
				pstmt.setString(1, formPass);
				pstmt.setString(2, formName);
				pstmt.setString(3, formID);

				pstmt.executeUpdate();
				%><script> 
				alert("성공적으로 가입 되었습니다."); 
				location.href="main.jsp";  
			</script><%
			}

		}
		
	}catch(SQLException ex){
		String sMessage="";
		if (ex.getErrorCode() == 20002)
			sMessage = "암호는 4자리 이상이어야합니다.";
		else if (ex.getErrorCode() == 20003)
			sMessage = "암호에 공란은 입력되지 않습니다.";
		else
			sMessage = "잠시 후 다시 시도하십시오.";
		out.println("<script>");
		out.println("alert('"+sMessage+"');");
		out.println("location.href='update.jsp';");
		out.println("</script>");
		out.flush();
	}finally{
		if(prof_pstmt != null) try{prof_pstmt.close();}catch(SQLException sqle){} 
		if(pstmt != null) try{pstmt.close();}catch(SQLException sqle){}
		if(myConn != null) try{myConn.close();}catch(SQLException sqle){}   
	}	
}
%>
</body>
</html>