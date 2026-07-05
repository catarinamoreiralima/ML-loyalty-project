# %%
import pandas as pd 
import sqlalchemy
import datetime 
from tqdm import tqdm 
import argparse
from pathlib import Path

DEFAULT_ORIGIN_BY_TABLE = {
    "fs_education": "education-platform",
    "fs_life_cycle": "analytics",
}

# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

def date_range(start_date, end_date, monthly=False):
    dates = []
    while start_date <= end_date:
        dates.append(start_date)
        dt_start = datetime.datetime.strptime(start_date, "%Y-%m-%d") + datetime.timedelta(days=1)
        start_date = dt_start.strftime("%Y-%m-%d")

    if monthly:
        dates = [d for d in dates if d.endswith("01")]
    return dates

def exec_query(table, database_origin, database_target, dt_start, dt_end, monthly=False):
    project_root = Path(__file__).resolve().parents[2]
    analytics_dir = Path(__file__).resolve().parent
    origin_file = "analytics.db" if database_origin == "analytics" else "database.db"
    target_file = "analytics.db" if database_target == "analytics" else "database.db"

    engine_app = sqlalchemy.create_engine(
        f"sqlite:///{project_root / 'data' / database_origin / origin_file}"
    )
    engine_analytics = sqlalchemy.create_engine(
        f"sqlite:///{project_root / 'data' / database_target / target_file}"
    )
 
    query = import_query(analytics_dir / f"{table}.sql") 
    dates = date_range(dt_start, dt_end, monthly=monthly)

    for i in tqdm(dates):

        with engine_analytics.connect() as conn:

            try:
                    conn.execute(sqlalchemy.text(f"DELETE FROM {table} WHERE dtRef = date('{i}', '-1 day')"))
                    conn.commit()
            except Exception as e:
                print(f"Erro ao deletar dados para a data {i}: {e}")
    
    
        query_format = query.format(date=i)

        df = pd.read_sql(query_format, engine_app)

        df.to_sql(table, engine_analytics, if_exists="append", index=False)


#%%

## Parametros de configuração e execução 
## script, tabela, database, datas de início e fim

def main():

    parser = argparse.ArgumentParser()

    parser.add_argument('--db_origin', '--db-origin', default=None, 
                        choices=['loyalty-system', 'education-platform', 'analytics'], 
                        type=str, 
                        help='Nome do banco de dados de origem')
    
    parser.add_argument('--db_target', '--db-target', default='analytics', 
                        choices=['analytics'], 
                        type=str, 
                        help='Nome do banco de dados de destino')
    
    parser.add_argument('--table', 
                        type=str, required=True, 
                        help='Nome da tabela a ser processada, com mesmo nome do arquivo SQL correspondente')
    
    now = datetime.datetime.now().strftime("%Y-%m-%d")

    parser.add_argument('--dt_start', '--dt-start', default=now, 
                        type=str, 
                        help='Data de início no formato YYYY-MM-DD')
    

    parser.add_argument('--dt_end', '--dt-end', default=now, 
                        type=str, 
                        help='Data de fim no formato YYYY-MM-DD')
    
    parser.add_argument('--monthly', action='store_true',
                        help='Se definido, processa apenas os primeiros dias de cada mês')
    

    args = parser.parse_args() 
    
    table = args.table
    database_origin = args.db_origin
    database_target = args.db_target
    dt_start = args.dt_start
    dt_end = args.dt_end
    monthly = args.monthly
    exec_query(table, database_origin, database_target, dt_start, dt_end, monthly)

if __name__ == "__main__":
    main()
