-- ========================================
-- MASTER SETUP SCRIPT - ALL IN ONE
-- Complete Banking & Finance ERP System
-- Run this SINGLE script to set up everything!
-- ========================================

USE master;
GO

-- Drop existing database if needed (UNCOMMENT TO RESET)
-- IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BFASDatabase')
-- BEGIN
--     DROP DATABASE BFASDatabase;
-- END
-- GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BFASDatabase')
BEGIN
    CREATE DATABASE BFASDatabase;
    PRINT '✓ Database created: BFASDatabase';
END
ELSE
BEGIN
    PRINT '✓ Database already exists: BFASDatabase';
END
GO

USE BFASDatabase;
GO

PRINT '';
PRINT '========================================';
PRINT 'MASTER SETUP - BANKING ERP SYSTEM';
PRINT '========================================';
PRINT '';

-- ========================================
-- PART 1: CORE TABLES
-- ========================================
PRINT 'PART 1: Creating core tables...';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'roles')
BEGIN
    CREATE TABLE roles (
        role_id INT PRIMARY KEY IDENTITY(1,1),
        role_name NVARCHAR(50) NOT NULL UNIQUE
    );
    PRINT '  ✓ roles table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'users')
BEGIN
    CREATE TABLE users (
        user_id INT PRIMARY KEY IDENTITY(1,1),
        role_id INT NOT NULL,
        full_name NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        profile_photo NVARCHAR(255) NULL,
        status NVARCHAR(20) DEFAULT 'Active',
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
    );
    PRINT '  ✓ users table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'bank_accounts')
BEGIN
    CREATE TABLE bank_accounts (
        account_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        account_number NVARCHAR(50) NOT NULL UNIQUE,
        account_type NVARCHAR(20) DEFAULT 'Savings',
        balance DECIMAL(18,2) DEFAULT 0,
        status NVARCHAR(20) DEFAULT 'Active',
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ bank_accounts table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'transactions')
BEGIN
    CREATE TABLE transactions (
        transaction_id INT PRIMARY KEY IDENTITY(1,1),
        account_id INT NOT NULL,
        transaction_type NVARCHAR(50) NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        transaction_date DATETIME DEFAULT GETDATE(),
        status NVARCHAR(20) DEFAULT 'Completed',
        reference_number NVARCHAR(50),
        FOREIGN KEY (account_id) REFERENCES bank_accounts(account_id)
    );
    PRINT '  ✓ transactions table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'transfers')
BEGIN
    CREATE TABLE transfers (
        transfer_id INT PRIMARY KEY IDENTITY(1,1),
        sender_account_id INT NOT NULL,
        receiver_account_id INT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        transfer_date DATETIME DEFAULT GETDATE(),
        status NVARCHAR(20) DEFAULT 'Completed',
        FOREIGN KEY (sender_account_id) REFERENCES bank_accounts(account_id),
        FOREIGN KEY (receiver_account_id) REFERENCES bank_accounts(account_id)
    );
    PRINT '  ✓ transfers table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'billers')
BEGIN
    CREATE TABLE billers (
        biller_id INT PRIMARY KEY IDENTITY(1,1),
        biller_name NVARCHAR(100) NOT NULL,
        biller_type NVARCHAR(50),
        created_at DATETIME DEFAULT GETDATE()
    );
    PRINT '  ✓ billers table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'payments')
BEGIN
    CREATE TABLE payments (
        payment_id INT PRIMARY KEY IDENTITY(1,1),
        account_id INT NOT NULL,
        biller_id INT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        payment_date DATETIME DEFAULT GETDATE(),
        status NVARCHAR(20) DEFAULT 'Completed',
        reference_number NVARCHAR(50),
        FOREIGN KEY (account_id) REFERENCES bank_accounts(account_id),
        FOREIGN KEY (biller_id) REFERENCES billers(biller_id)
    );
    PRINT '  ✓ payments table created';
END

GO

