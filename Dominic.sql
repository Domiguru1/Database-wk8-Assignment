-- Student Records Management System
-- Database Creation
DROP DATABASE IF EXISTS student_records_system;
CREATE DATABASE student_records_system;
USE student_records_system;

-- Table Creation with Constraints
-- Departments Table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    established_date DATE NOT NULL,
    building VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2) CHECK (budget >= 0)
);

-- Programs Table
CREATE TABLE programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_name VARCHAR(100) NOT NULL UNIQUE,
    program_code VARCHAR(10) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    duration_years INT NOT NULL CHECK (duration_years BETWEEN 1 AND 6),
    degree_level ENUM('Certificate', 'Diploma', 'Bachelor', 'Master', 'PhD') NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    enrollment_date DATE NOT NULL,
    program_id INT NOT NULL,
    graduation_date DATE,
    status ENUM('Active', 'Suspended', 'Graduated', 'Withdrawn') DEFAULT 'Active',
    FOREIGN KEY (program_id) REFERENCES programs(program_id),
    CHECK (graduation_date IS NULL OR graduation_date > enrollment_date)
);

-- Courses Table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    description TEXT,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Faculty Table
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) CHECK (salary >= 0),
    status ENUM('Active', 'On Leave', 'Retired') DEFAULT 'Active',
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Program_Courses (Many-to-Many Relationship)
CREATE TABLE program_courses (
    program_id INT NOT NULL,
    course_id INT NOT NULL,
    is_core BOOLEAN NOT NULL DEFAULT TRUE,
    semester_offered INT CHECK (semester_offered BETWEEN 1 AND 12),
    PRIMARY KEY (program_id, course_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Classes Table
CREATE TABLE classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    faculty_id INT NOT NULL,
    semester ENUM('Fall', 'Spring', 'Summer') NOT NULL,
    year INT NOT NULL CHECK (year BETWEEN 2000 AND 2100),
    room_number VARCHAR(20) NOT NULL,
    schedule VARCHAR(100) NOT NULL,
    max_capacity INT NOT NULL CHECK (max_capacity > 0),
    current_enrollment INT DEFAULT 0 CHECK (current_enrollment >= 0 AND current_enrollment <= max_capacity),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id),
    UNIQUE (course_id, semester, year, schedule)
);

-- Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade DECIMAL(4,2) CHECK (grade BETWEEN 0 AND 100),
    status ENUM('Enrolled', 'Dropped', 'Completed', 'Failed') DEFAULT 'Enrolled',
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    UNIQUE (student_id, class_id)
);

-- Student_Grades Table
CREATE TABLE student_grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    assignment_name VARCHAR(100) NOT NULL,
    grade DECIMAL(5,2) NOT NULL CHECK (grade BETWEEN 0 AND 100),
    weight DECIMAL(5,2) CHECK (weight BETWEEN 0 AND 100),
    submission_date DATE,
    feedback TEXT,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Student_Financials Table
CREATE TABLE student_financials (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_type ENUM('Tuition', 'Fee', 'Scholarship', 'Payment', 'Refund') NOT NULL,
    description TEXT,
    payment_method VARCHAR(50),
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Library_Books Table
CREATE TABLE library_books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_year INT,
    category VARCHAR(50),
    total_copies INT NOT NULL DEFAULT 1 CHECK (total_copies >= 0),
    available_copies INT NOT NULL DEFAULT 1 CHECK (available_copies >= 0 AND available_copies <= total_copies)
);

-- Book_Loans Table
CREATE TABLE book_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('Checked Out', 'Returned', 'Overdue', 'Lost') DEFAULT 'Checked Out',
    FOREIGN KEY (book_id) REFERENCES library_books(book_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    CHECK (due_date > checkout_date),
    CHECK (return_date IS NULL OR return_date >= checkout_date)
);

-- Sample Data Insertion
-- Insert Departments
INSERT INTO departments (department_name, department_code, established_date, building, budget)
VALUES 
('Computer Science', 'CS', '1990-01-15', 'Engineering Building', 1500000.00),
('Mathematics', 'MATH', '1985-08-20', 'Science Building', 800000.00),
('Physics', 'PHY', '1988-05-10', 'Science Building', 950000.00),
('English Literature', 'ENG', '1975-03-25', 'Humanities Building', 600000.00),
('Business Administration', 'BUS', '1995-11-05', 'Business Building', 1200000.00);

