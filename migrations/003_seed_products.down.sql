-- Remove seeded products
DELETE FROM products WHERE id BETWEEN 1 AND 16;

-- Reset the sequence
ALTER SEQUENCE products_id_seq RESTART WITH 1; 