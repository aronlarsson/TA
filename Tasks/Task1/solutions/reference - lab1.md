# Grading reference

## Failed tests

* If the error message is clear fail with small "look at the tests" message

* If the error is tricky to understand add a small hint. common tricky errors include:
  * Wrong `qualified` column for student `7890123456` on `PathToGraduation`
  * Duplicated students on `PathToGraduation`

## Successful test

In this case the submission is in good shape but some manual checks still need to be
performed:

* Make sure the `inserts.sql` file is only included with a reason writen somewhere is the submission. Otherwise, fail and ask to re-submit without it.
  - If a reason is given, check that the count of recomended credits in `pathToGraduation` is correct in particular that they correctly match the brach of the student to the recomended course.
  (I believe this doesn't apply anymore, we don't allow students to submit an `inserts.sql` file)
* Course names are only 6 character
* Grades in `Taken` can only be in `{U,3,4,5}`
* Course credits can not be negative
* Limited courses should not allow negative capacities
* Students ids should be length 10
* No extra constrains:
  * Overly restrictive types
  * Checks not in the domain description
