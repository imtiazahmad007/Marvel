const {expect, use} = require('chai');
const {deployContract, MockProvider, solidity} = require('ethereum-waffle');
const SwagToken = require('../build/SwagToken.json');
use(solidity);

describe('BasicToken', () => {
  const [wallet, walletTo] = new MockProvider().getWallets();
  let token;

  beforeEach(async () => {
    token = await deployContract(wallet, SwagToken, ['SwagToken', 'SWAG']);
  });

  it('Assigns initial balance', async () => {
    expect(await token.balanceOf(wallet.address)).to.equal('1000000000000000000000000000');
  });

  it('Transfer emits event', async () => {
    await expect(token.transfer(walletTo.address, 7))
      .to.emit(token, 'Transfer')
      .withArgs(wallet.address, walletTo.address, 7);
  });

  it('Can not transfer above the amount', async () => {
    await expect(token.transfer(walletTo.address, '1000000000000000000000000001'))
      .to.be.revertedWith('ERC20: transfer amount exceeds balance');
  });

  it('Send transaction changes receiver balance', async () => {
    await expect(() => wallet.sendTransaction({to: walletTo.address, gasPrice: 0, value: 200}))
      .to.changeBalance(walletTo, 200);
  });

  it('Send transaction changes sender and receiver balances', async () => {
    await expect(() =>  wallet.sendTransaction({to: walletTo.address, gasPrice: 0, value: 200}))
      .to.changeBalances([wallet, walletTo], [-200, 200]);
  });
});