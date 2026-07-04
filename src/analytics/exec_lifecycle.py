# %%
import pandas as pd 
import sqlalchemy 

# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


query = import_query("lifecycle.sql") 
print(query)

 
#%%

engine_app  = sqlalchemy.create_engine("sqlite:///../../data/loyalty_system/database.db")

engine_analytics = sqlalchemy.create_engine("sqlite:///../../data/analytics/analytics.db")


dates = [
    '2024-01-01',
    '2024-02-01',
    '2024-03-01',
    '2024-04-01',
    '2024-05-01',
    '2024-06-01'
]

for i in dates:

    with engine_analytics.connect() as conn:
        conn.execute(sqlalchemy.text(f"DELETE FROM lifecycle WHERE dtRef = date('{i}', '-1 day')"))
        conn.commit()
    
    
    query_format = query.format(date=i)

    df = pd.read_sql(query_format, engine_app)
    df.head()

    df.to_sql("lifecycle", engine_analytics, if_exists="append", index=False)
    # %%
