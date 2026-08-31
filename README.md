# Airline Database System

PostgreSQL airline database project developed for the **Databases** course at Instituto Superior Técnico.

**Project Part 2 · Final grade: 17.8/20 · Team of 3**

The project combines database integrity, realistic data population, a Python/Flask REST API, a PostgreSQL materialized view, OLAP-style analytical queries, and index design.

## Project scope

The course provided the initial PostgreSQL schema in `aviacao.sql`. Part 2 required us to build on that schema in five main areas:

1. implement three additional integrity constraints;
2. populate the database with a sufficiently large and consistent airline dataset;
3. develop a RESTful JSON API;
4. build a materialized analytical view and answer four SQL/OLAP questions using it;
5. design indexes for the analytical workload and justify them theoretically and with `EXPLAIN ANALYSE`.

This repository contains the implementation submitted for **Part 2 only**. Part 1, which focused on conceptual/relational modelling and relational algebra, is intentionally not included.

## 1. Database integrity

Three constraints were implemented with PostgreSQL trigger functions written in PL/pgSQL.

### RI-1 — Check-in consistency

When a seat is assigned during check-in:

- the ticket class must match the seat class;
- the seat must belong to the aircraft operating that flight.

### RI-2 — Flight capacity

The number of tickets sold for each class of a flight cannot exceed the number of seats of that class on the assigned aircraft.

### RI-3 — Sale time

A ticket sale must occur before the departure time of the corresponding flight.

The submitted implementations are preserved in [`analysis/E2-report-04.ipynb`](analysis/E2-report-04.ipynb).

## 2. Database population

The assignment required a consistent dataset satisfying, among others, the following coverage requirements:

- at least 10 real European international airports, including at least two cities served by two airports;
- at least 10 aircraft from at least 3 real models, with realistic seating and approximately the first 10% of rows assigned to first class;
- at least 5 flights per day from 1 January through 31 July 2025, covering all airports and aircraft while maintaining return routes and aircraft continuity;
- at least 30,000 tickets across at least 10,000 sales;
- checked-in tickets for completed flights and both classes represented on every flight.

The submitted data is stored as CSV files and loaded with [`data/populate.sql`](data/populate.sql).

## 3. REST API

The application is implemented in Python with Flask and accesses PostgreSQL through `psycopg` and `psycopg-pool`.

| Method | Endpoint | Behaviour |
| --- | --- | --- |
| `GET` | `/` | Lists all airports with name and city |
| `GET` | `/voos/<partida>` | Lists flights leaving the given airport during the next 12 hours |
| `GET` | `/voos/<partida>/<chegada>` | Lists the next three flights between two airports for which tickets are still available |
| `POST` | `/compra/<voo>` | Creates a sale and purchases one or more tickets for a flight |
| `POST` | `/checkin/<bilhete>` | Checks in a ticket and automatically assigns an available seat of the corresponding class |

The application uses parameterized SQL statements, a PostgreSQL connection pool, and explicit transaction handling with commit/rollback.

The submitted application is in [`app/app.py`](app/app.py).

## 4. Materialized flight statistics view

A PostgreSQL materialized view named `estatisticas_voos` combines operational data into a representation suitable for analytics.

It contains:

- aircraft serial number and departure time;
- departure and arrival city/country;
- year, month, day of month and day of week;
- first- and second-class passenger counts;
- first- and second-class seat capacities;
- first- and second-class ticket revenue.

The view is defined in the submitted notebook.

## 5. SQL and OLAP analysis

Using only `estatisticas_voos`, the project addresses four analytical objectives:

### Route demand

Determine the route or routes with the greatest demand during the previous year, treating opposite directions between the same two cities as one route and measuring demand through average aircraft occupancy.

### Fleet coverage

Determine the routes through which every aircraft in the company passed during the previous three months.

### Revenue analysis

Explore total, first-class and second-class sales across simultaneous spatial hierarchies

`global → country → city`

for departure and arrival, and the temporal hierarchy

`global → year → month → day`.

The implementation uses PostgreSQL `GROUPING SETS`/`ROLLUP`-style multidimensional aggregation.

### Weekly passenger-class patterns

Analyse the first-class/second-class passenger ratio by day of week, with geographical drill-down from global to country to city.

## 6. Index design

Three composite indexes were proposed over `estatisticas_voos` to support the collective analytical workload:

- `idx_voos_tempo_rota_aviao`
- `idx_voos_espaco_tempo`
- `idx_voos_semana_espaco`

Their design targets temporal/route/aircraft filtering, spatial-temporal analysis, and weekly geographical analysis respectively.

The original submission includes the theoretical justification and the course requested practical evaluation using `EXPLAIN ANALYSE`.

## Technologies

- PostgreSQL
- SQL
- PL/pgSQL
- Python
- Flask
- psycopg
- psycopg-pool
- Jupyter Notebook
- REST / JSON
- CSV / PostgreSQL `COPY`

## Repository structure

```text
.
├── app/
│   └── app.py
├── analysis/
│   └── E2-report-04.ipynb
├── data/
│   ├── aeroporto.csv
│   ├── assento.csv
│   ├── aviao.csv
│   ├── bilhete.csv
│   ├── venda.csv
│   ├── voo.csv
│   └── populate.sql
├── database/
│   ├── aviacao.sql
│   └── README.md
├── .gitignore
└── README.md
```

## Running the project

### 1. Create the database schema

Run the course-provided base schema:

```bash
psql -d postgres -f database/aviacao.sql
```

### 2. Add the project integrity constraints

The submitted PL/pgSQL trigger functions and triggers are preserved in `analysis/E2-report-04.ipynb`.

They should be executed before loading the populated dataset.

### 3. Load the data

`data/populate.sql` uses PostgreSQL `\copy` commands. In the original course environment, the CSV files were available under:

```text
/home/jovyan/data/
```

If you run the project in a different environment, adjust those paths before executing the script.

### 4. Configure the application

`app/app.py` reads the connection string from `DATABASE_URL`.

Example:

```bash
export DATABASE_URL="postgresql://postgres:postgres@localhost/postgres"
```

If the variable is not set, the original submitted development fallback is:

```text
postgresql://postgres:postgres@postgres/postgres
```

### Original course development environment

The project was developed and evaluated using the course-provided `bdist/db-workspace` development environment. The workspace/Docker configuration was supplied separately by the course and was therefore not part of the student submission preserved in this repository.

This also explains the default database hostname `postgres` used by the submitted application. A standalone clone of this repository does not include the original course workspace configuration; when running it in another environment, configure `DATABASE_URL` for the PostgreSQL instance being used.

### 5. Install the Python dependencies

The application imports:

```text
Flask
psycopg
psycopg-pool
```

Then run:

```bash
python app/app.py
```

## Provenance and authorship

This was a three-person academic project with an equal declared contribution of **33.3% per team member**.

The following distinction is important:

- `app/`, `data/` and `analysis/E2-report-04.ipynb` come from the final student submission;
- `database/aviacao.sql` is the starter schema supplied by the course and is included only to make the database structure reproducible;
- the assignment PDF and blank notebook template supplied by the course are **not redistributed**.

The submitted notebook is retained because it contains a substantial part of the technical implementation: integrity constraints, materialized view, analytical SQL, indexes and their justification.

## Academic note

This repository is intended as an academic portfolio archive of the submitted work. The implementation has been reorganized for repository clarity, but the submitted source code and data have not been rewritten to present a different solution.
