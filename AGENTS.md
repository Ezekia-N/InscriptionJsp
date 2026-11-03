# AGENTS.md

## Project

Eclipse **Dynamic Web Project** (JSP/Servlet) deployed on Tomcat 10.1 at context path `/Inscription`. There is no Maven/Gradle/npm build, test suite, linter, or CI. Build configuration lives in `.classpath`, `.project`, and `.settings/`; do not introduce a `pom.xml`/`build.gradle` or assume `mvn test` works.

## Layout and entrypoints

- `src/main/java/com/java/Inscription.java` — the only servlet, mapped to `/inscription`. It implements the CRUD routes:
  - `GET /inscription` — list users.
  - `GET /inscription?action=edit&id=N` — prefill the edit form.
  - `POST /inscription` with `action=create|update|delete` — mutate, then redirect with `?result=...` (POST/Redirect/GET).
- `src/main/java/com/java/PersonDAO.java` — all JDBC access; CRUD statements against `UserInfo`.
- `src/main/java/com/java/Person.java` — model and server-side validation (name lengths, age 0–100).
- `src/main/java/com/java/PersonException.java` — checked application exception for validation and "user not found" errors.
- `src/main/webapp/index.jsp` — web root and only JSP; renders the list plus the create/edit form. Uses JSP scriptlets because no JSTL dependency is present.
- `src/main/webapp/WEB-INF/lib/mariadb-java-client-3.5.9.jar` — JDBC driver is checked in. Dependencies are added as jars here; there is no dependency manager.
- `build/classes/` — Eclipse compiler output. Never hand-edit it. Eclipse republishes to `../.metadata/.plugins/org.eclipse.wst.server.core/tmp0/wtpwebapps/Inscription`; edit only the repo source, not the deployed copy.

## Build and run

Use Eclipse with the configured **Tomcat v10.1** runtime and **Java 25** facet. The app URL is `http://localhost:8080/Inscription/`.

The system default `javac` is Java 17, so it does not match the project's Java 25 target. For a disposable CLI syntax check, use JDK 27 and Tomcat 10's servlet API:

```sh
/usr/lib/jvm/java-27-openjdk/bin/javac --release 25 -encoding UTF-8 \
  -cp "/usr/share/java/tomcat10/servlet-api.jar:src/main/webapp/WEB-INF/lib/mariadb-java-client-3.5.9.jar" \
  -d /tmp/opencode/inscription-classes \
  $(find src/main/java -name '*.java')
```

This is Servlet 6 (`jakarta.servlet.*`), not `javax.servlet`. Do not use the Tomcat 9 / Java EE APIs.

## Database

Local MariaDB database `utilisateurs` is used. The JDBC URL and credentials are hardcoded in `PersonDAO`. The table is `UserInfo(id, nom, prenom, age)`.

`PersonDAO.getConnection()` must call `Class.forName("org.mariadb.jdbc.Driver")` explicitly: the driver is loaded from `WEB-INF/lib`, and without this Tomcat fails with `No suitable driver found`. Keep the SQL columns aligned with the schema (`nom`, `prenom`, `age`), not the old `username` field.
