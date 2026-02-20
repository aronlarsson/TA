CREATE OR REPLACE FUNCTION register_student() RETURNS TRIGGER AS
$$
DECLARE
    course_capacity      INT;
    course_registrations INT;
    max_position         INT;
BEGIN
    -- Already waiting/registered?
    IF EXISTS(SELECT * FROM Registrations WHERE student = NEW.student AND course = NEW.course)
    THEN
        RAISE EXCEPTION 'Student already registered or waiting';
    END IF;

    -- Are prerequisites met?
    IF EXISTS(
        SELECT prerequisite FROM Prerequisites WHERE course = NEW.course
        EXCEPT
        SELECT course FROM PassedCourses WHERE student = NEW.student
    )
    THEN
        RAISE EXCEPTION 'Prerequisites are not met';
    END IF;

    -- Already passed?
    IF EXISTS (SELECT course FROM PassedCourses WHERE student = NEW.student AND course = NEW.course)
    THEN
        RAISE EXCEPTION 'Already passed';
    END IF;

    course_capacity := (SELECT capacity FROM LimitedCourses WHERE code = NEW.course);
    course_registrations := (SELECT COUNT(*) FROM Registered WHERE course = NEW.course);

    -- Already full?
    IF EXISTS (SELECT *
               FROM LimitedCourses
               WHERE code = NEW.course) AND course_registrations >= course_capacity
    THEN
        max_position := (SELECT COALESCE(MAX(position), 0) FROM WaitingList WHERE course = NEW.course);
        INSERT INTO WaitingList VALUES (NEW.student, NEW.course, max_position + 1);

    ELSE
        INSERT INTO Registered VALUES (NEW.student, NEW.course);
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER register_student
    INSTEAD OF INSERT
    ON Registrations
    FOR EACH ROW EXECUTE FUNCTION register_student();


CREATE OR REPLACE FUNCTION update_waiting_list () RETURNS TRIGGER AS $$
    BEGIN
        UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course AND position >= OLD.position;
        RETURN OLD;
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_waiting_list
    AFTER DELETE
    ON WaitingList
    FOR EACH ROW EXECUTE FUNCTION update_waiting_list();


CREATE OR REPLACE FUNCTION unregister_student () RETURNS TRIGGER AS $$
    DECLARE
        course_capacity INT;
        course_registrations INT;
        waiting_student VARCHAR(10);
    BEGIN
        IF EXISTS(SELECT * FROM Registered WHERE student = OLD.student AND course = OLD.course) THEN
            DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            course_capacity := (SELECT capacity FROM LimitedCourses WHERE code = OLD.course);
            course_registrations := (SELECT COUNT(*) FROM Registered WHERE course = OLD.course);
            IF course_registrations < course_capacity AND EXISTS(SELECT * FROM WaitingList WHERE course = OLD.course) THEN
                waiting_student := (SELECT student FROM WaitingList WHERE course = OLD.course AND position = 1);
                DELETE FROM WaitingList WHERE course = OLD.course AND position = 1;
                INSERT INTO Registrations VALUES (waiting_student, OLD.course, 'registered');
            END IF;
        ELSE
            DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
        END IF;
        RETURN OLD;
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER unregister_student
    INSTEAD OF DELETE
    ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister_student();