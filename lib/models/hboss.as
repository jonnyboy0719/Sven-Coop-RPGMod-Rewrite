// Include our baseclass
#include "baseclass"

class CPlayerHBoss : CPlayerModelBase
{
	CPlayerHBoss()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Heavy Weapons Boss" );
		SetModel( "afterlife_hboss" );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/hboss/pain01.wav" );
		AddPainSound( "afterlife/player/hboss/pain02.wav" );
		AddPainSound( "afterlife/player/hboss/pain03.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/hboss/death01.wav" );
		AddDeathSound( "afterlife/player/hboss/death02.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/hboss/shame.wav" );
		AddSpawnSound( "afterlife/player/hboss/gogo.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/hboss/sowrong.wav" );
		AddMedicSound( "afterlife/player/hboss/duck.wav" );
		AddMedicSound( "afterlife/player/hboss/moremen.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/hboss/taunt01.wav" );
		AddGrenadeSound( "afterlife/player/hboss/taunt02.wav" );
		AddGrenadeSound( "afterlife/player/hboss/laugh.wav" );
	}
}
