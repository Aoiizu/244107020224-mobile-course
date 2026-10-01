# Assignment

## Why must the note list not be stored in SharedPreferences? What breaks if this rule is violated?

### SharedPreferences is for small primitive values. Storing the notes as one JSON string means rewriting the whole list on every change, with no real querying, sorting, or per-row dirty flag. It gets slow and fragile, and sync breaks. Collections belong in SQLite.

## When is cache-first enough, and when do you need another strategy (e.g. network-first for real-time prices)?

### Cache-first is enough when data changes slowly and slightly old data is fine, like posts or notes. For live data like prices, use network-first or streams so users never see stale values.

## How does a dirty flag become a sync queue without blocking the UI? When does a separate queue (outbox table) become necessary?

### Local writes set `dirty = 1` and return immediately. Then `syncNotes` uploads the dirty rows in the background and clears the flag only on success. An outbox table is needed when operation order or retries matter (create, edit, delete of the same note), because one flag can't record what happened.

## Which part of the AI recommendation did you reject, and why?

### I rejected any suggestion to keep the note list in SharedPreferences, because it is fragile for collections and can't support a dirty flag or `updated_at` for sync. I also didn't accept the AI's boilerplate and "real-time" claims as given. I checked them after installing the packages and chose SharedPreferences for settings plus sqflite for notes, since a notes app needs queries and sync columns more than reactive streams.

![alt text](image-22.png)