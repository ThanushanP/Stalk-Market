import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt
import datetime
import numpy as np


pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

ticker = yf.download('BTC-USD', 
                   start='2014-01-01', 
                   end='2024-12-02')['Close']


ticker.to_csv("ticker.csv")

ticker = pd.read_csv("ticker.csv")

train = ticker[ticker.index < pd.to_datetime("2017-12-31", format='%Y-%m-%d')]
test = ticker[ticker.index > pd.to_datetime("2017-12-31", format='%Y-%m-%d')]

# plt.ylabel('Price')
# plt.xlabel('Date')
# plt.xticks(rotation=45)

# plt.plot(ticker.index, ticker['Close'], )

# plt.show()

