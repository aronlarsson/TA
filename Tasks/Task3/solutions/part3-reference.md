# Grading reference

Remember: in your comments, give hints to the problem but not the exact solution!

In this part, the students are told to previde a series of inserts on
which Fire will run the followin tests:

1. valid registration to an unlimited course
2. valid registration to a limited course (in WaitingList position 1)
3. valid registration to the same limited course (in WaitingList position 2)
4. valid registration to a limited course with place
5. valid registration to the same limited course (in WaitingList position 1)
6. valid registration to an unlimited course
7. failed registration (course already passed)
8. failed registration (student already registered)
9. failed registration (student already in waiting list)
10. failed registration (student missing prereq)
11. failed registration (student missing prereq)
12. unregister a student from all courses, no change in waiting list
13. valid registration to a limited course (in WaitingList position 3)
14. unregister from waiting list, requires updating position in waiting list
15. unregister from course, requires moving from waiting lis and
        updating positions in waiting list
16. same here, waiting list becomes empty for the course
17. valid registration to an unlimited course


## Failed test

* A reason a particular test fails or doesn't give the expected output
  could simply be that they have configured the inserts.sql file
  wrongly. Have a quick look at it and ask to correct and resubmit if
  needed. 

 * If the error message is clear fail with small "look at the tests" message.

* Possible errors include:
   - no correct updating of position
   - typos in the views' name or attributes
   - Infinite loop/recursion in the trigger functions
   - Left-over `psql` sintax like `\set` or `\i`
   
* Do have a look at the triggers file as well to see whether there are
  things to comment there 


## Successful tests

* Look at their `triggers.sql` file, the main point of interests are

  - Does the code look reasonable easy to understand?
     We will not put much emphasis here but a very complicated code
     shouldn't be accepted either.
     
  - We will not put much emphasis in efficiency but here are a few common problems:
     - computing unnecessary Cartesian products/inner joins
     - defining too many variables as result of computations which will only be used once; 
        this said, use of variables can make the reading of the code easier
     - defining too many variables as result of computations at the beginning of the function, 
       of which most of them might not be needed at all if for example the student has
       already passed the course (or any other situation)

  - On the insert trigger there should be exceptions for lack of
    pre-requisites, already passed courses, and already registered to
    a course

  - On the insert trigger look for where the decision to register or wait
    is being made and make sure it looks good

  - On the delete trigger there is no possible exceptions.

  - On the delete trigger look for how they decide where to delete
    from. They can either look in `registrations` or in each of the tables,
    whichever is fine.

  - On the delete trigger make sure they delete from the `Registered` table
    before counting how many seat are left. otherwise it will always
    be full

  - Have a look at how they handle the position in the waiting list
    when inserting and deleting there, is it consistent and correct?

* For loops are forbidden, ew!
