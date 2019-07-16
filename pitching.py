from urllib.request import urlopen as req
from bs4 import BeautifulSoup as soup
import csv

# Creating a dictionary so I can translate the URL team indicator into a readable one for the spreadsheet
teamDict = {
"m": "Chiba",
"d": "Chunichi",
"h": "Fukuoka",
"t": "Hanshin",
"c": "Hiroshima",
"f": "Hokkaido",
"bs": "Orix",
"l": "Saitama",
"e": "Tohoku",
"s": "Tokyo",
"yb": "Yokohama",
"db": "Yokohama",
"g": "Yomiuri"
}

# My scraping method <3
def pitcherScrape():
    with open("pitching_08-15.csv", "w") as pitcherCSV:
        myWriter = csv.writer(pitcherCSV, delimiter = ',', lineterminator = '\n')

        # The header columns:
        myWriter.writerow(['name', 'team', 'G', 'GS', 'CG', 'SO', 'W', 'L', 'S', 'Hld', 'IP', 'H', 'HR', 'BB', 'K', 'RA', 'ER', 'ERA', 'WHIP', 'salary', 'year',\
        'year10', 'year11', 'year12', 'year13', 'year14', 'year15', 'teamID', 'team1', 'team2', 'team3', 'team4', 'team5', 'team6', 'team7', 'team8', 'team9',\
        'team10', 'team11', 'team12', 'leagueC', 'leagueP', '\n'])

        # Looping through the years
        for year in range(2015, 2007, -1):

            # Looping through each team in a year
            # teamCount = 0             # This is a test counter to see if all teams have been accounted for in a given year
            for team in teamDict:
                if not (year == 2011 and team == "db"):         # In 2011, both team URLs work, so this conditional will only spit back one of them
                    try:
                        pStats = 'http://npb.jp/bis/eng/{}/stats/idp1_{}.html'.format(year, team)
                        # print(pStats)

                        uClient = req(pStats)      # Client to go to the page?
                        thisHTML = uClient.read()       # Grabbing page?
                        uClient.close()                 # Closes connection

                        ramen = soup(thisHTML, 'html.parser')       # Creating some soup from the HTML
                        statsTable = ramen.table                    # Extracting the stats table

                        playerRows = statsTable.findAll("tr", {"class":"ststats"})                          # Extracting all the player rows

                        # Extraction of the pitching statistics
                        # For reference, the data table is organized as the following:
                        # 0.name, 1.G, 2.W, 3.L, 4.S, 5.hld, 6.CG, 7.SO, 8.PCT, 9.BF, 10.IP, 11.H, 12.HR, 13.BB, 14.intentional BB, 15.Hit batters, 16.K, 17.wild pitches, 18.balks, 19.R, 20.ER, 21.ERA
                        for player in playerRows:
                            allData = []        # Since the webpage doesn't name its td tags, I'll just grab them all for a given player and sort it afterward
                            stats = player.findAll("td")    # Find all td tags since we're only looking in the scope of a specific player
                            for cell in stats:
                                allData.append(cell.text) # NOTE: index 12 is actually the decimal (if any) for index 11

                            allData[11] = allData[11] + allData[12]
                            allData.pop(12)     # Popping the now extraneous decimal
                            allData.pop(0)      # Popping the first cell indicating handedness

                            # For some forFun reason, there are some non-numeric characters in the data (without a legend), so I have to see if the stats can even be converted
                            try:
                                pWHIP = str((float(allData[13]) + float(allData[11])) / float(allData[10]))
                                dumArr = teamDummy(team)

                                # lmao at the categories required
                                myWriter.writerow([allData[0], teamDict.get(team), allData[1], "", allData[6], allData[7], allData[2], allData[3], allData[4],\
                                 allData[5], allData[10], allData[11], allData[12], allData[13], allData[16], allData[19], allData[20], allData[21], pWHIP, "",\
                                   year, "", "", "", "", "", "", "", dumArr[0], dumArr[1], dumArr[2], dumArr[3], dumArr[4], dumArr[5], dumArr[6], dumArr[7],\
                                   dumArr[8], dumArr[9], dumArr[10], dumArr[11], dumArr[12], dumArr[13]])
                            except:
                                None
                        # teamCount = teamCount + 1;
                    except:
                        None
            # print(str(year) + ": " + str(teamCount))


# This function returns an array denoting the dummy variables appropriate for each team
def teamDummy(teamName):
    if(teamName == "m"):
        return ["1", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1"]
    if(teamName == "d"):
        return ["0", "1", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1", "0"]
    if(teamName == "h"):
        return ["0", "0", "1", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1"]
    if(teamName == "t") :
        return ["0", "0", "0", "1", "0", "0", "0", "0", "0", "0", "0", "0", "1", "0"]
    if(teamName == "c"):
        return ["0", "0", "0", "0", "1", "0", "0", "0", "0", "0", "0", "0", "1", "0"]
    if(teamName == "f"):
        return ["0", "0", "0", "0", "0", "1", "0", "0", "0", "0", "0", "0", "0", "1"]
    if(teamName == "bs"):
        return ["0", "0", "0", "0", "0", "0", "1", "0", "0", "0", "0", "0", "0", "1"]
    if(teamName == "l"):
        return ["0", "0", "0", "0", "0", "0", "0", "1", "0", "0", "0", "0", "0", "1"]
    if(teamName == "e"):
        return ["0", "0", "0", "0", "0", "0", "0", "0", "1", "0", "0", "0", "0", "1"]
    if(teamName == "s"):
        return ["0", "0", "0", "0", "0", "0", "0", "0", "0", "1", "0", "0", "1", "0"]
    if(teamName == "yb" or teamName == "db"):
        return ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1", "0", "1", "0"]
    if(teamName == "g"):
        return ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1", "1", "0"]

pitcherScrape()
