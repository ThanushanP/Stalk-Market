import pandas as pd
import yfinance as yf
import datetime
from statsmodels.tsa.statespace.sarimax import SARIMAX
from dateutil.relativedelta import relativedelta

from flask import Flask, request, jsonify
from flask_cors import CORS
import logging

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
    

    dictionary = {
        'train': str(train.to_dict()),
        'test': str(test.to_dict()),
        'pred': str(y_pred_out.to_dict()),
    }

    return dictionary

app = Flask(__name__)
CORS(app)
logging.basicConfig(level=logging.DEBUG)


@app.route('/predict', methods=['POST'])
def predict():
    logging.info("Received request: %s", request.get_json())
    try:
        data = request.get_json()
        ticker = data.get('ticker')
        if not ticker:
            response = jsonify({'error': 'Ticker is required'})
            response.status_code = 400
            logging.info("Response: %s", response.get_data(as_text=True))
            return response
        response = jsonify(AppAction(ticker))
        response.status_code = 200
        logging.info("Response: %s", response.get_data(as_text=True))
        return response
    except Exception as e:
        logging.exception("An error occurred while processing the request")
        response = jsonify({'error': 'An internal error occurred'})
        response.status_code = 500
        logging.info("Response: %s", response.get_data(as_text=True))
        return response

if __name__ == '__main__':
    app.run(debug=True)
