#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_Skull11_e
{
	ANIM_SKULL11_IDLE = 0,
	ANIM_SKULL11_SHOOT1,
	ANIM_SKULL11_SHOOT2,
	ANIM_SKULL11_RELOAD,
	ANIM_SKULL11_DRAW,
};

class weapon_skull11 : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int iDefault_MaxAmmo = 20;
	private int iDefault_MaxCarry = iDefault_MaxAmmo * 10;

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= iDefault_MaxCarry;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= iDefault_MaxAmmo;
		info.iSlot			= 2;
		info.iPosition		= 5;
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
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		// Set the model
		SetWeaponModel( 0, "models/afterlife/w_skull11.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_skull11.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_skull11.mdl" );

		SetWeaponWorldScale( 1.0 );
		SetFireRate( 0.35 );
		SetWeaponDamage( 28 );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/afterlife/ef_balrog1.spr" );	
		g_Game.PrecacheModel( "sprites/afterlife/sheet_skull11.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_skull11.txt" );

		PrecacheSound( "afterlife/skull11/boltpull.wav" );
		PrecacheSound( "afterlife/skull11/fire.wav" );
		PrecacheSound( "afterlife/skull11/clipin.wav" );
		PrecacheSound( "afterlife/skull11/clipout.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		return SetDeploy( ANIM_SKULL11_DRAW, "m16", 1.12f );
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
		// Shoot
		// >> Sound
		// >> Bullet count
		// >> Distance
		// >> Multiply Damage
		if ( !Attack_Firearm( "afterlife/skull11/fire.wav", 1, 9216, false ) )
			return;

		// Explosion shot
		// >> Sound
		// >> Sprite
		// >> Distance
		// >> Damage
		// >> Size
		// >> Range
		Attack_Explosion( "", "sprites/afterlife/ef_balrog1.spr", 9216, GetWeaponDamage() * 2, 64, 200 );

		// Play animation
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( ANIM_SKULL11_SHOOT1 ); break;
			case 1: self.SendWeaponAnim( ANIM_SKULL11_SHOOT2 ); break;
		}

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + GetFireRate();
	}

	void Reload()
	{
		if ( self.m_iClip == iDefault_MaxAmmo || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		// Reload the weapon
		// >> Clip amount
		// >> Animation
		// >> Timer
		// >> Bodygroup
		Reload( iDefault_MaxAmmo, ANIM_SKULL11_RELOAD, 4.06, 0 );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( ANIM_SKULL11_IDLE, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 3.1f;
	}
}

string WeaponName_skull11()
{
	return "weapon_skull11";
}

void RegisterWeapon_skull11()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_skull11(), WeaponName_skull11() );
	g_ItemRegistry.RegisterWeapon( WeaponName_skull11(), "afterlife", "buckshot", "" );
}