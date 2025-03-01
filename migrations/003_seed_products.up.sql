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

-- REVIEWS SEEDING SECTION:
-- Create 2-3 reviews for each product
-- Using various user IDs, star ratings, and review content

-- Product 1: Minimalist Desk Lamp
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('user123', 1, 'Perfect for late night work', 'I love how adjustable this lamp is. The light is bright but not harsh on the eyes. Highly recommend for anyone who works late!', 5, '2023-10-05T09:30:00Z'),
('designlover', 1, 'Sleek and functional', 'This lamp looks great on my desk and provides excellent lighting for reading and working. The minimalist design fits perfectly with my decor.', 4, '2023-10-15T14:20:00Z'),
('nightowl', 1, 'Good but could be better', 'The lamp works well but I wish it had more brightness levels. Otherwise it''s pretty good for the price.', 3, '2023-11-02T23:15:00Z');

-- Product 2: Ergonomic Office Chair
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('workfromhome', 2, 'Saved my back!', 'After months of back pain from my old chair, this one has been a lifesaver. The lumbar support is excellent and it''s very adjustable.', 5, '2023-10-20T11:45:00Z'),
('officepro', 2, 'Worth the investment', 'I was hesitant to spend this much on a chair, but my productivity has improved now that I''m comfortable all day. Great purchase.', 5, '2023-11-05T08:30:00Z');

-- Product 3: Wireless Keyboard
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('techwriter', 3, 'Responsive and reliable', 'The keys have just the right amount of travel and the Bluetooth connection is stable. Battery life is impressive too!', 4, '2023-09-12T15:30:00Z'),
('programmer42', 3, 'Good for coding', 'I type all day and this keyboard has been comfortable. The only issue is occasional lag when switching between devices.', 4, '2023-10-08T19:20:00Z'),
('mobileworker', 3, 'Compact and portable', 'Perfect size for my setup and easy to throw in my bag when I need to work elsewhere. Keys are a bit cramped though.', 3, '2023-10-25T10:15:00Z');

-- Product 4: Noise-Cancelling Headphones
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('audiophile', 4, 'Impressive noise cancellation', 'These headphones block out almost all ambient noise. Sound quality is excellent, especially for acoustic music.', 5, '2023-11-10T13:45:00Z'),
('traveler101', 4, 'Perfect for flights', 'Used these on a long-haul flight and they made such a difference. Comfortable to wear for many hours too.', 5, '2023-11-18T09:30:00Z');

-- Product 5: Smart Home Speaker
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('smarthomeenthusiast', 5, 'Great sound for the size', 'This speaker packs a surprising punch for something so compact. The assistant is responsive and accurate most of the time.', 4, '2023-08-15T14:20:00Z'),
('musiclover', 5, 'Decent but has limitations', 'Sound quality is good but the assistant sometimes struggles with complex requests. Integration with other smart devices could be better.', 3, '2023-09-02T11:10:00Z'),
('techfamily', 5, 'Kids love it', 'We use this for music, timers, weather updates, and answering the kids'' endless questions. Has become an essential part of our home.', 5, '2023-09-28T17:45:00Z');

-- Product 6: Ultra-Thin Laptop Stand
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('remoteworker', 6, 'Improved my posture', 'This stand puts my laptop at the perfect height to avoid neck strain. It''s lightweight and folds flat for travel.', 5, '2023-10-30T08:15:00Z'),
('digitalnomadd', 6, 'Essential for travel', 'I take this everywhere. It''s sturdy enough for my heavy laptop and so compact when folded. Great purchase!', 5, '2023-11-12T16:20:00Z');

-- Product 7: Premium Leather Notebook
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('journaler', 7, 'Beautiful craftsmanship', 'The leather is soft and the paper quality is excellent - no bleeding even with fountain pens. Gets better with age.', 5, '2023-07-20T09:30:00Z'),
('creativewriter', 7, 'Inspiring to use', 'There''s something about a quality notebook that makes writing more enjoyable. This one looks and feels premium.', 4, '2023-08-14T12:45:00Z'),
('businesspro', 7, 'Good but pricey', 'Nice notebook but not sure it justifies the price. Paper quality is excellent though.', 3, '2023-09-05T14:30:00Z');

-- Product 8: Wireless Charging Pad
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('techgeek', 8, 'Fast and reliable', 'Charges my phone quickly and works through my case. The non-slip surface keeps the phone in place.', 4, '2023-10-10T11:20:00Z'),
('minimalist', 8, 'Sleek addition to my desk', 'This charging pad looks great and works well. I appreciate not having to plug in my phone anymore.', 5, '2023-10-28T19:15:00Z');

