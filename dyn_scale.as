CCVar@ g_dynscale_fakescale;
CCVar@ g_dynscale_debug;
CCVar@ g_dynscale_bonus_score;
CCVar@ g_dynscale_bonus_multiply;
CCVar@ g_dynscale_amount;
CCVar@ g_dynscale_amount_bullets;
CCVar@ g_dynscale_amount_player;
CCVar@ g_dynscale_amount_player_max;
CCVar@ g_dynscale_amount_monster;
CCVar@ g_dynscale_amount_monster_max;

const float DYNSCALE_PLAYER = 0.05f;
const float DYNSCALE_NPC = 0.25f;
const float DYNSCALE_BULLET = 0.25f;
const float DYNSCALE_DAMAGE = 11.0f;

final class CDynamicDifficulty
{
	// Default
	private float flMultiplier_Player = DYNSCALE_PLAYER;
	private float flMultiplier_Scale = DYNSCALE_NPC;
	private float flMultiplier_Bullets = DYNSCALE_BULLET;
	private float flMonsterDamage_Scale = DYNSCALE_DAMAGE;
	private array<double> sk_vars_def = {
		150.0, // sk_agrunt_health
		20.6, // sk_agrunt_dmg_punch
		256.0, // sk_agrunt_melee_engage_distance
		30.8, // sk_agrunt_berserker_dmg_punch
		500.0, // sk_apache_health
		50.0, // sk_barnacle_health
		18.0, // sk_barnacle_bite
		65.0, // sk_barney_health
		110.0, // sk_bullsquid_health
		25.5, // sk_bullsquid_dmg_bite
		45.5, // sk_bullsquid_dmg_whip
		15.0, // sk_bullsquid_dmg_spit
		1.1, // sk_bigmomma_health_factor
		60.0, // sk_bigmomma_dmg_slash
		140.0, // sk_bigmomma_dmg_blast
		260.0, // sk_bigmomma_radius_blast
		1000.0, // sk_gargantua_health
		50.2, // sk_gargantua_dmg_slash
		0.9, // sk_gargantua_dmg_fire
		100.0, // sk_gargantua_dmg_stomp
		50.0, // sk_hassassin_health
		20.2, // sk_headcrab_health
		12.5, // sk_headcrab_dmg_bite
		100.0, // sk_hgrunt_health
		51.0, // sk_hgrunt_kick
		100.0, // sk_hgrunt_gspeed
		60.0, // sk_houndeye_health
		15.0, // sk_houndeye_dmg_blast
		80.0, // sk_islave_health
		11.8, // sk_islave_dmg_claw
		24.4, // sk_islave_dmg_clawrake
		0.8, // sk_islave_dmg_zap
		350.0, // sk_ichthyosaur_health
		30.0, // sk_ichthyosaur_shake
		3.0, // sk_leech_health
		0.2, // sk_leech_dmg_bite
		90.0, // sk_controller_health
		0.5, // sk_controller_dmgzap
		900.0, // sk_controller_speedball
		0.3, // sk_controller_dmgball
		900.0, // sk_nihilanth_health
		1.0, // sk_nihilanth_zap
		50.0, // sk_scientist_health
		2.0, // sk_snark_health
		11.2, // sk_snark_dmg_bite
		11.4, // sk_snark_dmg_pop
		100.0, // sk_zombie_health
		40.0, // sk_zombie_dmg_one_slash
		40.5, // sk_zombie_dmg_both_slash
		200.0, // sk_turret_health
		80.0, // sk_miniturret_health
		80.0, // sk_sentry_health
		600.0, // sk_babygargantua_health
		25.5, // sk_babygargantua_dmg_slash
		0.88, // sk_babygargantua_dmg_fire
		50.5, // sk_babygargantua_dmg_stomp
		200.0, // sk_hwgrunt_health
		0.8, // sk_rgrunt_explode
		40.5, // sk_massassin_sniper
		65.0, // sk_otis_health
		110.0, // sk_zombie_barney_health
		40.0, // sk_zombie_barney_dmg_one_slash
		40.5, // sk_zombie_barney_dmg_both_slash
		150.0, // sk_zombie_soldier_health
		40.0, // sk_zombie_soldier_dmg_one_slash
		40.5, // sk_zombie_soldier_dmg_both_slash
		200.5, // sk_gonome_health
		30.0, // sk_gonome_dmg_one_slash
		30.0, // sk_gonome_dmg_guts
		30.7, // sk_gonome_dmg_one_bite
		60.0, // sk_pitdrone_health
		25.5, // sk_pitdrone_dmg_bite
		25.5, // sk_pitdrone_dmg_whip
		25.2, // sk_pitdrone_dmg_spit
		200.0, // sk_shocktrooper_health
		12.5, // sk_shocktrooper_kick
		10.8, // sk_shocktrooper_maxcharge
		800.0, // sk_tor_health
		55.0, // sk_tor_punch
		11.8, // sk_tor_energybeam
		15.0, // sk_tor_sonicblast
		350.0, // sk_voltigore_health
		30.5, // sk_voltigore_dmg_punch
		40.5, // sk_voltigore_dmg_beam
		750.0, // sk_tentacle
		600.0, // sk_blkopsosprey
		600.0, // sk_osprey
		123.0, // sk_stukabat
		12.0, // sk_stukabat_dmg_bite
		50.0, // sk_sqknest_health
		450.0, // sk_kingpin_health
		0.2, // sk_kingpin_lightning
		0.5, // sk_kingpin_tele_blast
		0.8, // sk_kingpin_plasma_blast
		40.0, // sk_kingpin_melee
		500.0 // sk_kingpin_telefrag
	};

