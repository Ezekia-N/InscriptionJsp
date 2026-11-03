package com.java;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/inscription")
public class Inscription extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private static final PersonDAO PERSON_DAO = new PersonDAO();

	public Inscription()
	{
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		String message = messageForResult(request.getParameter("result"));

		if ("edit".equals(request.getParameter("action")))
		{
			try
			{
				Person person = PERSON_DAO.findById(parseId(request.getParameter("id")));

				if (person == null)
				{
					message = "Utilisateur introuvable.";
				}
				else
				{
					request.setAttribute("person", person);
				}
			}
			catch (PersonException | SQLException e)
			{
				message = "Erreur : " + e.getMessage();
			}
		}

		showList(request, response, message);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		request.setCharacterEncoding("UTF-8");
		String action = request.getParameter("action");

		try
		{
			String result;

			if ("delete".equals(action))
			{
				PERSON_DAO.delete(parseId(request.getParameter("id")));
				result = "deleted";
			}
			else if ("update".equals(action))
			{
				Person person = readPerson(request);
				person.setId(parseId(request.getParameter("id")));
				PERSON_DAO.update(person);
				result = "updated";
			}
			else
			{
				PERSON_DAO.insert(readPerson(request));
				result = "created";
			}

			response.sendRedirect(request.getContextPath() + "/inscription?result=" + result);
		}
		catch (PersonException | SQLException e)
		{
			showList(request, response, "Erreur : " + e.getMessage());
		}
	}

	private Person readPerson(HttpServletRequest request) throws PersonException
	{
		int age;

		try
		{
			age = Integer.parseInt(request.getParameter("age"));
		}
		catch (NumberFormatException e)
		{
			throw new PersonException("L'âge doit être un nombre valide.");
		}

		Person person = new Person();
		person.setNom(request.getParameter("nom"));
		person.setPrenom(request.getParameter("prenom"));
		person.setAge(age);
		return person;
	}

	private int parseId(String value) throws PersonException
	{
		try
		{
			return Integer.parseInt(value);
		}
		catch (NumberFormatException e)
		{
			throw new PersonException("Identifiant invalide.");
		}
	}

	private String messageForResult(String result)
	{
		if ("created".equals(result))
		{
			return "Utilisateur ajouté.";
		}
		if ("updated".equals(result))
		{
			return "Utilisateur modifié.";
		}
		if ("deleted".equals(result))
		{
			return "Utilisateur supprimé.";
		}
		return null;
	}

	private void showList(HttpServletRequest request, HttpServletResponse response, String message)
		throws ServletException, IOException
	{
		String error = null;

		try
		{
			request.setAttribute("people", PERSON_DAO.findAll());
		}
		catch (SQLException | PersonException e)
		{
			error = "Impossible de charger les utilisateurs : " + e.getMessage();
		}

		if (error != null)
		{
			message = message == null ? error : message + " " + error;
		}

		if (message != null)
		{
			request.setAttribute("message", message);
		}

		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
}
