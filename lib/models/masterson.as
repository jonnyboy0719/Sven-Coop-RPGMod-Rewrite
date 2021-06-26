// Include our baseclass
#include "baseclass"

class CPlayerMasterson : CPlayerModelBase
{
	CPlayerMasterson()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Masterson" );
		SetModel( "afterlife_masterson" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/masterson/sharp01.wav" );
		AddPainSound( "afterlife/player/masterson/sharp02.wav" );
		AddPainSound( "afterlife/player/masterson/sharp03.wav" );
		AddPainSound( "afterlife/player/masterson/sharp04.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/masterson/death01.wav" );
		AddDeathSound( "afterlife/player/masterson/death02.wav" );
		AddDeathSound( "afterlife/player/masterson/death03.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/masterson/spawn01.wav" );
		AddSpawnSound( "afterlife/player/masterson/spawn02.wav" );
		AddSpawnSound( "afterlife/player/masterson/spawn03.wav" );
		AddSpawnSound( "afterlife/player/masterson/spawn04.wav" );
		AddSpawnSound( "afterlife/player/masterson/spawn05.wav" );
		AddSpawnSound( "afterlife/player/masterson/spawn06.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/masterson/medic01.wav" );
		AddMedicSound( "afterlife/player/masterson/medic02.wav" );
		AddMedicSound( "afterlife/player/masterson/medic03.wav" );
		AddMedicSound( "afterlife/player/masterson/medic04.wav" );
		AddMedicSound( "afterlife/player/masterson/medic05.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/masterson/lookout01.wav" );
		AddGrenadeSound( "afterlife/player/masterson/lookout02.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult01.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult02.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult03.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult04.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult05.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult06.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult07.wav" );
		AddGrenadeSound( "afterlife/player/masterson/insult08.wav" );
		AddGrenadeSound( "afterlife/player/masterson/nasty01.wav" );
		AddGrenadeSound( "afterlife/player/masterson/nasty02.wav" );
		AddGrenadeSound( "afterlife/player/masterson/nasty03.wav" );
	}
}
