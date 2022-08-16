import MetaTrader5 as mt
import pandas as pd
import plotly.express as px
from datetime import datetime
import time

from requests import request
import secret

mt.initialize()

_login = secret.login
_password = secret.password
_server = secret.server

mt.login(_login,_password,_server)

account_info = mt.account_info()
#print(account_info)

login_number = account_info.login
balance = account_info.balance
equity = account_info.equity
company = account_info.company

print('Welcome to Eco_PendingEx')
EnablePending = input('EnablePending?<y/n>')
time.sleep(2)
print('Login Successful..')
print('Account Number : ',login_number)
print('Balance : ',balance)
print('Equity : ',equity)
print('Company : ',company)



num_symbols = mt.symbols_total()

symbol_info = mt.symbol_info(secret.Symbol)._asdict()
#print(symbol_info)

symbol_price_gold = mt.symbol_info_tick(secret.Symbol)._asdict()
#print(symbol_price_gold['time'])

ohic_data = pd.DataFrame(mt.copy_rates_range(
    secret.Symbol,
    mt.TIMEFRAME_D1,
    datetime(2022,1,1),
    datetime.now()))
#print(ohic_data)

tick_data = pd.DataFrame(mt.copy_ticks_range(
    secret.Symbol,
    datetime(2022,5,1),
    datetime.now(),
    mt.COPY_TICKS_ALL))
#print(tick_data)

#Ordertotal
orderstotal = mt.positions_total()
#print(orderstotal)

position = mt.positions_get()
#print(position[0][0])

#symbol = "EURUSDm"
#point = mt.symbol_info(symbol).point
def PriceStop(symbol):
    point = mt.symbol_info(symbol).point
    if(symbol=="XAUUSDm"):
        price_pd_buy_stop = mt.symbol_info_tick(symbol).ask+1000*point
        price_pd_sell_stop = mt.symbol_info_tick(symbol).ask-1000*point
    else:
        price_pd_buy_stop = mt.symbol_info_tick(symbol).ask+100*point
        price_pd_sell_stop = mt.symbol_info_tick(symbol).ask-100*point
    return price_pd_buy_stop,price_pd_sell_stop

def PriceLimit(symbol):
    point = mt.symbol_info(symbol).point
    if(symbol=="XAUUSDm"):
        price_pd_buy_limit = mt.symbol_info_tick(symbol).ask-1000*point
        price_pd_sell_limit = mt.symbol_info_tick(symbol).ask+1000*point
    else:
        price_pd_buy_limit = mt.symbol_info_tick(symbol).ask-100*point
        price_pd_sell_limit = mt.symbol_info_tick(symbol).ask+100*point
    return price_pd_buy_limit,price_pd_sell_limit

def SL_BUYSTOP(symbol):
    point = mt.symbol_info(symbol).point
    if(symbol=="XAUUSDm"):
        sl = PriceStop(symbol)[0]-secret.StopLoss*point*100
    else:
        sl = PriceStop(symbol)[0]-secret.StopLoss*point*10
    return sl
def SL_SELLSTOP(symbol):
    point = mt.symbol_info(symbol).point
    if(symbol=="XAUUSDm"):
        sl = PriceStop(symbol)[1]+secret.StopLoss*point*100
    else:
        sl = PriceStop(symbol)[1]+secret.StopLoss*point*10
    return sl
'''def SL_BUYLIMIT(symbol):
    if(symbol=="XAUUSDm"):
        sl = PriceLimit(symbol)[0]-secret.StopLoss*point*100
    else:
        sl = PriceLimit(symbol)[0]-secret.StopLoss*point*10
    return sl
def SL_SELLLIMIT(symbol):
    if(symbol=="XAUUSDm"):
        sl = PriceLimit(symbol)[1]+secret.StopLoss*point*100
    else:
        sl = PriceLimit(symbol)[1]+secret.StopLoss*point*10
    return sl'''

#print(PriceLimit(symbol)[0],SL_BUYSTOP(symbol))