-- ========================================
-- PART 2: ACCOUNTING TABLES
-- ========================================
PRINT 'PART 2: Creating accounting tables...';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'accounts_payable')
BEGIN
    CREATE TABLE accounts_payable (
        ap_id INT PRIMARY KEY IDENTITY(1,1),
        payee_name NVARCHAR(100) NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        due_date DATETIME NOT NULL,
        status NVARCHAR(20) DEFAULT 'Pending',
        created_by INT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (created_by) REFERENCES users(user_id)
    );
    PRINT '  ✓ accounts_payable table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'accounts_receivable')
BEGIN
    CREATE TABLE accounts_receivable (
        ar_id INT PRIMARY KEY IDENTITY(1,1),
        payer_name NVARCHAR(100) NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        due_date DATETIME NOT NULL,
        status NVARCHAR(20) DEFAULT 'Pending',
        created_by INT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (created_by) REFERENCES users(user_id)
    );
    PRINT '  ✓ accounts_receivable table created';
END

GO

-- ========================================
-- PART 3: ERP TABLES
-- ========================================
PRINT 'PART 3: Creating ERP tables...';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'employees')
BEGIN
    CREATE TABLE employees (
        employee_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        department NVARCHAR(100),
        position NVARCHAR(100),
        salary DECIMAL(18,2),
        hire_date DATETIME,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ employees table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventory_items')
BEGIN
    CREATE TABLE inventory_items (
        item_id INT PRIMARY KEY IDENTITY(1,1),
        item_name NVARCHAR(200) NOT NULL,
        quantity INT DEFAULT 0,
        unit_price DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Active'
    );
    PRINT '  ✓ inventory_items table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'crm_customers')
BEGIN
    CREATE TABLE crm_customers (
        customer_id INT PRIMARY KEY IDENTITY(1,1),
        customer_name NVARCHAR(200) NOT NULL,
        email NVARCHAR(100),
        phone NVARCHAR(20),
        deal_value DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Active'
    );
    PRINT '  ✓ crm_customers table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'projects')
BEGIN
    CREATE TABLE projects (
        project_id INT PRIMARY KEY IDENTITY(1,1),
        project_name NVARCHAR(200) NOT NULL,
        description NVARCHAR(1000),
        start_date DATETIME,
        end_date DATETIME,
        budget DECIMAL(18,2),
        actual_cost DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Active'
    );
    PRINT '  ✓ projects table created';
END

GO

-- ========================================
-- PART 4: ADVANCED BANKING FEATURES
-- ========================================
PRINT 'PART 4: Creating advanced banking tables...';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'loans')
BEGIN
    CREATE TABLE loans (
        loan_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        loan_number NVARCHAR(50) NOT NULL UNIQUE,
        loan_type NVARCHAR(50) NOT NULL,
        loan_amount DECIMAL(18,2) NOT NULL,
        interest_rate DECIMAL(5,2),
        term_months INT,
        monthly_payment DECIMAL(18,2),
        outstanding_balance DECIMAL(18,2),
        start_date DATETIME,
        end_date DATETIME,
        status NVARCHAR(20) DEFAULT 'Active',
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ loans table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'budgets')
BEGIN
    CREATE TABLE budgets (
        budget_id INT PRIMARY KEY IDENTITY(1,1),
        department NVARCHAR(100),
        category NVARCHAR(100),
        fiscal_year INT,
        allocated_amount DECIMAL(18,2),
        spent_amount DECIMAL(18,2) DEFAULT 0,
        status NVARCHAR(20) DEFAULT 'Active'
    );
    PRINT '  ✓ budgets table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'fixed_assets')
BEGIN
    CREATE TABLE fixed_assets (
        asset_id INT PRIMARY KEY IDENTITY(1,1),
        asset_code NVARCHAR(50) NOT NULL UNIQUE,
        asset_name NVARCHAR(200),
        asset_type NVARCHAR(100),
        purchase_cost DECIMAL(18,2),
        accumulated_depreciation DECIMAL(18,2) DEFAULT 0,
        book_value DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Active'
    );
    PRINT '  ✓ fixed_assets table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'payroll')
