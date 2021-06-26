// Include our actual files
#include "models/bigboss"
#include "models/bigsmoke"
#include "models/brobo"
#include "models/brobo_donor"
#include "models/captainkork"
#include "models/NekoPara_Azuki"
#include "models/NekoPara_Coconut"
#include "models/steve"
#include "models/serioussam"
#include "models/postal"
#include "models/werewolf"
#include "models/werewolf_sol"
#include "models/uboa"
#include "models/spetz1"
#include "models/spetz2"
#include "models/snake"
#include "models/sienigold"
#include "models/sienidonor"
#include "models/shygal"
#include "models/lycan"
#include "models/hunter"
#include "models/mself"
#include "models/mself_demon"
#include "models/masterson"
#include "models/hboss"
#include "models/cultist"
#include "models/cultist_hazmat"
#include "models/cultist_leader"
#include "models/nyannyan"
#include "models/nsmarine"

namespace Populate
{
	void PopulatePlayerModels()
	{
		CPlayerNsMarine m_nsmarine();
		CPlayerNyanNyan m_nyannyan();
		CPlayerBigBoss m_bigboss();
		CPlayerBigSmoke m_bigsmoke();
		CPlayerCaptainKork m_cptKrk();
		CPlayerBrobo m_brobo();
		CPlayerBroboDonor m_brobodonor();
		CPlayerNekoPara_Azuki m_nekopara_azuki();
		CPlayerNekoPara_Coconut m_nekopara_coconut();
		CPlayerSteve m_steve();
		CPlayerSeriousSam m_serioussam();
		CPlayerPostalDude m_postaldude();
		CPlayerWereWolf m_werewolf();
		CPlayerWereWolfSoldier m_werewolf_soldier();
		CPlayerUboa m_uboa();
		CPlayerSpetz1 m_spetz1();
		CPlayerSpetz2 m_spetz2();
		CPlayerSolidSnake m_afterlife_snake();
		CPlayerSieniGold m_sienigold();
		CPlayerSieniDonor m_sienidonor();
		CPlayerShyGal m_shygal();
		CPlayerLycan m_lycan();
		CPlayerHunter m_hunter();
		CPlayerMself m_mself();
		CPlayerMselfDemon m_mself_demon();
		CPlayerMasterson m_masterson();
		CPlayerHBoss m_heavyboss();
		CPlayerCultist m_cultist();
		CPlayerCultistHazmat m_cultist_hazmat();
		CPlayerCultistLeader m_cultist_leader();
	}
}