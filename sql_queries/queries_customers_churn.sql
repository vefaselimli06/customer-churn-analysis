--Şirkətin neçə faizlik müştəri itirilib?
SELECT 
    ROUND(
        (COUNT(CASE WHEN Churn = 'Yes' THEN 1 END) * 100.0) 
        / COUNT(*),
    2) AS churn_rate_percent
FROM customers_churn;

--Hansı müqavilə tipində churn daha çoxdur.
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN Churn = 'Yes' THEN 1 END) AS churned_customers,
    ROUND(
        COUNT(CASE WHEN Churn = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
    2) AS churn_rate
FROM customers_churn
GROUP BY Contract
ORDER BY churn_rate DESC;


--Aylıq ödənişi yüksək olan müştərilər gedirmi?
SELECT 
    Churn,
    ROUND(AVG(TO_NUMBER(MonthlyCharges)),2) AS avg_monthly_charge
FROM customers_churn
GROUP BY Churn;

--Ən çox gəlir gətirən payment method
SELECT 
    PaymentMethod,
    ROUND(SUM(TO_NUMBER(MonthlyCharges)),2) AS total_revenue,
    COUNT(*) AS total_customers
FROM customers_churn
GROUP BY PaymentMethod
ORDER BY total_revenue DESC;

--Uzun müddətli müştərilər churn edirmi?
SELECT 
    CASE
        WHEN tenure < 12 THEN '0-1 il'
        WHEN tenure BETWEEN 12 AND 24 THEN '1-2 il'
        WHEN tenure BETWEEN 25 AND 48 THEN '2-4 il'
        ELSE '4+ il'
    END AS customer_lifetime,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN Churn='Yes' THEN 1 END) AS churned,
    ROUND(
        COUNT(CASE WHEN Churn='Yes' THEN 1 END)*100.0 / COUNT(*),
    2) AS churn_rate
FROM customers_churn
GROUP BY
    CASE
        WHEN tenure < 12 THEN '0-1 il'
        WHEN tenure BETWEEN 12 AND 24 THEN '1-2 il'
        WHEN tenure BETWEEN 25 AND 48 THEN '2-4 il'
        ELSE '4+ il'
    END
ORDER BY churn_rate DESC;

--Internet Service üzrə churn analizi
SELECT 
    InternetService,
    COUNT(*) AS total_customers, 
    COUNT(CASE WHEN Churn='Yes' THEN 1 END) AS churned,  
    ROUND(
        COUNT(CASE WHEN Churn='Yes' THEN 1 END)*100.0 / COUNT(*),
    2) AS churn_rate
FROM customers_churn
GROUP BY InternetService
ORDER BY churn_rate DESC;


--Tech Support olmayan müştərilər daha çox gedirmi?
SELECT 
    TechSupport,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN Churn='Yes' THEN 1 END) AS churned_customers,
    ROUND(
        COUNT(CASE WHEN Churn='Yes' THEN 1 END)*100.0 / COUNT(*),
    2) AS churn_rate
FROM customers_churn
GROUP BY TechSupport
ORDER BY churn_rate DESC;


--Ən yüksək riskli müştərilər
SELECT 
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    InternetService
FROM customers_churn
WHERE 
    Churn = 'Yes'
    AND TO_NUMBER(MonthlyCharges) > 70
    AND tenure < 12
ORDER BY TO_NUMBER(MonthlyCharges) DESC;

--Gender üzrə churn fərqi
SELECT 
    gender,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN Churn='Yes' THEN 1 END) AS churned,
    ROUND(
        COUNT(CASE WHEN Churn='Yes' THEN 1 END)*100.0 / COUNT(*),
    2) AS churn_rate
FROM customers_churn
GROUP BY gender;

--Şirkətin itirdiyi potensial gəlir
SELECT 
    ROUND(SUM(TO_NUMBER(MonthlyCharges)),2) AS lost_monthly_revenue
FROM customers_churn
WHERE Churn='Yes';

--Şirkətə ən çox pul qazandıran müştərilər
SELECT *
FROM (
    SELECT 
        customerID,
        MonthlyCharges,
        RANK() OVER (
            ORDER BY TO_NUMBER(MonthlyCharges) DESC
        ) AS revenue_rank
        
    FROM customers_churn
)
WHERE revenue_rank <= 10;


--View
CREATE OR REPLACE VIEW vw_customer_risk_analysis AS
SELECT 
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    InternetService,
    TechSupport,
    Churn
FROM customers_churn;
select * from vw_customer_risk_analysis;

--KPI Dashboard üçün master query
SELECT
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN Churn='Yes' THEN 1 END) AS churned_customers,
    ROUND(
        COUNT(CASE WHEN Churn='Yes' THEN 1 END)*100.0 / COUNT(*),
    2) AS churn_rate,
    ROUND(AVG(TO_NUMBER(MonthlyCharges)),2) AS avg_monthly_charge,
    ROUND(SUM(TO_NUMBER(MonthlyCharges)),2) AS total_monthly_revenue
FROM customers_churn;
