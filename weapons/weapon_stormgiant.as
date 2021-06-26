#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum weapon_stormgiant_e
{
	ANIM_STORMGIANT_IDLE = 0,
	ANIM_STORMGIANT_DRAW_ATTACK,
	ANIM_STORMGIANT_DRAW_ATTACK_HIT,
	ANIM_STORMGIANT_DRAW,
	ANIM_STORMGIANT_ATTACK,
	ANIM_STORMGIANT_ATTACK_HIT,
	ANIM_STORMGIANT_ATTACK_MISS,
	ANIM_STORMGIANT_ATTACK_HEAVY,
	ANIM_STORMGIANT_ATTACK_HEAVY_HIT,
	ANIM_STORMGIANT_ATTACK_HEAVY_MISS
};

class weapon_stormgiant : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private bool bIsAttacking = false;
	private int iAttackState = 0;

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= -1;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= 0;
		info.iSlot			= 0;
		info.iPosition		= 6;
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
		SetWeaponModel( 0, "models/afterlife/p_stormgiant.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_stormgiant.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_stormgiant.mdl" );

		SetAdminWeapon( true );
		SetCustomMeleeSound( true );
		SetWeaponWorldScale( 1.0 );
		SetFireRate( 0.10 );
		SetWeaponDamage( 1000 );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		SetMeleeSound( 0, "null.wav" );
		SetMeleeSound( 1, "null.wav" );
		SetMeleeSound( 2, "null.wav" );

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/afterlife/640hud80.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_stormgiant.txt" );

		PrecacheSound( "afterlife/stormgiant/draw.wav" );
		PrecacheSound( "afterlife/stormgiant/draw_attack.wav" );
		PrecacheSound( "afterlife/stormgiant/hit1.wav" );
		PrecacheSound( "afterlife/stormgiant/hit2.wav" );
		PrecacheSound( "afterlife/stormgiant/idle.wav" );
		PrecacheSound( "afterlife/stormgiant/midslash1.wav" );
		PrecacheSound( "afterlife/stormgiant/midslash1_fail.wav" );
		PrecacheSound( "afterlife/stormgiant/midslash1_hit.wav" );
		PrecacheSound( "afterlife/stormgiant/midslash2.wav" );
		PrecacheSound( "afterlife/stormgiant/midslash2_fail.wav" );
		PrecacheSound( "afterlife/stormgiant/midslash2_hit.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		bIsAttacking = false;
		iAttackState = 0;
		return SetDeploy( ANIM_STORMGIANT_DRAW, "crowbar", 1.12f );
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

	void PlayerGotHit( CBaseEntity@ pEntity )
	{
		if ( pEntity is null ) return;
		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pEntity );
		if ( pPlayer is null ) return;

		// Ignore all admins
		if ( IsPlayerAdmin( pPlayer ) ) return;

		// Remove god mode
		pPlayer.pev.flags &= ~FL_GODMODE;
		pPlayer.pev.takedamage = DAMAGE_YES;

		// Kill the player
		pPlayer.TakeDamage( pPlayer.pev, pPlayer.pev, 999999, DMG_BLAST );
	}

	void SecondaryAttack()
	{
		if ( self.m_flNextSecondaryAttack > WeaponTimeBase() ) return;
		if ( iAttackState == 1 ) return;
		if ( !bIsAttacking )
		{
			g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/stormgiant/midslash2.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
			self.SendWeaponAnim( ANIM_STORMGIANT_ATTACK_HEAVY, 0, 0 );
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.9666666f;
			bIsAttacking = true;
			iAttackState = 2;
			return;
		}

		// Reset
		iAttackState = 0;

		// WaitTimer
		float flWait_Hit = 1.433333f;
		float flWait_Miss = 1.433333f;
		float flWait;

		// Shoot
		// >> Animation_Hit
		// >> Animation_Miss
		// >> Distance
		// >> Bodygroup
		// >> Firerate_Hit
		// >> Firerate_Miss
		bool bResult = Attack_MeleeEx( ANIM_STORMGIANT_ATTACK_HEAVY_HIT, ANIM_STORMGIANT_ATTACK_HEAVY_MISS, 32, 0, flWait_Hit, flWait_Miss, false );

		// Play sound
		string strSound;
		if ( bResult )
		{
			strSound = "afterlife/stormgiant/midslash2_hit.wav";
			flWait = flWait_Hit;
		}
		else
		{
			strSound = "afterlife/stormgiant/midslash2_fail.wav";
			flWait = flWait_Miss;
		}

		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strSound, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flWait;
	}

	void PrimaryAttack()
	{
		if ( self.m_flNextPrimaryAttack > WeaponTimeBase() ) return;
		if ( iAttackState == 2 ) return;
		if ( !bIsAttacking )
		{
			g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/stormgiant/midslash1.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
			self.SendWeaponAnim( ANIM_STORMGIANT_ATTACK, 0, 0 );
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.1f;
			bIsAttacking = true;
			iAttackState = 1;
			return;
		}

		// Reset
		iAttackState = 0;

		// WaitTimer
		float flWait_Hit = 2.3f;
		float flWait_Miss = 2.3f;
		float flWait;

		// Shoot
		// >> Animation_Hit
		// >> Animation_Miss
		// >> Distance
		// >> Bodygroup
		// >> Firerate_Hit
		// >> Firerate_Miss
		bool bResult = Attack_MeleeEx( ANIM_STORMGIANT_ATTACK_HIT, ANIM_STORMGIANT_ATTACK_MISS, 32, 0, flWait_Hit, flWait_Miss, false );

		// Play sound
		string strSound;
		if ( bResult )
		{
			strSound = "afterlife/stormgiant/midslash1_hit.wav";
			flWait = flWait_Hit;
		}
		else
		{
			strSound = "afterlife/stormgiant/midslash1_fail.wav";
			flWait = flWait_Miss;
		}

		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strSound, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flWait;
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( ANIM_STORMGIANT_IDLE, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 13.36667f;
	}

	void ItemPostFrame()
	{
		if ( bIsAttacking )
		{
			if ( iAttackState == 1 )
				PrimaryAttack();
			else if ( iAttackState == 2 )
				SecondaryAttack();
			else
				bIsAttacking = false;
		}
		else
		{
			BaseClass.ItemPostFrame();
		}
	}
}

string WeaponName_Stormgiant()
{
	return "weapon_stormgiant";
}

void Registerweapon_stormgiant()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_Stormgiant(), WeaponName_Stormgiant() );
	g_ItemRegistry.RegisterWeapon( WeaponName_Stormgiant(), "afterlife", "", "" );
}