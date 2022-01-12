

/////////////////////////////////////  deploy  /////////////////////////////////////
const Explorer = artifacts.require("Explorer");
const Explore = artifacts.require("Explore");
const ISP = artifacts.require("ISP");
const Monster = artifacts.require("Monster");
const Hunt = artifacts.require("Hunt");
const Train = artifacts.require("Train");
const ExplorerFactory = artifacts.require("ExplorerFactory");
const Api = artifacts.require("./api/Api");

module.exports = async function (deployer) {
  await deployer.deploy(Explorer);
  await deployer.deploy(Explore);
  await deployer.deploy(ISP);
  await deployer.deploy(Monster);
  await deployer.deploy(Hunt);
  await deployer.deploy(Train);
  await deployer.deploy(ExplorerFactory);
  await deployer.deploy(Api);

  const e = await Explorer.deployed();
  const e1 = await Explore.deployed();
  const i = await ISP.deployed();
  const t = await Train.deployed();
  const f = await ExplorerFactory.deployed();
  const h = await Hunt.deployed();
  const m = await Monster.deployed();
  const a = await Api.deployed();

  await e.setExplore(e1.address);
  await e.setExplorerFactoryClient(f.address);
  await e.setTrain(t.address);
  await e.setISPClient(i.address);
  await i.setMinter(e1.address, true);
  await i.setMinter(e.address, true);
  await e1.setNFTClient(e.address);
  await e1.setISPClient(i.address);
  await t.setNFTClient(e.address);
  await f.setMinter(e.address, true);
  await f.pushItem(1,1,1,1);
  await e.setHunt(h.address);
  await i.setMinter(h.address, true);
  await h.setExplorer(e.address);
  await h.setMonster(m.address);
  await h.setIsp(i.address);
  await a.setExplorer(e.address);
  await a.setTrain(t.address);
  await a.setExplore(e1.address);
  await a.setHunt(h.address);
};