-- Insert Programs
INSERT INTO programs (program_name, program_code, department_id, duration_years, degree_level)
VALUES 
('Bachelor of Science in Computer Science', 'BSCS', 1, 4, 'Bachelor'),
('Master of Science in Computer Science', 'MSCS', 1, 2, 'Master'),
('Bachelor of Arts in Mathematics', 'BAMATH', 2, 4, 'Bachelor'),
('Bachelor of Science in Physics', 'BSPHY', 3, 4, 'Bachelor'),
('Bachelor of Arts in English', 'BAENG', 4, 4, 'Bachelor'),
('Master of Business Administration', 'MBA', 5, 2, 'Master');

-- Insert Courses
INSERT INTO courses (course_code, course_name, credits, description, department_id)
VALUES 
('CS101', 'Introduction to Programming', 3, 'Fundamentals of programming using Python', 1),
('CS201', 'Data Structures', 4, 'Data structures and algorithms', 1),
('CS301', 'Database Systems', 3, 'Relational database design and implementation', 1),
('MATH101', 'Calculus I', 4, 'Differential and integral calculus', 2),
('MATH201', 'Linear Algebra', 3, 'Vector spaces and linear transformations', 2),
('PHY101', 'General Physics I', 4, 'Mechanics and thermodynamics', 3),
('ENG101', 'Composition I', 3, 'Introduction to academic writing', 4),
('BUS101', 'Principles of Management', 3, 'Fundamentals of business management', 5),
('CS401', 'Artificial Intelligence', 3, 'Introduction to AI concepts', 1),
('BUS301', 'Financial Accounting', 3, 'Principles of financial accounting', 5);

-- Insert Program_Courses
INSERT INTO program_courses (program_id, course_id, is_core, semester_offered)
VALUES 
(1, 1, TRUE, 1),
(1, 2, TRUE, 2),
(1, 3, TRUE, 3),
(1, 4, TRUE, 1),
(1, 5, FALSE, 3),
(1, 9, FALSE, 4),
(2, 2, TRUE, 1),
(2, 3, TRUE, 1),
(2, 9, TRUE, 2),
(3, 4, TRUE, 1),
(3, 5, TRUE, 2),
(4, 6, TRUE, 1),
(5, 7, TRUE, 1),
(6, 8, TRUE, 1),
(6, 10, TRUE, 2);

-- Insert Faculty
INSERT INTO faculty (first_name, last_name, date_of_birth, gender, email, phone, address, hire_date, department_id, position, salary, status)
VALUES 
('John', 'Smith', '1975-04-12', 'Male', 'john.smith@university.edu', '555-0101', '123 University Ave, City', '2005-08-15', 1, 'Professor', 95000.00, 'Active'),
('Sarah', 'Johnson', '1980-07-25', 'Female', 'sarah.johnson@university.edu', '555-0102', '456 College St, City', '2010-03-22', 1, 'Associate Professor', 80000.00, 'Active'),
('Michael', 'Williams', '1968-11-30', 'Male', 'michael.williams@university.edu', '555-0103', '789 Campus Rd, City', '1995-09-10', 2, 'Professor', 100000.00, 'Active'),
('Emily', 'Brown', '1972-05-18', 'Female', 'emily.brown@university.edu', '555-0104', '321 Scholar Ln, City', '2002-01-05', 3, 'Professor', 92000.00, 'Active'),
('David', 'Jones', '1985-02-14', 'Male', 'david.jones@university.edu', '555-0105', '654 Academy Blvd, City', '2015-08-20', 4, 'Assistant Professor', 75000.00, 'Active'),
('Jennifer', 'Garcia', '1978-09-08', 'Female', 'jennifer.garcia@university.edu', '555-0106', '987 Education Dr, City', '2008-07-15', 5, 'Associate Professor', 85000.00, 'Active');

