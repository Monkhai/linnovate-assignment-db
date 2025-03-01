-- Script to remove any test products

-- Display test products before deletion
SELECT id, name, price FROM products WHERE name = 'Test Product';

-- Delete all test products
DELETE FROM products WHERE name = 'Test Product';

-- Reset the sequence to the max ID
SELECT setval('products_id_seq', (SELECT COALESCE(MAX(id), 0) FROM products), true);

-- Verify deletion
SELECT COUNT(*) AS remaining_test_products FROM products WHERE name = 'Test Product';

-- Optional: Display all remaining products
-- SELECT id, name FROM products ORDER BY id; 