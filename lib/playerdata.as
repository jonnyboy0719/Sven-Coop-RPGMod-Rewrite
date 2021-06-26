// PlayerData
dictionary g_PlayerCoreData;
class PlayerData
{
	array<CAchievement@> hAchievements;	// Our achievements
	array<CPlayerModelBase@> hAvailableModels;	// Our models
	
	// Our saved SteamID
	string szSteamID;
	
	// Player stats
	int iLevel = 0;						// Our levelz
	int iPoints = 0;					// Our points
	int iPrestige = 0;					// Our prestige
	int iSouls = 0;						// Money
	int iStat_health = 0;				// Vitality
	int iStat_health_regen = 0;			// Health Regeneration
	int iStat_armor = 0;				// Superior Armor
	int iStat_armor_regen = 0;			// Nano Armor
	int iStat_gotg_ammo = 0;			// The Magic Pocket
	int iStat_gotg_weapon = 0;			// A Gift From The Gods
	int iStat_doublejump = 0;			// Icarus Potion
	int iStat_battlecry = 0;			// The Warrior's Battlecry
	int iStat_holyarmor = 0;			// Holy Armor
	
	int iDoubleJump = 0;				// Our double jump value
	
	float flScore = 0.0;				// Our current score
	
	int iExp = 0;						// Our EXP
	int iExpMax = 0;					// Our max EXP
	
	int iMedals = 0;
	
	string szModel = "null";			// Our model
	string szModelSpecial = "null";		// Special model (only the player can pick this)
	
	// Weekly stuff
	int iWeekly_Exp = 0;				// Special Weekly EXP bonus
	int iWeekly_Exp_Max = 0;			// Max CAP for Special Weekly EXP bonus
	
	// Wait 120 seconds to obtain free EXP
	int iWaitTimer_FreeEXP = 120;
	int iWaitTimer_Hurt = 0;
	int iWaitTimer_Hurt_Snd = 0;		// We don't want to spam this
	int iWaitTimer_SndEffect = 0;		// We don't want to spam this
	int iWaitTimer_UseModel = 3;
	int iWaitTimer_AmmoDrop = 1;		// At the start let's give some ammo
	int iWaitTimer_WeaponDrop = 1;		// Ditto, same for weapon
	int iWaitTimer_HolyArmor = 0;
	int iWaitTimer_HolyArmor_Max = 10;
	int iWaitTimer_HolyArmor_Reset = -1;
	int iWaitTimer_BattleCry = 0;
	int iWaitTimer_BattleCry_Max = 10;
	int iWaitTimer_BattleCry_Reset = -1;
	
	float flWaitTimer_SndEffect_Delay = 0;
	
	// Misc
	bool bIsHurt = false;
	bool bSndEffect = false;
	bool bSndEffectMedic = false;
	bool bReopenSkills = false;
	bool bHasJumped = false;
	bool bOldButtonJump = false;
	
	// Community stuff
	bool bIsCommunity = false;
	bool bIsDonator = false;
	
	void ResetOnJoin()
	{
		bIsHurt = false;
		bSndEffect = false;
		bSndEffectMedic = false;
		bReopenSkills = false;
		bHasJumped = false;
		bOldButtonJump = false;
		bIsCommunity = false;
		bIsDonator = false;
		
		flWaitTimer_SndEffect_Delay = 0;
		
		iWaitTimer_FreeEXP = 120;
		iWaitTimer_Hurt = 0;
		iWaitTimer_Hurt_Snd = 0;
		iWaitTimer_SndEffect = 0;
		iWaitTimer_UseModel = 3;
		iWaitTimer_AmmoDrop = 1;
		iWaitTimer_WeaponDrop = 1;
		iWaitTimer_HolyArmor = 0;
		iWaitTimer_HolyArmor_Max = 10;
		iWaitTimer_HolyArmor_Reset = -1;
		iWaitTimer_BattleCry = 0;
		iWaitTimer_BattleCry_Max = 10;
		iWaitTimer_BattleCry_Reset = -1;
		
		iWeekly_Exp = 0;
		iWeekly_Exp_Max = 0;
	}
	
	bool FindAchievement( string szID )
	{
		for ( uint i = 0; i < hAchievements.length(); i++ )
		{
			CAchievement@ pAchievement = hAchievements[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID ) return true;
		}
		return false;
	}
	
	int GetCurrentAchievementProgress( string szID )
	{
		for ( uint i = 0; i < hAchievements.length(); i++ )
		{
			CAchievement@ pAchievement = hAchievements[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID ) return pAchievement.GetCurrent();
		}
		return 0;
	}
	
	bool CanGiveAchievement( string szID )
	{
		for ( uint i = 0; i < hAchievements.length(); i++ )
		{
			CAchievement@ pAchievement = hAchievements[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID )
				return pAchievement.CanGiveAch();
		}
		return false;
	}
	
	bool AddAchievement( CAchievement@ pAchievement, string szID, int iCurrent )
	{
		if ( pAchievement is null ) return false;
		if ( !FindAchievement( szID ) )
		{
			CAchievement @pAch = CAchievement( pAchievement.GetID(), pAchievement.GetName(), pAchievement.GetDescription(), pAchievement.GetMedals(), pAchievement.GetEXP(), pAchievement.GetMoney(), pAchievement.GetMax(), pAchievement.IsSecret() );
			if ( iCurrent > 0 )
				pAch.SetCurrent( iCurrent );
			hAchievements.insertLast( @pAch );
		}
		return CanGiveAchievement( szID );
	}
	
	private int CanAddPlayerModel( CPlayerModelBase@ pModel )
	{
		if ( pModel is null ) return -1;
		if ( hAvailableModels.findByRef( @pModel ) != -1 ) return 0;
		hAvailableModels.insertLast( @pModel );
		return 1;
	}
	
	int AddPlayerModel( string szModel )
	{
		for ( uint i = 0; i < g_LoadedPlayerModels.length(); i++ )
		{
			CPlayerModelBase@ model = @g_LoadedPlayerModels[ i ];
			if ( model is null ) continue;
			if ( model.GetModel() == szModel ) return CanAddPlayerModel( model );
		}
		return -1;
	}
	
	bool RemovePlayerModel( string szModel )
	{
		for ( uint i = 0; i < hAvailableModels.length(); i++ )
		{
			CPlayerModelBase@ model = @hAvailableModels[ i ];
			if ( model is null ) continue;
			if ( model.GetModel() == szModel )
			{
				hAvailableModels.removeAt( i );
				return true;
			}
		}
		return false;
	}
}