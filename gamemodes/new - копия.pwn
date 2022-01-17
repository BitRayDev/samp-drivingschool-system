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

new
	g_str_least[32],
	g_str_small[256],
	g_str_big[512];

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
new Text:DrivingSchoolSuccessStaticTD[6];
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
	temp_driving_school_help_af[4]
}
new TempInfo[MAX_PLAYERS][E_TEMP];

enum E_PLAYER_INFO
{
	uID,
	uName[MAX_PLAYER_NAME],
	uDrivingLessonsPassed[MAX_DRIVING_SCHOOL_LESSONS],
	uLic[4],
	uLicTime[4],
}
new uInfo[MAX_PLAYERS][E_PLAYER_INFO];

enum E_VEHICLE_INFO
{
	vehicle_engine,
	vehicle_lights
}
new vInfo[MAX_VEHICLES][E_VEHICLE_INFO];

new const Float:DS_Checkpoints[MAX_DRIVING_SCHOOL_LESSONS][MAX_DRIVING_SCHOOL_CHECKPOINTS][3]
{
	{
	
	},
	{
        {-2065.0090,-146.4335,34.9700},
		{-2054.5742,-166.3652,34.9707},
		{-2066.9001,-181.4125,34.9747},
		{-2080.7214,-202.0790,34.9704},
		{-2067.2190,-220.1379,34.9699},
		{-2067.1130,-238.9906,34.9797},
		{-2082.7148,-256.0026,34.9682}
	},
	{
        {-2318.1301, -1591.3228, 483.1674},
		{-2051.0007, -173.5404, 35.3203}
	},
	{

	},
	{
        {-2021.7336,-262.4369,35.3203},
		{-2081.9395,-261.1098,35.3203},
		{-2077.2231,-122.7169,35.3203}
	},
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
	},
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
	},
	{
        {1551.5552,-1338.7643,329.4729},//
		{1545.7909,-1224.9702,261.1632},//
		{1493.6180,-1149.2578,135.3880},//
		{1474.8896,-1182.3683,107.9311},//
		{1432.0256,-1120.1376,92.8966},//
		{1390.6272,-1047.2587,57.9729},//
		{1389.8893,-960.6755,41.3636},//
		{1402.2605,-921.8911,35.6370}//Финиш
	},
	{
        
	},
	{
        {-1853.2885,1103.6876,58.2898},
		{-1764.4313,1099.7202,59.5922},
		{-1714.4314,1095.2404,57.0050},
		{-1713.8844,897.5162,33.6791},
		{-1713.9700,799.9075,32.3031},
		{-1682.0371,705.9565,30.7827}
	},
	{
        {-831.0173,1074.1729,34.7554},
		{-754.8358,1129.2898,32.9285},
		{-688.7571,1166.7894,29.7081}
	}
}

/*new const Float:DS_Checkpoints_Lesson2[][3] =
{
	
};

new const Float:DS_Checkpoints_Lesson3[][3] =
{
	
};

new const Float:DS_Checkpoints_Lesson5[][3] =
{
	
};

new const Float:DS_Checkpoints_Lesson6[][3] =
{

};

new const Float:DS_Checkpoints_Lesson7[][3] =
{
	
};

new const Float:DS_Checkpoints_Lesson8[][3] =
{
	
};

new const Float:DS_Checkpoints_Lesson10[][3] =
{
	
};

new const Float:DS_Checkpoints_Lesson11[][3] =
{
	
};*/

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

