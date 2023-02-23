CREATE TABLE public.etfs (
  id INT8 NOT NULL DEFAULT unique_rowid(),
  name VARCHAR NOT NULL,
  isin VARCHAR NOT NULL,
  last_hash VARCHAR NULL,
  "time" TIMESTAMP NULL DEFAULT now():::TIMESTAMP,
  stock_list STRING NULL,
  CONSTRAINT etfs_pkey PRIMARY KEY (id ASC)
)