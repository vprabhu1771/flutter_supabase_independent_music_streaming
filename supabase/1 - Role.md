```sql
-- 1. roles table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);
```

```sql
INSERT INTO roles (name) VALUES
('admin'),
('freelancer'),
('customer');
```
