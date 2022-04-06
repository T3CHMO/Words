const web3 = new Moralis.Web3(new Moralis.Web3.providers.HttpProvider("https://speedy-nodes-nyc.moralis.io/3a3640635f814031e9d233ba/eth/rinkeby"));
const coordinatorKey = ""; //<-- DO NOT SHARE

Moralis.Cloud.define("sign", async (request) => {
  const objId = request.params.objId;
  const query = new Moralis.Query("Word");
  query.equalTo("objectId", request.params.objId);
  const result = await query.find();
  if(result != 0){
    const hashedMessage = web3.utils.soliditySha3(result.get("user"), result.get("word"), result.get("definition"));
    return web3.eth.accounts.sign(hashedMessage, coordinatorKey);
  } 
  return 0;
});
