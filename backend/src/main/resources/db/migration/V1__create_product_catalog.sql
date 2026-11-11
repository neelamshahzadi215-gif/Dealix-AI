
-- =========================================
-- DEALIX AI: V1 Product Catalog Schema
-- MySQL 8+
-- =========================================

CREATE TABLE categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL,
    description VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    UNIQUE KEY uk_categories_slug (slug)
);

CREATE TABLE stores (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(160) NOT NULL,
    website_url VARCHAR(2048),
    logo_url VARCHAR(2048),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    UNIQUE KEY uk_stores_slug (slug)
);

CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT UNSIGNED,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(150),
    model VARCHAR(150),
    barcode VARCHAR(64),
    description TEXT,
    image_url VARCHAR(2048),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE SET NULL,

    INDEX idx_products_category (category_id),
    INDEX idx_products_brand_model (brand, model),
    INDEX idx_products_barcode (barcode),
    INDEX idx_products_status (status)
);

CREATE TABLE product_offers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    store_id BIGINT UNSIGNED NOT NULL,

    external_listing_id VARCHAR(191),
    listing_title VARCHAR(500) NOT NULL,
    seller_name VARCHAR(200),
    listing_url VARCHAR(2048) NOT NULL,
    normalized_url_hash BINARY(32),

    price DECIMAL(12,2) NOT NULL,
    shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'PKR',

    availability VARCHAR(30) NOT NULL DEFAULT 'UNKNOWN',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    first_seen_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    last_seen_at DATETIME(6),
    last_checked_at DATETIME(6),

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_offers_product
        FOREIGN KEY (product_id)
        REFERENCES products(id),

    CONSTRAINT fk_offers_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id),

    CONSTRAINT uk_offer_url_hash
        UNIQUE (store_id, normalized_url_hash),

    CONSTRAINT uk_offer_external_id
        UNIQUE (store_id, external_listing_id),

    CONSTRAINT chk_offer_price CHECK (price >= 0),
    CONSTRAINT chk_offer_shipping CHECK (shipping_cost >= 0),

    INDEX idx_offers_product (product_id),
    INDEX idx_offers_store (store_id),
    INDEX idx_offers_price (product_id, status, price),
    INDEX idx_offers_checked (last_checked_at)
);

CREATE TABLE price_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    offer_id BIGINT UNSIGNED NOT NULL,

    price DECIMAL(12,2) NOT NULL,
    shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'PKR',

    recorded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_price_history_offer
        FOREIGN KEY (offer_id)
        REFERENCES product_offers(id),

    CONSTRAINT chk_history_price CHECK (price >= 0),
    CONSTRAINT chk_history_shipping CHECK (shipping_cost >= 0),

    INDEX idx_history_offer_time (offer_id, recorded_at)
);
