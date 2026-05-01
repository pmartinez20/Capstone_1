/* Name: Paola Martinez
   Category: BRANDIES
   (American Grape, Imported Grape, Miscellaneous, Apricot, Blackberry, Cherry, Peach Brandies)
*/

-- 1. Create a list of all transactions for your chosen [Category/Vendor] that took place in
-- the last quarter of 2014, sorted by the total sale amount from highest to lowest.
-- (Strength: Identifying high-volume peak periods).

SELECT date,
    store,
    description,
    bottle_qty,
    btl_price,
    total :: money 
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
  AND date >= '2014-10-01'
  AND date <= '2014-12-31'
ORDER BY total DESC;


-- ============================================================
-- 2. Which transactions for your [Category/Vendor] had a bottle quantity greater than 12?
-- Display the date, store number, item description, and total amount.
-- (Strength: Identifying bulk buyers or wholesale-style transactions).

SELECT
    date,
    store,
    description,
    bottle_qty,
    total
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
  AND bottle_qty > 12
ORDER BY bottle_qty DESC;


-- ============================================================
-- 3. Find all products in the products_table whose item_description contains a specific
-- keyword (e.g., 'Limited', 'Spiced'). What categories do they belong to?
-- (Opportunity: Identifying niche product variants).

SELECT
    item_no,
    item_description,
    category_name,
    proof,
    bottle_price
FROM public.products
WHERE item_description LIKE '%Reserve%'
   OR item_description LIKE '%XO%';


-- ============================================================
-- Aggregation
-- ============================================================

-- 4. What is the total sales revenue and the average bottle price (btl_price) for
-- your chosen [Category/Vendor]?
-- (Strength/Baseline: Establishing the financial footprint).

SELECT
    ROUND(SUM(total::numeric), 2)        AS total_revenue,
    ROUND(AVG(btl_price::numeric), 2)    AS avg_bottle_price,
    SUM(bottle_qty)                      AS total_bottles_sold,
    COUNT(*)                             AS total_transactions
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
);


-- ============================================================
-- 5. How many transactions were recorded for each specific item description within your
-- chosen [Category]? Which specific product is the most frequently purchased?
-- (Strength: Identifying your "hero" product).

SELECT
    description,
    COUNT(*)             AS transaction_count,
    SUM(bottle_qty)      AS total_bottles_sold,
    ROUND(SUM(total), 2) AS total_revenue
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY description
ORDER BY transaction_count DESC;


-- ============================================================
-- 6. Which store generated the highest total revenue for your [Category/Vendor]?
-- Which generated the lowest (but still greater than zero)?
-- (Strength vs. Weakness: Identifying your best and worst retail partners).

-- Highest revenue store:
SELECT
    store,
    ROUND(SUM(total), 2) AS total_revenue
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY store
ORDER BY total_revenue DESC
LIMIT 1;

-- Lowest revenue store (greater than $0):
SELECT
    store,
    ROUND(SUM(total), 2) AS total_revenue
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY store
HAVING SUM(total) > 0
ORDER BY total_revenue ASC
LIMIT 1;


-- ============================================================
-- 7. What is the total revenue for every vendor within your chosen [Category],
-- sorted from highest to lowest?
-- (Threat: Identifying your top competitors in that space).

SELECT
    vendor            AS vendor_name,
    ROUND(SUM(total), 2)  AS total_revenue,
    COUNT(*)              AS transaction_count
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY vendor
ORDER BY total_revenue DESC;


-- ============================================================
-- 8. Which stores had total sales revenue for your [Category/Vendor] exceeding $2,000?
-- (Hint: Use HAVING to filter aggregated store totals).
-- (Strength: Pinpointing high-performing retail locations).

SELECT
    store,
    ROUND(SUM(total), 2)    AS total_revenue,
    COUNT(*)                AS transaction_count,
    SUM(bottle_qty)         AS total_bottles
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY store
HAVING SUM(total) > 2000
ORDER BY total_revenue DESC;


-- ============================================================
-- Joins
-- ============================================================

-- 9. Find all sales records where the category_name is either your chosen category
-- or a closely related competitor category (e.g., 'VODKA 80 PROOF' vs 'IMPORTED VODKA').
-- (Threat: Comparing performance against direct substitutes).

SELECT
    category_name,
    ROUND(SUM(total), 2)    AS total_revenue,
    COUNT(*)                AS transaction_count,
    SUM(bottle_qty)         AS total_bottles_sold
