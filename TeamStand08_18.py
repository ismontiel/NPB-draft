from urllib import urlopen as req
from bs4 import BeautifulSoup as soup

filename = "stats18_08.csv"
f = open(filename, "w")

headers = "Year, League, Team, Wins, Losses, Ties, WinPCT, \n"
f.write(headers)

for year in range(2018, 2007, -1):
    seasonStats = 'http://npb.jp/bis/eng/{0}/stats/'.format(year)
    uClient = req(seasonStats)
    thisHTML = uClient.read()
    uClient.close()

    ramen = soup(thisHTML, 'html.parser')

    leagueTables = ramen.findAll("table", {"class":"standings"})

    for table in leagueTables:
        league = table.td.text
        teamRows = table.findAll("tr")[2:]
        #print teamRows
        for team in teamRows:
            #Not really necessary, but a little more organized than putting it in the write function
            teamName = team.find("td", {"class":"standingsTeam"}).text
            totWins = team.find("td", {"class":"standingsWin"}).text
            totLosses = team.find("td", {"class":"standingsLose"}).text
            tie = team.find("td", {"class":"standingsTai"}).text
            winPCT = team.find("td", {"class":"standingsPct"}).text

            f.write(str(year) + "," + league + "," + teamName + "," + totWins + "," + totLosses + "," + tie + "," + winPCT + "\n")

f.close
