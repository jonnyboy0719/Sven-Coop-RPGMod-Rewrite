// Include our baseclass
#include "baseclass"

class CPlayerNsMarine : CPlayerModelBase
{
	CPlayerNsMarine()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "NSMarine" );
		SetModel( "afterlife_nsmarine" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/nsmarine/pain1.wav" );
		AddPainSound( "afterlife/player/nsmarine/pain2.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/nsmarine/death.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/nsmarine/spawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/nsmarine/medic1.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/nsmarine/grenade1.wav" );
	}
}
