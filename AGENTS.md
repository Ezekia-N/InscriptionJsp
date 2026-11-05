# AGENTS.md

## Project

Eclipse **Dynamic Web Project** (JSP/Servlet) deployed on Tomcat 10.1 at context path `/Inscription`. There is no Maven/Gradle/npm build, test suite, linter, or CI — do not introduce a `pom.xml`/`build.gradle` or assume `mvn test` works. Build configuration lives in `.classpath`, `.project`, and `.settings/`.

- Java **25** facet, servlet facet **6.0** → `jakarta.servlet.*`, never `javax.servlet.*` or Tomcat 9 / Java EE APIs.
- No `web.xml`: the servlet is mapped with `@WebServlet("/inscription")` and `index.jsp` is the default welcome page. Add servlets/filters via annotations too.

## Layout and entrypoints

- `src/main/java/com/java/Inscription.java` — the only servlet, mapped to `/inscription`. CRUD routes:
  - `GET /inscription` — list users (forwards to `/index.jsp`).
  - `GET /inscription?action=edit&id=N` — prefill the edit form.
  - `POST /inscription` with `action=create|update|delete` — mutate, then redirect to `?result=...` (POST/Redirect/GET). On error it forwards to the JSP instead of redirecting, so a refresh re-submits the POST.
  - `showList(request, response, message, error)` sets `message` (success) and `error` (exception text) as separate request attributes; the JSP styles them differently.
- `src/main/java/com/java/PersonDAO.java` — all JDBC access to `UserInfo`. One `static` instance is shared by every request and holds no fields: **do not add per-request instance fields** (thread safety).
- `src/main/java/com/java/Person.java` — model; validation is inside the setters/constructor and throws `PersonException` (nom ≤ 20, prenom ≤ 10, age 0–100, names trimmed, blank rejected).
- `src/main/java/com/java/PersonException.java` — checked exception for validation and "user not found".
- `src/main/webapp/index.jsp` — web root and only JSP; renders the list plus the create/edit form with JSTL, no scriptlets (`<c:out>`, `<c:forEach>`, `<c:url>`, `fn:escapeXml`). Taglib URIs are `jakarta.tags.core` / `jakarta.tags.functions` — the old `http://java.sun.com/jsp/jstl/core` URIs do not work with JSTL 3.
- `src/main/webapp/WEB-INF/lib/` — dependencies are committed as jars (`mariadb-java-client`, `jakarta.servlet.jsp.jstl` impl, `jakarta.servlet.jsp.jstl-api`); there is no dependency manager.
- The form deliberately has **no client-side validation** (`required`, `min`/`max`, `maxlength` are absent) so that invalid input reaches `Person` and its `PersonException` messages are the single source of validation truth. After a failed POST the form re-renders from `param.*` so entered values survive.
- `build/classes/` — Eclipse compiler output, never hand-edit. Eclipse republishes to `../.metadata/.plugins/org.eclipse.wst.server.core/tmp0/wtpwebapps/Inscription`; edit repo source, not the deployed copy.

## Build and run

Run/deploy from Eclipse with the configured **Tomcat v10.1** runtime; app URL is `http://localhost:8080/Inscription/`.

The system default `javac` is Java 17 and does not match the Java 25 target. For a disposable type-check, use JDK 27 and Tomcat 10's servlet API:

```sh
/usr/lib/jvm/java-27-openjdk/bin/javac --release 25 -encoding UTF-8 \
  -cp "/usr/share/java/tomcat10/servlet-api.jar:src/main/webapp/WEB-INF/lib/mariadb-java-client-3.5.9.jar" \
  -d /tmp/opencode/inscription-classes \
  $(find src/main/java -name '*.java')
```

This compiles only; it does not deploy or exercise the JSP, so JSTL/JSP errors need a real Tomcat run.

Running Tomcat outside Eclipse is awkward here: the WTP `conf/server.xml` copied into the workspace contains hardcoded `<Context docBase=".../wtpwebapps/Inscription">` entries, so a manual Tomcat serves Eclipse's published copy (and stale JSPs) instead of the repo. Remove those `Context` elements or deploy the repo's `src/main/webapp` plus `build/classes` yourself.

## Database

Local MariaDB database `utilisateurs`, table `UserInfo(id, nom, prenom, age)`. Credentials are hardcoded in `PersonDAO` (`ezekia`/`ezekia`) — no datasource, env var, or config file. A connection is opened and closed per statement; there is no pool.

- `PersonDAO.getConnection()` must keep the explicit `Class.forName("org.mariadb.jdbc.Driver")`: the driver is loaded from `WEB-INF/lib`, and without it Tomcat fails with `No suitable driver found`.
- Keep SQL columns aligned with the schema (`nom`, `prenom`, `age`), not the old `username` field.
- The schema enforces `varchar(20)` / `varchar(10)` on `nom`/`prenom`, matching the limits in `Person`; widening a limit needs an `ALTER TABLE` too.
- User-facing strings (messages, labels) are French — keep new ones consistent.