-- Insert Students
INSERT INTO students (first_name, last_name, date_of_birth, gender, email, phone, address, enrollment_date, program_id, graduation_date, status)
VALUES 
('Alice', 'Johnson', '2000-03-15', 'Female', 'alice.johnson@student.university.edu', '555-0201', '100 Student Housing, City', '2018-09-01', 1, '2022-05-15', 'Graduated'),
('Bob', 'Williams', '2001-07-22', 'Male', 'bob.williams@student.university.edu', '555-0202', '101 Student Housing, City', '2019-09-01', 1, NULL, 'Active'),
('Carol', 'Brown', '1999-11-05', 'Female', 'carol.brown@student.university.edu', '555-0203', '102 Student Housing, City', '2020-01-15', 2, NULL, 'Active'),
('Daniel', 'Davis', '2000-05-30', 'Male', 'daniel.davis@student.university.edu', '555-0204', '103 Student Housing, City', '2018-09-01', 3, '2022-05-15', 'Graduated'),
('Eve', 'Miller', '2002-02-18', 'Female', 'eve.miller@student.university.edu', '555-0205', '104 Student Housing, City', '2020-09-01', 4, NULL, 'Active'),
('Frank', 'Wilson', '2001-09-12', 'Male', 'frank.wilson@student.university.edu', '555-0206', '105 Student Housing, City', '2019-09-01', 5, NULL, 'Active'),
('Grace', 'Moore', '1998-12-25', 'Female', 'grace.moore@student.university.edu', '555-0207', '106 Student Housing, City', '2020-09-01', 6, NULL, 'Active'),
('Henry', 'Taylor', '2000-04-07', 'Male', 'henry.taylor@student.university.edu', '555-0208', '107 Student Housing, City', '2018-09-01', 1, NULL, 'Suspended');

-- Insert Classes
INSERT INTO classes (course_id, faculty_id, semester, year, room_number, schedule, max_capacity, current_enrollment)
VALUES 
(1, 1, 'Fall', 2023, 'ENG-101', 'MWF 10:00-10:50', 30, 25),
(2, 1, 'Fall', 2023, 'ENG-102', 'TTH 11:00-12:15', 25, 22),
(3, 2, 'Spring', 2024, 'ENG-201', 'MWF 13:00-13:50', 30, 18),
(4, 3, 'Fall', 2023, 'SCI-105', 'MWF 09:00-09:50', 35, 30),
(5, 3, 'Spring', 2024, 'SCI-106', 'TTH 14:00-15:15', 30, 25),
(6, 4, 'Fall', 2023, 'SCI-201', 'MWF 11:00-11:50', 30, 20),
(7, 5, 'Fall', 2023, 'HUM-101', 'TTH 09:30-10:45', 25, 22),
(8, 6, 'Spring', 2024, 'BUS-101', 'MWF 14:00-14:50', 30, 28),
(1, 2, 'Spring', 2024, 'ENG-103', 'TTH 13:00-14:15', 25, 0),
(9, 1, 'Fall', 2023, 'ENG-202', 'MWF 15:00-15:50', 20, 15);

-- Insert Enrollments
INSERT INTO enrollments (student_id, class_id, enrollment_date, grade, status)
VALUES 
(2, 1, '2023-08-15', 85.5, 'Completed'),
(2, 2, '2023-08-15', 78.0, 'Completed'),
(3, 7, '2023-08-15', 92.5, 'Completed'),
(3, 8, '2024-01-10', NULL, 'Enrolled'),
(4, 4, '2023-08-15', 88.0, 'Completed'),
(5, 6, '2023-08-15', 76.5, 'Completed'),
(6, 7, '2023-08-15', 95.0, 'Completed'),
(7, 8, '2024-01-10', NULL, 'Enrolled'),
(8, 1, '2023-08-15', 65.0, 'Failed'),
(2, 3, '2024-01-10', NULL, 'Enrolled'),
(5, 5, '2024-01-10', NULL, 'Enrolled'),
(3, 10, '2023-08-15', 89.5, 'Completed');

-- Insert Student_Grades
INSERT INTO student_grades (enrollment_id, assignment_name, grade, weight, submission_date, feedback)
VALUES 
(1, 'Midterm Exam', 82.0, 30, '2023-10-15', 'Good work, some minor errors'),
(1, 'Final Exam', 88.0, 40, '2023-12-10', 'Excellent performance'),
(1, 'Project', 90.0, 30, '2023-12-05', 'Well-designed project'),
(2, 'Midterm Exam', 75.0, 30, '2023-10-17', 'Needs improvement in algorithms'),
(2, 'Final Exam', 80.0, 40, '2023-12-12', 'Better than midterm'),
(3, 'Essay 1', 95.0, 20, '2023-09-20', 'Excellent analysis'),
(3, 'Essay 2', 90.0, 20, '2023-11-15', 'Well-researched'),
(6, 'Midterm Exam', 80.0, 30, '2023-10-16', 'Good understanding of concepts'),
(6, 'Final Exam', 73.0, 40, '2023-12-11', 'Some concepts not fully grasped'),
(10, 'Quiz 1', 85.0, 10, '2024-02-05', 'Good start'),
(12, 'Project Proposal', 90.0, 15, '2023-09-15', 'Innovative idea'),
(12, 'Final Project', 89.0, 35, '2023-12-01', 'Well-executed project');

