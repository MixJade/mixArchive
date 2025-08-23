package com.megacrit.cardcrawl.cards.red;

import com.megacrit.cardcrawl.actions.AbstractGameAction.AttackEffect;
import com.megacrit.cardcrawl.actions.animations.VFXAction;
import com.megacrit.cardcrawl.actions.common.*;
import com.megacrit.cardcrawl.cards.AbstractCard;
import com.megacrit.cardcrawl.cards.DamageInfo;
import com.megacrit.cardcrawl.characters.AbstractPlayer;
import com.megacrit.cardcrawl.core.CardCrawlGame;
import com.megacrit.cardcrawl.localization.CardStrings;
import com.megacrit.cardcrawl.monsters.AbstractMonster;
import com.megacrit.cardcrawl.powers.VulnerablePower;
import com.megacrit.cardcrawl.vfx.combat.HemokinesisEffect;

/**
 * 铁甲战士的基础卡：沉痛打击
 *
 * @since 2025-08-23 10:16:54
 */
@SuppressWarnings("unused")
public class Bash extends AbstractCard {
    public static final String ID = "Bash";
    private static final CardStrings cardStrings;

    public Bash() {
        super("Bash", cardStrings.NAME, "red/attack/bash", 0, cardStrings.DESCRIPTION, CardType.ATTACK, CardColor.RED, CardRarity.BASIC, CardTarget.ENEMY);
        this.baseDamage = 8;
        this.baseMagicNumber = 2; // 两层易伤
        this.magicNumber = this.baseMagicNumber;
        this.cardsToPreview = new Feed(); // 添加狂宴
    }

    public void use(AbstractPlayer p, AbstractMonster m) {
        // 消耗手牌
        this.addToBot(new ExhaustAction(this.magicNumber, false, true, true));
        // 箭头指向怪物
        if (m != null) {
            this.addToBot(new VFXAction(new HemokinesisEffect(p.hb.cX, p.hb.cY, m.hb.cX, m.hb.cY), 0.5F));
        }
        // 主角生命设为1
        int loseSelfHp = p.currentHealth - 1;
        this.addToBot(new LoseHPAction(p, p, loseSelfHp));
        // 怪物生命设为1
        int loseMonsterHp = this.baseDamage;
        if (m != null) {
            loseMonsterHp = m.currentHealth - 1;
        }
        this.addToBot(new DamageAction(m, new DamageInfo(p, loseMonsterHp, this.damageTypeForTurn), AttackEffect.BLUNT_HEAVY));
        // 添加易伤
        this.addToBot(new ApplyPowerAction(m, p, new VulnerablePower(m, this.magicNumber, false), this.magicNumber));
        // 添加狂宴
        this.addToBot(new MakeTempCardInHandAction(new Feed(), 1));
    }

    public void upgrade() {
        if (!this.upgraded) {
            this.upgradeName();
            this.upgradeDamage(2);
            this.upgradeMagicNumber(3);
        }
    }

    public AbstractCard makeCopy() {
        return new Bash();
    }

    static {
        cardStrings = CardCrawlGame.languagePack.getCardStrings("Bash");
        cardStrings.DESCRIPTION = "消耗 !M! 张手牌 。 NL 双方生命都设为1 NL 给予 !M! 层 易伤 。 NL 获得 *狂宴 。";
    }
}
