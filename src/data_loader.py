import psycopg2, psycopg2.extras
import pandas as pd
from sqlalchemy import create_engine


def connect(user, password, db, host='localhost', port=5432):
    '''Returns a connection and a metadata object'''
    # We connect with the help of the PostgreSQL URL
    url = 'postgresql://{}:{}@{}:{}/{}'
    url = url.format(user, password, host, port, db)

    # The return value of create_engine() is our connection object
    con = create_engine(url, client_encoding='utf8')

    return con

def create_table_from_df(df, table_name , connection, schema= 'moip'):
  df.to_sql(name= table_name, con= connection, schema= schema, if_exists= 'replace',index= False)


if __name__ == '__main__':

  # Database inputs
  user = 'your_username_here' 
  password = 'your_password_here!'
  db = 'postgres'

  # Connecting to database
  engine = connect(user, password, db, host='localhost', port=5432)

  print "******* reading data **********"
  input_data = '../data/data_berka/account.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting accounts into database **********"
  create_table_from_df(df = df, table_name = 'accounts', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/card.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting credit_card into database **********"
  create_table_from_df(df = df, table_name = 'credit_card', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/client.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting client into database **********"
  create_table_from_df(df = df, table_name = 'client', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/disp.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting disposition into database **********"
  create_table_from_df(df = df, table_name = 'disposition', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/loan.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting loan into database **********"
  create_table_from_df(df = df, table_name = 'loan', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/district.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting demograph into database **********"
  create_table_from_df(df = df, table_name = 'demograph', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/order.asc'
  df = pd.read_table(input_data, sep = ';', header = 0)

  print "******* create/inserting permanent_order into database **********"
  create_table_from_df(df = df, table_name = 'permanent_order', connection = engine)

  print "******* reading data **********"
  input_data = '../data/data_berka/trans.asc'
  cols_type = {"trans_id": int, "account_id": int, "date": str, "type": str, "operation": str, "amount": float, "balance": float, "k_symbol": str, "bank": str, "account": str }
  df = pd.read_table(input_data, sep = ';', header = 0, dtype = cols_type)

  df.drop(['k_symbol','bank','account'], axis = 1, inplace=True)
  print df.head()

  print "******* create/inserting transactions into database **********"
  create_table_from_df(df = df, table_name = 'transactions', connection = engine)

