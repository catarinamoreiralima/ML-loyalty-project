#%%
import pandas as pd 
import sqlalchemy
import matplotlib.pyplot as plt

# %%
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query("frequencia_valor.sql")


# %%
engine   = sqlalchemy.create_engine("sqlite:///../../data/loyalty_system/database.db")

# %%
df = pd.read_sql(query, engine)
df.head()

## tratamento de outliers
df = df[df['qntPontosPos'] < 4000] 

# %%
plt.plot(df['frequencia'], df['qntPontosPos'],  'o')
plt.grid(True)
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.show()



# %%
from sklearn import cluster, preprocessing


scaler = preprocessing.StandardScaler()

X = scaler.fit_transform(df[['frequencia', 'qntPontosPos']])

kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)

kmean.fit(X)

df['cluster_calc'] = kmean.labels_ 

df
 
# %%

df.groupby(by='cluster_calc')['IdCliente'].count()

# %%
import seaborn as sns

sns.scatterplot(data=df, x='frequencia', y='qntPontosPos', hue='cluster_calc', palette='Set1')
plt.title('Clusters de Clientes ML')
plt.show()
sns.scatterplot(data=df, x='frequencia', y='qntPontosPos', hue='cluster', palette='Set1')
plt.title('Clusters de Clientes SQL')
plt.show()

# %%

