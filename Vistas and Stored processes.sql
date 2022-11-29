--1
CREATE VIEW vw_PrecioHora
as
select Nombre, PrecioHoraBase, 
(select AVG(C.PrecioHora) from Colaboraciones C 
inner join Tareas T on C.IDTarea=T.ID
inner join TiposTarea on TT.ID=T.IDTipo)
as PromedioValorHora from TiposTarea TT

select * from vw_PrecioHora

--1 github
Create View VW_ReporteTiposTarea as
Select Aux.*, Aux.PromPrecioHora-Aux.PrecioHoraBase as Dif From (
select tt.Nombre, tt.PrecioHoraBase,
(
    select avg(c.PrecioHora) from Colaboraciones as c
    inner join tareas t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID
) as PromPrecioHora
from TiposTarea tt
) as Aux

select * from VW_ReporteTiposTarea

--2
ALTER VIEW vw_PrecioHora
as
select TT.Nombre,TT.PrecioHoraBase, 
(select AVG(C.PrecioHora) from Colaboraciones C 
inner join Tareas T on C.IDTarea=T.ID
inner join TiposTarea on TT.ID=T.IDTipo)
as PromedioValorHora,
(select )
CASE 
        WHEN PromedioValorHora-TT.PrecioHoraBase < 500 THEN 'Poca' 
        WHEN PromedioValorHora - TT.PrecioHoraBase > 500 and PromedioValorHora - TT.PrecioHoraBase < 1000 THEN 'Mediana'
		WHEN PromedioValorHora - TT.PrecioHoraBase > 1000 THEN 'Alta' 
    END AS Variacion
from TiposTarea TT

--2 github
Alter View VW_ReporteTiposTarea as
select t2.*, case
when t2.Dif < 500 then 'Poca'
When t2.Dif < 999 then 'Mediana'
Else 'Alta'
end as Variacion
 from (
    select t1.*, Abs(t1.PrecioHoraBase - t1.PromPrecioHora) as Dif 
    from (
        select tt.Nombre, tt.PrecioHoraBase,
        (
            select avg(c.PrecioHora) from Colaboraciones as c
            inner join tareas t on t.ID = c.IDTarea
            where t.IDTipo = tt.ID
        ) as PromPrecioHora
        from TiposTarea tt
    ) as t1
) as t2

select * from VW_ReporteTiposTarea



--3
CREATE PROCEDURE SP_Listar_Colaboraciones (
@IDCOLABORADOR INT
)
AS
BEGIN
      SELECT C.Nombre+ ', '+ C.Apellido AS 'Colaborador', COUNT (CO.IDTarea) as 'Cantidad de colaboraciones' from Colaboraciones CO
	  inner join Colaboradores C on C.ID = CO.IDColaborador
	  where @IDCOLABORADOR = C.ID
	  GROUP BY C.Nombre+ ', '+ C.Apellido
END

EXEC SP_Listar_Colaboraciones 4

--3 github
Create Procedure SP_ColaboracionesxColaborador(
    @IDColab bigint
)
as
begin
    Select IDTarea, 
    Format(Tiempo/60, '00') + ':' + Format(Tiempo%60, '00') as Tiempo,
    PrecioHora from Colaboraciones
     where IDColaborador = @IDColab And Estado = 1
end



Exec SP_ColaboracionesxColaborador 1

--4
CREATE VIEW vw_VistaProyectoXcolaborador as
select C1.Apellido, C1. Nombre, 
 CASE
 WHEN C1.Tipo = 'E' THEN 'Externo'
ELSE 'Interno'
END as Tipo,
COUNT (C2.IDColaborador) AS 'Proyectos distintos'
 FROM Colaboradores C1
 inner join Colaboraciones C2 on C1.ID = C2.IDColaborador
GROUP BY C1.ID,C1.Nombre, C1.Apellido, Tipo

select * from vw_VistaProyectoXcolaborador

--5
CREATE PROCEDURE SP_ProyectosxFecha(
@PRIMERFECHA date,
@SEGUNDAFECHA date
)

as
begin
set dateformat 'DMY'
select * from Proyectos
WHERE 
FechaInicio >@PRIMERFECHA and
FechaInicio< @SEGUNDAFECHA
end


--6
CREATE PROCEDURE sp_ModificarContacto(
@IDCLIENTE int,
@IDTIPOCONTACTO int,
@NUEVOVALOR varchar (100)
)
as
begin
if @IDCLIENTE = 1 BEGIN
UPDATE Clientes
SET EMail = @IDTIPOCONTACTO
END
ELSE IF @IDCLIENTE = 2 BEGIN
UPDATE Clientes
SET Telefono = @IDTIPOCONTACTO
END
ELSE IF @IDCLIENTE = 3 BEGIN
UPDATE Clientes
SET Telefono = @IDCLIENTE
END

end

Exec sp_ModificarContacto 1, 1, 'mailcambiado@mail.com'



--7

ALTER PROCEDURE sp_BajaModuloYTareas(
@IDMODULO int
)
as
begin
BEGIN TRY
   BEGIN TRANSACTION
   UPDATE Modulos
   SET estado = 0 where @IDMODULO = ID
   if @@ROWCOUNT <>1 begin
   RAISERROR ('Error', 16, 1)
   end
   UPDATE Tareas
   SET Estado = 0 where FechaInicio > GETDATE() or FechaInicio is null and @IDMODULO= @IDMODULO

   COMMIT TRANSACTION
   END TRY
   BEGIN CATCH 
     ROLLBACK TRANSACTION
	 RAISERROR ('Error al dar de baja el modulo', 16, 1)
    END CATCH

	END

	select * from Modulos where ID = 2
	select * from Tareas where IDModulo = 2


	execute sp_BajaModuloYTareas 2