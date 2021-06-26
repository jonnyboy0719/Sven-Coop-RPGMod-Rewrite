final class CAchievement
{
	private string m_szID;
	private string m_szName;
	private string m_szDescription;
	private int m_iCurVal;
	private int m_iMaxVal;
	private int m_iSouls;
	private int m_iExp;
	private int m_iMedals;
	private bool m_bIsSecret;
	private bool m_bCanObtain;
	
	string GetID() { return m_szID; }
	string GetName() { return m_szName; }
	string GetDescription() { return m_szDescription; }
	
	bool IsSecret() { return m_bIsSecret; }
	
	int GetCurrent() { return m_iCurVal; }
	int GetMax() { return m_iMaxVal; }
	int GetMoney() { return m_iSouls; }
	int GetEXP() { return m_iExp; }
	int GetMedals() { return m_iMedals; }
	
	CAchievement( const string& in szID, const string& in szName, const string& in szDescription, int iMedals, int iExperience, int iMoney, int iMax = 1, bool bSecret = false )
	{
		m_iCurVal = 0;
		m_szID = szID;
		m_szName = szName;
		m_szDescription = szDescription;
		m_iMedals = iMedals;
		m_iExp = iExperience;
		m_iSouls = iMoney;
		m_iMaxVal = iMax;
		m_bIsSecret = bSecret;
		m_bCanObtain = true;
	}
	
	void SetCurrent( int value )
	{
		m_iCurVal = value;
		if ( m_iCurVal >= m_iMaxVal )
			m_bCanObtain = false;
	}
	
	bool CanGiveAch()
	{
		// Ugly
		if ( m_iCurVal >= m_iMaxVal ) return true;
		m_iCurVal++;
		if ( m_iCurVal >= m_iMaxVal ) return true;
		return false;
	}
	
	void ObtainAchievement( CBasePlayer@ pPlayer, PlayerData@ data, bool bAnnounce, int iCurrent )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		// Does the player already have it?
		if ( !data.AddAchievement( this, GetID(), iCurrent ) ) return;
		if ( !m_bCanObtain ) return;
		
		// Set to false
		m_bCanObtain = false;
		
		if ( bAnnounce )
		{
			string szNick = pPlayer.pev.netname;
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, szNick + " has unlocked the challenge \"" + GetName() + "\"!\n");
			data.iSouls += GetMoney();
			data.iExp += GetEXP();
		}
		
		data.iMedals += GetMedals();
	}
}

final class CAchievementManager
{
	private array<CAchievement@> m_Items;
	private int iMaxMedals = 0;
	
	int GetMaxMedals() { return iMaxMedals; }
	
	bool ShouldAddItems()
	{
		if ( m_Items.length() <= 0 ) return true;
		return false;
	}
	
	void AddItem( CAchievement@ pItem )
	{
		if ( pItem is null )
			return;
		
		if ( m_Items.findByRef( @pItem ) != -1 )
			return;
		
		iMaxMedals += pItem.GetMedals();
		
		m_Items.insertLast( pItem );
	}
	
	uint GetAmount() { return m_Items.length(); }
	
	int PrintList( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return 0;
		if ( data is null ) return 0;
		
		int xy = 0;
		for ( uint i = 0; i < m_Items.length(); i++ )
		{
			CAchievement@ pAchievement = m_Items[ i ];
			if ( pAchievement is null ) continue;
			string szProgress = "" + data.GetCurrentAchievementProgress( pAchievement.GetID() ) + "/" + pAchievement.GetMax();
			if ( data.GetCurrentAchievementProgress( pAchievement.GetID() ) >= pAchievement.GetMax() )
			{
				szProgress = "Completed";
				xy++;
			}
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, pAchievement.GetName() + " [" + szProgress + "]\n   " + pAchievement.GetDescription() + "\n" );
		}
		return xy;
	}
	
	void GiveAchievement( CBasePlayer@ pPlayer, string szID, bool bAnnounce, int iCurrent = 0 )
	{
		if ( pPlayer is null ) return;
		
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( !g_PlayerCoreData.exists( szSteamId ) ) return;
		
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		
		for ( uint i = 0; i < m_Items.length(); i++ )
		{
			CAchievement@ pAchievement = m_Items[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID )
			{
				pAchievement.ObtainAchievement( pPlayer, data, bAnnounce, iCurrent );
				return;
			}
		}
	}
}
CAchievementManager g_Achivements;

namespace Populate
{
	void PopulateAchievements()
	{
		if ( !g_Achivements.ShouldAddItems() ) return;
		
		// szID, szName, iMedals, iExperience, iMoney, bSecret
		g_Achivements.AddItem( CAchievement( "prestige_1", "Prestige Time!", "Prestige for the first time", 1, 500, 25 ) );
		g_Achivements.AddItem( CAchievement( "prestige_5", "Look at me go!", "Prestige 5 times", 2, 9500, 150 ) );
		g_Achivements.AddItem( CAchievement( "prestige_lj", "LongJump Module", "Gotta get that long jump module!", 2, 800, 80 ) );
		g_Achivements.AddItem( CAchievement( "teamplayer", "Team Player", "Boost the whole team's HP & AP", 3, 2500, 200 ) );
		g_Achivements.AddItem( CAchievement( "godsdoing", "I HAVE THE POWER!!", "Become god", 1, 3600, 350, 10 ) );
		g_Achivements.AddItem( CAchievement( "secret1", "Praise The Alien Overlord!", "What even is this", 15, 9800, 5000, 1, true ) );
		g_Achivements.AddItem( CAchievement( "secret2", "I'm dying over here!", "If it bleeds, you can heal it", 3, 1250, 250, 1, true ) );
		g_Achivements.AddItem( CAchievement( "secret_postal", "Going POSTAL", "Just sign my petition god dammit", 20, 52500, 2025, 1, true ) );
		g_Achivements.AddItem( CAchievement( "extreme_uboa", "UBOA!?!", "( ﾟДﾟ) TOO EXTREME!! (´･ω･)", 2, 8000, 500 ) );
		g_Achivements.AddItem( CAchievement( "endyourlife", "Depressed", "Just end it all..", 5, 1, 10 ) );
		g_Achivements.AddItem( CAchievement( "warriorinside", "I'm one with the warrior inside", "Use warrior's battlecry!", 3, 15250, 1525, 10 ) );
		g_Achivements.AddItem( CAchievement( "ethereal", "Weaponized death!", "Empowered by crystalized essence of the dead!", 5, 5900, 5900 ) );
		g_Achivements.AddItem( CAchievement( "plasmarifle", "Crystal Meth", "These liquidized Afterlife crystal are really potent!", 15, 1885900, 5825 ) );
		g_Achivements.AddItem( CAchievement( "scinade", "I seem to be wounded!", "But I can keep going!", 5, 10500, 2625 ) );
		g_Achivements.AddItem( CAchievement( "martialarts", "Martial Arts", "最後の侍。", 10, 85900, 565 ) );
		g_Achivements.AddItem( CAchievement( "fotn", "WATAA", "Serious fisting", 5, 285900, 25 ) );
		g_Achivements.AddItem( CAchievement( "runeblade", "By the power of grayskull..", "-I have the poooower!", 15, 1885900, 1885900 ) );
	//	g_Achivements.AddItem( CAchievement( "xxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxx", 5, 8500, 25 ) );
	}
}