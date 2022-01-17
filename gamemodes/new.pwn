#include <a_samp>
#include <dc_cmd>
#include <foreach>
#include <sscanf2>
#include <streamer>

#define PRESSED(%0) (((newkeys & (%0))== (%0)) && ((oldkeys & (%0)) != (%0)))
#define function%0(%1) forward %0(%1); public %0(%1)
#define format:%0( %0[0] = EOS,format(%0,sizeof(%0),
//#define IsPlayerLogged(%0) (GetPVarInt(%0, "gLogged") && uInfo[%0][uID])

#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_PURPLE 0x800080FF
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_BLUE 0x0000BBAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_RED 0xAA3333AA
#define COLOR_LIME 0x10F441AA
#define COLOR_MAGENTA 0xFF00FFFF
#define COLOR_NAVY 0x000080AA
#define COLOR_AQUA 0xF0F8FFAA
#define COLOR_CRIMSON 0xDC143CAA
#define COLOR_FLBLUE 0x6495EDAA
#define COLOR_BISQUE 0xFFE4C4AA
#define COLOR_BLACK 0x000000AA
#define COLOR_CHARTREUSE 0x7FFF00AA
#define COLOR_BROWN 0XA52A2AAA
#define COLOR_CORAL 0xFF7F50AA
#define COLOR_GOLD 0xB8860BAA
#define COLOR_GREENYELLOW 0xADFF2FAA
#define COLOR_INDIGO 0x4B00B0AA
#define COLOR_IVORY 0xFFFF82AA
#define COLOR_LAWNGREEN 0x7CFC00AA
#define COLOR_SEAGREEN 0x20B2AAAA
#define COLOR_LIMEGREEN 0x32CD32AA //<--- Dark lime
#define COLOR_MIDNIGHTBLUE 0X191970AA
#define COLOR_MAROON 0x800000AA
#define COLOR_OLIVE 0x808000AA
#define C_PODSKAZ 0x8F8F8FAA

#define DRIVING_SCHOOL_VIRTUAL_WORLD 320

#define MAX_DRIVING_SCHOOL_CHECKPOINTS 20
#define MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS 20
#define MAX_DRIVING_SCHOOL_LESSONS 14

#define dDrivingSchool 250
#define dDrivingSchoolLessonSuccess 270
#define dEmpty 9999

new flash_timer[MAX_PLAYERS];
new flash_indicator;

new debug_mode = 1;

new
	g_str_least[32],
	g_str_small[256],
	g_str_big[512];

new Text:HelpArrowsTD[4];
new Text:HelpButtonsTD[3][2];

enum E_DRIVING_SCHOOL_TD
{
	PlayerText:driving_school_health_td,
	PlayerText:driving_school_timer_td,
	PlayerText:driving_school_hp_box_td
}
new Text:DrivingSchoolStaticTD[3];
new DrivingSchoolTD[MAX_PLAYERS][E_DRIVING_SCHOOL_TD];

enum E_DRIVING_SCHOOL_SUCCESS_TD
{
	PlayerText:driving_school_medal_td,
	PlayerText:driving_school_time_td,
	PlayerText:driving_school_health_td
}
new Text:DrivingSchoolSuccessStaticTD[9];
new DrivingSchoolSuccessTD[MAX_PLAYERS][E_DRIVING_SCHOOL_SUCCESS_TD];

enum E_DRIVING_SCHOOL_VW
{
	driving_school_vw_active
}
new DrivingSchoolVirtualWorld[MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS][E_DRIVING_SCHOOL_VW];

enum E_TEMP
{
	temp_belt,

    temp_driving_school_lesson,
    temp_driving_school_started,
    temp_driving_school_checkpoint,
	temp_driving_school_vehicle_id,
	temp_driving_school_timer,
	temp_driving_school_counter,
	temp_driving_school_td_timer,
	temp_driving_school_help_af[4],
	Float:temp_driving_start_pos[3]
}
new TempInfo[MAX_PLAYERS][E_TEMP];

enum E_PLAYER_INFO
{
	uID,
	uName[MAX_PLAYER_NAME],
	uDrivingLessonsPassed[MAX_DRIVING_SCHOOL_LESSONS],
	uDrivingLessonsStarted[4],
	uLic[4],
	uLicTime[4]
}
new uInfo[MAX_PLAYERS][E_PLAYER_INFO];

enum E_VEHICLE_INFO
{
	vehicle_engine,
	vehicle_lights,
	vehicle_grave_object[3]
}
new vInfo[MAX_VEHICLES][E_VEHICLE_INFO];

new const Float:DS_Checkpoints_Lesson2[][3] =
{
	{-2058.1067,-130.8329,34.9814},
	{-2051.5354,-142.6053,34.9805},
	{-2058.6545,-155.4515,34.9778},
	{-2060.4121,-158.2050,35.0286},
	{-2050.4092,-172.0959,34.9792},
	{-2057.9028,-184.1288,34.9791},
	{-2058.4607,-199.0801,34.9786}
};

new const Float:DS_Checkpoints_Lesson3[][3] =
{
	{-2318.1301, -1591.3228, 483.1674},
	{-2041.4725,-193.7183,35.3203}
};

new const Float:DS_Checkpoints_Lesson5[][3] =
{
	{-2023.6190,-269.5620,34.9168},
	{-2086.2690,-271.4882,34.9193},
	{-2087.9626,-126.2531,34.9148}
};

new const Float:DS_Checkpoints_Lesson6[][3] =
{
	{1556.7942,-101.7480,19.9383}, //
	{1467.0768,-208.7750,10.3990}, //
	{1320.9958,-195.5028,16.5341}, //
	{1220.1064,-110.4782,39.4774}, //
	{1121.7168,-59.7002,19.6423}, //
	{989.6609,-85.8565,21.2676}, //
	{861.8526,-95.3980,26.7604}, //
	{724.4709,-175.8031,20.5413}, //
	{628.7659,-195.0237,9.7098}, //
	{549.5950,-204.7448,16.5991}, //
	{438.8172,-295.9502,6.5781}, //
	{316.0426,-361.1162,9.2290}, //
	{355.6172,-404.3339,18.9548}, //
	{322.3149,-570.0662,9.2132}, //
	{303.1415,-788.7520,4.1020}, //
	{248.4217,-948.8580,33.9232}, //
	{189.3318,-1101.2048,63.1264}, //
	{100.5316,-1272.2064,45.0970}, //
	{-83.6322,-1427.0443,12.0533} // Финиш
};

new const Float:DS_Checkpoints_Lesson7[][3] =
{
	{-1581.5941,610.9472,69.7882}, //
	{-1519.8641,676.0270,138.8421}, //
	{-1485.7720,712.0159,94.5870}, //
	{-1383.7583,819.3657,49.1904}, //
	{-1299.2408,908.5935,85.2642}, //
	{-1255.4894,954.5131,138.8406}, //
	{-1215.3859,996.7209,88.2786}, //
	{-1164.8828,1050.0754,52.0644}, //
	{-1117.6144,1099.7085,37.7304} // Финиш
};

new const Float:DS_Checkpoints_Lesson8[][3] =
{
	{1551.5552,-1338.7643,329.4729},//
	{1545.7909,-1224.9702,261.1632},//
	{1493.6180,-1149.2578,135.3880},//
	{1474.8896,-1182.3683,107.9311},//
	{1432.0256,-1120.1376,92.8966},//
	{1390.6272,-1047.2587,57.9729},//
	{1389.8893,-960.6755,41.3636},//
	{1402.2605,-921.8911,35.6370}//Финиш
};

new const Float:DS_Checkpoints_Lesson10[][3] =
{
	{-1853.2885,1103.6876,58.2898},
	{-1764.4313,1099.7202,59.5922},
	{-1714.4314,1095.2404,57.0050},
	{-1713.8844,897.5162,33.6791},
	{-1713.9700,799.9075,32.3031},
	{-1682.0371,705.9565,30.7827}
};

new const Float:DS_Checkpoints_Lesson11[][3] =
{
	{-847.0583,1062.6404,40.7224},
	{-759.7208,1125.2667,33.1675},
	{-638.7007,1180.9717,31.3785},
	{-581.1481,1194.0023,27.7515},
	{-477.1293,1216.9614,30.0837},
	{-391.3094,1236.7281,43.6686}
};

new const Float:DS_Checkpoints_Lesson13[][3] =
{
	{-1302.3649,613.3439,-0.4203},
	{-1052.9757,520.0873,-0.3107},
	{-977.0287,344.5337,-0.2600},
	{-1036.8043,-121.4472,-0.1919},
	{-971.3460,-293.2999,-0.2616},
	{-566.7998,-327.0440,-0.3826},
	{-317.5326,-366.7320,-0.4090},
	{-198.3375,-677.3048,-0.3356},
	{-109.6838,-876.4573,-0.5720},
	{52.8399,-923.3969,-0.5698},
	{64.0816,-1109.1141,-0.7512},
	{56.1744,-1230.7544,-0.5992},
	{36.7405,-1366.2759,-0.6256},
	{51.3316,-1579.3569,-0.2707},
	{119.1017,-1948.9655,-0.4247},
	{250.0111,-1948.3196,-0.5970}
};

new const Float:DS_Checkpoints_Lesson14[][3] =
{
	{95.9029,358.7133,-0.6007},
	{386.1875,455.7715,-0.3812},
	{658.8198,531.3266,0.4081},
	{818.7607,573.7889,0.4437},
	{1028.3497,620.9578,1.0962},
	{1187.7152,616.9482,-0.3929},
	{1524.1283,588.3859,-0.4426},
	{1621.6920,609.4677,7.8309}
};

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

function Flasher()
{
    flash_indicator = !flash_indicator;
}

function FlashDownHelpArrow(playerid)
{
	if(flash_indicator)
		TextDrawShowForPlayer(playerid, HelpArrowsTD[1]);
	else
        TextDrawHideForPlayer(playerid, HelpArrowsTD[1]);
}

function Freezer(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		TogglePlayerControllable(playerid, 1);
	}
}

function FlashHelpButton(playerid)
{
	for(new i; i<3; i++)
	{
	    TextDrawShowForPlayer(playerid, HelpButtonsTD[i][0]);
		TextDrawShowForPlayer(playerid, HelpButtonsTD[i][1]);
	}
	new veh_id = GetPlayerVehicleID(playerid);
	if(flash_indicator)
	{
	    if(!TempInfo[playerid][temp_belt])
	    {
			TextDrawShowForPlayer(playerid, HelpButtonsTD[0][0]);
			TextDrawShowForPlayer(playerid, HelpButtonsTD[0][1]);
			return 1;
		}
		else if(!vInfo[veh_id][vehicle_engine])
	    {
			TextDrawShowForPlayer(playerid, HelpButtonsTD[1][0]);
			TextDrawShowForPlayer(playerid, HelpButtonsTD[1][1]);
			return 1;
		}
		else if(!vInfo[veh_id][vehicle_lights])
	    {
			TextDrawShowForPlayer(playerid, HelpButtonsTD[2][0]);
			TextDrawShowForPlayer(playerid, HelpButtonsTD[2][1]);
			return 1;
		}
	}
	else
	{
        if(!TempInfo[playerid][temp_belt])
	    {
			TextDrawHideForPlayer(playerid, HelpButtonsTD[0][0]);
			TextDrawHideForPlayer(playerid, HelpButtonsTD[0][1]);
			return 1;
		}
		else if(!vInfo[veh_id][vehicle_engine])
	    {
			TextDrawHideForPlayer(playerid, HelpButtonsTD[1][0]);
			TextDrawHideForPlayer(playerid, HelpButtonsTD[1][1]);
			return 1;
		}
		else if(!vInfo[veh_id][vehicle_lights])
	    {
			TextDrawHideForPlayer(playerid, HelpButtonsTD[2][0]);
			TextDrawHideForPlayer(playerid, HelpButtonsTD[2][1]);
			return 1;
		}
	}
	return 1;
}

function SecondTimer()
{
	foreach(new i:Player)
	{
	    if(TempInfo[i][temp_driving_school_lesson])
	    {
	        if(!TempInfo[i][temp_driving_school_started])
			{
			    if(!IsPlayerInRangeOfPoint(i, 5.0, TempInfo[i][temp_driving_start_pos][0], TempInfo[i][temp_driving_start_pos][1], TempInfo[i][temp_driving_start_pos][2]) && !TempInfo[i][temp_driving_school_td_timer])
				{
				
                    ShowPlayerLessonLoseDialog(i, "Вы не выполнили все указания");
				}
			}
	        if(TempInfo[i][temp_driving_school_started])
	        {
	            
	            if(2 <= TempInfo[i][temp_driving_school_lesson] <= 4)
				{
				    if(GetVehicleHealthInt(GetPlayerVehicleID(i)) <= 970)
				    	ShowPlayerLessonLoseDialog(i, "Машина повреждена");
			 	}
		        TempInfo[i][temp_driving_school_counter]++;
		        if(TempInfo[i][temp_driving_school_timer] > 0)
		        {
		            TempInfo[i][temp_driving_school_timer]--;
		            if(TempInfo[i][temp_driving_school_timer] <= 0)
		            {
	                    ShowPlayerLessonLoseDialog(i, "Время вышло");
		            }
		        }
		        UpdatePlayerDrivingSchoolTD(i);
	        }
			if(TempInfo[i][temp_driving_school_td_timer] > 0)
			{
			    TempInfo[i][temp_driving_school_td_timer]--;
			    if(TempInfo[i][temp_driving_school_td_timer] <= 0)
			    {
					HidePlayerLessonSuccessTD(i);
					
					uInfo[i][uDrivingLessonsPassed][TempInfo[i][temp_driving_school_lesson]-1] = 1;

					CheckPlayerLessons(i);

			        RespawnPlayerAfterLesson(i);
			    }
			}
			if(TempInfo[i][temp_driving_school_lesson] == 8)
			{
				new Float:pPos[3];
				GetPlayerPos(i, pPos[0], pPos[1], pPos[2]);
				if(pPos[2] < DS_Checkpoints_Lesson8[TempInfo[i][temp_driving_school_checkpoint]][2]-2)
				    ShowPlayerLessonLoseDialog(i, "Вы упали");
			}
	    }
	}
}

