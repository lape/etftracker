CREATE TABLE "public"."etfs" (
    "id" int8 NOT NULL DEFAULT unique_rowid(),
    "name" varchar NOT NULL,
    "isin" varchar NOT NULL,
    "last_hash" varchar,
    "time" timestamp DEFAULT now(),
    "stock_list" text,
    "active" bool DEFAULT true,
    "fund_type" varchar DEFAULT 'etf',
    PRIMARY KEY ("id")
);

