-- myReadSphere Database Schema Initialization Script
-- Generated from: Readsphere_Data_Schema.md

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==================================================
-- 1. Users Table
-- ==================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    class_id UUID,
    cefr_level VARCHAR(255),
    created_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_class_id ON users(class_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_cefr_level ON users(cefr_level);

-- ==================================================
-- 2. Classes Table
-- ==================================================
CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_name VARCHAR(255) NOT NULL,
    teacher_name VARCHAR(255),
    school_name VARCHAR(255)
);

-- Indexes for classes table
CREATE INDEX idx_classes_name ON classes(class_name);
CREATE INDEX idx_classes_school ON classes(school_name);

-- ==================================================
-- 3. Books Table
-- ==================================================
CREATE TABLE IF NOT EXISTS books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL
);

-- Indexes for books table
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);

-- ==================================================
-- 4. Class-Book Access Mapping Table
-- ==================================================
CREATE TABLE IF NOT EXISTS class_book_access (
    class_id UUID NOT NULL,
    book_id UUID NOT NULL,
    PRIMARY KEY (class_id, book_id),
    CONSTRAINT fk_class_book_access_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_book_access_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- Indexes for class_book_access table
CREATE INDEX idx_class_book_access_class ON class_book_access(class_id);
CREATE INDEX idx_class_book_access_book ON class_book_access(book_id);

-- ==================================================
-- 5. Tracking Events Table
-- ==================================================
CREATE TABLE IF NOT EXISTS tracking_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    meta_tags JSONB,
    log_reference VARCHAR(255),
    created_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tracking_events_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for tracking_events table
CREATE INDEX idx_tracking_events_user ON tracking_events(user_id);
CREATE INDEX idx_tracking_events_type ON tracking_events(event_type);
CREATE INDEX idx_tracking_events_created ON tracking_events(created_time);
CREATE INDEX idx_tracking_events_meta_tags ON tracking_events USING GIN (meta_tags);

-- ==================================================
-- 6. Active Sessions Table (NEW in v2)
-- ==================================================
CREATE TABLE IF NOT EXISTS active_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    content_type VARCHAR(255) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    last_active_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_seconds INTEGER,
    data_key VARCHAR(255),
    created_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_active_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for active_sessions table
CREATE INDEX idx_active_sessions_user ON active_sessions(user_id);
CREATE INDEX idx_active_sessions_content_type ON active_sessions(content_type);
CREATE INDEX idx_active_sessions_start_time ON active_sessions(start_time);
CREATE INDEX idx_active_sessions_last_active ON active_sessions(last_active_time);

-- ==================================================
-- Foreign Key Constraints for Users Table
-- ==================================================
ALTER TABLE users
    ADD CONSTRAINT fk_users_class 
    FOREIGN KEY (class_id) 
    REFERENCES classes(id) 
    ON DELETE SET NULL;

-- ==================================================
-- Insert Sample Data (Optional - for testing)
-- ==================================================

-- Sample Classes
INSERT INTO classes (id, class_name, teacher_name, school_name) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Grade 10 - English A', 'Mr. Smith', 'NTUST'),
    ('22222222-2222-2222-2222-222222222222', 'Grade 11 - Literature B', 'Ms. Johnson', 'NTUST')
ON CONFLICT (id) DO NOTHING;

-- Sample Books
INSERT INTO books (id, title, author) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Oedipus the King', 'Sophocles'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'The Odyssey', 'Homer'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'The Iliad', 'Homer')
ON CONFLICT (id) DO NOTHING;

-- Sample Class-Book Access
INSERT INTO class_book_access (class_id, book_id) VALUES
    ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    ('11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
    ('22222222-2222-2222-2222-222222222222', 'cccccccc-cccc-cccc-cccc-cccccccccccc')
ON CONFLICT (class_id, book_id) DO NOTHING;

-- Sample Users (password: test12345 - bcrypt hashed)
INSERT INTO users (id, email, password, first_name, last_name, role, class_id, cefr_level) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'test@gmail.com', '$2a$10$kikI1Z53iIyDhQTTUgw5xuGEbak5wNDWB7QPM3KIJDtvPI70TdumK', 'YI', 'FANG HSIEH', 'student', '11111111-1111-1111-1111-111111111111', 'B1'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'teacher@gmail.com', '$2a$10$kikI1Z53iIyDhQTTUgw5xuGEbak5wNDWB7QPM3KIJDtvPI70TdumK', 'John', 'Smith', 'teacher', NULL, NULL),
    ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'admin@gmail.com', '$2a$10$kikI1Z53iIyDhQTTUgw5xuGEbak5wNDWB7QPM3KIJDtvPI70TdumK', 'Admin', 'User', 'admin', NULL, NULL)
ON CONFLICT (email) DO NOTHING;

-- Sample Tracking Events
INSERT INTO tracking_events (user_id, event_type, meta_tags, log_reference) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'page_view', '{"book": "Oedipus", "page": 1}', NULL),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'hint_clicked', '{"book": "Oedipus", "score": 80, "chapter": 3}', NULL)
ON CONFLICT DO NOTHING;

-- ==================================================
-- Grant Permissions
-- ==================================================
-- Grant all privileges on tables to the database user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO CURRENT_USER;

-- ==================================================
-- Database Setup Complete
-- ==================================================
SELECT 'Database schema initialized successfully!' AS status;
