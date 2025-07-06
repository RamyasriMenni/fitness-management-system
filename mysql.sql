-- Use the FIT database
CREATE DATABASE FIT;

USE FIT;
show tables;

-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    age INT,
    gender ENUM('Male', 'Female', 'Other'),
    height_cm FLOAT,
    weight_kg FLOAT,
    role ENUM('User', 'Admin') DEFAULT 'User',
    phone_number VARCHAR(15),
    address TEXT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    profile_picture VARCHAR(255)
);
select *from  users;

-- Workouts Table
CREATE TABLE Workouts (
    workout_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    workout_date DATE,
    workout_type VARCHAR(100),
    duration_minutes INT,
    calories_burned FLOAT,
    intensity ENUM('Low', 'Medium', 'High'),
    heart_rate_avg INT,
    workout_notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Progress Tracking Table
CREATE TABLE Progress (
    progress_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    log_date DATE,
    weight_kg FLOAT,
    bmi FLOAT,
    body_fat_percentage FLOAT,
    muscle_mass FLOAT,
    hydration_level FLOAT,
    heart_rate INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);



-- Admin Management Table
CREATE TABLE AdminLogs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT,
    action VARCHAR(255),
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    affected_user_id INT,
    FOREIGN KEY (admin_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (affected_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);
-- Indexes for Optimization
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_workouts_user ON Workouts(user_id);
CREATE INDEX idx_progress_user ON Progress(user_id);
CREATE INDEX idx_adminlogs_admin ON AdminLogs(admin_id);

-- Queries for Workout Tracking and Admin Management

-- Ensure admin user exists
INSERT INTO Users (name, email, password_hash, role) 
VALUES ('Admin User', 'admin@example.com', 'securehash', 'Admin')
ON DUPLICATE KEY UPDATE user_id=user_id;

-- Ensure affected user exists
INSERT INTO Users (name, email, password_hash, role) 
VALUES ('Test User', 'test@example.com', 'hashedpassword', 'User')
ON DUPLICATE KEY UPDATE user_id=user_id;

-- Insert a new workout log
INSERT INTO Workouts (user_id, workout_date, workout_type, duration_minutes, calories_burned, intensity, heart_rate_avg, workout_notes)
VALUES (1, '2025-02-13', 'Cardio', 45, 400, 'High', 150, 'Morning treadmill session');

-- Retrieve a user's workout history
SELECT * FROM Workouts WHERE user_id = 1 ORDER BY workout_date DESC;

-- Track user progress over time
SELECT log_date, weight_kg, bmi, body_fat_percentage, muscle_mass, hydration_level, heart_rate 
FROM Progress WHERE user_id = 1 ORDER BY log_date DESC;

-- Admin retrieves all users
SELECT * FROM Users;

-- Admin deletes a user
DELETE FROM Users WHERE user_id = 2;

-- Log an admin action
INSERT INTO AdminLogs (admin_id, action, ip_address, affected_user_id) 
SELECT 1, 'Deleted user account', '192.168.1.100', 2 
WHERE EXISTS (SELECT 1 FROM Users WHERE user_id = 1) 
AND EXISTS (SELECT 1 FROM Users WHERE user_id = 2);

CREATE TRIGGER update_last_login
BEFORE UPDATE ON Users
FOR EACH ROW
SET NEW.last_login = CURRENT_TIMESTAMP;

-- Trigger to log user deletions in AdminLogs
CREATE TRIGGER log_user_deletion
AFTER DELETE ON Users
FOR EACH ROW
INSERT INTO AdminLogs (admin_id, action, ip_address, affected_user_id)
VALUES (NULL, 'User Deleted', 'System', OLD.user_id);

select *from Users;
SELECT * FROM AdminLogs;
SELECT * FROM Workouts;

DESC Users;
DESC Workouts;
DESC Progress;
DESC AdminLogs;


SELECT user, host FROM mysql.user;
CREATE USER 'root2'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON *.* TO 'root2'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

SHOW DATABASES;

ALTER TABLE AdminLogs DROP FOREIGN KEY adminlogs_ibfk_2;

ALTER TABLE AdminLogs ADD CONSTRAINT adminlogs_ibfk_2
FOREIGN KEY (affected_user_id) REFERENCES Users(user_id) ON DELETE SET NULL;

SELECT * FROM Progress WHERE user_id = YOUR_USER_ID;
INSERT INTO Progress (user_id, log_date, weight_kg, bmi, body_fat_percentage, muscle_mass, hydration_level, heart_rate)
VALUES (1, NOW(), 70.5, 24.5, 18.2, 40.0, 60.0, 75);
DESC Progress;
ALTER TABLE Progress MODIFY COLUMN log_date DATETIME;


SELECT * FROM Users WHERE role = 'admin';
SELECT user_id, name, email, password_hash FROM Users WHERE email = 'admin@example.com';
UPDATE Users 
SET password_hash = '$2b$12$Pw.jkXW0SI59Q0ylzsMLn.vsjCM0FgooDkc47ABeOGcMfu9hHO4zm' 
WHERE email = 'admin@example.com';







