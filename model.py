import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt, mpld3
import datetime
# import tensorflow as tf
from statsmodels.tsa.statespace.sarimax import SARIMAX
from dateutil.relativedelta import relativedelta
import json

from fireTS.models import NARX
from sklearn.ensemble import RandomForestRegressor

def AppAction(tick):
    '''
    Given string tick indicating stock ticker
        return json file of matplotlib figure of predictions
    '''
    ## retrieve current date
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
    y = train['Close']

    ##########################################
    # Model Fitting
    #########################################
    SARIMAXmodel = SARIMAX(y, order = (1,0,0), seasonal_order=(2,2,2,12))
    SARIMAXmodel = SARIMAXmodel.fit()
    y_pred = SARIMAXmodel.get_forecast(len(test.index))
    y_pred_df = y_pred.conf_int(alpha = 0.05) 
    y_pred_df['Predictions'] = SARIMAXmodel.predict(start = y_pred_df.index[0], end = y_pred_df.index[-1])
    y_pred_df.index = test.index
    y_pred_out = y_pred_df["Predictions"]

    '''
    Testing out with NN -- see nn-test file
    '''
    
    ## Creating Figure
    fig = plt.gcf()
    plt.plot(train.index, train['Close'], color='black', label='Training')
    plt.plot(test.index, test['Close'], color='r', label='Testing')
    plt.plot(y_pred_out, color='blue', label = 'SARIMA Predictions')
    plt.legend()
    # plt.show()

    ## saving to json
    mpld3.save_json(fig, 'stalker.json')
    ## return json content
    with open('stalker.json') as f:
        out = json.load(f)
    return out
