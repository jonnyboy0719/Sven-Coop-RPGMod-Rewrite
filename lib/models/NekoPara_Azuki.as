// Include our baseclass
#include "baseclass"

class CPlayerNekoPara_Azuki : CPlayerModelBase
{
	CPlayerNekoPara_Azuki()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Azuki (NekoPara)" );
		SetModel( "NekoPara_Azuki" );
		AddSounds();
	}
	
	void CustomSpawn( CBasePlayer@ pPlayer )
	{
		//g_SCRPGCore.CheckForSpecificAchievement( pPlayer, "playermodel_nekopara" );
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/nekopara/azuki_angry_nyan01.wav" );
		AddPainSound( "afterlife/player/nekopara/azuki_pain01.wav" );
		AddPainSound( "afterlife/player/nekopara/azuki_angry01.wav" );
		AddPainSound( "afterlife/player/nekopara/azuki_angry02.wav" );
		AddPainSound( "afterlife/player/nekopara/azuki_angry03.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/nekopara/azuki_death01.wav" );
		AddDeathSound( "afterlife/player/nekopara/azuki_death02.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/nekopara/azuki_spawn01.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/nekopara/azuki_nyan01.wav" );
		AddMedicSound( "afterlife/player/nekopara/azuki_nyan02.wav" );
		AddMedicSound( "afterlife/player/nekopara/azuki_nyan03.wav" );
		AddMedicSound( "afterlife/player/nekopara/azuki_nyan04.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/nekopara/azuki_laugth01.wav" );
		AddGrenadeSound( "afterlife/player/nekopara/azuki_laugth02.wav" );
	}
}
