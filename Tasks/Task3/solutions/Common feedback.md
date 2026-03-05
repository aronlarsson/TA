# Common feedback

## Both
- You should have a check if the course is limited before checking whether or not the number of registered students are larger than the capacity. If the course is not limited, the condition with the capacity evaluates to NULL, so the body of the IF statement is skipped. But unless you know the details of PostgreSQL it might be hard to follow along.

## Register

- The exception that a student or course doesn't exist is unnecessary; if that is the case, the trigger will never run, since there are no matching rows in the view that you try to insert into.
- In the insert trigger, if you successfully made an insert (either in Registered or WaitingList), you should return NEW to indicate that the operation was completed successfully. If you return NULL, it reports that no rows were affected, and it also prevents any potential subsequent triggers from running.

## Unregister

- The exception that a student isn't registered or waiting is unnecessary; if that is the case, the trigger will never run, since there are no matching rows in the view that you try to delete from. That means that if the student isn't registered, it has to be waiting when you are inside the trigger.
- You should also check in the deletion trigger if the student is waiting or registered (it has to be one of them, otherwise the trigger wouldn't run), and then delete accordingly, instead of simply deleting from both always. It makes it harder to understand what is happening, and looks like a student can be both waiting and registered for the same course at the same time.
- In the deletion trigger, if you successfully deleted (either from Registered or WaitingList), you should return OLD to indicate that the operation was completed successfully. If you return NULL, it reports that no rows were affected, and it also prevents any potential subsequent triggers from running.