-- Test to verify products were seeded correctly
DO $$
DECLARE
    product_count INTEGER;
    expected_count INTEGER := 15;
    test_product_count INTEGER;
    unexpected_products TEXT := '';
    test_failed BOOLEAN := false;
    error_message TEXT := '';
BEGIN
    -- Count the number of products in the table
    SELECT COUNT(*) INTO product_count FROM products;
    
    -- Get count of test products (should be 0)
    SELECT COUNT(*) INTO test_product_count FROM products WHERE name = 'Test Product';
    
    -- Check if there are any test products (there shouldn't be)
    IF test_product_count > 0 THEN
        test_failed := true;
        error_message := format('Found %s test products that should not exist', test_product_count);
        RAISE NOTICE 'TEST FAILED: %', error_message;
        
        -- Show the test products
        FOR i IN (SELECT id, name FROM products WHERE name = 'Test Product') LOOP
            RAISE NOTICE 'Unexpected test product found: ID=%, Name=%', i.id, i.name;
        END LOOP;
    END IF;
    
    -- Check if there are any other products that are not in our expected list
    FOR i IN (
        SELECT id, name 
        FROM products 
        WHERE name NOT IN (
            'Minimalist Desk Lamp',
            'Ergonomic Office Chair',
            'Wireless Keyboard',
            'Noise-Cancelling Headphones',
            'Smart Home Speaker',
            'Ultra-Thin Laptop Stand',
            'Premium Leather Notebook',
            'Wireless Charging Pad',
            'Minimalist Wall Clock',
            'Portable Bluetooth Speaker',
            'Adjustable Standing Desk',
            'Artisan Coffee Mug',
            'Smart Fitness Tracker',
            'Modern Plant Pot',
            'Designer Ballpoint Pen'
        )
    ) LOOP
        test_failed := true;
        unexpected_products := unexpected_products || format(E'\nUnexpected product: ID=%s, Name=%s', i.id, i.name);
        RAISE NOTICE 'Unexpected product found: ID=%, Name=%', i.id, i.name;
    END LOOP;
    
    IF unexpected_products <> '' THEN
        error_message := error_message || E'\n' || unexpected_products;
    END IF;
    
    -- Check if the count matches the expected number or if it is exact
    IF product_count = expected_count THEN
        RAISE NOTICE 'TEST PASSED: Found % products as expected', product_count;
    ELSE
        test_failed := true;
        error_message := error_message || format(E'\nExpected %s products but found %s', expected_count, product_count);
        RAISE NOTICE 'TEST FAILED: Expected % products but found %', expected_count, product_count;
    END IF;
    
    -- Check each expected product
    FOR product_name IN (
        SELECT unnest(ARRAY[
            'Minimalist Desk Lamp',
            'Ergonomic Office Chair',
            'Wireless Keyboard',
            'Noise-Cancelling Headphones',
            'Smart Home Speaker',
            'Ultra-Thin Laptop Stand',
            'Premium Leather Notebook',
            'Wireless Charging Pad',
            'Minimalist Wall Clock',
            'Portable Bluetooth Speaker',
            'Adjustable Standing Desk',
            'Artisan Coffee Mug',
            'Smart Fitness Tracker',
            'Modern Plant Pot',
            'Designer Ballpoint Pen'
        ])
    ) LOOP
        IF NOT EXISTS (SELECT 1 FROM products WHERE name = product_name) THEN
            test_failed := true;
            error_message := error_message || E'\nMissing product: ' || product_name;
            RAISE NOTICE 'TEST FAILED: Missing product: %', product_name;
        END IF;
    END LOOP;
    
    -- Final verdict
    IF test_failed THEN
        RAISE EXCEPTION 'PRODUCT SEEDING TEST FAILED: %', error_message;
    ELSE
        RAISE NOTICE 'All tests passed! Products were seeded correctly.';
    END IF;
END $$; 