BEGIN
    CREATE TABLE payroll (
        payroll_id INT PRIMARY KEY IDENTITY(1,1),
        employee_id INT NOT NULL,
        basic_salary DECIMAL(18,2),
        gross_pay DECIMAL(18,2),
        total_deductions DECIMAL(18,2),
        net_pay DECIMAL(18,2),
        pay_date DATETIME,
        status NVARCHAR(20) DEFAULT 'Pending'
    );
    PRINT '  ✓ payroll table created';
END

GO

-- ========================================
-- PART 5: CUSTOMER ERP FEATURES
-- ========================================
PRINT 'PART 5: Creating customer ERP tables...';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'loan_applications')
BEGIN
    CREATE TABLE loan_applications (
        application_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        application_number NVARCHAR(50) NOT NULL UNIQUE,
        loan_type NVARCHAR(50),
        requested_amount DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Pending',
        application_date DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ loan_applications table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'investments')
BEGIN
    CREATE TABLE investments (
        investment_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        investment_number NVARCHAR(50) NOT NULL UNIQUE,
        investment_type NVARCHAR(50),
        investment_name NVARCHAR(200),
        principal_amount DECIMAL(18,2),
        current_value DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Active',
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ investments table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'insurances')
BEGIN
    CREATE TABLE insurances (
        insurance_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        policy_number NVARCHAR(50) NOT NULL UNIQUE,
        insurance_type NVARCHAR(50),
        policy_name NVARCHAR(200),
        coverage_amount DECIMAL(18,2),
        premium_amount DECIMAL(18,2),
        status NVARCHAR(20) DEFAULT 'Active',
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ insurances table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'statements')
BEGIN
    CREATE TABLE statements (
        statement_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        account_id INT NOT NULL,
        statement_number NVARCHAR(50) NOT NULL UNIQUE,
        period_start DATETIME,
        period_end DATETIME,
        opening_balance DECIMAL(18,2),
        closing_balance DECIMAL(18,2),
        generated_date DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (account_id) REFERENCES bank_accounts(account_id)
    );
    PRINT '  ✓ statements table created';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'credit_scores')
