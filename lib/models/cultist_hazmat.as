// Include our baseclass
#include "baseclass"

class CPlayerCultistHazmat : CPlayerModelBase
{
	CPlayerCultistHazmat()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Hazmat Cultist" );
		SetModel( "afterlife_hazmat" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/hazmat/pain1.wav" );
		AddPainSound( "afterlife/player/hazmat/pain2.wav" );
		AddPainSound( "afterlife/player/hazmat/pain3.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/hazmat/death.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/hazmat/mayhem.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/hazmat/medic1.wav" );
		AddMedicSound( "afterlife/player/hazmat/medic2.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/hazmat/takecover1.wav" );
		AddGrenadeSound( "afterlife/player/hazmat/takecover2.wav" );
	}
}
