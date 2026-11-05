<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Update mode comes either from GET ?action=edit (person attribute) or from a
     failed update POST (id parameter re-submitted with the form). --%>
<c:set var="update" value="${not empty person or not empty param.id}" />
<%-- Re-display the submitted values after a validation error. --%>
<c:set var="formId" value="${not empty param.id ? param.id : person.id}" />
<c:set var="formNom" value="${not empty param.nom ? param.nom : person.nom}" />
<c:set var="formPrenom" value="${not empty param.prenom ? param.prenom : person.prenom}" />
<c:set var="formAge" value="${not empty param.age ? param.age : person.age}" />
<c:url var="formAction" value="/inscription" />
<c:url var="listUrl" value="/inscription" />
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
	.error { padding: .75rem; background: #fdecec; border: 1px solid #c88; color: #900; }
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

	<c:if test="${not empty message}">
		<p class="message"><c:out value="${message}" /></p>
	</c:if>
	<c:if test="${not empty error}">
		<p class="error"><c:out value="${error}" /></p>
	</c:if>

	<section>
		<h2><c:choose><c:when test="${update}">Modifier l'utilisateur n° <c:out value="${formId}" /></c:when><c:otherwise>Ajouter un utilisateur</c:otherwise></c:choose></h2>
		<form method="post" action="${fn:escapeXml(formAction)}">
			<input type="hidden" name="action" value="${update ? 'update' : 'create'}">
			<c:if test="${update}">
				<input type="hidden" name="id" value="${fn:escapeXml(formId)}">
			</c:if>
			<table class="form">
				<tr>
					<th><label for="nom">Nom :</label></th>
					<td><input type="text" id="nom" name="nom"
						value="${fn:escapeXml(formNom)}"></td>
				</tr>
				<tr>
					<th><label for="prenom">Prénom :</label></th>
					<td><input type="text" id="prenom" name="prenom"
						value="${fn:escapeXml(formPrenom)}"></td>
				</tr>
				<tr>
					<th><label for="age">Âge :</label></th>
					<td><input type="text" id="age" name="age" inputmode="numeric"
						value="${fn:escapeXml(formAge)}"></td>
				</tr>
			</table>
			<input type="submit" value="${update ? 'Enregistrer' : 'Ajouter'}">
			<c:if test="${update}">
				<a class="cancel" href="${fn:escapeXml(listUrl)}">Annuler</a>
			</c:if>
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
				<c:choose>
					<c:when test="${empty people}">
						<tr><td colspan="5">Aucun utilisateur enregistré.</td></tr>
					</c:when>
					<c:otherwise>
						<c:forEach var="person" items="${people}">
							<c:url var="editUrl" value="/inscription">
								<c:param name="action" value="edit" />
								<c:param name="id" value="${person.id}" />
							</c:url>
							<tr>
								<td><c:out value="${person.id}" /></td>
								<td><c:out value="${person.nom}" /></td>
								<td><c:out value="${person.prenom}" /></td>
								<td><c:out value="${person.age}" /></td>
								<td class="actions">
									<a href="${fn:escapeXml(editUrl)}">Modifier</a>
									<form method="post" action="${fn:escapeXml(formAction)}"
										onsubmit="return confirm('Supprimer cet utilisateur ?');">
										<input type="hidden" name="action" value="delete">
										<input type="hidden" name="id" value="${person.id}">
										<button type="submit" class="danger">Supprimer</button>
									</form>
								</td>
							</tr>
						</c:forEach>
					</c:otherwise>
				</c:choose>
			</tbody>
		</table>
		<p><a href="${fn:escapeXml(listUrl)}">Actualiser</a></p>
	</section>
</main>
</body>
</html>
