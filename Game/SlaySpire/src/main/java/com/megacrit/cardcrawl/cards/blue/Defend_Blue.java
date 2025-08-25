package com.megacrit.cardcrawl.cards.blue;

import com.megacrit.cardcrawl.actions.common.ApplyPowerAction;
import com.megacrit.cardcrawl.actions.common.DrawCardAction;
import com.megacrit.cardcrawl.actions.common.GainBlockAction;
import com.megacrit.cardcrawl.actions.common.GainEnergyAction;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;
import com.megacrit.cardcrawl.powers.DexterityPower;
import com.megacrit.cardcrawl.powers.FocusPower;
import com.megacrit.cardcrawl.powers.StrengthPower;

/**
 * 鸡煲基础防御
 *
 * @since 2025-08-16 19:24:21
 */
@SuppressWarnings("unused")
public class Defend_Blue extends AbstractCard {
    public static final String ID = "Defend_B";
    private static final CardStrings cardStrings;

    public Defend_Blue() {
        super("Defend_B", cardStrings.NAME, "blue/skill/defend", 0,
                cardStrings.DESCRIPTION
                        + " NL 抽 !M! 张牌"
                        + " NL 加 !M! 集中、力量、敏捷"
                        + " NL 获得 [B] [B] [B] ",
                CardType.SKILL, CardColor.BLUE, CardRarity.BASIC, CardTarget.SELF);
        this.baseBlock = 5;
        this.tags.add(CardTags.STARTER_DEFEND);
        // 拼接"快速检索"
        this.baseMagicNumber = 3;
        this.magicNumber = this.baseMagicNumber;
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        this.addToBot(new GainBlockAction(p, p, this.block));//加防御
        this.addToBot(new GainEnergyAction(this.magicNumber)); // 回复能量
        this.addToBot(new ApplyPowerAction(p, p, new FocusPower(p, this.magicNumber), this.magicNumber)); // 加集中
        this.addToBot(new ApplyPowerAction(p, p, new StrengthPower(p, this.magicNumber), this.magicNumber)); // 加力量
        this.addToBot(new ApplyPowerAction(p, p, new DexterityPower(p, this.magicNumber), this.magicNumber)); // 加敏捷
        this.addToBot(new DrawCardAction(p, this.magicNumber)); // 摸牌
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
