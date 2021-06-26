namespace Populate
{
	void PopulateSkills()
	{
		if ( !g_SkillMenu.ShouldAddItems() ) return;
		if ( !g_SkillMenuEx.ShouldAddItems() ) return;
		
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Vitality", Menu::SKILL_HEALTH, AB_HEALTH_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Superior Armor", Menu::SKILL_ARMOR, AB_ARMOR_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Health Regeneration", Menu::SKILL_HEALTH_REGEN, AB_HEALTH_REGEN_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Nano Armor", Menu::SKILL_ARMOR_REGEN, AB_ARMOR_REGEN_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "The Magic Pocket", Menu::SKILL_GOTG_AMMO, AB_AMMO_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "A Gift From The Gods", Menu::SKILL_GOTG_WEAPON, AB_WEAPON_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Icarus Potion", Menu::SKILL_DOUBLEJUMP, AB_DOUBLEJUMP_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "The Warrior's Battlecry", Menu::SKILL_BATTLECRY, AB_AURA_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Holy Armor", Menu::SKILL_HOLYARMOR, AB_HOLYGUARD_MAX ) );
		
		// Point increase menu
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 1 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 5 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 10 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 15 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 20 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 25 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 50 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 100 ) );
	}
}