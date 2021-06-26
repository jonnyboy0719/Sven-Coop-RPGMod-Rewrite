// Defines
bool g_MapDefined_MeleeOnly = false;
bool g_AuraIsActive = false;
int g_iWeeklyBonusEXP = 0;

// Load achievements
#include "lib/achievements"
// Load playerdata
#include "lib/playerdata"

// Menu stuff
enum MenuEnum
{
	MENU_SKILLS = 0,
	MENU_SHOP,
	MENU_MODELS
};

#include "menu/skills"
#include "menu/models"

// Give our garbage
#include "give_donator"
#include "give_prestiges"

Menu::SkillMenu g_SkillMenu;
Menu::SkillMenuEx g_SkillMenuEx;
Menu::PlayerModelsMenu g_PlayerModelsMenu;
// End

// Gift from the gods
GiftFromTheGods::AmmoDrop g_AmmoDrop;
GiftFromTheGods::WeaponDrop g_WeaponDrop;
// End

// Our max values
const int MAX_LEVEL = 800;
const int MAX_PRESTIGE = 10;

const int AB_HEALTH_MAX = 400;
const int AB_ARMOR_MAX = 210;
const int AB_HEALTH_REGEN_MAX = 50;
const int AB_ARMOR_REGEN_MAX = 55;
const int AB_AMMO_MAX = 30;
const int AB_DOUBLEJUMP_MAX = 5;
const int AB_WEAPON_MAX = 10;
const int AB_AURA_MAX = 20;
const int AB_HOLYGUARD_MAX = 20;

const string SND_LVLUP = "sc_rpg/levelup.wav";
const string SND_LVLUP_800 = "sc_rpg/levelup_last.wav";
const string SND_PRESTIGE = "sc_rpg/prestige.wav";
const string SND_READY = "sc_rpg/ready.wav";
const string SND_AURA01 = "sc_rpg/bttlcry01.wav";
const string SND_AURA02 = "sc_rpg/bttlcry02.wav";
const string SND_AURA03 = "sc_rpg/bttlcry03.wav";
const string SND_HOLYGUARD = "sc_rpg/harmor.wav";
const string SND_HOLYWEP = "sc_rpg/wepdrop.wav";
const string SND_JUMP = "sc_rpg/jump.wav";
const string SND_JUMP_LAND = "sc_rpg/jump_land.wav";
const string SND_NULL = "null.wav";

final class CSCRPGCore
{
	private CScheduledFunction@ hThinker = null;
	CSCRPGCore()
	{
		// Load our DB file
		LoadDB();
		
		// Precache sounds
		PrecacheCoreSound( SND_LVLUP );
		PrecacheCoreSound( SND_LVLUP_800 );
		PrecacheCoreSound( SND_PRESTIGE );
		PrecacheCoreSound( SND_READY );
		PrecacheCoreSound( SND_AURA01 );
		PrecacheCoreSound( SND_AURA02 );
		PrecacheCoreSound( SND_AURA03 );
		PrecacheCoreSound( SND_HOLYGUARD );
		PrecacheCoreSound( SND_HOLYWEP );
		PrecacheCoreSound( SND_JUMP );
		PrecacheCoreSound( SND_JUMP_LAND );
		PrecacheCoreSound( SND_NULL );
	}
	
	~CSCRPGCore()
	{
		// Unload it
		UnloadDB();
		Reset();
	}
	
	// SQL
	private bool m_bIsSQL = false;
	private string m_szSQL_Hostname = "";
	private string m_szSQL_User = "";
	private string m_szSQL_Password = "";
	private string m_szSQL_Database = "";
	private int m_iSQL_Port = 0;
	
	private bool m_bLoadedDB = false;
	private File@ player_data = null;
	
