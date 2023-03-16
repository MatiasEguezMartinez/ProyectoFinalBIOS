/* Grupo L2

   Alumno; Matías Egüez Martinez, CI; 5.220.205-4. 
   Alumno; Emilio Patella, CI; 5.374.390-4.
   Alumno; Lucas Lutter, CI: 5.375.443-4. */

USE master
GO
IF EXISTS(SELECT 1 FROM SysDataBases WHERE NAME='ProyectoFinal')
	DROP DATABASE ProyectoFinal
GO

CREATE DATABASE ProyectoFinal on (
	NAME='ProyectoFinal',
	FILENAME='D:\Descargas\ProyectoFinal.Mdf'  --   ¡¡Colocar Ruta!!
)											  
GO

USE ProyectoFinal
GO

Create Table Administrador(
NombreUsuario Varchar(20) primary key,
Nombre Varchar(20),
Contraseña varchar(30)
)
go

Create table Juego(
Codigo INT Identity(1,1) primary key, 
NombreAdmin Varchar(20),
Dificultad Varchar(7),
FechaCreacion datetime DEFAULT GETDATE(), --Se va a crear sola la fecha con el "DEFAULT GETDATE()"
foreign key (NombreAdmin) references Administrador (NombreUsuario),
)
go

create table Jugada(
CodigoJuego INT,
Id INT IDENTITY(1,1),
Fecha DATETIME DEFAULT GETDATE(), --Se va a crear sola la fecha con el "DEFAULT GETDATE()"
Jugador Varchar(100),
PuntajeTotal int,
PRIMARY KEY (CodigoJuego, Id),
FOREIGN KEY (CodigoJuego) REFERENCES Juego(Codigo)
)
go

create table Categoria(
CodigoCategoria varchar(4) primary key,
Nombre varchar(20),
)
go


create table Pregunta(
ID varchar (5) primary key,
CodigoCategoria varchar(4),
Texto Varchar(200),
Puntaje Int ,
foreign key (CodigoCategoria) references Categoria (CodigoCategoria),
)
go

create table Respuesta(
IdPregunta varchar (5),
IdRespuesta INT IDENTITY(1,1),
Correcta bit,
Texto Varchar(70),
PRIMARY KEY (IdPregunta, IdRespuesta),
FOREIGN KEY (IdPregunta) REFERENCES Pregunta(Id)
)
go

create table PreguntasEnJuego( 
CodigoJuego INT,
IdPregunta Varchar(5),
Primary key (CodigoJuego, IdPregunta),
foreign key (CodigoJuego) references Juego (Codigo),
foreign key (IdPregunta) references Pregunta (ID)
)
go

--Administrador-------------------------------------------------------------------------
CREATE PROC CrearAdmin 
@NombreUsuario VARCHAR(20),
@Nombre VARCHAR(20),
@Contraseña Varchar(30)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Administrador WHERE @NombreUsuario=NombreUsuario)
		RETURN -1

	INSERT Administrador VALUES (@NombreUsuario, @Nombre,@Contraseña)
	IF @@ERROR<>0 RETURN -2
	RETURN 1
END
GO
declare @Result int
exec @Result=CrearAdmin 'Admin','Administrador','1234'
select @Result

GO 

CREATE PROC BuscarAdmin
@NombreUsuario VARCHAR(20)
AS
BEGIN
	SELECT *
	FROM Administrador 
	WHERE @NombreUsuario=NombreUsuario 
END

GO
GO
CREATE PROC Logueo
@NombreUsuario VARCHAR(20),
@Contraseña varchar(30)
AS 
BEGIN
	SELECT NombreUsuario, Nombre 
	FROM Administrador 
	WHERE @NombreUsuario=NombreUsuario
	and @Contraseña=Contraseña
END

GO

--Administrador-------------------------------------------------------------------------

--Juego-------------------------------------------------------------------------

