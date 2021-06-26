// Include our baseclass
#include "baseclass"

class CPlayerBigSmoke : CPlayerModelBase
{
	CPlayerBigSmoke()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Bigsmoke" );
		SetModel( "afterlife_bigsmoke" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/bsmoke/pain.wav" );
		AddPainSound( "afterlife/player/bsmoke/pain2.wav" );
		AddPainSound( "afterlife/player/bsmoke/pain3.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/bsmoke/ded.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/bsmoke/spawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/bsmoke/medic.wav" );
		AddMedicSound( "afterlife/player/bsmoke/medic2.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/bsmoke/takecover.wav" );
		AddGrenadeSound( "afterlife/player/bsmoke/takecover2.wav" );
	}
}
