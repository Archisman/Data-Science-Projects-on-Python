#!/usr/bin/env python
import sys
import math
import array
import numpy as np
import pandas as pd

#Function to calculate daily log returns using actual returns and weights assigned to each signal
#Returns array of daily log returns
def compute_log_returns(_logret_matrix, _weight_matrix):
    _log_returns = np.empty(shape=(0))
    for i in xrange(0, _logret_matrix.shape[0]):
        _log_return = math.log(np.sum(_weight_matrix[i] * np.exp((_logret_matrix[i]))))
        #Append to the series of returns
        _log_returns = np.append(_log_returns, _log_return)
    return _log_returns

def perfstats(_log_returns):
    _annualized_percent_returns = (math.exp(252*np.mean(_log_returns))-1)*100
    _estimate_of_annual_range = math.sqrt(252.0) * np.std(_log_returns)
    _annualized_percent_stdev = ((math.exp(_estimate_of_annual_range) - 1) + (1 - math.exp(-_estimate_of_annual_range)))/2.0 * 100.0
    _sharpe = _annualized_percent_returns/_annualized_percent_stdev
    return _annualized_percent_returns, _annualized_percent_stdev, _sharpe

#Function to compute annualised percent returns using log returns and weights assigned to the signals
def getPerformanceStats(_logret_matrix, _weight_matrix):
    _log_returns = compute_log_returns(_logret_matrix, _weight_matrix)
    _net_log_returns = np.sum(_log_returns)
    _annualized_percent_returns, _annualized_percent_stdev, _sharpe = perfstats(_log_returns)
    print 'Annualise_percent_returns are %f Annualise_percent_stdev is %f Sharpe is %f\n' %(_annualized_percent_returns, _annualized_percent_stdev, _sharpe)

def eval(_logret_matrix):
    # Implement/call your functions here, feel free to import other modules
    _weights_matrix = np.empty(_logret_matrix.shape)
    _weights_matrix.fill(1.0/_logret_matrix.shape[1]) # Equal weight by default, implement your own method to compute weights here
    return _weights_matrix
    # return numpy 2d matrix where ith row represents the weights given to signals on ith day

def __main__():
    if len(sys.argv) > 1:
        _returns_data_filename = sys.argv[1]
        _ret_frame = pd.DataFrame.from_csv(_returns_data_filename)
        _logret_matrix = _ret_frame.values
        for name in _ret_frame.columns:
            _annualized_percent_returns, _annualized_percent_stdev, _sharpe = perfstats(_ret_frame[name])
            print name, 'Annualise_percent_returns are %f Annualise_percent_stdev is %f Sharpe is %f\n' %(_annualized_percent_returns, _annualized_percent_stdev, _sharpe)
        _weight_matrix = eval(_logret_matrix)
        getPerformanceStats(_logret_matrix, _weight_matrix)
    else:
        sys.exit('args: input_signal_combinations_file_path.csv')


if __name__ == '__main__':
    __main__()
