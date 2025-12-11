CREATE VIEW CourseQueuePositions AS
  SELECT * FROM WaitingList;

CREATE OR REPLACE FUNCTION register() RETURNS TRIGGER AS $$
    BEGIN
        -- Check that the student has not passed the course
        IF EXISTS (SELECT student, course FROM PassedCourses 
                   WHERE (NEW.student = PassedCourses.student 
                          AND NEW.course = PassedCourses.course)
                  ) THEN
            RAISE EXCEPTION 'Student has already passed that course';
        END IF;
        
        -- Check that the student is not already registered
        IF EXISTS (SELECT * FROM Registrations 
                   WHERE (student = NEW.student 
                          AND course = NEW.course)
                  ) THEN
            RAISE EXCEPTION 'Student is already % for this course.', (SELECT status FROM Registrations WHERE student = NEW.student AND course = NEW.course);
        END IF;
        -- Check that the student has passed prereqs
        IF EXISTS(SELECT prerequisite FROM Prerequisites WHERE course = NEW.course 
                  EXCEPT 
                  SELECT course FROM PassedCourses WHERE student = NEW.student
                 ) THEN
            RAISE EXCEPTION 'Student has not finished the prerequisite courses.';
        END IF;
        
        -- Is the course limited and full?
        IF EXISTS(SELECT * FROM Limitedcourses AS C
                  WHERE C.code = NEW.course 
                        AND (SELECT COUNT(*) FROM Registrations WHERE course = NEW.course) >= seats
                 ) THEN
            INSERT INTO WaitingList VALUES(
                NEW.student, 
                NEW.course, 
                (SELECT COUNT(*) + 1 FROM WaitingList WHERE course = NEW.course)
                );
            
        ELSE
            INSERT INTO Registered VALUES(NEW.student, NEW.course);
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER register
INSTEAD OF INSERT ON Registrations
FOR EACH ROW EXECUTE PROCEDURE register();
CREATE FUNCTION unregister() RETURNS trigger AS $$
DECLARE 
   waitingStudent TEXT;
   oldPosition INTEGER;
BEGIN
    IF OLD.status = 'registered' THEN
        DELETE FROM Registered WHERE (student = OLD.student AND course = OLD.course);
        
        -- Check if there is a free spot
        IF EXISTS(SELECT * FROM Limitedcourses AS C
                  WHERE C.code = OLD.course 
                        AND (SELECT COUNT(*) FROM Registered WHERE course = OLD.course) < C.seats -- Note use of registered table, to not count waiting list
                 ) THEN
            SELECT student INTO waitingStudent FROM WaitingList WHERE course=OLD.course AND position=1;
            
			-- Check that there is a student waiting
            IF waitingStudent IS NOT NULL THEN
              INSERT INTO Registered VALUES (waitingStudent, OLD.course);
              DELETE FROM WaitingList WHERE course = OLD.course AND position=1;
              UPDATE WaitingList SET position = position - 1 WHERE WaitingList.course = OLD.course;
			END IF;
        END IF;
        
    ELSE -- student on waiting list
        SELECT position INTO oldPosition FROM CourseQueuePositions WHERE student=OLD.student AND course=OLD.course;
        DELETE FROM WaitingList WHERE (course = OLD.course AND student=OLD.student);
        UPDATE WaitingList SET position = position - 1 WHERE WaitingList.course = OLD.course AND position > oldPosition;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unregister
INSTEAD OF DELETE ON Registrations
FOR EACH ROW EXECUTE PROCEDURE unregister();