function SecondTimer()
{
	foreach(new i:Player)
	{
	    if(TempInfo[i][temp_driving_school_lesson])
	    {
	        if(TempInfo[i][temp_driving_school_started])
	        {
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
	// Don't use these lines if it's a filterscript
	SetGameModeText("Blank Script");
	AddPlayerClass(0, -2032.6014,-95.2597,35.1641, 269.1425, 0, 0, 0, 0, 0, 0);
	SetTimer("SecondTimer", 1000, true);
	CreatePickup(1239, 23, -2032.4487, -102.0269, 35.1641, 0);
	Create3DTextLabel("Лицензии\nЛевый 'ALT'", COLOR_SEAGREEN, -2032.4487, -102.0269, 35.1641, 15.0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, uInfo[playerid][uName], MAX_PLAYER_NAME);
	uInfo[playerid][uID] = playerid+1;
	
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
	return 1;
}

public OnPlayerSpawn(playerid)
{
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
	    format:g_str_small("%s отстегнул ремень безопасности", uInfo[playerid][uName]);
		SetPlayerChatBubble(playerid, g_str_small, COLOR_PURPLE, 15.0, 1000);
		SendClientMessage(playerid, COLOR_GREEN, "Вы отстегнули ремень безопасности");
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
    		PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
    	}
    }
	else if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
		if(!TempInfo[playerid][temp_driving_school_lesson])
		{
		    if(!IsAMoto(vehicleid) && !IsAHeli(vehicleid) && !IsABoat(vehicleid))
		    {
				if(!uInfo[playerid][uLic][0])
				{
				    SendClientMessage(playerid, COLOR_RED, "У вас отсутсвует лицензия на вождение. Получить ее можно в Автошколе");
				    RemovePlayerFromVehicle(playerid);
				}
				else if(getdate() > uInfo[playerid][uLicTime][0])
				{
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
	        if(!IsAMoto(vehicleid) && !IsAHeli(vehicleid) && !IsABoat(vehicleid))
	        {
				TempInfo[playerid][temp_belt] = !TempInfo[playerid][temp_belt];
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
				if(!TempInfo[playerid][temp_driving_school_help_af][0] && TempInfo[playerid][temp_belt])
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Теперь заведите двигатель.");
				    SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите '2' чтобы завести двигатель.");
				    TempInfo[playerid][temp_driving_school_help_af][0] = 1;
				}
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
	        
     		if(!TempInfo[playerid][temp_belt] && !vInfo[vehicleid][vehicle_engine] && !IsAMoto(vehicleid) && !IsAHeli(vehicleid) && !IsABoat(vehicleid))
			{
				if(!TempInfo[playerid][temp_driving_school_help_af][1])
				{
				    TempInfo[playerid][temp_driving_school_help_af][1] = 1;
				    SendClientMessage(playerid, COLOR_RED, "[АШ]: Пристегнитесь, прежде чем завести двигатель");
					SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'N' чтобы пристегнуть ремень безопасности.");
				}
				return 1;
			}
			else
			{
			    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Теперь включите фары.");
		    	SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'Левый ALT' чтобы включить фары.");
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
		if(IsPlayerInRangeOfPoint(playerid, 1.5, -2032.4487,-102.0269,35.1641) && !GetPlayerVirtualWorld(playerid))
		{
		    ShowPlayerDialog(playerid, dDrivingSchool+3, DIALOG_STYLE_LIST, "Автошкола","\
			Лицензия на легковой транспорт\n\
			Лицензия на мотоциклы\n\
			Лицензия на вертолеты\n\
			Лицензия на лодки\n", "Выбрать", "Отмена");
		}
	}
	if(PRESSED(KEY_FIRE))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    new
				engine, lights, alarm, doors, bonnet, boot, objective,
				vehicleid = GetPlayerVehicleID(playerid);

     		if(!vInfo[vehicleid][vehicle_engine] && !vInfo[vehicleid][vehicle_lights] && !IsAHeli(vehicleid) && !IsABoat(vehicleid))
			{
				if(!TempInfo[playerid][temp_driving_school_help_af][2])
				{
				    TempInfo[playerid][temp_driving_school_help_af][2] = 1;
				    SendClientMessage(playerid, COLOR_RED, "[АШ]: Заведите двигатель, прежде чем включить фары.");
					SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите '2' чтобы завести двигатель.");
				}
				return 1;
			}
			else
			{
			    if(!TempInfo[playerid][temp_driving_school_help_af][3])
				{
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
							SetPlayerRaceCheckpoint(playerid, 0,
								DS_Checkpoints_Lesson3[0][0], DS_Checkpoints_Lesson3[0][1], DS_Checkpoints_Lesson3[0][2],
							 	DS_Checkpoints_Lesson3[1][0], DS_Checkpoints_Lesson3[1][1], DS_Checkpoints_Lesson3[1][2],
							 	5.0);
                        case 4:
							SetPlayerRaceCheckpoint(playerid, 1,
								885.2811,-1072.8804,24.1901,
							 	885.2811,-1072.8804,24.1901,
							 	5.0);
				    }
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Начните движение к метке");
				    TempInfo[playerid][temp_driving_school_help_af][3] = 1;
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
	        TempInfo[playerid][temp_driving_school_started] = 1;
	        switch(TempInfo[playerid][temp_driving_school_lesson])
	        {
	            case 1:
	            {
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Для начала пристегнитесь.");
					SendClientMessage(playerid, C_PODSKAZ, "[Подсказка]: Нажмите 'N' чтобы пристегнуть ремень безопасности.");
				}
				case 2:
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Для начала пристегнитесь.");
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы пристегнуться нажмите 'N'");
				}
				case 3:
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Для начала пристегнитесь.");
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы пристегнуться нажмите 'N'");
				}
				case 4:
				{
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Для начала пристегнитесь.");
				    SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы пристегнуться нажмите 'N'");
				}
				case 5:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					SetPlayerRaceCheckpoint(playerid, 0,
					DS_Checkpoints_Lesson5[0][0], DS_Checkpoints_Lesson5[0][1], DS_Checkpoints_Lesson5[0][2],
				 	DS_Checkpoints_Lesson5[1][0], DS_Checkpoints_Lesson5[1][1], DS_Checkpoints_Lesson5[1][2],
				 	5.0);
				}
				case 6:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					SetPlayerRaceCheckpoint(playerid, 0,
					DS_Checkpoints_Lesson6[0][0], DS_Checkpoints_Lesson6[0][1], DS_Checkpoints_Lesson6[0][2],
				 	DS_Checkpoints_Lesson6[1][0], DS_Checkpoints_Lesson6[1][1], DS_Checkpoints_Lesson6[1][2],
				 	5.0);
				}
				case 7:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					SetPlayerRaceCheckpoint(playerid, 0,
					DS_Checkpoints_Lesson7[0][0], DS_Checkpoints_Lesson7[0][1], DS_Checkpoints_Lesson7[0][2],
				 	DS_Checkpoints_Lesson7[1][0], DS_Checkpoints_Lesson7[1][1], DS_Checkpoints_Lesson7[1][2],
				 	5.0);
				}
				case 8:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					SetPlayerRaceCheckpoint(playerid, 0,
					DS_Checkpoints_Lesson8[0][0], DS_Checkpoints_Lesson8[0][1], DS_Checkpoints_Lesson8[0][2],
				 	DS_Checkpoints_Lesson8[1][0], DS_Checkpoints_Lesson8[1][1], DS_Checkpoints_Lesson8[1][2],
				 	5.0);
				}
				case 9:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					SetPlayerRaceCheckpoint(playerid, 4,
					-2227.5872,2326.7605,27.1145,
				 	-2227.5872,2326.7605,27.1145,
				 	5.0);
				}
				case 10:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					TogglePlayerControllable(playerid, 1);
					SetPlayerRaceCheckpoint(playerid, 3,
					DS_Checkpoints_Lesson10[0][0], DS_Checkpoints_Lesson10[0][1], DS_Checkpoints_Lesson10[0][2],
				 	DS_Checkpoints_Lesson10[1][0], DS_Checkpoints_Lesson10[1][1], DS_Checkpoints_Lesson10[1][2],
				 	5.0);
				}
				case 11:
				{
					SendClientMessage(playerid, COLOR_SEAGREEN, "[АШ]: Чтобы завести двигатель нажмите '2'");
					TogglePlayerControllable(playerid, 1);
					SetPlayerRaceCheckpoint(playerid, 3,
					DS_Checkpoints_Lesson11[0][0], DS_Checkpoints_Lesson10[0][1], DS_Checkpoints_Lesson10[0][2],
				 	DS_Checkpoints_Lesson11[1][0], DS_Checkpoints_Lesson10[1][1], DS_Checkpoints_Lesson10[1][2],
				 	5.0);
				}

			}
	    }
	    
	    case dDrivingSchool+2:
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
	    case dDrivingSchool+3:
	    {
	        if(!response) return 1;
	        SetPVarInt(playerid, "DrivingDialog3:ListItem", listitem);
			switch(listitem)
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

				    ShowPlayerDialog(playerid, dDrivingSchool+4, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
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

				    ShowPlayerDialog(playerid, dDrivingSchool+4, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
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

				    ShowPlayerDialog(playerid, dDrivingSchool+4, DIALOG_STYLE_TABLIST_HEADERS, "Автошкола", g_str_big, "Пройти", "Отмена");
				}
			}
	    }
	    case dDrivingSchool+4:
	    {
	        if(!response) return 1;
			new page = GetPVarInt(playerid, "DrivingDialog3:ListItem");
			switch(page)
			{
			    case 0:
					StartLesson(playerid, listitem+1);
                case 1:
					StartLesson(playerid, listitem+5);
                case 2:
					StartLesson(playerid, listitem+9);
                case 3:
					StartLesson(playerid, listitem+12);
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
	|| veh_model == 510)
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
	|| veh_model == 484)
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

