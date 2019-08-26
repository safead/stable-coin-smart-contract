const { constants, expectEvent } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;
const { expect } = require('chai');
const EnfaceCurrency = artifacts.require('EnfaceCurrency');

const initialSupply = 100;

contract('EnfaceCurrency', function ([_, creator]) {
  beforeEach(async function () {
    this.token = await EnfaceCurrency.new(initialSupply, { from: creator });
  });

  it('has a name', async function () {
    expect(await this.token.name()).to.equal('Enface USDT');
  });

  it('has a symbol', async function () {
    expect(await this.token.symbol()).to.equal('EUSDT');
  });

  it('has 18 decimals', async function () {
    expect(await this.token.decimals()).to.be.bignumber.equal('18');
  });

  it('assigns the initial total supply to the creator', async function () {
    const totalSupply = await this.token.totalSupply();
    const creatorBalance = await this.token.balanceOf(creator);

    expect(creatorBalance).to.be.bignumber.equal(totalSupply);

    await expectEvent.inConstruction(this.token, 'Transfer', {
      from: ZERO_ADDRESS,
      to: creator,
      value: totalSupply,
    });
  });
});
