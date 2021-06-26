// Include our baseclass
#include "baseclass"

class CPlayerNekoPara_Coconut : CPlayerModelBase
{
	CPlayerNekoPara_Coconut()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Coconut (NekoPara)" );
		SetModel( "NekoPara_Coconut" );
		AddSounds();
	}
	
	void CustomSpawn( CBasePlayer@ pPlayer )
	{
		//g_SCRPGCore.CheckForSpecificAchievement( pPlayer, "playermodel_nekopara" );
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/nekopara/coconut_hiss01.wav" );
		AddPainSound( "afterlife/player/nekopara/coconut_angry_nyan01.wav" );
		AddPainSound( "afterlife/player/nekopara/coconut_pain01.wav" );
		AddPainSound( "afterlife/player/nekopara/coconut_pain02.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/nekopara/coconut_death01.wav" );
		AddDeathSound( "afterlife/player/nekopara/coconut_sigh01.wav" );
		AddDeathSound( "afterlife/player/nekopara/coconut_sigh02.wav" );
		AddDeathSound( "afterlife/player/nekopara/coconut_sigh03.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/nekopara/coconut_spawn01.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/nekopara/coconut_nyan01.wav" );
		AddMedicSound( "afterlife/player/nekopara/coconut_nyan02.wav" );
		AddMedicSound( "afterlife/player/nekopara/coconut_nyan03.wav" );
		AddMedicSound( "afterlife/player/nekopara/coconut_nyan04.wav" );
		AddMedicSound( "afterlife/player/nekopara/coconut_nyan05.wav" );
		AddMedicSound( "afterlife/player/nekopara/coconut_nyan06.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/nekopara/coconut_purr01.wav" );
		AddGrenadeSound( "afterlife/player/nekopara/coconut_purr02.wav" );
	}
}
