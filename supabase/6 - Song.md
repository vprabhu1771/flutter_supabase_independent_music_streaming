```sql
-- 6. songs table
CREATE TABLE songs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    image_path VARCHAR(100) DEFAULT 'default_image.png',
    song_path VARCHAR(100) DEFAULT 'default_image.png',
    user_id uuid NULL,
    genre_id INT NULL,
    brand_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
```sql
ALTER TABLE songs ADD COLUMN duration INTERVAL;
```