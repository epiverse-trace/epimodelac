---
title: "Generar reportes a partir de bases de datos de vigilancia epidemiológica usando sivirep"
author: "Geraldine Gómez Millán"
date: "2023-11-03"
output: html_document
teaching: 50
exercises: 5
---


:::::::::::::::::::::::::::::::::::::: questions 
 
- ¿Cómo obtener un informe automatico de datos de SIVIGILA usando `sivirep`?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

Al final de este taller usted podrá: 
 
- Conocer el paquete `sivirep` 

- Identificar las funcionalidades principales de `sivirep` para generar un reporte básico. 

- Hacer uso de `sivirep` para el análisis de una de las enfermedades con mayor impacto en la región, como herramienta para la toma de decisiones y análisis. 

::::::::::::::::::::::::::::::::::::::::::::::::



## Introducción

Colombia ha mejorado a lo largo de los años la calidad, la accesibilidad
y la transparencia de su sistema oficial de vigilancia epidemiológica,
SIVIGILA. Este sistema está regulado por el Instituto Nacional de Salud
de Colombia y es operado por miles de trabajadores de la salud en las
secretarías de salud locales, hospitales y unidades primarias
generadoras de datos.

Sin embargo, todavía existen desafíos, especialmente a nivel local, en
cuanto a la oportunidad y la calidad del análisis epidemiológico y de
los informes epidemiológicos. Estas tareas pueden requerir una gran
cantidad de trabajo manual debido a limitaciones en el entrenamiento
para el análisis de datos, el tiempo que se requiere invertir, la
tecnología y la calidad del acceso a internet en algunas regiones de
Colombia.

## Objetivos

-   Conocer el paquete `sivirep`
-   Identificar las funcionalidades principales de `sivirep` para
    generar un reporte básico.
-   Hacer uso de `sivirep` para el análisis de una de las enfermedades
    con mayor impacto en la región, como herramienta para la toma de
    decisiones y análisis.

## Conceptos básicos a desarrollar

En esta práctica se desarrollarán los siguientes conceptos:

-   Función: conjunto de instrucciones que se encargan de transformar
    las entradas en los resultados deseados.

-   Modulo: cojunto de funciones que son agrupadas debido a su relación
    conceptual, resultados proporcionados y definición de
    responsabilidades.

-   R Markdown: es una extensión del formato Markdown que permite
    combinar texto con código R incrustado en el documento. Es una
    herramienta para generar informes automatizados y documentos
    técnicos interactivos.

-   SIVIGILA: Sistema de Notificación y Vigilancia en Salud Pública de
    Colombia.

-   Microdatos: Son los datos sobre las características de las unidades
    de estudio de una población (individuos, hogares, establecimientos,
    entre otras) que se encuentran consolidados en una base de datos.

-   Evento: Conjunto de sucesos o circunstancias que pueden modificar o
    incidir en la situación de salud de una comunidad.

-   Incidencia: Es la cantidad de casos nuevos de un evento o una
    enfermedad que se presenta durante un período de tiempo específico.
    Usualmente, se presentá como el número de casos por población a
    riesgo, y por ello el denominador podría variar dependiendo del
    evento o enfermedad.

-   Departamento: En Colombia, existen 32 unidades geográficas
    administrativas (adm1) llamadas departamentos.

-   Municipio: Corresponden al segundo nivel de división administrativa
    en Colombia, que mediante agrupación conforman los departamentos.
    Colombia posee 1104 municipios registrados.

-   Reporte: análisis descriptivo de una enfermedad o evento del
    SIVIGILA.

## Contenido del taller

Ha llegado el momento de explorar `sivirep`, de conocer cómo generar
reportes automatizados con el paquete y sus funcionalidades principales.

El evento que analizaremos es **Dengue** en el departamento del
**Cauca** para el año **2022**, ya que ha sido una de las regiones más
afectadas en Colombia a lo largo del tiempo por esta enfermedad.

Iniciaremos instalando e importando el paquete a través de los siguientes comandos:


``` r
remove.packages("sivirep")
if (!require("pak")) install.packages("pak")
pak::pak("epiverse-trace/sivirep") # Comando para instalar sivirep
rm(list = ls()) # Comando para limpiar el ambiente de R
library(sivirep) # Comando para importar sivirep
```

Verificar que el evento o enfermedad se encuentren disponibles para su
descarga en la lista que provee `sivirep`, la cual se puede obtener
ejecutando el siguiente comando:



### Reporte automatizado

Ahora generaremos un reporte automatizado a partir de la plantilla que
provee el paquete llamada `Reporte Básico {sivirep}`, la cual contiene
seis secciones y recibe los siguientes parámetros de entrada: el nombre
del evento o enfermedad, el año, el nombre de departamento (opcional) y
nombre del municipio (opcional) para descargar los datos de la fuente de
SIVIGILA.