def sendOrderBuyStop(symbol,lots,price,sl,tp,magic,comment):
    request = {
        "action": mt.TRADE_ACTION_PENDING,
        "symbol": symbol,
        "volume": lots,
        "type": mt.ORDER_TYPE_BUY_STOP,
        "price": price,
        "sl": sl,
        "tp": tp,
        "deviation": 20,
        "magic": magic,
        "comment": comment,
        "type_time": mt.ORDER_TIME_GTC,
        "type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)
    return result

def sendOrderSellStop(symbol,lots,price,sl,tp,magic,comment):
    request = {
        "action": mt.TRADE_ACTION_PENDING,
        "symbol": symbol,
        "volume": lots,
        "type": mt.ORDER_TYPE_SELL_STOP,
        "price": price,
        "sl": sl,
        "tp": tp,
        "deviation": 20,
        "magic": magic,
        "comment": comment,
        "type_time": mt.ORDER_TIME_GTC,
        "type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)
    return result

#sendOrderBuyStop(secret.Symbol,secret.Lots,secret.StopLoss,secret.TakeProfit,secret.MagicNumber,"Test send")
#sendOrderSellStop(secret.Symbol,secret.Lots,secret.StopLoss,secret.TakeProfit,secret.MagicNumber,"Test send")

def sendOrderBuyLimit(symbol,lots,price,sl,tp,magic,comment):
    request = {
        "action": mt.TRADE_ACTION_PENDING,
        "symbol": symbol,
        "volume": lots,
        "type": mt.ORDER_TYPE_BUY_LIMIT,
        "price": price,
        "sl": sl,
        "tp": tp,
        "deviation": 20,
        "magic": magic,
        "comment": comment,
        "type_time": mt.ORDER_TIME_GTC,
        "type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)
    return result

def sendOrderSellLimit(symbol,lots,price,sl,tp,magic,comment):
    request = {
        "action": mt.TRADE_ACTION_PENDING,
        "symbol": symbol,
        "volume": lots,
        "type": mt.ORDER_TYPE_SELL_LIMIT,
        "price": price,
        "sl": sl,
        "tp": tp,
        "deviation": 20,
        "magic": magic,
        "comment": comment,
        "type_time": mt.ORDER_TIME_GTC,
        "type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)
    return result
#-----------------------------------
def OP_BUY(symbol,lots,sl,tp,magic,comment):
    request = {
        "action": mt.TRADE_ACTION_DEAL,
        "symbol": symbol,
        "volume": lots,
        "type": mt.ORDER_TYPE_BUY,
        "price": mt.symbol_info_tick(symbol).ask,
        "sl": sl,
        "tp": tp,
        "deviation": 5,
        "magic": magic,
        "comment": comment,
        #"type_time": mt.ORDER_TIME_GTC,
        #"type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)
    return result

def OP_SELL(symbol,lots,sl,tp,magic,comment):
    request = {
        "action": mt.TRADE_ACTION_DEAL,
        "symbol": symbol,
        "volume": lots,
        "type": mt.ORDER_TYPE_SELL,
        "price": mt.symbol_info_tick(symbol).bid,
        "sl": sl,
        "tp": tp,
        "deviation": 5,
        "magic": magic,
        "comment": comment,
        #"type_time": mt.ORDER_TIME_GTC,
        #"type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)
    return result

#OP_BUY("EURUSDm",secret.Lots,secret.StopLoss,secret.TakeProfit,secret.MagicNumber,"Test send")
#OP_SELL(secret.Symbol,secret.Lots,secret.StopLoss,secret.TakeProfit,secret.MagicNumber,"Test send")
#-----------------------------------
def closeOrder(): #close by position
    request = {
        "action": mt.TRADE_ACTION_DEAL,
        "symbol": secret.Symbol,
        "volume": 0.01,
        "type": mt.ORDER_TYPE_SELL,
        #"position": position[0][0],
        "price": mt.symbol_info_tick(secret.Symbol).ask,
        "sl": 0.0,
        "tp": 0.0,
        "deviation": 20,
        "magic": 234000,
        "comment": "python script open",
        "type_time": mt.ORDER_TIME_GTC,
        "type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)

def closePendingOrder(): #close by position
    request = {
        "action": mt.TRADE_ACTION_REMOVE,
        "symbol": secret.Symbol,
        "volume": 0.01,
        "type": mt.ORDER_TYPE_CLOSE_BY,
        #"position": position[0][0],
        "price": mt.symbol_info_tick(secret.Symbol).ask,
        "sl": 0.0,
        "tp": 0.0,
        "deviation": 20,
        "magic": 234000,
        "comment": "python script open",
        "type_time": mt.ORDER_TIME_GTC,
        "type_filling": mt.ORDER_FILLING_IOC,
        }
    result = mt.order_send(request)
    print(result)

#closePendingOrder()
def ordersTotal():
    orders=mt.orders_total()
    return orders

#ordersTotal()