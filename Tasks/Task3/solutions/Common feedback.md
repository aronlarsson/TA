# Common feedback

## Register

- The exception that a student or course doesn't exist is unnecessary; if that is the case, the trigger will never run, since there are no matching rows in the view that you try to insert into.

## Unregister

- The exception that a student isn't registered or waiting is unnecessary; if that is the case, the trigger will never run, since there are no matching rows in the view that you try to delete from. That means that if the student isn't registered, it has to be waiting when you are inside the trigger.