-- Start transaction
BEGIN TRANSACTION;

-- Create CS_Modules table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS CS_Modules (
    ModuleID INT PRIMARY KEY,
    ModuleName VARCHAR(100) NOT NULL,
    Credits INT NOT NULL
);

-- Create Grades table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS Grades (
    StudentID INT,
    ModuleID INT,
    Grade VARCHAR(2),
    PRIMARY KEY (StudentID, ModuleID),
    FOREIGN KEY (ModuleID) REFERENCES CS_Modules(ModuleID)
);

-- Insert sample modules (skip duplicates)
INSERT INTO CS_Modules (ModuleID, ModuleName, Credits)
VALUES
    (1, 'Introduction to Programming', 15),
    (2, 'Data Structures', 15),
    (3, 'Algorithms', 15)
ON CONFLICT (ModuleID) DO NOTHING;

-- Insert sample grades (skip duplicates)
INSERT INTO Grades (StudentID, ModuleID, Grade)
VALUES
    (1001, 1, 'A'),
    (1001, 2, 'B+'),
    (1002, 1, 'B'),
    (1002, 3, 'A-')
ON CONFLICT (StudentID, ModuleID) DO NOTHING;

-- Finalize transaction
COMMIT;
