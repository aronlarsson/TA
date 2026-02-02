# Grading reference

In your comments, give hints to the problem but not the exact solution!
For example, the type of Courses is too general/not fully correct/not specific enough instead of the type of courses should be CHAR(6).

## Failed tests

* If the error message is clear, fail with a simple "look at the tests" message;
* If the error is tricky to understand, add a small hint.
* Common errors are
  * Wrong "qualified" column for some student on PathToGraduation
  * Duplicated students on PathToGraduation


## Successful test

In this case the submission is in good shape but some manual checks
still need to be performed:

* Course codes are only 6 character
* Grades in Taken can only be in {U,3,4,5}
* Course credits cannot be negative
* Limited courses should not allow negative capacities
* Students ids should be length 10
  Constraint for digit-only ids is not mandatory but good to
  have/encourage 
* No extra constrains except maybe some very sensible ones (for
  example position > 0):
  * Overly restrictive types
  * Checks not in the domain description
* Type of a foreign key should be the same as that in the referenced
  column (would Postgres complain if not?)
* Have a look at the code and try to identify not very good things,
  for example
  * unreadable/over complicated code (see comment later on)
  * expressions that are computed twice (for example nr of math
    credits computed in the selection and for the qualified attribute)
  * expressions of the style CASE <cond> THEN TRUE ELSE FALSE
  * have an unnecessary GROUP BY in a query which groups by many
    attributes to the point that each group is a singleton
  * over use of OUTER JOIN
* Beware for automatically generated code. If a submission is very
  long and/or overly complicated it might have been automatically
  generated and should be rejected.
* There is nothing so far that prevents a student having different
  programs in the tables Students and StudentBranches, do they check
  the program coincides in the view BasicInformation? Not really
  necessary they check this but might good to "flag"?
  
## Automatic tests

When grading the PathToGraduation view, every student that doesn't
qualify in the automatic test has a specific purpose, listed here:

-- Student 0123456789: doesn't belong to any branch
-- Student 1234567890: hasn't taken the mandatory courses on their branch
-- Student 2345678901: hasn't taken the mandatory courses on their program
-- Student 3456789012: doesn't have enough math credits
-- Student 5678901234: hasn't taken any seminar
-- Student 6789012345: doesn't have enough credits from the recommended courses of his branch
-- Student 7890123456: is qualified