FROM public.sales
WHERE category_name IN (
    -- Brandy categories
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES',
    -- Competitor / substitute categories
    'WHISKEY LIQUEUR',
    'AMERICAN COCKTAILS',
    'CREAM LIQUEURS',
    'MISC. AMERICAN CORDIALS & LIQUEURS'
)
GROUP BY category_name
ORDER BY total_revenue DESC;


-- ============================================================
-- 10. List all transactions where the state bottle cost was between $10 and $20 for
-- your [Category/Vendor].
-- (Opportunity: Analyzing performance in the "mid-tier" price bracket).

SELECT
    date,
    store,
    description,
    state_btl_cost,
    btl_price,
    bottle_qty,
    total
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
  AND state_btl_cost::numeric BETWEEN 10 AND 20
ORDER BY total DESC;


-- ============================================================
-- 11. Write a query that displays each store's total sales for your [Category/Vendor]
-- along with the store's name and address from the stores_table.
-- (Strength: Mapping your physical sales footprint).

SELECT
    s.store,
    st.name                     AS store_name,
    st.store_address,
    ROUND(SUM(s.total), 2)      AS total_brandy_revenue,
    COUNT(*)                    AS transaction_count
FROM public.sales s
JOIN public.stores st
    ON s.store = st.store
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY s.store, st.name, st.store_address
ORDER BY SUM(s.total) DESC;


-- ============================================================
-- 12. For each sale in your [Category], display the transaction date, total amount,
-- and the population of the county where the sale occurred by joining with counties_table.
-- (Opportunity: Correlating sales volume with population density).

SELECT
    s.date,
    s.county,
    c.population,
    s.description,
    s.total
FROM public.sales s
JOIN public.counties c
    ON s.county = c.county
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
ORDER BY s.date DESC;


-- ============================================================
-- 13. Write a query that shows total sales for your [Category/Vendor] by county.
-- Which county generates the most revenue for you?
-- (Strength: Identifying your geographic stronghold).

SELECT
    s.county,
    c.population,
    ROUND(SUM(s.total), 2)                AS total_revenue,
    SUM(s.bottle_qty)                     AS total_bottles_sold,
    ROUND(SUM(s.total) / c.population, 2) AS revenue_per_capita
FROM public.sales s
JOIN public.counties c
    ON s.county = c.county
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY s.county, c.population
ORDER BY SUM(s.total) DESC;


-- ============================================================
-- 14. Join the sales_table and products_table to show total revenue for your [Vendor]
-- alongside the proof and pack size of the items.
-- (Strength: Determining if higher proof or larger packs drive more revenue).

SELECT
    s.description,
    p.proof,
    p.pack,
    p.bottle_size,
    ROUND(SUM(s.total), 2)      AS total_revenue,
    SUM(s.bottle_qty)           AS total_bottles_sold,
    COUNT(*)                    AS transaction_count
FROM public.sales s
JOIN public.products p
    ON s.item = p.item_no
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY s.description, p.proof, p.pack, p.bottle_size
ORDER BY SUM(s.total) DESC;


-- ============================================================
-- 15. Are there any counties in the counties_table that have a population over 10,000
-- but zero sales for your [Category/Vendor]?
-- (Opportunity: Identifying untapped markets).
-- Result: No results returned. Every Iowa county with a population over 10,000
-- already has brandy sales on record.

SELECT
    c.county,
    c.population
FROM public.counties c
WHERE c.population > 10000
  AND c.county NOT IN (
      SELECT DISTINCT county
      FROM public.sales
      WHERE category_name IN (
          'AMERICAN GRAPE BRANDIES',
          'IMPORTED GRAPE BRANDIES',
          'MISCELLANEOUS BRANDIES',
          'APRICOT BRANDIES',
          'BLACKBERRY BRANDIES',
          'CHERRY BRANDIES',
          'PEACH BRANDIES'
      )
      AND county IS NOT NULL
  )
ORDER BY c.population DESC;


-- ============================================================
-- 16. Display total revenue for your [Category/Vendor] grouped by the store_status
-- (from stores_table). Are active stores ('A') performing significantly better than others?
-- (Threat: Assessing the risk of sales tied to inactive or closed locations).

SELECT
    st.store_status,
    ROUND(SUM(s.total), 2)      AS total_revenue,
    COUNT(*)                    AS transaction_count,
    COUNT(DISTINCT s.store)     AS store_count
FROM public.sales s
JOIN public.stores st
    ON s.store = st.store
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY st.store_status
ORDER BY SUM(s.total) DESC;