Para hacer uso de la plantilla se deben seguir los siguientes pasos:

1.  En RStudio hacer click **'File/New File/R'** Markdown:

![](https://github.com/epiverse-trace/sivirep/raw/main/man/figures/file_rmarkdown.png){.rmarkdown-img
align="center"
style="margin-left: 2.8em; margin-top: 0.8em; margin-bottom: 0.8em;"
width="560"}

2.  Selecciona la opción del panel izquierdo: **'From Template'**,           después haz clic en el template llamado `Reporte Básico {sivirep}`,
    indica el nombre que deseas para el reporte (i.e. Reporte_Laura), la
    ubicación donde deseas guardarlo y presiona **'Ok'**.

![](https://github.com/epiverse-trace/sivirep/raw/main/man/figures/reporte_basico.png){.rmarkdown-img
align="center"
style="margin-left: 2.8em; margin-top: 0.8em; margin-bottom: 0.8em;"
width="520"}

3.  En la parte superior de **'RStudio'*, presiona el botón **'Knit'**,
    despliega las opciones y selecciona **'Knit with parameters'**.

![](https://github.com/epiverse-trace/sivirep/raw/main/man/figures/button_knit.png){.rmarkdown-img
align="center"
style="margin-left: 2.8em; margin-top: 0.8em; margin-bottom: 0.8em;"
width="560"}

4. A continuación, aparecerá una pantalla donde podrás indicar el nombre
   de la enfermedad o evento, el año y el departamento del reporte.
   Esta acción descargará los datos deseados y también proporcionará la
   plantilla en un archivo R Markdown (.Rmd), al hacer clic en el botón     **'Knit'**.

![](./man/figures/params_knit.png){.rmarkdown-img
align="center"
style="margin-left: 2.8em; margin-top: 0.8em; margin-bottom: 0.8em;"
width="560"}


5. Espera unos segundos mientras el informe se genera en un archivo
   HTML.

**!Felicitaciones has generado tu primer reporte automatizado con
sivirep!**

### Actividad exploratoria

Para conocer las funciones principales del paquete realizaremos una
actividad exploratoria siguiendo el flujo de datos de `sivirep`.

Construiremos un informe en R Markdown para Dengue, departamento del Cauca, año 2022 (no se debe utilizar la plantilla
de reporte vista en la sección anterior) que de respuesta a las
siguientes preguntas:

1.  ¿Cómo es la distribución por sexo y semana epidemiológica de la
    enfermedad?
2.  ¿Esta distribución sugiere que la enfermedad  afecta más a
    un sexo o a otro? ¿sí, no y por qué?
3.  ¿Cómo afecta la enfermedad los distintos grupos etarios?
4.  ¿Cuál es el municipio que más se ve afectado por la enfermedad en la
    región?

### 1. Preparación y configuración del documento R Markdown
Realizaremos la configuración y preparación del documento en R Markdown a través de los siguientes pasos:

1. Crear un documento en R Mardown vacio:
2. Insertar un chunk en el documento con las siguientes opciones de configuración:


``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "figures/",
  include = TRUE,
    error = FALSE,
  warning = FALSE,
  message = FALSE
)
```
   
### 2. Importación de datos de SIVIGILA

Iniciaremos con la importación de los datos del evento o enfermedad
utilizando la función `import_data_event` la cual permite descargar los
datos desde la fuente de SIVIGILA utilizando un formato parametrizado
basado en el nombre del evento y el año.


``` r
data_dengue <-  import_data_event(nombre_event = "dengue",
                                  year = 2022)
```

### 3. Exploración de la base de datos

Recomendamos explorar la base de datos, sus variables, tipos de datos,
registros y otras caracteristicas que pueden ser relavantes para su
análisis y permitan responder correctamente a las preguntas planteadas
en la actividad.



Si tiene alguna duda respecto a las variables o desconoce su significado
puede dirigirse al [diccionario de datos del
SIVIGILA](https://www.dssa.gov.co/images/documentos/sivigila2017/Anexo%202%20Diccionario%20datos.pdf).

### 4. Limpieza de datos de SIVIGILA

Para limpiar los datos utilizaremos una función genérica que proporciona
`sivirep` llamada `limpiar_data_sivigila`, la cual envuelve diversas
tareas para identificar y corregir errores, inconsistencias y
discrepancias en los conjuntos de datos con el fin de mejorar su calidad
y precisión. Este proceso puede incluir la corrección de errores
tipográficos, el reemplazo de valores faltantes y la validación de
datos, entre otras tareas, como eliminar fechas improbables, limpiar
códigos de geolocalización y estandarizar los nombres de las columnas y
las categorías de edad.


``` r
data_limpia <- limpiar_data_sivigila(data_event = data_dengue)
data_limpia
```

### 5. Filtrar casos

Ahora debemos filtrar los datos del evento o enfermedad por el
departamento de `Cauca`, utilizando la función de `sivirep` llamada
`geo_filtro`. Esta función permite al usuario crear informes a nivel
subnacional, seleccionando casos específicos basados en la ubicación
geográfica.


``` r
data_filtrada <- geo_filtro(data_event = data_limpia, dpto = "Cauca")
data_filtrada
```

### 6. Variable de sexo

Agruparemos los datos de la enfermedad por la variable sexo para poder
visualizar su distribución y obtener los porcentajes a través de la
función que proporciona `sivirep`:


``` r
casos_sex <- agrupar_sex(data_event = data_filtrada,
                         porcentaje = TRUE)
