#%%
import pandas as pd
import sqlalchemy
from sklearn import model_selection

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/analytics.db")
 

#%%
## SAMPLE - OBTENCAO DE DADOS
df = pd.read_sql("abt_fiel", con)

# %%

## TREINO E TESTE - OOT

df_oot = df[df['dtRef'] == df['dtRef'].max()].reset_index(drop=True)

df_oot


#%%
## TREINO E TESTE - SPLIT

target = 'flFiel'

features = df.columns.to_list()[3:]

df_train_test =  df[df['dtRef'] < df['dtRef'].max()].reset_index(drop=True)

X = df_train_test[features] #isso é um pd.dataframe -> matriz -> maiusculo
y = df_train_test[target] # isso é pd.series -> vetor -> minusculo

X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

print(f"Base treino: {X_train.shape[0]} linhas e TX target {100*y_train.mean():.2f} %")
print(f"Base teste: {X_test.shape[0]} linhas e TX target {100*y_test.mean():.2f} %")



# %%

##EXPLORE - MISSING

s_nas = X_train.isna().mean()
s_nas = s_nas[s_nas > 0]

#%%
## EXPLORE
##SELECAO CATEGORIAS E NUMERICAS

cat_features = ['descLifeCycleAtual', 'descLifeCycleD28']

num_features = list(set(features) - set(cat_features))
 

df_train = X_train.copy()
df_train[target] = y_train.copy()

## ANALISE BIVARIADA NUMERICA

df_train[num_features] = df_train[num_features].astype(float)

bivariada_num = df_train.groupby(target)[num_features].median().T

bivariada_num['ratio'] = (bivariada_num[1] + 0.001) / (bivariada_num[0] + 0.001)    
bivariada_num = bivariada_num.sort_values('ratio', ascending=False)

to_remove = bivariada_num[bivariada_num['ratio'] == 1.00].index.to_list()

for i in to_remove:
    num_features.remove(i)

#%%

## ANALISE BIVARIADA CATEGORICA

bivariada_cat = df_train.groupby('descLifeCycleAtual')[target].mean() 
bivariada_cat = df_train.groupby('descLifeCycleD28')[target].mean() 

bivariada_cat

# %%
