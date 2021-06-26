#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_Fotn_e
{
	ANIM_FOTN_IDLE = 0,
	ANIM_FOTN_IDLE_LONG,
	ANIM_FOTN_PUNCH_LEFT,
	ANIM_FOTN_PUNCH_RIGHT,
	ANIM_FOTN_DRAW
};

class weapon_fotn : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private bool bIsAttacking = false;
	private bool bLeftPunch = false;
	private float flDefaultRate = 0.5;
	private float flFireRate = flDefaultRate;

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= -1;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= 0;
		info.iSlot			= 1;
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
		self.m_iClip			= -1;
		self.m_flCustomDmg		= self.pev.dmg;

		self.FallInit();// get ready to fall down.
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		// Set the model
		SetWeaponModel( 0, "models/afterlife/w_fotn.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_fotn.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_fotn.mdl" );

		SetCustomMeleeSound( true );
		SetWeaponWorldScale( 1.0 );
		SetFireRate( 0.10 );
		SetWeaponDamage( 42 );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		SetMeleeSound( 0, "null.wav" );
		SetMeleeSound( 1, "afterlife/fotn/fotn_hit1.wav" );
		SetMeleeSound( 2, "afterlife/fotn/fotn_hit2.wav" );

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/afterlife/sheet_fotn.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_fotn.txt" );

		PrecacheSound( "afterlife/fotn/fotn_atat1.wav" );
		PrecacheSound( "afterlife/fotn/fotn_atat2.wav" );
		PrecacheSound( "afterlife/fotn/fotn_atat3.wav" );
		PrecacheSound( "afterlife/fotn/fotn_atat4.wav" );
		PrecacheSound( "afterlife/fotn/fotn_hit1.wav" );
		PrecacheSound( "afterlife/fotn/fotn_hit2.wav" );
		PrecacheSound( "afterlife/fotn/fotn_omae.wav" );
		PrecacheSound( "afterlife/fotn/fotn_start.wav" );
		PrecacheSound( "afterlife/fotn/fotn_wata.wav" );
		PrecacheSound( "afterlife/fotn/knuckles.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		bool bResult = SetDeploy( ANIM_FOTN_DRAW, "crowbar", 1.12f );

		if ( bResult )
			g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/fotn/fotn_omae.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		return bResult;
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
		if ( !bIsAttacking )
		{
			g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/fotn/fotn_start.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
			// Set the new timer
			flFireRate = flDefaultRate;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + flFireRate;
			bIsAttacking = true;
			return;
		}

		// Shoot
		// >> Animation (if more than 0 in clip)
		// >> Animation2
		// >> Distance
		// >> Bodygroup
		// >> Firerate
		Attack_Melee( 0, bLeftPunch ? ANIM_FOTN_PUNCH_LEFT : ANIM_FOTN_PUNCH_RIGHT, 32, 0, flFireRate, false );

		// Play sound
		string strAtat;
		switch( Math.RandomLong( 0, 3 ) )
		{
			case 0: strAtat = "afterlife/fotn/fotn_atat1.wav"; break;
			case 1: strAtat = "afterlife/fotn/fotn_atat2.wav"; break;
			case 2: strAtat = "afterlife/fotn/fotn_atat3.wav"; break;
			case 3: strAtat = "afterlife/fotn/fotn_atat4.wav"; break;
		}
		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strAtat, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		// Change firerate
		flFireRate = flFireRate - 0.05;
		if ( flFireRate < 0.08 )
			flFireRate = 0.08;

		// Change from left to right and vice versa
		bLeftPunch = !bLeftPunch;

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + flFireRate;
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		if ( Math.RandomLong( 0, 1 ) == 1 )
		{
			self.SendWeaponAnim( ANIM_FOTN_IDLE, 0, 0 );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.3f;
		}
		else
		{
			self.SendWeaponAnim( ANIM_FOTN_IDLE_LONG, 0, 0 );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 4.1f;
		}
	}

	void ItemPostFrame()
	{
		// Reset
		if ( m_pPlayer.pev.button & IN_ATTACK == 0 && bIsAttacking )
		{
			g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/fotn/fotn_wata.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
			bIsAttacking = false;
			bLeftPunch = false;
			flFireRate = flDefaultRate;
		}
			
		BaseClass.ItemPostFrame();
	}
}

string WeaponName_Fotn()
{
	return "weapon_fotn";
}

void RegisterWeapon_Fotn()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_Fotn(), WeaponName_Fotn() );
	g_ItemRegistry.RegisterWeapon( WeaponName_Fotn(), "afterlife", "", "" );
}