# %%
import pandas as pd 
import sqlalchemy 

# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


query = import_query("lifecycle.sql") 

 
#%%

engine_app  = sqlalchemy.create_engine("sqlite:///../../data/loyalty_system/database.db")

engine_analytics = sqlalchemy.create_engine("sqlite:///../../data/analytics/analytics.db")

#%%
import datetime 
from tqdm import tqdm
 

def date_range(start_date, end_date):
    dates = []
    while start_date <= end_date:
        dates.append(start_date)
        dt_start = datetime.datetime.strptime(start_date, "%Y-%m-%d") + datetime.timedelta(days=1)
        start_date = dt_start.strftime("%Y-%m-%d")
    return dates

dates = date_range("2024-09-01", "2025-10-01")


#%%


for i in tqdm(dates):

    with engine_analytics.connect() as conn:

        try:
            conn.execute(sqlalchemy.text(f"DELETE FROM lifecycle WHERE dtRef = date('{i}', '-1 day')"))
            conn.commit()
        except Exception as e:
            print(f"Erro ao deletar dados para a data {i}: {e}")
    
    
    query_format = query.format(date=i)

    df = pd.read_sql(query_format, engine_app)
    df.head()

    df.to_sql("lifecycle", engine_analytics, if_exists="append", index=False)
    # %%
