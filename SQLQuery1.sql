-- Add payment_mode and qr_code columns to transactions table
USE BFASDatabase;
GO

-- Check if columns exist before adding
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'transactions') AND name = 'payment_mode')
BEGIN
    ALTER TABLE transactions ADD payment_mode NVARCHAR(50) NULL;
    PRINT '✅ Added payment_mode column to transactions';
END
ELSE
BEGIN
    PRINT 'ℹ️ payment_mode column already exists';
END
GO

-- Update all existing NULL values to 'Cash'
UPDATE transactions SET payment_mode = 'Cash' WHERE payment_mode IS NULL;
PRINT '✅ Updated existing transactions with default payment mode';
GO

-- Now make the column NOT NULL with default
ALTER TABLE transactions ALTER COLUMN payment_mode NVARCHAR(50) NOT NULL;
ALTER TABLE transactions ADD CONSTRAINT DF_transactions_payment_mode DEFAULT 'Cash' FOR payment_mode;
PRINT '✅ Set payment_mode as NOT NULL with default value';
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'transactions') AND name = 'qr_code')
BEGIN
    ALTER TABLE transactions ADD qr_code NVARCHAR(255) NULL;
    PRINT '✅ Added qr_code column to transactions';
END
ELSE
BEGIN
    PRINT 'ℹ️ qr_code column already exists';
END
GO

PRINT '';
PRINT '========================================';
PRINT '✅ DATABASE UPDATE COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT '📝 Changes Made:';
PRINT '   - Added payment_mode column (Cash, Card, QR Code)';
PRINT '   - Added qr_code column for QR payment tracking';
PRINT '';
PRINT '🚀 Next Steps:';
PRINT '   1. Restart your application';
PRINT '   2. Test transactions with payment modes';
PRINT '========================================';
GO