public OnGameModeInit()
{
	LoadTD();

	LoadMap();
	DisableInteriorEnterExits();
	SetGameModeText("Blank Script");
	AddPlayerClass(0, -2032.6014,-95.2597,35.1641, 269.1425, 0, 0, 0, 0, 0, 0);
	SetTimer("SecondTimer", 1000, true);
	SetTimer("Flasher", 300, true);
	CreatePickup(1239, 23, -2026.7771, -114.3430, 1035.1719, 0);

    CreatePickup(19132, 23, -2026.5967,-102.0626,35.1641, 0);
    CreatePickup(19132, 23, 1455.1343,-130.2843,2927.1428, 0);
    
    CreatePickup(1239, 23, 1469.7548,-137.5443,2927.1428, 0);
    CreatePickup(1239, 23, 1472.9192,-137.5447,2927.1428, 0);
    CreatePickup(1239, 23, 1469.7631,-139.9840,2927.1428, 0);
    CreatePickup(1239, 23, 1472.7772,-139.9845,2927.1428, 0);

	Create3DTextLabel("Водительские права\nЛевый 'ALT'", COLOR_SEAGREEN, 1469.7548,-137.5443,2927.1428, 15.0, 0, 1);
	Create3DTextLabel("Мотоциклы\nЛевый 'ALT'", COLOR_SEAGREEN, 1472.9192,-137.5447,2927.1428, 15.0, 0, 1);
	Create3DTextLabel("Вертолеты\nЛевый 'ALT'", COLOR_SEAGREEN, 1469.7631,-139.9840,2927.1428, 15.0, 0, 1);
	Create3DTextLabel("Лодки\nЛевый 'ALT'", COLOR_SEAGREEN, 1472.7772,-139.9845,2927.1428, 15.0, 0, 1);
	
	CreatePickup(1239, 23, 1465.2056,-130.4537,2927.1428, 0);
	Create3DTextLabel("Информация\nЛевый 'ALT'", COLOR_SEAGREEN, 1465.2056,-130.4537,2927.1428, 15.0, 0, 1);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPosEx(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	GivePlayerMoney(playerid, 20000);
	GetPlayerName(playerid, uInfo[playerid][uName], MAX_PLAYER_NAME);
	uInfo[playerid][uID] = playerid+1;
	
	for(new i; i<10; i++)
	    RemovePlayerAttachedObject(playerid, i);
	
	TempInfo[playerid][temp_belt] = 0;

    TempInfo[playerid][temp_driving_school_lesson] = 0;
    TempInfo[playerid][temp_driving_school_started] = 0;
    TempInfo[playerid][temp_driving_school_checkpoint] = 0;
    TempInfo[playerid][temp_driving_school_vehicle_id] = 0;
    TempInfo[playerid][temp_driving_school_timer] = 0;
    TempInfo[playerid][temp_driving_school_counter] = 0;
    TempInfo[playerid][temp_driving_school_td_timer] = 0;
	
	for(new i; i<MAX_DRIVING_SCHOOL_LESSONS; i++)
		uInfo[playerid][uDrivingLessonsPassed][i] = 0;

	for(new i; i<4; i++)
	{
	    uInfo[playerid][uLic][i] = 0;
	    uInfo[playerid][uLicTime][i] = 0;
	}
	    
	LoadPlayerTD(playerid);
	    
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(TempInfo[playerid][temp_driving_school_lesson])
	{
	    if(GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD >= 0 && GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD < MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS)
		{
		    DrivingSchoolVirtualWorld[GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD][driving_school_vw_active] = 0;
		}
	    if(TempInfo[playerid][temp_driving_school_vehicle_id] != INVALID_VEHICLE_ID)
	    {
	        DestroyVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]);
	        if(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object] != 0 && IsValidObject(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object]))
	        {
	            for(new i; i<3; i++)
	            {
		            DestroyObject(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][i]);
		            vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][i] = 0;
	            }
	        }
	        TempInfo[playerid][temp_driving_school_vehicle_id] = INVALID_VEHICLE_ID;
	    }
    }
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(TempInfo[playerid][temp_driving_school_lesson])
	{
	    RespawnPlayerAfterLesson(playerid);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(TempInfo[playerid][temp_belt])
    {
        if(IsAMoto(vehicleid))
        {
            RemovePlayerAttachedObject(playerid, 9);
        }
        else
        {
		    format:g_str_small("%s отстегнул ремень безопасности", uInfo[playerid][uName]);
			SetPlayerChatBubble(playerid, g_str_small, COLOR_PURPLE, 15.0, 1000);
			SendClientMessage(playerid, COLOR_GREEN, "Вы отстегнули ремень безопасности");
		}
		TempInfo[playerid][temp_belt] = 0;
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
    {
        if(TempInfo[playerid][temp_driving_school_lesson])
		{
		    ShowPlayerLessonLoseDialog(playerid, "Вы вышли из машины");
    		//PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
    	}
    	if(TempInfo[playerid][temp_belt])
    	{
	        if(IsPlayerAttachedObjectSlotUsed(playerid, 9))
			{
   				RemovePlayerAttachedObject(playerid, 9);
			}
		}
    }
	else if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
		if(!TempInfo[playerid][temp_driving_school_lesson] && !debug_mode)
		{
		    if(!IsAMoto(vehicleid) && !IsAHeli(vehicleid) && !IsABoat(vehicleid))
		    {
				if(!uInfo[playerid][uLic][0])
				{
				    SendClientMessage(playerid, COLOR_RED, "У вас отсутствует лицензия на вождение. Получить ее можно в Автошколе");
				    RemovePlayerFromVehicle(playerid);
				}
				else if(getdate() > uInfo[playerid][uLicTime][0])
				{
				    for(new i; i<4; i++)
				        uInfo[playerid][uDrivingLessonsPassed][i] = 0;
				    SendClientMessage(playerid, COLOR_RED, "Ваша лицензия на вождение больше не действительна.");
				    SendClientMessage(playerid, COLOR_RED, "Обновить срок действия лицензии можно в Автошколе.");
				}
		    }
			else if(IsAMoto(vehicleid))
		    {
				if(!uInfo[playerid][uLic][1])
				{
				    SendClientMessage(playerid, COLOR_RED, "У вас отсутсвует лицензия на мотоциклы. Получить ее можно в Автошколе");
				    RemovePlayerFromVehicle(playerid);
				}
				else if(getdate() > uInfo[playerid][uLicTime][1])
				{
				    for(new i=4; i<8; i++)
				        uInfo[playerid][uDrivingLessonsPassed][i] = 0;
				    SendClientMessage(playerid, COLOR_RED, "Ваша лицензия на мотоциклы больше не действительна.");
				    SendClientMessage(playerid, COLOR_RED, "Обновить срок действия лицензии можно в Автошколе.");
				}
		    }
		    else if(IsABoat(vehicleid))
		    {
				if(!uInfo[playerid][uLic][3])
				{
				    SendClientMessage(playerid, COLOR_RED, "У вас отсутсвует лицензия на лодки. Получить ее можно в Автошколе");
				    RemovePlayerFromVehicle(playerid);
				}
				else if(getdate() > uInfo[playerid][uLicTime][3])
				{
				    for(new i=8; i<11; i++)
				        uInfo[playerid][uDrivingLessonsPassed][i] = 0;
				    SendClientMessage(playerid, COLOR_RED, "Ваша лицензия на лодки больше не действительна.");
				    SendClientMessage(playerid, COLOR_RED, "Обновить срок действия лицензии можно в Автошколе.");
				    RemovePlayerFromVehicle(playerid);
				}
		    }
		    else if(IsAHeli(vehicleid))
		    {
				if(!uInfo[playerid][uLic][2])
				{
				    SendClientMessage(playerid, COLOR_RED, "У вас отсутсвует лицензия на вертолеты. Получить ее можно в Автошколе");
				    RemovePlayerFromVehicle(playerid);
				}
				else if(getdate() > uInfo[playerid][uLicTime][2])
				{
				    for(new i=11; i<14; i++)
				        uInfo[playerid][uDrivingLessonsPassed][i] = 0;
				    SendClientMessage(playerid, COLOR_RED, "Ваша лицензия на вертолеты больше не действительна.");
				    SendClientMessage(playerid, COLOR_RED, "Обновить срок действия лицензии можно в Автошколе.");
				    RemovePlayerFromVehicle(playerid);
				}
		    }
	    }
	}
	if(TempInfo[playerid][temp_belt])
	    TempInfo[playerid][temp_belt] = 0;
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(TempInfo[playerid][temp_driving_school_lesson])
	{
	    if(TempInfo[playerid][temp_driving_school_started])
     	{
			switch(TempInfo[playerid][temp_driving_school_lesson])
			{
	      		case 1:
				{
			        DisablePlayerRaceCheckpoint(playerid);
			        ShowPlayerLessonSuccessTD(playerid);
			    }
			    case 2:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson2);
			    }
			    case 3:
			    {
			        if(TempInfo[playerid][temp_driving_school_checkpoint] == 0)
			        {
				        ShowPlayerHelpArrows(playerid);
				 		SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Используйте стрелочки (стрелка вниз на клавиатуре) для управления амфибией в полете.");
			 		}
			        RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson3);
			    }
			    case 4:
			    {
			        DisablePlayerRaceCheckpoint(playerid);
			        ShowPlayerLessonSuccessTD(playerid);
			    }
			    case 5:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson5);
			    }
			    case 6:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson6);
			    }
			    case 7:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson7);
			    }
			    case 8:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson8);
			    }
			    case 9:
			    {
			        DisablePlayerRaceCheckpoint(playerid);
			        ShowPlayerLessonSuccessTD(playerid);
			    }
	      		case 10:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson10);
			    }
			    case 11:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson11);
			    }
			    case 12:
			    {
			        DisablePlayerRaceCheckpoint(playerid);
			        ShowPlayerLessonSuccessTD(playerid);
			    }
	      		case 13:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson13);
			    }
			    case 14:
			    {
					RebuildPlayerCheckpoint(playerid, DS_Checkpoints_Lesson14);
			    }
			}
		}
	}

	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(TempInfo[playerid][temp_driving_school_lesson])
	{
	    HidePlayerLessonSuccessTD(playerid);
		uInfo[playerid][uDrivingLessonsPassed][TempInfo[playerid][temp_driving_school_lesson]-1] = 1;
		CheckPlayerLessons(playerid);
		TempInfo[playerid][temp_driving_school_td_timer] = 0;
		
		/*if(clickedid == DrivingSchoolSuccessStaticTD[6])
		{
		    RespawnPlayerAfterLesson(playerid);
		}*/
		if(clickedid == DrivingSchoolSuccessStaticTD[7])
		{
  			CancelSelectTextDraw(playerid);
		    StartLesson(playerid, TempInfo[playerid][temp_driving_school_lesson]+1);
		}
		if(clickedid == DrivingSchoolSuccessStaticTD[8])
		{
  			CancelSelectTextDraw(playerid);
		    RespawnPlayerAfterLesson(playerid);
		}
		/*if(clickedid == Text:INVALID_TEXT_DRAW)
		{
		    RespawnPlayerAfterLesson(playerid);
		}*/
		//CancelSelectTextDraw(playerid);
	}
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	if(2 <= TempInfo[playerid][temp_driving_school_lesson] <= 4)
	{
	    if(GetVehicleHealthInt(vehicleid) <= 970)
	    	ShowPlayerLessonLoseDialog(playerid, "Машина повреждена");
 	}
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_NO))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        new vehicleid = GetPlayerVehicleID(playerid);
	        TempInfo[playerid][temp_belt] = !TempInfo[playerid][temp_belt];
	        if(IsAMoto(vehicleid))
			{
			    if(TempInfo[playerid][temp_belt])
			    {
			        switch(random(5))
					{
					    case 0: SetPlayerAttachedObject(playerid, 9, 18645, 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
					    case 1: SetPlayerAttachedObject(playerid, 9, 18976, 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
					    case 2: SetPlayerAttachedObject(playerid, 9, 18977, 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
					    case 3: SetPlayerAttachedObject(playerid, 9, 18978, 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
					    case 4: SetPlayerAttachedObject(playerid, 9, 18979, 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
					}
				}
				else
                    RemovePlayerAttachedObject(playerid, 9);
			}
	        else
	        {
				if(TempInfo[playerid][temp_belt])
				{
					format:g_str_small("%s пристегнул ремень безопасности", uInfo[playerid][uName]);
					SetPlayerChatBubble(playerid, g_str_small, COLOR_PURPLE, 15.0, 1000);
					SendClientMessage(playerid, COLOR_GREEN, "Вы пристегнули ремень безопасности");
				}
				else
				{
				    format:g_str_small("%s отстегнул ремень безопасности", uInfo[playerid][uName]);
					SetPlayerChatBubble(playerid, g_str_small, COLOR_PURPLE, 15.0, 1000);
					SendClientMessage(playerid, COLOR_GREEN, "Вы отстегнули ремень безопасности");
				}
			}
			if(TempInfo[playerid][temp_driving_school_lesson])
        	{
				if(!TempInfo[playerid][temp_driving_school_help_af][0])
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Теперь заведите двигатель.");
				    SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите '2' чтобы завести двигатель.");
				}
				TempInfo[playerid][temp_driving_school_help_af][0] = 1;
			}
	    }
	}
	if(PRESSED(KEY_SUBMISSION))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        new
				engine, lights, alarm, doors, bonnet, boot, objective,
				vehicleid = GetPlayerVehicleID(playerid);
	        
	        if(TempInfo[playerid][temp_driving_school_lesson])
	        {
	     		if(!TempInfo[playerid][temp_belt] && !vInfo[vehicleid][vehicle_engine])
				{
					if(!TempInfo[playerid][temp_driving_school_help_af][1])
					{
					    SendClientMessage(playerid, COLOR_RED, "[АШ]: Пристегнитесь, прежде чем завести двигатель");
						SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'N' чтобы пристегнуть ремень безопасности.");
						TempInfo[playerid][temp_driving_school_help_af][1] = 1;
					}
					return 1;
				}
				else
				{
                    if(!TempInfo[playerid][temp_driving_school_help_af][2])
					{
					    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Теперь включите фары.");
				    	SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'Левый ALT' чтобы включить фары.");
					}
				}
			}

			vInfo[vehicleid][vehicle_engine] = !vInfo[vehicleid][vehicle_engine];
			
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsExEx(vehicleid, vInfo[vehicleid][vehicle_engine], lights, alarm, doors, bonnet, boot, objective);
			
			if(!vInfo[vehicleid][vehicle_engine])
			{
			    format:g_str_small("%s заглушил двигатель", uInfo[playerid][uName]);
				SetPlayerChatBubble(playerid, g_str_small, COLOR_PURPLE, 15.0, 1000);
			}
			else
			{
			    format:g_str_small("%s завел двигатель", uInfo[playerid][uName]);
				SetPlayerChatBubble(playerid, g_str_small, COLOR_PURPLE, 15.0, 1000);
			}
		}
	}
	if(PRESSED(KEY_WALK))
	{
	    if(IsPlayerInRangeOfPoint(playerid, 1.5, -2026.5967,-102.0626,35.1641))
		{
		    SetPlayerPosEx(playerid, 1455.1343,-130.2843,2927.1428);
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 1455.1343,-130.2843,2927.1428))
		{
		    SetPlayerPosEx(playerid, -2026.5967,-102.0626,35.1641);
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 1465.2056,-130.4537,2927.1428))
		{
		    ShowPlayerDialog(playerid, dEmpty, DIALOG_STYLE_MSGBOX, "Автошкола", "Информация.\nТра-та-та", "ОК", "");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 1469.7548,-137.5443,2927.1428))
		{
		    if(!uInfo[playerid][uDrivingLessonsStarted][0])
		    {
		        SetPVarInt(playerid, "DrivingSchool:BuyLessonID", 0);
		        return ShowPlayerDialog(playerid, dDrivingSchool+8, DIALOG_STYLE_MSGBOX, "Автошкола", "\
				{ffffff}Для получения водительских прав вам\n\
				потребуется пройти 4 урока.\n\n\
				Стоимость курса: {008000}1000$.\n\
				{ffffff}Желаете начать?", "Начать", "Отмена");
   			}
		        
		    format:g_str_big("\
				Урок\tСтатус\n\
				1. Впервые за рулём\t%s\n\
				2. Дорога домой\t%s\n\
				3. Спуск смерти\t%s\n\
				4. Похороните Джона\t%s",
				(uInfo[playerid][uDrivingLessonsPassed][0]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][1]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][2]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][3]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

		    ShowPlayerDialog(playerid, dDrivingSchool+4, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 1472.9192,-137.5447,2927.1428))
		{
		    if(!uInfo[playerid][uDrivingLessonsStarted][1])
		    {
		        SetPVarInt(playerid, "DrivingSchool:BuyLessonID", 1);
		        return ShowPlayerDialog(playerid, dDrivingSchool+8, DIALOG_STYLE_MSGBOX, "Автошкола", "\
				{ffffff}Для получения лицензии на мотоциклы вам\n\
				потребуется пройти 4 урока.\n\n\
				Стоимость курса: {008000}1000$.\n\
				{ffffff}Желаете начать?", "Начать", "Отмена");
   			}
		    format:g_str_big("\
				Урок\tСтатус\n\
				1. Скоро на работу\t%s\n\
				2. Пыль в глаза\t%s\n\
				3. Тропа смерти\t%s\n\
				4. Двухколесный паркур\t%s",
				(uInfo[playerid][uDrivingLessonsPassed][4]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][5]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][6]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][7]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

		    ShowPlayerDialog(playerid, dDrivingSchool+5, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 1469.7631,-139.9840,2927.1428))
		{
		    if(!uInfo[playerid][uDrivingLessonsStarted][2])
		    {
		        SetPVarInt(playerid, "DrivingSchool:BuyLessonID", 2);
		        return ShowPlayerDialog(playerid, dDrivingSchool+8, DIALOG_STYLE_MSGBOX, "Автошкола", "\
				{ffffff}Для получения лицензии на вертолеты вам\n\
				потребуется пройти 3 урока.\n\n\
				Стоимость курса: {008000}1000$.\n\
				{ffffff}Желаете начать?", "Начать", "Отмена");
   			}
		    format:g_str_big("\
				Урок\tСтатус\n\
				1. Раскрутить лопасти\t%s\n\
				2. Ниже Карлсона\t%s\n\
				3. Тоннель Смерти\t%s",
				(uInfo[playerid][uDrivingLessonsPassed][8]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][9]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][10]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

		    ShowPlayerDialog(playerid, dDrivingSchool+6, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 1472.7772,-139.9845,2927.1428))
		{
		    if(!uInfo[playerid][uDrivingLessonsStarted][3])
		    {
		        SetPVarInt(playerid, "DrivingSchool:BuyLessonID", 3);
		        return ShowPlayerDialog(playerid, dDrivingSchool+8, DIALOG_STYLE_MSGBOX, "Автошкола", "\
				{ffffff}Для получения лицензии на лодки вам\n\
				потребуется пройти 3 урока.\n\n\
				Стоимость курса: {008000}1000$.\n\
				{ffffff}Желаете начать?", "Начать", "Отмена");
   			}
		    format:g_str_big("\
				Урок\tСтатус\n\
				1. Греби веслом\t%s\n\
				2. По течению\t%s\n\
				3. На волне\t%s",
				(uInfo[playerid][uDrivingLessonsPassed][11]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][12]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
				(uInfo[playerid][uDrivingLessonsPassed][13]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

			ShowPlayerDialog(playerid, dDrivingSchool+7, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
		}
	}
	if(PRESSED(KEY_FIRE))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    new
				engine, lights, alarm, doors, bonnet, boot, objective,
				vehicleid = GetPlayerVehicleID(playerid);

            if(TempInfo[playerid][temp_driving_school_lesson])
	        {
	            /*if(!TempInfo[playerid][temp_belt] && !vInfo[vehicleid][vehicle_engine])
				{
					if(!TempInfo[playerid][temp_driving_school_help_af][2])
					{
					    SendClientMessage(playerid, COLOR_RED, "[АШ]: Пристегнитесь, прежде чем включить фары");
						SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'N' чтобы пристегнуть ремень безопасности.");
					}
					return 1;
				}*/
	     		if(!vInfo[vehicleid][vehicle_engine] && !vInfo[vehicleid][vehicle_lights])
				{
					if(!TempInfo[playerid][temp_driving_school_help_af][2])
					{
					    SendClientMessage(playerid, COLOR_RED, "[АШ]: Заведите двигатель, прежде чем включить фары.");
						SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите '2' чтобы завести двигатель.");
						TempInfo[playerid][temp_driving_school_help_af][2] = 1;
					}
					return 1;
				}
				else
				{
				    if(!TempInfo[playerid][temp_driving_school_help_af][3])
					{
					    HidePlayerHelpButtons(playerid);
					    switch(TempInfo[playerid][temp_driving_school_lesson])
					    {
	      					case 1:
								SetPlayerRaceCheckpoint(playerid, 1,
									-2024.3085, -248.2156, 35.3203,
									-2024.3085, -248.2156, 35.3203,
									5.0);
	                        case 2:
								SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson2[0][0], DS_Checkpoints_Lesson2[0][1], DS_Checkpoints_Lesson2[0][2],
								 	DS_Checkpoints_Lesson2[1][0], DS_Checkpoints_Lesson2[1][1], DS_Checkpoints_Lesson2[1][2],
								 	5.0);
	                        case 3:
							{
								SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson3[0][0], DS_Checkpoints_Lesson3[0][1], DS_Checkpoints_Lesson3[0][2],
								 	DS_Checkpoints_Lesson3[1][0], DS_Checkpoints_Lesson3[1][1], DS_Checkpoints_Lesson3[1][2],
								 	5.0);
					 		}
	                        case 4:
	                        {
								SetPlayerRaceCheckpoint(playerid, 1,
									885.2811,-1072.8804,24.1901,
								 	885.2811,-1072.8804,24.1901,
								 	5.0);
						 	}
						 	case 5:
							{
							    SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson5[0][0], DS_Checkpoints_Lesson5[0][1], DS_Checkpoints_Lesson5[0][2],
								 	DS_Checkpoints_Lesson5[1][0], DS_Checkpoints_Lesson5[1][1], DS_Checkpoints_Lesson5[1][2],
								 	5.0);
							}
							case 6:
							{
							    SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson6[0][0], DS_Checkpoints_Lesson6[0][1], DS_Checkpoints_Lesson6[0][2],
								 	DS_Checkpoints_Lesson6[1][0], DS_Checkpoints_Lesson6[1][1], DS_Checkpoints_Lesson6[1][2],
								 	5.0);
							}
							case 7:
							{
							    SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson7[0][0], DS_Checkpoints_Lesson7[0][1], DS_Checkpoints_Lesson7[0][2],
								 	DS_Checkpoints_Lesson7[1][0], DS_Checkpoints_Lesson7[1][1], DS_Checkpoints_Lesson7[1][2],
								 	5.0);
							}
							case 8:
							{
                                SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson8[0][0], DS_Checkpoints_Lesson8[0][1], DS_Checkpoints_Lesson8[0][2],
								 	DS_Checkpoints_Lesson8[1][0], DS_Checkpoints_Lesson8[1][1], DS_Checkpoints_Lesson8[1][2],
								 	5.0);
							}
							case 9:
							{
                                SetPlayerRaceCheckpoint(playerid, 4,
									-2227.5872,2326.7605,187.1145,
								 	-2227.5872,2326.7605,187.1145,
								 	5.0);
							}
							case 10:
							{
                                SetPlayerRaceCheckpoint(playerid, 3,
									DS_Checkpoints_Lesson10[0][0], DS_Checkpoints_Lesson10[0][1], DS_Checkpoints_Lesson10[0][2],
								 	DS_Checkpoints_Lesson10[1][0], DS_Checkpoints_Lesson10[1][1], DS_Checkpoints_Lesson10[1][2],
								 	5.0);
							}
							case 11:
							{
                                SetPlayerRaceCheckpoint(playerid, 3,
									DS_Checkpoints_Lesson11[0][0], DS_Checkpoints_Lesson11[0][1], DS_Checkpoints_Lesson11[0][2],
								 	DS_Checkpoints_Lesson11[1][0], DS_Checkpoints_Lesson11[1][1], DS_Checkpoints_Lesson11[1][2],
								 	5.0);
							}
							case 12:
							{
                                SetPlayerRaceCheckpoint(playerid, 1,
									-759.8270,-1921.8171,5.0054,
								 	-759.8270,-1921.8171,5.0054,
								 	5.0);
							}
							case 13:
							{
                                SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson13[0][0], DS_Checkpoints_Lesson13[0][1], DS_Checkpoints_Lesson13[0][2],
								 	DS_Checkpoints_Lesson13[1][0], DS_Checkpoints_Lesson13[1][1], DS_Checkpoints_Lesson13[1][2],
								 	5.0);
							}
							case 14:
							{
                                SetPlayerRaceCheckpoint(playerid, 0,
									DS_Checkpoints_Lesson14[0][0], DS_Checkpoints_Lesson14[0][1], DS_Checkpoints_Lesson14[0][2],
								 	DS_Checkpoints_Lesson14[1][0], DS_Checkpoints_Lesson14[1][1], DS_Checkpoints_Lesson14[1][2],
								 	5.0);
							}
					    }
					    TempInfo[playerid][temp_driving_school_started] = 1;
					    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Начните движение к метке");
					    TempInfo[playerid][temp_driving_school_help_af][3] = 1;
				    }
				}
			}

			vInfo[vehicleid][vehicle_lights] = !vInfo[vehicleid][vehicle_lights];

			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsExEx(vehicleid, engine, vInfo[vehicleid][vehicle_lights], alarm, doors, bonnet, boot, objective);
		}
	
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case dDrivingSchool:
	    {
	        TogglePlayerControllable(playerid, 1);
	        if(TempInfo[playerid][temp_driving_school_lesson])
	        {
				if(IsAMoto(GetPlayerVehicleID(playerid)))
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Для начала наденьте шлем.");
					SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'N' чтобы надеть шлем.");
				}
				else
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Для начала пристегнитесь.");
					SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'N' чтобы пристегнуть ремень безопасности.");
				}
			}
	    }
	    
	    case dDrivingSchool+2:
	    {
	        if(TempInfo[playerid][temp_driving_school_lesson])
	        {
		        if(response)
		        {
		            StartLesson(playerid, TempInfo[playerid][temp_driving_school_lesson]);
		        }
				else
				{
				    RespawnPlayerAfterLesson(playerid);
				}
			}
	    }
	    case dDrivingSchool+4:
	    {
	        if(!response) return 1;
	        if(listitem != 0 && !uInfo[playerid][uDrivingLessonsPassed][listitem-1] && !debug_mode) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Прежде чем приступить к этому заданию, пройдите предыдущие");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem] && !uInfo[playerid][uLic][0]) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem] && uInfo[playerid][uLic][0] && uInfo[playerid][uLicTime][0] > getdate()) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
			StartLesson(playerid, listitem+1);
	    }
	    case dDrivingSchool+5:
	    {
	        if(!response) return 1;
	        if(listitem != 0 && !uInfo[playerid][uDrivingLessonsPassed][listitem+3] && !debug_mode) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Прежде чем приступить к этому заданию, пройдите предыдущие");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem+4] && !uInfo[playerid][uLic][1]) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem+4] && uInfo[playerid][uLic][1] && uInfo[playerid][uLicTime][1] > getdate()) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
			StartLesson(playerid, listitem+5);
	    }
	    case dDrivingSchool+6:
	    {
	        if(!response) return 1;
	        if(listitem != 0 && !uInfo[playerid][uDrivingLessonsPassed][listitem+7] && !debug_mode) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Прежде чем приступить к этому заданию, пройдите предыдущие");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem+8] && !uInfo[playerid][uLic][2]) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem+8] && uInfo[playerid][uLic][2] && uInfo[playerid][uLicTime][2] > getdate()) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
			StartLesson(playerid, listitem+9);
	    }
	    case dDrivingSchool+7:
	    {
	        if(!response) return 1;
	        if(listitem != 0 && !uInfo[playerid][uDrivingLessonsPassed][listitem+10] && !debug_mode) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Прежде чем приступить к этому заданию, пройдите предыдущие");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem+11] && !uInfo[playerid][uLic][3]) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
	        if(uInfo[playerid][uDrivingLessonsPassed][listitem+11] && uInfo[playerid][uLic][3] && uInfo[playerid][uLicTime][3] > getdate()) return SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Данное задание уже пройдено");
			StartLesson(playerid, listitem+12);
	    }
		case dDrivingSchool+8:
		{
		    if(!response) return 1;
		    new lic_id = GetPVarInt(playerid, "DrivingSchool:BuyLessonID");
			if(GetPlayerMoney(playerid) < 1000) return SendClientMessage(playerid, COLOR_RED, "Недостаточно средств");
			uInfo[playerid][uDrivingLessonsStarted][lic_id] = 1;
			GivePlayerMoney(playerid, -1000);
			switch(lic_id)
			{
				case 0:
				{
				    format:g_str_big("\
						Урок\tСтатус\n\
						1. Впервые за рулём\t%s\n\
						2. Дорога домой\t%s\n\
						3. Спуск смерти\t%s\n\
						4. Похороните Джона\t%s",
						(uInfo[playerid][uDrivingLessonsPassed][0]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][1]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][2]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][3]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

				    ShowPlayerDialog(playerid, dDrivingSchool+4, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
				}
				case 1:
				{
				    format:g_str_big("\
						Урок\tСтатус\n\
						1. Скоро на работу\t%s\n\
						2. Пыль в глаза\t%s\n\
						3. Тропа смерти\t%s\n\
						4. Двухколесный паркур\t%s",
						(uInfo[playerid][uDrivingLessonsPassed][4]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][5]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][6]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][7]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

				    ShowPlayerDialog(playerid, dDrivingSchool+5, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
				}
				case 2:
				{
                    format:g_str_big("\
						Урок\tСтатус\n\
						1. Раскрутить лопасти\t%s\n\
						2. Ниже Карлсона\t%s\n\
						3. Тоннель Смерти\t%s",
						(uInfo[playerid][uDrivingLessonsPassed][8]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][9]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][10]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

				    ShowPlayerDialog(playerid, dDrivingSchool+6, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
				}
				case 3:
				{
                    format:g_str_big("\
						Урок\tСтатус\n\
						1. Греби веслом\t%s\n\
						2. По течению\t%s\n\
						3. На волне\t%s",
						(uInfo[playerid][uDrivingLessonsPassed][11]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][12]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"),
						(uInfo[playerid][uDrivingLessonsPassed][13]) ? ("{008000}Пройдено") : ("{FF0000}Не пройдено"));

					ShowPlayerDialog(playerid, dDrivingSchool+7, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}


stock IsAMoto(vehicleid)
{
	new veh_model = GetVehicleModel(vehicleid);
	if(veh_model == 522
 	|| veh_model == 580
	|| veh_model == 488
	|| veh_model == 581
	|| veh_model == 471
	|| veh_model == 510
	|| veh_model == 448
	|| veh_model == 468)
		return 1;
	
	return 0;
}
stock IsABoat(vehicleid)
{
	new veh_model = GetVehicleModel(vehicleid);
	if(veh_model == 472
 	|| veh_model == 473
	|| veh_model == 593
	|| veh_model == 595
	|| veh_model == 484
	|| veh_model == 446
	|| veh_model == 493)
		return 1;

	return 0;
}
stock IsAHeli(vehicleid)
{
	new veh_model = GetVehicleModel(vehicleid);
	if(veh_model == 417
 	|| veh_model == 425
	|| veh_model == 447
	|| veh_model == 469
	|| veh_model == 487
	|| veh_model == 488
	|| veh_model == 497
	|| veh_model == 548
	|| veh_model == 563)
		return 1;

	return 0;
}

stock PlayerToPlayer(playerid, targetid, Float:range)
{
    if(IsPlayerConnected(playerid) && IsPlayerConnected(targetid))
	{
	    new Float:x, Float:y, Float:z;
	    GetPlayerPos(targetid, x, y, z);
		if(IsPlayerInRangeOfPoint(playerid, range, x, y, z)) return 1;
	}
	return 0;
}

stock LoadMap()
{
	new tmp_actor;
	for(new i; i<MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS; i++)
	{
 		tmp_actor = CreateActor(68,888.8700,-1077.4198,24.3040,89.4504); //
		ApplyActorAnimation(tmp_actor, "PED", "IDLE_CHAT", 4.1, 0, 0, 0, 0, 0); // Pay anim
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(10,886.9807,-1079.5336,24.2969,357.7682);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(33,885.2373,-1079.5972,24.2969,357.9144);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(39,883.9791,-1079.1621,24.3040,341.3911);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(24,883.0454,-1077.3440,24.2969,273.2509);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(54,890.1835,-1079.9419,24.2969,53.0430);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(117,889.9802,-1077.7550,24.2969,83.8962);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
		tmp_actor = CreateActor(118,884.4238,-1079.9109,24.2969,348.7047);
		SetActorVirtualWorld(tmp_actor, DRIVING_SCHOOL_VIRTUAL_WORLD+i);
	
		CreateDynamicObject(1631,397.6260100,460.3100000,0.0000000,0.0000000,0.0000000,288.0000000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (1)
		CreateDynamicObject(1632,665.3549800,532.3800000,0.9000000,0.0000000,0.0000000,288.0000000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (1)
		CreateDynamicObject(1632,1241.2710000,615.9979900,0.9000000,0.0000000,0.0000000,259.9960000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (2)
		CreateDynamicObject(1632,824.8579700,575.4379900,0.9000000,0.0000000,0.0000000,283.9940000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (3)
		CreateDynamicObject(1632,1032.4980500,622.3790300,0.9000000,0.0000000,0.0000000,277.9910000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (4)
		CreateDynamicObject(1632,1239.5909400,608.1749900,0.9000000,0.0000000,0.0000000,259.9910000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (5)
		CreateDynamicObject(1632,1237.8060300,599.8640100,0.9000000,0.0000000,0.0000000,259.9910000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (6)
		CreateDynamicObject(1632,1551.6149900,594.2719700,0.9000000,0.0000000,0.0000000,283.9910000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(waterjump2) (7)
		CreateDynamicObject(18567,667.3759800,532.3950200,1.0570000,0.0000000,0.0000000,100.0000000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(cs_logs04) (1)
		CreateDynamicObject(849,665.8510100,520.8430200,0.0000000,0.0000000,0.0000000,0.0000000, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object(cj_urb_rub_3) (1)
		
		CreateDynamicObject(979, 1491.59497, -1147.06799, 135.668, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (1)
		CreateDynamicObject(979, 1491.59595, -1138.07104, 135.668, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (2)
		CreateDynamicObject(979, 1491.60095, -1128.76794, 135.668, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (3)
		CreateDynamicObject(979, 1491.61499, -1119.43396, 135.668, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (4)
		CreateDynamicObject(979, 1496.32202, -1114.75098, 135.668, 0.00, 0.00, 180, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (5)
		CreateDynamicObject(979, 1505.67395, -1114.776, 135.668, 0.00, 0.00, 179.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (6)
		CreateDynamicObject(979, 1515.03406, -1114.74402, 135.668, 0.00, 0.00, 179.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (7)
		CreateDynamicObject(979, 1524.35999, -1114.77502, 135.668, 0.00, 0.00, 179.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (8)
		CreateDynamicObject(979, 1533.59998, -1114.85803, 135.668, 0.00, 0.00, 179.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (9)
		CreateDynamicObject(978, 1474.80298, -1195.28003, 108.186, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (1)
		CreateDynamicObject(978, 1427.56104, -1145.52502, 92.3, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (2)
		CreateDynamicObject(978, 1474.901, -1213.77905, 108.186, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (3)
		CreateDynamicObject(978, 1478.73206, -1221.20801, 108.186, 0.00, 0.00, 324, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (4)
		CreateDynamicObject(1228, 1479.58496, -1180.58398, 107.78, 0.00, 0.00, 272, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (roadworkbarrier1) (1)
		CreateDynamicObject(1228, 1482.16504, -1180.50098, 107.78, 0.00, 0.00, 266, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (roadworkbarrier1) (2)
		CreateDynamicObject(1228, 1484.771, -1180.49097, 107.78, 0.00, 0.00, 271.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (roadworkbarrier1) (3)
		CreateDynamicObject(1237, 1489.43604, -1189.88, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (31)
		CreateDynamicObject(1237, 1489.47095, -1195.96204, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (32)
		CreateDynamicObject(1237, 1489.46594, -1202.29102, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (33)
		CreateDynamicObject(1237, 1489.65198, -1208.276, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (34)
		CreateDynamicObject(1237, 1489.73999, -1213.90295, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (35)
		CreateDynamicObject(1237, 1489.46899, -1221.17896, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (36)
		CreateDynamicObject(1237, 1485.57202, -1223.14905, 107.356, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (strtbarrier01) (49)
		CreateDynamicObject(978, 1474.85156, -1204.52832, 108.186, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (5)
		CreateDynamicObject(978, 1427.54797, -1135.43005, 92.3, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (7)
		CreateDynamicObject(978, 1427.65198, -1125.37402, 92.3, 0.00, 0.00, 270, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadright) (8)
		CreateDynamicObject(979, 1476.06799, -1181.30505, 108.198, 0.00, 0.00, 142, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (1)
		CreateDynamicObject(979, 1484.70703, -1185.17798, 108.198, 0.00, 0.00, 169.998, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (sub_roadleft) (1)

		CreateDynamicObject(1237, -2018.677, -127.517, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.48206, -134.51801, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (2)
		CreateDynamicObject(1237, -2018.53503, -141.50999, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (3)
		CreateDynamicObject(1237, -2018.58997, -148.509, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (4)
		CreateDynamicObject(1237, -2018.39099, -154.987, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2018.45703, -163.205, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (6)
		CreateDynamicObject(1237, -2018.57996, -170.48, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (7)
		CreateDynamicObject(1237, -2019.43799, -178.77499, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (8)
		CreateDynamicObject(1237, -2019.28406, -187.77299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (9)
		CreateDynamicObject(1237, -2019.12097, -197.271, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (10)
		CreateDynamicObject(1237, -2018.94897, -207.269, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (11)
		CreateDynamicObject(1237, -2018.78198, -217.017, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (12)
		CreateDynamicObject(1237, -2018.62805, -226.01601, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (13)
		CreateDynamicObject(1237, -2018.46106, -235.76401, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (14)
		CreateDynamicObject(1237, -2018.37903, -246.513, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (15)
		CreateDynamicObject(1237, -2018.22095, -256.26199, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (16)
		CreateDynamicObject(1237, -2018.23096, -266.26199, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (17)
		CreateDynamicObject(1237, -2018.24097, -276.51199, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (18)
		CreateDynamicObject(1237, -2028.73999, -276.50299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (19)
		CreateDynamicObject(1237, -2038.48901, -276.495, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (20)
		CreateDynamicObject(1237, -2049.98804, -276.48401, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (21)
		CreateDynamicObject(1237, -2049.9873, -276.4834, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (22)
		CreateDynamicObject(1237, -2060.23706, -276.59601, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (23)
		CreateDynamicObject(1237, -2070.73608, -276.711, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (24)
		CreateDynamicObject(1237, -2082.23511, -276.83701, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (25)
		CreateDynamicObject(1237, -2091.98389, -276.944, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (26)
		CreateDynamicObject(1237, -2092.0769, -268.19299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (27)
		CreateDynamicObject(1237, -2092.1731, -259.19199, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (28)
		CreateDynamicObject(1237, -2092.28003, -249.192, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (29)
		CreateDynamicObject(1237, -2092.3811, -239.692, 34.242, 0.00, 0.00, 356, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (30)
		CreateDynamicObject(1237, -2092.41211, -228.94099, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (37)
		CreateDynamicObject(1237, -2092.44507, -217.69, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (38)
		CreateDynamicObject(1237, -2092.47998, -205.689, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (39)
		CreateDynamicObject(1237, -2092.51489, -193.438, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (40)
		CreateDynamicObject(1237, -2092.5481, -181.938, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (41)
		CreateDynamicObject(1237, -2092.58398, -169.688, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (42)
		CreateDynamicObject(1237, -2092.58398, -169.6875, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (43)
		CreateDynamicObject(1237, -2092.61694, -158.438, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (44)
		CreateDynamicObject(1237, -2092.65088, -146.438, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (45)
		CreateDynamicObject(1237, -2092.68896, -133.188, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (46)
		CreateDynamicObject(1237, -2092.73193, -118.188, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (47)
		CreateDynamicObject(1237, -2092.73145, -118.1875, 34.242, 0.00, 0.00, 355.995, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (48)
		CreateDynamicObject(1237, -2030.177, -127.651, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2030.10205, -134.64999, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2030.02502, -141.149, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.93994, -148.39799, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.86304, -154.897, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.77197, -162.646, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.68103, -170.395, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.58997, -178.144, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.48206, -187.39301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.36401, -197.392, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.24902, -207.14101, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.13501, -216.89, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.02905, -225.88901, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2028.91394, -235.638, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2028.79004, -246.13699, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2028.67603, -255.886, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2028.56201, -265.63501, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2038.55603, -266.25299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2050.05591, -266.38901, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2060.55591, -266.513, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2071.05591, -266.63699, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2071.05566, -266.63672, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.05591, -266.61801, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.04004, -258.617, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.021, -248.866, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.00195, -239.36501, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2081.98096, -228.614, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2081.96191, -218.11301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.10791, -205.61301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.24512, -193.86301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.38599, -181.86301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.53198, -169.36301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.65991, -158.36301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.79712, -146.61301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2082.95508, -133.11301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2083.13696, -117.613, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2072.63696, -117.488, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2061.14502, -117.321, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2052.65796, -117.079, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2043.15698, -117.026, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2057.01611, -117.212, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2072.70508, -132.991, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2060.96704, -133.03799, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2053.18896, -132.34399, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2052.93091, -124.514, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2049.67993, -137.491, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2047.03101, -142.66901, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2049.24194, -148.381, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2052.44604, -152.895, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2055.53809, -157.90199, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2057.96802, -138.013, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2055.1731, -143.59399, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2058.91406, -148.604, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2062.39307, -153.614, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2062.4729, -161.364, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2058.61597, -166.618, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2052.23389, -162.69099, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2047.92896, -167.912, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2054.03809, -172.464, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2048.27808, -177.715, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2045.06396, -172.976, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2058.27295, -177.394, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2052.19507, -182.259, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2061.92896, -182.14799, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2054.98511, -185.78999, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2062.01904, -186.146, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2055.06494, -192.73199, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2061.96094, -192.645, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2066.90601, -117.345, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2077.65503, -117.489, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2088.40405, -117.633, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -125.442, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79687, -125.44141, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -139.69099, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -152.94, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -164.689, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -176.188, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -187.938, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79687, -187.9375, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -199.438, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -211.688, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -222.938, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -234.938, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79712, -244.938, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.79687, -244.9375, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.56812, -253.935, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.32007, -263.681, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2092.09692, -272.427, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2087.47607, -277.061, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2076.47607, -276.78299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2065.72607, -276.51099, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2054.97607, -276.23901, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2054.97559, -276.23828, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2044.47595, -276.49899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2032.97595, -276.509, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2022.97595, -276.51901, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2017.93896, -271.52399, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.245, -260.78, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.16296, -251.03, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.32898, -241.028, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.745, -231.024, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.74414, -231.02344, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.72498, -221.27299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.70496, -211.272, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.68604, -201.771, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.68555, -201.77051, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2018.66797, -192.521, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2029.36096, -192.584, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2029.50696, -202.58299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2029.02502, -211.83299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2029.04395, -221.832, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2029.06201, -231.08099, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2028.57996, -240.58099, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2028.599, -250.83, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2028.61804, -260.57901, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2033.37805, -265.82001, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2043.93701, -266.39301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2055.21289, -266.41901, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2065.74097, -266.49301, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2076.78296, -266.784, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.0459, -263.15799, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2081.63696, -253.66299, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2081.99292, -244.36501, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.12891, -233.61501, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.25903, -223.36501, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2081.9021, -212.10899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.05688, -199.85899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.20898, -187.85899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.36108, -175.85899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.51001, -164.10899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.65601, -152.60899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2082.80811, -140.60899, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2077.90601, -132.79601, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2067.1521, -132.911, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2067.15137, -132.91016, 34.242, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (5)
		CreateDynamicObject(1237, -2055.14795, -198.23599, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2061.79395, -198.142, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2061.61206, -204.13901, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1237, -2055.34595, -204.44701, 34.242, 0.00, 0.00, 2, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0);  //object (strtbarrier01) (1)
		CreateDynamicObject(1427, -2058.55811, -204.58299, 34.867, 0.00, 0.00, 0.00, DRIVING_SCHOOL_VIRTUAL_WORLD+i, -1, -1, 300.0); //object (CJ_ROADBARRIER) (1)
	}
	
	// Don't use these lines if it's a filterscript
	//Map Exported with Texture Studio By: [uL]Pottus////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Objects////////////////////////////////////////////////////////////////////////////////////////////////////////
	new tmpobjid;
	tmpobjid = CreateDynamicObject(19379,1459.838,-130.318,2926.057,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_vinyl", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1454.673,-130.305,2927.884,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1454.695,-130.311,2927.884,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4887, "downtown_las", "ws_glassnbrassdoor", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1454.673,-130.305,2931.374,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1456.475,-128.869,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1451.153,-127.985,2927.884,0.000,179.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1454.693,-130.305,2924.512,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1457.576,-127.981,2927.884,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.976,-127.975,2927.883,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1451.153,-132.655,2927.884,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1457.576,-132.651,2927.884,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.976,-132.645,2927.883,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1457.602,-132.529,2928.204,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14530, "estate2", "Auto_hustler", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1457.562,-128.099,2928.204,0.000,0.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14530, "estate2", "Auto_feltzer", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1451.153,-127.985,2931.385,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1457.576,-127.981,2931.386,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.976,-127.975,2931.385,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1451.153,-132.655,2931.376,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1457.576,-132.651,2931.377,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.976,-132.645,2931.376,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1457.575,-132.641,2924.513,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1457.575,-127.991,2924.513,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,1470.338,-130.318,2926.057,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_vinyl", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1460.687,-132.715,2927.883,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18008, "intclothesa", "shop_wall3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1460.687,-127.895,2927.883,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18008, "intclothesa", "shop_wall3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.753,-130.945,2931.374,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.943,-131.684,2927.883,0.000,0.000,-112.900,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18008, "intclothesa", "shop_wall3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1460.022,-128.978,2927.883,0.000,0.000,-63.500,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18008, "intclothesa", "shop_wall3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.753,-123.255,2927.884,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.743,-130.305,2931.364,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14736, "whorerooms", "AH_bathmos", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.747,-123.265,2927.865,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14736, "whorerooms", "AH_bathmos", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1465.604,-126.675,2927.884,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.733,-130.305,2931.374,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1465.604,-126.675,2931.384,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.646,-126.685,2927.883,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4550, "skyscr1_lan2", "sl_librarycolmn1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1464.049,-126.679,2927.883,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1466.457,-126.685,2927.883,0.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4550, "skyscr1_lan2", "sl_librarycolmn1", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.646,-126.685,2931.375,0.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4550, "skyscr1_lan2", "sl_librarycolmn1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1464.049,-126.679,2931.375,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1466.457,-126.685,2931.384,0.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4550, "skyscr1_lan2", "sl_librarycolmn1", 0x00000000);
	tmpobjid = CreateDynamicObject(19937,1465.864,-129.377,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19937,1465.864,-131.287,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,1470.338,-130.318,2930.257,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1468.003,-128.375,2927.884,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,1465.890,-130.229,2927.163,180.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19937,1465.924,-129.376,2926.144,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19937,1465.924,-131.286,2926.144,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19938,1465.887,-131.447,2927.164,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19938,1465.887,-129.017,2927.164,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,1466.227,-130.235,2926.882,0.000,-0.000,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19938,1466.231,-129.017,2926.883,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19938,1466.231,-131.447,2926.883,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,1465.660,-130.299,2926.642,180.000,270.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19811,1465.863,-129.533,2927.137,0.000,0.000,-6.499,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1465.867,-129.533,2927.230,0.000,-0.000,83.498,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1466.414,-129.620,2927.351,-15.998,-0.000,83.498,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1465.456,-129.472,2927.074,15.998,0.000,-96.498,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.930,-128.728,2924.650,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.930,-131.709,2924.650,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.931,-130.217,2926.152,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.932,-131.716,2924.657,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.932,-128.721,2924.657,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.932,-130.224,2926.159,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.932,-130.217,2926.166,44.999,0.000,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1460.759,-134.158,2927.874,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,1459.838,-139.948,2926.057,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_vinyl", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,1470.337,-139.948,2926.057,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_vinyl", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-133.138,2927.263,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-133.138,2929.495,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1468.003,-128.375,2931.384,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(3089,1467.947,-134.795,2927.454,0.000,0.000,-174.600,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-134.898,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-134.708,2929.455,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1468.003,-138.005,2931.384,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-136.398,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-136.208,2929.455,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-137.898,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-137.708,2929.455,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-139.398,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-139.208,2929.455,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-134.348,2929.505,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-135.928,2929.505,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-137.418,2929.505,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-138.908,2929.505,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-135.938,2926.092,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-138.168,2926.092,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-134.348,2928.774,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-135.928,2928.774,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-137.418,2928.774,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1468.021,-138.908,2928.774,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1468.003,-144.145,2927.884,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(3857,1468.013,-136.176,2931.774,-0.000,0.000,-44.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3857,1468.013,-138.566,2925.939,-0.000,0.000,-44.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3857,1468.013,-136.176,2931.774,-0.000,0.000,-44.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3857,1468.013,-138.566,2925.939,-0.000,0.000,-44.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-135.708,2927.263,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-135.708,2929.493,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-137.408,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-137.218,2929.453,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(3089,1460.836,-138.879,2927.474,0.000,0.000,0.399,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-138.978,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-138.788,2929.453,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-140.478,2927.223,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-140.288,2929.453,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.770,-140.565,2931.374,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-136.908,2929.493,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-138.418,2929.493,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-139.968,2929.493,90.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-136.218,2926.090,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-136.908,2928.792,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-139.968,2926.090,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-138.418,2928.792,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1460.780,-139.968,2928.792,89.999,-89.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.773,-145.235,2927.884,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.646,-141.005,2927.883,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.117,-141.005,2927.883,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.646,-141.015,2931.374,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.117,-141.005,2931.374,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1463.018,-141.018,2931.045,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1466.219,-141.018,2931.045,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,1459.838,-139.948,2930.257,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1466.001,-141.025,2927.601,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,1470.338,-139.948,2930.257,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(3857,1460.784,-136.886,2931.774,-0.000,0.000,-44.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3859,1460.760,-134.711,2925.982,0.000,0.000,16.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3859,1460.760,-141.511,2925.982,0.000,0.000,16.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3859,1460.760,-134.711,2925.982,0.000,0.000,16.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3859,1460.760,-141.511,2925.982,0.000,0.000,16.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(3857,1460.784,-136.886,2931.774,-0.000,0.000,-44.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19325, "lsmall_shops", "lsmall_window01", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1460.747,-134.148,2927.874,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14736, "whorerooms", "AH_bathmos", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1455.963,-142.935,2927.884,180.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1455.963,-135.665,2927.884,180.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1454.523,-138.395,2927.884,180.000,0.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9583, "bigshap_sfw", "bridge_walls2_sfw", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1453.658,-141.651,2927.884,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1455.179,-143.171,2927.884,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9583, "bigshap_sfw", "bridge_walls2_sfw", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.763,-145.236,2927.884,180.000,0.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1455.963,-142.935,2931.376,180.000,-179.999,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1455.963,-135.665,2931.376,180.000,-179.999,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1454.523,-138.395,2931.376,0.000,179.999,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9583, "bigshap_sfw", "bridge_walls2_sfw", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1453.658,-141.651,2931.376,180.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1455.179,-143.171,2931.376,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9583, "bigshap_sfw", "bridge_walls2_sfw", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.753,-138.756,2931.375,180.000,179.999,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_2", 0x00000000);
	tmpobjid = CreateDynamicObject(14455,1459.854,-135.943,2927.802,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "mp_CJ_WOOD5", 0x00000000);
	tmpobjid = CreateDynamicObject(2162,1458.386,-142.833,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(2161,1459.726,-142.824,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14650, "ab_trukstpc", "mp_CJ_WOOD5", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1454.623,-139.978,2928.234,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14488, "dogsgym", "AH_stolewindow", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1454.623,-137.368,2928.234,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14488, "dogsgym", "AH_stolewindow", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.494,-138.898,2928.264,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.494,-140.998,2928.264,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.495,-139.958,2929.375,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.495,-139.958,2927.154,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.494,-136.288,2928.264,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.494,-138.388,2928.264,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.495,-137.348,2929.375,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,1454.495,-137.348,2927.154,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3629, "arprtxxref_las", "ws_corrugated2", 0x00000000);
	tmpobjid = CreateDynamicObject(2081,1455.045,-140.428,2926.573,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "mp_CJ_WOOD5", 0x00000000);
	tmpobjid = CreateDynamicObject(2081,1455.045,-137.818,2926.573,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "mp_CJ_WOOD5", 0x00000000);
	tmpobjid = CreateDynamicObject(2267,1458.010,-142.820,2928.063,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14530, "estate2", "Auto_windsor", 0x00000000);
	tmpobjid = CreateDynamicObject(19811,1457.274,-139.988,2927.027,0.000,0.000,-67.199,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1457.276,-139.992,2927.120,0.000,-0.000,22.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1457.467,-140.512,2927.241,-15.998,-0.000,22.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1457.127,-139.604,2926.964,15.998,0.000,-157.199,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2161,1458.446,-140.194,2926.153,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1460.789,-135.750,2927.864,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1460.789,-140.440,2927.864,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1460.789,-138.250,2930.595,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1468.010,-134.770,2930.575,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1468.010,-137.960,2930.575,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1468.010,-137.960,2927.093,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1468.010,-136.360,2927.093,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1472.884,-131.185,2927.884,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1474.974,-136.085,2927.884,180.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1472.884,-140.995,2927.884,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(2165,1472.156,-134.022,2926.143,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 3, 14479, "skuzzy_motelmain", "mp_CJ_Laminate1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 5, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(3077,1473.271,-132.967,2926.143,0.000,0.000,-45.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14530, "estate2", "ab_dsWhiteboard", 0x00000000);
	tmpobjid = CreateDynamicObject(19811,1471.322,-134.221,2926.877,0.000,0.000,83.500,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1471.322,-134.217,2926.970,0.000,-0.000,173.498,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1471.409,-133.670,2927.091,-15.998,-0.000,173.498,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19894, "laptopsamp1", "laptopscreen2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1471.261,-134.628,2926.814,15.998,0.000,-6.498,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19174,1474.886,-136.124,2928.034,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14668, "711c", "gun_ceiling1128", 0x00000000);
	tmpobjid = CreateDynamicObject(19174,1474.886,-139.334,2928.034,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14668, "711c", "gun_ceiling1128", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-135.260,2928.054,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "arrownoleftsign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-136.100,2928.054,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "arrownostraightsign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-136.950,2928.054,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "bluearrowright", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-135.260,2927.373,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "arrownorightsign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-136.100,2927.373,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "bluearrowleft", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-136.950,2927.373,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "bluearrowstraight", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-138.450,2928.054,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "trafficcamera", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-139.290,2928.054,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "workzonesign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-140.140,2928.054,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "speedlimitblanksign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-138.450,2927.373,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "stopsign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-139.290,2927.373,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "towawayzonesign", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1474.381,-140.140,2927.373,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "speedlimit50sign", 0x00000000);
	tmpobjid = CreateDynamicObject(2180,1473.343,-136.809,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14479, "skuzzy_motelmain", "mp_CJ_Laminate1", 0x00000000);
	tmpobjid = CreateDynamicObject(2180,1473.343,-139.249,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14479, "skuzzy_motelmain", "mp_CJ_Laminate1", 0x00000000);
	tmpobjid = CreateDynamicObject(2180,1470.272,-136.809,2926.143,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14479, "skuzzy_motelmain", "mp_CJ_Laminate1", 0x00000000);
	tmpobjid = CreateDynamicObject(2180,1470.272,-139.249,2926.143,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14479, "skuzzy_motelmain", "mp_CJ_Laminate1", 0x00000000);
	tmpobjid = CreateDynamicObject(1944,1469.762,-137.251,2927.073,23.600,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "bras_base", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19811,1469.756,-136.624,2926.897,0.000,0.000,-89.199,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1469.756,-136.628,2926.990,0.000,-0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1469.739,-137.181,2927.111,-15.998,-0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-80-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1469.764,-136.212,2926.834,15.998,0.000,-179.199,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19610,1469.765,-137.159,2926.981,-34.799,0.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19598, "sfbuilding1", "darkwood1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19115, "sillyhelmets", "sillyhelmet2", 0x00000000);
	tmpobjid = CreateDynamicObject(2356,1469.793,-138.346,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(1944,1469.762,-139.731,2927.073,23.600,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "bras_base", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19811,1469.756,-139.104,2926.897,0.000,0.000,-89.199,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1469.756,-139.108,2926.990,0.000,0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1469.739,-139.661,2927.111,-15.998,0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-80-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1469.764,-138.692,2926.834,15.998,0.000,-179.199,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19610,1469.765,-139.638,2926.981,-34.799,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19598, "sfbuilding1", "darkwood1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19115, "sillyhelmets", "sillyhelmet2", 0x00000000);
	tmpobjid = CreateDynamicObject(1944,1472.862,-139.731,2927.073,23.600,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "bras_base", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19811,1472.856,-139.104,2926.897,-0.000,0.000,-89.198,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1472.857,-139.108,2926.990,0.000,0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1472.840,-139.661,2927.111,-15.998,0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-80-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1472.864,-138.692,2926.834,15.998,-0.000,-179.198,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19610,1472.865,-139.638,2926.981,-34.799,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19598, "sfbuilding1", "darkwood1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19115, "sillyhelmets", "sillyhelmet2", 0x00000000);
	tmpobjid = CreateDynamicObject(1944,1472.862,-137.241,2927.073,23.600,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14650, "ab_trukstpc", "bras_base", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19811,1472.856,-136.614,2926.897,-0.000,0.000,-89.198,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19995,1472.857,-136.618,2926.990,0.000,0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1472.840,-137.171,2927.111,-15.998,0.000,0.798,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-80-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2263,1472.864,-136.202,2926.834,15.998,-0.000,-179.198,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-93-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-93-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19610,1472.865,-137.148,2926.981,-34.799,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19598, "sfbuilding1", "darkwood1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19115, "sillyhelmets", "sillyhelmet2", 0x00000000);
	tmpobjid = CreateDynamicObject(2356,1469.793,-140.646,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(2356,1473.032,-140.646,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(2356,1473.032,-138.225,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1472.884,-131.185,2931.376,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1474.974,-136.085,2931.376,0.000,-179.999,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1472.884,-140.995,2931.376,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,1474.886,-137.736,2929.213,0.000,270.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,1474.855,-137.729,2929.204,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "ROAD SIGN", 130, "Ariel", 50, 1, 0xFFFFFFFF, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19427,1468.897,-140.985,2927.883,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1474.088,-140.985,2927.883,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1474.088,-140.985,2931.383,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1468.897,-140.985,2931.383,360.000,0.000,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14846, "genintintpoliceb", "p_floor3", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,1471.461,-140.891,2928.673,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "DRIVING SCHOOL", 130, "Ariel", 60, 1, 0xFFFFFFFF, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19483,1471.461,-140.891,2928.333,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "OF", 130, "Ariel", 60, 1, 0xFFFFFFFF, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19483,1471.461,-140.891,2928.013,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "SAN ANDREAS", 130, "Ariel", 60, 1, 0xFFFFFFFF, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19174,1471.455,-140.914,2928.373,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14668, "711c", "gun_ceiling1128", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,1471.451,-140.892,2928.673,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "DRIVING SCHOOL", 130, "Ariel", 60, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19483,1471.451,-140.892,2928.333,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "OF", 130, "Ariel", 60, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19483,1471.451,-140.892,2928.013,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "SAN ANDREAS", 130, "Ariel", 60, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19427,1467.107,-139.179,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.107,-135.679,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.107,-132.179,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.107,-128.679,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.107,-125.179,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.647,-125.179,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.647,-128.679,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.647,-132.179,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.647,-135.679,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.647,-139.179,2930.093,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1464.127,-126.659,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1464.758,-126.659,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1464.758,-140.149,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1463.898,-140.149,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(5779,1465.365,-135.293,2930.204,180.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	tmpobjid = CreateDynamicObject(5779,1465.365,-140.533,2930.204,180.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	tmpobjid = CreateDynamicObject(5779,1462.226,-140.533,2930.204,180.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	tmpobjid = CreateDynamicObject(5779,1462.226,-135.293,2930.204,180.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	tmpobjid = CreateDynamicObject(5779,1462.226,-130.053,2930.204,180.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	tmpobjid = CreateDynamicObject(5779,1465.365,-130.063,2930.204,180.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.106,-139.179,2930.094,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.106,-135.679,2930.094,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.106,-132.179,2930.094,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1467.106,-128.679,2930.095,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.648,-128.679,2930.094,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.648,-132.179,2930.094,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.648,-135.679,2930.094,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1461.648,-139.178,2930.095,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1464.758,-140.148,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1463.898,-140.148,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1464.127,-126.660,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1464.758,-126.660,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-129.261,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-130.691,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-132.101,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-133.421,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-134.851,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-136.261,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1464.377,-137.631,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1462.895,-129.961,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1462.895,-131.391,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1462.895,-132.801,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1462.895,-134.121,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1462.895,-135.551,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1462.895,-136.961,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1465.855,-129.961,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1465.855,-131.391,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1465.855,-132.801,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1465.855,-134.121,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1465.855,-135.551,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2189,1465.855,-136.961,2930.155,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1456.475,-131.769,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1458.406,-130.197,2930.253,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1453.445,-130.409,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.146,-128.869,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.066,-131.769,2930.093,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1460.916,-130.409,2930.093,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1454.916,-130.197,2930.253,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-20-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1456.475,-131.768,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-30-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.066,-131.768,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-30-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1456.475,-128.878,2930.094,0.000,89.999,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-30-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1459.066,-128.878,2930.094,0.000,89.999,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-30-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1453.455,-130.409,2930.094,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-40-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,1460.906,-130.409,2930.094,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-40-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(18762,1471.368,-133.808,2932.635,0.000,180.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10778, "airportcpark_sfse", "ws_fluorescent2", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(14793,1455.097,-127.707,2930.074,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(18762,1471.368,-139.318,2932.635,0.000,180.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10778, "airportcpark_sfse", "ws_fluorescent2", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18762,1471.368,-136.528,2932.635,0.000,180.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10778, "airportcpark_sfse", "ws_fluorescent2", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18762,1457.616,-138.328,2932.635,0.000,180.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10778, "airportcpark_sfse", "ws_fluorescent2", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18762,1457.616,-139.338,2932.635,0.000,180.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10778, "airportcpark_sfse", "ws_fluorescent2", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19483,1465.640,-130.309,2926.613,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "INFORMATION", 130, "Ariel", 50, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(2165,1466.044,-131.193,2926.383,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 3, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 4, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 5, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1463.982,-126.800,2928.395,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 15040, "cuntcuts", "csnewspaper", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1460.872,-134.209,2928.354,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 15040, "cuntcuts", "csnewspaper02", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1460.755,-123.255,2924.511,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1460.776,-134.153,2924.511,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1467.978,-128.395,2924.511,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1467.986,-140.923,2924.511,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1468.867,-126.693,2924.511,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1474.958,-136.084,2924.511,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1472.897,-131.194,2924.511,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1472.897,-140.992,2924.511,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,1468.017,-128.402,2924.511,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14847, "mp_policesf", "mp_cop_floor1", 0x00000000);
	tmpobjid = CreateDynamicObject(2040,1459.600,-129.225,2927.544,90.000,27.999,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2040,1459.520,-131.477,2927.544,90.000,67.399,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,1464.364,-140.919,2928.394,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 15040, "cuntcuts", "GB_novels06", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,1462.791,-141.025,2927.601,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1983, "new_cabinets2", "shop_shelfnu3", 0x00000000);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	tmpobjid = CreateDynamicObject(19379,1459.838,-120.698,2926.057,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1726,1463.011,-127.278,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19808,1466.298,-129.582,2926.911,0.000,-0.000,83.498,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1726,1461.360,-135.198,2926.143,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2161,1456.615,-142.824,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2161,1459.726,-142.824,2927.493,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2161,1456.615,-142.824,2927.494,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2206,1457.046,-140.228,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1715,1457.994,-141.842,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2253,1454.776,-137.261,2927.344,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2253,1454.776,-139.951,2927.344,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2684,1457.825,-142.817,2927.333,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2684,1458.145,-142.817,2927.333,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19808,1457.425,-140.347,2927.091,0.000,-0.000,22.798,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19807,1458.627,-140.389,2927.142,0.000,0.000,-8.199,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1722,1459.024,-139.337,2926.143,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19808,1471.365,-133.835,2926.941,0.000,-0.000,173.498,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1715,1471.530,-132.618,2926.143,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1783,1469.044,-136.923,2926.473,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1783,1469.044,-139.403,2926.473,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1783,1473.484,-139.403,2926.473,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1783,1473.484,-136.913,2926.473,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2828,1458.496,-142.627,2927.073,0.000,0.000,4.600,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2737,1469.842,-131.314,2927.913,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1715,1467.569,-129.486,2926.143,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19807,1465.911,-130.169,2927.243,0.000,0.000,100.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1448.813,-136.580,2928.983,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1460.923,-124.380,2928.983,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1467.033,-124.380,2928.983,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1477.673,-136.580,2928.983,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1467.033,-147.470,2928.983,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1460.653,-147.470,2928.983,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1460.653,-136.570,2940.593,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1466.863,-136.570,2940.593,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1466.863,-136.570,2921.321,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,1460.782,-136.570,2921.321,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1726,1465.360,-140.408,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1808,1465.879,-140.738,2926.143,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	return 1;
}

stock ShowPlayerHelpArrows(playerid)
{
	for(new i; i<4; i++)
		TextDrawShowForPlayer(playerid, HelpArrowsTD[i]);
    flash_timer[playerid] = SetTimerEx("FlashDownHelpArrow", 300, true, "i", playerid);
}
stock HidePlayerHelpArrows(playerid)
{
	for(new i; i<4; i++)
		TextDrawHideForPlayer(playerid, HelpArrowsTD[i]);
	KillTimer(flash_timer[playerid]);
}
stock ShowPlayerHelpButtons(playerid)
{
	if(!IsAMoto(GetPlayerVehicleID(playerid)))
	{
		TextDrawShowForPlayer(playerid, HelpButtonsTD[0][0]);
		TextDrawShowForPlayer(playerid, HelpButtonsTD[0][1]);
	}
	TextDrawShowForPlayer(playerid, HelpButtonsTD[1][0]);
	TextDrawShowForPlayer(playerid, HelpButtonsTD[1][1]);
	TextDrawShowForPlayer(playerid, HelpButtonsTD[2][0]);
	TextDrawShowForPlayer(playerid, HelpButtonsTD[2][1]);
	flash_timer[playerid] = SetTimerEx("FlashHelpButton", 300, true, "i", playerid);
}
stock HidePlayerHelpButtons(playerid)
{
	for(new i; i<3; i++)
	{
		TextDrawHideForPlayer(playerid, HelpButtonsTD[i][0]);
		TextDrawHideForPlayer(playerid, HelpButtonsTD[i][1]);
	}
	KillTimer(flash_timer[playerid]);
}

stock LoadTD()
{
    HelpArrowsTD[0] = TextDrawCreate(310.666687, 360.748138, "LD_BEAT:up");
	TextDrawLetterSize(HelpArrowsTD[0], 0.000000, 0.000000);
	TextDrawTextSize(HelpArrowsTD[0], 17.000000, 21.000000);
	TextDrawAlignment(HelpArrowsTD[0], 1);
	TextDrawColor(HelpArrowsTD[0], -1);
	TextDrawSetShadow(HelpArrowsTD[0], 0);
	TextDrawSetOutline(HelpArrowsTD[0], 0);
	TextDrawBackgroundColor(HelpArrowsTD[0], 255);
	TextDrawFont(HelpArrowsTD[0], 4);
	TextDrawSetProportional(HelpArrowsTD[0], 0);
	TextDrawSetShadow(HelpArrowsTD[0], 0);

    HelpArrowsTD[1] = TextDrawCreate(310.666687, 386.049682, "LD_BEAT:down");
	TextDrawLetterSize(HelpArrowsTD[1], 0.000000, 0.000000);
	TextDrawTextSize(HelpArrowsTD[1], 17.000000, 21.000000);
	TextDrawAlignment(HelpArrowsTD[1], 1);
	TextDrawColor(HelpArrowsTD[1], -1);
	TextDrawSetShadow(HelpArrowsTD[1], 0);
	TextDrawSetOutline(HelpArrowsTD[1], 0);
	TextDrawBackgroundColor(HelpArrowsTD[1], 255);
	TextDrawFont(HelpArrowsTD[1], 4);
	TextDrawSetProportional(HelpArrowsTD[1], 0);
	TextDrawSetShadow(HelpArrowsTD[1], 0);

	HelpArrowsTD[2] = TextDrawCreate(331.367950, 386.049682, "LD_BEAT:right");
	TextDrawLetterSize(HelpArrowsTD[2], 0.000000, 0.000000);
	TextDrawTextSize(HelpArrowsTD[2], 17.000000, 21.000000);
	TextDrawAlignment(HelpArrowsTD[2], 1);
	TextDrawColor(HelpArrowsTD[2], -1);
	TextDrawSetShadow(HelpArrowsTD[2], 0);
	TextDrawSetOutline(HelpArrowsTD[2], 0);
	TextDrawBackgroundColor(HelpArrowsTD[2], 255);
	TextDrawFont(HelpArrowsTD[2], 4);
	TextDrawSetProportional(HelpArrowsTD[2], 0);
	TextDrawSetShadow(HelpArrowsTD[2], 0);

	HelpArrowsTD[3] = TextDrawCreate(288.965362, 386.049682, "LD_BEAT:left");
	TextDrawLetterSize(HelpArrowsTD[3], 0.000000, 0.000000);
	TextDrawTextSize(HelpArrowsTD[3], 17.000000, 21.000000);
	TextDrawAlignment(HelpArrowsTD[3], 1);
	TextDrawColor(HelpArrowsTD[3], -1);
	TextDrawSetShadow(HelpArrowsTD[3], 0);
	TextDrawSetOutline(HelpArrowsTD[3], 0);
	TextDrawBackgroundColor(HelpArrowsTD[3], 255);
	TextDrawFont(HelpArrowsTD[3], 4);
	TextDrawSetProportional(HelpArrowsTD[3], 0);
	TextDrawSetShadow(HelpArrowsTD[3], 0);

    HelpButtonsTD[0][0] = TextDrawCreate(363.999938, 383.977722, "LD_BEAT:square");
	TextDrawLetterSize(HelpButtonsTD[0][0], 0.000000, 0.000000);
	TextDrawTextSize(HelpButtonsTD[0][0], 21.000000, 26.000000);
	TextDrawAlignment(HelpButtonsTD[0][0], 1);
	TextDrawColor(HelpButtonsTD[0][0], -1);
	TextDrawSetShadow(HelpButtonsTD[0][0], 0);
	TextDrawSetOutline(HelpButtonsTD[0][0], 0);
	TextDrawBackgroundColor(HelpButtonsTD[0][0], 255);
	TextDrawFont(HelpButtonsTD[0][0], 4);
	TextDrawSetProportional(HelpButtonsTD[0][0], 0);
	TextDrawSetShadow(HelpButtonsTD[0][0], 0);

	HelpButtonsTD[1][0] = TextDrawCreate(386.933319, 384.092529, "LD_BEAT:square");
	TextDrawLetterSize(HelpButtonsTD[1][0], 0.000000, 0.000000);
	TextDrawTextSize(HelpButtonsTD[1][0], 21.000000, 26.000000);
	TextDrawAlignment(HelpButtonsTD[1][0], 1);
	TextDrawColor(HelpButtonsTD[1][0], -1);
	TextDrawSetShadow(HelpButtonsTD[1][0], 0);
	TextDrawSetOutline(HelpButtonsTD[1][0], 0);
	TextDrawBackgroundColor(HelpButtonsTD[1][0], 255);
	TextDrawFont(HelpButtonsTD[1][0], 4);
	TextDrawSetProportional(HelpButtonsTD[1][0], 0);
	TextDrawSetShadow(HelpButtonsTD[1][0], 0);

	HelpButtonsTD[2][0] = TextDrawCreate(409.634704, 384.092529, "LD_BEAT:square");
	TextDrawLetterSize(HelpButtonsTD[2][0], 0.000000, 0.000000);
	TextDrawTextSize(HelpButtonsTD[2][0], 21.000000, 26.000000);
	TextDrawAlignment(HelpButtonsTD[2][0], 1);
	TextDrawColor(HelpButtonsTD[2][0], -1);
	TextDrawSetShadow(HelpButtonsTD[2][0], 0);
	TextDrawSetOutline(HelpButtonsTD[2][0], 0);
	TextDrawBackgroundColor(HelpButtonsTD[2][0], 255);
	TextDrawFont(HelpButtonsTD[2][0], 4);
	TextDrawSetProportional(HelpButtonsTD[2][0], 0);
	TextDrawSetShadow(HelpButtonsTD[2][0], 0);

	HelpButtonsTD[0][1] = TextDrawCreate(371.666809, 389.511138, "N");
	TextDrawLetterSize(HelpButtonsTD[0][1], 0.212000, 1.405037);
	TextDrawAlignment(HelpButtonsTD[0][1], 1);
	TextDrawColor(HelpButtonsTD[0][1], -1);
	TextDrawSetShadow(HelpButtonsTD[0][1], 0);
	TextDrawSetOutline(HelpButtonsTD[0][1], 0);
	TextDrawBackgroundColor(HelpButtonsTD[0][1], 255);
	TextDrawFont(HelpButtonsTD[0][1], 2);
	TextDrawSetProportional(HelpButtonsTD[0][1], 1);
	TextDrawSetShadow(HelpButtonsTD[0][1], 0);

	HelpButtonsTD[1][1] = TextDrawCreate(394.568206, 389.511138, "2");
	TextDrawLetterSize(HelpButtonsTD[1][1], 0.212000, 1.405037);
	TextDrawAlignment(HelpButtonsTD[1][1], 1);
	TextDrawColor(HelpButtonsTD[1][1], -1);
	TextDrawSetShadow(HelpButtonsTD[1][1], 0);
	TextDrawSetOutline(HelpButtonsTD[1][1], 0);
	TextDrawBackgroundColor(HelpButtonsTD[1][1], 255);
	TextDrawFont(HelpButtonsTD[1][1], 2);
	TextDrawSetProportional(HelpButtonsTD[1][1], 1);
	TextDrawSetShadow(HelpButtonsTD[1][1], 0);

	HelpButtonsTD[2][1] = TextDrawCreate(416.269531, 392.411315, "Alt");
	TextDrawLetterSize(HelpButtonsTD[2][1], 0.097666, 0.865778);
	TextDrawAlignment(HelpButtonsTD[2][1], 1);
	TextDrawColor(HelpButtonsTD[2][1], -1);
	TextDrawSetShadow(HelpButtonsTD[2][1], 0);
	TextDrawSetOutline(HelpButtonsTD[2][1], 0);
	TextDrawBackgroundColor(HelpButtonsTD[2][1], 255);
	TextDrawFont(HelpButtonsTD[2][1], 2);
	TextDrawSetProportional(HelpButtonsTD[2][1], 1);
	TextDrawSetShadow(HelpButtonsTD[2][1], 0);

	//======================================
	
    DrivingSchoolStaticTD[0] = TextDrawCreate(570.003845, 198.723739, "box");
	TextDrawLetterSize(DrivingSchoolStaticTD[0], 0.000000, 1.500005);
	TextDrawTextSize(DrivingSchoolStaticTD[0], 0.000000, 44.000000);
	TextDrawAlignment(DrivingSchoolStaticTD[0], 2);
	TextDrawColor(DrivingSchoolStaticTD[0], -1);
	TextDrawUseBox(DrivingSchoolStaticTD[0], 1);
	TextDrawBoxColor(DrivingSchoolStaticTD[0], 53);
	TextDrawSetShadow(DrivingSchoolStaticTD[0], 0);
	TextDrawSetOutline(DrivingSchoolStaticTD[0], 0);
	TextDrawBackgroundColor(DrivingSchoolStaticTD[0], 255);
	TextDrawFont(DrivingSchoolStaticTD[0], 1);
	TextDrawSetProportional(DrivingSchoolStaticTD[0], 1);
	TextDrawSetShadow(DrivingSchoolStaticTD[0], 0);

	DrivingSchoolStaticTD[1] = TextDrawCreate(586.899719, 181.622695, "box");
	TextDrawLetterSize(DrivingSchoolStaticTD[1], 0.000000, 1.366672);
	TextDrawTextSize(DrivingSchoolStaticTD[1], 0.000000, 31.000000);
	TextDrawAlignment(DrivingSchoolStaticTD[1], 2);
	TextDrawColor(DrivingSchoolStaticTD[1], -1);
	TextDrawUseBox(DrivingSchoolStaticTD[1], 1);
	TextDrawBoxColor(DrivingSchoolStaticTD[1], 572661573);
	TextDrawSetShadow(DrivingSchoolStaticTD[1], 0);
	TextDrawSetOutline(DrivingSchoolStaticTD[1], 0);
	TextDrawBackgroundColor(DrivingSchoolStaticTD[1], 255);
	TextDrawFont(DrivingSchoolStaticTD[1], 1);
	TextDrawSetProportional(DrivingSchoolStaticTD[1], 1);
	TextDrawSetShadow(DrivingSchoolStaticTD[1], 0);

	DrivingSchoolStaticTD[2] = TextDrawCreate(552.166259, 196.377838, "Health");
	TextDrawLetterSize(DrivingSchoolStaticTD[2], 0.243664, 1.749330);
	TextDrawAlignment(DrivingSchoolStaticTD[2], 1);
	TextDrawColor(DrivingSchoolStaticTD[2], -1);
	TextDrawSetShadow(DrivingSchoolStaticTD[2], 0);
	TextDrawSetOutline(DrivingSchoolStaticTD[2], -1);
	TextDrawBackgroundColor(DrivingSchoolStaticTD[2], 255);
	TextDrawFont(DrivingSchoolStaticTD[2], 2);
	TextDrawSetProportional(DrivingSchoolStaticTD[2], 1);
	TextDrawSetShadow(DrivingSchoolStaticTD[2], 0);
	
	//===================================
	
	DrivingSchoolSuccessStaticTD[0] = TextDrawCreate(233.066574, 132.385131, "LD_SPAC:white");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[0], 0.000000, 0.000000);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[0], 174.000000, 176.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[0], 1);
	TextDrawColor(DrivingSchoolSuccessStaticTD[0], 255);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[0], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[0], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[0], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[0], 4);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[0], 0);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[0], 0);

	DrivingSchoolSuccessStaticTD[1] = TextDrawCreate(232.333328, 131.770385, "LD_DRV:tvcorn");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[1], 0.000000, 0.000000);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[1], 90.000000, 90.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[1], 1);
	TextDrawColor(DrivingSchoolSuccessStaticTD[1], -1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[1], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[1], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[1], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[1], 4);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[1], 0);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[1], 0);

	DrivingSchoolSuccessStaticTD[2] = TextDrawCreate(232.333206, 310.970428, "LD_DRV:tvcorn");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[2], 0.000000, 0.000000);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[2], 90.000000, -90.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[2], 1);
	TextDrawColor(DrivingSchoolSuccessStaticTD[2], -1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[2], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[2], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[2], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[2], 4);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[2], 0);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[2], 0);

	DrivingSchoolSuccessStaticTD[3] = TextDrawCreate(411.999664, 311.055511, "LD_DRV:tvcorn");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[3], 0.000000, 0.000000);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[3], -90.000000, -90.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[3], 1);
	TextDrawColor(DrivingSchoolSuccessStaticTD[3], -1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[3], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[3], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[3], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[3], 4);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[3], 0);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[3], 0);

	DrivingSchoolSuccessStaticTD[4] = TextDrawCreate(412.266479, 131.770416, "LD_DRV:tvcorn");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[4], 0.000000, 0.000000);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[4], -90.000000, 90.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[4], 1);
	TextDrawColor(DrivingSchoolSuccessStaticTD[4], -1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[4], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[4], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[4], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[4], 4);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[4], 0);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[4], 0);

	DrivingSchoolSuccessStaticTD[5] = TextDrawCreate(291.333404, 255.126022, "Success");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[5], 0.544999, 3.636740);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[5], 1);
	TextDrawColor(DrivingSchoolSuccessStaticTD[5], 8388863);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[5], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[5], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[5], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[5], 1);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[5], 1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[5], 0);
	
	/*DrivingSchoolSuccessStaticTD[6] = TextDrawCreate(322.032775, 316.918518, "Exit");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[6], 0.355333, 1.815703);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[6], 10.000000, 39.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[6], 2);
	TextDrawColor(DrivingSchoolSuccessStaticTD[6], -1);
	TextDrawUseBox(DrivingSchoolSuccessStaticTD[6], 1);
	TextDrawBoxColor(DrivingSchoolSuccessStaticTD[6], 255);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[6], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[6], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[6], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[6], 1);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[6], 1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[6], 0);
	TextDrawSetSelectable(DrivingSchoolSuccessStaticTD[6], 1);*/

	DrivingSchoolSuccessStaticTD[7] = TextDrawCreate(377.166687, 316.862823, "Next");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[7], 0.355333, 1.815703);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[7], 10.000000, 59.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[7], 2);
	TextDrawColor(DrivingSchoolSuccessStaticTD[7], 8388863);
	TextDrawUseBox(DrivingSchoolSuccessStaticTD[7], 1);
	TextDrawBoxColor(DrivingSchoolSuccessStaticTD[7], 255);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[7], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[7], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[7], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[7], 1);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[7], 1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[7], 0);
	TextDrawSetSelectable(DrivingSchoolSuccessStaticTD[7], 1);

	DrivingSchoolSuccessStaticTD[8] = TextDrawCreate(266.666778, 316.948150, "Exit");
	TextDrawLetterSize(DrivingSchoolSuccessStaticTD[8], 0.355333, 1.815703);
	TextDrawTextSize(DrivingSchoolSuccessStaticTD[8], 10.000000, 59.000000);
	TextDrawAlignment(DrivingSchoolSuccessStaticTD[8], 2);
	TextDrawColor(DrivingSchoolSuccessStaticTD[8], -1);
	TextDrawUseBox(DrivingSchoolSuccessStaticTD[8], 1);
	TextDrawBoxColor(DrivingSchoolSuccessStaticTD[8], 255);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[8], 0);
	TextDrawSetOutline(DrivingSchoolSuccessStaticTD[8], 0);
	TextDrawBackgroundColor(DrivingSchoolSuccessStaticTD[8], 255);
	TextDrawFont(DrivingSchoolSuccessStaticTD[8], 1);
	TextDrawSetProportional(DrivingSchoolSuccessStaticTD[8], 1);
	TextDrawSetShadow(DrivingSchoolSuccessStaticTD[8], 0);
	TextDrawSetSelectable(DrivingSchoolSuccessStaticTD[8], 1);

}

stock SetPlayerPosEx(playerid, Float:x, Float:y, Float:z)
{
	SetPlayerPos(playerid, x, y, z);
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("Freezer", 1000, false, "i", playerid);
	return 1;
}

stock LoadPlayerTD(playerid)
{
	DrivingSchoolTD[playerid][driving_school_hp_box_td] = CreatePlayerTextDraw(playerid, 610.194030, 198.823745, "box");
	PlayerTextDrawLetterSize(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 0.000000, 1.466670);
	PlayerTextDrawTextSize(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 0.000000, 31.000000);
	PlayerTextDrawAlignment(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 2);
	PlayerTextDrawColor(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], -1);
	PlayerTextDrawUseBox(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 1);
	PlayerTextDrawBoxColor(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 8388741);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 0);
	PlayerTextDrawSetOutline(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 0);
	PlayerTextDrawBackgroundColor(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 255);
	PlayerTextDrawFont(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 1);
	PlayerTextDrawSetProportional(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], 0);

	DrivingSchoolTD[playerid][driving_school_timer_td] = CreatePlayerTextDraw(playerid, 586.933471, 180.640930, "1:45");
	PlayerTextDrawLetterSize(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 0.309666, 1.533627);
	PlayerTextDrawAlignment(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 2);
	PlayerTextDrawColor(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], -1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 0);
	PlayerTextDrawSetOutline(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], -1);
	PlayerTextDrawBackgroundColor(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 255);
	PlayerTextDrawFont(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 3);
	PlayerTextDrawSetProportional(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], 0);

	DrivingSchoolTD[playerid][driving_school_health_td] = CreatePlayerTextDraw(playerid, 610.467163, 197.092666, "1000");
	PlayerTextDrawLetterSize(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 0.318331, 1.670516);
	PlayerTextDrawAlignment(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 2);
	PlayerTextDrawColor(playerid, DrivingSchoolTD[playerid][driving_school_health_td], -1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 0);
	PlayerTextDrawSetOutline(playerid, DrivingSchoolTD[playerid][driving_school_health_td], -1);
	PlayerTextDrawBackgroundColor(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 255);
	PlayerTextDrawFont(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 1);
	PlayerTextDrawSetProportional(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolTD[playerid][driving_school_health_td], 0);
	
	
	//=============================================================

	
	DrivingSchoolSuccessTD[playerid][driving_school_medal_td] = CreatePlayerTextDraw(playerid, 295.899993, 150.903213, "LD_DRV:bronze");
	PlayerTextDrawLetterSize(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 51.000000, 59.000000);
	PlayerTextDrawAlignment(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 1);
	PlayerTextDrawColor(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], -1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 0);
	PlayerTextDrawSetOutline(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 0);
	PlayerTextDrawBackgroundColor(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 255);
	PlayerTextDrawFont(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 4);
	PlayerTextDrawSetProportional(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 0);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td], 0);

	DrivingSchoolSuccessTD[playerid][driving_school_time_td] = CreatePlayerTextDraw(playerid, 322.333801, 215.718566, "Time:_05:20");
	PlayerTextDrawLetterSize(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 0.256999, 1.890369);
	PlayerTextDrawAlignment(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 2);
	PlayerTextDrawColor(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], -1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 0);
	PlayerTextDrawSetOutline(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 0);
	PlayerTextDrawBackgroundColor(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 255);
	PlayerTextDrawFont(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 2);
	PlayerTextDrawSetProportional(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], 0);

	DrivingSchoolSuccessTD[playerid][driving_school_health_td] = CreatePlayerTextDraw(playerid, 322.333587, 229.407501, "Veh_HP:_560");
	PlayerTextDrawLetterSize(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 0.256999, 1.890369);
	PlayerTextDrawAlignment(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 2);
	PlayerTextDrawColor(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], -1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 0);
	PlayerTextDrawSetOutline(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 0);
	PlayerTextDrawBackgroundColor(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 255);
	PlayerTextDrawFont(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 2);
	PlayerTextDrawSetProportional(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 1);
	PlayerTextDrawSetShadow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], 0);
}
stock RespawnPlayerAfterLesson(playerid)
{
	CancelSelectTextDraw(playerid);

    TempInfo[playerid][temp_driving_school_started] = 0;
    TempInfo[playerid][temp_driving_school_timer] = 0;
    TempInfo[playerid][temp_driving_school_checkpoint] = 0;
    
    HidePlayerDrivingSchoolTD(playerid);
    HidePlayerHelpButtons(playerid);
    HidePlayerHelpArrows(playerid);

    if(GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD >= 0 && GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD < MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS)
	{
	    DrivingSchoolVirtualWorld[GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD][driving_school_vw_active] = 0;
	}
	switch(TempInfo[playerid][temp_driving_school_lesson])
	{
	    case 1..4: SetPlayerPosEx(playerid, 1469.7548,-137.5443,2928.1428);
	    case 5..8: SetPlayerPosEx(playerid, 1472.9192,-137.5447,2928.1428);
	    case 9..11: SetPlayerPosEx(playerid, 1469.7631,-139.9840,2928.1428);
	    case 12..14: SetPlayerPosEx(playerid, 1472.7772,-139.9845,2928.1428);
	}
	SetPlayerFacingAngle(playerid, 132.5396);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);
    TempInfo[playerid][temp_driving_school_lesson] = 0;
    TogglePlayerControllable(playerid, 1);
    if(TempInfo[playerid][temp_driving_school_vehicle_id] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]);
        if(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object] != 0 && IsValidObject(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object]))
        {
            for(new i; i<3; i++)
            {
	            DestroyObject(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][i]);
	            vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][i] = 0;
            }
        }
        TempInfo[playerid][temp_driving_school_vehicle_id] = INVALID_VEHICLE_ID;
    }
}

stock GetVehicleHealthInt(vehicleid)
{
	new Float:veh_hp;
	GetVehicleHealth(vehicleid, veh_hp);
	return floatround(veh_hp, floatround_round);
}

stock UpdatePlayerDrivingSchoolTD(playerid)
{
	if(IsValidVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]))
	{
	    new veh_health = GetVehicleHealthInt(TempInfo[playerid][temp_driving_school_vehicle_id]);
	    
	    format:g_str_least("%d", veh_health);
		PlayerTextDrawSetString(playerid, DrivingSchoolTD[playerid][driving_school_health_td], g_str_least);
		
		switch(veh_health)
		{
		    case 0..450: PlayerTextDrawBoxColor(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], COLOR_RED);
		    case 451..750: PlayerTextDrawBoxColor(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], COLOR_YELLOW);
		    default: PlayerTextDrawBoxColor(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td], COLOR_GREEN);
		}
    }

    new ds_min, ds_sec;
	ds_min = TempInfo[playerid][temp_driving_school_timer] / 60;
	ds_sec = TempInfo[playerid][temp_driving_school_timer] % 60;

	format:g_str_least("%02d:%02d", ds_min, ds_sec);
	PlayerTextDrawSetString(playerid, DrivingSchoolTD[playerid][driving_school_timer_td], g_str_least);
	return 1;
}

stock ShowPlayerDrivingSchoolTD(playerid)
{
    UpdatePlayerDrivingSchoolTD(playerid);

    if(TempInfo[playerid][temp_driving_school_timer] > 0)
    {
    	PlayerTextDrawShow(playerid, DrivingSchoolTD[playerid][driving_school_timer_td]);
    	TextDrawShowForPlayer(playerid, DrivingSchoolStaticTD[1]);
    }

	TextDrawShowForPlayer(playerid, DrivingSchoolStaticTD[0]);
	TextDrawShowForPlayer(playerid, DrivingSchoolStaticTD[2]);
	
    PlayerTextDrawShow(playerid, DrivingSchoolTD[playerid][driving_school_health_td]);
    PlayerTextDrawShow(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td]);
    return 1;
}

stock HidePlayerDrivingSchoolTD(playerid)
{
	for(new i; i<3; i++)
		TextDrawHideForPlayer(playerid, DrivingSchoolStaticTD[i]);
		
    PlayerTextDrawHide(playerid, DrivingSchoolTD[playerid][driving_school_health_td]);
    PlayerTextDrawHide(playerid, DrivingSchoolTD[playerid][driving_school_timer_td]);
    PlayerTextDrawHide(playerid, DrivingSchoolTD[playerid][driving_school_hp_box_td]);
    return 1;
}

stock SetVehicleParamsExEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective)
{
	vInfo[vehicleid][vehicle_engine] = engine;
	vInfo[vehicleid][vehicle_lights] = lights;
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    return 1;
}

stock RebuildPlayerCheckpoint(playerid, const Float:cp_array[][], const sz = sizeof(cp_array))
{
    if(TempInfo[playerid][temp_driving_school_checkpoint]+1 < sz)
	{
	    TempInfo[playerid][temp_driving_school_checkpoint]++;
	    new cp = TempInfo[playerid][temp_driving_school_checkpoint];
	    if(cp+1 >= sz)
	    {
	        if(IsAHeli(GetPlayerVehicleID(playerid)))
	        {
			    SetPlayerRaceCheckpoint(playerid, 4,
				cp_array[cp][0], cp_array[cp][1], cp_array[cp][2],
			 	0.0, 0.0, 0.0,
			 	5.0);
		 	}
		 	else
		 	{
		 	    SetPlayerRaceCheckpoint(playerid, 1,
				cp_array[cp][0], cp_array[cp][1], cp_array[cp][2],
			 	0.0, 0.0, 0.0,
			 	5.0);
		 	}
	 	}
	 	else
	 	{
	 	    if(IsAHeli(GetPlayerVehicleID(playerid)))
	        {
			    SetPlayerRaceCheckpoint(playerid, 3,
				cp_array[cp][0], cp_array[cp][1], cp_array[cp][2],
			 	cp_array[cp+1][0], cp_array[cp+1][1], cp_array[cp+1][2],
			 	5.0);
		 	}
		 	else
		 	{
		 	    SetPlayerRaceCheckpoint(playerid, 0,
				cp_array[cp][0], cp_array[cp][1], cp_array[cp][2],
			 	cp_array[cp+1][0], cp_array[cp+1][1], cp_array[cp+1][2],
			 	5.0);
		 	}
	 	}
	}
	else
	{
		DisablePlayerRaceCheckpoint(playerid);
		HidePlayerDrivingSchoolTD(playerid);
		HidePlayerHelpArrows(playerid);
		ShowPlayerLessonSuccessTD(playerid);
	}
}

stock ShowPlayerLessonSuccessTD(playerid)
{
	SelectTextDraw(playerid, 0xAFAFAFAA);
    TempInfo[playerid][temp_driving_school_started] = 0;
    TempInfo[playerid][temp_driving_school_td_timer] = 10;
	TogglePlayerControllable(playerid, 0);
	for(new i; i<6; i++)
	    TextDrawShowForPlayer(playerid, DrivingSchoolSuccessStaticTD[i]);
	    
	if(TempInfo[playerid][temp_driving_school_lesson] != 4
	&& TempInfo[playerid][temp_driving_school_lesson] != 8
	&& TempInfo[playerid][temp_driving_school_lesson] != 11
	&& TempInfo[playerid][temp_driving_school_lesson] != 14)
	{
	    TextDrawShowForPlayer(playerid, DrivingSchoolSuccessStaticTD[7]);
	}
	TextDrawShowForPlayer(playerid, DrivingSchoolSuccessStaticTD[8]);
	    
	new ds_min, ds_sec;
	ds_min = TempInfo[playerid][temp_driving_school_counter] / 60;
	ds_sec = TempInfo[playerid][temp_driving_school_counter] % 60;
	
	format:g_str_least("Time: %02d:%02d", ds_min, ds_sec);
	PlayerTextDrawSetString(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td], g_str_least);
	
	format:g_str_least("Veh HP: %d", GetVehicleHealthInt(TempInfo[playerid][temp_driving_school_vehicle_id]));
	PlayerTextDrawSetString(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td], g_str_least);
	    
	PlayerTextDrawShow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td]);
	PlayerTextDrawShow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td]);
	PlayerTextDrawShow(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td]);
	return 1;
}
stock HidePlayerLessonSuccessTD(playerid)
{
	for(new i; i<9; i++)
	    TextDrawHideForPlayer(playerid, DrivingSchoolSuccessStaticTD[i]);

	PlayerTextDrawHide(playerid, DrivingSchoolSuccessTD[playerid][driving_school_medal_td]);
	PlayerTextDrawHide(playerid, DrivingSchoolSuccessTD[playerid][driving_school_time_td]);
	PlayerTextDrawHide(playerid, DrivingSchoolSuccessTD[playerid][driving_school_health_td]);
	return 1;
}

stock ShowPlayerLessonLoseDialog(playerid, message[])
{
	TogglePlayerControllable(playerid, 0);
	format:g_str_small("{ff0000}%s.\n{ffffff}Желаете начать заново?", message);
	ShowPlayerDialog(playerid, dDrivingSchool+2, DIALOG_STYLE_MSGBOX, "Урок", g_str_small, "Заново", "Выйти");
}

stock CheckPlayerLessons(playerid)
{
    new lesson_passed_counter;
    switch(TempInfo[playerid][temp_driving_school_lesson])
    {
        case 1..4:
        {
            for(new i; i<4; i++)
                if(uInfo[playerid][uDrivingLessonsPassed][i])
                    lesson_passed_counter++;
            format:g_str_small("[АШ]: Вы прошли %d из 4 уроков для получения лицензии на легковые автомобили", lesson_passed_counter);
            SendClientMessage(playerid, COLOR_SEAGREEN, g_str_small);

            if(lesson_passed_counter == 4)
            {
                SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Вы получили лицензию на управление легковым транспортом");
				uInfo[playerid][uLic][0] = 1;
				uInfo[playerid][uLicTime][0] = getdate()+30;
			}
        }
        case 5..8:
        {
            for(new i=4; i<8; i++)
                if(uInfo[playerid][uDrivingLessonsPassed][i])
                    lesson_passed_counter++;
                    
            format:g_str_small("[АШ]: Вы прошли %d из 4 уроков для получение лицензии на мотоциклы", lesson_passed_counter);
            SendClientMessage(playerid, COLOR_SEAGREEN, g_str_small);

            if(lesson_passed_counter == 4)
            {
                SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Вы получили лицензию на управление мотоциклами");
				uInfo[playerid][uLic][1] = 1;
				uInfo[playerid][uLicTime][1] = getdate()+30;
			}
        }
        case 9..11:
        {
            for(new i=8; i<11; i++)
                if(uInfo[playerid][uDrivingLessonsPassed][i])
                    lesson_passed_counter++;
                    
            format:g_str_small("[АШ]: Вы прошли %d из 3 уроков для получение лицензии на вертолеты", lesson_passed_counter);
            SendClientMessage(playerid, COLOR_SEAGREEN, g_str_small);

            if(lesson_passed_counter == 3)
            {
                SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Вы получили лицензию на управление мотоциклами");
				uInfo[playerid][uLic][2] = 1;
				uInfo[playerid][uLicTime][2] = getdate()+30;
			}
        }
        case 12..14:
        {
            for(new i=11; i<14; i++)
                if(uInfo[playerid][uDrivingLessonsPassed][i])
                    lesson_passed_counter++;
            SendClientMessage(playerid, COLOR_SEAGREEN, g_str_small);

            format:g_str_small("[АШ]: Вы прошли %d из 3 уроков для получение лицензии на лодки", lesson_passed_counter);
            SendClientMessage(playerid, COLOR_SEAGREEN, g_str_small);

            if(lesson_passed_counter == 3)
            {
                SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Вы получили лицензию на управление лодками");
				uInfo[playerid][uLic][3] = 1;
				uInfo[playerid][uLicTime][3] = getdate()+30;
			}
        }
    }
}
CMD:tp(playerid)
{
	SetPlayerPosEx(playerid,1458.5538,-130.1951,2927.1428);
}
stock StartLesson(playerid, lessonid)
{
    new as_vw = -1;
	if(GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD >= 0 && GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD < MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS)
	{
	    DrivingSchoolVirtualWorld[GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD][driving_school_vw_active] = 0;
	}
	//if(lessonid != 3 && lessonid != 4)
	//{
    for(new vw; vw<MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS; vw++)
    {
		if(!DrivingSchoolVirtualWorld[vw][driving_school_vw_active])
		{
		    as_vw = DRIVING_SCHOOL_VIRTUAL_WORLD+vw;
		    DrivingSchoolVirtualWorld[vw][driving_school_vw_active] = 1;
		    break;
  		}
    }
    if(as_vw == -1) return SendClientMessage(playerid, COLOR_RED, "Отсуствует пустая площадка для проведения урока. Попробуйте позже");
	SetPlayerVirtualWorld(playerid, as_vw);
    //}
    SetPlayerInterior(playerid, 0);
    TempInfo[playerid][temp_driving_school_checkpoint] = 0;
    if(IsValidVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]))
    {
        DestroyVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]);
        if(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object] != 0 && IsValidObject(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object]))
        {
            for(new i; i<3; i++)
            {
	            DestroyObject(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][i]);
	            vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][i] = 0;
            }
        }
        TempInfo[playerid][temp_driving_school_vehicle_id] = INVALID_VEHICLE_ID;
    }
	TempInfo[playerid][temp_driving_school_lesson] = lessonid;
	TempInfo[playerid][temp_driving_school_counter] = 0;
	TempInfo[playerid][temp_driving_school_timer] = 0;
	TempInfo[playerid][temp_driving_school_started] = 0;
	DisablePlayerRaceCheckpoint(playerid);
	
	HidePlayerHelpButtons(playerid);
	HidePlayerHelpArrows(playerid);
	ShowPlayerHelpButtons(playerid);

	TogglePlayerControllable(playerid, 0);
	
	for(new i; i<4; i++)
		TempInfo[playerid][temp_driving_school_help_af][i] = 0;
		
    TempInfo[playerid][temp_belt] = 0;
    RemovePlayerAttachedObject(playerid, 9);
    
 	switch(lessonid)
    {
        case 1:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(410, -2023.7158,-149.9784,35.3203, 180.0, 2, 2, 300);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 15;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Впервые за рулем\n\nВаша задача - пристегнуться, завести двигатель\nи проехать вперед.\nНичего сложного!", "Поехали", "");
        }
        case 2:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(598, -2074.3635,-126.7214,35.0402,271.5616, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
            new Panels, Doors, Lights, Tires;
			GetVehicleDamageStatus(TempInfo[playerid][temp_driving_school_vehicle_id], Panels, Doors, Lights, Tires);
            UpdateVehicleDamageStatus(TempInfo[playerid][temp_driving_school_vehicle_id], Panels, Doors, Lights, (Tires | 0b1111));
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 20;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - Дорога домой\n\nТут задачка посложнее. У вас пробиты колеса, попытайтесь проехать по\nвсем чекпоинтам не разбив машину.", "Поехали", "");
        }
        case 3:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(539, -2234.2000,-1742.7684,480.2095, 33.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 90;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - Cпуск смерти\n\nНеобходимо доехать из точки А в точку Б за 90 секунд, не повредив машину.", "Поехали", "");
        }
        case 4:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(442, -1981.9750,1118.1921,52.9446, 275.0, 0, 0, 300);
            vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][0] = CreateObject(19339, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
            vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][1] = CreateObject(2245, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
            vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][2] = CreateObject(325, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
            AttachObjectToVehicle(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][0], TempInfo[playerid][temp_driving_school_vehicle_id], 0.000000, -1.284999, 1.204999, 0.000000, 0.000000, 90.148422);
            AttachObjectToVehicle(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][1], TempInfo[playerid][temp_driving_school_vehicle_id], 0.000000, -0.579999, 1.604998, 0.000000, 0.000000, 0.000000); //Object Model: 2245 |
			AttachObjectToVehicle(vInfo[TempInfo[playerid][temp_driving_school_vehicle_id]][vehicle_grave_object][2], TempInfo[playerid][temp_driving_school_vehicle_id], 0.000000, -1.774998, 1.569998, -89.444953, 0.000000, 5.024998); //Object Model: 325
			SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
			SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
   			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 240;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 4", "Урок 4 - Похороните Джона\n\nНеобходимо доехать из точки А в точку Б за 90 секунд, не повредив машину.", "Поехали", "");
        }
        
        case 5:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(448, -2024.1781,-132.8457,34.8901,180.5889, 3, 3, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 20;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Скоро на работу\n\nНеобходимо завести двигатель, включить фары и проехать один круг по маппингу.", "Поехали", "");
        }
        case 6:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(468, 1559.4657,16.2805,23.8325, 182.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 90;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - Пыль в глаза\n\nНеобходимо проехать от А до В за 90 секунд", "ОК", "");
        }
        case 7:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(522, -1657.2830,531.1378,38.0086, 316.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 60;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - Тропа смерти\n\nНеобходимо проехать на моцике от А до В по мосту. 60 секунд.", "Поехали", "");
        }
        case 8:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(522, 1552.0715,-1365.8688,329.0319, 0.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 60;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 4", "Урок 4 - Двухколёсный паркур\n\nНеобходимо пройти все чекпоинты, прыгая по крышам небоскрёбов за отведённое время.", "Поехали", "");
        }
        case 9:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(469, -2227.5872,2326.7605,7.1145, 180.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            TempInfo[playerid][temp_driving_school_timer] = 60;
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Раскрутить лопасти\n\nЗавести двигатель, пристегнуть ремень и взлететь на нужную высоту вверх.", "Поехали", "");
        }
        case 10:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(488, -1920.4731,1102.9705,49.1042, 271.4193, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            TempInfo[playerid][temp_driving_school_timer] = 120;
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - Ниже Карлосона\n\nНеобходимо пролететь на низкой высоте (ниже крыш) по меткам в городе за определённое время.", "Поехали", "");
        }
        case 11:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(497, -871.8295,1044.5503,34.7220, 306.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            TempInfo[playerid][temp_driving_school_timer] = 120;
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - Тоннель смерти\n\nНеобходимо пролететь в тоннеле через чекпоинты за отведённое время.", "Поехали", "");
        }
        case 12:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(473, -761.2186,-2045.3983,4.9983, 0.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 10;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Греби веслом\n\nЗапустить двигатель и проплыть прямо до чекпоинта.", "Поехали", "");
        }
        case 13:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(493, -1465.2207,692.3495,-0.6553, 232.4837, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 120;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - По течению\n\nНеобходимо проплыть маршрут за отведённое время. Маршрут составь сам от армии СФ до пляжа ЛС.", "Поехали", "");
        }
        case 14:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(446, -47.6499,315.8129,-0.0911, 0.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleHealth(TempInfo[playerid][temp_driving_school_vehicle_id], 10000);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 90;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - На волне\n\nНеобходимо поставить трамплины и сделать маршрут по ним.", "Поехали", "");
        }
    }
    GetPlayerPos(playerid, TempInfo[playerid][temp_driving_start_pos][0], TempInfo[playerid][temp_driving_start_pos][1], TempInfo[playerid][temp_driving_start_pos][2]);
    printf("%f | %f | %f", TempInfo[playerid][temp_driving_start_pos][0], TempInfo[playerid][temp_driving_start_pos][1], TempInfo[playerid][temp_driving_start_pos][2]);
    ShowPlayerDrivingSchoolTD(playerid);
    return 1;
}
CMD:showlic(playerid, params[])
{
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_RED, "/showlic [ID]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, COLOR_RED, "Игрок не подключен");
    if(!PlayerToPlayer(playerid, params[0], 1.5)) return SendClientMessage(playerid, COLOR_RED, "Вы далеко друг от друга");
    format:g_str_small("\
    Лицензия\tСтатус\n\
	Легковые авто\t%s\n\
	Мотоциклы\t%s\n\
	Вертолеты\t%s\n\
	Лодки\t%s",
	(uInfo[playerid][uLic][0]) ? ((uInfo[playerid][uLicTime][0]>getdate()) ? ("{008000}Есть") : ("{ffa500}Аннулирована")) : ("{ff0000}Отсутсвует"),
	(uInfo[playerid][uLic][1]) ? ((uInfo[playerid][uLicTime][1]>getdate()) ? ("{008000}Есть") : ("{ffa500}Аннулирована")) : ("{ff0000}Отсутсвует"),
	(uInfo[playerid][uLic][2]) ? ((uInfo[playerid][uLicTime][2]>getdate()) ? ("{008000}Есть") : ("{ffa500}Аннулирована")) : ("{ff0000}Отсутсвует"),
	(uInfo[playerid][uLic][3]) ? ((uInfo[playerid][uLicTime][3]>getdate()) ? ("{008000}Есть") : ("{ffa500}Аннулирована")) : ("{ff0000}Отсутсвует"));
	
	ShowPlayerDialog(playerid, dEmpty, DIALOG_STYLE_TABLIST_HEADERS, "Лицензии", g_str_small, "ОК", "");
	return 1;
}

//================================== DEBUG
CMD:startlesson(playerid, params[])
{
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_RED, "/startlesson [Lesson ID]");

	StartLesson(playerid, params[0]);

    return 1;
}
CMD:setskin(playerid, params[])
{
	if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, COLOR_RED, "/setskin [ID] [Skin]");
	if(IsPlayerConnected(params[0]))
		SetPlayerSkin(params[0], params[1]);
	return 1;
}
CMD:veh(playerid,params[])
{
    new string[145];
    new Float:pX,Float:pY,Float:pZ;
    if(sscanf(params, "ddd", params[0],params[1],params[2])) return SendClientMessage(playerid, -1, "{BEBEBE}Использование: /veh [id машины] {цвет 1} {цвет 2}");
    {
        if(params[1] > 126 || params[1] < 0 || params[2] > 126 || params[2] < 0) return SendClientMessage(playerid, -1, "ID цвета от 0 до 126!");
        GetPlayerPos(playerid,pX,pY,pZ);
        new vehid = CreateVehicle(params[0],pX+2,pY,pZ,0.0,params[1],params[2],0,0);
        LinkVehicleToInterior(vehid, GetPlayerInterior(playerid));
        SetVehicleVirtualWorld(vehid, GetPlayerVirtualWorld(playerid));
        PutPlayerInVehicle(playerid, vehid, 0);
        format(string,sizeof(string),"{696969}[!] {1E90FF}Вы создали автомобиль №%d",params[0]);
        SendClientMessage(playerid,-1,string);
    }
    return 1;
}
CMD:restart(playerid)
{
	SendRconCommand("gmx");
}
