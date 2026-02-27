-- 01_create_staging.sql
-- Objetivo: Criar tabelas staging com limpeza básica, tipos corretos e data quality checks
-- Referência: Practical Statistics (cap. exploratory data analysis), SQL Performance Explained (evitar funções em WHERE), Celko (tipos consistentes)

-- Crie schema se necessário (opcional)
-- CREATE SCHEMA IF NOT EXISTS staging;

-- staging_accounts: limpeza simples
CREATE TABLE staging_accounts AS
SELECT 
    TRIM(account_id) AS account_id,
    TRIM(account_name) AS account_name,
    TRIM(industry) AS industry,
    TRIM(country) AS country,
    TRIM(referral_source) AS referral_source,
    plan_tier AS plan_tier_initial,
    seats AS seats_initial,
    signup_date::DATE AS signup_date,
    is_trial,
    churn_flag,
    -- Data quality: flag se chave nula
    CASE WHEN account_id IS NULL THEN 1 ELSE 0 END AS dq_null_id
FROM read_csv_auto('data/raw/accounts.csv');  -- DuckDB style; ajuste para seu engine

-- staging_subscriptions
CREATE TABLE staging_subscriptions AS
SELECT 
    TRIM(subscription_id) AS subscription_id,
    TRIM(account_id) AS account_id,
    start_date::DATE AS start_date,
    end_date::DATE AS end_date,
    plan_tier,
    seats,
    mrr_amount::NUMERIC AS mrr_amount,
    arr_amount::NUMERIC AS arr_amount,
    is_trial,
    upgrade_flag,
    downgrade_flag,
    churn_flag,
    billing_frequency,
    auto_renew_flag,
    CASE WHEN subscription_id IS NULL OR account_id IS NULL THEN 1 ELSE 0 END AS dq_null_key
FROM read_csv_auto('data/raw/subscriptions.csv');

-- Faça o mesmo para as outras 3 tabelas (feature_usage, support_tickets, churn_events)
-- Exemplo rápido para feature_usage:
CREATE TABLE staging_feature_usage AS
SELECT 
    TRIM(usage_id) AS usage_id,
    TRIM(subscription_id) AS subscription_id,
    usage_date::DATE AS usage_date,
    TRIM(feature_name) AS feature_name,
    usage_count,
    usage_duration_secs,
    error_count,
    is_beta_feature
FROM read_csv_auto('data/raw/feature_usage.csv');

-- ... repita para support_tickets e churn_events
