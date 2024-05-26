-- Represents user information
CREATE TABLE `user` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT, -- Unique identifier for the user
  `username` varchar(64) DEFAULT null, -- Username of the user
);

-- Represent each payday
CREATE TABLE `payday` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT, -- Unique identifier for the user
  `user_id` int NOT NULL, -- ID of the user to whom the payday belongs
  `payday_date` datetime NOT NULL, -- Date of payday
  `amount` decimal(15, 2) DEFAULT null, -- Total earned money for the month
  `note` varchar(255) DEFAULT null, -- Additional notes
  CONSTRAINT `fk_payday_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

-- Represent a monthly expenses event (every payday)
CREATE TABLE `monthly_expenses` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT,  -- Unique identifier for the user
  `payday_id` int NOT NULL, -- ID of the payday
  `start_date` datetime NOT NULL, -- Start expenses's period
  `end_date` datetime NOT NULL, -- End expenses's period
  `utilities` decimal(15, 2) DEFAULT null, -- Utilities expenses for the month
  `groceries` decimal(15, 2) DEFAULT null, -- Groceries expenses for the month
  `misc` decimal(15, 2) DEFAULT null, -- Miscellaneous expenses for the month
  `amount` decimal(15, 2) DEFAULT null, -- Total money spent for the month
  `note` varchar(255) DEFAULT null, -- Additional notes
  CONSTRAINT `fk_monthly_expenses_payday_id` FOREIGN KEY (`payday_id`) REFERENCES `payday` (`id`)
);

-- Represents a broker 
CREATE TABLE `broker` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT, -- Unique identifier for the broker
  `user_id` int NOT NULL, -- ID of the user
  `name` varchar(64) NOT NULL, -- Name of the broker
  `amount` decimal(15, 2) DEFAULT null, -- Total invested at the given date
  `latest_update` datetime DEFAULT null, -- Date of the latest update
  `note` varchar(255) DEFAULT null, -- Additional notes
  CONSTRAINT `fk_broker_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

-- Represents a bank
CREATE TABLE `bank` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT, -- Unique identifier for the bank
  `user_id` int NOT NULL, -- ID of the user
  `name` varchar(64) NOT NULL, -- Name of the bank
  `amount` decimal(15, 2) DEFAULT null, -- Amount saved at the given date
  `latest_update` datetime DEFAULT null, -- Date of the latest update
  `note` varchar(255) DEFAULT null, -- Additional notes
  CONSTRAINT `fk_bank_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

-- Represents a pension provider
CREATE TABLE `pension` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT, -- Unique identifier for the savings record
  `user_id` int NOT NULL, -- ID of the user
  `name` varchar(64) NOT NULL, -- Name of the pension provider
  `amount` decimal(15, 2) DEFAULT null, -- Total pension at the given date
  `latest_update` datetime DEFAULT null, -- Date of the latest update
  `note` varchar(255) DEFAULT null, -- Additional notes
  CONSTRAINT `fk_pension_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

-- Represents net worth over time
CREATE TABLE `net_worth` (
  `id` int PRIMARY KEY NOT NULL AUTO_INCREMENT, -- Unique identifier for the savings record
  `user_id` int NOT NULL, -- ID of the user
  `payday_id` int NOT NULL, -- ID of the payday
  `date` datetime NOT NULL, -- Date of the net worth record
  `total_savings` decimal(15, 2) DEFAULT null, -- Total savings at the given date
  `total_investments` decimal(15, 2) DEFAULT null, -- Total investments at the given date
  `total_pension` decimal(15, 2) DEFAULT null, -- Total pension at the given date
  `net_worth` decimal(15, 2) DEFAULT null, -- Total net worth at the given date
  `note` varchar(255) DEFAULT null, -- Additional notes
  CONSTRAINT `fk_net_worth_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `fk_net_worth_payday_id` FOREIGN KEY (`payday_id`) REFERENCES `payday` (`id`)
);

--- TRIGGERS

-- Trigger to automatically update the amount field when inserting or updating on monthly_expenses table
CREATE TRIGGER update_monthly_expenses_amount
BEFORE INSERT OR UPDATE ON monthly_expenses
FOR EACH ROW
BEGIN
    SET NEW.amount = NEW.utilities + NEW.groceries + NEW.misc;
END;

-- UPDATE latest_update
-- Trigger to automatically set latest_update to current time on broker table
CREATE TRIGGER update_broker_latest_update
BEFORE INSERT OR UPDATE ON broker
FOR EACH ROW
BEGIN
    SET NEW.latest_update = CURRENT_TIMESTAMP;
END;

-- Trigger to automatically set latest_update to current time on bank table
CREATE TRIGGER update_bank_latest_update
BEFORE INSERT OR UPDATE ON bank
FOR EACH ROW
BEGIN
    SET NEW.latest_update = CURRENT_TIMESTAMP;
END;

-- Trigger to automatically set latest_update to current time on pension table
CREATE TRIGGER update_pension_latest_update
BEFORE INSERT OR UPDATE ON pension
FOR EACH ROW
BEGIN
    SET NEW.latest_update = CURRENT_TIMESTAMP;
END;
--

-- Change the delimiter to //
DELIMITER //

CREATE TRIGGER update_net_worth_after_savings
AFTER INSERT OR UPDATE ON savings
FOR EACH ROW
BEGIN
  DECLARE total_savings DECIMAL(15, 2);

  -- Calculate the total savings
  SET total_savings = (SELECT SUM(amount) FROM savings WHERE user_id = NEW.user_id);

-- Change the delimiter back to ;
DELIMITER ;