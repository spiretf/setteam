#pragma semicolon 1
#include <sourcemod>
#include <tf2>

public Plugin:myinfo = {
	name = "setteam",
	author = "Icewind",
	description = "Set players team",
	version = "0.1",
	url = "https://spire.tf"
};

int force_team[MAXPLAYERS+1];

public OnPluginStart() {
	RegServerCmd("sm_setteam", SetTeam, "Set a players team");
	RegServerCmd("sm_forceteam", ForceExec, "Set a players team and keep them there");

	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_JoinTeam, "autoteam");
}

int parse_team(const char[] team_str) {
    int team = 0;

    if (StrEqual("red", team_str)) {
        team = 2;
    }
    if (StrEqual("blue", team_str)) {
        team = 3;
    }
    if (StrEqual("spec", team_str)) {
        team = 1;
    }

    return team;
}

public Action:SetTeam(args) {
	char player[128];
	char team_str[128];

    if (args != 2) {
        PrintToServer("Usage: sm_setteam <player> red|blue|spec");

        return Plugin_Handled;
    }
    GetCmdArg(1, player, sizeof(player));
    GetCmdArg(2, team_str, sizeof(team_str));

    int team = parse_team(team_str);

    if (team == 0) {
        PrintToServer("Usage: sm_setteam <player> red|blue|spec");

        return Plugin_Handled;
    }

    int client = FindTarget(0, player, false, true);

    force_team[client] = 0;
    ChangeClientTeam(client, team);

    return Plugin_Handled;
}

public Action:ForceExec(args) {
    char player[128];
    char team_str[128];

    if (args != 2) {
        PrintToServer("Usage: sm_forceteam <player> red|blue|spec|free");

        return Plugin_Handled;
    }
    GetCmdArg(1, player, sizeof(player));
    GetCmdArg(2, team_str, sizeof(team_str));

    int team = parse_team(team_str);

    int client = FindTarget(0, player, false, true);

    if (team == 0) {
        force_team[client] = team;

        return Plugin_Handled;
    }

    ChangeClientTeam(client, team);
    force_team[client] = team;

	return Plugin_Handled;
}

public Action:Command_JoinTeam(client, const String:command[], argc) {
    if (force_team[client] > 0) {
        return Plugin_Handled;
    } else {
        return Plugin_Continue;
    }
}

public void OnClientConnected(client) {
    force_team[client] = 0;
}

public void OnClientDisconnect(client) {
    force_team[client] = 0;
}
