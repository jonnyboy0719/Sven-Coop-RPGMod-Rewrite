// Include our baseclass
#include "baseclass"

class CPlayerBroboDonor : CPlayerModelBase
{
	CPlayerBroboDonor()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Brobo: Donor" );
		SetModel( "afterlife_robo_donor" );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/robo/pain.wav" );
		AddPainSound( "afterlife/player/robo/woop.wav" );
		AddPainSound( "afterlife/player/robo/ass.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/robo/death.wav" );
		AddDeathSound( "afterlife/player/robo/death2.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/robo/spawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/robo/health.wav" );
		AddMedicSound( "afterlife/player/robo/molested.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/robo/no.wav" );
		AddGrenadeSound( "afterlife/player/robo/gg.wav" );
	}
}
