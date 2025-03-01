-- Test to verify reviews were seeded correctly
DO $$
DECLARE
    total_review_count INTEGER;
    min_reviews_per_product INTEGER := 2;
    max_reviews_per_product INTEGER := 3;
    expected_min_total INTEGER := 15 * min_reviews_per_product; -- At least 2 per product
    product_record RECORD;
    review_record RECORD;
    test_failed BOOLEAN := false;
    error_message TEXT := '';
    min_content_length INTEGER := 20; -- Minimum expected length for review content
BEGIN
    -- Get total review count
    SELECT COUNT(*) INTO total_review_count FROM reviews;
    
    -- First check: Do we have at least the minimum expected number of reviews?
    IF total_review_count < expected_min_total THEN
        test_failed := true;
        error_message := format('Expected at least %s reviews, but found only %s', 
                                expected_min_total, total_review_count);
        RAISE NOTICE 'TEST FAILED: %', error_message;
    ELSE
        RAISE NOTICE 'TEST PASSED: Found % reviews (expected at least %)', 
                     total_review_count, expected_min_total;
    END IF;
    
    -- Second check: Verify each product has between 2-3 reviews
    FOR product_record IN SELECT id, name FROM products ORDER BY id LOOP
        DECLARE
            product_review_count INTEGER;
        BEGIN
            SELECT COUNT(*) INTO product_review_count 
            FROM reviews 
            WHERE product_id = product_record.id;
            
            IF product_review_count < min_reviews_per_product OR product_review_count > max_reviews_per_product THEN
                test_failed := true;
                error_message := error_message || format(E'\nProduct %s (%s) has %s reviews (expected between %s and %s)', 
                                                       product_record.id, 
                                                       product_record.name,
                                                       product_review_count,
                                                       min_reviews_per_product,
                                                       max_reviews_per_product);
                RAISE NOTICE 'TEST FAILED: Product % (%s) has % reviews (expected between % and %)', 
                             product_record.id, 
                             product_record.name,
                             product_review_count,
                             min_reviews_per_product,
                             max_reviews_per_product;
            ELSE
                RAISE NOTICE 'TEST PASSED: Product % (%s) has % reviews', 
                             product_record.id, 
                             product_record.name,
                             product_review_count;
            END IF;
        END;
    END LOOP;
    
    -- Third check: Verify review content lengths
    FOR review_record IN SELECT id, product_id, review_title, review_content FROM reviews ORDER BY product_id, id LOOP
        DECLARE
            content_length INTEGER;
            title_length INTEGER;
        BEGIN
            content_length := length(review_record.review_content);
            title_length := length(review_record.review_title);
            
            -- Check review content length
            IF content_length < min_content_length THEN
                test_failed := true;
                error_message := error_message || format(E'\nReview %s for product %s has content length %s (expected at least %s)', 
                                                       review_record.id, 
                                                       review_record.product_id,
                                                       content_length,
                                                       min_content_length);
                RAISE NOTICE 'TEST FAILED: Review % for product % has content length % (expected at least %)', 
                             review_record.id, 
                             review_record.product_id,
                             content_length,
                             min_content_length;
            END IF;
            
            -- Check review title exists
            IF title_length = 0 THEN
                test_failed := true;
                error_message := error_message || format(E'\nReview %s for product %s has empty title', 
                                                       review_record.id, 
                                                       review_record.product_id);
                RAISE NOTICE 'TEST FAILED: Review % for product % has empty title', 
                             review_record.id, 
                             review_record.product_id;
            END IF;
        END;
    END LOOP;
    
    -- Output summary statistics
    RAISE NOTICE '';
    RAISE NOTICE '=== Review Length Statistics ===';
    
    -- Show average review length by product
    FOR product_record IN 
        SELECT 
            p.id, 
            p.name, 
            COUNT(r.id) AS review_count,
            ROUND(AVG(LENGTH(r.review_content))) AS avg_content_length,
            MIN(LENGTH(r.review_content)) AS min_content_length,
            MAX(LENGTH(r.review_content)) AS max_content_length
        FROM products p
        JOIN reviews r ON p.id = r.product_id
        GROUP BY p.id, p.name
        ORDER BY p.id
    LOOP
        RAISE NOTICE 'Product % (%s): % reviews, Avg length: % chars, Min: % chars, Max: % chars',
                     product_record.id,
                     product_record.name,
                     product_record.review_count,
                     product_record.avg_content_length,
                     product_record.min_content_length,
                     product_record.max_content_length;
    END LOOP;
    
    -- Overall statistics
    DECLARE
        avg_review_length NUMERIC;
        min_review_length INTEGER;
        max_review_length INTEGER;
    BEGIN
        SELECT 
            ROUND(AVG(LENGTH(review_content))), 
            MIN(LENGTH(review_content)), 
            MAX(LENGTH(review_content))
        INTO 
            avg_review_length, 
            min_review_length, 
            max_review_length
        FROM reviews;
        
        RAISE NOTICE '';
        RAISE NOTICE 'Overall: % reviews, Avg length: % chars, Min: % chars, Max: % chars',
                     total_review_count,
                     avg_review_length,
                     min_review_length,
                     max_review_length;
    END;
    
    -- Final verdict
    IF test_failed THEN
        RAISE EXCEPTION 'REVIEW SEEDING TEST FAILED: %', error_message;
    ELSE
        RAISE NOTICE '';
        RAISE NOTICE 'All review tests passed! Reviews were seeded correctly.';
    END IF;
END $$; 