CREATE PROC CrearJuego
@NombreUsuarioAdmin Varchar(20),
@Dificultad Varchar(7)
AS
BEGIN
	INSERT Juego (NombreAdmin,Dificultad)
	VALUES (@NombreUsuarioAdmin, @Dificultad)

	IF @@ERROR <>0 RETURN -2
	RETURN 1
END		
GO


CREATE PROC BuscarJuego
@Codigo int
AS
BEGIN
	SELECT 
		Codigo, 
		NombreAdmin,
		Dificultad,
		FechaCreacion
	FROM Juego
	WHERE @Codigo=Codigo
END

GO
CREATE PROC EditarJuego
@Codigo INT,
@NombreAdmin VARCHAR(20),
@Dificultad Varchar(7)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM JUEGO WHERE Codigo=@Codigo)
		RETURN -1	

	UPDATE Juego
	SET NombreAdmin=@NombreAdmin,
		Dificultad=@Dificultad,
		FechaCreacion=GETDATE()
	WHERE Codigo=@Codigo

	IF @@ERROR<>0 RETURN -2
	RETURN 1
END

GO


CREATE PROC ListadoJuegos
As
BEGIN
	select *
	From Juego
END

GO


CREATE PROC JuegoConPregunta
as
begin
	SELECT DISTINCT PreguntasEnJuego.CodigoJuego , Juego.NombreAdmin, Juego.Dificultad, Juego.FechaCreacion
	FROM PreguntasEnJuego 
	INNER JOIN Juego
	ON PreguntasEnJuego.CodigoJuego=Juego.Codigo
end
GO

--Juego--------------------------------------------------------------------------
--Jugada-------------------------------------------------------------------------

CREATE PROC CrearJugada
@CodigoJuego int,
@Jugador varchar(100),
@Puntaje INT
AS
BEGIN
		INSERT Jugada(CodigoJuego,Jugador,PuntajeTotal) VALUES (@CodigoJuego,@Jugador,@Puntaje)
		IF @@ERROR<>0 RETURN -2
		RETURN 1
END
GO



CREATE PROC ListadoJugadas
@CodigoJuego int
as
begin
	Select id,CodigoJuego,Fecha,Jugador,PuntajeTotal, juego.Dificultad, Juego.FechaCreacion,Juego.NombreAdmin
	From Jugada inner join Juego
	On jugada.CodigoJuego=juego.Codigo
	where @CodigoJuego=Codigo
end

GO

CREATE PROC Jugadas
as
begin
	select *
	From Jugada
	order by Fecha asc
end
GO

--Jugada----------------------------------------------------------------------------
--Categoría-------------------------------------------------------------------------
CREATE PROC CrearCategoria
@CodigoCategoria varchar(4),
@Nombre varchar(20)
AS
BEGIN
		IF  EXISTS (SELECT 1 FROM Categoria WHERE CodigoCategoria=@CodigoCategoria)
		RETURN -1

		insert Categoria values (@CodigoCategoria, @Nombre)
		IF @@ERROR<>0 RETURN -2
		RETURN 1
END

GO


CREATE PROC BuscarCategoria
@CodigoCategoria varchar(4)
AS
BEGIN
	select * from Categoria where @CodigoCategoria=Categoria.CodigoCategoria
END

GO
CREATE PROC EditarCategoria
@CodigoCategoria varchar(4),
@nombre varchar(20)
AS
BEGIN
	IF not EXISTS (SELECT 1 FROM Categoria WHERE CodigoCategoria=@CodigoCategoria)
		RETURN -1

	update Categoria set Nombre=@nombre where CodigoCategoria=@CodigoCategoria
	
	IF @@ERROR<>0 RETURN -2
	RETURN 1
END

GO


CREATE PROC BorrarCategoria
@CodigoCategoria varchar(4)
AS
BEGIN
	IF not EXISTS (SELECT 1 FROM Categoria WHERE CodigoCategoria=@CodigoCategoria)
		RETURN -1

	if exists(select 1 From Pregunta where CodigoCategoria=@CodigoCategoria)
	   return -3
	delete Categoria where CodigoCategoria=@CodigoCategoria
	IF @@ERROR<>0 RETURN -2
	RETURN 1
