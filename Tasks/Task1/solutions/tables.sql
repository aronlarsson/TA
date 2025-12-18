CREATE TABLE IF NOT EXISTS Students (
    idnr VARCHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login VARCHAR(20) NOT NULL,
    program TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Branches (
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)
);

CREATE TABLE IF NOT EXISTS Courses (
    code VARCHAR(6) PRIMARY KEY
        CONSTRAINT code_format CHECK ( char_length(code) = 6 ),
    name TEXT NOT NULL,
    credits INT NOT NULL
        CONSTRAINT non_negative_credits CHECK ( credits >= 0 ),
    department VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS LimitedCourses(
    code VARCHAR(6) PRIMARY KEY REFERENCES Courses(code),
    capacity INT NOT NULL
        CONSTRAINT non_negative_capacity CHECK ( capacity >= 0 )
);

CREATE TABLE IF NOT EXISTS StudentBranches(
    student VARCHAR(10) PRIMARY KEY REFERENCES Students(idnr),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE IF NOT EXISTS Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS Classified(
    course VARCHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE IF NOT EXISTS MandatoryProgram(
    course VARCHAR(6) REFERENCES Courses(code),
    program TEXT,
    PRIMARY KEY (course, program)
);

CREATE TABLE IF NOT EXISTS MandatoryBranch(
    course VARCHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE IF NOT EXISTS RecommendedBranch(
    course VARCHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE IF NOT EXISTS Registered(
    student VARCHAR(10) REFERENCES Students(idnr),
    course VARCHAR(6) REFERENCES Courses(code),
    PRIMARY KEY (student, course)
);

CREATE TABLE IF NOT EXISTS Taken(
    student VARCHAR(10) REFERENCES Students(idnr),
    course VARCHAR(6) REFERENCES Courses(code),
    grade VARCHAR(1) NOT NULL
        CONSTRAINT allowed_grades CHECK ( grade in ('U', '3', '4', '5') ),
    PRIMARY KEY (student, course)
);

CREATE TABLE IF NOT EXISTS WaitingList(
    student VARCHAR(10) REFERENCES Students(idnr),
    course VARCHAR(6) REFERENCES LimitedCourses(code),
    position INT NOT NULL
        CONSTRAINT greater_than_zero CHECK ( position > 0 ),
    PRIMARY KEY (student, course)
);