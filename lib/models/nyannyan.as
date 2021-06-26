// Include our baseclass
#include "baseclass"

class CPlayerNyanNyan : CPlayerModelBase
{
	CPlayerNyanNyan()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Nyan Nyan" );
		SetModel( "afterlife_nyannyan" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// Spawn Sound
		AddSpawnSound( "afterlife/player/nyanmyan/nyannyan.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/nyanmyan/meow.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/nyanmyan/meow.wav" );
	}
}
