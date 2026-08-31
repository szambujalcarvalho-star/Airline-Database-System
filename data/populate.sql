-- Os atributos das tabelas no CSV devem ser os mesmos da tabela aviao no aviacao.sql

-- Populates the aeroporto table
\copy aeroporto FROM '/home/jovyan/data/aeroporto.csv' DELIMITER ',' CSV HEADER

-- Populates the aviao table
\copy aviao FROM '/home/jovyan/data/aviao.csv' DELIMITER ',' CSV HEADER

-- Populates the assento table
\copy assento FROM '/home/jovyan/data/assento.csv' DELIMITER ',' CSV HEADER

-- Populates the voo table
\copy voo FROM '/home/jovyan/data/voo.csv' DELIMITER ',' CSV HEADER

-- Populates the venda table
\copy venda FROM '/home/jovyan/data/venda.csv' DELIMITER ',' CSV HEADER;

-- Corrige a sequência após importação
SELECT setval('venda_codigo_reserva_seq', (SELECT MAX(codigo_reserva) FROM venda));


-- Populates the bilhete table
\copy bilhete FROM '/home/jovyan/data/bilhete.csv' DELIMITER ',' CSV HEADER;

-- Corrige a sequência da tabela bilhete
SELECT setval('bilhete_id_seq', (SELECT MAX(id) FROM bilhete));
