CREATE TABLE dummy_data (
    id INT,
    name VARCHAR(50),
    age INT
);

INSERT INTO dummy_data (id, name, age)
VALUES (1, 'Berke Poslu', 17),
       (2, 'Fiona Daniela Kusi Waelti', 3),
       (3, 'John Wick', 90);

SELECT * FROM dummy_data;