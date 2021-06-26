#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_Ethereal_MK2_e
{
	ANIM_ETHEREAL_MK2_IDLE = 0,
	ANIM_ETHEREAL_MK2_RELOAD,
	ANIM_ETHEREAL_MK2_DRAW,
	ANIM_ETHEREAL_MK2_SHOOT
};

class weapon_af_ethereal_mk2 : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
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
		info.iPosition		= 7;
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
		SetWeaponModel( 0, "models/afterlife/w_plasmagun_v2.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_plasmagun_v2.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_plasmagun_v2.mdl" );

		SetWeaponWorldScale( 1.0 );
		SetFireRate( 0.32 );
		SetWeaponDamage( 75 );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "models/afterlife/w_ethereal_ammo.mdl" );	// Ammo model
		g_Game.PrecacheModel( "sprites/laserbeam.spr" );
		g_Game.PrecacheModel( "sprites/afterlife/sheet_ethereal_mk2.spr" );
		g_Game.PrecacheModel( "sprites/afterlife/plasmagun/explode_v2.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_af_ethereal_mk2.txt" );

		PrecacheSound( "items/ammopickup1.wav" );
		PrecacheSound( "afterlife/plasmagun/exp.wav" );
		PrecacheSound( "afterlife/plasmagun/fire.wav" );
		PrecacheSound( "afterlife/plasmagun/idle.wav" );
		PrecacheSound( "afterlife/plasmagun/draw.wav" );
		PrecacheSound( "afterlife/plasmagun/clipin1.wav" );
		PrecacheSound( "afterlife/plasmagun/clipin2.wav" );
		PrecacheSound( "afterlife/plasmagun/clipout.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		return SetDeploy( ANIM_ETHEREAL_MK2_DRAW, "m16", 1.12f );
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
		// >> Sound (Explosion)
		// >> Particle
		// >> Bullet count
		// >> Distance
		// >> Particle Size
		// >> Damage Size
		// >> Color (red)
		// >> Color (green)
		// >> Color (blue)
		// >> Dynlight (true by default)
		if ( !Attack_Particle( "afterlife/plasmagun/fire.wav", "afterlife/plasmagun/exp.wav", "sprites/afterlife/plasmagun/explode_v2.spr", 1, 9216, 15, 200, 255, 10, 10 ) )
			return;

		// Play animation
		self.SendWeaponAnim( ANIM_ETHEREAL_MK2_SHOOT );

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
		Reload( iDefault_MaxAmmo, ANIM_ETHEREAL_MK2_RELOAD, 3.66, 0 );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( ANIM_ETHEREAL_MK2_IDLE, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 6.1f;
	}
}

string WeaponName_Ethereal_MK2()
{
	return "weapon_af_ethereal_mk2";
}

void RegisterWeapon_Ethereal_MK2()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_Ethereal_MK2(), WeaponName_Ethereal_MK2() );
	g_ItemRegistry.RegisterWeapon( WeaponName_Ethereal_MK2(), "afterlife", "afterlife_crystals", "" );
}