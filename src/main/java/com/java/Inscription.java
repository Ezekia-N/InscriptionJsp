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
		String error = null;

		if ("edit".equals(request.getParameter("action")))
		{
			try
			{
				Person person = PERSON_DAO.findById(parseId(request.getParameter("id")));

				if (person == null)
				{
					error = "Utilisateur introuvable.";
				}
				else
				{
					request.setAttribute("person", person);
				}
			}
			catch (PersonException | SQLException e)	
			{
				error = e.getMessage();
			}
		}

		showList(request, response, message, error);
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
			showList(request, response, null, e.getMessage());
		}
	}

	private Person readPerson(HttpServletRequest request) throws PersonException
	{
		String ageValue = request.getParameter("age");

		if (ageValue == null || ageValue.trim().isEmpty())
		{
			throw new PersonException("L'âge est obligatoire.");
		}

		int age;

		try
		{
			age = Integer.parseInt(ageValue.trim());
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

	private void showList(HttpServletRequest request, HttpServletResponse response, String message, String error)
		throws ServletException, IOException
	{
		String loadError = null;

		try
		{
			request.setAttribute("people", PERSON_DAO.findAll());
		}
		catch (SQLException | PersonException e)
		{
			loadError = "Impossible de charger les utilisateurs : " + e.getMessage();
		}

		if (loadError != null)
		{
			error = error == null ? loadError : error + " " + loadError;
		}

		if (message != null)
		{
			request.setAttribute("message", message);
		}

		if (error != null)
		{
			request.setAttribute("error", error);
		}

		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
}
