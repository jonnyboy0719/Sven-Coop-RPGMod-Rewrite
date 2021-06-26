#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_USP45Akimbo_e
{
	ANIM_USP45AKIMBO_IDLE = 0,
	ANIM_USP45AKIMBO_SHOOT_RIGHT,
	ANIM_USP45AKIMBO_SHOOT_LEFT,
	ANIM_USP45AKIMBO_DRAW,
	ANIM_USP45AKIMBO_IDLE_B,
	ANIM_USP45AKIMBO_SHOOT_RIGHT_B,
	ANIM_USP45AKIMBO_SHOOT_LEFT_B,
	ANIM_USP45AKIMBO_CHANGE_TO_B,
	ANIM_USP45AKIMBO_CHANGE_TO_N,
	ANIM_USP45AKIMBO_RELOAD,
	ANIM_USP45AKIMBO_RELOAD_B
};

class weapon_usp45akimbo : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int iDefault_MaxAmmo = 30;
	private int iDefault_MaxCarry = iDefault_MaxAmmo * 10;
	private int iDefaultDamage = 35;
	private float flDefaultFireRate = 0.2;
	private float flFireRateBadAss = 0.15;
	private bool bLeftShot = false;
	private bool bBadAss = false;

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= iDefault_MaxCarry;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= iDefault_MaxAmmo;
		info.iSlot			= 1;
		info.iPosition		= 4;
		info.iWeight		= 0;
		info.iId     		= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 		= ITEM_FLAG_NOAUTORELOAD | ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_SELECTONEMPTY;
		return true;
	}

	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, self.GetW_Model( GetWeaponModel( 0 ) ) );
		self.m_iClip			= iDefault_MaxAmmo;
		self.m_flCustomDmg		= self.pev.dmg;

		self.FallInit();// get ready to fall down.
		
		// Make sure we fire from our right first
		bLeftShot = false;
		bBadAss = false;
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		// Set the model
		SetWeaponModel( 0, "models/afterlife/w_usp45_akimbo.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_usp45_akimbo.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_usp45_akimbo.mdl" );

		SetWeaponWorldScale( 1.0 );
		SetFireRate( flDefaultFireRate );
		SetWeaponDamage( iDefaultDamage );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/afterlife/sheet_usp45akimbo.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_usp45akimbo.txt" );

		PrecacheSound( "afterlife/usp45/clipin.wav" );
		PrecacheSound( "afterlife/usp45/clipout.wav" );
		PrecacheSound( "afterlife/usp45/fire.wav" );
		PrecacheSound( "afterlife/usp45/sliderelease.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		// Reset firerate and damage
		SetFireRate( flDefaultFireRate );
		bBadAss = false;
		return SetDeploy( ANIM_USP45AKIMBO_DRAW, "uzis", 1.03f );
	}

	bool CanDeploy()
	{
		return true;
	}

	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false;
		EffectsFOVOFF();
		SetThink( null );
		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		SetAnimationExt( bLeftShot ? "uzis_left" : "uzis_right" );
		AkimboFireFix();

		// Shoot
		// >> Sound
		// >> Bullet count
		// >> Distance
		// >> Multiply Damage
		if ( !Attack_Firearm( "afterlife/usp45/fire.wav", 1, 9216, bBadAss ) )
			return;

		// Play animation
		if ( bLeftShot )
			self.SendWeaponAnim( bBadAss ? ANIM_USP45AKIMBO_SHOOT_LEFT_B : ANIM_USP45AKIMBO_SHOOT_LEFT );
		else
			self.SendWeaponAnim( bBadAss ? ANIM_USP45AKIMBO_SHOOT_RIGHT_B : ANIM_USP45AKIMBO_SHOOT_RIGHT );

		// From false to true, and viceversa
		bLeftShot = !bLeftShot;

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + GetFireRate();
	}

	void SecondaryAttack()
	{
		if ( self.m_flNextSecondaryAttack > WeaponTimeBase() )
			return;

		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.21f;

		if ( bBadAss )
		{
			SetFireRate( flDefaultFireRate );
			self.SendWeaponAnim( ANIM_USP45AKIMBO_CHANGE_TO_N, 0, 0 );
		}
		else
		{
			SetFireRate( flFireRateBadAss );
			self.SendWeaponAnim( ANIM_USP45AKIMBO_CHANGE_TO_B, 0, 0 );
		}
		
		// From false to true, and viceversa
		bBadAss = !bBadAss;
	}

	void Reload()
	{
		if ( self.m_flNextSecondaryAttack > WeaponTimeBase() )
			return;

		if ( self.m_iClip == iDefault_MaxAmmo || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		float flReloadTime = 2.42;
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + flReloadTime;

		SetAnimationExt( "uzis_left" );

		// Reset FOV
		EffectsFOVOFF();

		// Reload the weapon
		// >> Clip amount
		// >> Animation
		// >> Timer
		// >> Bodygroup
		int iAnim = bBadAss ? ANIM_USP45AKIMBO_RELOAD_B : ANIM_USP45AKIMBO_RELOAD;
		Reload( iDefault_MaxAmmo, iAnim, flReloadTime, 0 );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( bBadAss ? ANIM_USP45AKIMBO_IDLE_B : ANIM_USP45AKIMBO_IDLE, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.01f;
	}
}

string WeaponName_usp45akimbo()
{
	return "weapon_usp45akimbo";
}

void RegisterWeapon_usp45akimbo5()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_usp45akimbo(), WeaponName_usp45akimbo() );
	g_ItemRegistry.RegisterWeapon( WeaponName_usp45akimbo(), "afterlife", "9mm", "" );
}