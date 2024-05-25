import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt
import datetime
import numpy as np
from statsmodels.tsa.statespace.sarimax import SARIMAX
from statsmodels.tsa.arima.model import ARIMA





""" pastSearches = {}

def getData(stock):

    if stock in pastSearches and datetime.now.date() - pastSearches[stock] <= 5:
        return pd.read_csv(stock + ".csv")
    else:
        pastSearches[stock] =  datetime.now.date()     
        pd.set_option('display.max_columns', None)
        pd.set_option('display.max_rows', None)

        ticker = yf.download(stock.uppercase(), 
                        start='2022-01-01', 
                        end='2024-05-02')['Close']


        ticker.to_csv(stock+".csv")
        """









pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

ticker = yf.download('VFV.TO', 
                   start='2022-01-01', 
                   end='2024-07-02')['Close']


ticker.to_csv("ticker.csv")

ticker = pd.read_csv("ticker.csv")

ticker.index = pd.to_datetime(ticker['Date'], format='%Y-%m-%d')

train = ticker[ticker.index < pd.to_datetime("2024-04-01", format='%Y-%m-%d')]
test = ticker[ticker.index > pd.to_datetime("2024-04-01", format='%Y-%m-%d')]

y = train['Close']

# #############################################################################

## START SARIMA (5, 4, 2)
SARIMAXmodel = SARIMAX(y, order = (1,0,0), seasonal_order=(2,2,2,12))
SARIMAXmodel = SARIMAXmodel.fit()
y_pred = SARIMAXmodel.get_forecast(len(test.index))
y_pred_df = y_pred.conf_int(alpha = 0.05) 
y_pred_df["Predictions"] = SARIMAXmodel.predict(start = y_pred_df.index[0], end = y_pred_df.index[-1])
y_pred_df.index = test.index
y_pred_out = y_pred_df["Predictions"]
## START SARIMA

## START ARMA
""" ARMAmodel = SARIMAX(y, order = (1, 0, 1))
ARMAmodel = ARMAmodel.fit()
y_pred = ARMAmodel.get_forecast(len(test.index))
y_pred_df = y_pred.conf_int(alpha = 0.05) 
y_pred_df["Predictions"] = ARMAmodel.predict(start = y_pred_df.index[0], end = y_pred_df.index[-1])
y_pred_df.index = test.index
y_pred_out = y_pred_df["Predictions"] """
## END ARMA

## START ARIMA
""" ARIMAmodel = ARIMA(y, order = (0,0,0))
ARIMAmodel = ARIMAmodel.fit()
y_pred = ARIMAmodel.get_forecast(len(test.index))
y_pred_df = y_pred.conf_int(alpha = 0.05) 
y_pred_df["Predictions"] = ARIMAmodel.predict(start = y_pred_df.index[0], end = y_pred_df.index[-1])
y_pred_df.index = test.index
y_pred_out = y_pred_df["Predictions"] """
## END ARIMA

plt.figure()
plt.plot(train.index, train['Close'], color='black', label='Training')
plt.plot(test.index, test['Close'], color='r', label='Testing')
plt.plot(y_pred_out, color='blue', label = 'SARIMA Predictions')
plt.legend()
plt.show()

# plt.ylabel('Price')
# plt.xlabel('Date')
# plt.xticks(rotation=45)
# plt.plot(ticker.index, ticker['Close'], )
# plt.show()

