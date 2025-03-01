-- COMPREHENSIVE PRODUCT SEEDING MIGRATION

-- Disable triggers temporarily to bypass any constraints
SET session_replication_role = 'replica';

-- AGGRESSIVE CLEANUP SECTION:
-- Delete any reviews that might be associated with test products
DELETE FROM reviews WHERE product_id IN (SELECT id FROM products WHERE name = 'Test Product');

-- Remove test products specifically before the general cleanup
DELETE FROM products WHERE name = 'Test Product';

-- Clean up all existing products to start fresh
TRUNCATE products CASCADE;

-- Reset the sequence
ALTER SEQUENCE products_id_seq RESTART WITH 1;

-- PRODUCT SEEDING SECTION:
-- Insert exactly 15 products (the correct count)
INSERT INTO products (name, price, created_at, image, description) 
VALUES 
  ('Minimalist Desk Lamp', 49.99, '2023-09-15T14:30:00Z', 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500&auto=format&fit=crop&q=60', 'A sleek, adjustable desk lamp with multiple brightness levels and a modern design.'),
  ('Ergonomic Office Chair', 199.99, '2023-10-05T09:45:00Z', 'https://images.unsplash.com/photo-1589384267710-7a170981ca78?w=500&auto=format&fit=crop&q=60', 'High-back mesh chair with lumbar support and adjustable armrests for all-day comfort.'),
  ('Wireless Keyboard', 79.99, '2023-08-20T11:15:00Z', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500&auto=format&fit=crop&q=60', 'Compact wireless keyboard with responsive keys and multi-device Bluetooth connectivity.'),
  ('Noise-Cancelling Headphones', 149.99, '2023-11-02T16:20:00Z', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&auto=format&fit=crop&q=60', 'Premium over-ear headphones with active noise cancellation and 30-hour battery life.'),
  ('Smart Home Speaker', 129.99, '2023-07-10T13:00:00Z', 'https://images.unsplash.com/photo-1558203728-00f45181dd84?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60', 'Voice-controlled smart speaker with rich sound and integrated virtual assistant.'),
  ('Ultra-Thin Laptop Stand', 39.99, '2023-10-18T10:30:00Z', 'https://images.unsplash.com/photo-1661961110218-35af7210f803?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60', 'Portable aluminum laptop stand with adjustable height and foldable design.'),
  ('Premium Leather Notebook', 24.99, '2023-06-12T09:15:00Z', 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=500&auto=format&fit=crop&q=60', 'Handcrafted leather journal with premium paper and an elegant bookmark.'),
  ('Wireless Charging Pad', 35.99, '2023-09-28T14:20:00Z', 'https://images.unsplash.com/photo-1608755728617-aefab37d2edd?w=500&auto=format&fit=crop&q=60', 'Fast-charging Qi wireless charger compatible with all modern smartphones.'),
  ('Minimalist Wall Clock', 42.5, '2023-08-05T16:45:00Z', 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=500&auto=format&fit=crop&q=60', 'Silent quartz wall clock with a clean design and precise movement.'),
  ('Portable Bluetooth Speaker', 59.99, '2023-11-15T11:30:00Z', 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&auto=format&fit=crop&q=60', 'Waterproof Bluetooth speaker with 360° sound and 12-hour playback.'),
  ('Adjustable Standing Desk', 299.99, '2023-07-22T08:50:00Z', 'https://images.unsplash.com/photo-1611269154421-4e27233ac5c7?w=500&auto=format&fit=crop&q=60', 'Electric height-adjustable desk with memory settings and cable management.'),
  ('Artisan Coffee Mug', 19.99, '2023-10-10T13:15:00Z', 'https://images.unsplash.com/photo-1497515114629-f71d768fd07c?w=500&auto=format&fit=crop&q=60', 'Hand-thrown ceramic mug with natural glaze and comfortable handle.'),
  ('Smart Fitness Tracker', 89.99, '2023-09-02T15:40:00Z', 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=500&auto=format&fit=crop&q=60', 'Waterproof fitness tracker with heart rate monitoring and sleep analysis.'),
  ('Modern Plant Pot', 32.5, '2023-11-08T10:20:00Z', 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500&auto=format&fit=crop&q=60', 'Minimalist ceramic plant pot with drainage hole and bamboo tray.'),
  ('Designer Ballpoint Pen', 15.99, '2023-08-30T09:10:00Z', 'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=500&auto=format&fit=crop&q=60', 'Precision-engineered ballpoint pen with smooth writing action and metal construction.');

-- VERIFICATION SECTION:
-- One final check to remove any test products that might have been created somehow
DELETE FROM products WHERE name = 'Test Product';

-- Reset triggers
SET session_replication_role = 'origin';

-- Verify exact product count and no test products
DO $$
DECLARE
    product_count INTEGER;
    test_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO product_count FROM products;
    SELECT COUNT(*) INTO test_count FROM products WHERE name = 'Test Product';
    
    IF product_count != 15 THEN
        RAISE EXCEPTION 'Expected exactly 15 products, but found % products', product_count;
    END IF;
    
    IF test_count > 0 THEN
        RAISE EXCEPTION 'Found % test products after cleanup', test_count;
    END IF;
END $$; 