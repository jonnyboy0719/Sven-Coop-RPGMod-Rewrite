enum WeaponState
{
	WEP_STATE_RIFLE = 0,
	WEP_STATE_SHOTGUN,
	WEP_STATE_SIDEARM,
	WEP_STATE_AKIMBO,
	WEP_STATE_SNIPER,
	WEP_STATE_HMG,
	WEP_STATE_MELEE_CROWBAR,
	WEP_STATE_MELEE_WRENCH
};

enum SniperState
{
	SNIPER_DEFAULT = 0,
	SNIPER_ZOOM
};

mixin class weapon_afterlife_base
{
	// Default setup
	private int iDamageBits = DMG_BULLET;
	private int iZoomState = SNIPER_DEFAULT;
	private int iDamage = 16;
	private bool bAdminWeapon = false;
	private float flWeaponScale = 1.0;
	private int iWeaponState = 0;
	private string strVModel = "";
	private string strWModel = "";
	private string strPModel = "";
	private float flFireRate = 1.0;
	private bool bCustomMeleeSound = false;
	private string strMelee_Miss = "";
	private string strMelee_Hit = "";
	private string strMelee_Hit_World = "";
	private Vector VecAccuracy = VECTOR_CONE_2DEGREES;
	
	// Functions
	bool GetAdminWeapon() { return bAdminWeapon; }
	void SetAdminWeapon( bool state ) { bAdminWeapon = state; }
	void SetWeaponState( int state ) { iWeaponState = state; }
	void SetDamageBits( int bit ) { iDamageBits = bit; }
	int GetWeaponDamage() { return iDamage; }
	void SetWeaponDamage( int bit ) { iDamage = bit; }
	void SetCustomMeleeSound( bool state ) { bCustomMeleeSound = state; }
	void SetWeaponWorldScale( float scale ) { flWeaponScale = scale; }
	void SetWeaponAccuracy( Vector acc ) { VecAccuracy = acc; }
	
	string GetWeaponModel( int state )
	{
		if ( state == 1 ) return strVModel;
		else if ( state == 2 ) return strPModel;
		return strWModel;
	}
	void SetWeaponModel( int state, string strModel )
	{
		if ( state == 1 )
			strVModel = strModel;
		else if ( state == 2 )
			strPModel = strModel;
		else
			strWModel = strModel;
	}

	void SetMeleeSound( int state, string strSound )
	{
		if ( state == 1 )
			strMelee_Hit = strSound;
		else if ( state == 2 )
			strMelee_Hit_World = strSound;
		else
			strMelee_Miss = strSound;
	}
	
	void PrecacheSound( const string strSound )
	{
		g_SoundSystem.PrecacheSound( strSound );
		g_Game.PrecacheGeneric( "sound/" + strSound );
	}
	
	void SetAnimationExt( const string strExt )
	{
		m_pPlayer.m_szAnimExtension = strExt;
	}

	bool IsPlayerAdmin( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return false;
		AdminLevel_t adminLevel = g_PlayerFuncs.AdminLevel( pPlayer );
		if ( adminLevel >= ADMIN_YES )
			return true;
		return false;
	}

	bool CanPickupWeapon( CBasePlayer@ pPlayer )
	{
		// Check if the player has the rights to use this
		if ( pPlayer is null ) return false;
		if ( GetAdminWeapon() ) { return IsPlayerAdmin( pPlayer ); }
		return true;
	}

	bool SetDeploy( int iAnimation, string strAnim, float deployTime = 1.0f )
	{
		bool bResult;
		{
			bResult = Deploy( GetWeaponModel( 1 ), GetWeaponModel( 2 ), iAnimation, strAnim, 0 );
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	bool CommonAddToPlayer( CBasePlayer@ pPlayer ) // adds a weapon to the player
	{
		if ( !CanPickupWeapon( pPlayer ) )
			return false;

		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		NetworkMessage weapon( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			weapon.WriteLong( g_ItemRegistry.GetIdForName( self.pev.classname ) );
		weapon.End();

		return true;
	}

	void CustomTouch( CBaseEntity@ pOther )
	{
		if( !pOther.IsPlayer() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

		if ( !CanPickupWeapon( pPlayer ) )
			return;

		if( pPlayer.HasNamedPlayerItem( self.pev.classname ) !is null )
			return;

		if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
			self.AttachToPlayer( pPlayer );
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup1.wav", 1, ATTN_NORM );
		}
	}

	void CustomUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		if( !pActivator.IsPlayer() || !pActivator.IsAlive() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

		if ( !CanPickupWeapon( pPlayer ) )
			return;

		if( pPlayer.HasNamedPlayerItem( self.pev.classname ) !is null )
			return;

		if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
			self.AttachToPlayer( pPlayer );
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
		}
	}

	protected bool m_fDropped;
	CBasePlayerItem@ DropItem()
	{
		self.pev.scale = flWeaponScale;
		m_fDropped = true;
		return self;
	}

	void DynamicTracer( Vector start, Vector end, NetworkMessageDest msgType = MSG_PVS, edict_t@ dest = null )
	{
		NetworkMessage DynTrace( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
			DynTrace.WriteByte( TE_TRACER );
			DynTrace.WriteCoord( start.x );
			DynTrace.WriteCoord( start.y );
			DynTrace.WriteCoord( start.z );
			DynTrace.WriteCoord( end.x );
			DynTrace.WriteCoord( end.y );
			DynTrace.WriteCoord( end.z );
		DynTrace.End();
	}

	void PlayTracer( CBasePlayer@ pPlayer, Vector& in vecAttachOrigin, Vector& in vecAttachAngles, TraceResult& in tr )
	{
		g_EngineFuncs.GetAttachment( pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		DynamicTracer( vecAttachOrigin + g_Engine.v_forward * 64, tr.vecEndPos );
	}

	void DynamicLazerTracer( int iColorR, int iColorG, int iColorB, Vector start, Vector end, NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null )
	{
		NetworkMessage DynTrace( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
			DynTrace.WriteByte( TE_BEAMPOINTS );
			DynTrace.WriteCoord( start.x );
			DynTrace.WriteCoord( start.y );
			DynTrace.WriteCoord( start.z );
			DynTrace.WriteCoord( end.x );
			DynTrace.WriteCoord( end.y );
			DynTrace.WriteCoord( end.z );
			DynTrace.WriteShort( g_EngineFuncs.ModelIndex( "sprites/laserbeam.spr" ) );
			DynTrace.WriteByte( 0 );
			DynTrace.WriteByte( 100 );
			DynTrace.WriteByte( 1 );
			DynTrace.WriteByte( 16 );
			DynTrace.WriteByte( 0 );
			DynTrace.WriteByte( iColorR );
			DynTrace.WriteByte( iColorG );
			DynTrace.WriteByte( iColorB );
			DynTrace.WriteByte( 255 ); // actually brightness
			DynTrace.WriteByte( 32 );
		DynTrace.End();
	}

	void PlayLazerTracer( CBasePlayer@ pPlayer, Vector& in vecAttachOrigin, Vector& in vecAttachAngles, TraceResult& in tr, int iColorR, int iColorG, int iColorB )
	{
		g_EngineFuncs.GetAttachment( pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		DynamicLazerTracer( iColorR, iColorG, iColorB, vecAttachOrigin + g_Engine.v_forward * 64, tr.vecEndPos );
	}

	edict_t@ ENT( const entvars_t@ pev )
	{
		return pev.pContainingEntity;
	}

	void Reload( int iAmmo, int iAnim, float iTimer, int iBodygroup )
	{
		self.DefaultReload( iAmmo, iAnim, iTimer, iBodygroup );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + iTimer;
	}

	bool Deploy( string& in vmodel, string& in pmodel, int& in iAnim, string& in pAnim, int& in iBodygroup )
	{
		self.pev.scale = 1.0;
		m_fDropped = false;
		self.DefaultDeploy( self.GetV_Model( vmodel ), self.GetP_Model( pmodel ), iAnim, pAnim, 0, iBodygroup );
		EffectsFOVOFF();
		return true;
	}

	void punchangle( float& in punch_x, float& in punch_y, float& in punch_z, bool shouldrise = false )
	{
		if( shouldrise )
			m_pPlayer.pev.punchangle.x += punch_x;
		else
			m_pPlayer.pev.punchangle.x = punch_x;

		m_pPlayer.pev.punchangle.y = punch_y;
		m_pPlayer.pev.punchangle.z -= punch_z;
	}

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	void CoFGetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity, Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale, bool leftShell, bool downShell )
	{
		Vector vecForward, vecRight, vecUp;
	
		g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );
	
		const float fR = (leftShell == true) ? Math.RandomFloat( -120, -60 ) : Math.RandomFloat( 60, 120 );
		const float fU = (downShell == true) ? Math.RandomFloat( -150, -90 ) : Math.RandomFloat( 90, 150 );

		for( int i = 0; i < 3; ++i )
		{
			ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * Math.RandomFloat( 1, 50 );
			ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
		}
	}

	float GetFireRate() { return flFireRate; }
	void SetFireRate( float rate ) { flFireRate = rate; }

	void SetFOV( int fov )
	{
		m_pPlayer.pev.fov = m_pPlayer.m_iFOV = fov;
	}
	
	bool IsZoomed() { return iZoomState == SNIPER_ZOOM ? true : false; }

	void EffectsFOVON( int value )
	{
		SetFOV( value );
		m_pPlayer.pev.maxspeed = 150;
		m_pPlayer.SetVModelPos( Vector( 0, 0, 0 ) );
		iZoomState = SNIPER_ZOOM;
	}

	void EffectsFOVOFF()
	{
		SetFOV( 0 );
		m_pPlayer.pev.maxspeed = 0;
		m_pPlayer.ResetVModelPos();
		iZoomState = SNIPER_DEFAULT;
	}
	
	void AkimboFireFix()
	{
		SetThink( ThinkFunction( this.DoAkimboAnimFix ) );
		self.pev.nextthink = WeaponTimeBase() + 0.1;
	}
	
	void DoAkimboAnimFix()
	{
		SetAnimationExt( "uzis" );
	}

	float WeaponTimeBase() { return g_Engine.time; }

	void PrimaryAttack() {}
	void SecondaryAttack() {}
	void Reload() {}

	void DynamicLight( Vector& in vecPos, int& in radius, int& in r, int& in g, int& in b, int8& in life, int& in decay )
	{
		NetworkMessage dynLight( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			dynLight.WriteByte( TE_DLIGHT );
			dynLight.WriteCoord( vecPos.x );
			dynLight.WriteCoord( vecPos.y );
			dynLight.WriteCoord( vecPos.z );
			dynLight.WriteByte( radius );
			dynLight.WriteByte( int(r) );
			dynLight.WriteByte( int(g) );
			dynLight.WriteByte( int(b) );
			dynLight.WriteByte( life );
			dynLight.WriteByte( decay );
		dynLight.End();
	}

	void TE_Explosion( Vector origin, string sprite, int scale, int frameRate, int flags )
	{
		NetworkMessage exp1( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			exp1.WriteByte( TE_EXPLOSION );
			exp1.WriteCoord( origin.x );
			exp1.WriteCoord( origin.y );
			exp1.WriteCoord( origin.z );
			exp1.WriteShort( g_EngineFuncs.ModelIndex(sprite) );
			exp1.WriteByte( int((scale-50) * .60) );
			exp1.WriteByte( frameRate );
			exp1.WriteByte( flags );
		exp1.End();
	}

	void TE_Sprite( Vector origin, string sprite, int scale, int alpha )
	{
		NetworkMessage SprTemp( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			SprTemp.WriteByte( TE_SPRITE );
			SprTemp.WriteCoord( origin.x );
			SprTemp.WriteCoord( origin.y );
			SprTemp.WriteCoord( origin.z );
			SprTemp.WriteShort(g_EngineFuncs.ModelIndex( sprite ) );
			SprTemp.WriteByte( scale );
			SprTemp.WriteByte( alpha );
		SprTemp.End();
	}

	void Attack_Explosion( const string strSoundName, const string strSpriteLocation, float iMaxDist, int iDamage, int iSpriteSize, float flDamageSize, bool bDecal = true )
	{
		// Setup
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );

		// Where the explosion will happen
		Vector vecSrc    	= m_pPlayer.GetGunPosition();
		Vector vecAiming 	= m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		Vector vecDir		= vecAiming + x * VecAccuracy.x * g_Engine.v_right + y * VecAccuracy.y * g_Engine.v_up;
		Vector vecEnd		= vecSrc + vecDir * iMaxDist;

		// Tracer
		TraceResult tr;
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		// Go boom
		entvars_t@ pevOwner = self.pev.owner.vars;
		TE_Explosion( tr.vecEndPos, strSpriteLocation, iSpriteSize, 15, TE_EXPLFLAG_NOSOUND );
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, pevOwner, iDamage, flDamageSize, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB );

		// Create decal
		if ( bDecal )
			g_Utility.DecalTrace( tr, DECAL_SCORCH1 + Math.RandomLong(0, 1) );

		// Play sound
		if ( strSoundName != "" )
			g_SoundSystem.PlaySound( self.edict(), CHAN_ITEM, strSoundName, 1.0, ATTN_NORM, 0, PITCH_NORM, 0, true, tr.vecEndPos );
	}

	bool Attack_Firearm( const string strSoundName, int iBullets, float iMaxDist, bool bMultiDamage )
	{
		if ( self.m_iClip <= 0 )
			return false;

		// We don't have anough bullets!!
		if ( self.m_iClip < iBullets )
			return false;

		// Don't shoot if the timer is higher than WeaponTimeBase
		if ( self.m_flNextPrimaryAttack > WeaponTimeBase() )
			return false;

		// iBullets can't be less than 1
		if ( iBullets < 1 )
			iBullets = 1;

		// Common between each weapon
		Vector vecSrc    	= m_pPlayer.GetGunPosition();
		Vector vecAiming 	= m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		m_pPlayer.m_iWeaponVolume 	= NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash 	= NORMAL_GUN_FLASH;

		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strSoundName, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		for ( int i = 0; i < iBullets; ++i )
			--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		DynamicLight( m_pPlayer.EyePosition() + g_Engine.v_forward * 64, 18, 240, 180, 100, 1, 100 );
		m_pPlayer.FireBullets( iBullets, vecSrc, vecAiming, VecAccuracy, iMaxDist, BULLET_PLAYER_CUSTOMDAMAGE, 2, iDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		TraceResult tr;
		float x, y;

		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir	= vecAiming + x * VecAccuracy.x * g_Engine.v_right + y * VecAccuracy.y * g_Engine.v_up;
		Vector vecEnd	= vecSrc + vecDir * iMaxDist;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		Vector vecTracerOr, vecTracerAn;

		PlayTracer( m_pPlayer, (iZoomState == SNIPER_DEFAULT) ? vecTracerOr : vecSrc, vecTracerAn, tr );

		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );

				if( bMultiDamage == true )
				{
					if( pHit !is null )
					{
						g_WeaponFuncs.ClearMultiDamage();
						pHit.TraceAttack( m_pPlayer.pev, iDamage, vecEnd, tr, iDamageBits );
						g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
					}
				}

				g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + (vecEnd - vecSrc) * 2, BULLET_PLAYER_CUSTOMDAMAGE );

				if( pHit is null || pHit.IsBSPModel() == true )
				{
					g_WeaponFuncs.DecalGunshot( tr, 100 );
				}
			}
		}
		return true;
	}

	bool Attack_Lazer( const string strSoundName, int iBullets, float iMaxDist, int iColorR, int iColorG, int iColorB, bool bDynLight = true )
	{
		if ( self.m_iClip <= 0 )
			return false;

		// We don't have anough bullets!!
		if ( self.m_iClip < iBullets )
			return false;

		// Don't shoot if the timer is higher than WeaponTimeBase
		if ( self.m_flNextPrimaryAttack > WeaponTimeBase() )
			return false;

		// iBullets can't be less than 1
		if ( iBullets < 1 )
			iBullets = 1;

		// Common between each weapon
		Vector vecSrc    	= m_pPlayer.GetGunPosition();
		Vector vecAiming 	= m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		m_pPlayer.m_iWeaponVolume 	= NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash 	= NORMAL_GUN_FLASH;

		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strSoundName, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		for ( int i = 0; i < iBullets; ++i )
			--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		if ( bDynLight )
			DynamicLight( m_pPlayer.EyePosition() + g_Engine.v_forward * 64, 18, iColorR, iColorG, iColorB, 1, 100 );
		m_pPlayer.FireBullets( iBullets, vecSrc, vecAiming, VecAccuracy, iMaxDist, BULLET_PLAYER_CUSTOMDAMAGE, 2, iDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		TraceResult tr;
		float x, y;

		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir	= vecAiming + x * VecAccuracy.x * g_Engine.v_right + y * VecAccuracy.y * g_Engine.v_up;
		Vector vecEnd	= vecSrc + vecDir * iMaxDist;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		Vector vecTracerOr, vecTracerAn;

		PlayLazerTracer( m_pPlayer, (iZoomState == SNIPER_DEFAULT) ? vecTracerOr : vecSrc, vecTracerAn, tr, iColorR, iColorG, iColorB );

		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + (vecEnd - vecSrc) * 2, BULLET_PLAYER_CUSTOMDAMAGE );

				if( pHit is null || pHit.IsBSPModel() == true )
				{
					g_WeaponFuncs.DecalGunshot( tr, 100 );
				}
			}
		}
		return true;
	}

	bool Attack_Particle( const string strSoundName, const string strSoundNameExpl, const string strParticle, int iBullets, float iMaxDist, int iSpriteSize, float flDamageSize, int iColorR, int iColorG, int iColorB, bool bDynLight = true )
	{
		if ( self.m_iClip <= 0 )
			return false;

		// We don't have anough bullets!!
		if ( self.m_iClip < iBullets )
			return false;

		// Don't shoot if the timer is higher than WeaponTimeBase
		if ( self.m_flNextPrimaryAttack > WeaponTimeBase() )
			return false;

		// iBullets can't be less than 1
		if ( iBullets < 1 )
			iBullets = 1;

		// Common between each weapon
		Vector vecSrc    	= m_pPlayer.GetGunPosition();
		Vector vecAiming 	= m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		m_pPlayer.m_iWeaponVolume 	= NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash 	= NORMAL_GUN_FLASH;

		g_SoundSystem.EmitSoundDyn( self.pev.owner, CHAN_WEAPON, strSoundName, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		for ( int i = 0; i < iBullets; ++i )
			--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		if ( bDynLight )
			DynamicLight( m_pPlayer.EyePosition() + g_Engine.v_forward * 64, 18, iColorR, iColorG, iColorB, 1, 100 );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		TraceResult tr;
		float x, y;

		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir	= vecAiming + x * VecAccuracy.x * g_Engine.v_right + y * VecAccuracy.y * g_Engine.v_up;
		Vector vecEnd	= vecSrc + vecDir * iMaxDist;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		// Go boom
		entvars_t@ pevOwner = self.pev.owner.vars;
		TE_Sprite( tr.vecEndPos, strParticle, iSpriteSize, 225 );
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, pevOwner, iDamage, flDamageSize, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB );

		// Change the dynlight to our own
		if ( bDynLight )
			DynamicLight( tr.vecEndPos, 35, iColorR, iColorG, iColorB, 2, 100 );

		// Custom explosion sound
		g_SoundSystem.PlaySound( self.edict(), CHAN_ITEM, strSoundNameExpl, 1.0, ATTN_NORM, 0, PITCH_NORM, 0, true, tr.vecEndPos );

		return true;
	}

	void PlayerGotHit( CBaseEntity@ pEntity ) {}

	protected TraceResult m_trHit;
	bool Attack_Melee( int iAnimation, int iAnimation2, float distance, int bodygroup, float firerate, bool bPunchAngle = true )
	{
		bool fDidHit = false;
		float flDamage = iDamage;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * distance;

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );

				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if( tr.flFraction >= 1.0 )
		{
			// miss
			if ( iAnimation2 > 0 )
				self.SendWeaponAnim( ( self.m_iClip > 0 ) ? iAnimation : iAnimation2, 0, bodygroup );

			EffectsFOVOFF();
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + firerate;
			self.m_flTimeWeaponIdle = g_Engine.time + firerate + 0.5f;

			// play wiff or swish sound
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, (bCustomMeleeSound) ? strMelee_Miss : "weapons/cbar_miss1.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );
		}
		else
		{
			// hit
			fDidHit = true;
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			if ( iAnimation2 > 0 )
				self.SendWeaponAnim( (self.m_iClip > 0) ? iAnimation : iAnimation2, 0, bodygroup );
			EffectsFOVOFF();

			if ( bPunchAngle )
				m_pPlayer.pev.punchangle.z = Math.RandomLong( -7, -5 );

			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;

			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextTertiaryAttack + firerate < g_Engine.time )
			{
				// first swing does full damage and will launch the enemy a bit
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB | DMG_LAUNCH );
			}
			else
			{
				// subsequent swings do 50% (Changed -Sniper/KernCore) (50% less damage)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.5, g_Engine.v_forward, tr, DMG_CLUB | DMG_LAUNCH );
			}	
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + firerate;
				self.m_flTimeWeaponIdle = g_Engine.time + firerate + 0.5f;

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
					if( pEntity.IsPlayer() )
					{
						PlayerGotHit( pEntity );
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}

					g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_ITEM, (bCustomMeleeSound) ? strMelee_Hit : "weapons/cbar_hitbod1.wav" , 1, ATTN_NORM );

					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR | BULLET_NONE );
				
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + firerate;
				self.m_flTimeWeaponIdle = g_Engine.time + firerate + 0.5f;
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.
				fvolbar = 1;

				// also play crowbar strike
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, (bCustomMeleeSound) ? strMelee_Hit_World : "weapons/cbar_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); 
			}

			// delay the decal a bit
			m_trHit = tr;
			//SetThink( ThinkFunction( this.Smack ) );
			//self.pev.nextthink = g_Engine.time + Math.RandomFloat( 0.2f, 0.4f );

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}

	bool Attack_MeleeEx( int iAnimation, int iAnimation2, float distance, int bodygroup, float firerate, float firerate_miss, bool bPunchAngle = true )
	{
		bool fDidHit = false;
		float flDamage = iDamage;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * distance;

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );

				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if( tr.flFraction >= 1.0 )
		{
			// miss
			self.SendWeaponAnim( iAnimation2, 0, bodygroup );

			EffectsFOVOFF();
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + firerate_miss;
			self.m_flTimeWeaponIdle = g_Engine.time + firerate_miss + 0.5f;

			// play wiff or swish sound
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, (bCustomMeleeSound) ? strMelee_Miss : "weapons/cbar_miss1.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );
		}
		else
		{
			// hit
			fDidHit = true;
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			self.SendWeaponAnim( iAnimation, 0, bodygroup );
			EffectsFOVOFF();

			if ( bPunchAngle )
				m_pPlayer.pev.punchangle.z = Math.RandomLong( -7, -5 );

			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;

			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextTertiaryAttack + firerate < g_Engine.time )
			{
				// first swing does full damage and will launch the enemy a bit
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB | DMG_LAUNCH );
			}
			else
			{
				// subsequent swings do 50% (Changed -Sniper/KernCore) (50% less damage)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.5, g_Engine.v_forward, tr, DMG_CLUB | DMG_LAUNCH );
			}	
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + firerate;
				self.m_flTimeWeaponIdle = g_Engine.time + firerate + 0.5f;

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
					if( pEntity.IsPlayer() )
					{
						PlayerGotHit( pEntity );
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}

					g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_ITEM, (bCustomMeleeSound) ? strMelee_Hit : "weapons/cbar_hitbod1.wav" , 1, ATTN_NORM );

					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR | BULLET_NONE );
				
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + firerate;
				self.m_flTimeWeaponIdle = g_Engine.time + firerate + 0.5f;
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.
				fvolbar = 1;

				// also play crowbar strike
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, (bCustomMeleeSound) ? strMelee_Hit_World : "weapons/cbar_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); 
			}

			// delay the decal a bit
			m_trHit = tr;
			//SetThink( ThinkFunction( this.Smack ) );
			//self.pev.nextthink = g_Engine.time + Math.RandomFloat( 0.2f, 0.4f );

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}
}