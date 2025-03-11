```sql
-- 7. platlists table
CREATE TABLE playlists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    user_id uuid NULL,
);
```

```sql
INSERT INTO playlists (name) VALUES
('Dance'),
('Favorite');
```
