# Grading reference

For these lab students will submit their own tests; they will be
 printed in Fire one by one, followed by the join of the `coursequeuepositions` and
 `registrations` views.

## Failed test

 - If the error message is clear fail with small "look at the tests" message.
   Common errors include:

   - typos in the views' name or attributes
   - Infinite loop/recursion in the trigger functions
   - Left-over `psql` sintax like `\set` or `\i`

- If a tests appears as failed but its output is mostly correct this is ok;
  as long as the tests cases are being printed there is no need to fail students.
  These errors occur when last line of the file is a comment or lacks a EOL.

- If the output of the tests includes `SELECTS` or `INSERTS/DELETES` not
  to `registrations` you can ask them to re-submit with better tests.
  These is of course entirely up to you, but if you are trying to hard
  to understand a tests output it should have been better ;)

## Successful tests

- The very first thing you should do is go through the test cases an
  make sure they make sense. Some submission will have comments
  explaining what each tests does; while they are not required
  to do so, if you can no understand the reasoning for some of the
  tests is ok to ask students to resubmit with some comments above
  their tests.

- The main test cases one should look for are:
  - register to an unlimited course
  - register to a limited course
  - Try register when already register
  - Try to register when already waiting
  - Try to register to an already passed course
  - register to a course with pre-requisites
  - Try to register without fulfilling the pre-requisites
  - unregister from an unlimited course
  - unregister from a limited course without a waiting list
  - unregister from a limited course with a waiting list
  - unregister from a limited course with a waiting list when the student is registered
  - unregister when the student is in the middle of the waiting list
  - unregister from an overfull course with a waiting list

- If you found any inconsistencies with the tests cases write in your message
  with reference to the tests that failed and the expected output. common errors
  are:

  - Nothing happened, when it should have
  - pre-requisites are completely ignored
  - The waiting list (coursequeuepositions) is out of order or it has gaps
  - They say something will happen and then something else happens

- Next look at their `triggers.sql` file, the main point of interests are

  - On the insert trigger there should be exceptions for lack of pre-requisites,
    already passed courses, and already registered to a course

  - On the insert trigger look for where the decision to register or wait
    is being made and make sure it looks good

  - Depending on their implementation of `coursequeuepositions` you might need
    to check if a student is being added at the `MAX(position) + 1` position


  - On the delete trigger there is no possible exceptions.

  - On the delete trigger look for how they decide where to delete
    from. They can either look in `registrations` or in each of the tables,
    whichever is fine.

  - On the delete trigger make sure they delete from the `Registered` table
    before counting how many seat are left. otherwise it will always be full


- Finally take a look at the `coursequeuepositions` view and whether it
  does something interesting or not. In the first case (interesting)
  chances are the trigger functions will be simple as they don't need
  to order the waiting list on each operation. Otherwise, pay extra attention
  on the trigger function on how the waiting list is updated; in this case
  the delete trigger must have an `UPDATE` operation decreasing the positions
  in the list.

- For loops are forbidden, ew!