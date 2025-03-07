```sql
-- 7. platlists table
CREATE TABLE platlists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);
```

```sql
INSERT INTO platlists (name) VALUES
('Dance'),
('Favorite');
```
