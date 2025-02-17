
CREATE PROCEDURE dbo.P_CREATE_TABLE
    @dbName NVARCHAR(128)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @errorMessage NVARCHAR(4000); -- Variable to store error message

    -- Start the transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Build dynamic SQL
        SET @sql = 'USE ' + QUOTENAME(@dbName) + ';
        
        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''OrderDetails'')
            DROP TABLE OrderDetails;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Orders'')
            DROP TABLE Orders;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Products'')
            DROP TABLE Products;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Categories'')
            DROP TABLE Categories;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Customers'')
            DROP TABLE Customers;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Employees'')
            DROP TABLE Employees;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Shippers'')
            DROP TABLE Shippers;

        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''Suppliers'')
            DROP TABLE Suppliers;

        -- Create the new tables
        CREATE TABLE Categories (
            CategoryID INTEGER PRIMARY KEY IDENTITY(1,1),
            CategoryName VARCHAR(25),
            Description VARCHAR(255)
        );

        CREATE TABLE Customers (
            CustomerID INTEGER PRIMARY KEY IDENTITY(1,1),
            CustomerName VARCHAR(50),
            ContactName VARCHAR(50),
            Address VARCHAR(50),
            City VARCHAR(20),
            PostalCode VARCHAR(10),
            Country VARCHAR(15)
        );

        CREATE TABLE Employees (
            EmployeeID INTEGER PRIMARY KEY IDENTITY(1,1),
            LastName VARCHAR(15),
            FirstName VARCHAR(15),
            BirthDate DATETIME,
            Photo VARCHAR(25),
            Notes VARCHAR(1024)
        );

        CREATE TABLE Shippers (
            ShipperID INTEGER PRIMARY KEY IDENTITY(1,1),
            ShipperName VARCHAR(25),
            Phone VARCHAR(15)
        );

        CREATE TABLE Suppliers (
            SupplierID INTEGER PRIMARY KEY IDENTITY(1,1),
            SupplierName VARCHAR(50),
            ContactName VARCHAR(50),
            Address VARCHAR(50),
            City VARCHAR(20),
            PostalCode VARCHAR(10),
            Country VARCHAR(15),
            Phone VARCHAR(15)
        );

        CREATE TABLE Products (
            ProductID INTEGER PRIMARY KEY IDENTITY(1,1),
            ProductName VARCHAR(50),
            SupplierID INTEGER,
            CategoryID INTEGER,
            Unit VARCHAR(25),
            Price NUMERIC,
            FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
            FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
        );

        CREATE TABLE Orders (
            OrderID INTEGER PRIMARY KEY IDENTITY(10248,1),
            CustomerID INTEGER,
            EmployeeID INTEGER,
            OrderDate DATETIME,
            ShipperID INTEGER,
            FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
            FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
            FOREIGN KEY (ShipperID) REFERENCES Shippers(ShipperID)
        );

        CREATE TABLE OrderDetails (
            OrderDetailID INTEGER PRIMARY KEY IDENTITY(1,1),
            OrderID INTEGER,
            ProductID INTEGER,
            Quantity INTEGER,
            FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
            FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        );
        ';

        -- Execute the dynamic SQL
        EXEC sp_executesql @sql;

        -- Commit the transaction after successful execution
        COMMIT TRANSACTION;
        PRINT 'Transaction Committed Successfully';
    END TRY
    BEGIN CATCH
        -- Capture the error message
        SET @errorMessage = ERROR_MESSAGE();

        -- Rollback the transaction
        ROLLBACK TRANSACTION;

        -- Optionally, print the error message for debugging
        PRINT 'Error: ' + @errorMessage;

        -- Raise the error again to ensure it is propagated
        THROW;
    END CATCH;
END;
