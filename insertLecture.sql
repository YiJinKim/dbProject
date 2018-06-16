create or replace PROCEDURE InsertLecture(
sCourseName IN VARCHAR2,
nCourseUnit IN NUMBER,
sProfessorId IN VARCHAR2,
sCourseId IN VARCHAR2,
nCourseIdNo IN NUMBER,
nTime IN NUMBER,
nMax IN NUMBER,
result OUT VARCHAR2
)
IS
duplicate_time_professor EXCEPTION;


check1 NUMBER;
check2 NUMBER;

nYear NUMBER;
nSemester NUMBER;


CURSOR duplicate_time_cursor IS
SELECT *
FROM TEACH
WHERE p_id = sProfessorId;



BEGIN
result := '';

--DBMS_OUTPUT.put_line('#');
--DBMS_OUTPUT.put_line(sProfessorId || '���� �����ȣ ' || sCourseId || ', �й� ' || TO_CHAR(nCourseIdNo) || '�� ���� ����� ��û�Ͽ����ϴ�.');

/* �⵵, �б� �˾Ƴ��� */
nYear := Date2EnrollYear(SYSDATE);
nSemester := Date2EnrollSemester(SYSDATE);

/* ����ó�� 1 : �ߺ� �ð� ���� �ִ� ���*/
check1 := 0;
For time_list IN duplicate_time_cursor LOOP
	check1 := compareTime4pro(nTime,time_list.c_id,time_list.c_id_no);
	IF(check1 >0 ) THEN
		RAISE duplicate_time_professor;
	END IF;
END LOOP;


INSERT INTO TEACH
VALUES(sProfessorId, sCourseId, nCourseIdNo,sCourseName,nCourseUnit, nYear, nSemester,nTime ,nMax);

  COMMIT;
  result := '������ �߰��Ͽ����ϴ�.';

EXCEPTION
WHEN duplicate_time_professor THEN
result := '�̹� ��ϵ� ���� �� �ߺ��Ǵ� ���ǰ� �����մϴ�.';
WHEN OTHERS THEN
    ROLLBACK;
    result := '����Ŀ� �ٽ� �õ����ּ���';
END;
/