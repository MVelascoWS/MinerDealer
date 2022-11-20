task("get-owner", "Calls the MinerAPI actor.")
  .addParam("contract", "The MinerAPITest actor address")
  .setAction(async (taskArgs) => {
    const contractAddr = taskArgs.contract
    const networkId = network.name
    console.log("Reading MinerAPITest on network ", networkId)
    const MinerAPITest = await ethers.getContractFactory("MinerMockTest")

    //Get signer information
    const accounts = await ethers.getSigners()
    const signer = accounts[0]


    const minerAPITestContract = new ethers.Contract(contractAddr, MinerAPITest, signer)
    let result = await minerAPITestContract.mock_set_owner_test()
    console.log("Owner is: ", result)
  })

module.exports = {}