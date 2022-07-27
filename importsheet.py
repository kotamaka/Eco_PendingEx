from symtable import Symbol
import ezsheets
import gspread
from oauth2client.service_account import ServiceAccountCredentials 
from pprint import pprint 

scope = [
'https://www.googleapis.com/auth/spreadsheets',
'https://www.googleapis.com/auth/drive'
]

creds = ServiceAccountCredentials.from_json_keyfile_name("credentials.json", scope) 
client = gspread.authorize(creds) 
sheet = client.open("Forex-Factory").worksheet("week2")
data = sheet.get_all_values()

daylist = 'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
monthlist = 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'

for i in data:
    date = i[0]
    time = i[1]
    symbol = i[3]
    if date != '' and time != '' and time != 'All Day':
        '''if "Aug" in date:
            rd = date.replace('Aug ','/08/')
            print(rd,time,symbol)'''


