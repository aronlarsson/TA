# Common feedback

## Tables

- Since the domain description doesn't specify any constraints on the credits on a course, it is probably better to allow courses with zero credits (however you should never be able to lose credits from taking a course, so it can't be negative. If that would be possible, it should have been stated in the description).
- Course codes should always be six characters.
- Course credits should not be allowed to be negative.
- Capacity of a limited course should not be allowed to be negative.
- You should use types in referencing columns that matches the type of the column being referenced to.
- Position in waiting list should at least not be allowed to be negative.
- Grades should only be allowed to be one of U, 3, 4 , 5.



## Views

- You are using a lot of outer JOINS (LEFT/RIGHT). You should always use (INNER) JOIN by default and make sure to only use right join where necessary.