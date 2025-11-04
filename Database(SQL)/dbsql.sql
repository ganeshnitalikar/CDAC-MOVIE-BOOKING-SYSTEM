-- =====================================
-- MOVIE TICKET BOOKING SYSTEM (MVP SCHEMA)
-- =====================================


-- ======================
-- Creating database
-- ======================
CREATE DATABASE PROJECT_CDAC;

-- ======================
-- Use created database
-- ======================

USE PROJECT_CDAC;


-- ======================
-- 1. Roles Table
-- ======================
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100)
);

-- ======================
-- 2. Users Table
-- ======================
CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT,
    status ENUM('active','inactive','blocked') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- ======================
-- 3. Cities Table
-- ======================
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100),
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100)
);

-- ======================
-- 4. Theaters Table
-- ======================
CREATE TABLE theaters (
    theater_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city_id INT,
    address VARCHAR(255),
    total_screens INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_theaters_city FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- ======================
-- 5. Screens Table
-- ======================
CREATE TABLE screens (
    screen_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    theater_id BIGINT,
    screen_name VARCHAR(50),
    seat_capacity INT,
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_screens_theater FOREIGN KEY (theater_id) REFERENCES theaters(theater_id)
);

-- ======================
-- 6. Seats Table
-- ======================
CREATE TABLE seats (
    seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    screen_id BIGINT,
    seat_number VARCHAR(10) NOT NULL,
    seat_type ENUM('Regular','Premium','VIP'),
    row_no VARCHAR(5),
    is_active BOOLEAN DEFAULT TRUE,
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_seats_screen FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
);

-- ======================
-- 7. Movies Table
-- ======================
CREATE TABLE movies (
    movie_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    duration_mins INT,
    release_date DATE,
    language VARCHAR(50),
    genre VARCHAR(100),
    rating DECIMAL(2,1),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100)
);

-- ======================
-- 8. Shows Table
-- ======================
CREATE TABLE shows (
    show_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT,
    screen_id BIGINT,
    show_time DATETIME,
    price DECIMAL(10,2),
    status ENUM('scheduled','cancelled','completed') DEFAULT 'scheduled',
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_shows_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    CONSTRAINT fk_shows_screen FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
);

-- ======================
-- 9. Bookings Table
-- ======================
CREATE TABLE bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    show_id BIGINT,
    booking_status ENUM('pending','confirmed','cancelled') DEFAULT 'pending',
    total_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_bookings_show FOREIGN KEY (show_id) REFERENCES shows(show_id)
);

-- ======================
-- 10. Booking Seats Table
-- ======================
CREATE TABLE booking_seats (
    booking_seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT,
    seat_id BIGINT,
    seat_price DECIMAL(10,2),
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_booking_seats_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT fk_booking_seats_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
);

-- ======================
-- 11. Payments Table
-- ======================
CREATE TABLE payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT,
    payment_method VARCHAR(50),
    transaction_ref VARCHAR(255),
    amount DECIMAL(10,2),
    status ENUM('success','failed','pending','refunded') DEFAULT 'pending',
    paid_at TIMESTAMP,
    xtra1 VARCHAR(100),
    xtra2 VARCHAR(100),
    xtra3 VARCHAR(100),
    xtra4 VARCHAR(100),
    xtra5 VARCHAR(100),
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- =====================================
-- VIEWS
-- =====================================

-- View 1: Movies with their shows & screens
CREATE VIEW vw_movie_shows AS
SELECT m.movie_id, m.title, s.show_id, s.show_time, sc.screen_name, t.name AS theater_name, c.city_name
FROM movies m
JOIN shows s ON m.movie_id = s.movie_id
JOIN screens sc ON s.screen_id = sc.screen_id
JOIN theaters t ON sc.theater_id = t.theater_id
JOIN cities c ON t.city_id = c.city_id;

-- View 2: User Bookings with seats & payments
CREATE VIEW vw_user_bookings AS
SELECT u.username, b.booking_id, m.title, s.show_time, st.seat_number, p.status AS payment_status, p.amount
FROM users u
JOIN bookings b ON u.user_id = b.user_id
JOIN shows s ON b.show_id = s.show_id
JOIN movies m ON s.movie_id = m.movie_id
JOIN booking_seats bs ON b.booking_id = bs.booking_id
JOIN seats st ON bs.seat_id = st.seat_id
JOIN payments p ON b.booking_id = p.booking_id;

-- View 3: Revenue per movie
CREATE VIEW vw_revenue_report AS
SELECT 
    m.title, 
    SUM(p.amount) AS total_revenue, 
    COUNT(b.booking_id) AS total_bookings
FROM movies m
JOIN shows s ON m.movie_id = s.movie_id
JOIN bookings b ON s.show_id = b.show_id
JOIN payments p ON b.booking_id = p.booking_id
WHERE p.status = 'success'
GROUP BY m.title;
