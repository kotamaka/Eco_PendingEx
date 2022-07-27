import csv

with open('./calendar_event/calendar-event-list.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        print(row[1])