-- Product 9: Minimalist Wall Clock
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('homedecor', 9, 'Elegant and functional', 'This clock looks beautiful on my wall and the silent movement means no annoying ticking. The minimalist design works in any room.', 5, '2023-09-18T15:30:00Z'),
('clockcollector', 9, 'Accurate and stylish', 'Keeps perfect time and the simple design makes it easy to read from across the room. Very satisfied with this purchase.', 4, '2023-10-02T10:15:00Z'),
('simplicityseeker', 9, 'Just what I needed', 'No frills, just a clean, simple clock that looks great. The silent mechanism is a huge plus.', 5, '2023-10-14T08:45:00Z');

-- Product 10: Portable Bluetooth Speaker
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('beachgoer', 10, 'Perfect for outdoor use', 'Took this to the beach and the waterproofing worked great. Sound quality is impressive for the size and battery lasted all day.', 5, '2023-11-20T16:45:00Z'),
('partyhoster', 10, 'Great sound, easy to carry', 'Used this for a small gathering and the sound filled the space nicely. Easy to connect and the battery life is excellent.', 4, '2023-11-25T13:20:00Z');

-- Product 11: Adjustable Standing Desk
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('healthconscious', 11, 'Game changer for work', 'Being able to switch between sitting and standing has made such a difference in how I feel at the end of the day. The motor is quiet and smooth.', 5, '2023-08-30T09:45:00Z'),
('officemanager', 11, 'Great quality but expensive', 'This is an excellent standing desk but the price point is high. The memory settings are very convenient though.', 4, '2023-09-15T11:30:00Z'),
('tallperson', 11, 'Finally found the right height', 'As a tall person, finding a desk that goes high enough has been a challenge. This one is perfect and very stable even at max height.', 5, '2023-09-28T14:15:00Z');

-- Product 12: Artisan Coffee Mug
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('coffeelover', 12, 'Beautiful and functional', 'This mug keeps my coffee warm and looks beautiful. The handle is comfortable to hold and the glaze is perfect.', 5, '2023-10-22T07:30:00Z'),
('morningritual', 12, 'My new favorite mug', 'There''s something special about drinking from a handmade mug. This one has the perfect weight and size.', 5, '2023-11-05T08:15:00Z');

-- Product 13: Smart Fitness Tracker
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('fitnessaddict', 13, 'Accurate and motivating', 'The heart rate monitor is accurate compared to my chest strap, and the sleep analysis has helped me improve my rest. Battery life is great too.', 5, '2023-09-20T16:45:00Z'),
('runner42', 13, 'Good but app needs work', 'The tracker hardware is excellent but the app is sometimes buggy and could use a better interface. Otherwise very happy with it.', 4, '2023-10-05T18:30:00Z'),
('healthtracker', 13, 'Great for motivation', 'Being able to see my progress has kept me motivated. The waterproofing works well for swimming too.', 4, '2023-10-18T15:20:00Z');

-- Product 14: Modern Plant Pot
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('plantparent', 14, 'Stylish and practical', 'This pot looks great in my living room and the drainage is perfect for my fiddle leaf fig. The bamboo tray catches water perfectly.', 5, '2023-11-12T13:15:00Z'),
('indoorgardener', 14, 'Simple elegance', 'Clean lines and neutral color make this pot work anywhere. Good size for medium plants.', 4, '2023-11-22T10:30:00Z');

-- Product 15: Designer Ballpoint Pen
INSERT INTO reviews (user_id, product_id, review_title, review_content, stars, created_at) VALUES
('stationerylover', 15, 'Writes beautifully', 'The ink flows smoothly and the weight of the pen makes writing a pleasure. It looks professional too.', 5, '2023-09-10T14:30:00Z'),
('journalist', 15, 'Reliable and elegant', 'I use this pen daily and it never fails. The metal construction makes it feel substantial and it writes consistently.', 4, '2023-09-25T11:20:00Z'),
('penthusiast', 15, 'Great everyday pen', 'Not too heavy, not too light - just right. Ink is smooth and it looks much more expensive than it is.', 5, '2023-10-08T15:45:00Z');

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
    review_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO product_count FROM products;
    SELECT COUNT(*) INTO test_count FROM products WHERE name = 'Test Product';
    SELECT COUNT(*) INTO review_count FROM reviews;
    
    IF product_count != 15 THEN
        RAISE EXCEPTION 'Expected exactly 15 products, but found % products', product_count;
    END IF;
    
    IF test_count > 0 THEN
        RAISE EXCEPTION 'Found % test products after cleanup', test_count;
    END IF;
    
    IF review_count < 30 THEN
        RAISE EXCEPTION 'Expected at least 30 reviews, but found only %', review_count;
    END IF;
    
    RAISE NOTICE 'Seeding successful: % products and % reviews created', product_count, review_count;
END $$; 