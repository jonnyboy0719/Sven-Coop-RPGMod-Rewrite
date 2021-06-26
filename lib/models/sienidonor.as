// Include our baseclass
#include "baseclass"

class CPlayerSieniDonor : CPlayerModelBase
{
	CPlayerSieniDonor()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Sieni: Donor" );
		SetModel( "afterlife_sieni_gold" );
		SetAllowedState( state_donator );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/sieni/pain.wav" );
		AddPainSound( "afterlife/player/sieni/pain2.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/sieni/ded.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/sieni/spawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/sieni/medic.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/sieni/takecover.wav" );
	}
}
