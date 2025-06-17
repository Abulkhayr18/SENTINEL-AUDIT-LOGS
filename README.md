# SentinelSphere Data Warehouse

A comprehensive cybersecurity and compliance monitoring data warehouse built using dimensional modeling principles to provide robust analytics and reporting capabilities for enterprise security operations.

## Overview

SentinelSphere is designed to centralize and analyze security events, user activities, audit logs, and compliance violations across your organization's digital infrastructure. The data warehouse employs a star schema with snowflaked dimensions to optimize query performance while maintaining data integrity and flexibility.

## Architecture

### Dimensional Model Design
- **Star Schema**: Optimized for analytical queries and reporting
- **Snowflaked IAM Dimensions**: Normalized policy structure for flexible access control analysis
- **Bridge Tables**: Support many-to-many relationships for complex data scenarios

## Database Schema

### Fact Tables

#### `fact_security_events`
Central fact table capturing all security incidents and events across the organization.
- **Granularity**: One record per security event
- **Key Metrics**: Event severity, timestamp, affected resources
- **Dimensions**: User, Device, Application, Cloud Provider, Location, Severity

#### `fact_user_activity`
Tracks detailed user actions and command executions for behavioral analysis.
- **Granularity**: One record per user action
- **Key Metrics**: Commands executed, application usage
- **Dimensions**: User, Application, Device

#### `fact_audit_logs`
Records policy enforcement actions and administrative activities.
- **Granularity**: One record per audit event
- **Key Metrics**: Policy actions, compliance activities
- **Dimensions**: User, IAM Policy, Cloud Provider

#### `fact_compliance_violations`
Captures regulatory and policy compliance breaches.
- **Granularity**: One record per violation
- **Key Metrics**: Violation severity, compliance framework impact
- **Dimensions**: Compliance Framework, User, Severity

### Dimension Tables

#### Core Dimensions
- **`dim_user`**: User profiles including department and role information
- **`dim_device`**: Device inventory with OS and type classification
- **`dim_application`**: Application catalog with version and vendor details
- **`dim_cloud_provider`**: Cloud service provider reference
- **`dim_location`**: Geographic and network location data
- **`dim_incident_severity`**: Standardized severity levels and descriptions
- **`dim_compliance_framework`**: Regulatory frameworks (GDPR, SOX, HIPAA, etc.)

#### Snowflaked IAM Dimensions
The Identity and Access Management (IAM) structure is snowflaked for normalized policy management:

```
dim_iam_policy
├── dim_policy_type (Authentication, Authorization, etc.)
├── dim_scope (Global, Department, Application-specific)
└── dim_permission (Read, Write, Admin, etc.)
```

### Bridge Tables
- **`bridge_user_roles`**: Many-to-many relationship between users and roles
- **`bridge_event_tags`**: Flexible tagging system for security events

## Key Features

### 🔒 Security Event Analytics
- Real-time security incident tracking
- Multi-dimensional threat analysis
- Cross-platform event correlation

### 👤 User Behavior Monitoring
- Command execution tracking
- Application usage patterns
- Anomaly detection support

### 📋 Compliance Management
- Multi-framework compliance tracking
- Violation trend analysis
- Audit trail maintenance

### 🏗️ Flexible Architecture
- Snowflaked IAM for complex policy structures
- Bridge tables for many-to-many relationships
- Extensible tagging system

## Use Cases

### Security Operations Center (SOC)
- **Incident Response**: Quick identification and analysis of security events
- **Threat Hunting**: Pattern recognition across multiple data sources
- **Risk Assessment**: Severity-based prioritization and resource allocation

### Compliance & Audit
- **Regulatory Reporting**: Automated compliance violation tracking
- **Policy Enforcement**: IAM policy effectiveness analysis
- **Audit Preparation**: Historical data retrieval and trend analysis

### IT Operations
- **User Access Management**: Role assignment and permission tracking
- **Asset Management**: Device and application inventory
- **Activity Monitoring**: Command execution and usage analytics