-- Insert Student_Financials
INSERT INTO student_financials (student_id, transaction_date, amount, transaction_type, description, payment_method, status)
VALUES 
(2, '2023-08-01', 5000.00, 'Tuition', 'Fall 2023 Tuition', 'Credit Card', 'Completed'),
(2, '2023-08-15', -1000.00, 'Scholarship', 'Academic Excellence Scholarship', NULL, 'Completed'),
(2, '2024-01-05', 5000.00, 'Tuition', 'Spring 2024 Tuition', 'Bank Transfer', 'Pending'),
(3, '2023-08-01', 6000.00, 'Tuition', 'Fall 2023 Tuition', 'Credit Card', 'Completed'),
(3, '2024-01-05', 6000.00, 'Tuition', 'Spring 2024 Tuition', 'Bank Transfer', 'Pending'),
(4, '2023-08-01', 5000.00, 'Tuition', 'Fall 2023 Tuition', 'Credit Card', 'Completed'),
(5, '2023-08-01', 5000.00, 'Tuition', 'Fall 2023 Tuition', 'Credit Card', 'Completed'),
(6, '2023-08-01', 5000.00, 'Tuition', 'Fall 2023 Tuition', 'Credit Card', 'Completed'),
(7, '2024-01-05', 7000.00, 'Tuition', 'Spring 2024 Tuition', 'Bank Transfer', 'Pending'),
(8, '2023-08-01', 5000.00, 'Tuition', 'Fall 2023 Tuition', 'Credit Card', 'Completed');

-- Insert Library_Books
INSERT INTO library_books (isbn, title, author, publisher, publication_year, category, total_copies, available_copies)
VALUES 
('978-0134685991', 'Effective Java', 'Joshua Bloch', 'Addison-Wesley', 2018, 'Computer Science', 5, 3),
('978-0262033848', 'Introduction to Algorithms', 'Cormen, Leiserson, Rivest, Stein', 'MIT Press', 2009, 'Computer Science', 3, 1),
('978-0321125217', 'Database Systems: The Complete Book', 'Hector Garcia-Molina, Jeffrey D. Ullman, Jennifer Widom', 'Pearson', 2008, 'Computer Science', 2, 2),
('978-0471056690', 'Calculus', 'Michael Spivak', 'Wiley', 2008, 'Mathematics', 4, 4),
('978-0201558029', 'Linear Algebra Done Right', 'Sheldon Axler', 'Springer', 1997, 'Mathematics', 3, 2),
('978-0805382915', 'Fundamentals of Physics', 'David Halliday, Robert Resnick, Jearl Walker', 'Wiley', 2013, 'Physics', 5, 3),
('978-0316769488', 'The Catcher in the Rye', 'J.D. Salinger', 'Little, Brown and Company', 1951, 'Literature', 2, 1),
('978-0136083252', 'Business Essentials', 'Ronald J. Ebert, Ricky W. Griffin', 'Pearson', 2010, 'Business', 3, 2),
('978-0262035613', 'Artificial Intelligence: A Modern Approach', 'Stuart Russell, Peter Norvig', 'Pearson', 2020, 'Computer Science', 2, 0),
('978-0073401805', 'Financial Accounting', 'Robert Libby, Patricia Libby, Frank Hodge', 'McGraw-Hill', 2016, 'Business', 2, 2);

-- Insert Book_Loans
INSERT INTO book_loans (book_id, student_id, checkout_date, due_date, return_date, status)
VALUES 
(1, 2, '2023-09-10', '2023-10-10', '2023-10-05', 'Returned'),
(2, 3, '2023-10-15', '2023-11-15', NULL, 'Overdue'),
(3, 2, '2024-01-20', '2024-02-20', NULL, 'Checked Out'),
(6, 5, '2023-11-01', '2023-12-01', '2023-11-25', 'Returned'),
(7, 6, '2023-12-10', '2024-01-10', NULL, 'Checked Out'),
(9, 3, '2023-09-05', '2023-10-05', NULL, 'Lost'),
(1, 8, '2023-10-01', '2023-11-01', '2023-10-28', 'Returned'),
(5, 2, '2024-01-15', '2024-02-15', NULL, 'Checked Out');