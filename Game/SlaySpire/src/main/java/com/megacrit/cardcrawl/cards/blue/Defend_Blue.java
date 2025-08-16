package com.megacrit.cardcrawl.cards.blue;

import com.megacrit.cardcrawl.actions.common.DrawCardAction;
import com.megacrit.cardcrawl.actions.common.GainBlockAction;
import com.megacrit.cardcrawl.actions.common.GainEnergyAction;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.core.Settings;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;

/**
 * 鸡煲基础攻击
 *
 * @since 2025-08-16 19:24:21
 */
@SuppressWarnings("unused")
public class Defend_Blue extends AbstractCard {
    public static final String ID = "Defend_B";
    private static final CardStrings cardStrings;

    public Defend_Blue() {
        super("Defend_B", cardStrings.NAME, "blue/skill/defend", 0, cardStrings.DESCRIPTION + " NL 抽 !M! 张牌 NL 获得 [B] ", CardType.SKILL, CardColor.BLUE, CardRarity.BASIC, CardTarget.SELF);
        this.baseBlock = 5;
        this.tags.add(CardTags.STARTER_DEFEND);
        // 拼接"快速检索"
        this.baseMagicNumber = 3;
        this.magicNumber = this.baseMagicNumber;
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        this.addToBot(new DrawCardAction(p, this.magicNumber)); // 拼接"快速检索"
        this.addToBot(new GainEnergyAction(1)); // 回复1点能量
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
        return new Defend_Blue();
    }

    static {
        cardStrings = CardCrawlGame.languagePack.getCardStrings("Defend_B");
    }
}
