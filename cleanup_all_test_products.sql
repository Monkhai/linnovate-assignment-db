-- COMPREHENSIVE TEST PRODUCT CLEANUP
-- This script is designed to be run after tests to ensure all test products are removed

-- Disable triggers temporarily to bypass any constraints
SET session_replication_role = 'replica';

-- First show all test products before cleanup
SELECT id, name, price, created_at FROM products WHERE name = 'Test Product';

-- Delete any reviews that might be associated with test products
DELETE FROM reviews WHERE product_id IN (SELECT id FROM products WHERE name = 'Test Product');

-- Now forcefully remove the test products
DELETE FROM products WHERE name = 'Test Product';

-- Re-enable triggers
SET session_replication_role = 'origin';

-- Verify no test products remain
DO $$
DECLARE
    test_count INTEGER;
    test_ids TEXT := '';
BEGIN
    SELECT COUNT(*) INTO test_count FROM products WHERE name = 'Test Product';
    
    IF test_count > 0 THEN
        -- If test products still exist, show details and raise exception
        FOR test_product IN (SELECT id, name FROM products WHERE name = 'Test Product') LOOP
            test_ids := test_ids || test_product.id || ', ';
        END LOOP;
        
        RAISE EXCEPTION 'CRITICAL ERROR: % test products still exist after cleanup! IDs: %', 
                        test_count, 
                        SUBSTRING(test_ids FROM 1 FOR LENGTH(test_ids) - 2);
    ELSE
        RAISE NOTICE 'Success: All test products have been removed.';
    END IF;
END $$; 