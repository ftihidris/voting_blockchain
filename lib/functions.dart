import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:voting_blockchain/constants.dart';

Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString('assets/abi.json');
  String contractAddress = contractAddress1;
  final contract = DeployedContract(ContractAbi.fromJson(abi, 'Vote2U'),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

Future<String> callFunction(String funcname, List<dynamic> args,
    Web3Client ethClient, String privateKey) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(funcname);
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
    ),
    chainId: null,
    fetchChainIdFromNetworkId: true,
  );
  return result;
}

Future<String> addCandidate(
    String name, String course, Web3Client ethClient) async {
  var response = await callFunction(
      'addCandidate', [name, course], ethClient, owner_private_key);
  print('Candidate added successfully');
  return response;
}

Future<bool> authorizeVoter(String address, Web3Client ethClient) async {
  var response = await callFunction(
      'authorizeVoter',
      [EthereumAddress.fromHex(address)],
      ethClient,
      owner_private_key);
  print('Voter Authorized successfully');
  return response == 'Success'; // Check for success message from the contract
}

Future<bool> verifyVoter(int studentId, Web3Client ethClient) async {
  try {
    final contract = await loadContract();
    final result = await ethClient.call(
      contract: contract,
      function: contract.function('isEligibleVoter'),
      params: [BigInt.from(studentId)],
    );

    if (result.isEmpty) {
      print('Error: Empty result received');
      return false;
    }

    bool isVerified = result[0]; // Assuming the result is a boolean indicating verification status
    return isVerified;
  } catch (e) {
    print('Error verifying voter: $e');
    return false; // Return false in case of any error
  }
}

Future<List<dynamic>> getCandidatesNum(Web3Client ethClient) async {
  List<dynamic> result = await ask('getNumCandidates', [], ethClient);
  return result;
}

Future<List<dynamic>> getTotalVotes(Web3Client ethClient) async {
  List<dynamic> result = await ask('getTotalVotes', [], ethClient);
  return result;
}

Future<List<dynamic>> candidateInfo(
    int candidateId, Web3Client ethClient) async {
  List<dynamic> result =
      await ask('getCandidateInfo', [BigInt.from(candidateId)], ethClient);
  return result;
}

Future<List<dynamic>> ask(
    String funcName, List<dynamic> args, Web3Client ethClient) async {
  final contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result = ethClient.call(
      contract: contract, function: ethFunction, params: args.toList());
  return result;
}

Future<String> vote(int candidateId, Web3Client ethClient) async {
  var response = await callFunction(
      "vote", [BigInt.from(candidateId)], ethClient, voter_private_key);
  print("Vote counted successfully");
  return response;
}
