CREATE OR REPLACE PROCEDURE InsertEnroll(
  sStudentId IN VARCHAR2, 
  sCourseId IN VARCHAR2, 
  nCourseIdNo IN NUMBER,
  result OUT VARCHAR2)
IS
  too_many_sumCourseUnit EXCEPTION;
  too_many_courses EXCEPTION;
  too_many_students EXCEPTION;
  duplicate_time EXCEPTION;
 nCourseName VARCHAR2(50);
  nYear NUMBER;
  nSemester NUMBER;
  nSumCourseUnit NUMBER;
  nCourseUnit NUMBER;
 nTime NUMBER;
  nCnt NUMBER;
  nTeachMax NUMBER;
  overlap NUMBER;
  CURSOR duplicate_time_cursor IS
    SELECT *
    FROM enroll
    WHERE s_id = sStudentId;
BEGIN
  result := '';



  /* �⵵, �б� �˾Ƴ��� */
  nYear := Date2EnrollYear(SYSDATE);
  nSemester := Date2EnrollSemester(SYSDATE);


  /* ���� ó�� 1 : �ִ����� �ʰ����� */
  nSumCourseUnit :=0;
  nCourseUnit :=0;
  SELECT SUM(e.c_unit) 
  INTO nSumCourseUnit
  FROM teach t, enroll e
  WHERE e.s_id = sStudentId and e.c_year = nYear and e.c_semester = nSemester and e.c_id = t.c_id and e.c_id_no = t.c_id_no;

  SELECT c_name, c_unit, c_time
  INTO nCourseName, nCourseUnit, nTime
  FROM teach
  WHERE c_id = sCourseId and c_id_no = nCourseIdNo;

  IF (nSumCourseUnit + nCourseUnit > 18)
  THEN  
     RAISE too_many_sumCourseUnit;
  END IF;


  /* ���� ó�� 2 : ������ ���� ��û ���� */
  SELECT COUNT(*)
  INTO nCnt
  FROM enroll
  WHERE s_id = sStudentId and c_id = sCourseId;

  IF (nCnt > 0) 
  THEN
     RAISE too_many_courses;
  END IF;


  /* ���� ó�� 3 : ������û �ο� �ʰ� ���� */
  SELECT c_max
  INTO nTeachMax
  FROM teach
  WHERE c_year= nYear and c_semester = nSemester and c_id = sCourseId and c_id_no= nCourseIdNo;

  SELECT COUNT(*)
  INTO nCnt
  FROM enroll
  WHERE c_year = nYear and c_semester = nSemester and c_id = sCourseId and c_id_no = nCourseIdNo;

  IF (nCnt >= nTeachMax)
  THEN
     RAISE too_many_students;
  END IF;


  /* ���� ó�� 4 : ��û�� ����� �ð� �ߺ� ���� */
  overlap := 0;
  FOR enroll_list IN duplicate_time_cursor LOOP
    overlap := compareTime(sCourseId, nCourseIdNo, enroll_list.c_id, enroll_list.c_id_no);
  
    IF (overlap > 0)
    THEN
       RAISE duplicate_time;
    END IF;
 END LOOP;


  /* ���� ��û ��� */
  INSERT INTO enroll(S_ID,C_ID,C_ID_NO,C_NAME,C_UNIT,C_YEAR,C_SEMESTER,C_TIME)
  VALUES (sStudentId, sCourseId, nCourseIdNo, nCourseName, nCourseUnit, nYear, nSemester,nTime);

  COMMIT;
  result := '������û ����� �Ϸ�Ǿ����ϴ�.';

EXCEPTION
  WHEN too_many_sumCourseUnit THEN
    result := '�ִ������� �ʰ��Ͽ����ϴ�';
  WHEN too_many_courses THEN
    result := '�̹� ��ϵ� ������ ��û�Ͽ����ϴ�';
  WHEN too_many_students THEN
    result := '������û �ο��� �ʰ��Ǿ� ����� �Ұ����մϴ�';
  WHEN duplicate_time THEN
    result := '�̹� ��ϵ� ���� �� �ߺ��Ǵ� �ð��� �����մϴ�';
  WHEN no_data_found THEN
    result := '�̹� �б� ������ �ƴմϴ�.';
  WHEN OTHERS THEN
    ROLLBACK;
    result := SQLCODE;
END;
/