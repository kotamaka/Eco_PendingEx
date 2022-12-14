from datetime import datetime
from datetime import timedelta
import datetime,time
import secret
import csv,login,requests

#test_time = '07/22/2022 13:45:00'
def PushMessgeOnly(result):
    
    host = 'https://notify-api.line.me/api/notify'
    
    headers = {'content-type':'application/x-www-form-urlencoded','Authorization':'Bearer '+secret.Token_notify}
    r = requests.post(host, headers=headers, data={'message':result})
    print(r.text)
    return 200

def MyTime():
    now = datetime.datetime.now()
    real_date_time = now.strftime("%m/%d/%Y %H:%M:%S")
    
    return real_date_time

def DeleyTime():
    now = datetime.datetime.now()
    tdelta = timedelta(minutes=3)
    open = now-tdelta
    after_date_time = open.strftime("%m/%d/%Y %H:%M:%S")
    
    return after_date_time
r = 0
def app():
    with open('./calendar_event/calendar-event-list.csv') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            sym=''
            if row[4]=='USD' or row[4]=='CNY': 
                sym = secret.Symbol 
                MagicNumber = 10001
                OrderType = 'OP_SELL'
            if row[4]=='EUR' : 
                sym = 'EURUSDm'
                MagicNumber = 10002
                OrderType = 'OP_SELL'
            if row[4]=='GBP' : 
                sym = 'GBPUSDm'
                MagicNumber = 10003
                OrderType = 'OP_SELL'
            if row[4]=='AUD' : 
                sym = 'AUDUSDm'
                MagicNumber = 10004
                OrderType = 'OP_SELL'
            if row[4]=='CAD' : 
                sym = 'USDCADm'
                MagicNumber = 10005
                OrderType = 'OP_BUY'
            if row[4]=='JPY' : 
                sym = 'USDJPYm'
                MagicNumber = 10006
                OrderType = 'OP_BUY'
            if row[4]=='CHF' : 
                sym = 'USDCHFm'
                MagicNumber = 10007
                OrderType = 'OP_BUY'
            if row[4]=='NZD' : 
                sym = 'NZDUSDm'
                MagicNumber = 10008
                OrderType = 'OP_SELL'
            if row[1] == MyTime() and login.ordersTotal()<2 and login.EnablePending=="y":
                if row[3] == "LOW":
                    print('Send Order successful at {}'.format(row[1]))
                    login.sendOrderBuyLimit(sym,secret.Lots,login.PriceLimit(sym)[0],login.SL_BUYSTOP(sym),secret.TakeProfit,MagicNumber,"Impact : {}".format(row[3]))
                    login.sendOrderSellLimit(sym,secret.Lots,login.PriceLimit(sym)[1],login.SL_SELLSTOP(sym),secret.TakeProfit,MagicNumber,"Impact : {}".format(row[3]))
                    PushMessgeOnly('\nSend Order successful! \nAt {}\nImpact : {}'.format(row[1],row[3]))
                    time.sleep(60)
                else:
                    print('Send Order successful at {}'.format(row[1]))
                    login.sendOrderBuyStop(sym,secret.Lots,login.PriceStop(sym)[0],login.SL_BUYSTOP(sym),secret.TakeProfit,MagicNumber,"Impact : {}".format(row[3]))
                    login.sendOrderSellStop(sym,secret.Lots,login.PriceStop(sym)[1],login.SL_SELLSTOP(sym),secret.TakeProfit,MagicNumber,"Impact : {}".format(row[3]))
                    PushMessgeOnly('\nSend Order successful! \nAt {}\nImpact : {}'.format(row[1],row[3]))
                    time.sleep(60)
            if row[1] == MyTime() and login.ordersTotal()<2 and login.EnablePending!="y":
                if OrderType=='OP_BUY':
                    print('Send Order successful at {}'.format(row[1]))
                    login.OP_BUY(sym,secret.Lots,secret.StopLoss,secret.TakeProfit,MagicNumber,"Impact : {}".format(row[3]))
                    #PushMessgeOnly('Send Order successful at {}'.format(row[1]))
                    time.sleep(60)
                    r = 0
                    return r
                if OrderType=='OP_SELL':
                    print('Send Order successful at {}'.format(row[1]))
                    login.OP_SELL(sym,secret.Lots,secret.StopLoss,secret.TakeProfit,MagicNumber,"Impact : {}".format(row[3]))
                    #PushMessgeOnly('Send Order successful at {}'.format(row[1]))
                    time.sleep(60)
                    r = 0
                    return r
            else:
                print('{} != {}'.format(row[1],MyTime()))
        #time.sleep(1)
if __name__=='__main__':
    while True :
        app()
        print('Round : {}'.format(r))
        r+=1
        time.sleep(1)

'''now = datetime.datetime.now()
st = now.timestamp()
tdelta = timedelta(minutes=3)
open = now-tdelta
real_date_time = now.strftime("%d/%m/%Y %H:%M:%S")
after_date_time = open.strftime("%d/%m/%Y %H:%M:%S")
print(real_date_time)
print(after_date_time)'''



