// Include our baseclass
#include "baseclass"

class CPlayerSeriousSam : CPlayerModelBase
{
	CPlayerSeriousSam()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Serious Sam" );
		SetModel( "afterlife_ssam" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/ssam/pain1.wav" );
		AddPainSound( "afterlife/player/ssam/pain2.wav" );
		AddPainSound( "afterlife/player/ssam/pain3.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/ssam/death1.wav" );
		AddDeathSound( "afterlife/player/ssam/death2.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/ssam/spawn1.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/ssam/medic1.wav" );
		AddMedicSound( "afterlife/player/ssam/medic2.wav" );
		AddMedicSound( "afterlife/player/ssam/medic3.wav" );
		AddMedicSound( "afterlife/player/ssam/medic4.wav" );
		AddMedicSound( "afterlife/player/ssam/medic5.wav" );
		AddMedicSound( "afterlife/player/ssam/medic6.wav" );
		AddMedicSound( "afterlife/player/ssam/medic7.wav" );
		AddMedicSound( "afterlife/player/ssam/medic8.wav" );
		AddMedicSound( "afterlife/player/ssam/medic9.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/ssam/grenade1.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade2.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade3.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade4.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade5.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade6.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade7.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade8.wav" );
		AddGrenadeSound( "afterlife/player/ssam/grenade9.wav" );
	}
}
