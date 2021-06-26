// Include our baseclass
#include "baseclass"

class CPlayerUboa : CPlayerModelBase
{
	CPlayerUboa()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Uboa" );
		SetModel( "afterlife_uboa" );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/uboa/pain_fix.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/uboa/ded_fix.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/uboa/spawn_fix.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/uboa/medic_fix.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/uboa/takecover_fix.wav" );
	}
}
