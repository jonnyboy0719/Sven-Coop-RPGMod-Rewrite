// Include our baseclass
#include "baseclass"

class CPlayerMself : CPlayerModelBase
{
	CPlayerMself()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Elfi" );
		SetModel( "afterlife_mself" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/mself/pain01.wav" );
		AddPainSound( "afterlife/player/mself/pain02.wav" );
		AddPainSound( "afterlife/player/mself/pain03.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/mself/death.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/mself/spawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/mself/medic.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/mself/takecover.wav" );
	}
}
