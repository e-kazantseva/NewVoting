const { inputToConfig } = require("@ethereum-waffle/compiler");
const { getContractFactory } = require("@nomiclabs/hardhat-ethers/types");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe ("voteCon", function(){
  let acc1
  let acc2
  let acc3
  let acc4
  let acc5
  let acc6
  let _voteCon
  const n1 = "abc"
  const n2 = "aqwe"
  const n3 = "zxc"
  beforeEach(async function(){
    [acc1, acc2, acc3, acc4, acc5, acc6] = await ethers.getSigners();
    const voteCon = await ethers.getContractFactory("voteCon", acc1);
    _voteCon = await voteCon.deploy()
    await _voteCon.deployed()
  })

  it("it should be deployed", async function(){
    expect(_voteCon.address).to.be.properAddress
  })

  it("it should be zero balance", async function(){
    const balance = await _voteCon.balance()
    expect(balance).to.eq(0)
  })

  it("it should be created", async function(){
    await _voteCon.connect(acc1).createVoting([n1, n2, n3], [acc2, acc3, acc4])
    // await _createVoting.wait()
    // const votingDate = await _voteCon.connect(acc1).votingDate(1)
    // expect(votingDate.numberOfVoting).to.equal(1)
  })
})
