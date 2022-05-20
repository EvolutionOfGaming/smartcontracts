

/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IEvolveStorage.sol";
import "./IEvolveBulkSender.sol";

interface IEvolveFactory{
    function updateStorage(IEvolveStorage _storageAddress) external returns(bool);

    function updateBulkSender(IEvolveBulkSender _bulkSender) external returns(bool);

    function updateTokenAddress(IERC20 _tokenAddress) external returns(bool);

    function addNewCompetion(uint256 _presetId, address[] calldata _teamA, address[] calldata _teamB , bool[] calldata _boolNeedReplace, uint256 _createAt) external returns(uint256 competitionId);
        
    function setCompetionWinner(uint256 _competionId, uint8 _winnerTeam) external returns(bool);

    function cancelCompetion(uint256 _competionId) external returns(bool);

    function updateFactoryAdmin(address _newAdminAddress) external returns(bool);
    function updateTokenRate(uint newRate) external returns(bool);
    function destroyFactory(address _newFactory) external returns(bool);

}