	private array<double> sk_vars_bullets_def = {
		0.5, // sk_12mm_bullet
		0.3, // sk_9mmAR_bullet
		0.3, // sk_9mm_bullet
		0.3, // sk_hornet_dmg
		0.4, // sk_otis_bullet
		0.5, // sk_grunt_buckshot
		0.23 // sk_556_bullet
	};

	private array<string> sk_vars_bullets = {
		"sk_12mm_bullet",
		"sk_9mmAR_bullet",
		"sk_9mm_bullet",
		"sk_hornet_dmg",
		"sk_otis_bullet",
		"sk_grunt_buckshot",
		"sk_556_bullet"
	};

	private array<string> sk_vars = {
		"sk_agrunt_health",
		"sk_agrunt_dmg_punch",
		"sk_agrunt_melee_engage_distance",
		"sk_agrunt_berserker_dmg_punch",
		"sk_apache_health",
		"sk_barnacle_health",
		"sk_barnacle_bite",
		"sk_barney_health",
		"sk_bullsquid_health",
		"sk_bullsquid_dmg_bite",
		"sk_bullsquid_dmg_whip",
		"sk_bullsquid_dmg_spit",
		"sk_bigmomma_health_factor",
		"sk_bigmomma_dmg_slash",
		"sk_bigmomma_dmg_blast",
		"sk_bigmomma_radius_blast",
		"sk_gargantua_health",
		"sk_gargantua_dmg_slash",
		"sk_gargantua_dmg_fire",
		"sk_gargantua_dmg_stomp",
		"sk_hassassin_health",
		"sk_headcrab_health",
		"sk_headcrab_dmg_bite",
		"sk_hgrunt_health",
		"sk_hgrunt_kick",
		"sk_hgrunt_gspeed",
		"sk_houndeye_health",
		"sk_houndeye_dmg_blast",
		"sk_islave_health",
		"sk_islave_dmg_claw",
		"sk_islave_dmg_clawrake",
		"sk_islave_dmg_zap",
		"sk_ichthyosaur_health",
		"sk_ichthyosaur_shake",
		"sk_leech_health",
		"sk_leech_dmg_bite",
		"sk_controller_health",
		"sk_controller_dmgzap",
		"sk_controller_speedball",
		"sk_controller_dmgball",
		"sk_nihilanth_health",
		"sk_nihilanth_zap",
		"sk_scientist_health",
		"sk_snark_health",
		"sk_snark_dmg_bite",
		"sk_snark_dmg_pop",
		"sk_zombie_health",
		"sk_zombie_dmg_one_slash",
		"sk_zombie_dmg_both_slash",
		"sk_turret_health",
		"sk_miniturret_health",
		"sk_sentry_health",
		"sk_babygargantua_health",
		"sk_babygargantua_dmg_slash",
		"sk_babygargantua_dmg_fire",
		"sk_babygargantua_dmg_stomp",
		"sk_hwgrunt_health",
		"sk_rgrunt_explode",
		"sk_massassin_sniper",
		"sk_otis_health",
		"sk_zombie_barney_health",
		"sk_zombie_barney_dmg_one_slash",
		"sk_zombie_barney_dmg_both_slash",
		"sk_zombie_soldier_health",
		"sk_zombie_soldier_dmg_one_slash",
		"sk_zombie_soldier_dmg_both_slash",
		"sk_gonome_health",
		"sk_gonome_dmg_one_slash",
		"sk_gonome_dmg_guts",
		"sk_gonome_dmg_one_bite",
		"sk_pitdrone_health",
		"sk_pitdrone_dmg_bite",
		"sk_pitdrone_dmg_whip",
		"sk_pitdrone_dmg_spit",
		"sk_shocktrooper_health",
		"sk_shocktrooper_kick",
		"sk_shocktrooper_maxcharge",
		"sk_tor_health",
		"sk_tor_punch",
		"sk_tor_energybeam",
		"sk_tor_sonicblast",
		"sk_voltigore_health",
		"sk_voltigore_dmg_punch",
		"sk_voltigore_dmg_beam",
		"sk_tentacle",
		"sk_blkopsosprey",
		"sk_osprey",
		"sk_stukabat",
		"sk_stukabat_dmg_bite",
		"sk_sqknest_health",
		"sk_kingpin_health",
		"sk_kingpin_lightning",
		"sk_kingpin_tele_blast",
		"sk_kingpin_plasma_blast",
		"sk_kingpin_melee",
		"sk_kingpin_telefrag"
	};
	
