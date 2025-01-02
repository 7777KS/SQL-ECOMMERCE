CREATE DATABASE e__commerce__;
USE e__commerce__;

-- Table: Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Address TEXT
);
INSERT INTO Customers (CustomerID, Name, Email, Address)
VALUES
(1, 'Rahul', 'Rahulkumar121@gmail.com', 'A-144,Ashoknagar'),
(2, 'Sandeep', 'sandeep23@gmail.com', 'B-34,VasantKunj'),
(3, 'Anil Gupta', 'anil.gupta11@gmail.com', '67 Civil Lines'),
(4, 'Krishna Saini', 'sainikrishna1000@gmail.com', 'A-122 Indrapuri');

-- Table: Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2),
    Stock INT
);
INSERT INTO Products (ProductID, ProductName, Price, Stock)
VALUES 
(101, 'iPhone 13 Pro Max', 60000, 5),
(102, 'AirPods Pro', 20000, 4),
(103, 'MacBook Pro 16', 120000, 2),
(104, 'iPad Air', 45000, 3);

-- Table: Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES 
(1, 1, '2024-12-20 10:15:00', 120000),
(2, 2, '2024-12-21 14:45:00', 160000),
(3, 3, '2024-12-22 09:30:00', 120000),
(4, 4, '2024-12-23 16:20:00', 45000);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price)
VALUES
(1, 101, 2, 60000),
(2, 102, 8, 20000),
(3, 103, 1, 120000),
(4, 104, 1, 45000);

DELIMITER $$

CREATE PROCEDURE PlaceOrder (
    IN orderID INT,          -- Existing Order ID
    IN productID INT,        -- Product being ordered
    IN quantity INT          -- Quantity of the product
)
BEGIN
    DECLARE productPrice DECIMAL(10, 2);
    DECLARE stock INT;

    -- Step 1: Check stock availability
    SELECT Price, Stock INTO productPrice, stock
    FROM Products
    WHERE ProductID = productID
    LIMIT 1;

    IF stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found.';
    ELSEIF stock < quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for the product.';
    ELSE
        -- Step 2: Add details to the OrderDetails table
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price)
        VALUES (orderID, productID, quantity, productPrice);

        -- Step 3: Update the product stock
        UPDATE Products
        SET Stock = Stock - quantity
        WHERE ProductID = productID;
    END IF;
END $$

DELIMITER ;

SELECT * FROM Products;
CALL PlaceOrder(1, 101, 1);
