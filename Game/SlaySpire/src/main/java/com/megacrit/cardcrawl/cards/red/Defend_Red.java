package com.megacrit.cardcrawl.cards.red;

import com.megacrit.cardcrawl.actions.common.GainBlockAction;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.core.Settings;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;

/**
 * 铁甲战士的基础卡：防御
 *
 * @since 2025-08-15 21:53:31
 */
@SuppressWarnings("unused")
public class Defend_Red extends AbstractCard {
    public static final String ID = "Defend_R";
    private static final CardStrings cardStrings;

    public Defend_Red() {
        // 花费改为0
        super("Defend_R", cardStrings.NAME, "red/skill/defend", 0, cardStrings.DESCRIPTION, CardType.SKILL, CardColor.RED, CardRarity.BASIC, CardTarget.SELF);
        // 格挡值改为50
        this.baseBlock = 50;
        this.tags.add(CardTags.STARTER_DEFEND);
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        if (Settings.isDebug) {
            this.addToBot(new GainBlockAction(p, p, 50));
        } else {
            this.addToBot(new GainBlockAction(p, p, this.block));
        }

    }

    public void upgrade() {
        if (!this.upgraded) {
            this.upgradeName();
            this.upgradeBlock(3);
        }

    }

    public AbstractCard makeCopy() {
        return new Defend_Red();
    }

    static {
        cardStrings = CardCrawlGame.languagePack.getCardStrings("Defend_R");
    }
}
