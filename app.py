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

def app():
    with open('./calendar_event/calendar-event-list.csv') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            sym=''
            if row[4]=='USD' or row[4]=='CNY': 
                sym = secret.Symbol 
                MagicNumber = 10001
            if row[4]=='EUR' : 
                sym = 'EURUSDm'
                MagicNumber = 10002
            if row[4]=='GBP' : 
                sym = 'GBPUSDm'
                MagicNumber = 10003
            if row[4]=='AUD' : 
                sym = 'AUDUSDm'
                MagicNumber = 10004
            if row[4]=='CAD' : 
                sym = 'USDCADm'
                MagicNumber = 10005
            if row[4]=='JPY' : 
                sym = 'USDJPYm'
                MagicNumber = 10006
            if row[4]=='CHF' : 
                sym = 'USDCHFm'
                MagicNumber = 10007
            if row[4]=='NZD' : 
                sym = 'NZDUSDm'
                MagicNumber = 10008
            if row[1] == MyTime() and login.ordersTotal()<2:
                print('Send Order successful at {}'.format(row[1]))
                login.sendOrderBuyStop(sym,secret.Lots,login.price(sym)[0],secret.StopLoss,secret.TakeProfit,MagicNumber,"Eco Impact : {}".format(row[3]))
                login.sendOrderSellStop(sym,secret.Lots,login.price(sym)[1],secret.StopLoss,secret.TakeProfit,MagicNumber,"Eco Impact : {}".format(row[3]))
                #PushMessgeOnly('Send Order successful at {}'.format(row[1]))
                time.sleep(60)
            else:
                print('{} != {}'.format(row[1],MyTime()))
        #time.sleep(1)
if __name__=='__main__':
    r = 0
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



