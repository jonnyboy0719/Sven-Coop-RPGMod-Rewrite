// Include our actual files
#include "populate_models"

void LoadPlayerModels()
{
	g_LoadedPlayerModels.removeRange( 0, g_LoadedPlayerModels.length() );
	
	// Create them
	Populate::PopulatePlayerModels();
	
	// Init them
	for ( uint i = 0; i < g_LoadedPlayerModels.length(); i++ )
	{
		CPlayerModelBase@ model = @g_LoadedPlayerModels[ i ];
		if ( model is null ) continue;
			model.Init();
	}
}

CPlayerModelBase@ GrabPlayerModel( string szModel )
{
	// Don't check if it's set to null already
	if ( szModel == "null" ) return null;
	for ( uint i = 0; i < g_LoadedPlayerModels.length(); i++ )
	{
		CPlayerModelBase@ model = @g_LoadedPlayerModels[ i ];
		if ( model is null ) continue;
		if ( model.GetModel() == szModel ) return model;
	}
	return null;
}

void SetPlayerModel( CBasePlayer@ pPlayer )
{
	if ( pPlayer is null ) return;
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		CPlayerModelBase@ model = @GrabPlayerModel( data.szModel );
		if ( model is null ) return;
		model.SetPlayerModel( pPlayer );
	}
}

// Player died
void PlayerHasDied( CBasePlayer@ pPlayer )
{
	if ( pPlayer is null ) return;
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		data.AddPlayerModel( "afterlife_kork" );	// Congratz, you earned cpt. kork
	}
}

void PlayPlayerSound( CBasePlayer@ pPlayer, ModelSoundState iSoundType, bool bOverrideSnd = false )
{
	if ( pPlayer is null ) return;
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		CPlayerModelBase@ model = @GrabPlayerModel( data.szModel );
		if ( model is null ) return;
		model.PlaySound( pPlayer, iSoundType, bOverrideSnd );
	}
}
