CREATE DATABASE Project

use Project


CREATE TABLE Trainee(
	Trainee_ID INT PRIMARY KEY,
	FName NVARCHAR(100),
	LName NVARCHAR(100),
	Gender BIT DEFAULT 0,
	Email NVARCHAR(100),
	Background NVARCHAR(100)
);


-- Drop default constraint
ALTER TABLE Trainee
DROP CONSTRAINT DF__Trainee__Gender__24927208;

-- Now drop the column
ALTER TABLE Trainee
DROP COLUMN Gender;

-- ADD THE COLUMN WITH THE DATA TYPE THAT I CHANGE IT
ALTER TABLE Trainee
ADD Gender NVARCHAR(100);

-- Check if the column exists, then add it only if it doesn't
IF COL_LENGTH('Trainee', 'TName') IS NULL
BEGIN
    ALTER TABLE Trainee ADD TName NVARCHAR(50);
END

-- To Marge two column as one column
ALTER TABLE Trainee
ADD TName NVARCHAR(50)

UPDATE Trainee
SET TName = CONCAT(FName, ' ', LName)

ALTER TABLE Trainee 
DROP COLUMN FName

ALTER TABLE Trainee 
DROP COLUMN LName

DELETE FROM Enrollment;
DELETE FROM Trainee;

-- Drop the existing foreign key first
ALTER TABLE Enrollment DROP CONSTRAINT FK__Enrollmen__Train__34C8D9D1;

-- Recreate it with ON DELETE CASCADE
ALTER TABLE Enrollment 
ADD CONSTRAINT FK_Trainee_Enrollment 
FOREIGN KEY (Trainee_ID) REFERENCES Trainee(Trainee_ID) ON DELETE CASCADE;


SELECT * FROM Trainee

INSERT INTO Trainee(Trainee_ID, TName, Gender, Email, Background)
VALUES (1, 'Aisha Al-Harthy', 'Female', 'aisha@example.com', 'Engineering'),
	   (2, 'Sultan Al-Farsi', 'Male', 'sultan@example.com', 'Business'),
       (3, 'Mariam Al-Saadi', 'Female', 'mariam@example.com', 'Marketing'),
       (4, 'Omar Al-Balushi', 'Male', 'omar@example.com', 'ComputerScience'),
       (5, 'Fatma Al-Hinai', 'Female', 'fatma@example.com', 'DataScience');


CREATE TABLE Trainer(
	Trainer_ID INT PRIMARY KEY,
	FName NVARCHAR(100),
	LName NVARCHAR(100),
	Specialty NVARCHAR(20),
	Phone NVARCHAR(20),
	Email NVARCHAR(100)
);

sp_help Trainer;

ALTER TABLE Trainer 
DROP COLUMN TRName;

ALTER TABLE Trainer 
ADD TRName NVARCHAR(50);

-- First, delete dependent rows if any
DELETE FROM Schedule;  
DELETE FROM Trainer;


SELECT * FROM Trainer

INSERT INTO Trainer(Trainer_ID, TRName, Specialty, Phone, Email)
VALUES (1, 'Khalid Al-Maawali', 'Databases', '96891234567', 'khalid@example.com'),
	   (2, 'Noura Al-Kindi', 'Web Development', '96892345678', 'noura@example.com'),
	   (3, 'Salim Al-Harthy', 'Data Science', '96893456789', 'salim@example.com' );

CREATE TABLE Course(
	Course_ID INT PRIMARY KEY,
	Title NVARCHAR(100),
	Category NVARCHAR(50),
	Duration_hours INT,
	C_Level NVARCHAR(20)
);

DELETE FROM Schedule; -- Delete dependent rows first if needed
DELETE FROM Course;   -- Then delete existing courses

SELECT * FROM Course

INSERT INTO Course(Course_ID, Title, Category, Duration_hours, C_Level)
VALUES (1, 'Database', 'Fundamentals Databases', 20, 'Beginner'),
	  (2, 'Web Development Basics' , 'Web' ,30, 'Beginner'),
	  (3, 'Data Science Introduction', 'Data Science', 25, 'Intermediate'),
	  (4, 'Advanced SQL Queries', 'Databases', 15, 'Advanced'); 

CREATE TABLE Schedule(
	Schedule_ID INT PRIMARY KEY,
	Course_ID INT,
	Trainer_ID INT,
	StartDate DATE,
	EndDate DATE,
	TimeSlot NVARCHAR(50),
	FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID),
	FOREIGN KEY (Trainer_ID) REFERENCES Trainer(Trainer_ID)
);

SELECT * FROM Schedule

INSERT INTO Schedule(Schedule_ID, Course_ID, Trainer_ID, StartDate, EndDate, TimeSlot)
VALUES (1, 1, 1, '2025-07-01', '2025-07-10', 'Morning'),
	   (2, 2, 2, '2025-07-05', '2025-07-20', 'Evening'),
	   (3, 3, 3, '2025-07-10', '2025-07-25', 'Weekend'),
	   (4, 4, 1, '2025-07-15', '2025-07-22', 'Morning');

CREATE TABLE Enrollment(
	Enrollment_ID INT PRIMARY KEY,
	Trainee_ID INT,
	Course_ID INT,
	EnrollmentDate DATE,
	FOREIGN KEY (Trainee_ID) REFERENCES Trainee(Trainee_ID),
	FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
);

DROP TABLE Enrollment;

SELECT * FROM Enrollment

