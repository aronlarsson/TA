CREATE VIEW __Reference_Solution__BasicInformation AS
  SELECT Students.idnr, Students.name, Students.login, Students.program, StudentBranches.branch
  FROM Students LEFT JOIN StudentBranches ON Students.idnr = StudentBranches.student;


CREATE VIEW __Reference_Solution__FinishedCourses AS
  SELECT student, course, Courses.name as courseName, grade, credits
  FROM Taken JOIN Courses ON Taken.course = Courses.code;


CREATE VIEW __Reference_Solution__Registrations AS
  (SELECT student, course, 'registered' AS status FROM Registered)
    UNION
  (SELECT student, course, 'waiting' AS status FROM WaitingList);


CREATE VIEW __Reference_Solution__PassedCourses AS
  SELECT student, course, credits FROM __Reference_Solution__FinishedCourses WHERE grade <> 'U';


CREATE VIEW __Reference_Solution__UnreadMandatory AS
  (SELECT idnr AS student, course FROM Students NATURAL JOIN MandatoryProgram)
    UNION
  (SELECT idnr AS student, course FROM Students, StudentBranches NATURAL JOIN MandatoryBranch
   WHERE Students.idnr = StudentBranches.student)
    EXCEPT
  (SELECT student, course FROM __Reference_Solution__PassedCourses);


CREATE VIEW __Reference_Solution__PathToGraduation AS
  WITH
    CreditsTaken AS
      (SELECT idnr, COALESCE(totalCredits, 0) AS totalCredits FROM Students
       LEFT JOIN (SELECT student, SUM(credits) AS totalCredits FROM __Reference_Solution__PassedCourses
                  GROUP BY student) AS P
       ON P.student = idnr),

    RecommendedCredits AS
      (SELECT idnr, COALESCE(recommendedCredits, 0) AS recommendedCredits FROM Students
       LEFT JOIN (SELECT student, SUM(credits) AS recommendedCredits FROM __Reference_Solution__PassedCourses
                  NATURAL JOIN StudentBranches
                  WHERE course IN (SELECT course FROM RecommendedBranch
                                   WHERE (program, branch) = (StudentBranches.program, StudentBranches.branch))
                  GROUP BY student) AS P
       ON P.student = idnr),

    MandatoryLeft AS
      (SELECT idnr, COALESCE(mandatoryLeft, 0) AS mandatoryLeft FROM Students
       LEFT JOIN (SELECT student, COUNT(*) AS mandatoryLeft FROM __Reference_Solution__UnreadMandatory
                  GROUP BY student) AS M
       ON M.student = idnr),

    MathematicalCredits AS
      (SELECT idnr, COALESCE(mathCredits, 0) AS mathCredits FROM Students
       LEFT JOIN (SELECT student, SUM(credits) AS mathCredits FROM __Reference_Solution__PassedCourses
                  WHERE course IN (SELECT course FROM Classified
                                   WHERE LOWER(classification) LIKE '%math%')
                  GROUP BY student) AS C
       ON C.student = idnr),

    SeminarCourses AS
      (SELECT idnr, COALESCE(seminarCourses, 0) AS seminarCourses FROM Students
       LEFT JOIN (SELECT student, COUNT(*) AS seminarCourses FROM __Reference_Solution__PassedCourses
                  WHERE course IN (SELECT course FROM Classified
                                   WHERE LOWER(classification) LIKE '%seminar%')
                  GROUP BY student) AS C
       ON C.student = idnr)

  SELECT idnr AS student, totalCredits, mandatoryLeft, mathCredits, seminarCourses,
         mandatoryLeft = 0 AND recommendedCredits >= 10 AND
         mathCredits >= 20 AND seminarCourses > 0 AS qualified
  FROM Students
  NATURAL JOIN CreditsTaken
  NATURAL JOIN RecommendedCredits
  NATURAL JOIN MandatoryLeft
  NATURAL JOIN MathematicalCredits
  NATURAL JOIN SeminarCourses;

CREATE VIEW __Reference_Solution__InfoForGraduation AS
  WITH
    CreditsTaken AS
      (SELECT idnr, COALESCE(totalCredits, 0) AS totalCredits FROM Students
       LEFT JOIN (SELECT student, SUM(credits) AS totalCredits FROM __Reference_Solution__PassedCourses
                  GROUP BY student) AS P
       ON P.student = idnr),

    RecommendedCredits AS
      (SELECT idnr, COALESCE(recommendedCredits, 0) AS recommendedCredits FROM Students
       LEFT JOIN (SELECT student, SUM(credits) AS recommendedCredits FROM __Reference_Solution__PassedCourses
                  NATURAL JOIN StudentBranches
                  WHERE course IN (SELECT course FROM RecommendedBranch
                                   WHERE (program, branch) = (StudentBranches.program, StudentBranches.branch))
                  GROUP BY student) AS P
       ON P.student = idnr),

    MandatoryLeft AS
      (SELECT idnr, COALESCE(mandatoryLeft, 0) AS mandatoryLeft FROM Students
       LEFT JOIN (SELECT student, COUNT(*) AS mandatoryLeft FROM __Reference_Solution__UnreadMandatory
                  GROUP BY student) AS M
       ON M.student = idnr),

    MathematicalCredits AS
      (SELECT idnr, COALESCE(mathCredits, 0) AS mathCredits FROM Students
       LEFT JOIN (SELECT student, SUM(credits) AS mathCredits FROM __Reference_Solution__PassedCourses
                  WHERE course IN (SELECT course FROM Classified
                                   WHERE LOWER(classification) LIKE '%math%')
                  GROUP BY student) AS C
       ON C.student = idnr),

    SeminarCourses AS
      (SELECT idnr, COALESCE(seminarCourses, 0) AS seminarCourses FROM Students
       LEFT JOIN (SELECT student, COUNT(*) AS seminarCourses FROM __Reference_Solution__PassedCourses
                  WHERE course IN (SELECT course FROM Classified
                                   WHERE LOWER(classification) LIKE '%seminar%')
                  GROUP BY student) AS C
       ON C.student = idnr)
  SELECT idnr AS student,
         totalCredits,
         recommendedCredits,
         mandatoryLeft,
         mathCredits,
         seminarCourses
  FROM Students
  NATURAL JOIN CreditsTaken
  NATURAL JOIN RecommendedCredits
  NATURAL JOIN MandatoryLeft
  NATURAL JOIN MathematicalCredits
  NATURAL JOIN SeminarCourses;