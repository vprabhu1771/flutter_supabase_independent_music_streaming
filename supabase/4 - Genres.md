```sql
-- 4. genres table
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);
```

```sql
INSERT INTO genres (name) VALUES
('Dance'),
('Drive'),
('Rain'),
('Hip Hop'),
('Party'),
('Bhakti'),
('90s'),
('2000s');
```
