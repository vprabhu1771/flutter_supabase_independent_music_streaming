```
CREATE TABLE playlist_songs (
    id SERIAL PRIMARY KEY,
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    UNIQUE (playlist_id, song_id)  -- Prevent duplicate song entries in the same playlist
)
```