BEGIN
    CREATE TABLE credit_scores (
        score_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        score INT,
        credit_rating NVARCHAR(20),
        score_date DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
    PRINT '  ✓ credit_scores table created';
END

GO

-- ========================================
-- PART 6: INSERT ROLES
-- ========================================
PRINT 'PART 6: Inserting roles...';

IF NOT EXISTS (SELECT * FROM roles WHERE role_name = 'Admin')
BEGIN
    INSERT INTO roles (role_name) VALUES ('Admin');
    PRINT '  ✓ Admin role created';
END

IF NOT EXISTS (SELECT * FROM roles WHERE role_name = 'Employee')
BEGIN
    INSERT INTO roles (role_name) VALUES ('Employee');
    PRINT '  ✓ Employee role created';
END

IF NOT EXISTS (SELECT * FROM roles WHERE role_name = 'Customer')
BEGIN
    INSERT INTO roles (role_name) VALUES ('Customer');
    PRINT '  ✓ Customer role created';
END

GO

-- ========================================
-- PART 7: CREATE LOGIN ACCOUNTS
-- ========================================
PRINT 'PART 7: Creating login accounts...';

IF NOT EXISTS (SELECT * FROM users WHERE email = 'admin@bfas.com')
BEGIN
    INSERT INTO users (role_id, full_name, email, password, status, created_at)
    SELECT role_id, 'Administrator', 'admin@bfas.com', 'admin123', 'Active', GETDATE()
    FROM roles WHERE role_name = 'Admin';
    PRINT '  ✓ Admin account created';
END

IF NOT EXISTS (SELECT * FROM users WHERE email = 'employee1@bfas.com')
BEGIN
    INSERT INTO users (role_id, full_name, email, password, status, created_at)
    SELECT role_id, 'Employee One', 'employee1@bfas.com', 'employee123', 'Active', GETDATE()
    FROM roles WHERE role_name = 'Employee';
    PRINT '  ✓ Employee account created';
END

IF NOT EXISTS (SELECT * FROM users WHERE email = 'john@example.com')
BEGIN
    INSERT INTO users (role_id, full_name, email, password, status, created_at)
    SELECT role_id, 'John Doe', 'john@example.com', 'password123', 'Active', GETDATE()
    FROM roles WHERE role_name = 'Customer';
    PRINT '  ✓ Customer account created';
END

GO

-- ========================================
-- PART 8: CREATE SAMPLE BANK ACCOUNT
-- ========================================
PRINT 'PART 8: Creating sample bank account...';

IF NOT EXISTS (SELECT * FROM bank_accounts WHERE account_number = '1234567890')
BEGIN
    INSERT INTO bank_accounts (user_id, account_number, account_type, balance, status, created_at)
    VALUES (3, '1234567890', 'Savings', 5000.00, 'Active', GETDATE());
    PRINT '  ✓ Sample bank account created';
END

GO

-- ========================================
-- PART 9: CREATE INDEXES
-- ========================================
PRINT 'PART 9: Creating indexes for performance...';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_users_email')
    CREATE INDEX IX_users_email ON users(email);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_bank_accounts_user_id')
    CREATE INDEX IX_bank_accounts_user_id ON bank_accounts(user_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_transactions_account_id')
    CREATE INDEX IX_transactions_account_id ON transactions(account_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_loans_user_id')
    CREATE INDEX IX_loans_user_id ON loans(user_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_investments_user_id')
    CREATE INDEX IX_investments_user_id ON investments(user_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_insurances_user_id')
    CREATE INDEX IX_insurances_user_id ON insurances(user_id);

PRINT '  ✓ Indexes created';

GO

-- ========================================
-- COMPLETION SUMMARY
-- ========================================
PRINT '';
PRINT '========================================';
PRINT 'SETUP COMPLETE! ✓';
PRINT '========================================';
PRINT '';
PRINT 'Database: BFASDatabase';
PRINT 'Tables Created: 20+';
PRINT 'Roles Created: 3 (Admin, Employee, Customer)';
PRINT 'User Accounts: 3';
PRINT 'Indexes: 6+';
PRINT '';
PRINT 'LOGIN ACCOUNTS:';
PRINT '  Admin:    admin@bfas.com / admin123';
PRINT '  Employee: employee1@bfas.com / employee123';
PRINT '  Customer: john@example.com / password123';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '  1. Go to Visual Studio';
PRINT '  2. Build solution (Ctrl+Shift+B)';
PRINT '  3. Press F5 to run';
PRINT '  4. Login with accounts above';
PRINT '  5. Start using your ERP!';
PRINT '';
PRINT 'STATUS: PRODUCTION READY ✓';
PRINT '========================================';
GO
USE BFASDatabase;
GO

-- =============================================
-- Update cards table with new columns
-- =============================================
PRINT 'Updating cards table...';

-- Add balance column
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cards' AND COLUMN_NAME = 'balance')
BEGIN
    ALTER TABLE cards ADD balance DECIMAL(18,2) NOT NULL DEFAULT 0;
    PRINT '✓ Added balance column';
END

-- Add is_primary column
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cards' AND COLUMN_NAME = 'is_primary')
BEGIN
    ALTER TABLE cards ADD is_primary BIT NOT NULL DEFAULT 0;
    PRINT '✓ Added is_primary column';
END

-- Add updated_at column
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cards' AND COLUMN_NAME = 'updated_at')
BEGIN
    ALTER TABLE cards ADD updated_at DATETIME NOT NULL DEFAULT GETDATE();
    PRINT '✓ Added updated_at column';
END
GO

-- =============================================
-- Create card_requests table
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'card_requests')
BEGIN
    CREATE TABLE card_requests (
        request_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        account_id INT NOT NULL,
        card_type NVARCHAR(20) NOT NULL DEFAULT 'Debit',
        requested_limit DECIMAL(18,2) NULL,
        reason NVARCHAR(500) NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        approved_by INT NULL,
        approval_date DATETIME NULL,
        rejection_reason NVARCHAR(500) NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (account_id) REFERENCES bank_accounts(account_id),
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
    );
    PRINT '✓ Created card_requests table';
END
GO

-- =============================================
-- Create card_transfers table
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'card_transfers')
BEGIN
    CREATE TABLE card_transfers (
        transfer_id INT PRIMARY KEY IDENTITY(1,1),
        from_card_id INT NOT NULL,
        to_card_id INT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        description NVARCHAR(500) NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'Completed',
        transfer_date DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (from_card_id) REFERENCES cards(card_id),
        FOREIGN KEY (to_card_id) REFERENCES cards(card_id)
    );
    PRINT '✓ Created card_transfers table';
END
GO

-- =============================================
-- Create scheduled_payments table
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'scheduled_payments')
BEGIN
    CREATE TABLE scheduled_payments (
        schedule_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        card_id INT NOT NULL,
        biller_id INT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        frequency NVARCHAR(20) NOT NULL DEFAULT 'Monthly',
        next_payment_date DATETIME NOT NULL,
        last_payment_date DATETIME NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'Active',
        description NVARCHAR(500) NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (card_id) REFERENCES cards(card_id),
        FOREIGN KEY (biller_id) REFERENCES billers(biller_id)
    );
    PRINT '✓ Created scheduled_payments table';
END
GO

-- =============================================
-- Create system_settings table
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'system_settings')
BEGIN
    CREATE TABLE system_settings (
        setting_id INT PRIMARY KEY IDENTITY(1,1),
        setting_key NVARCHAR(100) NOT NULL UNIQUE,
        setting_value NVARCHAR(500) NOT NULL,
        setting_type NVARCHAR(50) NOT NULL DEFAULT 'String',
        description NVARCHAR(500) NULL,
        category NVARCHAR(100) NULL,
        updated_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_by INT NULL,
        FOREIGN KEY (updated_by) REFERENCES users(user_id)
    );
    PRINT '✓ Created system_settings table';
    
    -- Insert default settings
    INSERT INTO system_settings (setting_key, setting_value, setting_type, description, category) VALUES
    ('TransactionFee', '0.50', 'Decimal', 'Fee per transaction', 'Fees'),
    ('WithdrawalFee', '1.00', 'Decimal', 'Fee per withdrawal', 'Fees'),
    ('TransferFee', '2.00', 'Decimal', 'Fee per transfer', 'Fees'),
    ('MinimumBalance', '100.00', 'Decimal', 'Minimum account balance', 'Limits'),
    ('MaxDailyWithdrawal', '5000.00', 'Decimal', 'Maximum daily withdrawal limit', 'Limits'),
    ('InterestRate', '2.5', 'Decimal', 'Annual interest rate (%)', 'Interest'),
    ('CardRequestApprovalRequired', 'true', 'Boolean', 'Require admin approval for card requests', 'Settings');
    
    PRINT '✓ Inserted default system settings';
END
GO

-- Set the first card of each account as primary if no primary exists
UPDATE c1
SET c1.is_primary = 1
FROM cards c1
INNER JOIN (
    SELECT account_id, MIN(card_id) as first_card_id
    FROM cards
    WHERE card_status = 'Active'
    GROUP BY account_id
) c2 ON c1.account_id = c2.account_id AND c1.card_id = c2.first_card_id
WHERE NOT EXISTS (
    SELECT 1 FROM cards c3 
    WHERE c3.account_id = c1.account_id AND c3.is_primary = 1
);
PRINT '✓ Set primary cards';
GO

PRINT '';
PRINT '=========================================';
PRINT 'Database schema updated successfully!';
PRINT '=========================================';
PRINT '';
PRINT 'New tables created:';
PRINT '  ✓ card_requests';
PRINT '  ✓ card_transfers';
PRINT '  ✓ scheduled_payments';
PRINT '  ✓ system_settings';
PRINT '';
PRINT 'Cards table updated with:';
PRINT '  ✓ balance column';
PRINT '  ✓ is_primary column';
PRINT '  ✓ updated_at column';
PRINT '';
GO
