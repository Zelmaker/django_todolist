CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

INSERT INTO users (name, email) VALUES ('test 1', 'test1@mail.ru');
INSERT INTO users (name, email) VALUES ('test 2', 'test2@mail.ru');
