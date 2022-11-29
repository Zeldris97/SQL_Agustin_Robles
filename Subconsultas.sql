--Listar los nombres de proyecto y costo estimado de aquellos proyectos cuyo
costo estimado sea mayor al promedio de costos.
select P.Nombre, P.CostoEstimado from Proyectos P
where P.CostoEstimado> 
(select AVG(CostoEstimado) FROM Proyectos)

--Listar razón social, cuit y contacto (email, celular o teléfono) de aquellos
--clientes que no tengan proyectos que comiencen en el año 2020.
select C.RazonSocial, C.Cuit, COALESCE (C.Email, C.celular, C.Telefono) as contacto from Clientes C
where C.ID not in 
(select C.ID from Clientes
inner join Proyectos P on C.ID = P.IDCliente
where P.FechaInicio = '2020')

--Listado de países que no tengan clientes relacionados.
select P.Nombre from Paises P
where P.ID not in 
(select P.ID from Paises P 
inner join Ciudades C on P.ID = C.IDPais
inner join Clientes CL on Cl.IDCiudad = C.ID)


-- Por cada país listar el nombre, la cantidad de clientes y la cantidad de colaboradores

select p.Nombre,
(
    select count(*) from Clientes C
    inner join Ciudades C1 on C1.ID = C.IDCiudad
    where C1.IDPais = p.ID
) as Clientes,
(
    select count(*) from Colaboradores C
    inner join Ciudades C1 on C1.ID = C.IDCiudad
    where C1.IDPais = p.ID
) as Colaboradores
 from paises p


-- Listar por cada país el nombre, la cantidad de clientes y la cantidad de colaboradores de aquellos países que no tengan clientes pero sí colaboradores.
Select *
from (
    select p.Nombre,
    (
        select count(*) from Clientes C
        inner join Ciudades C1 on C1.ID = C.IDCiudad
        where C1.IDPais = p.ID
    ) as Clientes,
    (
        select count(*) from Colaboradores C
        inner join Ciudades C1 on C1.ID = C.IDCiudad
        where C1.IDPais = p.ID
    ) as Colaboradores
    from paises p
) as MiTabla
Where MiTabla.Clientes = 0 and MiTabla.Colaboradores > 0