## Getting Started

### Prerequisites
- SQL Server, PostgreSQL, or compatible RDBMS
- Appropriate database permissions for schema creation
- ETL/ELT tools for data integration

### Installation

1. **Create Database**
   ```sql
   CREATE DATABASE SENTINELSPHERE;
   ```

2. **Execute Schema**
   ```bash
   sqlcmd -S [server] -d SENTINELSPHERE -i SentinelSphere_DW.sql
   ```

3. **Verify Installation**
   Check that all tables and foreign key constraints are created successfully.

### Data Loading

The warehouse is designed to accommodate data from various sources:
- **SIEM Systems**: Security event feeds
- **Identity Providers**: User and role information
- **Asset Management**: Device and application inventories
- **Cloud Platforms**: Multi-cloud activity logs
- **Compliance Tools**: Framework-specific violation data

## Query Examples

### Top Security Events by Severity
```sql
SELECT 
    s.level,
    COUNT(*) as event_count,
    AVG(DATEDIFF(hour, fse.timestamp, GETDATE())) as avg_age_hours
FROM fact_security_events fse
JOIN dim_incident_severity s ON fse.severity_id = s.severity_id
WHERE fse.timestamp >= DATEADD(day, -30, GETDATE())
GROUP BY s.level
ORDER BY event_count DESC;
```

### User Activity Analysis
```sql
SELECT 
    u.username,
    u.department,
    COUNT(fa.activity_id) as total_activities,
    COUNT(DISTINCT fa.application_id) as apps_used
FROM fact_user_activity fa
JOIN dim_user u ON fa.user_id = u.user_id
WHERE fa.timestamp >= DATEADD(day, -7, GETDATE())
GROUP BY u.username, u.department
ORDER BY total_activities DESC;
```

### Compliance Framework Violations
```sql
SELECT 
    cf.framework_name,
    cf.region_applicability,
    COUNT(fcv.violation_id) as violation_count,
    AVG(CASE WHEN s.level = 'Critical' THEN 4
             WHEN s.level = 'High' THEN 3
             WHEN s.level = 'Medium' THEN 2
             ELSE 1 END) as avg_severity_score
FROM fact_compliance_violations fcv
JOIN dim_compliance_framework cf ON fcv.framework_id = cf.framework_id
JOIN dim_incident_severity s ON fcv.severity_id = s.severity_id
GROUP BY cf.framework_name, cf.region_applicability
ORDER BY violation_count DESC;
```

## Performance Considerations

### Indexing Strategy
- **Fact Tables**: Clustered indexes on primary keys, non-clustered on foreign keys and timestamp columns
- **Dimension Tables**: Clustered indexes on primary keys, consider covering indexes for frequently queried attributes
- **Bridge Tables**: Composite indexes on both key columns

### Partitioning Recommendations
- **Time-based Partitioning**: Partition fact tables by month/quarter on timestamp columns
- **Archival Strategy**: Implement data retention policies based on compliance requirements

## Data Governance

### Data Quality
- Implement validation rules for critical dimensions
- Monitor data freshness and completeness
- Establish data lineage documentation

### Security & Access Control
- Role-based access control aligned with organizational hierarchy
- Column-level security for sensitive data
- Audit logging for warehouse access

## Contributing

### Schema Modifications
1. Follow dimensional modeling best practices
2. Maintain referential integrity
3. Document changes in schema evolution log
4. Test performance impact of modifications

### Adding New Data Sources
1. Map source data to existing dimensions where possible
2. Create new dimensions only when necessary
3. Update ETL processes and documentation
4. Validate data quality and integrity

## Support & Maintenance

### Monitoring
- Set up alerts for ETL failures
- Monitor query performance and resource usage
- Track data growth and storage requirements

### Backup & Recovery
- Implement regular backup schedules
- Test recovery procedures periodically
- Maintain documentation for disaster recovery

