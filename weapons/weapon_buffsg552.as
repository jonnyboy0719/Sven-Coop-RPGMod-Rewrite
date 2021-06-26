#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_BuffSG552_e
{
	ANIM_BUFFSG_IDLE = 0,
	ANIM_BUFFSG_RELOAD,
	ANIM_BUFFSG_DRAW,
	ANIM_BUFFSG_SHOOT1,
	ANIM_BUFFSG_SHOOT2,
	ANIM_BUFFSG_SHOOT3
};

class weapon_buffsg552 : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int iDefault_MaxAmmo = 30;
	private int iDefault_MaxCarry = iDefault_MaxAmmo * 10;
	private int iDefaultDamage = 50;
	private float flDefaultFireRate = 0.11;

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= iDefault_MaxCarry;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= iDefault_MaxAmmo;
		info.iSlot			= 2;
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
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		// Set the model
		SetWeaponModel( 0, "models/afterlife/w_buffsg552.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_buffsg552.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_buffsg552.mdl" );

		SetWeaponWorldScale( 1.0 );
		SetFireRate( flDefaultFireRate );
		SetWeaponDamage( iDefaultDamage );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/afterlife/buffsg552_expl.spr" );
		g_Game.PrecacheModel( "sprites/afterlife/sheet_buffsg.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_buffsg552.txt" );

		PrecacheSound( "afterlife/buffsg552/draw.wav" );
		PrecacheSound( "afterlife/buffsg552/fire.wav" );
		PrecacheSound( "afterlife/buffsg552/idle.wav" );
		PrecacheSound( "afterlife/buffsg552/reload.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		return SetDeploy( ANIM_BUFFSG_DRAW, "mp5", 1.03f );
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
		if ( !Attack_Firearm( "afterlife/buffsg552/fire.wav", IsZoomed() ? 2 : 1, 9216, IsZoomed() ) )
			return;

		// Explosion shot
		// >> Sound
		// >> Sprite
		// >> Distance
		// >> Damage
		// >> Size
		// >> Range
		if ( IsZoomed() )
			Attack_Explosion( "", "sprites/afterlife/buffsg552_expl.spr", 9216, GetWeaponDamage() * 2, 64, 100, false );

		// Play animation
		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( ANIM_BUFFSG_SHOOT1 ); break;
			case 1: self.SendWeaponAnim( ANIM_BUFFSG_SHOOT2 ); break;
			case 2: self.SendWeaponAnim( ANIM_BUFFSG_SHOOT3 ); break;
		}

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + GetFireRate();
	}

	void SecondaryAttack()
	{
		if ( self.m_flNextSecondaryAttack > WeaponTimeBase() )
			return;

		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;

		if ( IsZoomed() )
		{
			SetFireRate( flDefaultFireRate );
			SetWeaponDamage( iDefaultDamage );
			EffectsFOVOFF();
		}
		else
		{
			SetFireRate( 0.25 );
			SetWeaponDamage( iDefaultDamage * 2 );
			EffectsFOVON( 25 );
		}
	}

	void Reload()
	{
		if ( self.m_iClip == iDefault_MaxAmmo || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		// Reset FOV
		EffectsFOVOFF();

		// Reset firerate and damage
		SetFireRate( flDefaultFireRate );
		SetWeaponDamage( iDefaultDamage );

		// Reload the weapon
		// >> Clip amount
		// >> Animation
		// >> Timer
		// >> Bodygroup
		Reload( iDefault_MaxAmmo, ANIM_BUFFSG_RELOAD, 2.03, 0 );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( ANIM_BUFFSG_IDLE, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 6.1f;
	}
}

string WeaponName_buffsg552()
{
	return "weapon_buffsg552";
}

void RegisterWeapon_buffsg55()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_buffsg552(), WeaponName_buffsg552() );
	g_ItemRegistry.RegisterWeapon( WeaponName_buffsg552(), "afterlife", "556", "" );
}