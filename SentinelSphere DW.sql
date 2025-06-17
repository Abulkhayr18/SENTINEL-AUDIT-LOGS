CREATE DATABASE SENTINELSPHERE;


-- FACT TABLES
-- ======================================

CREATE TABLE fact_security_events (
    event_id INT PRIMARY KEY,
    timestamp DATETIME,
    user_id INT,
    device_id INT,
    application_id INT,
    cloud_provider_id INT,
    severity_id INT,
    location_id INT,
    event_type VARCHAR(100),
    description TEXT
);

CREATE TABLE fact_user_activity (
    activity_id INT PRIMARY KEY,
    user_id INT,
    timestamp DATETIME,
    command_executed VARCHAR(255),
    application_id INT,
    device_id INT
);

CREATE TABLE fact_audit_logs (
    audit_id INT PRIMARY KEY,
    user_id INT,
    policy_id INT,
    timestamp DATETIME,
    action_taken VARCHAR(100),
    cloud_provider_id INT
);

CREATE TABLE fact_compliance_violations (
    violation_id INT PRIMARY KEY,
    framework_id INT,
    timestamp DATETIME,
    user_id INT,
    description TEXT,
    severity_id INT
);

-- ======================================
-- DIMENSION TABLES
-- ======================================

CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    username VARCHAR(100),
    email VARCHAR(100),
    department VARCHAR(100),
    role VARCHAR(100)
);

CREATE TABLE dim_device (
    device_id INT PRIMARY KEY,
    hostname VARCHAR(100),
    device_type VARCHAR(50),
    os VARCHAR(50)
);

CREATE TABLE dim_application (
    application_id INT PRIMARY KEY,
    app_name VARCHAR(100),
    version VARCHAR(50),
    vendor VARCHAR(100)
);

CREATE TABLE dim_cloud_provider (
    cloud_provider_id INT PRIMARY KEY,
    provider_name VARCHAR(100)
);

CREATE TABLE dim_compliance_framework (
    framework_id INT PRIMARY KEY,
    framework_name VARCHAR(100),
    region_applicability VARCHAR(100)
);

CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    country VARCHAR(100),
    region VARCHAR(100),
    ip_range VARCHAR(100)
);

CREATE TABLE dim_incident_severity (
    severity_id INT PRIMARY KEY,
    level VARCHAR(50),
    description TEXT
);

-- ======================================
-- SNOWFLAKED IAM DIMENSIONS
-- ======================================

CREATE TABLE dim_iam_policy (
    policy_id INT PRIMARY KEY,
    policy_name VARCHAR(100),
    type_id INT,
    scope_id INT,
    permission_id INT
);

CREATE TABLE dim_policy_type (
    type_id INT PRIMARY KEY,
    type_name VARCHAR(100)
);

CREATE TABLE dim_scope (
    scope_id INT PRIMARY KEY,
    scope_name VARCHAR(100)
);

CREATE TABLE dim_permission (
    permission_id INT PRIMARY KEY,
    permission_name VARCHAR(100)
);

-- ======================================
-- BRIDGE TABLES
-- ======================================

CREATE TABLE bridge_user_roles (
    user_id INT,
    role_id INT,
    assigned_by VARCHAR(100),
    assigned_at DATETIME,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE bridge_event_tags (
    event_id INT,
    tag VARCHAR(100),
    PRIMARY KEY (event_id, tag)
);

-- ======================================
-- FOREIGN KEY CONSTRAINTS
-- ======================================

ALTER TABLE fact_security_events
ADD FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (device_id) REFERENCES dim_device(device_id),
    FOREIGN KEY (application_id) REFERENCES dim_application(application_id),
    FOREIGN KEY (cloud_provider_id) REFERENCES dim_cloud_provider(cloud_provider_id),
    FOREIGN KEY (severity_id) REFERENCES dim_incident_severity(severity_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id);

ALTER TABLE fact_user_activity
ADD FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (application_id) REFERENCES dim_application(application_id),
    FOREIGN KEY (device_id) REFERENCES dim_device(device_id);

ALTER TABLE fact_audit_logs
ADD FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (policy_id) REFERENCES dim_iam_policy(policy_id),
    FOREIGN KEY (cloud_provider_id) REFERENCES dim_cloud_provider(cloud_provider_id);

ALTER TABLE fact_compliance_violations
ADD FOREIGN KEY (framework_id) REFERENCES dim_compliance_framework(framework_id),
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (severity_id) REFERENCES dim_incident_severity(severity_id);

ALTER TABLE dim_iam_policy
ADD FOREIGN KEY (type_id) REFERENCES dim_policy_type(type_id),
    FOREIGN KEY (scope_id) REFERENCES dim_scope(scope_id),
    FOREIGN KEY (permission_id) REFERENCES dim_permission(permission_id);