-- ============================================================
-- Subqueries
-- ============================================================

-- 17. Using a subquery, find all transactions for your [Category/Vendor] from stores
-- located in a specific high-growth city (e.g., 'Des Moines') found in the stores_table.
-- (Opportunity: Drilling down into urban market performance).

-- Test: confirm Des Moines stores exist in stores table
SELECT store, store_address
FROM public.stores
WHERE store_address LIKE '%Des Moines%';

-- Test: confirm transaction count from Des Moines brandy stores
SELECT COUNT(*)
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
AND store IN (
    SELECT store FROM public.stores
    WHERE store_address ILIKE '%des moines%'
);

-- Final query: all Des Moines brandy transactions
SELECT
    date,
    store,
    description,
    bottle_qty,
    btl_price,
    total
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
  AND store IN (
      SELECT store
      FROM public.stores
      WHERE store_address LIKE '%Des Moines%'
  )
ORDER BY total DESC;


-- ============================================================
-- 18. Which stores had total sales for your [Category/Vendor] that were above the
-- average store revenue for that same group? (Hint: Use a subquery for the average).
-- (Strength: Identifying stores that are over-performing).

SELECT
    store,
    ROUND(SUM(total), 2) AS store_total_revenue
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY store
HAVING SUM(total) > (
    SELECT AVG(store_revenue)
    FROM (
        SELECT store, SUM(total) AS store_revenue
        FROM public.sales
        WHERE category_name IN (
            'AMERICAN GRAPE BRANDIES',
            'IMPORTED GRAPE BRANDIES',
            'MISCELLANEOUS BRANDIES',
            'APRICOT BRANDIES',
            'BLACKBERRY BRANDIES',
            'CHERRY BRANDIES',
            'PEACH BRANDIES'
        )
        GROUP BY store
    ) AS store_totals
)
ORDER BY SUM(total) DESC;


-- ============================================================
-- 19. Find the top 5 highest-grossing items for your [Vendor], then use a subquery
-- to look up their full details (like case_cost and proof) from the products_table.
-- (Strength: Deep-dive into the specs of your most profitable inventory).

SELECT
    p.item_no,
    p.item_description,
    p.proof,
    p.pack,
    p.bottle_size,
    p.case_cost,
    p.bottle_price,
    top5.total_revenue
FROM public.products p
JOIN (
    SELECT
        item,
        ROUND(SUM(total), 2) AS total_revenue
    FROM public.sales
    WHERE category_name IN (
        'AMERICAN GRAPE BRANDIES',
        'IMPORTED GRAPE BRANDIES',
        'MISCELLANEOUS BRANDIES',
        'APRICOT BRANDIES',
        'BLACKBERRY BRANDIES',
        'CHERRY BRANDIES',
        'PEACH BRANDIES'
    )
    GROUP BY item
    ORDER BY total_revenue DESC
    LIMIT 5
) AS top5
    ON p.item_no = top5.item
ORDER BY top5.total_revenue DESC;


-- ============================================================
-- 20. Write a query using a subquery to find all sales records for your [Category]
-- from stores that have an 'A' (Active) status in the stores_table.
-- (Strength: Filtering for reliable, ongoing revenue streams).

SELECT
    s.date,
    s.store,
    s.county,
    s.description,
    s.bottle_qty,
    s.btl_price,
    s.total
FROM public.sales s
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
  AND s.store IN (
      SELECT store
      FROM public.stores
      WHERE store_status = 'A'
  )
ORDER BY s.date DESC, s.total DESC;


-- ============================================================
-- BONUS: CTE used as a reusable brandy filter
-- (Professional alternative to repeating the WHERE clause on every query)

WITH brandy_sales AS (
    SELECT *
    FROM public.sales
    WHERE category_name IN (
        'AMERICAN GRAPE BRANDIES',
        'IMPORTED GRAPE BRANDIES',
        'MISCELLANEOUS BRANDIES',
        'APRICOT BRANDIES',
        'BLACKBERRY BRANDIES',
        'CHERRY BRANDIES',
        'PEACH BRANDIES'
    )
)
SELECT *
FROM brandy_sales;

-- Example usage:
-- SELECT store, ROUND(SUM(total),2) AS revenue
-- FROM brandy_sales
-- GROUP BY store
-- ORDER BY revenue DESC;


-- ============================================================
-- ADDITIONAL QUERIES — Used to build presentation slides
-- These were not part of the original 20 questions.
-- Each is labeled with the slide(s) it supported.
-- ============================================================

