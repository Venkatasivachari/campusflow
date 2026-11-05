-- ==============================================================================
-- V5: Root Owner Singleton Control & Ownership Audit History
-- Strictly enforces exactly ONE active Root Owner in the institutional database
-- ==============================================================================

CREATE TABLE IF NOT EXISTS root_owner_control (
    singleton_id TINYINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1),
    user_id BIGINT NOT NULL UNIQUE,
    owner_id VARCHAR(50) NOT NULL UNIQUE,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_root_owner_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ownership_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    previous_owner_id VARCHAR(50) NULL,
    new_owner_id VARCHAR(50) NOT NULL,
    transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by VARCHAR(50) NOT NULL,
    transfer_reason TEXT,
    ip_address VARCHAR(45) NULL
) ENGINE=InnoDB;

-- Seed the initial Root Owner singleton record
INSERT INTO root_owner_control (singleton_id, user_id, owner_id)
SELECT 1, u.id, 'OWN0001'
FROM users u
WHERE u.email = 'owner@college.local'
ON DUPLICATE KEY UPDATE owner_id = 'OWN0001';

-- Record initial foundation into audit trail if not already logged
INSERT INTO ownership_history (previous_owner_id, new_owner_id, approved_by, transfer_reason)
SELECT 'NONE', 'OWN0001', 'SYSTEM_INIT', 'Initial Institution Foundation and Appointment of Dr. Rajeshwar Rao'
WHERE NOT EXISTS (SELECT 1 FROM ownership_history WHERE new_owner_id = 'OWN0001');

