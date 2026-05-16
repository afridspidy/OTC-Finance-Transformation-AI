CREATE TABLE ar_data (
  customer_id TEXT,
  customer_name TEXT,
  invoice_number TEXT,
  invoice_amount REAL,
  days_outstanding INTEGER,
  aging_bucket TEXT,
  match_status TEXT,
  assigned_to TEXT
);

INSERT INTO ar_data VALUES
('C001','Pacific Telco Ltd','INV-2024-001',15000,12,'0-30','Matched','AI Auto-Matched'),
('C002','Summit Corp','INV-2024-002',42000,45,'31-60','Matched','AI Auto-Matched'),
('C003','Apex Networks','INV-2024-003',8450,67,'61-90','Analyst Review','Analyst Review'),
('C004','BlueStar Comms','INV-2024-004',21000,92,'90+','Suspense','Analyst Review'),
('C005','Meridian Global','INV-2024-005',5750,8,'0-30','Matched','AI Auto-Matched'),
('C006','Northern Freight','INV-2024-006',33000,55,'31-60','Analyst Review','Analyst Review'),
('C007','Delta Systems','INV-2024-007',18750,101,'90+','Suspense','Analyst Review'),
('C008','Coastal Connect','INV-2024-008',9200,22,'0-30','Matched','AI Auto-Matched'),
('C009','Horizon Telecom','INV-2024-009',44000,78,'61-90','Matched','AI Auto-Matched'),
('C010','Pinnacle Corp','INV-2024-010',12500,130,'90+','Suspense','Analyst Review');
```

**Step 3: Write your queries (paste these one at a time in the right panel)**

**Query 1 — AR Aging Bucket Summary (the most important query)**
```sql
-- This query answers: How much money is stuck in each time bucket?
-- A CFO asks this question every single month.
SELECT
  aging_bucket,
  COUNT(*) AS number_of_invoices,
  ROUND(SUM(invoice_amount), 2) AS total_amount_usd,
  ROUND(AVG(days_outstanding), 1) AS avg_days_outstanding
FROM ar_data
GROUP BY aging_bucket
ORDER BY
  CASE aging_bucket
    WHEN '0-30' THEN 1
    WHEN '31-60' THEN 2
    WHEN '61-90' THEN 3
    WHEN '90+' THEN 4
  END;
```

**Query 2 — AI vs Manual Workload Split**
```sql
-- This query answers: What percentage of work did AI handle vs human?
-- This is the core ROI metric for the AI project.
SELECT
  assigned_to,
  COUNT(*) AS invoice_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ar_data), 1) AS percentage,
  ROUND(SUM(invoice_amount), 2) AS total_amount_usd
FROM ar_data
GROUP BY assigned_to;
```

**Query 3 — High Risk — Overdue More Than 90 Days**
```sql
-- This query answers: Who owes us money that is critically overdue?
-- Collections teams run this query every morning.
SELECT
  customer_name,
  invoice_number,
  invoice_amount,
  days_outstanding,
  match_status
FROM ar_data
WHERE days_outstanding > 90
ORDER BY invoice_amount DESC;
```

**Query 4 — Exception Report — Items Needing Human Review**
```sql
-- This query answers: What does the analyst team need to work on today?
-- In your Accenture role, you did this manually every morning.
-- This query automates your morning routine.
SELECT
  customer_name,
  invoice_number,
  invoice_amount,
  days_outstanding,
  aging_bucket,
  match_status
FROM ar_data
WHERE match_status IN ('Analyst Review', 'Suspense')
ORDER BY days_outstanding DESC;
