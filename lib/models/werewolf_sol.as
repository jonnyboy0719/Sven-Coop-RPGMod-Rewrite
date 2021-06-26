// Include our baseclass
#include "baseclass"

class CPlayerWereWolfSoldier : CPlayerModelBase
{
	CPlayerWereWolfSoldier()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Werewolf Soldier" );
		SetModel( "afterlife_werewolf_sol" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/werewolf/onpain1_new.wav" );
		AddPainSound( "afterlife/player/werewolf/onpain2_new.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/werewolf/ondeath.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/werewolf/onspawn.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/werewolf/medic1.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/werewolf/grenade1.wav" );
	}
}
