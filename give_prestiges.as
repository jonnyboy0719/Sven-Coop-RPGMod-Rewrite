namespace GiveToPlayer
{
	void GiveItem( CBasePlayer@ pPlayer, string szItem )
	{
		if ( pPlayer is null ) return;
		CBaseEntity@ pEntity = g_EntityFuncs.Create( szItem, pPlayer.pev.origin, Vector(0, pPlayer.pev.angles.y, 0), true );
		if ( pEntity is null ) return;
		pEntity.pev.spawnflags = 1024;	// Disable Respawn
		g_EntityFuncs.DispatchSpawn( pEntity.edict() );
	}

	void GivePrestiges( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;

		if ( data.iWaitTimer_UseModel < 0 )
			GivePrestige( 2, "item_longjump", pPlayer, data );
		GivePrestige( 9, "weapon_keyblade", pPlayer, data );
	}

	void GivePrestige( int &in level, string &in szWeapon, CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( data.iPrestige >= level )
			GiveWeapon( pPlayer, szWeapon );
	}
}