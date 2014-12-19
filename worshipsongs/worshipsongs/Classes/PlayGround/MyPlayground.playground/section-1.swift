// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var fifaTeams = ["Brazil", "Croatia", "Mexico", "Cameroon", "Spain", "Netherlands", "Chile", "Australia","Columbia", "Greece", "Ivory Coast", "Japan", "Uruguay", "Costa Rica", "England", "Italy","Switzerland", "Ecuador", "France", "Honduras", "Argentina", "Bosnia-Herzegovia", "Iran","Nigeria","Germany", "Portugal", "Ghana", "USA", "Belgium", "Algeria", "Russia", "Korea"]

var searchResultsOfFifaTeams = fifaTeams

func searchTeamName(searchText: String){
    
    for teamName in fifaTeams
        
    {
        
        if (teamName as NSString).localizedCaseInsensitiveContainsString(searchText)
            
        {
            
            //searchResultsOfFifaTeams.append(teamName)
            let selectedTeam = teamName
            
        }
        
    }
    
}


searchTeamName("Ir")


struct SongModel {
    var title : String
    var lyrics : String
}

var songModel = SongModel(title: "", lyrics: "")

songModel.title = "Helo"
println(songModel.title)


var fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("songs.sqlite")


var searchLyricsQuery = "SELECT lyrics FROM songs where title = 'sample'"
