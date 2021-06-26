#include "ammo/ammo_crystals"
#include "weapons/weapon_keyblade"
#include "weapons/weapon_buffsg552"
#include "weapons/weapon_skull11"
#include "weapons/weapon_af_ethereal"
#include "weapons/weapon_af_ethereal_mk2"
#include "weapons/weapon_fotn"
#include "weapons/weapon_stormgiant"
#include "weapons/weapon_saber"
#include "weapons/weapon_usp45akimbo"

#include "lib/playermodels"
#include "lib/giftfromthegods"
#include "lib/weaponshop"

void RegisterAllWeapons()
{
	// Weapons
	RegisterKeyBlade();
	RegisterWeapon_buffsg55();
	RegisterWeapon_skull11();
	RegisterWeapon_Ethereal();
	RegisterWeapon_Ethereal_MK2();
	RegisterWeapon_Fotn();
	Registerweapon_stormgiant();
	RegisterWeapon_Saber();
	RegisterWeapon_usp45akimbo5();

	// Ammo
	RegisterAmmoCrystals();
}

void RPGGetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity, Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale )
{
	Vector vecForward, vecRight, vecUp;
	
	g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );
	
	const float fR = Math.RandomFloat( 50, 70 );
	const float fU = Math.RandomFloat( 100, 150 );
 
	for( int i = 0; i < 3; ++i )
	{
		ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * 25;
		ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
	}
}