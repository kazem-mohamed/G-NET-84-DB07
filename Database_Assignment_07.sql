USE Hospital;
GO

-- ============================================================
-- Database Assignment 07 - Questions 1 to 27
-- Database: Hospital (restore Hospital (1).bak before running)
-- ============================================================

-- ============================================================
-- Q1. Display All Patients
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetAllPatients
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, DOB, WardId
    FROM dbo.Patients;
END;
GO

-- ============================================================
-- Q2. Display All Consultants
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetAllConsultants
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, Salary
    FROM dbo.Consultants;
END;
GO

-- ============================================================
-- Q3. Display Patients with Their Wards
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetPatientsWithWards
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.Id AS PatientId,
           p.Name AS PatientName,
           p.DOB,
           p.WardId,
           w.Name AS WardName
    FROM dbo.Patients AS p
    LEFT JOIN dbo.Wards AS w ON w.Id = p.WardId;
END;
GO

-- ============================================================
-- Q4. Get Patient by ID
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetPatientById
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, DOB, WardId
    FROM dbo.Patients
    WHERE Id = @PatientId;
END;
GO

-- The restored database contains a function with this name from Assignment 06.
-- Remove only that function so the required stored procedure can use the name.
IF OBJECT_ID(N'dbo.GetConsultantsByMinimumSalary', N'IF') IS NOT NULL
    DROP FUNCTION dbo.GetConsultantsByMinimumSalary;
GO

-- ============================================================
-- Q5. Get Consultants by Minimum Salary
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetConsultantsByMinimumSalary
    @MinimumSalary DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, Salary
    FROM dbo.Consultants
    WHERE Salary >= @MinimumSalary;
END;
GO

-- The restored database contains a function with this name from Assignment 06.
IF OBJECT_ID(N'dbo.GetPatientsByWard', N'IF') IS NOT NULL
    DROP FUNCTION dbo.GetPatientsByWard;
GO

-- ============================================================
-- Q6. Get Patients by Ward
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetPatientsByWard
    @WardId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, DOB, WardId
    FROM dbo.Patients
    WHERE WardId = @WardId;
END;
GO

-- ============================================================
-- Q7. Return Patient Count through an OUTPUT Parameter
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetPatientCount
    @PatientCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @PatientCount = COUNT(*)
    FROM dbo.Patients;
END;
GO

