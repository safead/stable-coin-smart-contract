require('openzeppelin-test-helpers');

const ContextMock = artifacts.require('ContextMock');
const ContextMockCaller = artifacts.require('ContextMockCaller');

const { shouldBehaveLikeRegularContext } = require('./behaviors/Context.behavior');

contract('Context', function ([_, sender]) {
  beforeEach(async function () {
    this.context = await ContextMock.new();
    this.caller = await ContextMockCaller.new();
  });

  shouldBehaveLikeRegularContext(sender);
});
