/* This is the SQL used to create the database DNZO uses. */

CREATE TABLE task_lists (
  'key' INTEGER PRIMARY KEY,
  'remote_key' TEXT,
  'name' TEXT
);

CREATE TABLE tasks (
  'key' INTEGER PRIMARY KEY,
  'remote_key' TEXT,
  'task_list_id' NUMERIC,
  'archived' NUMERIC,
  'body' TEXT,
  'contexts' TEXT,
  'project' TEXT,
  'due' NUMERIC
);