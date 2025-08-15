package com.megacrit.cardcrawl.cards.red;

import com.megacrit.cardcrawl.actions.AbstractGameAction.AttackEffect;
import com.megacrit.cardcrawl.actions.common.DamageAction;
import com.megacrit.cardcrawl.actions.common.DamageAllEnemiesAction;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.cards.DamageInfo;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.core.Settings;
import com.megacrit.cardcrawl.dungeons.AbstractDungeon;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;

/**
 * 铁甲战士的基础卡：打击
 * @since 2025-08-15 21:53:31
 */
@SuppressWarnings("unused")
public class Strike_Red extends AbstractCard {
    public static final String ID = "Strike_R";
    private static final CardStrings cardStrings;

    public Strike_Red() {
        // 花费改为0
        super("Strike_R", cardStrings.NAME, "red/attack/strike", 0, cardStrings.DESCRIPTION, CardType.ATTACK, CardColor.RED, CardRarity.BASIC, CardTarget.ENEMY);
        // 修改伤害为60
        this.baseDamage = 60;
        this.tags.add(CardTags.STRIKE);
        this.tags.add(CardTags.STARTER_STRIKE);
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        if (Settings.isDebug) {
            if (Settings.isInfo) {
                this.multiDamage = new int[AbstractDungeon.getCurrRoom().monsters.monsters.size()];

                for(int i = 0; i < AbstractDungeon.getCurrRoom().monsters.monsters.size(); ++i) {
                    this.multiDamage[i] = 150;
                }

                this.addToBot(new DamageAllEnemiesAction(p, this.multiDamage, this.damageTypeForTurn, AttackEffect.SLASH_DIAGONAL));
            } else {
                this.addToBot(new DamageAction(m, new DamageInfo(p, 150, this.damageTypeForTurn), AttackEffect.BLUNT_HEAVY));
            }
        } else {
            this.addToBot(new DamageAction(m, new DamageInfo(p, this.damage, this.damageTypeForTurn), AttackEffect.SLASH_DIAGONAL));
        }

    }

    public void upgrade() {
        if (!this.upgraded) {
            this.upgradeName();
            // 锻造升级后，伤害提升30
            this.upgradeDamage(30);
        }

    }

    public AbstractCard makeCopy() {
        return new Strike_Red();
    }

    static {
        cardStrings = CardCrawlGame.languagePack.getCardStrings("Strike_R");
    }
}
