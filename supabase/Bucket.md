```
Allow user to manage own images
```

```
((auth.role() = 'authenticated'::text) AND (bucket_id = 'assets'::text) AND (name ~~ 'profile_pictures/%'::text))
```

![Image](Allow%20user%20to%20manage%20own%20images.PNG)

```
Allow Authenticated Users to Upload 1bqp9qb_0
```

```
(bucket_id = 'assets'::text)
```

![Image](Allow%20Authenticated%20Users%20to%20Upload.PNG)

```
Allow Authenticated Users to Update 1bqp9qb_0
```

```
(bucket_id = 'assets'::text)
```

![Image](Allow%20Authenticated%20Users%20to%20Update.PNG)

```
Allow Authenticated Users to Delete 1bqp9qb_0 1bqp9qb_0
```

```
(bucket_id = 'assets'::text)
```

![Image](Allow%20Authenticated%20Users%20to%20Delete.PNG)