	private array<string> sk_vars_player = {
		"sk_player_head",
		"sk_player_chest",
		"sk_player_stomach",
		"sk_player_arm",
		"sk_player_leg"
	};
	
	private array<string> sk_vars_monster = {
		"sk_monster_head",
		"sk_monster_chest",
		"sk_monster_stomach",
		"sk_monster_arm",
		"sk_monster_leg"
	};
	
	CDynamicDifficulty()
	{
		Clear();
	}
	
	void Clear()
	{
		flMultiplier_Player = DYNSCALE_PLAYER;
		flMultiplier_Scale = DYNSCALE_NPC;
		flMultiplier_Bullets = DYNSCALE_BULLET;
		flMonsterDamage_Scale = DYNSCALE_DAMAGE;
		UpdateDynamicScale();
	}
	
	float GetDynamicScale()
	{
		int min = 0;
		int max = 0;
		CBasePlayer@ pPlayer;
		for( int y = 1; y < g_Engine.maxClients; ++y )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( y );
			if ( pPlayer !is null )
				min++;
			max++;
		}
		// Override it, if we can
		if ( g_dynscale_fakescale !is null && g_dynscale_fakescale.GetInt() > 0 )
			min = g_dynscale_fakescale.GetInt();
		if ( min > max ) min = max;
		return float(min/max);
	}
	
	float BonusScore()
	{
		if ( g_dynscale_bonus_score is null ) return 0;
		if ( g_dynscale_bonus_multiply is null ) return 0;
		
		float flBonusScore = g_dynscale_bonus_score.GetFloat();
		int min = 0;
		int max = 0;
		CBasePlayer@ pPlayer;
		for( int y = 1; y < g_Engine.maxClients; ++y )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( y );
			if ( pPlayer !is null )
				min++;
			max++;
		}
		// Override it, if we can
		if ( g_dynscale_fakescale !is null && g_dynscale_fakescale.GetInt() > 0 )
			min = g_dynscale_fakescale.GetInt();
		if ( min > max ) min = max;
		
		float flMultiply = (g_dynscale_bonus_multiply.GetFloat()*min);
		flBonusScore += flMultiply;
		return flBonusScore;
	}
	
	private void CalculatePlayers()
	{
		int min = 0;
		int max = 0;
		int iPlayers = 0;
		float flTempScale = 0.25f;
		
		// Calculate the amount of players
		CBasePlayer@ pPlayer;
		for( int y = 1; y < g_Engine.maxClients; ++y )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( y );
			if ( pPlayer !is null )
				min++;
			max++;
		}
		
		// If iPlayers is 0, set it to 1
		if ( min == 0 )
			min = 1;
		
		// Override it, if we can
		if ( g_dynscale_fakescale !is null && g_dynscale_fakescale.GetInt() > 0 )
			min = g_dynscale_fakescale.GetInt();
		
		if ( min > max ) min = max;
		
		iPlayers = min;
		
		// How much we should scale it
		if ( g_dynscale_amount !is null )
			flTempScale = g_dynscale_amount.GetFloat();
		
		// Our final result
		flMultiplier_Scale = (flTempScale*iPlayers);
		
		// How much we should scale it
		if ( g_dynscale_amount_bullets !is null )
			flTempScale = g_dynscale_amount_bullets.GetFloat();
		
		// Our final result
		flMultiplier_Bullets = (flTempScale*iPlayers);
		
		// How much we should scale it (monster variant)
		if ( g_dynscale_amount_monster !is null )
			flTempScale = g_dynscale_amount_monster.GetFloat();
		
		// How much should we cap it at?
		if ( g_dynscale_amount_monster_max !is null && g_dynscale_amount_monster_max.GetInt() > 0 )
			iPlayers = g_dynscale_amount_monster_max.GetInt();
		
		// Max amount of player check
		if ( iPlayers > max )
			iPlayers = max;
		
		// Now do the same for monster damage scale
		// Except, we will divide the result
		flMonsterDamage_Scale = (flTempScale/iPlayers);
		
		iPlayers = min;
		
		// How much we should scale it (monster variant)
		if ( g_dynscale_amount_player !is null )
			flTempScale = g_dynscale_amount_player.GetFloat();
		
		// How much should we cap it at?
		if ( g_dynscale_amount_player_max !is null && g_dynscale_amount_player_max.GetInt() > 0 )
			iPlayers = g_dynscale_amount_player_max.GetInt();
		
		// Max amount of player check
		if ( iPlayers > max )
			iPlayers = max;
		
		// Now do the same for monster damage scale
		// Except, we will divide the result
		flMultiplier_Player = (flTempScale*iPlayers);
	}
	
	void UpdateDynamicScale()
	{
		CalculatePlayers();
		int iMax = sk_vars_def.size();
		for( int i = 0; i < iMax; ++i )
		{
			double dblScale = sk_vars_def[i];
			dblScale *= double(flMultiplier_Scale);
			string strValue = sk_vars[i] + " " + dblScale + "\n";
			g_EngineFuncs.ServerCommand( strValue );
			Debug( strValue );
		}
		
		// Player damage
		iMax = sk_vars_player.size();
		for( int i = 0; i < iMax; ++i )
		{
			double dblScale = 11.0; // Default value
			dblScale *= double(flMultiplier_Player);
			string strValue = sk_vars_player[i] + " " + dblScale + "\n";
			g_EngineFuncs.ServerCommand( strValue );
			Debug( strValue );
		}
		
		// Bullet Hell
		iMax = sk_vars_bullets_def.size();
		for( int i = 0; i < iMax; ++i )
		{
			double dblScale = sk_vars_bullets_def[i];
			dblScale *= double(flMultiplier_Bullets);
			string strValue = sk_vars_bullets[i] + " " + dblScale + "\n";
			g_EngineFuncs.ServerCommand( strValue );
			Debug( strValue );
		}
		
		// Monster damage
		iMax = sk_vars_monster.size();
		for( int i = 0; i < iMax; ++i )
		{
			double dblScale = 1.5; // Default value
			dblScale *= double(flMonsterDamage_Scale);
			string strValue = sk_vars_monster[i] + " " + dblScale + "\n";
			g_EngineFuncs.ServerCommand( strValue );
			Debug( strValue );
		}
	}
	
	void Debug( string strMsg )
	{
		if ( g_dynscale_debug is null ) return;
		if ( g_dynscale_debug.GetInt() < 1 ) return;
		g_EngineFuncs.ServerCommand( "echo \"" + strMsg + "\"" );
	}
	
	void ScaleCheck()
	{
		UpdateDynamicScale();
		g_Scheduler.SetTimeout( @this, "ScaleCheck", 1.0 );
	}
}
CDynamicDifficulty@ g_DynamicDifficultySystem;