stock LoadPlayerTD(playerid)
{
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
    if(GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD >= 0 && GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD < MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS)
	{
	    DrivingSchoolVirtualWorld[GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD][driving_school_vw_active] = 0;
	}
    SetPlayerPos(playerid, -2032.6014,-95.2597,35.1641);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 1);
    if(TempInfo[playerid][temp_driving_school_vehicle_id] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]);
        TempInfo[playerid][temp_driving_school_vehicle_id] = INVALID_VEHICLE_ID;
    }

    TempInfo[playerid][temp_driving_school_lesson] = 0;
    TempInfo[playerid][temp_driving_school_timer] = 0;
    TempInfo[playerid][temp_driving_school_checkpoint] = 0;
    HidePlayerDrivingSchoolTD(playerid);
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
			 	0.0, 0.0, 0.0,
			 	5.0);
		 	}
	 	}
	}
	else
	{
		DisablePlayerRaceCheckpoint(playerid);
		ShowPlayerLessonSuccessTD(playerid);
	}
}

stock ShowPlayerLessonSuccessTD(playerid)
{
    TempInfo[playerid][temp_driving_school_started] = 0;
    TempInfo[playerid][temp_driving_school_td_timer] = 5;
	TogglePlayerControllable(playerid, 0);
	for(new i; i<6; i++)
	    TextDrawShowForPlayer(playerid, DrivingSchoolSuccessStaticTD[i]);
	    
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
	for(new i; i<6; i++)
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
stock StartLesson(playerid, lessonid)
{
    new as_vw = -1;
	if(GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD >= 0 && GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD < MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS)
	{
	    DrivingSchoolVirtualWorld[GetPlayerVirtualWorld(playerid)-DRIVING_SCHOOL_VIRTUAL_WORLD][driving_school_vw_active] = 0;
	    SetPlayerVirtualWorld(playerid, 0);
	}
	if(lessonid != 3 && lessonid != 4)
	{
	    for(new vw; vw<MAX_DRIVING_SCHOOL_VIRTUAL_WORLDS; vw++)
	    {
			if(!DrivingSchoolVirtualWorld[vw][driving_school_vw_active])
			{
			    as_vw = DRIVING_SCHOOL_VIRTUAL_WORLD+vw;
			    break;
	  		}
	    }
	    if(as_vw == -1) return SendClientMessage(playerid, COLOR_RED, "Отсуствует пустая площадка для проведения урока. Попробуйте позже");
		SetPlayerVirtualWorld(playerid, as_vw);
		SetPlayerInterior(playerid, 0);
		TogglePlayerControllable(playerid, 0);
    }
    TempInfo[playerid][temp_driving_school_checkpoint] = 0;
    if(IsValidVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]))
    {
        DestroyVehicle(TempInfo[playerid][temp_driving_school_vehicle_id]);
        TempInfo[playerid][temp_driving_school_vehicle_id] = 0;
    }
	TempInfo[playerid][temp_driving_school_lesson] = lessonid;
	TempInfo[playerid][temp_driving_school_counter] = 0;
	TempInfo[playerid][temp_driving_school_timer] = 0;
	TempInfo[playerid][temp_driving_school_started] = 0;
	
	for(new i; i<4; i++)
		TempInfo[playerid][temp_driving_school_help_af][i] = 0;
		
    TempInfo[playerid][temp_belt] = 0;
 	switch(lessonid)
    {
        case 1:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(410, -2023.7158,-149.9784,35.3203, 180.0, 2, 2, 300);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 15;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Впервые за рулем\n\nВаша задача - пристегнуться, завести двигатель\nи проехать вперед.\nНичего сложного!", "ОК", "");
        }
        case 2:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(598, -2072.2231,-132.0949,34.9798, 170.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
            new Panels, Doors, Lights, Tires;
			GetVehicleDamageStatus(TempInfo[playerid][temp_driving_school_vehicle_id], Panels, Doors, Lights, Tires);
            UpdateVehicleDamageStatus(TempInfo[playerid][temp_driving_school_vehicle_id], Panels, Doors, Lights, (Tires | 0b1111));
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 20;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - Дорога домой\n\nТут задачка посложнее. У вас пробиты колеса, попытайтесь проехать по\nвсем чекпоинтам не разбив машину.", "ОК", "");
        }
        case 3:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(539, -2234.2000,-1742.7684,480.2095, 170.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
			SetPlayerVirtualWorld(playerid, 0);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 90;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - Cпуск смерти\n\nНеобходимо доехать из точки А в точку Б за 90 секунд, не повредив машину.", "ОК", "");
        }
        case 4:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(442, -1981.9750,1118.1921,52.9446, 170.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
			SetPlayerVirtualWorld(playerid, 0);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 180;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 4", "Урок 4 - Похороните Джона\n\nНеобходимо доехать из точки А в точку Б за 90 секунд, не повредив машину.", "ОК", "");
        }
        
        case 5:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(448, -2019.8757, -132.9421, 35.2781, 180.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 20;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Пыль в глаза\n\nНеобходимо завести двигатель, включить фары и проехать один круг по маппингу.", "ОК", "");
        }
        case 6:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(468, 1559.4657,16.2805,23.8325, 182.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 90;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - Скоро на работу\n\nНеобходимо проехать от А до В за 90 секунд", "ОК", "");
        }
        case 7:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(522, -1657.2830,531.1378,38.0086, 316.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 60;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - Тропа смерти\n\nНеобходимо проехать на моцике от А до В по мосту. 60 секунд.", "ОК", "");
        }
        case 8:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(522, 1552.0715,-1365.8688,329.0319, 0.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			TempInfo[playerid][temp_driving_school_timer] = 60;
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 4", "Урок 4 - Двухколёсный паркур\n\nНеобходимо пройти все чекпоинты, прыгая по крышам небоскрёбов за отведённое время.", "ОК", "");
        }
        case 9:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(469, -2227.5872,2326.7605,7.1145, 170.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 1", "Урок 1 - Раскрутить лопасти\n\nЗавести двигатель, пристегнуть ремень и взлететь на нужную высоту вверх.", "ОК", "");
        }
        case 10:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(488, -1920.4731,1102.9705,49.1042, 170.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 0, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 2", "Урок 2 - Ниже Карлосона\n\nНеобходимо пролететь на низкой высоте (ниже крыш) по меткам в городе за определённое время.", "ОК", "");
        }
        case 11:
        {
            TempInfo[playerid][temp_driving_school_vehicle_id] = CreateVehicle(497, -871.8049,1044.5327,42.2911, 306.0, 2, 2, 300);
            SetVehicleParamsExEx(TempInfo[playerid][temp_driving_school_vehicle_id], 1, 0, 0, 1, 0, 0, 0);
            SetVehicleVirtualWorld(TempInfo[playerid][temp_driving_school_vehicle_id], as_vw);
			PutPlayerInVehicle(playerid, TempInfo[playerid][temp_driving_school_vehicle_id], 0);
			ShowPlayerDialog(playerid, dDrivingSchool, DIALOG_STYLE_MSGBOX, "Урок 3", "Урок 3 - Тоннель смерти\n\nНеобходимо пролететь в тоннеле через чекпоинты за отведённое время.", "ОК", "");
        }
    }
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
