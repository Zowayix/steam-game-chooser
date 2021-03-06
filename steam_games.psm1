import-module (join-path $PSScriptRoot common)

function get_library_list_path(){
    $steamdir = get_steam_path
    return join-path $steamdir steamapps\libraryfolders.vdf
}

function get_appmanifests($libs){
    $libs | % {
        gci "$_\steamapps\*.acf"
    }
}

function parse_appmanifest($path){
    $game = parse_steamkv $path
    $game | add-member game_type steam
    $game | add-member library (split-path -parent $path)
    return $game
}

function parse_library_list($path){
    #There's always a steamapps folder in the install path, seemingly
    get_steam_path

    gc $path | % {
        if($_ -match "^\s*`"(\d+)`"\s+`"(.+)`"$"){
            $matches[2]
        }
    }
}

function get_shared_config($userid){
    $userid = default_userid $userid
    $steamdir = get_steam_path
    $path = join-path $steamdir userdata\$userid\7\remote\sharedconfig.vdf
    return parse_steamkv $path
}

function get_categories($appid, $userid){
    $shared_config = get_shared_config $userid
    $tags = $shared_config.Software.Valve.Steam.Apps.$appid.tags
    return $tags | gm -type NoteProperty | % {
        $tags.($_.name)
    }
}

function get_local_config($userid){
    $userid = default_userid $userid
    $steamdir = get_steam_path
    $path = join-path $steamdir userdata\$userid\config\localconfig.vdf
    return parse_steamkv $path
}

function get_last_played($appid, $userid){
    #This information is in sharedconfig.vdf too, but it's wrong
    $config = get_local_config $userid
    return convert_unix_time $config.Software.Valve.Steam.Apps.$appid.LastPlayed
}

Export-ModuleMember -Function *