INSERT INTO Enrollment(Enrollment_ID, Trainee_ID, Course_ID, EnrollmentDate)
VALUES (1, 1, 1, '2025-06-01'),
	   (2, 2, 1, '2025-06-02'), 
	   (3, 3, 2, '2025-06-03'),
	   (4, 4, 3, '2025-06-04'), 
	   (5, 5, 3, '2025-06-05'), 
	   (6, 1, 4, '2025-06-06');
-------------------------------------------------------------------------
-- Trainee Perspective :
-- 1- Show all available courses (title, level, category)
SELECT Title, C_Level, Category
From Course;

-- 2- View beginner-level Data Science courses 
SELECT Title, C_Level, Category
FROM Course
WHERE C_Level = 'Beginner' AND Category = 'Data Science';

-- 3- Show courses this trainee is enrolled in 
SELECT C.Title 
FROM Enrollment E
Join Course C ON E.Course_ID = C.Course_ID
WHERE E.Trainee_ID = 1;

-- 4- View the schedule (start_date, time_slot) for the trainee's enrolled courses 
SELECT C.Title, S.StartDate, S.TimeSlot
FROM Enrollment E
JOIN Schedule S ON E.Course_ID = S.Course_ID
JOIN Course C ON S.Course_ID = C.Course_ID
WHERE E.Trainee_ID = 1;

-- 5- Count how many courses the trainee is enrolled in 
SELECT COUNT(*) AS CourseCount 
FROM Enrollment E
WHERE Trainee_ID = 1;

-- 6- Show course titles, trainer names, and time slots the trainee is attending
SELECT C.Title, T.TRName AS TRName, S.TimeSlot
FROM Enrollment E
JOIN Schedule S ON E.Course_ID = S.Course_ID
JOIN Course C ON S.Course_ID = C.Course_ID
JOIN Trainer T ON T.Trainer_ID = S.Trainer_ID
WHERE E.Trainee_ID = 1;

-----------------------------------------------------------------------
-- Trainer Perspective:
-- 1- List all courses the trainer is assigned to
SELECT DISTINCT C.Title
FROM Schedule S
JOIN Course C ON S.Course_ID = C.Course_ID
WHERE S.Trainer_ID = 1;

-- 2- Show upcoming sessions (with dates and time slots) 
SELECT C.Title, S.StartDate, S.EndDate, S.TimeSlot
FROM Schedule S
JOIN Course C ON S.Course_ID = C.Course_ID
WHERE S.Trainer_ID = 1 AND S.StartDate >= GETDATE();

-- 3- See how many trainees are enrolled in each of your courses 
SELECT C.Title, COUNT(E.Trainee_ID) AS Number_Of_Trainees
FROM Schedule S
JOIN Course C ON S.Course_ID = C.Course_ID
JOIN Enrollment E ON C.Course_ID = E.Course_ID
WHERE S.Trainer_ID = 1
GROUP BY C.Title;

-- 4- List names and emails of trainees in each of your courses 
SELECT DISTINCT T.TName AS TraineeName, T.Email
FROM Schedule S
JOIN Enrollment E ON S.Course_ID = E.Course_ID
JOIN Trainee T ON T.Trainee_ID = E.Trainee_ID
WHERE S.Trainer_ID = 1;

-- 5- Show the trainer's contact info and assigned courses
SELECT T.Phone, T.Email, C.Title
FROM Trainer T
JOIN Schedule S ON T.Trainer_ID = S.Trainer_ID
JOIN Course C ON S.Course_ID = C.Course_ID
WHERE T.Trainer_ID = 1;

-- 6- Count the number of courses the trainer teaches 
SELECT COUNT(DISTINCT Course_ID) AS CourseCount
FROM Schedule
WHERE trainer_id = 1;
---------------------------------------------------------------------
--Admin Perspective:
-- 1-Add a new course (INSERT statement)
INSERT INTO Course (Course_ID, Title, Category, Duration_hours, C_Level)
VALUES (5, 'Python Basics', 'Programming', 25, 'Beginner');

-- 2-Create a new schedule for a trainer 
INSERT INTO Schedule (Schedule_ID, Course_ID, Trainer_ID, StartDate, EndDate, TimeSlot)
VALUES (5, 5, 2, '2025-07-25', '2025-08-05', 'Evening');

-- 3-View all trainee enrollments with course title and schedule info
SELECT T.TName AS trainee_name, C.Title AS Course_Title, S.StartDate, S.TimeSlot
FROM Enrollment E
JOIN Trainee T ON E.trainee_id = T.Trainee_ID
JOIN Course C ON E.Course_ID = C.Course_ID
JOIN Schedule S ON C.Course_ID = S.Course_ID;

-- 4-Show how many courses each trainer is assigned to
SELECT T.TRName AS Trainer_Name, COUNT(DISTINCT S.Course_ID) AS CourseCount
FROM Trainer T
JOIN Schedule S ON T.Trainer_ID = S.Trainer_ID
GROUP BY T.TRName;

-- 5-List all trainees enrolled in "Data Basics"
SELECT T.TName, T.Email
FROM Enrollment E
JOIN Trainee t ON E.Trainee_ID = T.Trainee_ID
JOIN Course c ON E.Course_ID = C.Course_ID
WHERE C.Title = 'Data Basics';

-- 6-Identify the course with the highest number of enrollments 
SELECT TOP 1 C.Title, COUNT(E.Enrollment_ID) AS Total_Enrollments
FROM Enrollment E
JOIN Course C ON E.Course_ID = C.Course_ID
GROUP BY C.Title
ORDER BY Total_Enrollments DESC;

-- 7- Display all schedules sorted by start date
SELECT *
FROM Schedule
ORDER BY StartDate ASC;