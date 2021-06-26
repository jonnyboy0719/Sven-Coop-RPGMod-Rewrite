#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_Saber_e
{
	ANIM_SABER_IDLE = 0,
	ANIM_SABER_DRAW,
	ANIM_SABER_STAB,
	ANIM_SABER_MIDSLASH1,
	ANIM_SABER_MIDSLASH2,
	ANIM_SABER_MIDSLASH3
};

class weapon_saber : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CScheduledFunction@ PlayerLightSchedule = null;
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}

	// NOTE:
	//		This is a modified func from CoF weapons pack
	//		Credit goes to KernCore!
	private void LanternDLight( Vector& in vecPos )
	{
		NetworkMessage LanternDL( MSG_ALL, NetworkMessages::SVC_TEMPENTITY, null );
			LanternDL.WriteByte( TE_DLIGHT );
			LanternDL.WriteCoord( vecPos.x );
			LanternDL.WriteCoord( vecPos.y );
			LanternDL.WriteCoord( vecPos.z );
			LanternDL.WriteByte( 22 ); //Radius
			LanternDL.WriteByte( int(255) ); //R
			LanternDL.WriteByte( int(15) ); //G
			LanternDL.WriteByte( int(15) ); //B
			LanternDL.WriteByte( 1 ); //Life
			LanternDL.WriteByte( 0 ); //Decay
		LanternDL.End();
	}

	//Solokiller
	private void ClearThinkMethods()
	{
		g_Scheduler.RemoveTimer( PlayerLightSchedule );
		@PlayerLightSchedule = @null;
	}

	~weapon_saber()
	{
		ClearThinkMethods();
		//g_Log.PrintF("Lantern has been destroyed via ~ \n");
	}
	//Solokiller

	void OnDestroy()
	{
		ClearThinkMethods();
		//g_Log.PrintF("Lantern has been destroyed via OnDestroy \n");
	}

	void LightPlayerThink()
	{
		//LanternDLight( m_pPlayer.Center() );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= -1;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= 0;
		info.iSlot			= 0;
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
		self.m_iClip			= -1;
		self.m_flCustomDmg		= self.pev.dmg;

		self.FallInit();// get ready to fall down.
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		// Set the model
		SetWeaponModel( 0, "models/afterlife/w_saber.mdl" );
		SetWeaponModel( 1, "models/afterlife/v_saber.mdl" );
		SetWeaponModel( 2, "models/afterlife/p_saber.mdl" );

		SetCustomMeleeSound( true );
		SetWeaponWorldScale( 1.0 );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		SetMeleeSound( 0, "null.wav" );
		SetMeleeSound( 1, "afterlife/saber/hit1.wav" );
		SetMeleeSound( 2, "afterlife/saber/hit2.wav" );

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/afterlife/sheet_saber.spr" );
		// Precahe this sprite sheet file!
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_saber.txt" );

		PrecacheSound( "afterlife/saber/draw.wav" );
		PrecacheSound( "afterlife/saber/hit1.wav" );
		PrecacheSound( "afterlife/saber/hit2.wav" );
		PrecacheSound( "afterlife/saber/idle.wav" );
		PrecacheSound( "afterlife/saber/midslash1.wav" );
		PrecacheSound( "afterlife/saber/midslash2.wav" );
		PrecacheSound( "afterlife/saber/midslash3.wav" );
		PrecacheSound( "afterlife/saber/stab.wav" );
		PrecacheSound( "afterlife/saber/wall1.wav" );
		PrecacheSound( "afterlife/saber/wall2.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		bool bResult = SetDeploy( ANIM_SABER_DRAW, "crowbar", 1.16f );

		if ( bResult )
		{
			@PlayerLightSchedule = @g_Scheduler.SetInterval( @this, "LightPlayerThink", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
			g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/saber/draw.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
		}
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
		g_Scheduler.RemoveTimer( PlayerLightSchedule );
		@PlayerLightSchedule = @null;
		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		float flFireRate = 1.16f;
		SetWeaponDamage( 200 );

		// Shoot
		// >> Animation (if more than 0 in clip)
		// >> Animation2
		// >> Distance
		// >> Bodygroup
		// >> Firerate
		int iAnimation;
		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: iAnimation = ANIM_SABER_MIDSLASH1; break;
			case 1: iAnimation = ANIM_SABER_MIDSLASH2; break;
			case 2: iAnimation = ANIM_SABER_MIDSLASH3; break;
		}
		Attack_Melee( 0, iAnimation, 35, 0, flFireRate, false );

		// Play sound
		string strAtat;
		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: strAtat = "afterlife/saber/midslash1.wav"; break;
			case 1: strAtat = "afterlife/saber/midslash2.wav"; break;
			case 2: strAtat = "afterlife/saber/midslash3.wav"; break;
		}
		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strAtat, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + flFireRate;
	}

	void SecondaryAttack()
	{
		float flFireRate = 1.16f;
		SetWeaponDamage( 80 );

		// Shoot
		// >> Animation (if more than 0 in clip)
		// >> Animation2
		// >> Distance
		// >> Bodygroup
		// >> Firerate
		Attack_Melee( 0, ANIM_SABER_STAB, 40, 0, flFireRate, false );

		g_Scheduler.SetTimeout( @this, "SecondarySwingAttack", 0.35 );

		// Play sound
		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, "afterlife/saber/stab.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + flFireRate;
	}
	
	void SecondarySwingAttack()
	{
		Attack_Melee( 0, -1, 40, 0, flFireRate, false );
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( ANIM_SABER_IDLE, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 10.01f;
	}

	void ItemPostFrame()
	{
		BaseClass.ItemPostFrame();
	}
}

string WeaponName_Saber()
{
	return "weapon_saber";
}

void RegisterWeapon_Saber()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_Saber(), WeaponName_Saber() );
	g_ItemRegistry.RegisterWeapon( WeaponName_Saber(), "afterlife", "", "" );
}