	private void PlaySoundEffect( CBasePlayer@ pPlayer, string snd )
	{
		if ( pPlayer is null ) return;
		g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_AUTO, snd, 1.0f, ATTN_NORM, 0, 100 );
	}
	
	private void OnThink()
	{
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
			if ( (pPlayer !is null) && (pPlayer.IsConnected()) )
			{
				float flCurrentFrags = int(pPlayer.pev.frags);
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
				if ( g_PlayerCoreData.exists(szSteamId) )
				{
					PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
					if ( data is null ) continue;
					
					// Fix the model not showing
					if ( data.iWaitTimer_UseModel >= 0 )
					{
						if ( data.iWaitTimer_UseModel == 0 )
						{
							SetPlayerModel( pPlayer );
							// Play the sound, because we want to notify the players that we spawned!
							PlayPlayerSound( pPlayer, sound_spawn );
							if ( data.iPrestige >= 2 )
								GiveToPlayer::GiveItem( pPlayer, "item_longjump" );
						}
						data.iWaitTimer_UseModel--;
					}
					
					// Check our regen stuff
					RegenPlayer( pPlayer, data );
					
					// Check our timers
					PlayerTimers( pPlayer, data );
					
					// Playtime EXP bonus
					PlayTimeEXP( pPlayer, data );
					
					// Draw our HUD info
					DrawHUDInfo( pPlayer, data );
					
					// AchievementsCheck
					CheckForAchievements( pPlayer, data );
					
					if ( flCurrentFrags <= data.flScore ) continue;
					
					// Set our values and such
					data.flScore = flCurrentFrags;
					
					// Increase our EXP
					IncreaseEXP( data );
					
					// Give some cash
					data.iSouls += Math.RandomLong( 1, 5 );
					
					// Calculate level up, and save our data
					CalculateLevelUp( pPlayer, data );
				}
			}
		}
	}
	
	private void CheckForAchievements( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.iWaitTimer_UseModel > 0 ) return;
		
		// Prestige
		if ( data.iPrestige >= 1 )
			g_Achivements.GiveAchievement( pPlayer, "prestige_1", true );
		if ( data.iPrestige >= 2 )
			g_Achivements.GiveAchievement( pPlayer, "prestige_lj", true );
		if ( data.iPrestige >= 5 )
			g_Achivements.GiveAchievement( pPlayer, "prestige_5", true );
		
		// Map check
		if ( IsCurrentMap( "extreme_uboa_afterlife_v2" ) )
			g_Achivements.GiveAchievement( pPlayer, "extreme_uboa", true );
		if ( IsCurrentMap( "inv_dojo" ) )
			g_Achivements.GiveAchievement( pPlayer, "martialarts", true );
		
		// Check if we can add our player models tied to achievements
		AchievementPlayerModels( data );
	}
	
	void AchievementPlayerModels( PlayerData@ data )
	{
		if ( data is null ) return;
		
		if ( data.FindAchievement( "extreme_uboa" ) )
			data.AddPlayerModel( "afterlife_uboa" );
		
		if ( data.FindAchievement( "checkybrecky" ) )
		{
			data.AddPlayerModel( "afterlife_spetz1" );
			data.AddPlayerModel( "afterlife_spetz2" );
		}
	}
	
	void CheckForSpecificAchievement( CBasePlayer@ pPlayer, string szIDCheck )
	{
		if ( szIDCheck == "weapon_runeblade" )
			g_Achivements.GiveAchievement( pPlayer, "runeblade", true );
		if ( szIDCheck == "weapon_af_ethereal" )
			g_Achivements.GiveAchievement( pPlayer, "ethereal", true );
		if ( szIDCheck == "weapon_af_ethereal_mk2" )
			g_Achivements.GiveAchievement( pPlayer, "plasmarifle", true );
		if ( szIDCheck == "weapon_fotn" )
			g_Achivements.GiveAchievement( pPlayer, "fotn", true );
		if ( szIDCheck == "weapon_scinade" )
			g_Achivements.GiveAchievement( pPlayer, "scinade", true );
	}
	
	private string GetSkillProgress( float flProgress, float flProgressMAX )
	{
		float ratio = flProgress / flProgressMAX;
		float realpos = ratio * 10;
		string output = "[";
		
		// Our progress
		for ( int i = 0; i < 10; i++ )
		{
			if ( i <= realpos )
				output += "#";
			else
				output += "-";
		}
		
		output += "]";
		return output;
	}
	
	private void DrawHUDInfo( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		string szBonusEXP = "";
		if ( g_iWeeklyBonusEXP > 0 )
			szBonusEXP = " ( +" + g_iWeeklyBonusEXP + " )";
		string output = "";
		if ( data.iLevel < MAX_LEVEL )
			output = "Exp.:  " + data.iExp + " / " + data.iExpMax + szBonusEXP + "\n";
		output += "Level:  " + data.iLevel + " / " + MAX_LEVEL + "\n";
		output += "Medals:  " + data.iMedals + " / " + g_Achivements.GetMaxMedals() + "\n";
		output += "Souls:  " + data.iSouls + "\n";
		output += "Prestige:  " + data.iPrestige + " / " + MAX_PRESTIGE + "\n";
		output += "Your SteamID:  " + data.szSteamID + "\n";
		
		if ( data.iPoints > 0 )
			output += "\nYou have " + data.iPoints + " skillpoint(s) available!\nWrite /skills to access the menu!\n\n";
		
		// Our message
		HUDTextParams params;
		
		params.channel = 16;	// We don't want to break other text channels, so lets put it here instead
		params.effect = 0;
		params.x = 0.75;
		params.y = 0.04;
		
		params.r1 = 184;
		params.g1 = 10;
		params.b1 = 14;
		params.a1 = 225;
		
		params.r2 = 255;
		params.g2 = 15;
		params.b2 = 15;
		params.a2 = 200;
		
		params.fadeinTime = 0.0;
		params.fadeoutTime = 0.0;
		params.holdTime = 255.0;
		params.fxTime = 6.0;
		
		g_PlayerFuncs.HudMessage(
			pPlayer,
			params,
			output
		);
		
		// Our holy armor / battlecry
		string buffer1 = "";
		string buffer2 = "";
		
		if ( data.iStat_holyarmor > 0 )
		{
			if ( data.iWaitTimer_HolyArmor >= data.iWaitTimer_HolyArmor_Max )
			{
				if ( IsGodMode( pPlayer ) )
					buffer1 = "Holy Armor:\nCan't be used right now!\n";
				else
					buffer1 = "Holy Armor:\n[Write 'medic' to use]\n";
			}
			else
				buffer1 = "Holy Armor:\n" + GetSkillProgress( data.iWaitTimer_HolyArmor, data.iWaitTimer_HolyArmor_Max ) + "\n";
		}
		
		if ( data.iStat_battlecry > 0 )
		{
			if ( data.iWaitTimer_BattleCry >= data.iWaitTimer_BattleCry_Max )
			{
				if ( g_AuraIsActive )
					buffer2 = "The Warrior's Battlecry:\nCan't be used right now!\n";
				else
					buffer2 = "The Warrior's Battlecry:\n[Write 'grenade' to use]\n";
			}
			else
				buffer2 = "The Warrior's Battlecry:\n" + GetSkillProgress( data.iWaitTimer_BattleCry, data.iWaitTimer_BattleCry_Max ) + "\n";
		}
		
		string output2 = buffer1 + buffer2;
		
		// Our message
		HUDTextParams params2;
		
		params2.channel = 17;	// We don't want to break other text channels, so lets put it here instead
		params2.effect = 0;
		params2.x = 0.02;
		params2.y = 0.8;
		
		params2.r1 = 184;
		params2.g1 = 10;
		params2.b1 = 14;
		params2.a1 = 225;
		
		params2.r2 = 255;
		params2.g2 = 15;
		params2.b2 = 15;
		params2.a2 = 255;
		
		params2.fadeinTime = 0.0;
		params2.fadeoutTime = 0.0;
		params2.holdTime = 255.0;
		params2.fxTime = 6.0;
		
		g_PlayerFuncs.HudMessage(
			pPlayer,
			params2,
			output2
		);
	}
	
	private void PlayTimeEXP( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( data is null ) return;
		if ( data.iWaitTimer_FreeEXP <= 0 )
		{
			if ( data.iLevel < MAX_LEVEL )
			{
				data.iExp += 150 + data.iLevel;
				CalculateLevelUp( pPlayer, data );
			}
			data.iWaitTimer_FreeEXP = 120;
			data.iSouls += Math.RandomLong( 25, 50 );
		}
		else
			data.iWaitTimer_FreeEXP--;
	}
	
	void SetMaxArmorHealth( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		const int MAX_DEFAULT = 100;
		pPlayer.pev.max_health = MAX_DEFAULT + data.iStat_health + data.iMedals;
		pPlayer.pev.armortype = MAX_DEFAULT + data.iStat_armor + data.iMedals;
	}
	
	private void SetArmorHealth( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		pPlayer.pev.health += data.iStat_health;
		pPlayer.pev.armorvalue += data.iStat_armor;
	}
	
	private void DoBattleCry( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		// Reads the player health, aura (+150)
		float flvalue = pPlayer.pev.health / 2 + 150 + data.iStat_battlecry;
		
		// Grabs our health and armor values
		float flvalue_self = pPlayer.pev.health / 2 + 180 + data.iStat_battlecry;
		float flvalue_self_armor = pPlayer.pev.armorvalue / 2 + 180 + data.iStat_battlecry;
		
		// Change to int
		int value = int( flvalue );
		int value_self = int( flvalue_self );
		int value_self_armor = int( flvalue_self_armor );
		
		// If the player has less health or armor, override it.
		if ( pPlayer.pev.health < value_self )
			pPlayer.pev.health = value_self;
		
		if ( pPlayer.pev.armorvalue < value_self_armor )
			pPlayer.pev.armorvalue = value_self_armor;
		
		// Within radius? then give them some boost!
		float distance = 200.0f + data.iStat_battlecry;
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex( i );
			if ( (pTarget !is null) && (pTarget.IsConnected()) )
			{
				// Don't increase ourselves
				if ( pTarget == pPlayer ) continue;
				Vector vEntOrigin = (pTarget.pev.absmin + pTarget.pev.absmax)/2;
				if ( (vEntOrigin - pPlayer.pev.origin).Length() < distance )
				{
					if ( pPlayer.pev.health < value )
						pPlayer.pev.health = value;
					
					if ( pPlayer.pev.armorvalue < value )
						pPlayer.pev.armorvalue = value;
					
					g_Achivements.GiveAchievement( pPlayer, "teamplayer", true );
				}
			}
		}
	}
	
	private void PlayerTimers( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.iWaitTimer_Hurt_Snd > 0 ) data.iWaitTimer_Hurt_Snd--;
		if ( data.iWaitTimer_SndEffect > 0 ) data.iWaitTimer_SndEffect--;
		
		if ( data.iWaitTimer_HolyArmor < data.iWaitTimer_HolyArmor_Max )
		{
			data.iWaitTimer_HolyArmor++;
			if ( data.iWaitTimer_HolyArmor == data.iWaitTimer_HolyArmor_Max )
				ClientSidedSound( pPlayer, SND_READY );
		}
		
		if ( data.iWaitTimer_HolyArmor_Reset > 0 )
			data.iWaitTimer_HolyArmor_Reset--;
		else
		{
			if ( data.iWaitTimer_HolyArmor_Reset == 0 )
			{
				SetGodMode( pPlayer, false );
				SetAuraGlow( false, pPlayer, 255, 255, 255 );
				data.iWaitTimer_HolyArmor_Reset = -1;
			}
		}
		
		if ( data.iWaitTimer_BattleCry < data.iWaitTimer_BattleCry_Max )
		{
			data.iWaitTimer_BattleCry++;
			if ( data.iWaitTimer_BattleCry == data.iWaitTimer_BattleCry_Max )
				ClientSidedSound( pPlayer, SND_READY );
		}
		
		if ( data.iWaitTimer_BattleCry_Reset > 0 )
		{
			DoBattleCry( pPlayer, data );
			data.iWaitTimer_BattleCry_Reset--;
		}
		else
		{
			if ( data.iWaitTimer_BattleCry_Reset == 0 )
			{
				SetAuraGlow( false, pPlayer, 255, 255, 255 );
				g_AuraIsActive = false;
				data.iWaitTimer_BattleCry_Reset = -1;
			}
		}
		
		if ( pPlayer.IsAlive() )
		{
			if ( data.iStat_gotg_ammo > 0 )
			{
				if ( data.iWaitTimer_AmmoDrop > 0 )
					data.iWaitTimer_AmmoDrop--;
				else
				{
					g_AmmoDrop.GiveDrop( pPlayer, data.iStat_gotg_ammo );
					data.iWaitTimer_AmmoDrop = 60 - data.iStat_gotg_ammo;
				}
			}
			
			if ( data.iStat_gotg_weapon > 0 )
			{
				if ( data.iWaitTimer_WeaponDrop > 0 )
					data.iWaitTimer_WeaponDrop--;
				else
				{
					g_WeaponDrop.GiveDrop( pPlayer, data.iStat_gotg_ammo );
					data.iWaitTimer_WeaponDrop = 60 - data.iStat_gotg_weapon;
				}
			}
		}
		
		if ( data.iWaitTimer_Hurt > 0 )
		{
			data.iWaitTimer_Hurt--;
			if ( data.iWaitTimer_Hurt == 0 )
				data.bIsHurt = false;
		}
	}
	
	private void CalculatePoints( PlayerData@ data )
	{
		if ( data is null ) return;
		
		// Read our unused levels from our level
		int iUnusedPoints = data.iLevel;
		
		// Now we remove points if we have some under the stat values
		iUnusedPoints -= data.iStat_health;
		iUnusedPoints -= data.iStat_health_regen;
		iUnusedPoints -= data.iStat_armor;
		iUnusedPoints -= data.iStat_armor_regen;
		iUnusedPoints -= data.iStat_gotg_ammo;
		iUnusedPoints -= data.iStat_gotg_weapon;
		iUnusedPoints -= data.iStat_doublejump;
		iUnusedPoints -= data.iStat_battlecry;
		iUnusedPoints -= data.iStat_holyarmor;
		
		// Our unused points
		data.iPoints = iUnusedPoints;
	}
	
	private void RegenPlayer( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.bIsHurt ) return;
		
		if ( data.iStat_health_regen > 0 )
		{
			if ( pPlayer.pev.health < pPlayer.pev.max_health )
				pPlayer.pev.health += 5 + data.iStat_health_regen;
		}
		
		if ( data.iStat_armor_regen > 0 )
		{
			if ( pPlayer.pev.armorvalue < pPlayer.pev.armortype )
				pPlayer.pev.armorvalue += 5 + data.iStat_armor_regen;
		}
	}
	
	private void LevelUp( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		// Increase our level
		data.iLevel++;
		
		// Increase our points
		data.iPoints++;
		
		// Reset exp
		data.iExp = 0;
		
		// Play sound effect
		if ( data.iLevel >= MAX_LEVEL )
		{
			PlaySoundEffect( pPlayer, SND_LVLUP_800 );
			string szNick = pPlayer.pev.netname;
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] Everyone say \"Congratulations!!!\" to " + szNick + ", who has reached Level " + MAX_LEVEL + "!!\n");
		}
		else
			ClientSidedSound( pPlayer, SND_LVLUP );
		
		// Calculate new required EXP
		RequiredEXP( data );
	}
	
	private bool InsertData_Begin( string SteamID )
	{
		// We already exist, ignore...
		if ( g_PlayerCoreData.exists( SteamID ) )
			return false;
		
		PlayerData data;
		data.szSteamID = SteamID;
		data.iMedals = 0;
		g_PlayerCoreData[data.szSteamID] = data;
		
		return true;
	}
	
	private void InsertData( string szFullLine, string SteamID, int iVal, string szLine )
	{
		// Just makin sure linux wont fuck
		szFullLine = szLine.SubString( szLine.Length() - 1, 1 );
		if ( szFullLine == " " || szFullLine == "\n" || szFullLine == "\r" || szFullLine == "\t" )
			szLine = szLine.SubString( 0, szLine.Length() - 1 );
		
		// We don't exist, ignore...
		if ( !g_PlayerCoreData.exists( SteamID ) )
			return;
		
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[SteamID]);
		
		int iOutput = atoi( szLine );
		switch( iVal )
		{
			case 1: data.iLevel = iOutput; break;
			case 2: data.iPrestige = iOutput; break;
			case 3: data.iSouls = iOutput; break;
			case 4: data.iExp = iOutput; break;
			case 5: data.iExpMax = iOutput; break;
			case 6: data.iStat_health = iOutput; break;
			case 7: data.iStat_armor = iOutput; break;
			case 8: data.iStat_health_regen = iOutput; break;
			case 9: data.iStat_armor_regen = iOutput; break;
			case 10: data.iStat_gotg_ammo = iOutput; break;
			case 11: data.iStat_gotg_weapon = iOutput; break;
			case 12: data.iStat_doublejump = iOutput; break;
			case 13: data.iStat_battlecry = iOutput; break;
			case 14: data.iStat_holyarmor = iOutput; break;
			case 15: data.szModel = szLine; break;
			case 16: data.szModelSpecial = szLine; break;
			case 17: data.bIsCommunity = iOutput > 0 ? true : false; break;
			case 18: data.bIsDonator = iOutput > 0 ? true : false; break;
		}
		
		g_PlayerCoreData[SteamID] = data;
	}
	
	private void LoadDB()
	{
		g_PlayerCoreData.deleteAll();
		if ( !m_bIsSQL ) return;
		// TODO - SQL load
	}
	
	private void UnloadDB()
	{
		g_PlayerCoreData.deleteAll();
		if ( !m_bLoadedDB ) return;
		if ( !m_bIsSQL ) return;
		// TODO - We only continue if we use SQL
	}
	
	private int LoadFromDB( string SteamID, string szValue )
	{
		if ( !m_bLoadedDB ) return 0;
		// TODO
		return 0;
	}
	
	private string LoadFromDB_Model( string SteamID, string szValue )
	{
		if ( !m_bLoadedDB ) return "";
		// TODO
		return "";
	}
	
	private void LoadData( PlayerData@ data, string SteamID )
	{
		data.szSteamID = SteamID;
		data.bIsCommunity = LoadFromDB( SteamID, "member" ) > 0 ? true : false;
		data.bIsDonator = LoadFromDB( SteamID, "donator" ) > 0 ? true : false;
		data.iLevel = LoadFromDB( SteamID, "level" );
		data.iPrestige = LoadFromDB( SteamID, "prestige" );
		data.iSouls = LoadFromDB( SteamID, "money" );
		data.iExp = LoadFromDB( SteamID, "exp" );
		data.iExpMax = LoadFromDB( SteamID, "exp_max" );
		data.iStat_health = LoadFromDB( SteamID, "health" );
		data.iStat_health_regen = LoadFromDB( SteamID, "health_regen" );
		data.iStat_armor = LoadFromDB( SteamID, "armor" );
		data.iStat_armor_regen = LoadFromDB( SteamID, "armor_regen" );
		data.iStat_gotg_ammo = LoadFromDB( SteamID, "gotg_ammo" );
		data.iStat_gotg_weapon = LoadFromDB( SteamID, "gotg_weapon" );
		data.iStat_doublejump = LoadFromDB( SteamID, "doublejump" );
		data.iStat_battlecry = LoadFromDB( SteamID, "battlecry" );
		data.iStat_holyarmor = LoadFromDB( SteamID, "holyarmor" );
	}
	
	private void AddPlayerModel( CBasePlayer@ pPlayer, string SteamID, string szModel )
	{
		if ( !g_PlayerCoreData.exists( SteamID ) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[SteamID]);
		if ( data is null ) return;
		data.AddPlayerModel( szModel );
	}
	
	// Only used by the local files
	private string ToSteamID64( string &in szSteamID )
	{
		if ( szSteamID.Length() < 11 )
			return "steamid_invalid";
		
		int iID_10 = atoi( szSteamID.SubString( 10, 1 ) );
		int iID_8 = atoi( szSteamID.SubString( 8, 1 ) );
		
		int iUpper = 765611979;
		int iFriendID = iID_10 * 2 + 60265728 + iID_8 - 48;
		
		int iDiv = iFriendID / 100000000;
		int tt = iDiv / 10 + 1;
		int iIdx = 9 - ( iDiv > 0 ? tt : 0 );
		iUpper += iDiv;
		
		string buffer = "" + iUpper + iIdx + iFriendID;
		return buffer;
	}
	
	private void LoadFromFile( CBasePlayer@ pPlayer, string SteamID )
	{
		if ( m_bIsSQL ) return;
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_" + ToSteamID64( SteamID ) + ".txt", OpenFile::READ );
		if ( player_data !is null && player_data.IsOpen() )
		{
			while( !player_data.EOFReached() )
			{
				string sLine;
				player_data.ReadLine( sLine );
				// Fix for linux
				string sFix = sLine.SubString( sLine.Length() - 1, 1 );
				if ( sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t" )
					sLine = sLine.SubString( 0, sLine.Length() - 1 );
				
				if ( sLine.SubString( 0, 1 ) == "#" || sLine.IsEmpty() )
					continue;
				
				array<string> parsed = sLine.Split(" ");
				if ( parsed.length() < 1 )
					continue;
				
				// SteamID compare
				if ( CheckConfigDefine( sFix, parsed[0], "stats" ) )
				{
					/*
						0 - stats
						1 - LEVEL
						2 - PRESTIGE
						3 - MONEY
						4 - EXP
						5 - EXPMAX
						6 - STAT_HEALTH
						7 - STAT_ARMOR
						8 - STAT_HEALTH_REGEN
						9 - STAT_ARMOMR_REGEN
						10 - STAT_AMMO
						11 - STAT_WEAPON
						12 - STAT_JUMP
						13 - STAT_AURA
						14 - STAT_HOLYARMOR
						15 - PLAYER_MODEL
						16 - PLAYER_MODEL_SPECIAL
					*/
					if ( parsed.length() < 14 )
						continue;
					
					if ( InsertData_Begin( SteamID ) )
					{
						InsertData( sFix, SteamID, 1, parsed[1] );
						InsertData( sFix, SteamID, 2, parsed[2] );
						InsertData( sFix, SteamID, 3, parsed[3] );
						InsertData( sFix, SteamID, 4, parsed[4] );
						InsertData( sFix, SteamID, 5, parsed[5] );
						InsertData( sFix, SteamID, 6, parsed[6] );
						InsertData( sFix, SteamID, 7, parsed[7] );
						InsertData( sFix, SteamID, 8, parsed[8] );
						InsertData( sFix, SteamID, 9, parsed[9] );
						InsertData( sFix, SteamID, 10, parsed[10] );
						InsertData( sFix, SteamID, 11, parsed[11] );
						InsertData( sFix, SteamID, 12, parsed[12] );
						InsertData( sFix, SteamID, 13, parsed[13] );
						InsertData( sFix, SteamID, 14, parsed[14] );
						InsertData( sFix, SteamID, 15, parsed[15] );
						InsertData( sFix, SteamID, 16, parsed[16] );
					}
				}
				// Our achievement we have earned
				else if ( CheckConfigDefine( sFix, parsed[0], "achievement" ) )
					g_Achivements.GiveAchievement( pPlayer, parsed[ 1 ], false, atoi( parsed[ 2 ] ) );
				// Our models
				else if ( CheckConfigDefine( sFix, parsed[0], "model" ) )
					AddPlayerModel( pPlayer, SteamID, parsed[ 1 ] );
			}
			m_bLoadedDB = true;
			player_data.Close();
		}
		else
			g_Game.AlertMessage(at_logged, "[SCRPG] Failed to load scrpg_" + ToSteamID64( SteamID ) + ".txt!\n");
	}
	
	private void SaveToFile( PlayerData@ data, bool backup = false )
	{
		if ( data is null ) return;
		string strBackup = "";
		if ( backup )
			strBackup = "-backup";
		string fileLoad = "scripts/plugins/store/scrpg_" + ToSteamID64( data.szSteamID ) + strBackup + ".txt";
		@player_data = g_FileSystem.OpenFile( fileLoad, OpenFile::WRITE );
		if ( player_data !is null && player_data.IsOpen() )
		{
			string output = "stats " + data.iLevel + " " + data.iPrestige + " "
			+ data.iSouls + " " + data.iExp + " " + data.iExpMax + " " + data.iStat_health
			+ " " + data.iStat_armor + " " + data.iStat_health_regen + " " + data.iStat_armor_regen + " "
			+ data.iStat_gotg_ammo + " " + data.iStat_gotg_weapon + " " + data.iStat_doublejump + " "
			+ data.iStat_battlecry + " " + data.iStat_holyarmor + " " + data.szModel + " " + data.szModelSpecial + " "
			+ data.bIsCommunity + " " + data.bIsDonator + "\n";
			
			// Add our achievements
			if ( data.hAchievements.length() > 0 )
			{
				output += "\n";
				for ( uint i = 0; i < data.hAchievements.length(); i++ )
				{
					CAchievement@ pAchievement = data.hAchievements[ i ];
					if ( pAchievement is null ) continue;
					output += "achievement " + pAchievement.GetID() + " " + pAchievement.GetCurrent() + "\n";
				}
			}
			
			// Add our models
			if ( data.hAvailableModels.length() > 0 )
			{
				output += "\n";
				for ( uint i = 0; i < data.hAvailableModels.length(); i++ )
				{
					CPlayerModelBase@ pModel = data.hAvailableModels[ i ];
					if ( pModel is null ) continue;
					output += "model " + pModel.GetModel() + "\n";
				}
			}
			
			player_data.Write( output );
			player_data.Close();
		}
		else
			g_Game.AlertMessage(at_logged, "[SCRPG] Failed to save " + fileLoad + "!\n");
	}
	
	private void SaveData( PlayerData@ data )
	{
		if ( data is null ) return;
		if ( m_bIsSQL )
		{
			// TODO
		}
		else
			SaveToFile( data );
	}
	
	private void CalculateLevelUp( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( data is null ) return;
		if ( data.iExp >= data.iExpMax )
			LevelUp( pPlayer, data );
		SaveData( data );
	}
	
	private void RequiredEXP( PlayerData@ data )
	{
		if ( data is null ) return;
		float flLevelToEXPCalculation = float( data.iLevel ) * 1500.0 * 8.5;
		data.iExpMax = int( flLevelToEXPCalculation ) + data.iLevel;
	}
	
	private int CalculateBonusEXP( PlayerData@ data )
	{
		if ( data is null ) return 0;
		
		// Medal calculation
		float flMedals = 0;
		if ( data.iMedals > 0 )
			flMedals = data.iMedals * 8;
		int iMedalExp = int( flMedals );
		
		// Lets calculate
		if ( data.iPrestige > 0 )
		{
			float flPrestigeCalculate = float( data.iPrestige / 0.1 ) * 500;
			return int( flPrestigeCalculate ) + iMedalExp + g_iWeeklyBonusEXP;
		}
		
		return iMedalExp + g_iWeeklyBonusEXP;
	}
	
	private void IncreaseEXP( PlayerData@ data )
	{
		if ( data is null ) return;
		int randnum = Math.RandomLong( 500, 1000 );
		float flLevelCalculate = float( data.iLevel + randnum ) * 10 * 7.2;
		int iCalculateEXP = int( flLevelCalculate ) + CalculateBonusEXP( data );
		
		// Set the calculated EXP.
		data.iExp += iCalculateEXP;
		if ( data.iWeekly_Exp_Max > 0 )
			data.iWeekly_Exp += iCalculateEXP;
	}
	
	private void DoPrestige( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		if ( data.iPrestige >= MAX_PRESTIGE )
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] You have hit the limit, you can no longer prestige!\n");
			return;
		}
		
		if ( data.iLevel < MAX_LEVEL )
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] You must be level " + MAX_LEVEL + " to prestige!\n");
			return;
		}
		
		// Reset level
		data.iLevel = 0;
		
		// Increase our prestige
		data.iPrestige++;
		
		if ( data.iPrestige >= 2 )
			GiveToPlayer::GiveItem( pPlayer, "item_longjump" );
		
		// Reset skills
		ResetSkills( pPlayer );
		
		// Give 8k souls
		data.iSouls += 8000;
		
		// Calculate our EXP again
		RequiredEXP( data );
		
		// Play sound
		ClientSidedSound( pPlayer, SND_PRESTIGE );
		
		// Announce to everyone
		string szNick = pPlayer.pev.netname;
		string szVal = "st";
		if ( data.iPrestige > 1 )
			szVal = data.iPrestige > 2 ? "th" : "nd";
		g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] " + szNick + " have prestiged for the " + data.iPrestige + szVal + " time!!\n");
	}
	
	private void SetAuraGlow( bool state, CBasePlayer@ pPlayer, int red, int green, int blue )
	{
		if ( pPlayer is null ) return;
		pPlayer.pev.rendermode = kRenderNormal;
		pPlayer.pev.renderfx = state ? kRenderFxGlowShell : kRenderFxNone;
		pPlayer.pev.renderamt = state ? 4 : 255;
		pPlayer.pev.rendercolor = Vector( red, green, blue );
	}
	
	private void SetGodMode( CBasePlayer@ pPlayer, bool state )
	{
		if ( pPlayer is null ) return;
		if ( state )
		{
			if ( pPlayer.pev.flags & FL_GODMODE == 0 )
				pPlayer.pev.flags |= FL_GODMODE;
		}
		else
		{
			if ( pPlayer.pev.flags & FL_GODMODE > 0 )
				pPlayer.pev.flags &= ~FL_GODMODE;
		}
	}
	
	private bool IsGodMode( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return false;
		if ( pPlayer.pev.flags & FL_GODMODE > 0 ) return true;
		return false;
	}
	
	bool IsDonator( PlayerData@ data )
	{
		if ( data is null ) return false;
		return data.bIsDonator;
	}
	
	bool IsDonator( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return false;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return false;
			return IsDonator( data );
		}
		return false;
	}
	
	void AddToCommunity( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			if ( data.bIsCommunity )
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "You are already an community member!\n");
				return;
			}
			data.bIsCommunity = true;
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "Welcome to the Afterlife Community!\nCommunity models has been unlocked!\n");
			g_Achivements.GiveAchievement( pPlayer, "community", true );
		}
	}
	
	bool IsAdministrators( CBasePlayer@ pPlayer, string SteamID )
	{
		// JonnyBoy0719 -- Creator of SCRPG
		if ( SteamID == "STEAM_0:1:24323838" )
			return true;
		// Dark4557
		if ( SteamID == "STEAM_0:1:8122893" )
			return true;
		AdminLevel_t adminLevel = g_PlayerFuncs.AdminLevel( pPlayer );
		if ( adminLevel >= ADMIN_YES )
			return true;
		return false;
	}
	
	private void GiveDonorWeapons( CBasePlayer@ pPlayer, string SteamID )
	{
		// Check donator
		if ( !IsDonator( pPlayer ) )
		{
			// Not donator, then check if we are an admin
			if ( !IsAdministrators( pPlayer, SteamID ) )
				return;
		}
		GiveToPlayer::GiveDonatorWeapons( pPlayer );
	}
	
	private void GiveSpecialWeapons( CBasePlayer@ pPlayer, string SteamID )
	{
		// Stormgiant (also known as ban hammer)
		if ( IsAdministrators( pPlayer, SteamID ) )
			GiveToPlayer::GiveWeapon( pPlayer, "weapon_stormgiant" );
		
		// Give donor weapons
		GiveDonorWeapons( pPlayer, SteamID );
		
		// Prestige stuff
		if ( g_PlayerCoreData.exists( SteamID ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[SteamID]);
			GiveToPlayer::GivePrestiges( pPlayer, data );
		};
	}
	
	private void DisplaySkills( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data.iPoints < 5 )
				g_SkillMenu.Show( pPlayer, data.iPoints );
			else
				g_SkillMenuEx.Show( pPlayer, data.iPoints );
		}
	}
	
	private void DisplayShop( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		// TODO
	}
	
	private void DisplayModels( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		g_PlayerModelsMenu.Show( pPlayer );
	}
	
	private void ClearThinker()
	{
		if ( hThinker is null ) return;
		g_Scheduler.RemoveTimer( hThinker );
		@hThinker = @null;
	}
	
	private bool CheckConfigDefine( string szFullLine, string szLine, string szCompare )
	{
		// Just makin sure linux wont fuck
		szFullLine = szLine.SubString( szLine.Length() - 1, 1 );
		if ( szFullLine == " " || szFullLine == "\n" || szFullLine == "\r" || szFullLine == "\t" )
			szLine = szLine.SubString( 0, szLine.Length() - 1 );
		// Normal string compare
		if ( szLine == szCompare )
			return true;
		return false;
	}
	
	private void CheckCurrentDate()
	{
		DateTime date;
		/*
		g_Game.AlertMessage(at_logged, "[SCRPG] Current Day " + date.GetDayOfMonth() + "\n");
		string szCurrentDate = "" + date.GetYear() + "-" + date.GetMonth() + "-" + date.GetDayOfMonth();
		g_Game.AlertMessage(at_logged, "[SCRPG] Date: " + szCurrentDate + "\n");
		*/
		bool bNewWeek = false;
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_weekly.txt", OpenFile::READ );
		if ( player_data !is null && player_data.IsOpen() )
		{
			while( !player_data.EOFReached() )
			{
				string sLine;
				player_data.ReadLine( sLine );
				// Fix for linux
				string sFix = sLine.SubString( sLine.Length() - 1, 1 );
				if ( sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t" )
					sLine = sLine.SubString( 0, sLine.Length() - 1 );
				
				if ( sLine.SubString( 0, 1 ) == "#" || sLine.IsEmpty() )
					continue;
				
				array<string> parsed = sLine.Split(" ");
				if ( parsed.length() < 1 )
					continue;
				
				if ( CheckConfigDefine( sFix, parsed[0], "month" ) )
				{
					int SavedMonth = atoi( parsed[1] );
					int SavedDay = atoi( parsed[2] );
					if ( date.GetMonth() != SavedMonth )
						bNewWeek = true;
					if ( date.GetDayOfMonth() > SavedDay + 7 )
						bNewWeek = true;
				}
				
				if ( CheckConfigDefine( sFix, parsed[0], "bonusexp" ) )
					g_iWeeklyBonusEXP = atoi( parsed[1] );
			}
			player_data.Close();
		}
		else
			bNewWeek = true;
		
		if ( !bNewWeek ) return;
		
		g_iWeeklyBonusEXP = Math.RandomLong( 5500, 10650 );
		
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_weekly.txt", OpenFile::WRITE );
		if ( player_data !is null && player_data.IsOpen() )
		{
			string output = "month " + date.GetMonth() + " " + date.GetDayOfMonth() + "\n";
			output += "bonusexp " + g_iWeeklyBonusEXP + "\n";
			player_data.Write( output );
			player_data.Close();
		}
	}
	
	string GetCurrentMap()
	{
		return string( g_Engine.mapname );
	}
	
	bool IsCurrentMap( string szMapName )
	{
		if ( szMapName.ToLowercase() == string(g_Engine.mapname).ToLowercase() )
			return true;
		return false;
	}
	
	void CheckMapDefines()
	{
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_mapdefines.txt", OpenFile::READ );
		if ( player_data !is null && player_data.IsOpen() )
		{
			bool bFounddefines = false;
			g_Game.AlertMessage(at_logged, "[SCRPG] Loading map defines for: " + GetCurrentMap() + "\n");
			while( !player_data.EOFReached() )
			{
				string sLine;
				player_data.ReadLine( sLine );
				// Fix for linux
				string sFix = sLine.SubString( sLine.Length() - 1, 1 );
				if ( sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t" )
					sLine = sLine.SubString( 0, sLine.Length() - 1 );
				
				if ( sLine.SubString( 0, 1 ) == "#" || sLine.IsEmpty() )
					continue;
				
				array<string> parsed = sLine.Split(" ");
				if ( parsed.length() < 1 )
					continue;
				
				if ( CheckConfigDefine( sFix, parsed[0], GetCurrentMap() ) )
				{
					bFounddefines = true;
					for ( uint i = 1; i < parsed.length(); i++ )
					{
						if ( CheckConfigDefine( sFix, parsed[ i ], "melee_only" ) )
						{
							g_Game.AlertMessage(at_logged, "\t>> melee_only has been applied!\n");
							g_MapDefined_MeleeOnly = true;
						}
					}
				}
			}
			if ( !bFounddefines )
				g_Game.AlertMessage(at_logged, "\t>> No defines found, skipping...\n");
			player_data.Close();
		}
		else
			g_Game.AlertMessage(at_logged, "[SCRPG] Failed to load scrpg_mapdefines.txt!\n");
		
		// After we checked map defines, check our date!
		CheckCurrentDate();
	}
	
	void CreateThinker()
	{
		@hThinker = @g_Scheduler.SetInterval( @this, "OnThink", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
	}
	
	void AdminGiveWeapon( CBasePlayer@ pPlayer, string szWeapon )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( IsAdministrators( pPlayer, szSteamId ) )
			pPlayer.GiveNamedItem( szWeapon );
	}
	
	// Player model stuff!
	void GiveModelPlayer( CBasePlayer@ pCaller, CBasePlayer@ pPlayer, string szModel )
	{
		if ( pCaller is null ) return;
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pCaller.edict() );
		if ( !IsAdministrators( pCaller, szSteamId ) ) return;
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		int iRet = data.AddPlayerModel( szModel );
		string strRet;
		switch( iRet )
		{
			case -1: strRet = "The model " + szModel + " does not exist.\n"; break;
			case 0: strRet = "The player already owns the model " + szModel + ".\n"; break;
			case 1: strRet = szModel + " has been added to the player.\n"; break;
		}
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, strRet);
	}
	
	void RemoveModelFromPlayer( CBasePlayer@ pCaller, CBasePlayer@ pPlayer, string szModel )
	{
		if ( pCaller is null ) return;
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pCaller.edict() );
		if ( !IsAdministrators( pCaller, szSteamId ) ) return;
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		if ( data.RemovePlayerModel( szModel ) )
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szModel + " has been removed from the player.\n");
		else
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "The player does not own the model " + szModel + ".\n");
	}
	
	void SetModelOnPlayer( CBasePlayer@ pCaller, CBasePlayer@ pPlayer, string szModel, bool special )
	{
		if ( pCaller is null ) return;
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pCaller.edict() );
		if ( !IsAdministrators( pCaller, szSteamId ) ) return;
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		if ( special )
			data.szModelSpecial = szModel;
		else
			data.szModel = szModel;
	}
	
	void UnsetModelFromPlayer( CBasePlayer@ pCaller, CBasePlayer@ pPlayer, bool special )
	{
		if ( pCaller is null ) return;
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pCaller.edict() );
		if ( !IsAdministrators( pCaller, szSteamId ) ) return;
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		if ( special )
			data.szModelSpecial = "null";
		else
			data.szModel = "null";
	}
	
	void Reset()
	{
		g_PlayerCoreData.deleteAll();
		g_MapDefined_MeleeOnly = false;
		g_AuraIsActive = false;
		@player_data = null;
		ClearThinker();
	}
	
	void DoPlayerJump( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.bOldButtonJump ) return;
		if ( data.iDoubleJump >= data.iStat_doublejump ) return;
		
		// If we are on the highest cap (or more)
		// Set our vel to 320 <~> 335
		if ( data.iStat_doublejump >= AB_DOUBLEJUMP_MAX )
			pPlayer.pev.velocity[2] = Math.RandomFloat( 320.0, 335.0 );
		else
			pPlayer.pev.velocity[2] = Math.RandomFloat( 265.0, 285.0 );
		
		data.bOldButtonJump = true;
		data.iDoubleJump++;
		ClientSidedSound( pPlayer, SND_JUMP );
	}
	
	void ShowAchievements( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		
		// Show our challanges / achievements
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Challenges:\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "===================================================================\n");
		
		// Display them
		int iCompleted = g_Achivements.PrintList( pPlayer, data );
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\nYou have completed " + iCompleted + " out of " + g_Achivements.GetAmount() + " challenges.\n");
		
		// Print to chat
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "The challenges has been printed on the console!\n");
	}
	
	void ShowCommands( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		// Print to console
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "===================================================================\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "RPG Mod Commands\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "===================================================================\n\n");
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".medic\n  Activates 'Holy Armor'\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".grenade\n  Activates 'Warrior's Battlecry'\n");
		
		if ( IsAdministrators( pPlayer, szSteamId ) )
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n===================================================================\n\n");
			
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".give_weapon <classname>\n  Give yourself a weapon\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".give_model <player> <model>\n  Give a player a model\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".remove_model <player> <model>\n  Removes the model from the player\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".set_model <player> <model> <special 0|1>\n  Sets the model of choice\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".unset_model <player> <special 0|1>\n  Unsets the model of choice\n");
		}
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n===================================================================\n");
		
		// Print to chat
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "The commands has been printed on the console!\n");
	}
	
	void TryPrestige( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		DoPrestige( pPlayer, data );
	}
	
	void LoadClientData( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		// Load from our File (Only loads if SQL is not enabled)
		LoadFromFile( pPlayer, szSteamId );
		
		// We exist!
		if ( !g_PlayerCoreData.exists(szSteamId) )
		{
			PlayerData data;
			data.szSteamID = szSteamId;
			g_PlayerCoreData[szSteamId] = data;
		}
		
		// Now load the data
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			RequiredEXP( data );
			SetMaxArmorHealth( pPlayer, data );
			SetArmorHealth( pPlayer, data );
			CalculatePoints( data );
			// Reset our specific values
			data.ResetOnJoin();
		}
	}
	
	void ResetSkills( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		
		// Reset everything
		data.iStat_health = data.iStat_health_regen = data.iStat_armor =
		data.iStat_armor_regen = data.iStat_gotg_ammo = data.iStat_gotg_weapon =
		data.iStat_doublejump = data.iStat_battlecry =data.iStat_holyarmor = 0;
		SetMaxArmorHealth( pPlayer, data );
		
		// Recalculate our points
		CalculatePoints( data );
	}
	
	void PlayerSpawned( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		SetPlayerModel( pPlayer );
		PlayPlayerSound( pPlayer, sound_spawn );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			data.iWaitTimer_Hurt = 0;
			SetArmorHealth( pPlayer, data );
		}
		
		GiveSpecialWeapons( pPlayer, szSteamId );
	}
	
	void SaveClientData( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			SaveData( data );
		}
	}
	
	void PlayerIsHurt( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			// We are in godmode
			if ( IsGodMode( pPlayer ) ) return;
			data.bIsHurt = true;
			data.iWaitTimer_Hurt = 8;
			if ( data.iWaitTimer_Hurt_Snd == 0 )
			{
				PlayPlayerSound( pPlayer, sound_pain );
				data.iWaitTimer_Hurt_Snd = 1;
			}
		}
	}
	
	void DoSecret( CBasePlayer@ pPlayer, string szSecret )
	{
		if ( pPlayer is null ) return;
		if ( szSecret == "secret_postal" )
		{
			string szSound;
			switch( Math.RandomLong( 0, 3 ) )
			{
				case 0: szSound = "afterlife/player/postal/grenade1.wav"; break;
				case 1: szSound = "afterlife/player/postal/grenade5.wav"; break;
				case 2: szSound = "afterlife/player/postal/medic2.wav"; break;
				case 3: szSound = "afterlife/player/postal/medic12.wav"; break;
			}
			g_SCRPGCore.ClientSidedSound( pPlayer, szSound );
		}
		g_Achivements.GiveAchievement( pPlayer, szSecret, true );
	}
	
	void DoSoundEffect( CBasePlayer@ pPlayer, bool bIsMedicShout )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data.iWaitTimer_SndEffect == 0 )
			{
				SendClientCommand( pPlayer, bIsMedicShout ? "medic\n" : "grenade\n" );
				data.flWaitTimer_SndEffect_Delay = 0.07;	// Delay it
				data.bSndEffect = true;
				data.bSndEffectMedic = bIsMedicShout;
				data.iWaitTimer_SndEffect = 3;
			}
			
			// Holy armor
			if ( bIsMedicShout && data.iStat_holyarmor > 0 )
			{
				if ( data.iWaitTimer_HolyArmor == data.iWaitTimer_HolyArmor_Max )
				{
					data.iWaitTimer_HolyArmor = 0;
					data.iWaitTimer_HolyArmor_Max = 300 - data.iStat_holyarmor;
					data.iWaitTimer_HolyArmor_Reset = 8 + data.iStat_holyarmor;
					SetGodMode( pPlayer, true );
					SetAuraGlow( true, pPlayer, 140, 255, 219 );
					ClientSidedSound( pPlayer, SND_HOLYGUARD );
					string szNick = pPlayer.pev.netname;
					g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] " + szNick + " has activated their Holy Armor!\n");
					
					g_Achivements.GiveAchievement( pPlayer, "godsdoing", true );
				}
			}
			// Battlecry
			else if ( data.iStat_battlecry > 0 )
			{
				if ( data.iWaitTimer_BattleCry == data.iWaitTimer_BattleCry_Max )
				{
					data.iWaitTimer_BattleCry = 0;
					data.iWaitTimer_BattleCry_Max = 200 - data.iStat_battlecry;
					data.iWaitTimer_BattleCry_Reset = 10 + data.iStat_battlecry;
					SetAuraGlow( true, pPlayer, 255, 15, 15 );
					string szSound;
					switch( Math.RandomLong( 0, 2 ) )
					{
						case 0: szSound = SND_AURA01; break;
						case 1: szSound = SND_AURA02; break;
						case 2: szSound = SND_AURA03; break;
					}
					g_AuraIsActive = true;
					ClientSidedSound( pPlayer, szSound );
					string szNick = pPlayer.pev.netname;
					g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] " + szNick + " has activated their The Warrior's Battlecry!\n");
					
					g_Achivements.GiveAchievement( pPlayer, "warriorinside", true );
				}
			}
		}
	}
	
	void SendClientCommand( CBasePlayer@ pPlayer, string szCommand )
	{
		if ( pPlayer is null ) return;
		NetworkMessage m( MSG_ONE, NetworkMessages::NetworkMessageType(9), pPlayer.edict() );
			m.WriteString( szCommand );
		m.End();
	}
	
	void ClientSidedSound( CBasePlayer@ pPlayer, string szSound )
	{
		if ( pPlayer is null ) return;
		SendClientCommand( pPlayer, "spk \"" + szSound + "\"\n" );
	}
	
	void ShowMenu( CBasePlayer@ pPlayer, MenuEnum eMenu )
	{
		switch( eMenu )
		{
			case MENU_SKILLS: DisplaySkills( pPlayer ); break;
			case MENU_SHOP: DisplayShop( pPlayer ); break;
			case MENU_MODELS: DisplayModels( pPlayer ); break;
		}
	}
}
CSCRPGCore@ g_SCRPGCore;

#include "lib/populate_skills"
#include "lib/populate_weapondrop"

void LoadRPGCore()
{
	if ( g_SCRPGCore !is null )
	{
		g_SCRPGCore.Reset();
		@g_SCRPGCore = null;
	}

	CSCRPGCore core();
	@g_SCRPGCore = @core;
	
	// Add stuff into our menu!
	Populate::PopulateSkills();
	
	// Add stuff into our weapon drop
	Populate::PopulateWeaponDrop();
	
	// Load our achievements
	Populate::PopulateAchievements();
}
