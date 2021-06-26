// Include our baseclass
#include "baseclass"

class CPlayerSolidSnake : CPlayerModelBase
{
	CPlayerSolidSnake()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Solid Snake" );
		SetModel( "afterlife_snake" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/snake/pain1.wav" );
		AddPainSound( "afterlife/player/snake/pain2.wav" );
		AddPainSound( "afterlife/player/snake/pain3.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/snake/death.wav" );
		AddDeathSound( "afterlife/player/snake/death2.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/snake/spawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/snake/medic1.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/snake/alert_fix.wav" );
	}
}
