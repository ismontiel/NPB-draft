from urllib.request import urlopen as req
from bs4 import BeautifulSoup as soup
import csv

with open("pLions17.csv", "w") as lionsCSV:
    lionsWriter = csv.writer(lionsCSV, delimiter = ',', lineterminator = '\n')


    headers = "name, G, GS, CG, SO, W, L, S, Hld, IP, H, HR, BB, K, RA, ER, ERA, WHIP, \n"
    lionsWriter.writerow(['name', 'G', 'GS', 'CG', 'SO', 'W', 'L', 'S', 'Hld', 'IP', 'H', 'HR', 'BB', 'K', 'RA', 'ER', 'ERA', 'WHIP', '\n'])

    lionStats = 'http://npb.jp/bis/eng/2017/stats/idp1_l.html'
    uClient = req(lionStats)      # Client to go to the page?
    thisHTML = uClient.read()       # Grabbing page?
    uClient.close()                 # Closes connection

    ramen = soup(thisHTML, 'html.parser')       # Creating some soup from the HTML
    statsTable = ramen.table                    # Extracting the stats table

    playerRows = statsTable.findAll("tr", {"class":"ststats"})                          # Extracting all the player rows

    # Extraction of the data
    # For reference, the data table is organized as the following:
    # 0.name, 1.G, 2.W, 3.L, 4.S, 5.hld, 6.CG, 7.SO, 8.PCT, 9.BF, 10.IP, 11.H, 12.HR, 13.BB, 14.intentional BB, 15.Hit batters, 16.K, 17.wild pitches, 18.balks, 19.R, 20.ER, 21.ERA
    for player in playerRows:
        allData = []
        stats = player.findAll("td")    # Find all since we're only looking in the scope of a specific player
        for cell in stats:
            allData.append(cell.text) # NOTE: index 12 is actually the decimal (if any) for index 11
        allData[11] = allData[11] + allData[12]
        allData.pop(12)     # Popping the now extraneous decimal
        allData.pop(0)      # Popping the first cell indicating handedness
        # print(allData)    # Everthing seems to be here
        pWHIP = str((float(allData[13]) + float(allData[11])) / float(allData[10]))


        # lmao at the categories required
        lionsWriter.writerow([allData[0], allData[1], "", allData[6], allData[7], allData[2], allData[3], allData[4], allData[5], allData[10], allData[11], allData[12], allData[13], allData[16], allData[19], allData[20], allData[21], pWHIP, '\n'])
