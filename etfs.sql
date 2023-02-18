-- -------------------------------------------------------------
-- TablePlus 5.3.2(490)
--
-- https://tableplus.com/
--
-- Database: shared
-- Generation Time: 2023-02-18 12:04:08.3500
-- -------------------------------------------------------------


-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."etfs" (
    "id" int8 NOT NULL DEFAULT unique_rowid(),
    "name" varchar NOT NULL,
    "isin" varchar NOT NULL,
    "last_hash" varchar,
    "time" timestamp DEFAULT now():::TIMESTAMP,
    "stock_list" text,
    PRIMARY KEY ("id")
);

