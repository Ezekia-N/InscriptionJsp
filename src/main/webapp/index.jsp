<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.List, com.java.Person" %>
<%!
	private static String escapeHtml(String value)
	{
		if (value == null)
		{
			return "";
		}

		return value.replace("&", "&amp;")
			.replace("<", "&lt;")
			.replace(">", "&gt;")
			.replace("\"", "&quot;")
			.replace("'", "&#39;");
	}
%>
<%
	@SuppressWarnings("unchecked")
	List<Person> people = (List<Person>) request.getAttribute("people");
	Person editing = (Person) request.getAttribute("person");
	String message = (String) request.getAttribute("message");
	String contextPath = request.getContextPath();
	boolean update = editing != null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Gestion des utilisateurs</title>
<style>
	body { font-family: Arial, sans-serif; margin: 2rem; color: #222; }
	main { max-width: 900px; margin: 0 auto; }
	h1 { margin-bottom: 1.5rem; }
	section { margin-bottom: 2rem; }
	table { width: 100%; border-collapse: collapse; }
	th, td { border: 1px solid #ccc; padding: .5rem; text-align: left; }
	thead { background: #f2f2f2; }
	.form th, .form td { border: none; padding: .25rem .5rem; }
	.form th { width: 120px; }
	input[type="text"], input[type="number"] { padding: .35rem; width: 100%; max-width: 300px; }
	.message { padding: .75rem; background: #eef6ee; border: 1px solid #8c8; }
	.actions { white-space: nowrap; }
	.actions form { display: inline; }
	button, input[type="submit"] { padding: .35rem .75rem; cursor: pointer; }
	.danger { color: #a00; }
	.cancel { margin-left: .75rem; }
</style>
</head>
<body>
<main>
	<h1>Gestion des utilisateurs</h1>

	<% if (message != null) { %>
		<p class="message"><%= escapeHtml(message) %></p>
	<% } %>

	<section>
		<h2><%= update ? "Modifier l'utilisateur n°" + editing.getId() : "Ajouter un utilisateur" %></h2>
		<form method="post" action="<%= contextPath %>/inscription">
			<input type="hidden" name="action" value="<%= update ? "update" : "create" %>">
			<% if (update) { %>
				<input type="hidden" name="id" value="<%= editing.getId() %>">
			<% } %>
			<table class="form">
				<tr>
					<th><label for="nom">Nom :</label></th>
					<td><input type="text" id="nom" name="nom" maxlength="20"
						value="<%= escapeHtml(update ? editing.getNom() : "") %>" required></td>
				</tr>
				<tr>
					<th><label for="prenom">Prénom :</label></th>
					<td><input type="text" id="prenom" name="prenom" maxlength="10"
						value="<%= escapeHtml(update ? editing.getPrenom() : "") %>" required></td>
				</tr>
				<tr>
					<th><label for="age">Âge :</label></th>
					<td><input type="number" id="age" name="age" min="0" max="100"
						value="<%= update ? editing.getAge() : "" %>" required></td>
				</tr>
			</table>
			<input type="submit" value="<%= update ? "Enregistrer" : "Ajouter" %>">
			<% if (update) { %>
				<a class="cancel" href="<%= contextPath %>/inscription">Annuler</a>
			<% } %>
		</form>
	</section>

	<section>
		<h2>Liste des utilisateurs</h2>
		<table>
			<thead>
				<tr>
					<th>ID</th>
					<th>Nom</th>
					<th>Prénom</th>
					<th>Âge</th>
					<th>Actions</th>
				</tr>
			</thead>
			<tbody>
				<% if (people == null || people.isEmpty()) { %>
					<tr><td colspan="5">Aucun utilisateur enregistré.</td></tr>
				<% } else { %>
					<% for (Person person : people) { %>
						<tr>
							<td><%= person.getId() %></td>
							<td><%= escapeHtml(person.getNom()) %></td>
							<td><%= escapeHtml(person.getPrenom()) %></td>
							<td><%= person.getAge() %></td>
							<td class="actions">
								<a href="<%= contextPath %>/inscription?action=edit&amp;id=<%= person.getId() %>">Modifier</a>
								<form method="post" action="<%= contextPath %>/inscription"
									onsubmit="return confirm('Supprimer cet utilisateur ?');">
									<input type="hidden" name="action" value="delete">
									<input type="hidden" name="id" value="<%= person.getId() %>">
									<button type="submit" class="danger">Supprimer</button>
								</form>
							</td>
						</tr>
					<% } %>
				<% } %>
			</tbody>
		</table>
		<p><a href="<%= contextPath %>/inscription">Actualiser</a></p>
	</section>
</main>
</body>
</html>
