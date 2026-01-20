# myReadSphere – Data Schema Documentation

> Source: *Data Schema – readsphere.pdf*

---

## 1. Users

### Table: `users`

| Column       | Type      | Example                                 | Remark                               |
| ------------ | --------- | --------------------------------------- | ------------------------------------ |
| id           | UUID(36)  | d8f1f3cd-dc21-430c-9270-3c25354b4672    | **PK**, Default: `gen_random_uuid()` |
| email        | char(255) | [test@gmail.com](mailto:test@gmail.com) | Unique, blank = false                |
| password     | char(255) | test12345                               | blank = false                        |
| first_name   | char(255) | YI                                      | blank = false                        |
| last_name    | char(255) | FANG HSIEH                              | blank = false                        |
| role         | char(255) | student                                 | e.g. `student`, `teacher`, `admin`   |
| class_id     | UUID(36)  | –                                       | FK → classes.id, blank = true        |
| cefr_level   | char(255) | B1                                      | blank = true                         |
| created_time | DateTime  | 2023-02-13 13:15:30                     | auto_now_add = true                  |

**Notes**

* User data comes primarily from API
* `role` determines system permission
* `cefr_level` used for adaptive reading content

---

## 2. Classes

### Table: `classes`

| Column       | Type      | Example                              | Remark                               |
| ------------ | --------- | ------------------------------------ | ------------------------------------ |
| id           | UUID(36)  | d8f1f3cd-dc21-430c-9270-3c25354b4672 | **PK**, Default: `gen_random_uuid()` |
| class_name   | char(255) | Grade 10 – English A                 | blank = false                        |
| teacher_name | char(255) | Mr. Smith                            | blank = true                         |
| school_name  | char(255) | NTUST                                | blank = true                         |

**Purpose**

* Represents teaching group / classroom
* Used to control accessible books

---

## 3. Books

### Table: `books`

| Column | Type      | Example                              | Remark                               |
| ------ | --------- | ------------------------------------ | ------------------------------------ |
| id     | UUID(36)  | d8f1f3cd-dc21-430c-9270-3c25354b4672 | **PK**, Default: `gen_random_uuid()` |
| title  | char(255) | Oedipus the King                     | blank = false                        |
| author | char(255) | Sophocles                            | blank = false                        |

**Purpose**

* Stores literary works available on platform

---

## 4. Class–Book Access Mapping

### Table: `class_book_access`

| Column   | Type     | Example | Remark                              |
| -------- | -------- | ------- | ----------------------------------- |
| class_id | UUID(36) | –       | **PK (Composite)**, FK → classes.id |
| book_id  | UUID(36) | –       | **PK (Composite)**, FK → books.id   |

**Purpose**

* Many-to-many relationship
* Controls which classes can read which books

---

## 5. Tracking Events

### Table: `tracking_events`

| Column        | Type      | Example                              | Remark                               |
| ------------- | --------- | ------------------------------------ | ------------------------------------ |
| id            | UUID(36)  | d8f1f3cd-dc21-430c-9270-3c25354b4672 | **PK**, Default: `gen_random_uuid()` |
| user_id       | UUID(36)  | –                                    | FK → users.id, Not Null              |
| event_type    | char(255) | page_view, hint_clicked              | blank = false                        |
| meta_tags     | JSONB     | {"book": "Oedipus", "score": 80}     | Stores analyzable attributes         |
| log_reference | char(255) | /logs/user_123/chat.jsonl            | Optional JSONL path for long logs    |
| created_time  | DateTime  | 2023-02-13 13:15:30                  | auto_now_add = true                  |

**Design Notes**

* `meta_tags` supports indexed query
* `log_reference` used for AI dialogue or long text storage

---

## Overall Relationship Summary

```
users
  └── class_id → classes.id

classes
  └── class_book_access.class_id

books
  └── class_book_access.book_id

users
  └── tracking_events.user_id
```

---

## System Usage Context

* **Auth / Identity**: users
* **Permission Boundary**: classes + class_book_access
* **Content Source**: books
* **Learning Analytics / Behavior Tracking**: tracking_events
* **Adaptive Reading Logic**: users.cefr_level

---

*Generated as Markdown for direct documentation / GitHub README usage.*
