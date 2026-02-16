# Grading reference

Breath... breath-in... breath-out... you can do this.

Remember, if only two or three of these points are wrong it is ok to
write some feedback and ask them to re-submit. However, if things are
worse than that, do not spend much time motivating your decision; ask
them to go to a lab session for help instead.
You might ask them to tag you in their help request so other TAs know
they expect you to help them.
As always, use your own judgement for very bad submissions, but if you
don't feel someone "gets it" it is probably better they get help in a
lab session than in writing.

In your comments, give hints to the problem but not the exact solution!
For example, there is a missing UNIQUE constraint in WaitingList instead the constraint UNIQUE(course, position) is missing from WaitingList.ß

# ER

* Seven entities one of which is weak and one ISA
* Single many-to-at-most-one connection: Student to Branch
* Three many-to-one connections:
   - Student to Program
   - Branch to Program (as part of the weak entity relationship)
   - Course to Department
* Single weak entity: Branch to Program
* Single subentity: LimitedCourse to Course
* Single self-relationship: PrerequisiteCourses

* Check that all entities exist. Similar or closely-resembling names are allowed.
  Usual pitfalls are:
  - Concrete entities for mandatory and recommended courses
  - Unnecessary ISA relationships with classification or
    recommended/mandatory courses. 
  - Using the double line rectangle notation of weak entities without
    specifying the weak relationship. 
  - ISA-Weak entities 

* Check that all the attribute on each entity correspond to that entity.
  e.g. that the Student entity does not have a program attribute.

* Check for the two special relationships.
  - ISA relationship from course to limitedcourse
  - The weak relationship between program and branch

* Make sure there are no further ISA or Weak relationships

* Look for the interesting relationships (names might vary).
  - prerequisites, which has a loop on courses.
  - waitingList should be between Student and limitedcourses (not
    courses), and have a position attribute 
	Should have a position attribute
  - classified should be implemented correctly

* Make sure cardinalities make sense
  - Many-to-One between students and program
  - Many-to-at-most-one between students and branches
  - Many-to-many between department and program
  
* Compare the rest of the diagram with the one provided

* If the use different notation for the arrows and such and don't explain ask them to do so!

# ER Schema

* It should look very much like the one for lab 1 with the additions
  of Departments, Program and HostedBy tables. 
  
* Tables only for entities, many-to-many relationships and
  relationships with weak entities 

* Be extra careful about the PKs of the following tables since
  students often get them wrong (the most common error is in
  parenthesis): 
  - Classified (only course as PK)
  - Registered (only student as PK)
  - MandatoryProgram (only course as PK)
  - RecomendeBranch, MandatoryBranch (only branch name is part of the PK)
  - WaitingList (all attributes as PK)

* Make sure all FK references to branches are pair of (branch,
  program)
  
* Students should not have a branch attribute

# Functional dependencies

* Make sure they use no extra attributes than the ones provided.

* 15 FD (when written with a single attribute in the RHS)

* There are essentially 3 groups of FDs in this domain, make sure they exist. 
  - Student related
  - Course related
  - WaitingList/Taken related

* Look for the important FDs which are the ones that create UNIQUE constrains
  - (idnr -> login) and (login -> idnr); they often forgot login as an attribute in the ER 
  - (course idnr -> positon) and (course position -> idnr)
  - (departmentName -> departmentAbbreviation) and
     (departmentAbbreviation -> departmentName)

* Look for non-FDS, the most common are:
  - (idnr -> course)
  - (course -> clasification)
  - (course -> grade) or (idnr -> grade)
  - (idnr programName -> branch)
  - (program -> course)
  - (branch -> course)

* The output of online BCNF decomposition tool, is fine here.

* Make sure the MVD make sense and that they have at least one
  (probably `course ->> clasification` or 
  `courseCode studentIdnr ->> grade/position`) 

# FD Schema

* Look for the following 3 pairs, where one should be a PK and the
  other should have an UNIQUE constrain 
  - idnr/login 
  - dname/dcode
  - course idnr/course position
  
* Extra constraint in StudentBranches: (idnr, program)
  
* There should be 7 or 8 tables

# SQL

* Check that everything looks like in the ER

* Look for the 3 UNIQUE constrains from the FD Schema (`login`,
  `dname`, and `(course,position)`) 

* Look for a FK constrain in `StudentBranches` of the form
  `(idnr,program) -> Student(idnr,program)` and if this exists make
  sure `(idnr,program)` is UNIQUE in the students table since
  otherwise the code will not run.
