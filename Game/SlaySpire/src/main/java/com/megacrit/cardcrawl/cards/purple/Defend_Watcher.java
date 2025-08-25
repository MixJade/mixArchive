package com.megacrit.cardcrawl.cards.purple;

import com.megacrit.cardcrawl.actions.common.DrawCardAction;
import com.megacrit.cardcrawl.actions.common.GainBlockAction;
import com.megacrit.cardcrawl.actions.common.HealAction;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;

/**
 * 观者基础防御
 *
 * @since 2025-08-24 23:06:13
 */
@SuppressWarnings("unused")
public class Defend_Watcher extends AbstractCard {
    public static final String ID = "Defend_P";
    private static final CardStrings cardStrings;

    public Defend_Watcher() {
        // 费用0
        super("Defend_P", cardStrings.NAME, "purple/skill/defend", 0, cardStrings.DESCRIPTION, CardType.SKILL, CardColor.PURPLE, CardRarity.BASIC, CardTarget.SELF);
        this.baseBlock = 9; // 9点防御
        this.baseMagicNumber = 9; // 9点回血
        this.magicNumber = this.baseMagicNumber;
        this.tags.add(CardTags.STARTER_DEFEND);
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        this.addToBot(new GainBlockAction(p, p, this.block));
        // 回血
        this.addToBot(new HealAction(p, p, this.magicNumber));
        // 摸牌2张
        this.addToBot(new DrawCardAction(p, 2));
    }

    public AbstractCard makeCopy() {
        return new Defend_Watcher();
    }

    public void upgrade() {
        if (!this.upgraded) {
            this.upgradeName();
            this.upgradeBlock(3);
        }

    }

    static {
        cardStrings = CardCrawlGame.languagePack.getCardStrings("Defend_P");
        cardStrings.DESCRIPTION += " NL 回复 !M! 生命。 NL 摸2牌。";
    }
}
