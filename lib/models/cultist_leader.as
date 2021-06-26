// Include our baseclass
#include "baseclass"

class CPlayerCultistLeader : CPlayerModelBase
{
	CPlayerCultistLeader()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Cultist Leader" );
		SetModel( "afterlife_hollow" );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/follower_demonic/pain01_fix.wav" );
		AddPainSound( "afterlife/player/follower_demonic/pain02_fix.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/follower_demonic/death01_fix.wav" );
		AddDeathSound( "afterlife/player/follower_demonic/death02_fix.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/follower_demonic/spawn01_fix.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/follower_demonic/insult01_fix.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/follower_demonic/insult02_fix.wav" );
	}
}
