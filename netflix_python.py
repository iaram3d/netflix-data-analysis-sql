import sqlite3 as sq3
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from IPython.display import display  # para mostrar los DF como los muestra el intérprete en un entorno de Jupyter Notebooks

conn = sq3.connect('netflix_oscar.db')

dfs = {
     "df_content": pd.read_sql_query("SELECT * FROM content",conn),
     "df_oscar": pd.read_sql_query("SELECT * FROM oscar",conn),
     "df_production": pd.read_sql_query("SELECT * FROM production",conn)
      
      }


conn.close()

# Analisis de la calidad de los datos
def analizar_columna(columna):
    no_nulos = columna.count()
    nulos = columna.isnull().sum()
    vacios = (columna == '').sum()
    distintos = columna.nunique()
    return pd.Series([no_nulos, nulos, vacios, distintos],index=["No_nulos", "Nulos", "Vacios", "Distintos"])

dfs_analisis = {tabla:pd.DataFrame for tabla in dfs}
print(dfs_analisis)

for tabla, df in dfs.items(): 
    dfs_analisis[tabla] = df.apply(analizar_columna)

for tabla, df in dfs_analisis.items():
    print(f"{tabla}:")
    display(df)
    print()

# Consultas especificas a DF con pandas
df_content = dfs["df_content"].fillna('')
df_production =  dfs["df_production"].fillna('')
df_oscar = dfs["df_oscar"].fillna('')

# Todos los registros
display(df_content.loc[:,['type', 'title_content', 'country', 'rating', 'duration', 'listed_in']])

# Registros en los que participa Argentina
display(df_content.loc[df_content["country"].str.contains('Argentina'),['id_content', 'type', 'title_content', 'cast', 'rating', 'duration', 'listed_in']])

# Registros con puntaje IMDB mayor a 7.5
display(df_production.loc[df_production['imdb_score']>7.5,['title_production', 'genre', 'language', 'imdb_score']])

# Registros en Frances que duran mas de 90 minutos
frances_90 = df_production.loc[(df_production["runtime"]>90)&(df_production["language"]=="French")]
df_joineado = pd.merge(frances_90,df_content, how = 'inner', on='id_content')
display(df_joineado.loc[:,["title_production", "type", "runtime", "imdb_score"]] \
.sort_values("imdb_score",ascending=False).reset_index(drop=True)
)

# Consultas a set_total con pandas
df_set_total = pd.read_csv('set_total.csv')
df_set_total

# Elimino registros duplicados
df_set_total.duplicated().sum()
df_set_total.shape
df_set_total.drop_duplicates(inplace=True,keep='first')
df_set_total.shape

# Modifico tipos de datos
df_set_total["id_content"]=df_set_total["id_content"].fillna(0).astype('int64')
df_set_total["id_content"]
df_set_total["release_year"]=df_set_total["release_year"].fillna(0).astype('int64')
df_set_total["release_year"]
df_set_total["year_ceremony"]=df_set_total["year_ceremony"].fillna(0).astype('int64')
df_set_total["year_ceremony"]
df_set_total.dtypes

# Visualizacion con Matplotlib
df_content = dfs["df_content"]
df_production = dfs["df_production"]
df_oscar = dfs["df_oscar"]

# Relacion entre cantidad de peliculas y series
display(df_content["type"].value_counts())
aplotear= df_content["type"].value_counts()

fig,ax=plt.subplots()
ax.pie(aplotear, labels=aplotear.index, autopct="%.2f%%")
ax.set_title("Relación Movies con TV Show")
fig.show()

# TOP 10 paises que tienen mayor cantidad de registros en la plataforma, desglosando por tipo de contenido
dfc_limpio = df_content[["country", "type"]].dropna(subset=["country"])
dfc_limpio = dfc_limpio[~dfc_limpio["country"].str.contains(",")]

dfc_limpio= dfc_limpio.pivot_table(index="country",columns="type",aggfunc="size",fill_value="0")
dfc_limpio= dfc_limpio[dfc_limpio.index !=""]

dfc_limpio["Movie"] = pd.to_numeric(dfc_limpio["Movie"], errors='coerce')
dfc_limpio["TV Show"] = pd.to_numeric(dfc_limpio["TV Show"], errors='coerce')

dfc_limpio["Total"]=dfc_limpio["Movie"]+dfc_limpio["TV Show"]
dfc_limpio = dfc_limpio.sort_values("Total", ascending=False).head(10)

dfc_limpio.drop("Total",axis="columns",inplace=True)

fig,ax2=plt.subplots()
bars= dfc_limpio.plot(kind='bar',rot=75,width=0.5,ax=ax2)
for bar in bars.patches:
    x = bar.get_x() + bar.get_width() / 2
    y = bar.get_height()
    ax2.annotate(f'{y}', (x, y), ha='left', va='bottom', fontsize=8)
ax2.set_title("Top 10 países con más titulos")
fig.show()

# Visualizacion con Seaborn

# TOP 20 directores con mas producciones en orden descendiente
df_3bi = df_content[["director","type"]].dropna(subset=["director"])

cross_table= pd.crosstab(index=df_3bi["director"],columns=df_3bi["type"],margins=True)

filtrado = cross_table.sort_values(by="All",ascending=False).head(21)
fig,ax3=plt.subplots(figsize=(14,9))
sns.heatmap(filtrado[1:],annot=True,cbar=False,cmap="Blues",ax=ax3)
ax3.xaxis.set_ticks_position("top")
ax3.set_title("Top 20 directores con más producciones")
plt.show()

# TOP 20 generos con mayor cantidad de producciones en orden descendiente
top20generos = df_content["listed_in"].value_counts().nlargest(20).to_frame("cantidad")

fig,ax4=plt.subplots(figsize=(14,9))
def map_cantidad_to_color(cant):
    if 100<= cant <150:
        return 'lightblue'
    elif 150 <= cant <200:
        return 'lightgreen'
    elif 200<= cant <250:
        return 'gold'
    elif 250<= cant <300:
        return 'orange'
    elif 300<= cant <350:
        return 'salmon'
    elif 350<= cant <400:
        return 'red'
    else:
        return 'gray'

colors = [map_cantidad_to_color(cant) for cant in top20generos ["cantidad"]]
sns.barplot(top20generos,x="cantidad", y=top20generos.index, orient="h", palette=colors)
for bar in ax4.patches:
    width = bar.get_width()
    ax4.annotate(f'{int(width)}',
                 xy=(width,bar.get_y()+bar.get_height()/2),
                 xytext=(-25, 0),
                 textcoords="offset points",
                 ha='left', va='center',
                 color="black",
                 weight='bold')

ax4.set_xticks(range(0, 370, 50))
ax4.set_xlim(0, 365)
ax4.set_title("Top 20 géneros con más producciones")
plt.show()

# 15 idiomas con mayor cantidad de titulos sin contar ingles en orden descendente
df_idioma = df_production[~df_production['language'].str.contains('English', case=False)]

top_languages = df_idioma['language'].value_counts().head(15)
plt.figure(figsize=(10, 6))
sns.barplot(x=top_languages.values, y=top_languages.index, palette='viridis')
plt.title("Top 15 idiomas con más títulos aparte del inglés")
plt.tight_layout()
plt.show()