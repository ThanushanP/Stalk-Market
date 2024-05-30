import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt, mpld3
import datetime
import tensorflow as tf
from statsmodels.tsa.statespace.sarimax import SARIMAX
from dateutil.relativedelta import relativedelta
import json

from fireTS.models import NARX
from sklearn.ensemble import RandomForestRegressor

tick = 'VFV.TO' # temp ticker
current_date = datetime.date.today()
formatted_Cur = current_date.strftime('%Y-%m-%d')
### set start, end, and training split dates
lb = str(int(formatted_Cur[:4]) - 2) + '-01-01'
ub = (current_date + relativedelta(months=2) + relativedelta(day=2)).strftime('%Y-%m-%d')
cut = (current_date - relativedelta(months=1) + relativedelta(day=1)).strftime('%Y-%m-%d')

## obtaining stock market dataset given ticker
ticker = yf.download(tick, start = lb, end = ub)['Close']
ticker.to_csv('ticker.csv')
ticker = pd.read_csv('ticker.csv')

## format time index to year month day
ticker.index = pd.to_datetime(ticker['Date'], format='%Y-%m-%d')

## data split for training and testing
train = ticker[ticker.index < pd.to_datetime(cut, format='%Y-%m-%d')]
test = ticker[ticker.index > pd.to_datetime(cut, format='%Y-%m-%d')]


xtrain, xtest = [[val.timestamp()] for val in train.index], [[val.timestamp()] for val in test.index]
ytrain, ytest = train['Close'], test['Close']

## NARX
mdl = NARX(RandomForestRegressor(), auto_order=2, exog_order=[3], exog_delay=[1])
print(mdl)
# Fit the model and make the prediction
mdl.fit(xtrain, ytrain)
forecast_step = 36
yforecast = mdl.forecast(xtest[:-forecast_step], 
                          ytest[:-forecast_step], 
                          step=forecast_step, 
                          X_future=xtest[-forecast_step:-1])
plt.figure()
yforecast = pd.Series(yforecast, index=ytest.index[-forecast_step:])
plt.plot(train.index, train['Close'], color='black', label='Training')
ytest.plot(label='Actual', color='r')
yforecast.plot(label='forecast', color='blue')
plt.legend()
plt.show()

""" # RNN Model
model = tf.keras.Sequential([
    tf.keras.layers.SimpleRNN(50, activation='relu', input_shape=(xtrain.shape[1], 1)),
    tf.keras.layers.Dense(1)
])

# Compilation
model.compile(optimizer='adam', loss='mse')

# Training
model.fit(xtrain, ytrain, epochs=200, verbose=0)

# Evaluation
loss = model.evaluate(xtest, ytest)
print(f'Test Loss: {loss}') """