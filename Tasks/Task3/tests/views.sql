
-- View: StudentsFollowing
-- For all students, their names, and the program and branch (if any) they
-- are following.
CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program, branch
FROM Students LEFT OUTER JOIN StudentBranches ON idnr = student;

-- View: FinishedCourses
-- For all students, all finished courses, along with their names, grades
-- (grade 'U', '3', '4' or '5') and number of credits.
CREATE VIEW FinishedCourses AS
SELECT student, course, Courses.name as courseName, grade, credits
FROM Taken JOIN Courses ON code = course;

-- View: Registrations
-- All registered and waiting students for all courses, along with their
-- waiting status ('registered' or 'waiting').
CREATE VIEW Registrations AS
(SELECT student, course, 'registered' AS status FROM Registered)
UNION
(SELECT student, course, 'waiting' AS status FROM WaitingList);

-- Helper View: PassedCourses
-- For all students, all passed courses, i.e. courses finished with a grade
-- other than 'U', and the number of credits for those courses. This view is
-- intended as a helper view towards the PathToGraduation view, and will not be
-- directly used by your application.
CREATE VIEW PassedCourses AS
SELECT student, course, credits
 FROM FinishedCourses
 WHERE grade != 'U';

-- Helper View: UnreadMandatory
-- For all students, the mandatory courses (branch and program) they have not
-- yet passed. This view is intended as a helper view towards the
-- PathToGraduation view, and will not be directly used by your application.
CREATE VIEW UnreadMandatory AS
((SELECT idnr as student, course
  FROM Students JOIN Mandatoryprogram USING (program))
UNION
(SELECT student, course
 FROM StudentBranches JOIN MandatoryBranch USING (branch, program) ))
EXCEPT
(SELECT student, course FROM PassedCourses);

-- Helper View RecommendedCourses
CREATE VIEW RecommendedCourses AS 
SELECT student, course, credits 
FROM StudentBranches 
     JOIN RecommendedBranch USING (branch, program)
     JOIN PassedCourses USING (student, course);


CREATE VIEW PathToGraduation AS
WITH
AllClassified AS -- This is a clever but not necessary trick to make the classification queries below simpler
 (SELECT student, classification, COUNT(*) AS num, SUM(credits) AS total
  FROM PassedCourses JOIN Classified USING (course) 
  GROUP BY PassedCourses.student, classification),
MandatoryLeft AS
 (SELECT student, COUNT(Course) AS mandatory_courses_left
  FROM UnreadMandatory
  GROUP BY student),
TotalCredits AS
 (SELECT student, SUM(credits) AS total_credits
  FROM PassedCourses
  GROUP BY student),
BranchCredits AS
 (SELECT student, SUM(credits) AS branch_credits
  FROM RecommendedCourses
  GROUP BY student),
MathCredits AS
 (SELECT student, total AS math_credits FROM AllClassified WHERE classification = 'math'),
SeminarCount AS
 (SELECT student, num AS seminar_courses FROM AllClassified WHERE classification = 'seminar')
-- End of WITH-clause, actual query starts here
SELECT 
  student, 
  COALESCE(total_credits,0) totalCredits, -- The underscore naming in attributes is not required, but may help understanding
  COALESCE(mandatory_courses_left,0) mandatoryLeft, 
  COALESCE(math_credits,0) mathCredits, 
  COALESCE(seminar_courses,0) seminarCourses,
  COALESCE((
   mandatory_courses_left IS NULL
   AND branch_credits >= 10
   AND math_credits >= 20
   AND seminar_courses >= 1),false) AS qualified
FROM (SELECT idnr as student FROM Students) Students
  LEFT OUTER JOIN StudentBranches USING (student)
  LEFT OUTER JOIN MandatoryLeft USING (student)
  LEFT OUTER JOIN BranchCredits USING (student)
  LEFT OUTER JOIN TotalCredits USING (student)
  LEFT OUTER JOIN MathCredits USING (student)
  LEFT OUTER JOIN SeminarCount USING (student)




