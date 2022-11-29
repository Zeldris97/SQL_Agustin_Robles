--3
create Trigger tr_AgregarTesting on Tareas
after insert
as
begin
--asignar idmodulo
declare @IDTIPO int, @IDMODULO int,
@TIPO varchar (50)

select @IDTIPO = IDTipo, @IDMODULO = IDModulo from inserted
select @TIPO = Nombre from TiposTarea where ID = @IDTIPO

IF @TIPO like  '%Programaci[óo]n%' begin
insert into Tareas (IDModulo,IDTipo, FechaInicio,FechaFin)
values (@IDMODULO,10,null,null)
insert into Tareas (IDModulo,IDTipo, FechaInicio,FechaFin)
values (@IDMODULO,11,null,null)
end
end

--6
CREATE TRIGGER tr_BajaProyecto on Proyectos
instead of delete
as
begin
declare @IDPROYECTO bigint
select @IDPROYECTO = ID from inserted
--baja logica del proyecto
UPDATE Proyectos
set Estado = 0 where ID = @IDPROYECTO
UPDATE Modulos
set Estado = 0 where @IDPROYECTO in (select IDProyecto from Modulos)
end

--7
CREATE TRIGGER tr_ModificarFecha on Tareas
after insert
as
begin
declare @FECHAMAX date
declare @FECHATAREA DATE
declare @IDMODULO int
select @FECHAMAX = FechaEstimadaFin from Modulos
select @FECHATAREA = FechaFin, @IDMODULO = IDModulo from inserted
if @FECHAMAX < @FECHATAREA begin
update Modulos
set FechaEstimadaFin = @FECHATAREA WHERE ID = @IDMODULO
end
end


CREATE TRIGGER tr_AgregarHistorialPrecios on TiposTarea
after update
as
begin
declare @IDTAREA int
declare @PRECIOANTERIOR money
declare @PRECIOACTUAL money

select @IDTAREA = ID, @PRECIOACTUAL = PrecioHoraBase from inserted
select @PRECIOANTERIOR = PrecioHoraBase from deleted

if (@PRECIOACTUAL!=@PRECIOANTERIOR) begin
insert into HistorialPreciosTiposTarea (IDTipo,PrecioAnterior,FechaModificacion)
values (@IDTAREA, @PRECIOANTERIOR,GETDATE())
END
END


update TiposTarea set PrecioHoraBase = 4000 where ID = 1



SELECT * FROM sys.triggers
GO

