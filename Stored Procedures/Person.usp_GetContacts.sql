SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Person].[usp_GetContacts]
AS -- Get all contacts
      SELECT    FirstName ,
                LastName ,
                Title ,
                EmailAddress ,
                Suffix ,
                EmailAddress ,
                EmailPromotion
      FROM      Person.Contact;
GO