END

GO


Create PROC ListarCategorias
as
begin
	select * 
	From Categoria
end

GO
--Categoría-------------------------------------------------------------------------
--Pregunta-------------------------------------------------------------------------

CREATE PROC CrearPregunta
@Id varchar(5),
@CodigoCategoria varchar(4),
@Texto Varchar(200),
@Puntaje Int,
@Correcta1 bit,
@TextoR1 Varchar(70),
@Correcta2 bit,
@TextoR2 Varchar(70),
@Correcta3 bit,
@TextoR3 Varchar(70)
as
begin
	IF EXISTS (SELECT 1 FROM pregunta WHERE ID=@id)
		RETURN -1
	IF not exists(select 1 From Categoria where @CodigoCategoria=CodigoCategoria)
		return -3
	if exists(select 1 From Respuesta Where Texto=@TextoR1 and @Id=IdPregunta)
		return -4
	begin transaction
	insert pregunta values(@Id, @CodigoCategoria, @Texto, @Puntaje)
	if @@ERROR<>0
	begin
		rollback tran
		return -2
	end
	insert Respuesta values (@Id,@Correcta1,@TextoR1)
	if @@ERROR<>0
	begin
		rollback tran
		return -2
	end
	insert Respuesta values (@Id,@Correcta2,@TextoR2)
	if @@ERROR<>0
	begin
		rollback tran
		return -2
	end
	insert Respuesta values (@Id,@Correcta3,@TextoR3)
	if @@ERROR<>0
	begin
		rollback tran
		return -2
	end	
	COMMIT TRAN
	return 1
end

GO

CREATE PROC BuscarPregunta
@Id varchar(5)
AS
BEGIN
	select * 
	from Pregunta
	where Pregunta.ID=@Id
END

GO


CREATE PROC ListadoPreguntas
as
begin
	select * From Pregunta
end

GO

CREATE PROC ListaDePreguntasPorJuego
@CodigoJuego int
as
begin
	select pregunta.*
	From Pregunta 
		inner Join PreguntasEnJuego
		inner join Juego 
		on PreguntasEnJuego.CodigoJuego=Juego.Codigo 
		on PreguntasEnJuego.IdPregunta=Pregunta.ID 
	Where @codigoJuego=CodigoJuego
end

GO


--Pregunta--------------------------------------------------------------------------
--Respuesta-------------------------------------------------------------------------
GO
Create PROC BuscarRespuestas
@IdPregunta varchar(5)
AS
BEGIN
	select r.IdPregunta,r.Correcta,r.Texto from Respuesta r where r.IdPregunta=@IdPregunta
END

GO

--Respuesta-------------------------------------------------------------------------
--PreguntasEnJuego-------------------------------------------------------------------------
CREATE PROC CrearPreguntasEnJuego
@CodigoJuego int,
@IdPregunta Varchar(5)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM PreguntasEnJuego j WHERE j.CodigoJuego=@CodigoJuego and j.IdPregunta=@IdPregunta)
		RETURN -1

	if not exists(select 1 from juego where juego.Codigo=@CodigoJuego) return -3
	if not exists(select 1 from Pregunta where pregunta.id=@IdPregunta) return -4

	insert PreguntasEnJuego values (@CodigoJuego,@IdPregunta)
	IF @@ERROR<>0 RETURN -2
	RETURN 1
END

GO

CREATE PROC BorrarPreguntasEnJuego
@CodigoJuego int,
@IdPregunta Varchar(5)
AS
BEGIN
	IF not EXISTS (SELECT 1 FROM PreguntasEnJuego j WHERE j.CodigoJuego=@CodigoJuego and j.IdPregunta=@IdPregunta)
		RETURN -1

	DELETE PreguntasEnJuego  WHERE CodigoJuego=@CodigoJuego and IdPregunta=@IdPregunta
	IF @@ERROR<>0 RETURN -2
	RETURN 1
END

go
--PreguntasEnJuego-------------------------------------------------------------------------