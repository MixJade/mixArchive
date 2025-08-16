package com.megacrit.cardcrawl.cards.red;

import com.megacrit.cardcrawl.actions.AbstractGameAction.AttackEffect;
import com.megacrit.cardcrawl.actions.common.ApplyPowerAction;
import com.megacrit.cardcrawl.actions.common.DamageAction;
import com.megacrit.cardcrawl.actions.common.DrawCardAction;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.cards.DamageInfo;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;
import com.megacrit.cardcrawl.powers.StrengthPower;
import com.megacrit.cardcrawl.powers.VulnerablePower;
import com.megacrit.cardcrawl.powers.WeakPower;

/**
 * 铁甲战士的基础卡：打击
 *
 * @since 2025-08-15 21:53:31
 */
@SuppressWarnings("unused")
public class Strike_Red extends AbstractCard {
    public static final String ID = "Strike_R";
    private static final CardStrings cardStrings;

    public Strike_Red() {
        // 花费改为0
        super("Strike_R", cardStrings.NAME, "red/attack/strike", 0, cardStrings.DESCRIPTION + " NL 抽 !M! 张牌 NL 给予 !M! 层 虚弱、易伤、失力", CardType.ATTACK, CardColor.RED, CardRarity.BASIC, CardTarget.ENEMY);
        // 修改伤害为60
        this.baseDamage = 60;
        this.tags.add(CardTags.STRIKE);
        this.tags.add(CardTags.STARTER_STRIKE);
        // 特技属性
        this.baseMagicNumber = 3;
        this.magicNumber = this.baseMagicNumber;
        // 保留
        this.selfRetain = true;
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        // 造成伤害
        this.addToBot(new DamageAction(m, new DamageInfo(p, this.damage, this.damageTypeForTurn), AttackEffect.SLASH_DIAGONAL));
        // 摸牌
        this.addToBot(new DrawCardAction(p, this.magicNumber));
        // 给予虚弱
        this.addToBot(new ApplyPowerAction(m, p, new WeakPower(m, this.magicNumber, false), this.magicNumber));
        // 给予易伤
        this.addToBot(new ApplyPowerAction(m, p, new VulnerablePower(m, this.magicNumber, false), this.magicNumber));
        // 削减力量
        this.addToBot(new ApplyPowerAction(m, p, new StrengthPower(m, -this.magicNumber), -this.magicNumber));
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
