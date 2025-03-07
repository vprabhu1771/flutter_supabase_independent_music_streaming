```sql
-- 5. brands table
CREATE TABLE brands (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    image_path VARCHAR(100) DEFAULT 'default_image.png',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

```sql
-- Insert with default image_path ('default_image.png' will be used)
INSERT INTO brands (name) VALUES
('AVM Music'),
('Think Music'),
('Sony Music');
```

```sql
-- Insert with custom image_path
INSERT INTO "public"."brands" ("id", "created_at", "name", "image_path") VALUES 
('1', '2025-02-24 11:41:04.282503+00', 'AVM Music', 'https://static.vecteezy.com/system/resources/thumbnails/006/137/360/small_2x/painter-paint-the-wall-free-vector.jpg'), 
('2', '2025-02-24 11:41:21.012703+00', 'Think Music', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkfzjwHX_XSZ_3JUaSxRDQ4hLN3AvyDbr3bg&s'), 
('3', '2025-02-24 11:41:29.527716+00', 'Sony Music', 'https://www.plumbingbyjake.com/wp-content/uploads/2015/11/VIGILANT-plumber-fixing-a-sink-shutterstock_132523334-e1448389230378.jpg');
```
