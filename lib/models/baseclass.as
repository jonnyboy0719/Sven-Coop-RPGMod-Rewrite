enum ModelSoundState
{
	sound_pain = 0,
	sound_death,
	sound_spawn,
	sound_medic,
	sound_grenade
};

enum ModelAllowState
{
	state_private = -1,
	state_public,
	state_community,
	state_donator
};

// If included into the class, it goes crazy
void PrecacheCoreSound( string &in szSound )
{
	g_Game.PrecacheGeneric( "sound/" + szSound );
	g_SoundSystem.PrecacheSound( szSound );
}

void PrecachePlayerModel( string input )
{
	string modelpath = "models/player/" + input + "/" + input + ".mdl";
	g_Game.PrecacheModel( modelpath );
}

// Our base class
class CPlayerModelBase
{
	private string m_strModel;
	private string m_strName;
	private ModelAllowState m_iAllowedState;
	private array<string> m_Sounds_Pain;
	private array<string> m_Sounds_Death;
	private array<string> m_Sounds_Spawn;
	private array<string> m_Sounds_Medic;
	private array<string> m_Sounds_Grenade;
	
	void Init()
	{
		m_strName = "Custom Model";
		m_strModel = "";
		m_iAllowedState = state_private;	// state_private, private models, needs to be assigned, earned and/or given to
	}
	
	void SetPlayerModel( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szModel = "models/player/" + m_strModel + "/" + m_strModel + ".mdl";
		g_EntityFuncs.SetModel( pPlayer, szModel );
		g_SCRPGCore.SendClientCommand( pPlayer, "model " + m_strModel + "\n" );
		CustomSpawn( pPlayer );
	}
	
	void CustomSpawn( CBasePlayer@ pPlayer ) {}
	void OnPlayerDied( CBasePlayer@ pPlayer ) {}
	
	void SetModel( string input )
	{
		m_strModel = input;
		PrecachePlayerModel( input );
	}
	
	void SetName( string input ) { m_strName = input; }
	void SetAllowedState( ModelAllowState input ) { m_iAllowedState = input; }
	
	string GetModel() { return m_strModel; }
	string GetName() { return m_strName; }
	ModelAllowState GetAllowedState() { return m_iAllowedState; }
	
	void AddPainSound( string &in szSound ) { PrecacheCoreSound( szSound ); m_Sounds_Pain.insertLast( szSound ); }
	void AddDeathSound( string &in szSound ) { PrecacheCoreSound( szSound ); m_Sounds_Death.insertLast( szSound ); }
	void AddSpawnSound( string &in szSound ) { PrecacheCoreSound( szSound ); m_Sounds_Spawn.insertLast( szSound ); }
	void AddMedicSound( string &in szSound ) { PrecacheCoreSound( szSound ); m_Sounds_Medic.insertLast( szSound ); }
	void AddGrenadeSound( string &in szSound ) { PrecacheCoreSound( szSound ); m_Sounds_Grenade.insertLast( szSound ); }
	
	bool PlaySound( CBasePlayer@ pPlayer, ModelSoundState iSoundType, bool bOverrideSnd )
	{
		// Player is invalid?
		if ( pPlayer is null ) return false;
		if ( !pPlayer.IsConnected() ) return false;
		
		// Pick our array
		array<string> mTemp;
		switch( iSoundType )
		{
			case sound_pain: mTemp = m_Sounds_Pain; break;
			case sound_death: mTemp = m_Sounds_Death; break;
			case sound_spawn: mTemp = m_Sounds_Spawn; break;
			case sound_medic: mTemp = m_Sounds_Medic; break;
			case sound_grenade: mTemp = m_Sounds_Grenade; break;
		}
		
		// Not enough?
		if ( mTemp.length() <= 0 ) return false;
		
		// Pick the best one
		uint target = Math.RandomLong( 0, mTemp.length() - 1 );
		string Output = mTemp[target];
		g_SoundSystem.PlaySound( pPlayer.edict(), bOverrideSnd ? CHAN_VOICE : CHAN_AUTO, Output, 1.0f, ATTN_NORM, 0, 100 );
		
		return true;
	}
}

array<CPlayerModelBase@> g_LoadedPlayerModels;
void AddToList( CPlayerModelBase@ model )
{
	g_LoadedPlayerModels.insertLast( model );
}
