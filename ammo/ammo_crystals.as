#include "../base_ammo"

class ammo_crystals : ScriptBasePlayerAmmoEntity, ammo_afterlife_base
{
	void Spawn()
	{ 
		Precache();
		g_EntityFuncs.SetModel( self, "models/afterlife/w_ethereal_ammo.mdl" );
		BaseClass.Spawn();
	}

	void Precache()
	{
		BaseClass.Precache();
		g_Game.PrecacheModel( "models/afterlife/w_ethereal_ammo.mdl" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		//afterlife_crystal
		return CommonAddAmmo( pOther, 20, 200, "afterlife_crystals" );
	}
}

void RegisterAmmoCrystals()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "ammo_crystals", "ammo_crystals" );
}