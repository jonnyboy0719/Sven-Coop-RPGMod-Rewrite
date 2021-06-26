// Include our baseclass
#include "baseclass"

class CPlayerMselfDemon : CPlayerModelBase
{
	CPlayerMselfDemon()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Demon Elfi" );
		SetModel( "afterlife_mself_demon" );
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
		AddSpawnSound( "afterlife/player/mself/spawn_demon.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/mself/medic.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/mself/takecover.wav" );
	}
}