-- ============================================================
-- Q8. Return Average Consultant Salary through an OUTPUT Parameter
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetAverageConsultantSalary
    @AverageSalary DECIMAL(18, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @AverageSalary = CAST(AVG(Salary) AS DECIMAL(18, 2))
    FROM dbo.Consultants;
END;
GO

-- ============================================================
-- Q9. Return Patient Medication Quantity through an OUTPUT Parameter
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.GetPatientMedicationQuantity
    @PatientId INT,
    @TotalQuantity INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalQuantity = COALESCE(SUM(Quantity), 0)
    FROM dbo.DrugAdministrations
    WHERE PatientId = @PatientId;
END;
GO

-- ============================================================
-- Q10. Increase a Salary using an Input-Output Parameter
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.IncreaseSalary
    @Salary DECIMAL(18, 2) OUTPUT,
    @Percentage DECIMAL(9, 2)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Salary = @Salary + (@Salary * @Percentage / 100.0);
END;
GO

-- ============================================================
-- Q11. Increase Medication Quantity using an Input-Output Parameter
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.IncreaseMedicationQuantity
    @Quantity INT OUTPUT,
    @AdditionalQuantity INT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Quantity = @Quantity + @AdditionalQuantity;
END;
GO

-- ============================================================
-- Q12. Convert Monthly Salary to Annual Salary
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.ConvertMonthlySalaryToAnnualSalary
    @MonthlySalary DECIMAL(18, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @MonthlySalary = @MonthlySalary * 12;
END;
GO

-- ============================================================
-- Q13. Insert Patient with TRY-CATCH Error Handling
-- @PatientId is required only when Patients.Id is not an IDENTITY column.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.InsertPatientWithErrorHandling
    @PatientId INT = NULL,
    @Name NVARCHAR(100),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF COLUMNPROPERTY(OBJECT_ID(N'dbo.Patients'), N'Id', N'IsIdentity') = 1
            INSERT INTO dbo.Patients (Name, DOB, WardId)
            VALUES (@Name, @DOB, @WardId);
        ELSE
        BEGIN
            IF @PatientId IS NULL
                THROW 50001, 'PatientId is required when Patients.Id is not an IDENTITY column.', 1;

            INSERT INTO dbo.Patients (Id, Name, DOB, WardId)
            VALUES (@PatientId, @Name, @DOB, @WardId);
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(2048) = ERROR_MESSAGE();
        THROW 50002, @ErrorMessage, 1;
    END CATCH;
END;
GO

-- ============================================================
-- Q14. Update Consultant Salary with TRY-CATCH Error Handling
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.UpdateConsultantSalaryWithErrorHandling
    @ConsultantId INT,
    @NewSalary DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Consultants
        SET Salary = @NewSalary
        WHERE Id = @ConsultantId;

        IF @@ROWCOUNT = 0
            THROW 50003, 'Consultant not found.', 1;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(2048) = ERROR_MESSAGE();
        THROW 50004, @ErrorMessage, 1;
    END CATCH;
END;
GO

-- ============================================================
-- Q15. Delete Patient with TRY-CATCH Error Handling
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.DeletePatientWithErrorHandling
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DELETE FROM dbo.Patients
        WHERE Id = @PatientId;

        IF @@ROWCOUNT = 0
            THROW 50005, 'Patient not found.', 1;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(2048) = ERROR_MESSAGE();
        THROW 50006, @ErrorMessage, 1;
    END CATCH;
END;
GO

-- ============================================================
-- Q16. Add a New Patient
-- @PatientId is required only when Patients.Id is not an IDENTITY column.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.AddPatient
    @PatientId INT = NULL,
    @Name NVARCHAR(100),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF COLUMNPROPERTY(OBJECT_ID(N'dbo.Patients'), N'Id', N'IsIdentity') = 1
        INSERT INTO dbo.Patients (Name, DOB, WardId)
        VALUES (@Name, @DOB, @WardId);
    ELSE
    BEGIN
        IF @PatientId IS NULL
            THROW 50007, 'PatientId is required when Patients.Id is not an IDENTITY column.', 1;

        INSERT INTO dbo.Patients (Id, Name, DOB, WardId)
        VALUES (@PatientId, @Name, @DOB, @WardId);
    END;
END;
GO

-- ============================================================
-- Q17. Add a New Consultant
-- @ConsultantId is required only when Consultants.Id is not an IDENTITY column.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.AddConsultant
    @ConsultantId INT = NULL,
    @Name NVARCHAR(100),
    @Salary DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON;

    IF COLUMNPROPERTY(OBJECT_ID(N'dbo.Consultants'), N'Id', N'IsIdentity') = 1
        INSERT INTO dbo.Consultants (Name, Salary)
        VALUES (@Name, @Salary);
    ELSE
    BEGIN
        IF @ConsultantId IS NULL
            THROW 50008, 'ConsultantId is required when Consultants.Id is not an IDENTITY column.', 1;

        INSERT INTO dbo.Consultants (Id, Name, Salary)
        VALUES (@ConsultantId, @Name, @Salary);
    END;
END;
GO

-- ============================================================
-- Q18. Record a Medication Administration
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.AddDrugAdministration
    @NurseId INT,
    @DrugCode INT,
    @PatientId INT,
    @Dosage NVARCHAR(100),
    @AdministrationDate DATE,
    @AdministrationTime TIME(0),
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.DrugAdministrations
    (
        NurseId,
        DrugCode,
        PatientId,
        Dosage,
        [DATE],
        [Time],
        Quantity
    )
    VALUES
    (
        @NurseId,
        @DrugCode,
        @PatientId,
        @Dosage,
        @AdministrationDate,
        @AdministrationTime,
        @Quantity
    );
END;
GO

-- ============================================================
-- Q19. Update Patient Information
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.UpdatePatientInformation
    @PatientId INT,
    @Name NVARCHAR(100),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Patients
    SET Name = @Name,
        DOB = @DOB,
        WardId = @WardId
    WHERE Id = @PatientId;
END;
GO

-- ============================================================
-- Q20. Update Consultant Salary
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.UpdateConsultantSalary
    @ConsultantId INT,
    @NewSalary DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Consultants
    SET Salary = @NewSalary
    WHERE Id = @ConsultantId;
END;
GO

-- ============================================================
-- Q21. Increase Nurse Salary by a Percentage
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.IncreaseNurseSalary
    @NurseNumber INT,
    @Percentage DECIMAL(9, 2)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Nurses
    SET Salary = Salary + (Salary * @Percentage / 100.0)
    WHERE Number = @NurseNumber;
END;
GO

-- ============================================================
-- Q22. Delete a Patient
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.DeletePatient
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Patients
    WHERE Id = @PatientId;
END;
GO

-- ============================================================
-- Q23. Delete a Consultant
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.DeleteConsultant
    @ConsultantId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Consultants
    WHERE Id = @ConsultantId;
END;
GO

-- ============================================================
-- Q24. Delete a Medication Administration using its identifying columns
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.DeleteDrugAdministration
    @NurseId INT,
    @DrugCode INT,
    @PatientId INT,
    @AdministrationDate DATE,
    @AdministrationTime TIME(0)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.DrugAdministrations
    WHERE NurseId = @NurseId
      AND DrugCode = @DrugCode
      AND PatientId = @PatientId
      AND [DATE] = @AdministrationDate
      AND [Time] = @AdministrationTime;
END;
GO

-- ============================================================
-- Q25. Store All Patients Returned by GetAllPatients
-- ============================================================
DROP TABLE IF EXISTS dbo.AllPatientsFromProcedure;

CREATE TABLE dbo.AllPatientsFromProcedure
(
    Id INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    WardId INT NULL
);

INSERT INTO dbo.AllPatientsFromProcedure (Id, Name, DOB, WardId)
EXEC dbo.GetAllPatients;

SELECT Id, Name, DOB, WardId
FROM dbo.AllPatientsFromProcedure;
GO

-- ============================================================
-- Q26. Store High-Salary Consultants (Salary >= 50000)
-- ============================================================
DROP TABLE IF EXISTS dbo.HighSalaryConsultants;

CREATE TABLE dbo.HighSalaryConsultants
(
    Id INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Salary DECIMAL(18, 2) NOT NULL
);

INSERT INTO dbo.HighSalaryConsultants (Id, Name, Salary)
EXEC dbo.GetConsultantsByMinimumSalary @MinimumSalary = 50000;

SELECT Id, Name, Salary
FROM dbo.HighSalaryConsultants;
GO

-- ============================================================
-- Q27. Store Patients Returned by GetPatientsByWard
-- ============================================================
DROP TABLE IF EXISTS dbo.WardPatientsFromProcedure;

CREATE TABLE dbo.WardPatientsFromProcedure
(
    Id INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    WardId INT NOT NULL
);

DECLARE @WardIdForStorage INT = 1;

INSERT INTO dbo.WardPatientsFromProcedure (Id, Name, DOB, WardId)
EXEC dbo.GetPatientsByWard @WardId = @WardIdForStorage;

SELECT Id, Name, DOB, WardId
FROM dbo.WardPatientsFromProcedure;
GO

-- Safe examples for Q1-Q12 (no table data is changed):
-- EXEC dbo.GetAllPatients;
-- EXEC dbo.GetAllConsultants;
-- EXEC dbo.GetPatientsWithWards;
-- EXEC dbo.GetPatientById @PatientId = 201;
-- EXEC dbo.GetConsultantsByMinimumSalary @MinimumSalary = 50000;
-- EXEC dbo.GetPatientsByWard @WardId = 1;
-- DECLARE @PatientCount INT;
-- EXEC dbo.GetPatientCount @PatientCount = @PatientCount OUTPUT;
-- SELECT @PatientCount AS PatientCount;
-- DECLARE @AverageSalary DECIMAL(18, 2);
-- EXEC dbo.GetAverageConsultantSalary @AverageSalary = @AverageSalary OUTPUT;
-- SELECT @AverageSalary AS AverageConsultantSalary;
-- DECLARE @TotalQuantity INT;
-- EXEC dbo.GetPatientMedicationQuantity @PatientId = 201, @TotalQuantity = @TotalQuantity OUTPUT;
-- SELECT @TotalQuantity AS TotalMedicationQuantity;
-- DECLARE @Salary DECIMAL(18, 2) = 10000;
-- EXEC dbo.IncreaseSalary @Salary = @Salary OUTPUT, @Percentage = 10;
-- SELECT @Salary AS IncreasedSalary;
GO