void DynScale_RegisterHooks()
{
	@g_dynscale_debug = CCVar("dynscale_debug", 0, "Debug scaling", ConCommandFlag::AdminOnly);
	@g_dynscale_fakescale = CCVar("dynscale_fake", 0, "Fake scale the amount of players", ConCommandFlag::AdminOnly);
	@g_dynscale_bonus_score = CCVar("dynscale_bonus_score", 20, "The amount of bonus score you get (base score)\n\tThe higher the difficulty, this will be multiplied by dynscale_bonus_multiply", ConCommandFlag::AdminOnly);
	@g_dynscale_bonus_multiply = CCVar("dynscale_bonus_multiply", 11.5f, "The amount we should multiply with (from amount of players)", ConCommandFlag::AdminOnly);
	@g_dynscale_amount = CCVar("dynscale_amount", 0.35f, "The amount to scale with", ConCommandFlag::AdminOnly);
	@g_dynscale_amount_bullets = CCVar("dynscale_amount_bullets", 0.22f, "The amount to scale with", ConCommandFlag::AdminOnly);
	@g_dynscale_amount_player = CCVar("dynscale_amount_player", 0.012f, "The amount to scale with", ConCommandFlag::AdminOnly);
	@g_dynscale_amount_player_max = CCVar("dynscale_amount_player_cap", 8, "The cap amount (amount of players)", ConCommandFlag::AdminOnly);
	@g_dynscale_amount_monster = CCVar("dynscale_amount_monster", 1.5f, "The amount to scale with", ConCommandFlag::AdminOnly);
	@g_dynscale_amount_monster_max = CCVar("dynscale_amount_monster_cap", 5, "The cap amount (amount of players)", ConCommandFlag::AdminOnly);
}
