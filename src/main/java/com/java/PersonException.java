package com.java;

public class PersonException extends Exception
{
	private static final long serialVersionUID = 1L;

	public PersonException(String message)
	{
		super(message);
	}

	public PersonException(String message, Throwable cause)
	{
		super(message, cause);
	}
}
