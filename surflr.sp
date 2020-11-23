#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <cstrike>
#include <sdkhooks>
#include <devzones>
#include <smlib>
#pragma semicolon 1
#pragma newdecls required
bool LRatiliyor = false, InLR[MAXPLAYERS] = false, CanFire[MAXPLAYERS] = false; int istekatan = -1, istekgonderilen = -1, bodysayi[MAXPLAYERS] = 0;public Plugin myinfo = {name = "SURF LR", author = "phiso", description = "Surfte lr atmanıza yarar.", version = "1.0", url = "phiso#3331 - https://discord.gg/D3kcQy3BRx - https://pluginmerkezi.com"};
public void OnMapStart()
{
	char mapismi[128];
	GetCurrentMap(mapismi, sizeof(mapismi));
	char EklentiIsmi[128];
	GetPluginFilename(INVALID_HANDLE, EklentiIsmi, sizeof(EklentiIsmi));
	if (StrContains(mapismi, "surf", false))
	{
		ServerCommand("sm plugins unload %s", EklentiIsmi);
	}
	else
	{
		ServerCommand("sm plugins load %s", EklentiIsmi);
		CreateTimer(180.0, LR_Reklam, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		AddFileToDownloadsTable("sound/Plugin_Merkezi/Surf_LR/lrsarki.mp3");
		PrecacheSound("Plugin_Merkezi/Surf_LR/lrsarki.mp3");
	}
}
public Action LR_Reklam(Handle Timer){CPrintToChatAll("{darkred}[pluginmerkezi.com]{lime}!lr yazarak LR atabilirsiniz!");}
public void OnPluginStart()
{
	HookEvent("player_hurt", hurt);
	HookEvent("weapon_fire", weaponfire);
	HookEvent("player_death", Oyuncu_Oldugunde);
	RegConsoleCmd("sm_lr", menuac); 
}
public Action menuac(int client, int args)
{
	if (!LRatiliyor)
	{
		if (IsPlayerAlive(client))
		{
			menu22(client);
			istekatan = client;
		}
		else
		{
			CPrintToChat(client, "{darkred}[pluginmerkezi.com] {darkblue}!lr {default}için {darkblue}yaşıyor {lime}olmalısınız.");
		}
	}
	else
	{
		CPrintToChat(client, "{darkred}[pluginmerkezi.com] {orchid}Şuan {default}bir {orange}LR {green}atılıyor biraz bekle dostum.");
	}
}

public Action menu22(int client)
{
	Menu menu = new Menu(MenuCallBack);
	menu.SetTitle("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n^-^ Kim ile LR atmak istersin? ^-^\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n");
	char sName[MAX_NAME_LENGTH], sUserId[10];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && i != client && IsPlayerAlive(i))
		{
			GetClientName(i, sName, sizeof(sName));
			IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
			menu.AddItem(sUserId, sName);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuCallBack(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(itemNum, info, sizeof(info));
		GetClientOfUserId(StringToInt(info));
		int target = GetClientOfUserId(StringToInt(info));
		if (IsPlayerAlive(target))
		{
			istekgonderilen = target;
			evethayir(target);
		}
		else
		{
			CPrintToChat(client, "{darkred}[pluginmerkezi.com] {lime}Seçtiğiniz kişi {darkred}ölü.");
		}
	}
}
public Action evethayir(int client)
{
	Menu menu = new Menu(MenuCallBack2);
	menu.SetTitle("%N - Sizinle LR atmak istiyor, LR atmak istiyor musunuz?", istekatan);
	
	char opcionmenu[124];
	
	Format(opcionmenu, sizeof(opcionmenu), "✓ Evet, istiyorum.");
	menu.AddItem("option1", opcionmenu);
	
	Format(opcionmenu, sizeof(opcionmenu), "✕ Hayır, istemiyorum.");
	menu.AddItem("option2", opcionmenu);

	menu.Display(client, 15);
}

public int MenuCallBack2(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(itemNum, info, sizeof(info));
		if (strcmp(info, "option1") == 0)
		{
			float konum[3];
			konum[0] = -5901.15;
			konum[1] = -3092.97;
			konum[2] = 1982.09;
			float konum2[3];
			konum2[0] = -5891.07;
			konum2[1] = -2732.26;
			konum2[2] = 1982.09;
			TeleportEntity(istekatan, konum, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(istekgonderilen, konum2, NULL_VECTOR, NULL_VECTOR);
			SetEntityHealth(istekgonderilen, 100);
			SetEntityHealth(istekatan, 100);
			Client_RemoveAllWeapons(istekatan);
			Client_RemoveAllWeapons(istekgonderilen);
			GiveDeagle(istekatan);
			CPrintToChatAll("{darkred}[pluginmerkezi.com] {orange}%N {darkblue}ile {orange}%N LR atıyor", istekatan, istekgonderilen);
			CPrintToChatAll("{darkred}[pluginmerkezi.com] {orange}İlk atış hakkı {darkblue}%N'de!", istekatan);
			LRatiliyor = true;
			InLR[istekgonderilen] = true;
			InLR[istekatan] = true;
			CanFire[istekatan] = true;
			CanFire[istekgonderilen] = false;
			bodysayi[istekatan] = 0;
			bodysayi[istekgonderilen] = 0;
			Handle HudText = CreateHudSynchronizer();
			SetHudTextParams(-1.0, -0.5, 0.5, 255, 0, 0, 255, 2, 1.0, 0.1, 0.2);
			ShowSyncHudText(istekatan, HudText, "ATIŞ HAKKI SİZDE !");
			ShowSyncHudText(istekgonderilen, HudText, "ATIŞ HAKKI KARŞI TARAFTA !");
			SDKHook(istekatan, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(istekgonderilen, SDKHook_OnTakeDamage, OnTakeDamage);
			EmitSoundToClient(istekgonderilen, "Plugin_Merkezi/Surf_LR/lrsarki.mp3");
			EmitSoundToClient(istekatan, "Plugin_Merkezi/Surf_LR/lrsarki.mp3");
		}
		else if (strcmp(info, "option2") == 0)
		{
			CPrintToChat(istekgonderilen, "{darkred}[pluginmerkezi.com]{orange}LR isteğini {darkred}reddetdin.");
			CPrintToChat(istekatan, "{darkred}[pluginmerkezi.com]{lime}%N {orange}LR isteğini {darkred}reddetdi.", istekgonderilen);
			InLR[istekgonderilen] = false;
			InLR[istekatan] = false;
			istekgonderilen = 0;
			istekatan = 0;
		}
	}
}
public Action weaponfire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (LRatiliyor)
	{
		if (IsClientInGame(client))
		{
			if (InLR[client])
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				char weaponname[256];
				if (IsValidEntity(weapon))
				{
					GetEdictClassname(weapon, weaponname, sizeof(weaponname));
				}
				if (CanFire[client])
				{
					if (StrEqual(weaponname, "weapon_deagle", true))
					{
						if (istekatan == client)
						{
							CanFire[istekgonderilen] = true;
							CanFire[istekatan] = false;
							CreateTimer(1.0, silahsil, istekatan);
							GiveDeagle(istekgonderilen);
							Handle hHudText = CreateHudSynchronizer();
							SetHudTextParams(-1.0, -0.5, 0.5, 255, 0, 0, 255, 2, 1.0, 0.1, 0.2);
							ShowSyncHudText(istekgonderilen, hHudText, "ATIŞ HAKKI SİZDE !");
						}
						else if (istekgonderilen == client)
						{
							CanFire[istekatan] = true;
							CanFire[istekgonderilen] = false;
							CreateTimer(1.0, silahsil, istekgonderilen);
							GiveDeagle(istekatan);
							Handle hHudText = CreateHudSynchronizer();
							SetHudTextParams(-1.0, -0.5, 0.5, 255, 0, 0, 255, 2, 1.0, 0.1, 0.2);
							ShowSyncHudText(istekatan, hHudText, "ATIŞ HAKKI SİZDE !");
						}
						CPrintToChatAll("{darkred}[pluginmerkezi.com] {orange}%N {lime}atış hakkını kullandı.", client);
					}
				}
				else
				{
					if (StrEqual(weaponname, "weapon_deagle", true))
					{
						ForcePlayerSuicide(client);
						CPrintToChatAll("{darkred}[pluginmerkezi.com] {orange}%N {lime}adlı oyuncu {green}sırası gelmeden sıktığı için {lightred}öldürüldü.", client);
						ResetLR();
					}
				}
			}
		}
	}
	return Plugin_Handled;
}
public void ResetLR()
{
	LRatiliyor = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			InLR[i] = false;
			bodysayi[i] = 0;
			CanFire[i] = false;
			SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			StopSound(i, SNDCHAN_AUTO, "Plugin_Merkezi/Surf_LR/lrsarki.mp3");
		}
	}
	istekgonderilen = -1;
	istekatan = -1;
}
public void GiveDeagle(int client){if (IsClientInGame(client)){Client_GiveWeaponAndAmmo(client, "weapon_deagle", _, 0, _, 1);}}
public void Zone_OnClientEntry(int client, const char[] zone)
{
	if (StrContains(zone, "lrkapi", false) == 0)
	{
		if (LRatiliyor)
		{
			float yatak[3];
			yatak[0] = -5678.90; 
			yatak[1] = -3198.10; 
			yatak[2] = 2017.16; 
			TeleportEntity(client, yatak, NULL_VECTOR, NULL_VECTOR);
			CPrintToChat(client, "{darkred}[pluginmerkezi.com] {green}Şuanda bir {darkred}LR {green}atıldığı için yatağa {default}ışınlandınız.");
		}
	}
}
public void Zone_OnClientLeave(int client, const char[] zone)
{
	if (StrContains(zone, "lroda", false) == 0)
	{
		if (InLR[client])
		{
			float yatak[3];
			yatak[0] = -5678.90; 
			yatak[1] = -3198.10;
			yatak[2] = 2017.16;
			TeleportEntity(istekatan, yatak, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(istekgonderilen, yatak, NULL_VECTOR, NULL_VECTOR);		
			CPrintToChatAll("{darkred}[pluginmerkezi.com]{green}Herhangi {darkred}LR{lime} atan biri{darkred}LR {lime}odasından ayrıldığı için lr iptal edildi.");
			CreateTimer(1.0, DelayReset);
		}
	}
}
public Action Oyuncu_Oldugunde(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (LRatiliyor)
	{
		if (InLR[client])
		{
			float yatak[3];
			yatak[0] = -5678.90; //x
			yatak[1] = -3198.10; //y
			yatak[2] = 2017.16; //z
			CPrintToChat(client, "{darkred}[pluginmerkezi.com] {lime}LR`yi {darkred}kaybettin :C");
			CPrintToChatAll("{darkred}[pluginmerkezi.com] {darkred}LR {lime}bitti. {darkred}!lr {green}yazarak {darkred}lr {green}isteği atabilirsiniz.");
			TeleportEntity(istekgonderilen, yatak, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(istekatan, yatak, NULL_VECTOR, NULL_VECTOR);
			CreateTimer(1.0, DelayReset);
		}		
	}
}
public Action DelayReset(Handle Timer){ResetLR();}public Action silahsil(Handle Timer, any client){Client_RemoveAllWeapons(client, "", false);}
public Action hurt(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int hitgroup = GetEventInt(event, "hitgroup");
	if(LRatiliyor)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char weaponname[256];
		if (IsValidEntity(weapon))
		{
			GetEdictClassname(weapon, weaponname, sizeof(weaponname));
		}
		if (InLR[client] && InLR[attacker])
		{
			if (StrEqual(weaponname, "weapon_deagle"))
			{
				if (hitgroup == 1)
				{
					CPrintToChatAll("{darkred}[pluginmerkezi.com] {orange}%N {lime}adlı oyuncu {green}LR'yi kazandı!", attacker);
				}
				else
				{
					bodysayi[attacker]++;
					if (bodysayi[attacker] > 1)
					{
						ForcePlayerSuicide(attacker);
						CPrintToChatAll("{darkred}[pluginmerkezi.com] {orange}%N {green}2 body attığı için {lightred}öldürüldü.", attacker);
						ResetLR();
					}
					CPrintToChatAll("{darkred}[pluginmerkezi.com] {lime}%N {darkred}Body {lime}attı bir kez daha body atarsa {darkred}öldürülecek.", attacker);
				}
			}
		}
	}
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(victim) && IsValidClient(attacker))
	{
		if (LRatiliyor)
		{
			if (InLR[victim] && !InLR[attacker])
			{
				damage = 0.0;
				CPrintToChat(attacker, "{darkred}[pluginmerkezi.com]{lime}Şuanda {darkred}%N {red}LR {lime}atıyor, {red}LR {lime}atan birine vuramazsın.", victim);
				return Plugin_Changed;
			}
			else if (!InLR[victim] && InLR[attacker])
			{
				damage = 0.0;
				CPrintToChat(attacker, "{darkred}[pluginmerkezi.com]{lime}Şuanda {darkred}LR {lime}atıyorsun, {darkred}LR {lime}atmayan birine vuramazsın.");
				return Plugin_Changed;
			}
		}	
	}
	return Plugin_Continue;
}
stock bool IsValidClient(int iClient)
{
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient) || IsFakeClient(iClient))
	{
		return false;
	}
	return true;
}