casos_sex
```

Además, `sivirep` cuenta con una función para generar el gráfico por
esta variable llamada `plot_sex`:


``` r
plot_sex(data_agrupada = casos_sex)
```

La distribución de casos por sexo y semana epidemiológica se puede
generar utilizando la función `agrupar_sex_semanaepi` proporcionada por
`sivirep`.


``` r
casos_sex_semanaepi <- agrupar_sex_semanaepi(data_event = data_filtrada)
casos_sex_semanaepi
```

La función de visualización correspondiente es `plot_sex_semanaepi`, que
`sivirep` proporciona para mostrar la distribución de casos por sexo y
semana epidemiológica.


``` r
plot_sex_semanaepi(data_agrupada = casos_sex_semanaepi)
```

### 7. Variable de edad

`sivirep` proporciona una función llamada `agrupar_edad`, que puede
agrupar los datos de enfermedades por grupos de edad. De forma
predeterminada, esta función produce rangos de edad con intervalos de 10
años.


``` r
casos_edad <- agrupar_edad(data_event = data_limpia, interval_edad = 10)
casos_edad
```

La función de visualización correspondiente es `plot_edad`.


``` r
plot_edad(data_agrupada = casos_edad)
```

### 8. Distribución espacial de casos

Obtener la distribución espacial de los casos es útil para identificar
áreas con una alta concentración de casos, agrupaciones de enfermedades
y factores de riesgo ambientales o sociales.

En Colombia, existen 32 unidades geográficas administrativas (adm1)
llamadas departamentos. `sivirep` proporciona una función llamada
`agrupar_mpio` que permite obtener un data.frame de casos agrupados por
departamento o municipio.


``` r
dist_esp_dept <- agrupar_mpio(data_event = data_filtrada)
dist_esp_dept
```

Con la función llamada `plot_map`, podremos generar un mapa estático que
muestra la distribución de casos por municipios.


``` r
mapa <- plot_map(data_agrupada = dist_esp_dept)
mapa
```

### 9. Análisis de resultados

Analiza los resultados obtenidos en la ejecución de las funciones y
responde las preguntas planteadas en el enunciado de la actividad
exploratoria.

Dentro del R Markdown desarrolla dos (2) conclusiones pertinentes a la
enfermedad teniendo en cuenta el contexto de la región y las estrategias que podrían contribuir a su mitigación.

## Reflexión

Conformaremos grupos de 4-5 personas y discutiremos sobre la
disponibilidad de los datos y el impacto que esto tiene en la
construcción de análisis y en las acciones que se pueden emprender para
mitigar el efecto de esta enfermedad sobre la población.

## Desafio

En el siguiente enlace podrán encontrar el desafío que debérán desarrollar con `sivirep`:
- https://docs.google.com/document/d/1_79eyXHTaQSPSvUzlikx9DKpBvICaiqy/edit?usp=sharing&ouid=113064166206309718856&rtpof=true&sd=true

------------------------------------------------------------------------

### Sobre este documento

Este documento ha sido diseñado por Geraldine Gómez Millán para el Curso
Internacional: Análisis de Brotes y Modelamiento en Salud Pública,
Bogotá 2023. TRACE-LAC/Javeriana.

#### Recursos

- [Presentación del taller](https://www.canva.com/design/DAFzKDqZT0E/uwZABHMIn14qq_LT9uSKEA/edit?utm_content=DAFzKDqZT0E&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)
- [Encuesta](https://forms.office.com/r/bRpPuAh8hF?origin=lprLink)
- [Página de sivirep](https://epiverse-trace.github.io/sivirep/)
- [Documentación de las funciones de sivirep](https://epiverse-trace.github.io/sivirep/reference/index.html)
- [Repositorio de sivirep](https://github.com/epiverse-trace/sivirep)

#### Contribuciones

- Geraldine Gómez Millán
- Jaime Pavlich-Mariscal
- Andrés Moreno
