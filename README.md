# SRE Bootcamp

This bootcamp is being worked upon with the intention of gaining production like deployment experience.
Throughout the bootcamp, the goal is to develop and deploy a simple CRUD app using different approaches, and on
different tech(i.e., on prem, using k8s etc.).

## About the application:

- It is a simple CRUD app that works with `Student` records.
- A `Student` currently has `name`, `email`, and `grade`.
- The app supports the following operations on `Student` entity:
    - Creating record
    - Updating record by ID
    - Deleting record by ID
    - Fetching a single record by ID
    - Fetching all existing records

### Requirements:

- Java 21
- Gradle 8.14.3
- Docker

### Running the application:

1. You should have a running local postgres db instance.
2. You can supply the db creds, url in the application-local.yml to run the application locally.
3. You can also optionally choose to set them as env vars(`DB_PASSWORD`, `DB_USERNAME`, `DB_URL`) and then run
   the application.
4. Command to run the app:
   - `SPRING_PROFILES_ACTIVE=local ./gradlew bootRun` in case you set the db creds in application-local.yml
   - `./gradlew bootRun` in case you set the db creds as env vars 