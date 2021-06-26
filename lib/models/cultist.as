// Include our baseclass
#include "baseclass"

class CPlayerCultist : CPlayerModelBase
{
	CPlayerCultist()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Cultist" );
		SetModel( "afterlife_follower" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/follower/paina.wav" );
		AddPainSound( "afterlife/player/follower/painb.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/follower/death.wav" );
		AddDeathSound( "afterlife/player/follower/death2_fix.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/follower/spawn_fix.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/follower/insulta.wav" );
		AddMedicSound( "afterlife/player/follower/insultc.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/follower/insultb_fix.wav" );
		AddGrenadeSound( "afterlife/player/follower/insultc.wav" );
	}
}
