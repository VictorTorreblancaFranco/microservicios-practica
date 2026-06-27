CREATE TABLE IF NOT EXISTS pedidos (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL,
  quantity INTEGER NOT NULL,
  total NUMERIC(10, 2),
  price NUMERIC(10, 2),
  status VARCHAR(30),
  fecha TIMESTAMP
);