-- ============================================================
-- ADDITIONAL QUERY A
-- Slide 3 (Summary Statistics) — Total vendor count
-- Q7 lists each vendor individually but does not return a single count.
-- This collapses the vendor list to one number for the summary stat slide.

SELECT COUNT(DISTINCT vendor) AS vendor_count
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
);


-- ============================================================
-- ADDITIONAL QUERY B
-- Slides 5 and 8 (Q4 Seasonality / December Drop-Off)
-- Q1 returns individual transaction rows. This groups them by month
-- to produce the three monthly totals shown in the chart.

SELECT
    TO_CHAR(date, 'YYYY-MM')        AS month,
    ROUND(SUM(total::numeric), 2)   AS monthly_revenue,
    COUNT(*)                        AS transaction_count
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
AND date BETWEEN '2014-10-01' AND '2014-12-31'
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- ADDITIONAL QUERY C
-- Slide 4 (Top Brands by Revenue)
-- Q5 and Q19. Hennessy appears
-- under multiple product descriptions (different sizes and expressions).
-- Grouping by vendor_name collapses all SKUs into one brand-level total.

SELECT
    p.vendor_name,
    ROUND(SUM(s.total::numeric), 2) AS total_revenue,
    SUM(s.bottle_qty)               AS total_bottles,
    COUNT(*)                        AS transaction_count
FROM public.sales s
JOIN public.products p
    ON s.item = p.item_no
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY p.vendor_name
ORDER BY total_revenue DESC
LIMIT 5;


-- ============================================================
-- ADDITIONAL QUERY D
-- Slide 9 (County Revenue Per Capita)
-- Q13 returns total revenue by county. Revenue per capita was added
-- as a calculated column (SUM(total) / population) to normalize for
-- county size. Raw revenue alone always favors large counties.

SELECT
    s.county,
    c.population,
    ROUND(SUM(s.total::numeric), 2)                         AS total_revenue,
    ROUND(SUM(s.total::numeric) / c.population::numeric, 2) AS revenue_per_capita
FROM public.sales s
JOIN public.counties c
    ON s.county = c.county
WHERE s.category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
GROUP BY s.county, c.population
ORDER BY revenue_per_capita DESC
LIMIT 10;


-- ============================================================
-- ADDITIONAL QUERY E
-- Slide 10 (Promote Higher-Value Bottles)
-- Q10 returns individual transactions in the $10–$20 range but does
-- not summarize by price band. CASE statement creates $2-wide
-- brackets and aggregates transaction count and revenue within each.

SELECT
    CASE
        WHEN state_btl_cost::numeric >= 10 AND state_btl_cost::numeric < 12 THEN '$10-$12'
        WHEN state_btl_cost::numeric >= 12 AND state_btl_cost::numeric < 14 THEN '$12-$14'
        WHEN state_btl_cost::numeric >= 14 AND state_btl_cost::numeric < 16 THEN '$14-$16'
        WHEN state_btl_cost::numeric >= 16 AND state_btl_cost::numeric < 18 THEN '$16-$18'
        WHEN state_btl_cost::numeric >= 18 AND state_btl_cost::numeric <= 20 THEN '$18-$20'
    END                             AS price_bracket,
    COUNT(*)                        AS transaction_count,
    ROUND(SUM(total::numeric), 2)   AS total_revenue,
    ROUND(AVG(total::numeric / bottle_qty), 2) AS avg_revenue_per_bottle
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
AND state_btl_cost::numeric BETWEEN 10 AND 20
GROUP BY price_bracket
ORDER BY price_bracket;


-- ============================================================
-- ADDITIONAL QUERY F
-- Slide 7 (Vendor Concentration Risk)
-- Moet Hennessy appears under two different vendor name formats in
-- the source data due to inconsistent entry. This query uses LIKE
-- to catch both variants and sum them into a single combined total
-- for accurate analysis.

SELECT
    'Moet Hennessy USA (Combined)' AS vendor_name,
    ROUND(SUM(total::numeric), 2)  AS total_revenue
FROM public.sales
WHERE category_name IN (
    'AMERICAN GRAPE BRANDIES',
    'IMPORTED GRAPE BRANDIES',
    'MISCELLANEOUS BRANDIES',
    'APRICOT BRANDIES',
    'BLACKBERRY BRANDIES',
    'CHERRY BRANDIES',
    'PEACH BRANDIES'
)
AND vendor ILIKE '%Moet%';