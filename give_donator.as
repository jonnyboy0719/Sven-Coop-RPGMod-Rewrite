namespace GiveToPlayer
{
	void GiveWeapon( CBasePlayer@ pPlayer, string szWeapon )
	{
		if ( pPlayer is null ) return;
		pPlayer.GiveNamedItem( szWeapon );
	}

	void GiveDonatorWeapons( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		GiveWeapon( pPlayer, "weapon_usp45akimbo" );
		GiveWeapon( pPlayer, "weapon_saber" );
	}
}