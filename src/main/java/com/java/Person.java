package com.java;

public class Person
{
	private int id;
	private String nom;
	private String prenom;
	private int age;

	public Person()
	{
	}

	public Person(int id, String nom, String prenom, int age) throws PersonException
	{
		this.id = id;
		this.nom = validateNom(nom);
		this.prenom = validatePrenom(prenom);
		this.age = validateAge(age);
	}

	public int getId()
	{
		return id;
	}

	public void setId(int id)
	{
		this.id = id;
	}

	public String getNom()
	{
		return nom;
	}

	public void setNom(String nom) throws PersonException
	{
		this.nom = validateNom(nom);
	}

	private static String validateNom(String nom) throws PersonException
	{
		if (nom == null || nom.trim().isEmpty())
		{
			throw new PersonException("Le nom est obligatoire.");
		}

		String valeur = nom.trim();
		if (valeur.length() > 20)
		{
			throw new PersonException("Le nom ne doit pas dépasser 20 caractères.");
		}

		return valeur;
	}

	public String getPrenom()
	{
		return prenom;
	}

	public void setPrenom(String prenom) throws PersonException
	{
		this.prenom = validatePrenom(prenom);
	}

	private static String validatePrenom(String prenom) throws PersonException
	{
		if (prenom == null || prenom.trim().isEmpty())
		{
			throw new PersonException("Le prénom est obligatoire.");
		}

		String valeur = prenom.trim();
		if (valeur.length() > 10)
		{
			throw new PersonException("Le prénom ne doit pas dépasser 10 caractères.");
		}

		return valeur;
	}

	public int getAge()
	{
		return age;
	}

	public void setAge(int age) throws PersonException
	{
		this.age = validateAge(age);
	}

	private static int validateAge(int age) throws PersonException
	{
		if (age < 0 || age > 100)
		{
			throw new PersonException("L'âge doit être compris entre 0 et 100.");
		}

		return age;
	}
}
